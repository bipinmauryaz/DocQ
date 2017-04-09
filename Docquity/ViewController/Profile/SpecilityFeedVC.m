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
#import "PermissionCheckYourSelfVC.h"
#import "TLSummaryCell.h"
#import "TLPhotosCell.h"
#import "TLTextFeedCell.h"
#import "TLImageFeedCell.h"
#import "WebVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "UINavigationBar+ZZHelper.h"
#import "ProfileData.h"
#import "Localytics.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "NSString+GetRelativeTime.h"
#import "SDCollectionViewController.h"
#import "CollectionViewController.h"
#import "NewCommentVC.h"
#import "SSCWhatsAppActivity.h"
#import "SVPullToRefresh.h"
#import "SpecilityFeedVC.h"
#import "UpdateFeed.h"
#import "SDPhotoBrowser.h"
#import "SDPhotoItem.h"
#import "NewProfileVC.h"
#import "newFeedPostViewController.h"
#import "MailActivity.h"
#import "ChatViewController.h"
#import "ServicesManager.h"
#import "UserTimelineVC.h"
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
    refreshControl .backgroundColor =  [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor lightGrayColor];
    [refreshControl  addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [self.tableview insertSubview: refreshControl atIndex:0];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    [self getFeedBySpecilityWithAuthkey:self.specId];
    self.tableview.tableFooterView = self.spinner ;
    __weak SpecilityFeedVC *weakSelf = self;
    
    [self.tableview addPullToRefreshWithActionHandler:^{
        [Localytics tagEvent:@"WhatsTrending PullDown"];
        [weakSelf getFeedBySpecilityWithAuthkey:self.specId];
    }position:SVPullToRefreshPositionBottom];
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIColor *color    = kThemeColor;
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationItem.title = self.specName;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.title = self.specName;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica SemiBold" size:16.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self setBackButton];
     photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) dateTitle:@"" title:@"" subtitle:@""];
    
    if(specFeedArr.count>0){
        for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
            NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
            for (NSUInteger k = 0; k < specFeedArr.count; k++) {
                NSDictionary *data = specFeedArr[k];
                if ([data[@"feed_id"] isEqualToString:delfeedid]) {
                    [specFeedArr removeObjectAtIndex:k];
                    break;
                }
            }
        }
        [self.tableview reloadData];
    }
}

-(void)setBackButton{

    UIBarButtonItem *backButton;
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(GoToBackView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

-(void)GoToBackView{
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate specilityViewFindDelete:isDeleteFeed deleteFeedID:deleteFeedid];
}

-(void)specilityViewFindDelete:(BOOL)isDelete deleteFeedID:(NSMutableArray*)deleteFeedID {
    isDeleteFeed = isDelete;
    for (NSString *feedid in deleteFeedID)
    {
        [deleteFeedid addObject:feedid];
    }
}
-(void)isDeleteFeed:(BOOL)isdelete Feedid:(NSString*)feedid{
    if(isdelete){
        for(int i=0;i<specFeedArr.count ;i++){
            if([[[specFeedArr objectAtIndex:i]valueForKey:@"feed_id" ] isEqualToString:feedid])
            {
                [specFeedArr removeObjectAtIndex:i];
                break;
            }
        }
    }
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
    offset = 1;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if([[[specFeedArr objectAtIndex:indexPath.row] valueForKey:@"classification"] isEqualToString:@"cme"])
    {
        [[AppDelegate appDelegate] navigateToTabBarScren:1];
    }else{
        clickedIndexPath = indexPath;
        [self pushToCommentView];
    }
    
}


#pragma mark - get userProfileTimeLineRequest
-(void)getFeedBySpecilityWithAuthkey:(NSString*)custid{
     NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[DocquityServerEngine sharedInstance]getViewFeedBySpecialityRequestWithAuthKey:[userPref valueForKey:userAuthKey] speciality_id:self.specId limit:@"10" offset:[NSString stringWithFormat:@"%ld",(long)offset] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [refreshControl endRefreshing];
     //   NSLog(@"responseObject getFeedBySpecilityWithAuthkey:%@",responseObject);
        if(responseObject == nil){
     //       NSLog(@"Response is null");
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
                    self.tableview.showsPullToRefresh = feedDataArr.count > 9 ;
                    
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
 //   NSLog(@"like indexpath row %ld",(long)clickedIndexPath.row);
    NSMutableDictionary *dict = [specFeedArr objectAtIndex:clickedIndexPath.row];
  //  NSLog(@"Like stauts indexpath section %ld = %@",(long)clickedIndexPath.section,[dict valueForKey: @"like_status"]);
    if([[dict valueForKey: @"like_status"]isEqualToString:@"0"]){
        [self setFeedLikeRequest:[dict valueForKey:@"feed_id"]];
        [self reloadTableForLikeFeed:true];
    }
    else{
   //     NSLog(@"Already liked");
     }
}

- (void)didPressMetaBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
   // NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
   // NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self openMetadataUrl];
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
//    NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
//    NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
     [self openDocument];
}

- (void)didPressFeedAction:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
//    NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
//    NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self actionOnFeed];
}


