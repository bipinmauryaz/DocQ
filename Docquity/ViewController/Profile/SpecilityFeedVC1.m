//
//  SpecilityFeedVC.m
//  Docquity
//
//  Created by Docquity-iOS on 13/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "SpecilityFeedVC.h"
#import "TLTextFeedCell.h"
#import "TLImageFeedCell.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"
#import "SVPullToRefresh.h"
#import "Localytics.h"
#import "SSCWhatsAppActivity.h"
#import "PermissionCheckYourSelfVC.h"
#import "UpdateFeed.h"
#import "newFeedPostViewController.h"
@interface SpecilityFeedVC ()
<
TLTextFeedCellDelegate,
TLImageFeedCellDelegate
>{
    UIRefreshControl *refreshControl;
}
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation SpecilityFeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 1;
    isDeleteFeed = false;
    refreshControl = [[UIRefreshControl alloc] init];
    specFeedArr = [[NSMutableArray alloc]init];
    deleteFeedid = [[NSMutableArray alloc]init];
    refreshControl .backgroundColor = [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [self.tableview insertSubview: refreshControl atIndex:0];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    [self getFeedBySpecilityWithAuthkey:self.specId];
    self.tableview.tableFooterView = self.spinner ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIColor *color    = kThemeColor;
    self.navigationItem.title = self.specName;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica SemiBold" size:16.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationItem.title = self.specName;
    [self setNeedsStatusBarAppearanceUpdate];
    [self setBackButton];
}

-(void)setBackButton{
    
    NSLog(@"setBackButton");
    UIBarButtonItem *backButton;
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(GoToBackView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;

}

-(void)GoToBackView{
    NSLog(@"GoToBackView");
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate specilityViewFindDelete:isDeleteFeed deleteFeedID:deleteFeedid];
}


-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
 
}

