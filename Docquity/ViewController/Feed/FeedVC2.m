/*============================================================================
 PROJECT: Docquity
 FILE:    FeedVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 22/10/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "FeedVC.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "FeedCell.h"
#import "SVPullToRefresh.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import "NSString+HTML.h"
#import "NewProfileVC.h"
#import "WebVC.h"
#import "Localytics.h"
#import "MailActivity.h"
#import "SVProgressHUD.h"
#import "newFeedPostViewController.h"
#import "SSCWhatsAppActivity.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "NewCommentVC.h"
#import "PermissionCheckYourSelfVC.h"
#import "DocquityServerEngine.h"
#import "UILoadingView.h"
#import "UserTimelineVC.h"
#import "UpdateFeed.h"
//#import "Analytics.h"

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define TABLEVIEW_PAGE_SIZE 20
#define TABLEVIEW_CELL_HEIGHT 44.0

/*============================================================================
 Interface: FeedVC
 =============================================================================*/
@interface FeedVC ()
{
    int pageContent; //page number/number of cells visble to user now
    int casepageContent; //casepage number/number of cells visble to user now
    int curentindex; //current selected index
    NSString*customId;
    int likeStatusValue;
    NSString*feedJabberID;
    int tlikeValue;
    NSString *exactDateTime;
    NSString* fileType; //fileType
    NSString *_processedFeedId;    //feed id
    NSInteger _processedFeedIndex;
    UIRefreshControl *refreshControl;
    NSString*cus_uId;
    NSDictionary *feeddicInfo;
    NSString *feedsTitle;
    NSString*feedsshareUrl;
    NSString * permstus;
    UILoadingView *loader;
    UIView *blankloaderview;
}
typedef enum{
    kTag_imgProfileBtn =100,
    kTag_Profileimg,
    kTag_likeTxtLbl,
    kTag_tLikeLbl,
    kTag_kLikeImg,
    kTag_kLikeBtn,
    
    kTag_ImgViewNotWifi,
    kTag_LblNotInternet,
    kTag_BtnRetry,
}All_Tag;

@end
@implementation FeedVC
@synthesize myfeedArr,myfeedTV,myfeed_casesArr;
@synthesize nilView;
@synthesize moviePlayerViewController;
@synthesize trends_button,cases_button;

- (void)viewDidLoad {
    [super viewDidLoad];
    isserviceCall = FALSE;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    appDelegate.feebVCRef = self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.myfeedTV.backgroundView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];

    self.myfeedTV.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    self.mycaseTV.backgroundView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    self.mycaseTV.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    
    blankloaderview = [[UIView alloc]initWithFrame:CGRectMake(0, 102, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 102-48)];
    blankloaderview.backgroundColor = [UIColor clearColor];
    blankloaderview.hidden = YES;
    [self.view addSubview: blankloaderview];
   
    loader = [[UILoadingView alloc] initWithFrame:CGRectMake(0, 0, blankloaderview.bounds.size.width, blankloaderview.frame.size.height)];
    [blankloaderview addSubview:loader];
    
    // Do any additional setup after loading the view from its nib.
    self.myfeedArr = [[NSMutableArray alloc]init];
    self.myfeed_casesArr = [[NSMutableArray alloc]init];
    pageContent = 1; //initial state of page that control should start 0 to limit 10
    casepageContent = 1; //initial state of page that control should start 0 to limit 10
    
    // Initialize the refresh control.
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor =  [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor lightGrayColor];
    //[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    
    trends_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    cases_button.titleLabel.textColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1];
    [self buttonChangedonClick:trends_button];
}

-(void)viewDidAppear:(BOOL)animated{
    if(trends_button.selected == YES){
        if([[UpdateFeed sharedInstance] deleteFeedArray].count>0){
            for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
                NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
                for (NSUInteger k = 0; k <myfeedArr.count; k++) {
                    NSDictionary *data = myfeedArr[k];
                    if ([data[@"feed_id"] isEqualToString:delfeedid]) {
                        [myfeedArr removeObjectAtIndex:k];
                        break;
                    }
                }
            }
        }
    
        [myfeedTV reloadData];
    }else{
        if([[UpdateFeed sharedInstance] deleteFeedArray].count>0){
            for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
                NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
                for (NSUInteger k = 0; k <myfeed_casesArr.count; k++) {
                    NSDictionary *data = myfeed_casesArr[k];
                    if ([data[@"feed_id"] isEqualToString:delfeedid]) {
                        [myfeed_casesArr removeObjectAtIndex:k];
                        break;
                    }
                }
            }
        }
        
        [_mycaseTV reloadData];
    
    }
}

- (void)refreshData
{
    //Reload table data
    pageContent = 1;
    casepageContent = 1;
    if (self.myfeedArr == nil)
    {
        self.myfeedArr = [[NSMutableArray alloc]init];
    }
    if (self.myfeed_casesArr == nil)
    {
        self.myfeed_casesArr = [[NSMutableArray alloc]init];
    }
    [AppDelegate appDelegate].isbackFromPostFeed = YES;
    if (trends_button.selected == YES) {
        [self getFeedFilteredListRequest];
        [self.myfeedTV reloadData];
    }
    else{
        [self getCasesFilteredListRequest];
        [self.mycaseTV reloadData];
    }
    // End the refreshing
    if (refreshControl) {
        [Localytics tagEvent:@"WhatsTrending PullUP"];
        NSString *title = [NSString stringWithFormat:@"Refreshing..."];
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Feed Page Visit"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Feed vISIT"
                                                          action:@"button_trends"
                                                           label:@"OPEN"
                                                           value:nil] build]];
     */
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.hidesBackButton = true;
    [self registerNotification];
    // NSLog(@"viewWillAppear at feed vc");
    [Localytics tagEvent:@"WhatsTrending"];
    //initial state of page that control should start 0 to limit 10
}