- (void)didPressUserBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    if([[specFeedArr objectAtIndex:clickedIndexPath.row][@"custom_id"]isEqualToString:@""]){
//        NSLog(@"same Profile");
    }else{
        [self pushToOthersTimeline];
    }
}

- (void)didTapUserImage:(UIImageView*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    if([[specFeedArr objectAtIndex:clickedIndexPath.row][@"custom_id"]isEqualToString:@""]){
//        NSLog(@"same Profile");
    }else{
        [self pushToOthersTimeline];
    }
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

-(void)shareFeed{
    [[AppDelegate appDelegate] getPlaySound];
    MailActivity *mailActivity = [self generateMailActiviy];
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    
    NSString *shareTitle = [NSString stringWithFormat:@"%@",[[[specFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"title"]stringByDecodingHTMLEntities]];
    NSString *urlreflink;
    NSString *reflink;
    
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
//    if ([reflink rangeOfString:@"="].location != NSNotFound)
//    {
//        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0,reflink.length)];
//        urlreflink  = [reflink substringFromIndex:range.location+1];
//    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedShareUrl,reflink];
    NSURL *urlToShare = [NSURL URLWithString:urlreflink];
    NSString*sharelastMsg = @"Shared via Docquity!";
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareTitle, urlToShare, sharelastMsg] applicationActivities:@[whatsAppActivity,mailActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeMail,UIActivityTypeSaveToCameraRoll];
    
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - mail Activity Open Action
- (MailActivity *) generateMailActiviy
{
    MailActivity *mailAct = [[MailActivity alloc] init];
    NSString *shareTitle = [NSString stringWithFormat:@"%@",[[[specFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"title"]stringByDecodingHTMLEntities]];
    
    NSString* urlreflink;
    NSString*reflink;
    //Preparing vairous values for mail
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"] ;
    NSString*shareMsgLine1 = @"Hi,";
    NSString*shareMsgLine2  = @"Sharing with you some recent discussions on Docquity. The fastest growing private & secure doctors only professional network.";
    
    NSString*shareMsgLine6 = @"I hope you like it and expecting to connect with you on Docquity.";
    NSString*shareMsgLine7 = @"Thanks";
    NSString*shareMsgLine8 = @"<a href=\"https://itunes.apple.com/us/app/docquity/id1048947290?mt=8/path/to/link\">Download Docquity</a>\n";
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
//    if ([reflink rangeOfString:@"="].location != NSNotFound)
//    {
//        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0,reflink.length)];
//        urlreflink  = [reflink substringFromIndex:range.location+1];
//    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedShareUrl,reflink];
    
    NSURL *shareUrl = [NSURL URLWithString:urlreflink];
    [emailBody appendString:[NSString stringWithFormat:@"%@<br></br>%@\n <br><br>%@</br>\n %@\n <br><br>%@</br>\n <br>%@</br>\n %@",shareMsgLine1,shareMsgLine2,shareTitle,shareUrl,shareMsgLine6,shareMsgLine7,shareMsgLine8,nil]];
    
    NSString *subject = shareTitle;
    MFMailComposeViewController *mailComposer = mailAct.mMailComposer;
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:emailBody isHTML:YES];
    return mailAct;
}


-(void)actionOnFeed{
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        //NSLog(@"Edit");
        ///Edit Feed here
        NSDictionary*feedInformation = [specFeedArr objectAtIndex:clickedIndexPath.row];
        [self setEditFeedWithFeedID:feedInformation];
        //[self setEditFeedWithFeedID:[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
       // NSLog(@"Delete");
        
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
    // Edit Feed here
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self getcheckedUserPermissionData];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        newFeedPostViewController *postvw = [storyboard instantiateViewControllerWithIdentifier:@"NewPostFeedVC"];
        postvw.FeedInformation = feeddicInfo.mutableCopy;
        postvw.isEditFeed = YES;
        [self presentViewController:postvw animated:YES completion:nil];
    }
}