-(void)refreshData{
    [self getFeedBySpecilityWithAuthkey:self.specId];
    if (refreshControl) {
        NSString *title = @"Refreshing...";
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return specFeedArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if([[[specFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeNormal])
    {
        TLTextFeedCell *tlTextCell = [tableView dequeueReusableCellWithIdentifier:@"TLTextFeedCell" forIndexPath:indexPath];
        [tlTextCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlTextCell.delegate = self;
        return tlTextCell;
    }else if([[[specFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeImage])
    {
        TLImageFeedCell *tlImageCell = [tableView dequeueReusableCellWithIdentifier:@"TLImageFeedCell" forIndexPath:indexPath];
        [tlImageCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlImageCell.delegate = self;
        return tlImageCell;
    } else if([[[specFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeVideo])
    {
        TLImageFeedCell *tlImageCell = [tableView dequeueReusableCellWithIdentifier:@"TLImageFeedCell" forIndexPath:indexPath];
        [tlImageCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlImageCell.delegate = self;
        return tlImageCell;
    }
    else if([[[specFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeMeta])
    {
        TLTextFeedCell *tlMetaCell;
        if ([[specFeedArr objectAtIndex:indexPath.row] objectForKey:@"meta_array"]) {
            tlMetaCell = [tableView dequeueReusableCellWithIdentifier:@"TLMetaFeedCell" forIndexPath:indexPath];
        } else {
            tlMetaCell = [tableView dequeueReusableCellWithIdentifier:@"TLOldMetaFeedCell" forIndexPath:indexPath];
            tlMetaCell.webview.scrollView.bounces = false;
            tlMetaCell.webview.scrollView.scrollEnabled = false;
            NSString * urslStrig = [specFeedArr objectAtIndex:indexPath.row][@"file_url"];
            urslStrig = [urslStrig stringByDecodingHTMLEntities];
            tlMetaCell.webview.opaque = NO;
            tlMetaCell.webview.backgroundColor = [UIColor clearColor];
            [tlMetaCell.webview loadHTMLString:urslStrig baseURL:nil];
            tlMetaCell.lbl_feed_title.text = [[[[specFeedArr objectAtIndex:indexPath.row] valueForKey:@"title"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
            tlMetaCell.lbl_desc.text = [[[[specFeedArr objectAtIndex:indexPath.row] valueForKey:@"content"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
        }
        
        [tlMetaCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlMetaCell.metaview_container.layer.borderColor = [UIColor lightGrayColor].CGColor;
        tlMetaCell.metaview_container.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
        tlMetaCell.metaview_container.layer.shadowOpacity = 0.5;
        tlMetaCell.metaview_container.layer.shadowRadius = 1.0;
        tlMetaCell.metaview_container.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        tlMetaCell.delegate = self;
        return tlMetaCell;
    }else if([[[specFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeDoc])
    {
        TLTextFeedCell *tlDocCell = [tableView dequeueReusableCellWithIdentifier:@"TLDocFeedCell"];
        [tlDocCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlDocCell.pdf_backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        tlDocCell.delegate = self;
        return tlDocCell;
    }else{
        TLTextFeedCell *tlTextCell = [tableView dequeueReusableCellWithIdentifier:@"TLTextFeedCell" forIndexPath:indexPath];
        [tlTextCell configureCellForRowAtIndexPath:indexPath withData:[specFeedArr objectAtIndex:indexPath.row]];
        tlTextCell.delegate = self;
        return tlTextCell;
    }
}


#pragma mark - get userProfileTimeLineRequest

-(void)getFeedBySpecilityWithAuthkey:(NSString*)custid{
    
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[DocquityServerEngine sharedInstance]getViewFeedBySpecialityRequestWithAuthKey:[userPref valueForKey:userAuthKey] speciality_id:self.specId limit:@"10" offset:[NSString stringWithFormat:@"%ld",(long)offset] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"responseObject get profile timeline:%@",responseObject);
        if(responseObject == nil){
            NSLog(@"Response is null");
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
            [self.tableview.pullToRefreshView stopAnimating];
            
            self.tableview.tableFooterView = nil;
            return ;
        }
        if(error){
            if (error.code == NSURLErrorTimedOut) {
                
                //time out error here
                
            } else{
                
                [self singleButtonAlertViewWithAlertTitle:AppName message:InternetSlowMessage buttonTitle:OK_STRING];
            }
            
        }else {
            NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
            if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil) {
                [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                // tel is null
            } else {
                if([[resposeDic valueForKey:@"status"]integerValue] == 1) {
                    offset ==1?[specFeedArr removeAllObjects]:nil;
                    NSMutableArray *feedDataArr= [resposeDic objectForKey:@"feed"];
                    if([feedDataArr count]) {
                        for(int i=0; i<[feedDataArr count]; i++)
                        {
                            NSMutableDictionary *feedDic = [[NSMutableDictionary alloc] initWithDictionary:feedDic = feedDataArr[i]];
                            if (feedDic != nil && [feedDic isKindOfClass:[NSMutableDictionary class]]) {
                                [specFeedArr addObject:feedDic];
                            }
                        }
                    }
                    self.tableview.tableFooterView = nil;
                    offset ++;
                    [self.tableview reloadData];
                    [self.tableview.pullToRefreshView stopAnimating];
                    
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 7) {
                    self.tableview.showsPullToRefresh = NO;
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 9) {
                    [[AppDelegate appDelegate] logOut];
                } else  if([[resposeDic valueForKey:@"status"]integerValue] == 11) {
                    
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 5) {
                    [[AppDelegate appDelegate]ShowPopupScreen];
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 0) {
                    
                }
            }
        }
    }];
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressLikeBtn:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"like indexpath row %ld",(long)clickedIndexPath.row);
    
    NSMutableDictionary *dict = [specFeedArr objectAtIndex:clickedIndexPath.row];
    NSLog(@"Like stauts indexpath section %ld = %@",(long)clickedIndexPath.section,[dict valueForKey: @"like_status"]);
    if([[dict valueForKey: @"like_status"]isEqualToString:@"0"]){
        [self setFeedLikeRequest:[dict valueForKey:@"feed_id"]];
        [self reloadTableForLikeFeed:true];
    }else{
        NSLog(@"Already liked");
        
    }
}

- (void)didPressCommentBtn:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    [self pushToCommentView];
}
- (void)didPressShareBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    feedShareUrl = [specFeedArr objectAtIndex:clickedIndexPath.row][@"feed_share_url"];
    [self shareFeed];
}
- (void)didPressDocumentBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
    NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
}

- (void)didPressFeedAction:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
    NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self actionOnFeed];
}


-(void)pushToCommentView{
    NSMutableDictionary *dict = [specFeedArr objectAtIndex:clickedIndexPath.row];
    NSString *total_like = [dict valueForKey:@"total_like"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewCommentVC *newFeedcomment = [storyboard instantiateViewControllerWithIdentifier:@"NewCommentVC"];
    newFeedcomment.t_likeStr = total_like;
    newFeedcomment.hidesBottomBarWhenPushed = YES;
    newFeedcomment.feedDict = dict;
    newFeedcomment.delegate = self;
    newFeedcomment.isNoifPView = NO;
    [AppDelegate appDelegate].isComeFromNotificationScreen = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIColor *color    = kThemeColor;
    self.navigationController.navigationBar.barTintColor = color;
    [self.navigationController pushViewController:newFeedcomment animated:YES];
}

#pragma mark - whatsApp Activity Controller
- (SSCWhatsAppActivity *)generateWhatsappActivity
{
    [[AppDelegate appDelegate] getPlaySound];
    
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    
    return whatsAppActivity;
}

-(void)shareFeed{
    [Localytics tagEvent:@"PDF result Share"];
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    
    NSString *shareTitle = [NSString stringWithFormat:@"%@",[[[specFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"title"]stringByDecodingHTMLEntities]];
    NSString *urlreflink;
    NSString *reflink;
    
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
    if ([reflink rangeOfString:@"="].location != NSNotFound)
    {
        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0,reflink.length)];
        urlreflink  = [reflink substringFromIndex:range.location+1];
    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedShareUrl,urlreflink];
    NSURL *urlToShare = [NSURL URLWithString:urlreflink];
    NSString*sharelastMsg = @"Shared via Docquity!";
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareTitle, urlToShare, sharelastMsg] applicationActivities:@[whatsAppActivity]];
    
    //[activityViewController setValue:@"CME Certificate Docquity" forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePostToVimeo,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToFacebook];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
}


-(void)actionOnFeed{
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        NSLog(@"Edit");
        ///Edit Feed here
        NSDictionary*feedInformation = [specFeedArr objectAtIndex:clickedIndexPath.row];
        [self setEditFeedWithFeedID:feedInformation];
        //[self setEditFeedWithFeedID:[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
        NSLog(@"Delete");
        
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:kdeletePostTitle message:kdeletePostConfirmation preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self setDeleteFeedRequest:[specFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)setEditFeedWithFeedID:(NSDictionary *)feeddicInfo{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    newFeedPostViewController *postvw = [storyboard instantiateViewControllerWithIdentifier:@"NewPostFeedVC"];
    postvw.FeedInformation = feeddicInfo.mutableCopy;
    postvw.isEditFeed = YES;
    [self presentViewController:postvw animated:YES completion:nil];
    
    // Edit Feed here
}



-(void)setDeleteFeedRequest:(NSString*)currentFeedId{
    [[AppDelegate appDelegate]showIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]DeleteFeedRequesttWithAuthKey:[userDef objectForKey:userAuthKey]  user_id:[userDef objectForKey:userId] feed_id:currentFeedId  action:@"delete" user_type:@"user" device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage format:jsonformat callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
         [[AppDelegate appDelegate] hideIndicator];
         if(responseObject == nil){
             NSLog(@"Response is null");
             [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             self.tableview.tableFooterView = nil;
             return ;
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if(error){
             if (error.code == NSURLErrorTimedOut) {
                 //time out error here
                 [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];
                 
             }else{
                 [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }
         }else {
             NSMutableDictionary *responsePost=[responseObject objectForKey:@"posts"];
             if ([responsePost isKindOfClass:[NSNull class]]||responsePost ==nil) {
                 [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }else {
                 
                 NSString *message=  [NSString stringWithFormat:@"%@",[responsePost objectForKey:@"msg"]?[responsePost objectForKey:@"msg"]:@""];
                 if([[responsePost valueForKey:@"status"]integerValue] == 1)
                 {
                     [self reloadTableForDeleteFeed];
                     isDeleteFeed = YES;
                     [deleteFeedid addObject:[specFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
                     
                 }
                 else  if([[responsePost valueForKey:@"status"]integerValue] == 0)
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                     [alert show];
                 }
                 else  if([[responsePost valueForKey:@"status"]integerValue] == 9)
                 {
                     [[AppDelegate appDelegate]logOut];
                 }
                 else  if([[responsePost valueForKey:@"status"]integerValue] == 11)
                 {
                     NSString*userValidateCheck = @"readonly";
                     NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                     [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                     NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                     if ([u_permissionstus isEqualToString:@"readonly"]) {
                         [self getcheckedUserPermissionData];
                     }
                 }
             }
         }
     }];
}

#pragma mark - setfeedLikeRequest
- (void)setFeedLikeRequest:(NSString*)latestFeedId
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetFeedLikeRequesttWithAuthKey:[userDef objectForKey:userAuthKey] feed_id:latestFeedId device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responceObject, NSError *error) {
        BOOL likeFailed = NO;
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            // NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory;
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
            else {
                likeFailed = YES;
            }
            if (likeFailed) {
                [self reloadTableForLikeFeed:false];
            }
        }
    }];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
        {
            //tel is null
        }
        else {
            NSString * stusmsg =[NSString stringWithFormat:@"%@",[postDic objectForKey:@"msg"]?[postDic objectForKey:@"msg"]:@""];
            NSString * ICNumber;
            NSString * Identity;
            NSString *InviteCodeExample;
            NSString * InviteCodeTyp;
            NSString * IdentityMsg;
            NSDictionary *dataDic=[postDic objectForKey:@"data"];
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
            {
                // tel is null
            }
            else {
                permstus = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"permission"]?[dataDic objectForKey:@"permission"]:@""];
                NSDictionary *reqDic=[dataDic objectForKey:@"requirement"];
                if ([reqDic isKindOfClass:[NSNull class]]|| reqDic ==nil)
                {
                    // tel is null
                }
                else {
                    ICNumber =[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"ic_number"]?[reqDic objectForKey:@"ic_number"]:@""];
                    
                    Identity=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity"]?[reqDic objectForKey:@"identity"]:@""];
                    
                    IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    if ([IdentityMsg  isEqualToString:@""] || [IdentityMsg isEqualToString:@"<null>"]) {
                    }
                    else {
                        IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    }
                    NSDictionary *IC_reqDic=[reqDic objectForKey:@"ic_requirement"];
                    if ([IC_reqDic isKindOfClass:[NSNull class]]||IC_reqDic ==nil)
                    {
                        // tel is null
                    }
                    else {
                        InviteCodeExample =[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_example"]?[IC_reqDic objectForKey:@"invite_code_example"]:@""];
                        InviteCodeTyp=[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_type"]?[IC_reqDic objectForKey:@"invite_code_type"]:@""];
                    }
                }
            }
            if([[postDic valueForKey:@"status"]integerValue] == 1){
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:permstus?permstus:@"" forKey:user_permission];//mandatory
                [userpref synchronize];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 11){
                [self pushToVerifyAccount:stusmsg invite_codeType:InviteCodeTyp invite_code_example:InviteCodeExample ic_number:ICNumber identity:Identity identity_message:IdentityMsg];
            }
            else{
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:@"OK" autoDismissFlag:NO];
            }
        }
    }];
}

-(void)pushToVerifyAccount:(NSString*)stusmsg invite_codeType:(NSString*)InviteCodeTyp invite_code_example:(NSString*)InviteCodeExample ic_number:(NSString*)ICNumber identity:(NSString*)Identity identity_message:(NSString*)IdentityMsg{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    PermissionCheckYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"PermissionCheckYourSelfVC"];
    selfVerify.titleMsg = stusmsg;
    selfVerify.titledesc = InviteCodeTyp;
    selfVerify.tf_placeholder = InviteCodeExample;
    selfVerify.IcnumberValue = ICNumber;
    selfVerify.idetityValue = Identity;
    selfVerify.identityTypMsg = IdentityMsg;
    [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

-(void)reloadTableForDeleteFeed{
    [specFeedArr removeObjectAtIndex:clickedIndexPath.row];
    [self.tableview reloadData];
}

-(void)reloadTableForLikeFeed:(BOOL)likeStatus{
    
    NSMutableDictionary *dict = [specFeedArr objectAtIndex:clickedIndexPath.row];
    NSInteger total_like = [dict[@"total_like"]integerValue];
    NSLog(@"Total Like = %ld",(long)total_like);
    total_like = likeStatus?++total_like:--total_like;
    NSLog(@"Total Like cond = %ld",(long)total_like);
    NSString *tLikeString = [NSString stringWithFormat:@"%ld", (long)total_like];
    likeStatus?[dict setValue:@"1" forKey:@"like_status"]:[dict setValue:@"0" forKey:@"like_status"];
    [dict setValue:tLikeString forKey:@"total_like"];
    NSLog(@"like_status = %@",[dict valueForKey: @"like_status"]);
    [self.tableview reloadData];
    [[AppDelegate appDelegate].ActivityArray addObject: [specFeedArr objectAtIndex:clickedIndexPath.row]];
    //    [self.tableview beginUpdates];
    //    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:clickedIndexPath.row inSection:clickedIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //    [self.tableview endUpdates];
}


-(void)commentviewReturnsForFeedid:(NSString*)feedid commentCount:(NSString*)TotalComment LikesCount:(NSString*)TotalLikes ilike:(BOOL)flag updatedTimeStamp:(NSString *)updateTimeStamp{
    NSLog(@"Feedid = %@, comment count = %@, Like count = %@" ,feedid,TotalComment,TotalLikes);
    
    for (NSMutableDictionary *tempDic in specFeedArr){
        if ([[tempDic valueForKey:@"feed_id"]isEqualToString:feedid]) {
            [tempDic setObject:TotalLikes forKey:@"total_like"];
            [tempDic setObject:TotalComment forKey:@"total_comments"];
            flag==true?[tempDic setObject:@"1" forKey:@"like_status"]:nil;
            if (![updateTimeStamp isEqualToString:@""]) {
                [tempDic setObject:updateTimeStamp forKey:@"date_of_updation"];
            }
            [self.tableview reloadData];
            [[AppDelegate appDelegate].ActivityArray addObject: [specFeedArr objectAtIndex:clickedIndexPath.row]];
            break;
        }
    }
}

- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    link = [link stringByReplacingOccurrencesOfString:@"#" withString:@""];
    link = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self pushToSpecilityForID:[self getSpecilityIdByName:link ForIndexPath:indexPath] specilityName:link];
}

-(NSString *)getSpecilityIdByName:(NSString *)specName ForIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *specArr = [specFeedArr objectAtIndex:indexPath.row][@"speciality"];
    NSString *spcid = @"";
    for (NSMutableDictionary * dic in specArr) {
        if ([[dic valueForKey:@"speciality_name"] isEqualToString:specName]) {
            spcid = [dic valueForKey:@"speciality_id"];
            break;
        }
    }
    NSLog(@"Spec name = %@ and Spec id = %@",specName,spcid);
    return spcid;
}

-(void)pushToSpecilityForID:(NSString *)specid specilityName:(NSString *)specName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    SpecilityFeedVC *specilityfeed = [storyboard instantiateViewControllerWithIdentifier:@"SpecilityFeedVC"];
    specilityfeed.specId = specid;
    specilityfeed.specName = specName;
//    specilityfeed.delegate = self;
    [self.navigationController pushViewController:specilityfeed animated:YES];
}

@end