#pragma mark - whatsApp Activity Controller
- (SSCWhatsAppActivity *)generateWhatsappActivity
{
    [[AppDelegate appDelegate] getPlaySound];
    MailActivity *mailActivity = [self generateMailActiviy];
    NSString*shareTitle = feedsTitle;
    NSString* urlreflink;
    NSString*reflink;
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
    if ([reflink rangeOfString:@"="].location != NSNotFound)
    {
        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0,reflink.length)];
        urlreflink  = [reflink substringFromIndex:range.location+1];
    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedsshareUrl,urlreflink];
    NSURL *urlToShare = [NSURL URLWithString:urlreflink];
    NSString*sharelastMsg = @"Shared via Docquity!";
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareTitle, urlToShare, sharelastMsg] applicationActivities:@[whatsAppActivity,mailActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeMail,UIActivityTypeSaveToCameraRoll];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    return whatsAppActivity;
}

#pragma mark - mail Activity Open Action
- (MailActivity *) generateMailActiviy
{
    MailActivity *mailAct = [[MailActivity alloc] init];
    NSString* urlreflink;
    NSString*reflink;
    //Preparing vairous values for mail
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"] ;
    NSString*shareMsgLine1 = @"Hi,";
    NSString*shareMsgLine2  = @"Sharing with you some recent discussions on Docquity. The fastest growing private & secure doctors only professional network.";
    
    NSString*shareTitle = feedsTitle;
    NSString*shareMsgLine6 = @"I hope you like it and expecting to connect with you on Docquity.";
    NSString*shareMsgLine7 = @"Thanks";
    NSString*shareMsgLine8 = @"<a href=\"https://itunes.apple.com/us/app/docquity/id1048947290?mt=8/path/to/link\">Download Docquity</a>\n";
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
    if ([reflink rangeOfString:@"="].location != NSNotFound)
    {
        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, reflink.length)];
        urlreflink  = [reflink substringFromIndex:range.location+1];
    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedsshareUrl,urlreflink];
    NSURL *shareUrl = [NSURL URLWithString:urlreflink];
    [emailBody appendString:[NSString stringWithFormat:@"%@<br></br>%@\n <br><br>%@</br>\n %@\n <br><br>%@</br>\n <br>%@</br>\n %@",shareMsgLine1,shareMsgLine2,shareTitle,shareUrl,shareMsgLine6,shareMsgLine7,shareMsgLine8,nil]];
    
    NSString *subject = feedsTitle;
    MFMailComposeViewController *mailComposer = mailAct.mMailComposer;
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:emailBody isHTML:YES];
    return mailAct;
}

-(void) showSuccessToastWithMsg:(NSString *) msg{
    [SVProgressHUD showSuccessWithStatus:msg];
}

-(IBAction)addFeedBtn:(id)sender{
    [Localytics tagEvent:@"WhatsTrending New Post Click"];
    [[AppDelegate appDelegate] getPlaySound];
    //Checking Device-----Iphone 5 or other
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        isClickFromShare =NO;
        [self getcheckedUserPermissionData];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        newFeedPostViewController *postvw = [storyboard instantiateViewControllerWithIdentifier:@"NewPostFeedVC"];
        if (trends_button.selected == YES) {
            postvw.isTrends = YES;
        }
        else{
            postvw.isTrends = NO;
        }
        postvw.isEditFeed = false;
        [self presentViewController:postvw animated:YES completion:nil];
    }
}