-(void)setDeleteFeedRequest:(NSString*)currentFeedId{
    [[AppDelegate appDelegate]showIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]DeleteFeedRequesttWithAuthKey:[userDef objectForKey:userAuthKey]  user_id:[userDef objectForKey:userId] feed_id:currentFeedId  action:@"delete" user_type:@"user" device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage format:jsonformat callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
         [[AppDelegate appDelegate] hideIndicator];
         if(responseObject == nil){
           //  NSLog(@"Response is null");
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
                     [[[UpdateFeed sharedInstance]deleteFeedArray] addObject:currentFeedId];
                     //[deleteFeedid addObject:currentFeedId];
                     
                 }
                 else  if([[responsePost valueForKey:@"status"]integerValue] == 0)
                 {
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                     [self presentViewController:alertController animated:YES completion:nil];               }
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
//    NSLog(@"Total Like = %ld",(long)total_like);
    total_like = likeStatus?++total_like:--total_like;
//    NSLog(@"Total Like cond = %ld",(long)total_like);
    NSString *tLikeString = [NSString stringWithFormat:@"%ld", (long)total_like];
    likeStatus?[dict setValue:@"1" forKey:@"like_status"]:[dict setValue:@"0" forKey:@"like_status"];
    [dict setValue:tLikeString forKey:@"total_like"];
//    NSLog(@"like_status = %@",[dict valueForKey: @"like_status"]);
    [self.tableview reloadData];
    [[AppDelegate appDelegate].ActivityArray addObject: [specFeedArr objectAtIndex:clickedIndexPath.row]];
    [[[UpdateFeed sharedInstance]activityArray]removeAllObjects];
    for (NSMutableDictionary *GtempDic in [AppDelegate appDelegate].ActivityArray){
        [[[UpdateFeed sharedInstance]activityArray]addObject:GtempDic];
    }
    //    [self.tableview beginUpdates];
    //    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:clickedIndexPath.row inSection:clickedIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //    [self.tableview endUpdates];
}


-(void)commentviewReturnsForFeedid:(NSString*)feedid commentCount:(NSString*)TotalComment LikesCount:(NSString*)TotalLikes ilike:(BOOL)flag updatedTimeStamp:(NSString *)updateTimeStamp{
//    NSLog(@"Feedid = %@, comment count = %@, Like count = %@" ,feedid,TotalComment,TotalLikes);
    
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
            [[[UpdateFeed sharedInstance]activityArray]removeAllObjects];
            for (NSMutableDictionary *GtempDic in [AppDelegate appDelegate].ActivityArray){
                [[[UpdateFeed sharedInstance]activityArray]addObject:GtempDic];
            }
            
            
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
    specName = [specName stringByEncodingHTMLEntities];
    NSMutableArray *specArr = [specFeedArr objectAtIndex:indexPath.row][@"speciality"];
    NSString *spcid = @"";
    for (NSMutableDictionary * dic in specArr) {
        if ([[dic valueForKey:@"speciality_name"] isEqualToString:specName]) {
            spcid = [dic valueForKey:@"speciality_id"];
            break;
        }
    }
//    NSLog(@"Spec name = %@ and Spec id = %@",specName,spcid);
    return spcid;
}

