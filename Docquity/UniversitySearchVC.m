//
//  UniversitySearchVC.m
//  Docquity
//
//  Created by Arimardan Singh on 11/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#import "UniversitySearchVC.h"
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "UniversityTVCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "UIImageView+Letters.h"
#import "AppDelegate.h"
#import "UILoadingView.h"

@interface UniversitySearchVC (){
    UIActivityIndicatorView*activityIndicator;
    NSString* universityId;
    NSString* universityName;
}

@end

@implementation UniversitySearchVC
@synthesize nilView,uni_nameListArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.nilView.hidden = NO;
    nilLbl.hidden = NO;
    self.searchBar.clipsToBounds = YES;
   //  self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //[self.spinner startAnimating];
   // self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);

    //self.tableView.tableFooterView = self.spinner;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = NO;
   // if (isback==YES) {
    [self.delegate UpdateInfoWithUniversityId:universityId update_university_name:universityName];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchBarActive) {
    return [self.uni_nameListArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // NSLog(@"heightForRowAtIndexPath");
    // Space cell's height
   return 76;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"UniversityTVCell";
    UniversityTVCell *unicell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!unicell) {
        unicell = [[UniversityTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
         if (searchBarActive) {
            NSString *uni_Name =nil;
            NSString*uni_id = nil;
            if([self.uni_nameListArr count]>0)
            {
                if([self.uni_nameListArr objectAtIndex:indexPath.row]){
                    NSDictionary* uni_nameDic=[self.uni_nameListArr objectAtIndex:indexPath.row];
                    if(uni_nameDic && [uni_nameDic isKindOfClass:[NSDictionary class]])
                    {
                        uni_Name = [NSString stringWithFormat:@"%@", [uni_nameDic objectForKey:@"university_name"]?[uni_nameDic  objectForKey:@"university_name"]:@""];
                        
                        uni_id = [NSString stringWithFormat:@"%@", [uni_nameDic objectForKey:@"university_id"]?[uni_nameDic  objectForKey:@"university_id"]:@""];
                    }
                }
            }
            if ([uni_Name isEqualToString:@""] || [uni_Name  isEqualToString:@"<null>"]) {
            }
            else {
                unicell.uni_namelbl.text= uni_Name;
            }
            //Create user ImageView
            unicell.universityImg.layer.cornerRadius = unicell.universityImg.frame.size.width / 2;
            unicell.universityImg.clipsToBounds = YES;
            [unicell.universityImg  setImageWithString:uni_Name color:nil circular:YES];
        }
        return unicell;
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        if(indexPath.row<[self.uni_nameListArr count]){
            NSDictionary *dict = [self.uni_nameListArr  objectAtIndex: indexPath.row];
         universityId  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"university_id"]];
         universityName  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"university_name"]];
         [self dismissViewControllerAnimated:YES completion:nil];
        // [self.navigationController pushViewController:lv animated:YES];
        }
    }
}

#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    //[self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    self.searchResults = [NSMutableArray arrayWithArray:[[dic valueForKey:@"keyword"] filteredArrayUsingPredicate:resultPredicate]];
    // NSLog(@"search result = %@",self.searchResults);
    [[dic valueForKey:@"keyword"] filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length>0) {
        // search and reload data source
        searchBarActive = YES;
        [self filterContentForSearchText:searchText
                                   scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                          objectAtIndex:[self.searchDisplayController.searchBar
                                                         selectedScopeButtonIndex]]];
        searchTxt=searchText;
        NSString *trimmedString = [searchTxt stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@""]) {
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
            [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
            dispatch_async(downloadQueue, ^{
                //do your downloading
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getUniveristityData];
                    //maybe some UI stuff
                    [[self.view.subviews lastObject] removeFromSuperview];
                });
            });
          //  dispatch_release(downloadQueue);

         }
    }    else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        self.tableView.hidden =YES;
        searchBarActive = NO;
        self.nilView.hidden = NO;
        nilLbl.hidden = NO;
        nilLbl.text = @"Search for University name";
    }
}

#pragma mark - backButtonAction
-(IBAction)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    // NSLog(@"searchBarCancelButtonClicked");
    [self layoutSubviews];
}

-(void)layoutSubviews{
    // [super la];
    [self.searchBar setShowsCancelButton:NO animated:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchBarActive = YES;
    [self.searchBar resignFirstResponder];
    NSString *trimmedString = [searchTxt stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![trimmedString isEqualToString:@""]) {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else{
            [self getUniveristityData];
            [activityIndicator startAnimating];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]forState:UIControlStateNormal];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    //    searchBarActive = NO;
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - get university search data
-(void)getUniveristityData{
  NSUserDefaults* userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]Getsearch_university:[NSString stringWithFormat:@"%@",[userdef valueForKey:API_Token]] keyword:searchTxt device_type:kDeviceType app_version:[userdef valueForKey:kAppVersion]  lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
        NSMutableDictionary *resposePost =[responseObject objectForKey:@"posts"];
        
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message = [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                self.tableView.hidden= NO;
                self.nilView.hidden = YES;
                nilLbl.hidden = YES;
                NSDictionary *universityDic= [resposePost objectForKey:@"data"];
                if ([universityDic isKindOfClass:[NSNull class]]||universityDic == nil)
                {
                    // tel is null
                }
                else {
                    self.uni_nameListArr = [[NSMutableArray alloc]init];
                    self.uni_nameListArr = [[universityDic objectForKey:@"university_list"] mutableCopy];
                    [self.uni_nameListArr  addObject:@{@"university_name":@"Other", @"university_id":@"0"}];
                    [self.tableView reloadData];
                }
              }
              else if([[resposePost valueForKey:@"status"]integerValue] == 0){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:message preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 7){
            [[AppDelegate appDelegate] hideIndicator];
            self.nilView.hidden = NO;
            nilLbl.hidden = NO;
            nilLbl.text = @"Sorry, we didn't find any results matching this search.";
            self.tableView.hidden= YES;
         }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