#pragma mark UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (trends_button.selected == YES) {
        self.mycaseTV.hidden=YES;
        self.myfeedTV.hidden=NO;
    }
    else{
        self.mycaseTV.hidden=NO;
        self.myfeedTV.hidden=YES;
    }
    if (tableView == self.mycaseTV){
        return [self.myfeed_casesArr count];
    }else if (tableView == self.myfeedTV) {
        return [self.myfeedArr count];
    }
    return  0;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 125.0f;
    float padding = 4.0f;
    NSDictionary *feed;
    if (trends_button.selected == YES) {
        self.mycaseTV.hidden=YES;
        self.myfeedTV.hidden=NO;
        feed= self.myfeedArr[indexPath.row];
    }
    else{
        self.mycaseTV.hidden=NO;
        self.myfeedTV.hidden=YES;
        feed= self.myfeed_casesArr[indexPath.row];
    }
    NSString *content = feed[@"content"];
    NSString *seemore = feed[@"see_more"];
    height += 30+padding;
    CGRect lblRect = [content boundingRectWithSize:(CGSize){self.view.frame.size.width-30, MAXFLOAT}
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    if ([seemore integerValue] == 1)
    {
        if([[feed valueForKey:@"speciality"]count]>0) {
             height += 14+85+30;//Add see more button height as well
        }
        else{
        height += 14+85;//Add see more button height as well
        }
    }
    else
    {
        height += 14+lblRect.size.height+padding*2;
    }
    if ([[feed valueForKey:@"file_type"]isEqualToString:@"image"]) {
        //This is media type feed so lets check image height..
        height += 250.0f + padding;
    }
    if ([[feed valueForKey:@"file_type"]isEqualToString:@"document"]) {
        //This is media type feed so lets check document height..
        height += 132.0f + padding;
    }
    if ([[feed valueForKey:@"file_type"]isEqualToString:@"link"]) {
        //This is media type feed so lets check image height..
             height += 270.0f + padding;
     }
    if ([[feed valueForKey:@"file_type"]isEqualToString:@"video"]) {
        //This is media type feed so lets check image height..
        height += 250.0f + padding;
    }
    if([[feed valueForKey:@"speciality"]count]>0) {
        height += 47.0f;
        }
    if ([feed[@"total_like"] integerValue] > 0 || [feed[@"total_comments"] integerValue] > 0) {
        height += 25.0f;
    }
      return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AppDelegate appDelegate].isComeFromTrending = YES;
    static NSString *cellIdentifier = @"FeedCellIdentifier";
    FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView == self.myfeedTV) {
        if (cell == nil) {
            cell = [[FeedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.trustButton addTarget:self action:@selector(likeBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentButton addTarget:self action:@selector(commentBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.editButton addTarget:self action:@selector(editBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.shareButton addTarget:self action:@selector(shareBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.seeMoreButton addTarget:self action:@selector(commentBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.videoplayBtn addTarget:self action:@selector(videoButtonClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.documentBtn addTarget:self action:@selector(documentButtonClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            
            UITapGestureRecognizer *tapon_poplaritlyLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.poplaritlyLabel addGestureRecognizer:tapon_poplaritlyLabel];
            [cell.poplaritlyLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *tapon_titleLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.titleLabel addGestureRecognizer:tapon_titleLabel];
            [cell.titleLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *tapon_multiImgVw = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.feedMultipleImageView addGestureRecognizer:tapon_multiImgVw];
            [cell.feedMultipleImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUserNameLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.userNameLabel addGestureRecognizer:taponUserNameLabel];
            [cell.userNameLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponassoLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.assoLabel addGestureRecognizer:taponassoLabel];
            [cell.assoLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponFeedTypeImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.feedTypeImageView addGestureRecognizer:taponFeedTypeImg];
            [cell.feedTypeImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.userImageView addGestureRecognizer:taponUserImg];
            [cell.userImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUsertime = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.timeLabel addGestureRecognizer:taponUsertime];
            [cell.timeLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponcontentTxtView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            
            [cell.contentTextView addGestureRecognizer:taponcontentTxtView];
            [cell.contentTextView setUserInteractionEnabled:YES];
            
            //open metalink on webview
            [cell.openMetaDataButton addTarget:self action:@selector(openMetadataUrlLink:event:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *feed;
        self.mycaseTV.hidden=YES;
        self.myfeedTV.hidden=NO;
        feed= self.myfeedArr[indexPath.row];
        [cell setInfo:feed];
        if (!cell.feedImageView.hidden) {
            [cell.feedImageView setupImageViewerWithCompletionOnOpen:^{
                [self.tabBarController.tabBar setHidden:YES];
                [Localytics tagEvent:@"WhatsTrending Photo Click"];
                NSLog(@"Open");
            } onClose:^{
                [self.tabBarController.tabBar setHidden:NO];
                NSLog(@"Close");
            }];
        }
    }
    else if (tableView == self.mycaseTV) { // tableView == secondTableView
        if (cell == nil) {
            cell = [[FeedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.trustButton addTarget:self action:@selector(likeBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentButton addTarget:self action:@selector(commentBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.editButton addTarget:self action:@selector(editBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.shareButton addTarget:self action:@selector(shareBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.seeMoreButton addTarget:self action:@selector(commentBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.videoplayBtn addTarget:self action:@selector(videoButtonClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.documentBtn addTarget:self action:@selector(documentButtonClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            
            UITapGestureRecognizer *tapon_poplaritlyLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.poplaritlyLabel addGestureRecognizer:tapon_poplaritlyLabel];
            [cell.poplaritlyLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *tapon_titleLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.titleLabel addGestureRecognizer:tapon_titleLabel];
            [cell.titleLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *tapon_multiImgVw = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            [cell.feedMultipleImageView addGestureRecognizer:tapon_multiImgVw];
            [cell.feedMultipleImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUserNameLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.userNameLabel addGestureRecognizer:taponUserNameLabel];
            [cell.userNameLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponassoLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.assoLabel addGestureRecognizer:taponassoLabel];
            [cell.assoLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponFeedTypeImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.feedTypeImageView addGestureRecognizer:taponFeedTypeImg];
            [cell.feedTypeImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.userImageView addGestureRecognizer:taponUserImg];
            [cell.userImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponUsertime = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
            [cell.timeLabel addGestureRecognizer:taponUsertime];
            [cell.timeLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *taponcontentTxtView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCommentView:)];
            
            [cell.contentTextView addGestureRecognizer:taponcontentTxtView];
            [cell.contentTextView setUserInteractionEnabled:YES];
            
            //open metalink on webview
            [cell.openMetaDataButton addTarget:self action:@selector(openMetadataUrlLink:event:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *feed;
        self.mycaseTV.hidden=NO;
        self.myfeedTV.hidden=YES;
        feed= self.myfeed_casesArr[indexPath.row];
        [cell setInfo:feed];
        if (!cell.feedImageView.hidden) {
            [cell.feedImageView setupImageViewerWithCompletionOnOpen:^{
                [self.tabBarController.tabBar setHidden:YES];
                [Localytics tagEvent:@"WhatsTrending Photo Click"];
                NSLog(@"Open");
            } onClose:^{
                [self.tabBarController.tabBar setHidden:NO];
                NSLog(@"Close");
            }];
        }
    }
    return cell;
}

#pragma mark - video Button clicked
-(void)videoButtonClicked:(id)sender event:(id)event
{
    [Localytics tagEvent:@"WhatsTrending VideoPlay Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *feed;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feed   = [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feed  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
    NSString*fileUrlLink = [feed valueForKey:@"file_url"];
    
    // Make a URL
    NSURL *url = [NSURL URLWithString:
                  fileUrlLink];
    // Initialize the MPMoviePlayerController object using url
    _videoPlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    // Add a notification. (It will call a "moviePlayBackDidFinish" method when _videoPlayer finish or stops the plying video)
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_videoPlayer];
    // Set control style tp default
    _videoPlayer.controlStyle = MPMovieControlStyleDefault;
    
    //_videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    // Set shouldAutoplay to YES
    _videoPlayer.shouldAutoplay = YES;
    
    // Add _videoPlayer's view as subview to current view.
    [[_videoPlayer view] setFrame: [self.view bounds]];  // frame must match parent view
    [self.view addSubview: [_videoPlayer view]];
    
    // Set the screen to full.
    [_videoPlayer setFullscreen:YES animated:NO];
}

#pragma mark - documentBtn Clicked Action
-(void)documentButtonClicked:(id)sender event:(id)event
{
    [Localytics tagEvent:@"WhatsTrending DocumentUpload Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *feed;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feed   = [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feed  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
    NSString*documentfeedUrlLink = [feed valueForKey:@"file_url"];
    NSString*documentfeedtitle =  [feed valueForKey:@"file_name"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = documentfeedUrlLink;
    webvw.documentTitle =documentfeedtitle;
    webvw.hidesBottomBarWhenPushed = YES;
    [self presentViewController:webvw
                       animated:YES
                     completion:nil];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [_videoPlayer stop];
    MPMoviePlayerController *videoplayer = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:videoplayer];
    if ([videoplayer
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [videoplayer.view removeFromSuperview];
        // remove the video player from superview.
    }
}

#pragma mark - openMetaDataLink Clicked Action
-(void)openMetadataUrlLink:(id)sender event:(id)event
{
    [Localytics tagEvent:@"WhatsTrending Meta Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *feed;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feed   = [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feed  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
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
    [self presentViewController:webvw
                       animated:YES
                     completion:nil];
}

#pragma mark - seeMore Cliked Action
- (void)seeMoreButtonClicked:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *feed;
    NSIndexPath *tapedIndexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        tapedIndexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feed   = [self.myfeedArr objectAtIndex: tapedIndexPath.row];
        [feed setValue:@"0" forKey:@"see_more"];
        [self.myfeedTV reloadData];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        tapedIndexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feed  = [self.myfeed_casesArr objectAtIndex: tapedIndexPath.row];
        [feed setValue:@"0" forKey:@"see_more"];
        [self.mycaseTV reloadData];
    }
}

#pragma mark - comment Btn Clicked Action
- (void)commentBtnClicked:(id)sender event:(id)event{
    [Localytics tagEvent:@"What’s Trending Comment Click"];
    [[AppDelegate appDelegate] getPlaySound];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *dict;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        dict   = [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        dict  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
    _processedFeedId =  [dict objectForKey:@"feed_id"];
    NSString*likeSts =  [dict objectForKey:@"like_status"];
    NSString*tlike =  [dict objectForKey:@"total_like"];
    likeStatusValue =[likeSts intValue];
    if (indexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        NewCommentVC *newFeedcomment = [storyboard instantiateViewControllerWithIdentifier:@"NewCommentVC"];
        newFeedcomment.t_likeStr = tlike;
        newFeedcomment.hidesBottomBarWhenPushed = YES;
        newFeedcomment.feedDict = dict;
        newFeedcomment.delegate = self;
        newFeedcomment.isNoifPView = NO;
        [AppDelegate appDelegate].isComeFromNotificationScreen = NO;
        [self.navigationController pushViewController:newFeedcomment animated:YES];
    }
}

#pragma mark - shareButton Clicked Action
- (void)shareBtnClicked:(id)sender event:(id)event{
    [Localytics tagEvent:@"WhatsTrending Share Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *dict;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        dict   =    [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        dict  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
    _processedFeedId =  [dict objectForKey:@"feed_id"];
    feedsTitle = dict[@"title"];
    feedsshareUrl = dict[@"feed_share_url"];
    if (indexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
        if ([u_permissionstus isEqualToString:@"readonly"]) {
            [[AppDelegate appDelegate] getPlaySound];
            isClickFromShare =YES;
            [self getcheckedUserPermissionData];
        }
        else{
            [self generateWhatsappActivity];
        }
    }
}

#pragma mark - likeBtn Clicked Action
- (void)likeBtnClicked:(UIButton*)sender event:(id)event{
    [[AppDelegate appDelegate] getPlaySound];
    [Localytics tagEvent:@"WhatsTrending Like Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSDictionary *dict;
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        dict   = [self.myfeedArr objectAtIndex: indexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        dict  = [self.myfeed_casesArr objectAtIndex: indexPath.row];
    }
    _processedFeedIndex = indexPath.row;
    _processedFeedId = [dict objectForKey:@"feed_id"];
    NSInteger total_like = [dict[@"total_like"]integerValue];
    total_like += 1;
    NSString *likeString = [NSString stringWithFormat:@"%ld", (long)total_like];
    [dict setValue:@"1" forKey:@"like_status"];
    [dict setValue:likeString forKey:@"total_like"];
     if (indexPath != nil)
    {
        sender.selected = !sender.selected;
        if(sender.selected)
        {
            //Update like status.. Check Network connection
            Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
            NetworkStatus internetStatus = [r currentReachabilityStatus];
            if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        }
            [self setFeedLikeRequest:_processedFeedId];
        }
    if(trends_button.selected == YES){
    [self.myfeedTV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
    [self.mycaseTV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

#pragma mark - openProfile Action
- (void)openProfileView:(UITapGestureRecognizer*)gesture
{
    [Localytics tagEvent:@"WhatsTrending Profile Click"];
    NSDictionary *feeddict;
    NSIndexPath *tapedIndexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [gesture locationInView:self.myfeedTV];
        tapedIndexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feeddict   = [self.myfeedArr objectAtIndex: tapedIndexPath.row];
    }
    else{
        CGPoint currentTouchPosition = [gesture locationInView:self.mycaseTV];
        tapedIndexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feeddict  = [self.myfeed_casesArr objectAtIndex: tapedIndexPath.row];
    }
    NSString*custom_uId =  [feeddict objectForKey:@"custom_id"];
    NSString*feedjabId =  [feeddict objectForKey:@"feeder_jabber_id"];
    if (tapedIndexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
        NewProfile.hidesBottomBarWhenPushed = YES;
         NewProfile .custid=  custom_uId;
         [AppDelegate appDelegate].isComeFromSettingVC = YES;
        [self.navigationController pushViewController:NewProfile animated:YES];
    }
}

#pragma mark - editButton Click Action
- (void)editBtnClicked:(UIButton*)sender event:(id)event
{
    [Localytics tagEvent:@"WhatsTrending EditPostArrow Click"];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSIndexPath *indexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [touch locationInView:self.myfeedTV];
        indexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feeddicInfo = [self.myfeedArr objectAtIndex: indexPath.row];
        if ([[feeddicInfo valueForKey:@"file_type"]isEqualToString:@"image"]) {
            FeedCell *cell = [self.myfeedTV cellForRowAtIndexPath:indexPath];
            UIImage *image = cell.feedImageView.image;
            [feeddicInfo setValue:image forKey:@"FeedImg"];
        }else if([[feeddicInfo valueForKey:@"file_type"]isEqualToString:@"document"]){
            FeedCell *cell = [self.myfeedTV cellForRowAtIndexPath:indexPath];
            UIImage *image = cell.documentThumbnailImgView.image;
            [feeddicInfo setValue:image forKey:@"FeedImg"];
        }
    }
    else{
        CGPoint currentTouchPosition = [touch locationInView:self.mycaseTV];
        indexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feeddicInfo = [self.myfeed_casesArr objectAtIndex: indexPath.row];
        if ([[feeddicInfo valueForKey:@"file_type"]isEqualToString:@"image"] || [[feeddicInfo valueForKey:@"file_type"]isEqualToString:@"document"]) {
            FeedCell *cell = [self.mycaseTV cellForRowAtIndexPath:indexPath];
            UIImage *image = cell.feedImageView.image;
            [feeddicInfo setValue:image forKey:@"FeedImg"];
        }else if([[feeddicInfo valueForKey:@"file_type"]isEqualToString:@"document"]){
            FeedCell *cell = [self.myfeedTV cellForRowAtIndexPath:indexPath];
            UIImage *image = cell.documentThumbnailImgView.image;
            [feeddicInfo setValue:image forKey:@"FeedImg"];
        }
    }
    _processedFeedId =  [feeddicInfo objectForKey:@"feed_id"];
    cus_uId =  [feeddicInfo objectForKey:@"custom_id"];
    if (indexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *cuId=[userpref objectForKey:ownerCustId];
    if([cus_uId isEqualToString:cuId]) {
        [[AppDelegate appDelegate] getPlaySound];
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
        if ([u_permissionstus isEqualToString:@"readonly"]) {
            [AppDelegate appDelegate].ischeckedReadOnlyPermissionStus  =YES;
            [[AppDelegate appDelegate] ischeckedreadOnly];
        }
        else{
            UIActionSheet *actionSheet;
            if([[feeddicInfo valueForKey:@"classification"] isEqualToString:@"cme"]){
            actionSheet = [[UIActionSheet alloc]
                               initWithTitle:@"What do you want to do?"
                               delegate:self cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:@"Delete"
                               otherButtonTitles:nil,nil];
                ischeckCME =YES;
            }
            else {
                ischeckCME = NO;
                actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete"
                                                 otherButtonTitles:@"Edit",nil];
                
                
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                // In this case the device is an iPad.
                [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
            }
            else{
                // In this case the device is an iPhone/iPod Touch.
                [actionSheet showInView:self.view];
            }
            actionSheet.tag = 100;
        }
    }
}

#pragma ActionSheetControllerDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0: // action delete
            {
                UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:@"Delete Post" message:@"Are you sure you want to permanently remove this post from Docquity?" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
                confAl.tag = 999;
                [confAl show];
            }
                break;
            case 1: // action edit
            {
                [Localytics tagEvent:@"WhatTrending EditPost Edit Click"];
                [[AppDelegate appDelegate] getPlaySound];
                Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
                NetworkStatus internetStatus = [r currentReachabilityStatus];
                if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                if (ischeckCME) {
                    ischeckCME = NO;
                }
                else{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                newFeedPostViewController *postvw = [storyboard instantiateViewControllerWithIdentifier:@"NewPostFeedVC"];
                postvw.FeedInformation = feeddicInfo.mutableCopy;
                postvw.isEditFeed = YES;
                [self presentViewController:postvw animated:YES completion:nil];
            }
            }
                break;
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (alertView.tag == 999){
        if (buttonIndex == 0) {
            [Localytics tagEvent:@"WhatsTrending EditPost Delete Click"];
            //calling services for delete post feed.
            [self setDeleteFeedRequest:_processedFeedId];
        }
    }
}

#pragma mark - seeMore Btn Click Action
- (void)seeMoreClicked:(UITapGestureRecognizer*)gesture{
    NSDictionary *feed;
    NSIndexPath *tapedIndexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [gesture locationInView:self.myfeedTV];
        tapedIndexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        feed   = [self.myfeedArr objectAtIndex: tapedIndexPath.row];
        [feed setValue:@"0" forKey:@"see_more"];
        [self.myfeedTV reloadData];
    }
    else{
        CGPoint currentTouchPosition = [gesture locationInView:self.mycaseTV];
        tapedIndexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        feed  = [self.myfeed_casesArr objectAtIndex: tapedIndexPath.row];
        [feed setValue:@"0" forKey:@"see_more"];
        [self.mycaseTV reloadData];
    }
}

#pragma mark - openComment View Action
- (void)openCommentView:(UITapGestureRecognizer*)gesture{
    [Localytics tagEvent:@"WhatsTrending Content Click"];
    [[AppDelegate appDelegate] getPlaySound];
    NSDictionary *dict;
    NSIndexPath *tapedIndexPath;
    if(trends_button.selected == YES){
        CGPoint currentTouchPosition = [gesture locationInView:self.myfeedTV];
        tapedIndexPath = [self.myfeedTV indexPathForRowAtPoint: currentTouchPosition];
        dict   = [self.myfeedArr objectAtIndex: tapedIndexPath.row];
    }
    else{
        
        CGPoint currentTouchPosition = [gesture locationInView:self.mycaseTV];
        tapedIndexPath = [self.mycaseTV indexPathForRowAtPoint: currentTouchPosition];
        dict  = [self.myfeed_casesArr objectAtIndex: tapedIndexPath.row];
    }

    _processedFeedId =  [dict objectForKey:@"feed_id"];
    NSString*likeSts =  [dict objectForKey:@"like_status"];
    NSString*tlike =  [dict objectForKey:@"total_like"];
    likeStatusValue =[likeSts intValue];
    if (tapedIndexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        if([[dict valueForKey:@"classification"] isEqualToString:@"cme"]){
            [[AppDelegate appDelegate] navigateToTabBarScren:1];
        }
        else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
            NewCommentVC *newFeedcomment = [storyboard instantiateViewControllerWithIdentifier:@"NewCommentVC"];
            newFeedcomment.t_likeStr = tlike;
            newFeedcomment.hidesBottomBarWhenPushed = YES;
            newFeedcomment.feedDict = dict;
            newFeedcomment.delegate = self;
            newFeedcomment.isNoifPView = NO;
            [AppDelegate appDelegate].isComeFromNotificationScreen = NO;
            [self.navigationController pushViewController:newFeedcomment animated:YES];
        }
    }
}

-(void)addBottom:(UIButton *)sender{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height-3, sender.frame.size.width, 3)];
    lineView.backgroundColor = [UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    lineView.tag = 1112;
    [sender addSubview:lineView];
}

-(void)deselectModeSender:(UIButton*)sender{
    [sender setTitleColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    UIView *border = (UIView*)[sender viewWithTag:1112];
    [border removeFromSuperview];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"docquitySetFeedUploaded" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if (!isserviceCall) {
        // NSLog(@"give me back");
        if ([[notification name] isEqualToString:@"docquitySetFeedUploaded"]){
            [self.myfeedTV setContentOffset:CGPointMake(0, 0) animated:NO];
            if ([AppDelegate appDelegate].isCases_Feed == YES) {
                [self buttonChangedonClick:cases_button];
                casepageContent = 1;
                if ([self.myfeed_casesArr count]!=0) {
                    !isserviceCall?[self getCasesFilteredListRequest]:nil;
                }
                isserviceCall = YES;
            }
            else{
                [self buttonChangedonClick:trends_button];
                pageContent = 1;
                if ([self.myfeedArr count]!=0) {
                   [self getFeedFilteredListRequest];
                    }
                isserviceCall = YES;
            }
        }
    }
}

-(void)commentviewReturnsForFeedid:(NSString*)feedid commentCount:(NSString*)TotalComment LikesCount:(NSString*)TotalLikes ilike:(BOOL)flag updatedTimeStamp:(NSString *)updateTimeStamp{
    // NSLog(@"Feedid = %@, comment count = %@, Like count = %@" ,feedid,TotalComment,TotalLikes);
    if(trends_button.selected == YES){
        for (NSMutableDictionary *tempDic in self.myfeedArr){
            if ([[tempDic valueForKey:@"feed_id"]isEqualToString:feedid]) {
                [tempDic setObject:TotalLikes forKey:@"total_like"];
                [tempDic setObject:TotalComment forKey:@"total_comments"];
                flag==true?[tempDic setObject:@"1" forKey:@"like_status"]:nil;
                if (![updateTimeStamp isEqualToString:@""]) {
                    [tempDic setObject:updateTimeStamp forKey:@"date_of_updation"];
                }
                [self.myfeedTV reloadData];
                break;
            }
        }
    }
    else{
        for (NSMutableDictionary *tempDic in self.myfeed_casesArr){
            if ([[tempDic valueForKey:@"feed_id"]isEqualToString:feedid]) {
                [tempDic setObject:TotalLikes forKey:@"total_like"];
                [tempDic setObject:TotalComment forKey:@"total_comments"];
                if (![updateTimeStamp isEqualToString:@""]) {
                    [tempDic setObject:updateTimeStamp forKey:@"date_of_updation"];
                }
                flag==true?[tempDic setObject:@"1" forKey:@"like_status"]:nil;
                [self.mycaseTV reloadData];
                break;
            }
        }
    }
}

#pragma mark - button change click for Trends/Cases
-(IBAction)buttonChangedonClick:(UIButton *)sender{
    trends_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    cases_button.titleLabel.textColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1];
    if (0 == sender.tag) {
        [self.myfeedTV insertSubview: refreshControl atIndex:0];
        __weak FeedVC *weakSelf = self;
        [self.myfeedTV addPullToRefreshWithActionHandler:^{
            [Localytics tagEvent:@"WhatsTrending PullDown"];
            //Call Feeds here
             [weakSelf getFeedFilteredListRequest];
        }
        position:SVPullToRefreshPositionBottom];
        [Localytics tagEvent:@"WhatsTrending Trends"];
        [self removeBottom:sender];
        [self addBottom:sender];
        UIImage *case_image = [UIImage imageNamed:@"cases_grey.png"];
        cases_icon.image= case_image;
        UIImage *trends_image = [UIImage imageNamed:@"trends_hover.png"];
        trends_icon.image = trends_image;
        trends_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
        cases_button.titleLabel.textColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1];
        [self deselectModeSender:cases_button];
        trends_button.selected =YES;
        cases_button.selected =NO;
        if ([self.myfeedArr count]==0) {
            [self showLoader];
            dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
            dispatch_async(downloadQueue, ^{
                //your data loading
                dispatch_async(dispatch_get_main_queue(), ^{
                [self getFeedFilteredListRequest];
                    // //maybe some visual data reloading that should be run in the main thread
                });
            });
        }
        else{
            self.myfeedTV.hidden = NO;
            self.mycaseTV.hidden = YES;
            nilView.hidden =YES;
            [self.myfeedTV reloadData];
        }
    }
    else {
        [self.mycaseTV insertSubview: refreshControl atIndex:0];
        __weak FeedVC *weakSelf = self;
        [self.mycaseTV addPullToRefreshWithActionHandler:^{
            [Localytics tagEvent:@"WhatsTrending PullDown"];
            //Call Feeds here
            [weakSelf getCasesFilteredListRequest];
        }position:SVPullToRefreshPositionBottom];
        [Localytics tagEvent:@"WhatsTrending Cases"];
        [self removeBottom:sender];
        [self addBottom:sender];
        UIImage *case_image = [UIImage imageNamed:@"cases-hover.png"];
        cases_icon.image= case_image;
        UIImage *trends_image = [UIImage imageNamed:@"trends_grey.png"];
        trends_icon.image = trends_image;
        cases_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
        trends_button.titleLabel.textColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1];
        cases_button.selected =YES;
        trends_button.selected =NO;
        [self deselectModeSender:trends_button];
        if ([self.myfeed_casesArr count]==0) {
            [self.mycaseTV reloadData];
            [self showLoader];
            dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
            dispatch_async(downloadQueue, ^{
                //your data loading
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getCasesFilteredListRequest];;
                    //maybe some visual data reloading that should be run in the main thread
                });
            });
         }
        else{
            self.myfeedTV.hidden = YES;
            self.mycaseTV.hidden = NO;
            nilView.hidden =YES;
            [self.mycaseTV reloadData];
        }
    }
}

#pragma mark - remove bottom from superview
-(void)removeBottom:(UIButton*)btn{
    for (UIView *view in btn.subviews) {
        if (view.tag==1112) {
            [view removeFromSuperview];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic==nil)
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
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic== nil)
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
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:OK_STRING autoDismissFlag:NO];
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

#pragma mark - get FeedListRequest
-(void)getFeedFilteredListRequest{
     isserviceCall = YES;
    //NSLog(@"pageContent=%d",pageContent);
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *fromindex=[NSString stringWithFormat:@"%d",pageContent];
    [[DocquityServerEngine sharedInstance]ViewFeed_FilteredRequestWithAuthKey:[userpref objectForKey:userAuthKey] offset:fromindex feed_kind:@"post" device_type:kDeviceType app_version:[userpref objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary* responceObject, NSError* error) {
        [[AppDelegate appDelegate] hideIndicator];
        [[AppDelegate appDelegate] hideIndicator];
//      [loader removeFromSuperview];
        [self hideLoader];
        if ([AppDelegate appDelegate].isbackFromPostFeed ==YES) {
            // NSLog(@"Is Back from post feed vc");
            // pageContent =1;
            [[AppDelegate appDelegate] hideIndicator];
        }
        else if (pageContent ==1) {

        }
        [self.myfeedTV.pullToRefreshView stopAnimating];
        //self.myfeedTV.tableFooterView = nil;
        NSLog(@"%@",responceObject);
        NSDictionary *resposeCode=[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            // response is null
        }
        else {
            NSMutableArray *temparr = [[NSMutableArray alloc]init];
            temparr= [resposeCode objectForKey:@"feed"];
            // NSLog(@"%@",response);
            NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
            if([[resposeCode valueForKey:@"status"]integerValue] == 1) {
                //Nil View loading
                if ([temparr count]==0) {
                    self.myfeedTV.hidden = YES;
                    self.mycaseTV.hidden = YES;
                    self.nilView.hidden = NO;
                    nilLbl.hidden = NO;
                }
                else {
                    if([temparr count])
                    {
                        //more data found
                        pageContent==1?[self.myfeedArr removeAllObjects]:nil;
                        pageContent ==1?[refreshControl endRefreshing]:nil;
                        for(int i=0; i<[temparr count]; i++){
    
                            NSMutableDictionary *feedInfo = [[NSMutableDictionary alloc] initWithDictionary:feedInfo = temparr[i]];
                            if (feedInfo != nil && [feedInfo isKindOfClass:[NSMutableDictionary class]]) {
                                NSString *title = feedInfo[@"title"];
                                title = [title stringByDecodingHTMLEntities];
                                [feedInfo  setObject:title forKey:@"title"];
                                NSString *feedContent = [feedInfo objectForKey:@"content"]?[feedInfo objectForKey:@"content"]:@"";
                                if (feedContent.length) {
                                    feedContent = [feedContent stringByDecodingHTMLEntities];
                                    feedContent = [feedContent stringByDecodingHTMLEntities];
                                    [feedInfo setObject:feedContent forKey:@"content"];
                                    CGRect rect = [feedContent boundingRectWithSize:(CGSize){self.view.frame.size.width-20, MAXFLOAT}
                                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
                                    if (rect.size.height > 70) {
                                        [feedInfo setValue:@"1" forKey:@"see_more"];
                                    }
                                    else{
                                        [feedInfo setValue:@"0" forKey:@"see_more"];
                                    }
                                }
                                else{
                                    [feedInfo setValue:@"0" forKey:@"see_more"];
                                }
                                [self.myfeedArr addObject:feedInfo];
                            }
                        }
                        if ([temparr  count]==0) {
                            UIAlertView* alertvw = [[UIAlertView alloc]initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alertvw show];
                        }
                    }
                }
                self.myfeedTV.hidden = NO;
                 self.mycaseTV.hidden = YES;
                self.nilView.hidden = YES;
                nilLbl.hidden = YES;
                [self.myfeedTV reloadData];
                pageContent++;
                isserviceCall = false;
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 5)
            {
                [[AppDelegate appDelegate]ShowPopupScreen];
                isserviceCall = false;
            }
            else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                    isserviceCall = false;
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 7)
            {
                if (pageContent==1) {
                    self.nilView.hidden = NO;
                    self.mycaseTV.hidden = YES;
                    self.myfeedTV.hidden = YES;
                    nilLbl.hidden = NO;
                    nilLbl.text = @"No one from your association has posted any trends yet!.";
                    isserviceCall = false;
                    [refreshControl endRefreshing];
                }
                [self.myfeedTV setShowsPullToRefresh:NO];
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
                isserviceCall = false;
            }
        }
    }];
}

#pragma mark - get CaseListRequest
-(void)getCasesFilteredListRequest{
    isserviceCall = YES;
    //NSLog(@"pageContent=%d",pageContent);
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *fromindex=[NSString stringWithFormat:@"%d",casepageContent];
    [[DocquityServerEngine sharedInstance]ViewFeed_FilteredRequestWithAuthKey:[userpref objectForKey:userAuthKey] offset:fromindex feed_kind:@"cases" device_type:kDeviceType app_version:[userpref objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary* responceObject, NSError* error) {
        [self hideLoader];
        //[loader removeFromSuperview];
        [[AppDelegate appDelegate] hideIndicator];
        [[AppDelegate appDelegate] hideIndicator];
        if ([AppDelegate appDelegate].isbackFromPostFeed ==YES) {
            // NSLog(@"Is Back from post feed vc");
            // casepageContent =1;
            [[AppDelegate appDelegate] hideIndicator];
        }
        else if (casepageContent ==1) {

        }
        [self.mycaseTV.pullToRefreshView stopAnimating];
      //  NSLog(@"%@",responceObject);
        NSDictionary *resposeCode=[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            // response is null
        }
        else {
            NSMutableArray *temparr = [[NSMutableArray alloc]init];
            temparr= [resposeCode objectForKey:@"feed"];
            // NSLog(@"%@",response);
            NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
            if([[resposeCode valueForKey:@"status"]integerValue] == 1) {
                //Nil View loading
                if ([temparr count]==0) {
                    self.myfeedTV.hidden = YES;
                    self.mycaseTV.hidden = YES;
                    self.nilView.hidden = NO;
                    nilLbl.hidden = NO;
                }
                else {
                    if([temparr count])
                    {
                        //more data found
                        casepageContent==1?[self.myfeed_casesArr removeAllObjects]:nil;
                        casepageContent ==1?[refreshControl endRefreshing]:nil;
                        for(int i=0; i<[temparr count]; i++){
                            
                            NSMutableDictionary *feedInfo = [[NSMutableDictionary alloc] initWithDictionary:feedInfo = temparr[i]];
                            if (feedInfo != nil && [feedInfo isKindOfClass:[NSMutableDictionary class]]) {
                                NSString *title = feedInfo[@"title"];
                                title = [title stringByDecodingHTMLEntities];
                                [feedInfo  setObject:title forKey:@"title"];
                                NSString *feedContent = [feedInfo objectForKey:@"content"]?[feedInfo objectForKey:@"content"]:@"";
                                if (feedContent.length) {
                                    feedContent = [feedContent stringByDecodingHTMLEntities];
                                    feedContent = [feedContent stringByDecodingHTMLEntities];
                                    [feedInfo setObject:feedContent forKey:@"content"];
                                    CGRect rect = [feedContent boundingRectWithSize:(CGSize){self.view.frame.size.width-20, MAXFLOAT}
                                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
                                    if (rect.size.height > 70) {
                                        [feedInfo setValue:@"1" forKey:@"see_more"];
                                    }
                                    else{
                                        [feedInfo setValue:@"0" forKey:@"see_more"];
                                    }
                                }
                                else{
                                    [feedInfo setValue:@"0" forKey:@"see_more"];
                                }
                                [self.myfeed_casesArr addObject:feedInfo];
                            }
                        }
                        if ([temparr  count]==0) {
                            UIAlertView* alertvw = [[UIAlertView alloc]initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alertvw show];
                        }
                    }
                }
                self.myfeedTV.hidden = YES;
                self.mycaseTV.hidden = NO;
                self.nilView.hidden = YES;
                nilLbl.hidden = YES;
                [self.mycaseTV reloadData];
                casepageContent++;
                isserviceCall = false;
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 5)
            {
                [[AppDelegate appDelegate]ShowPopupScreen];
                isserviceCall = false;
            }
             else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                    isserviceCall = false;
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 7)
            {
                if (casepageContent==1) {
                    self.nilView.hidden = NO;
                    self.myfeedTV.hidden = YES;
                    self.mycaseTV.hidden = YES;
                    nilLbl.hidden = NO;
                    nilLbl.text = @"No one from your association has posted any cases yet!.";
                    isserviceCall = false;
                    [refreshControl endRefreshing];
                }
                [self.mycaseTV setShowsPullToRefresh:NO];
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
                isserviceCall = false;
            }
        }
    }];
}

#pragma mark - set delete feed from list
-(void)setDeleteFeedRequest:(NSString*)currentFeedId{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]DeleteFeedRequesttWithAuthKey:[userDef objectForKey:userAuthKey]  user_id:[userDef objectForKey:userId] feed_id:currentFeedId  action:@"delete" user_type:@"user" device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error)
     {
         NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
         if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
         {
             // Response is null
         }
         else {
             NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
             if([[resposePost valueForKey:@"status"]integerValue] == 1)
             {
                 [AppDelegate appDelegate].isCases_Feed = NO;
                 [self refreshData];
                 [AppDelegate appDelegate].isbackFromPostFeed = NO;
                 [[AppDelegate appDelegate] hideIndicator];
             }
             else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
             {
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                 [alert show];
             }
             else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
             {
                 [[AppDelegate appDelegate]logOut];
             }
             else  if([[resposePost valueForKey:@"status"]integerValue] == 11)
             {
                 NSString*userValidateCheck = @"readonly";
                 NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                 [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                 NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                 if ([u_permissionstus isEqualToString:@"readonly"]) {
                     [self getcheckedUserPermissionData];
                     isserviceCall = false;
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
                NSDictionary *dict = [self.myfeedArr objectAtIndex:_processedFeedIndex];
                NSInteger total_like = [dict[@"total_like"]integerValue];
                total_like -= 1;
                NSString *likeString = [NSString stringWithFormat:@"%ld", (long)total_like];
                [dict setValue:@"0" forKey:@"like_status"];
                [dict setValue:likeString forKey:@"total_like"];
                [self.myfeedTV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_processedFeedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

-(void)hideLoader{
    blankloaderview.hidden = YES;
}

-(void)showLoader{
    blankloaderview.hidden = NO;
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