-(void)pushToSpecilityForID:(NSString *)specid specilityName:(NSString *)specName{
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    SpecilityFeedVC *specilityfeed = [storyboard instantiateViewControllerWithIdentifier:@"SpecilityFeedVC"];
    specilityfeed.specId = specid;
    specilityfeed.specName = specName;
    //specilityfeed.delegate = self;
    [self.navigationController pushViewController:specilityfeed animated:YES];
}

#pragma mark - documentBtn Clicked Action
-(void)openDocument
{
    [Localytics tagEvent:@"WhatsTrending DocumentUpload Click"];
    NSMutableDictionary *feed = [specFeedArr objectAtIndex:clickedIndexPath.row];
    NSString*documentfeedUrlLink = [feed valueForKey:@"file_url"];
    NSString*documentfeedtitle =  [feed valueForKey:@"file_name"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = documentfeedUrlLink;
    webvw.documentTitle =documentfeedtitle;
    webvw.hidesBottomBarWhenPushed = YES;
    [self presentViewController:webvw animated:YES completion:nil];
}

-(void)playVideoByURL:(NSString *)url {
    [self openVideo:url];
}

- (void)openVideo:(NSString*)videoUrl{
//    NSLog(@"videoUrl = %@",videoUrl);
    [Localytics tagEvent:@"CourseDetails VideoPlay Click"];
    NSURL *url = [NSURL URLWithString:videoUrl];
    self.videoPlayer =  [[MPMoviePlayerController alloc]initWithContentURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_videoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    _videoPlayer.controlStyle = MPMovieControlStyleDefault;  // Set control style tp default
    _videoPlayer.shouldAutoplay = YES;  // Set shouldAutoplay to YES
    [[_videoPlayer view] setFrame: [self.view bounds]];
    [self.view addSubview: [_videoPlayer view]];
    [_videoPlayer setFullscreen:YES animated:NO];  // Set the screen to full.
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [_videoPlayer stop];
    MPMoviePlayerController *videoPlayer = [notification object];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:videoPlayer];
    if ([videoPlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [videoPlayer.view removeFromSuperview];
    }
}

- (void)moviePlayerPlaybackDidFinishNotification:(NSNotification*)notification
{
    [_videoPlayer.view removeFromSuperview];
}


#pragma mark - openMetaDataLink Clicked Action
-(void)openMetadataUrl
{
    [Localytics tagEvent:@"WhatsTrending Meta Click"];
    NSMutableDictionary *feed = [specFeedArr objectAtIndex:clickedIndexPath.row];
    NSString*feedUrlLink = [feed valueForKey:@"meta_url"];
    if (feedUrlLink && (feedUrlLink.length != 0)) {
        NSRange rng = [feedUrlLink rangeOfString:@"http://"options:NSCaseInsensitiveSearch];
        NSRange rng1 = [feedUrlLink rangeOfString:@"https://"options:NSCaseInsensitiveSearch];
        if (rng.location == NSNotFound && rng1.location == NSNotFound) {
            feedUrlLink = [NSString stringWithFormat:@"http://%@" ,feedUrlLink];
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = feedUrlLink;
    webvw.hidesBottomBarWhenPushed = YES;
    [self presentViewController:webvw animated:YES completion:nil];
}

//-(void)imgviewTapped:(UIImageView*)sender{
//    [self photoViewSetup];
//    [photoView fadeInPhotoViewFromImageView:sender];
//}

- (void)imgviewTapped:(UIImageView*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    [self photoViewSetup:sender];
}

-(void)photoViewSetup:(UIImageView*)sender{
    NSString *activity =@"";
    NSString *comment = [specFeedArr objectAtIndex:clickedIndexPath.row][@"total_comments"];
    NSString *likes = [specFeedArr objectAtIndex:clickedIndexPath.row][@"total_like"];
    NSString *update = [NSString setUpdateTimewithString:[[specFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"date_of_updation"]];
    if([comment isEqualToString:@"0"] && [likes isEqualToString:@"0"]){
        activity = update;
    }else if([comment isEqualToString:@"0"]) {
        if([likes  integerValue] == 1){
           activity = @"1 Like";
        }else {
           activity = [NSString stringWithFormat:@"%@ Likes",likes];
        }
    }else {
    
        if([comment  integerValue] == 1){
            activity = @"1 comment";
        }else {
            activity = [NSString stringWithFormat:@"%@ comments",comment];
        }
    }
    NSString *subtitle = [specFeedArr objectAtIndex:clickedIndexPath.row][@"content"];
    NSString *title = [specFeedArr objectAtIndex:clickedIndexPath.row][@"title"];
    [photoView fadeInPhotoViewFromImageView:sender withTitle:title subTitle:subtitle dateTitle:activity];
}


-(void)pushToOthersTimeline{
    NSMutableDictionary *dict = [specFeedArr objectAtIndex:clickedIndexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *otherTimeline = [storyboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    
    otherTimeline.custid = [dict valueForKey:@"custom_id"];
    [self.navigationController pushViewController:otherTimeline animated:YES];
}


-(void)qbStartChat{
    FriendModel *fmodal = self.profileData.FriendDic;
    NSString *fullName = @"";
    NSString *loginid = @"";
    NSUInteger chatID = 0;
    QBUUser *User = [QBUUser new];
    NSString *cid = self.profileData.chat_id;
    
    if([cid isKindOfClass:[NSNull class]]){
        cid = @"0";
    }
    chatID = cid.integerValue;
    loginid = self.profileData.jabber_id;
    fullName = [NSString stringWithFormat:@"%@ %@",self.profileData.first_name, self.profileData.last_name];
    //    NSString * selectedFCustid  = [NSString stringWithFormat:@"%@",self.profileData.custom_id];
    if(chatID == 0){
        UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confAl.tag = 888;
        [confAl show];
        return;
    }
    User.ID = chatID;
    User.login = loginid;
    User.fullName = fullName;
    selectedFStatus = fmodal.friend_status;
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        [self getcheckedUserPermissionData];
    }
    else{
        [self joinChatWithUser:User];
    }
}
-(void)joinChatWithUser:(QBUUser*)user {
    __weak __typeof(self) weakSelf = self;
    [self createChatWithName:nil selectedUser:user completion:^(QBChatDialog *dialog) {
        __typeof(self) strongSelf = weakSelf;
        if( dialog != nil ) {
            ChatViewController *chatController = (ChatViewController *)[[UIStoryboard storyboardWithName:@"QBStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatController.dialog = dialog;
            NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
            if (dialogWithIDWasEntered != nil) {
                // some chat already opened, return to dialogs view controller first
                [self.navigationController popViewControllerAnimated:NO];
            }
            chatController.oppCustid = self.profileData.custom_id;
            chatController.friendStatus = selectedFStatus;
            [self.navigationController pushViewController:chatController animated:YES];
            //[strongSelf navigateToChatViewControllerWithDialog:dialog];
        }
        else {
            // [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
        }
    }];
}

- (void)createChatWithName:(NSString *)name selectedUser:(QBUUser*)user completion:(void(^)(QBChatDialog *dialog))completion {
    
    // Creating private chat dialog.
    [ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:user completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        if (!response.success && createdDialog == nil) {
            if (completion) {
                completion(nil);
            }
        }
        else {
            if (completion) {
                completion(createdDialog);
            }
        }
    }];
}

-(void)openWebviewWithURL:(NSString *)url {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WebVC *webview = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webview.fullURL = url;
    [self presentViewController:webview animated:YES completion:nil];
    
}

-(void)clickedUrl:(NSString *)url{
    [self openWebviewWithURL: url];
}


- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"docquitySetFeedUploaded" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    offset = 1;
    [self getFeedBySpecilityWithAuthkey:self.specId];
    
}

@end
