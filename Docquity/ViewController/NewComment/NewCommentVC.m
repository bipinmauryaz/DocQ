/*============================================================================
 PROJECT: Docquity
 FILE:    NewCommentVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 21/09/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "NewCommentVC.h"
#import "NSString+HTML.h"
#import "DefineAndConstants.h"
#import "UIImageView+WebCache.h"
#import "DocquityServerEngine.h"
#import "SectionCell.h"
#import "AppDelegate.h"
#import "UIViewController+KeyboardAnimation.h"
#import "Localytics.h"
#import "WebVC.h"
#import "MailActivity.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "SSCWhatsAppActivity.h"
#import "FeedLikeListVC.h"
#import "editCommentVC.h"
#import "NewProfileVC.h"
#import "SVPullToRefresh.h"
#import "RepliesVC.h"
#import "PermissionCheckYourSelfVC.h"
#import "CAPSPhotoView.h"
#import "KILabel.h"
#import "UserTimelineVC.h"
#import "SpecilityFeedVC.h"
#import "FeedVC.h"
//#import "FeedBySpecialityVC.h"
#import "UpdateFeed.h"

/*===========================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 44
typedef enum{
    kTag_Topbar =100,
    kTag_scroll,
    kTag_ContentView,
    kTag_Profileimg,
    kTag_Privacyimg,
    kTag_Feedview,
    kTag_trustStatus,
    kTag_viewlikecomment,
    kTag_lowerCommentViewsep,
    kTag_uppersep,
    kTag_ImgFeed,
    
}All_Tag;
@interface NewCommentVC (){
    NSString * permstus;
    CAPSPhotoView *photoView;
    NSString *updateTime;
}

@end

@implementation NewCommentVC
@synthesize feedDict;
@synthesize feedCommentIdStr,t_likeStr,t_likeStatusStr;
- (void)viewDidLoad {
    [super viewDidLoad];
    isCommentpost = NO;
    isCheckviaRefreshComments =NO;
    offset = 1;
    limit = @"10";
    selectedSection = 0;
    selectedRow =0;
    isReplyComment = NO;
    totalLikes =0;
    self.view.backgroundColor = [UIColor whiteColor];
    //[self setupTableView];
    self.feedid = [self.feedDict valueForKey:@"feed_id"];
    self.t_likeStr = [feedDict objectForKey:@"total_like"];
    self.commentArray = [[NSMutableArray alloc]init];
    self.tableView.tableHeaderView = [self headerView];
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    
    if([[feedDict valueForKey:@"total_comments"]integerValue]!=0){
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        self.tableView.tableFooterView = spinner;
        [self getFeedCommentRequest];
    }
    else{
        self.tableView.showsPullToRefresh = NO;
    }
    NSString* tFeedLike = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"total_like"]?[feedDict objectForKey:@"total_like"]:@""];
    totalLikes = tFeedLike.integerValue;
    totalComment =[[feedDict valueForKey:@"total_comments"]integerValue];
}


- (void)viewWillAppear:(BOOL)animated {
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Visit Feed Detail screen"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Comments";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica SemiBold" size:16.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
    [self checkFeedStat];
    // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width - 70, 32)];
    commentTextView.textContainer.lineFragmentPadding = 8;
    commentTextView.delegate = self;
    commentTextView.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
    commentTextView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    commentTextView.layer.cornerRadius = 4.0;
    commentTextView.layer.borderWidth = 0.5f;
    commentTextView.font = [UIFont systemFontOfSize:13.0];
    placeholder = [[UILabel alloc]initWithFrame:CGRectMake(8, 1, commentTextView.frame.size.width, 30)];
    placeholder.text = @"Write a comment...";
    placeholder.font = [UIFont systemFontOfSize:13.0];
    placeholder.textColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
    [commentTextView addSubview:placeholder];
    //commentTextView.text = @"Write a comment...";
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:commentTextView];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    spacer.width = 16;
    postbtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postButtonAction)];
    [postbtn setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium]} forState:UIControlStateNormal];
    [self.toolbar setItems:[[NSArray alloc] initWithObjects:barItem,postbtn,nil]];
    // [self.toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    if([commentTextView hasText])
    {
        postbtn.enabled = YES;
        commentTextView.scrollEnabled = YES;
        placeholder.hidden = YES;
     }
    else
    {
        postbtn.enabled = NO;
        commentTextView.scrollEnabled = NO;
        placeholder.hidden = NO;
    }
    [self.view setNeedsLayout];
    [self subscribeToKeyboard];
    _isNoifPView?[self setBackButton]:nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //totalLikes = t_likeStr.integerValue;
    updateTime = updateTime?updateTime:@"";
    if(!_isNoifPView){
        if (offset==2){
            if(isCommentpost == YES){
                 totalComment =[[feedDict valueForKey:@"total_comments"]integerValue];
                totalComment++;
            }
            else{
            totalComment =[[feedDict valueForKey:@"total_comments"]integerValue];
            }
            [self.delegate commentviewReturnsForFeedid:[self.feedDict valueForKey:@"feed_id"] commentCount:[NSString stringWithFormat:@"%ld",(long)totalComment] LikesCount:[NSString stringWithFormat:@"%ld",(long)totalLikes]ilike:isMyLike updatedTimeStamp:updateTime];
        }
        else
        {
            if(isCheckviaRefreshComments == YES){
                totalComment = [[feedDict valueForKey:@"total_comments"]integerValue];
                if(isCommentpost == YES){
                    totalComment++;
                }
             }
            else
            {
            }
           [self.delegate commentviewReturnsForFeedid:[self.feedDict valueForKey:@"feed_id"] commentCount:[NSString stringWithFormat:@"%ld",(long)totalComment] LikesCount:[NSString stringWithFormat:@"%ld",(long)totalLikes]ilike:isMyLike updatedTimeStamp:updateTime];
            }
      }
  }

#pragma mark - Post Button Click
-(void)postButtonAction
{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Post Comment"];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        isClickFromShare =NO;
        [self getcheckedUserPermissionData];
    }
    else{
        [self hideKeyboard];
        // NSLog(@"Post your comment");
        if (!isReplyComment)
        {
            [Localytics tagEvent:@"WhatsTrending CommentScreen CommentPost Click"];
            NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (result.length > 0) {
                NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                [userpref setObject:self.feedCommentIdStr forKey:feedID];
                [userpref setObject:result forKey:feedComment];
                [userpref synchronize];
                if ([commentTextView.text length] == 0){
                    [UIAppDelegate alerMassegeWithError:@"Please write a comment." withButtonTitle:OK_STRING autoDismissFlag:NO];
                    return;
                }
                lastComment = result; //commentTextview.text;
                [self setCommentdata];
            }
        }else{
            [Localytics tagEvent:@"WhatsTrending CommentScreen CommentReplyPost Click"];
            NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (result.length > 0) {
                 if ([commentTextView.text length] == 0){
                    [UIAppDelegate alerMassegeWithError:@"Please write a reply." withButtonTitle:OK_STRING autoDismissFlag:NO];
                    return;
                }
                lastComment = result; //commentTextview.text;
                // [self setCommentReplydata];
                [self setCommentReplyAction:@"add" replyID:@""];
            }
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([commentTextView hasText]){
        postbtn.enabled = YES;
       //commentTextView.scrollEnabled = YES;
        placeholder.hidden = YES;
     }
    else
    {
        postbtn.enabled = NO;
        commentTextView.scrollEnabled = NO;
        placeholder.hidden = NO;
    }
    _previousContentHeight = textView.frame.size.height;
    CGFloat maxHeight = 90.0f;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fminf(newSize.height, maxHeight));
    textView.frame = newFrame;
    //   CGRect inputrect;
    if(newSize.height > 90){
        commentTextView.scrollEnabled = YES;
    }else{
        commentTextView.scrollEnabled = NO;
    }
    if (_previousContentHeight<newSize.height) {
        self.toolBarHeightConstraints.constant = self.toolBarHeightConstraints.constant + (newFrame.size.height-_previousContentHeight);
        
    }else if (_previousContentHeight>newSize.height){
        self.toolBarHeightConstraints.constant = self.toolBarHeightConstraints.constant - (_previousContentHeight - newFrame.size.height);
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.height -self.toolbar.frame.origin.y - 50, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Custom View For Table Header
-(UIView *)headerView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *conView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 10)];
    UIView *FeedView;
    conView.backgroundColor = [UIColor redColor];
    int viewHeight = 0;
    //   int i =0;
    FeedView= [[UIView alloc]init];
    CGRect FeedRect = CGRectMake(0, 0,width, 200);
    FeedView.frame = FeedRect;
    FeedView.tag = kTag_Feedview;
    [conView addSubview:FeedView];
    FeedView.backgroundColor = [UIColor clearColor];
    if ([[feedDict valueForKey:@"file_type"]isEqualToString:@"image"]) {
        isImg = YES;
    }else{
        isImg = NO;
    }
    if ([[feedDict valueForKey:@"file_type"]isEqualToString:@"link"]) {
        ismetaData = YES;
    }else{
        ismetaData = NO;
    }
    if ([[feedDict valueForKey:@"file_type"]isEqualToString:@"video"]) {
        isVideo = YES;
    }else{
        isVideo = NO;
    }
    if ([[feedDict valueForKey:@"file_type"]isEqualToString:@"document"]) {
        isDocument = YES;
    }else{
        isDocument = NO;
    }
    UIImageView *profileImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10 , 40, 40)];
    NSString*feedPostedUserPic = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"profile_pic_path"]?[feedDict objectForKey:@"profile_pic_path"]:@""];
    
    [profileImg sd_setImageWithURL:[NSURL URLWithString:feedPostedUserPic]
                  placeholderImage:[UIImage imageNamed:@"avatar.png"]
                           options:SDWebImageRefreshCached];
    profileImg.contentMode = UIViewContentModeScaleAspectFill;
    profileImg.layer.cornerRadius = 4.0;
    profileImg.layer.masksToBounds = YES;
    
    profileImg.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    profileImg.layer.borderWidth = 0.5;
    
    profileImg.tag = kTag_Profileimg;
    [FeedView addSubview:profileImg];
    
    UILabel *LblUserName = [[UILabel alloc]initWithFrame:CGRectMake(profileImg.frame.size.width + profileImg.frame.origin.x + 10, profileImg.frame.origin.y, FeedView.frame.size.width -(profileImg.frame.size.width + profileImg.frame.origin.x +32), 16)];
    LblUserName.font = [UIFont boldSystemFontOfSize:14.0];
    LblUserName.backgroundColor = [UIColor clearColor];
    NSString*username  = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"name"]?[feedDict objectForKey:@"name"]:@""];
    username = [[username  stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    LblUserName.text =  [username capitalizedString];
    [FeedView addSubview:LblUserName];
    feedsshareUrl = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"feed_share_url"]?[feedDict objectForKey:@"feed_share_url"]:@""];
    
    UIImageView *ImgPrivacy = [[UIImageView alloc]initWithFrame:CGRectMake(LblUserName.frame.origin.x, LblUserName.frame.origin.y + LblUserName.frame.size.height+ 4 , 16, 16)];
    //ImgPrivacy.layer.cornerRadius = 7.0;
    ImgPrivacy.contentMode = UIViewContentModeScaleAspectFill;
    ImgPrivacy.layer.masksToBounds = YES;
    ImgPrivacy.tag = kTag_Privacyimg;
    [FeedView addSubview:ImgPrivacy];
    
    assoLbl = [[UILabel alloc]initWithFrame:CGRectMake(ImgPrivacy.frame.size.width + ImgPrivacy.frame.origin.x +3, LblUserName.frame.origin.y + LblUserName.frame.size.height+4, FeedView.frame.size.width -(ImgPrivacy.frame.origin.x), 15)];
    assoLbl.font = [UIFont systemFontOfSize:13.0];
    assoLbl.textColor = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
    assoLbl.backgroundColor = [UIColor clearColor];
    [FeedView addSubview:assoLbl];
    NSMutableArray *assoarr = [[NSMutableArray alloc]init];
    assoarr =[feedDict objectForKey:@"association_list"];
    NSMutableString *asId;
    NSMutableString *assoImg;
    NSMutableString *assoName;
    for(int i=0; i<[assoarr count]; i++)
    {
        NSDictionary *assoInfo =  assoarr[i];
        if ([assoarr count]==1){
            if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
            {
                asId = assoInfo[@"association_id"];
                assoImg = assoInfo[@"association_pic"];
                assoName = assoInfo[@"association_name"];
                assoLbl.text = [NSString stringWithFormat:@" %@ \uA789",assoName];
                [ImgPrivacy  sd_setImageWithURL:[NSURL URLWithString:assoImg]
                               placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                        options:SDWebImageRefreshCached];
            }
        }
        else if ([assoarr count]>1) {
            //associationList = @"Everyone";
         
                if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
                {
                    NSInteger assoCountNumber = ([assoarr count]-1);
                    NSString*assoNumbers =  [NSString stringWithFormat:@"%ld", assoCountNumber];
                    //asId = assoInfo[@"association_id"];
                    assoImg = [assoarr objectAtIndex:0][@"association_pic"];
                    assoName = [assoarr objectAtIndex:0][@"association_name"];
                      // [assoInfo[@"association_pic"]objectAtIndex:0];
                    //assoName = [assoInfo[@"association_name"]objectAtIndex:0];
                   assoLbl.text = [NSString stringWithFormat:@" %@ + %@ \uA789",assoName,assoNumbers];
                    [ImgPrivacy sd_setImageWithURL:[NSURL URLWithString:assoImg]
                                          placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                                   options:SDWebImageRefreshCached];
                }
         }
    }
    assoLbl.numberOfLines =0;
    [assoLbl sizeToFit];
    LblTime = [[UILabel alloc]initWithFrame:CGRectMake(assoLbl.frame.size.width + assoLbl.frame.origin.x +3, LblUserName.frame.origin.y + LblUserName.frame.size.height+4, FeedView.frame.size.width-assoLbl.frame.size.width-assoLbl.frame.origin.x-40, 15)];
    LblTime.font = [UIFont systemFontOfSize:13.0];
    LblTime.textColor = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
    LblTime.backgroundColor = [UIColor clearColor];
    [FeedView addSubview:LblTime];
    [self setUpdateTimewithDic:feedDict];
    LblTime.text =[self setUpdateTimewithDic:feedDict];
    LblTitle = [[UILabel alloc]initWithFrame:CGRectMake(profileImg.frame.origin.x, profileImg.frame.origin.y + profileImg.frame.size.height+8, FeedView.frame.size.width -(profileImg.frame.origin.x)*2, 21)];
    LblTitle.font = [UIFont boldSystemFontOfSize:13.0];
    NSString*feed_title =[NSString stringWithFormat:@"%@",[feedDict objectForKey:@"title"]?[feedDict objectForKey:@"title"]:@""];
    LblTitle.text= [feed_title stringByDecodingHTMLEntities];
    
    CGRect tempFrameLblTitle = LblTitle.frame;
    LblTitle.numberOfLines = 0;
    LblTitle.backgroundColor = [UIColor clearColor];
    LblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [LblTitle sizeToFit];
    CGRect finalFrameLblTitle = LblTitle.frame;
    finalFrameLblTitle.size.width = tempFrameLblTitle.size.width;
    LblTitle.frame = finalFrameLblTitle;
    [FeedView addSubview:LblTitle];
    photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height) dateTitle:LblTime.text
                                               title:LblUserName.text
                                            subtitle:LblTitle.text];
    
    //Set open profile View
    UITapGestureRecognizer *taponUserNameLbl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFeederProfileView:)];
    [LblUserName setUserInteractionEnabled:YES];
    [LblUserName addGestureRecognizer:taponUserNameLbl];
    
    //Set open profile View
    UITapGestureRecognizer *taponTimeLbl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFeederProfileView:)];
    [LblTime setUserInteractionEnabled:YES];
    [LblTime addGestureRecognizer:taponTimeLbl];
    
    //Set open profile View
    UITapGestureRecognizer *taponUserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFeederProfileView:)];
    [profileImg setUserInteractionEnabled:YES];
    [profileImg addGestureRecognizer:taponUserImg];
    
    //Set open profile View
    UITapGestureRecognizer *taponAssoLbl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFeederProfileView:)];
    [assoLbl setUserInteractionEnabled:YES];
    [assoLbl  addGestureRecognizer:taponAssoLbl];
    
    //Set open profile View
    UITapGestureRecognizer *taponImgAsso = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFeederProfileView:)];
    [ImgPrivacy setUserInteractionEnabled:YES];
    [ImgPrivacy addGestureRecognizer:taponImgAsso];
    
    NSString*specialityId;
    NSString*specialityName;
    NSMutableArray* Specialityarr = [[NSMutableArray alloc]init];
    NSMutableArray* SpecialityNamearr = [[NSMutableArray alloc]init];
    NSMutableArray* SpecialityIdArr = [[NSMutableArray alloc]init];
     Specialityarr = [feedDict valueForKey:@"speciality"];
      UITextView * LblDesc = [[UITextView alloc]init];
    if ([Specialityarr count] == 0) {
        LblDesc.frame = CGRectMake(4, LblTitle.frame.origin.y + LblTitle.frame.size.height, FeedView.frame.size.width -(profileImg.frame.origin.x)*2, 0);
    }
    else
    {
    KILabel *specialityTaglbl = [[KILabel alloc]initWithFrame: CGRectMake(profileImg.frame.origin.x, LblTitle.frame.origin.y + LblTitle.frame.size.height+5, FeedView.frame.size.width -(profileImg.frame.origin.x)*2, 20)];
    specialityTaglbl.font = [UIFont systemFontOfSize:13.0];
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range)
        {
        [self tappedLink:string cellForRowAtIndexPath:nil];
        //    NSLog(@"string = %@",string);
           // [self forceDownKeyboard];
        };
        specialityTaglbl.hashtagLinkTapHandler = tapHandler;
        
    for(int i=0; i<[Specialityarr count]; i++)
    {
        NSDictionary *speclityInfo =  Specialityarr[i];
        if (speclityInfo != nil && [speclityInfo isKindOfClass:[NSDictionary class]])
        {
            specialityId = speclityInfo[@"speciality_id"];
            specialityName = speclityInfo[@"speciality_name"];
        }
        [SpecialityNamearr addObject:specialityName];
        [SpecialityIdArr addObject:specialityId];
    }
    NSString * myspeciality = [[SpecialityNamearr valueForKey:@"description"] componentsJoinedByString:@" #"];
  
    myspeciality = [myspeciality stringByDecodingHTMLEntities];
    //  NSLog(@"Speciality Tag Name: %@",myspeciality);
    
    specialityTaglbl.text =     [NSString stringWithFormat:@"#%@", [myspeciality stringByDecodingHTMLEntities]];
  //   NSLog(@"Speciality label Name: %@",specialityTaglbl.text);
    CGRect tempFrameLblsoecilityframe = specialityTaglbl.frame;
    specialityTaglbl.numberOfLines = 0;
    specialityTaglbl.backgroundColor = [UIColor clearColor];
    specialityTaglbl.lineBreakMode = NSLineBreakByWordWrapping;
    [specialityTaglbl sizeToFit];
    CGRect finalFrameLblSpecility = specialityTaglbl.frame;
    finalFrameLblSpecility.size.width = tempFrameLblsoecilityframe.size.width;
    specialityTaglbl.frame = finalFrameLblSpecility;
        FeedView.userInteractionEnabled = YES;
        specialityTaglbl.userInteractionEnabled = YES;
    [FeedView addSubview:specialityTaglbl];
    LblDesc.frame = CGRectMake(4, specialityTaglbl.frame.origin.y + specialityTaglbl.frame.size.height-5, FeedView.frame.size.width -(profileImg.frame.origin.x)*2, 0);
    }
    
    LblDesc.font = [UIFont systemFontOfSize:13.0];
    LblDesc.textColor = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
    NSString *content =[NSString stringWithFormat:@"%@",[feedDict objectForKey:@"content"]?[feedDict objectForKey:@"content"]:@""];
    content = [content stringByDecodingHTMLEntities];
    content = [content stringByDecodingHTMLEntities];
    content = [content stringByReplacingOccurrencesOfString: @"<br>" withString: @" "];
    content = [content stringByReplacingOccurrencesOfString:@"<br/>" withString: @" "];
    content=  [content stringByReplacingOccurrencesOfString:@"<br />" withString: @" "];
    
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            //NSLog(@"found URL: %@", url);
            //content = [url absoluteString];
        }
    }
    if ([content.lowercaseString containsString:[NSString stringWithFormat:@"%@",url]]) {
        // NSLog(@"mesg: %@",content);
        content =  [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",url] withString:[NSString stringWithFormat:@"%@",url] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
        
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        
    }else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    LblDesc.backgroundColor = [UIColor clearColor];
    LblDesc.editable = NO;
    LblDesc.scrollEnabled = NO;
    LblDesc.dataDetectorTypes = UIDataDetectorTypeAll;
    if([[feedDict valueForKey:@"classification"] isEqualToString:@"cme"]){
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:content  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(Click here)" options:kNilOptions error:nil]; // Matches 'Click here' case SENSITIVE
        NSRange range = NSMakeRange(0 ,content.length);
        
        // Change all words that are equal to 'Click here' to hyperlink color in the attributed string
        [regex enumerateMatchesInString:content options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange subStringRange = [result rangeAtIndex:0];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] range:subStringRange];
        }];
        
        LblDesc .attributedText = mutableAttributedString;
        //Set open CME View
        UITapGestureRecognizer *taponcontent = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCMEView:)];
        [LblDesc setUserInteractionEnabled:YES];
        [LblDesc addGestureRecognizer:taponcontent];
    }
    else{
    LblDesc.text = content;
    }
     if(content.length >0)
    {
        CGFloat fixedWidth = LblDesc.frame.size.width;
        CGSize newSize = [LblDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = LblDesc.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        LblDesc.frame = newFrame;
        LblDesc.scrollEnabled = NO;
        LblDesc.editable = NO;
        LblDesc.dataDetectorTypes = UIDataDetectorTypeLink;
    }
    [FeedView addSubview:LblDesc];
    
    // Create Image Feed
    UIView *ImgFeed = [[UIView alloc]init];
    ImgFeed.tag = kTag_ImgFeed;
    CGRect ImgFeedRect =CGRectMake(0, LblDesc.frame.origin.y + LblDesc.frame.size.height+5 , FeedView.frame.size.width , 0);
    
    //Set meta WebView
    UIWebView *metacontentWv = [[UIWebView alloc]init];
    metacontentWv.backgroundColor = [UIColor clearColor];
    metacontentWv.contentMode = UIViewContentModeScaleToFill;
    metacontentWv.layer.borderWidth = 1.0;
    metacontentWv.layer.borderColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0].CGColor;
    metacontentWv.clipsToBounds = YES;
    [metacontentWv.scrollView setScrollEnabled:NO];
    CGRect metaFeedRect =CGRectMake(LblTitle.frame.origin.x, LblDesc.frame.origin.y + LblDesc.frame.size.height+5 , FeedView.frame.size.width -(LblTitle.frame.origin.x)*2, 0);
    UIButton *metalinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    metalinkBtn .backgroundColor = [UIColor clearColor];
    CGRect btnframe =CGRectMake(LblTitle.frame.origin.x, 5, FeedView.frame.size.width -(LblTitle.frame.origin.x)*2, 250);
    metalinkBtn.frame = btnframe;
    [metacontentWv addSubview:metalinkBtn];
    
    //set video View
    UIImageView *VideoImgFeed = [[UIImageView alloc]init];
    VideoImgFeed.backgroundColor = [UIColor clearColor];
    CGRect VideoImgFeedRect =CGRectMake(LblTitle.frame.origin.x, LblDesc.frame.origin.y + LblDesc.frame.size.height+5 , FeedView.frame.size.width -(LblTitle.frame.origin.x)*2, 0);
    
    //set document View
    documentView= [[UIView alloc]init];
    documentView.frame = CGRectMake(LblTitle.frame.origin.x, LblDesc.frame.origin.y + LblDesc.frame.size.height+5 , FeedView.frame.size.width -(LblTitle.frame.origin.x)*2, 132);
    documentView.backgroundColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [FeedView addSubview:documentView];
    UIImageView *documentImgFeed = [[UIImageView alloc]init];
    documentImgFeed .frame = CGRectMake(5, 5, documentView.frame.size.width-10, 85.0f);
    documentImgFeed.backgroundColor = [UIColor clearColor];
    documentImgFeed.contentMode = UIViewContentModeScaleAspectFill;
    documentImgFeed.clipsToBounds = YES;
    [documentView addSubview:documentImgFeed];
    documentContainerVw = [[UIView alloc]init];
    documentContainerVw.frame = CGRectMake(5, 90, documentView.frame.size.width-10, 37.0f);
    [documentView addSubview:documentContainerVw];
    documentContainerVw.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
    
    //Add file name label
    lbl_doc_file_name = [[UILabel alloc]init];
    lbl_doc_file_name.backgroundColor = [UIColor clearColor];
    lbl_doc_file_name.textColor = [UIColor whiteColor];
    lbl_doc_file_name.font = [UIFont systemFontOfSize:15.0f];
    lbl_doc_file_name.frame = CGRectMake(35 ,5 , documentImgFeed.frame.size.width -40, 25.0f);
    [documentContainerVw addSubview:lbl_doc_file_name];
    
    //Add imageType
    img_document_type = [[UIImageView alloc]init];
    img_document_type.backgroundColor = [UIColor clearColor];
    img_document_type.contentMode = UIViewContentModeScaleAspectFill;
    img_document_type.clipsToBounds = YES;
    [documentContainerVw addSubview:img_document_type];
    img_document_type.frame = CGRectMake(5, 5, 25, 25);
    [documentContainerVw addSubview: img_document_type];

    if (isImg) {
        metalinkBtn.hidden =YES;
        metacontentWv.hidden = YES;
        VideoImgFeed.hidden = YES;
        ImgFeed.hidden = NO;
        documentView.hidden = YES;
        ImgFeedRect.size.height = 250;
        ImgFeed.frame = ImgFeedRect;
         if([[feedDict valueForKey:@"image_list"]count]>1){
            [ImgFeed addSubview:[self makeCollageViewInParentView:ImgFeed withNumberOfCollage:[[feedDict valueForKey:@"image_list"]count] ImageUrls:[feedDict valueForKey:@"image_list"]]];
            
        } else {
            singleImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ImgFeedRect.size.width, 250)];
            singleImage.contentMode  = UIViewContentModeScaleAspectFill;
            singleImage.layer.masksToBounds = YES;
            NSString *imgFileUrl = [ self.feedDict valueForKey:@"file_url"];
            //imgFileUrl = [ImageUrl stringByAppendingPathComponent:imgFileUrl];
            
            [singleImage sd_setImageWithURL:[NSURL URLWithString:imgFileUrl] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
             [ImgFeed addSubview:singleImage];
            singleImage.userInteractionEnabled = YES;
            
            UIButton *singleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            singleButton.frame = CGRectMake(0, 0, singleImage.frame.size.width, singleImage.frame.size.height);
            [singleImage addSubview:singleButton];
            [singleButton addTarget:self action:@selector(viewSingleImage:) forControlEvents:UIControlEventTouchUpInside];
        }
        [FeedView addSubview:ImgFeed];
    }
    if (ismetaData) {
        metalinkBtn.hidden =NO;
        NSString*feedGetmeta = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"file_url"]?[feedDict objectForKey:@"file_url"]:@""];
        feedmetaUrlLink = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"meta_url"]?[feedDict objectForKey:@"meta_url"]:@""];
        [metalinkBtn addTarget:self action:@selector(openMetadataUrlLink:) forControlEvents:UIControlEventTouchUpInside];
        
        //Set Feed meta
        metaFeedRect.size.height = 250;
        feed_ImgURL= [feedGetmeta stringByDecodingHTMLEntities];
        metacontentWv.opaque = NO;
        CGRect rect;
        metacontentWv.backgroundColor = [UIColor clearColor];
        rect = metacontentWv.frame;
        rect.size.height = 1;
        metacontentWv.frame = rect;
        [metacontentWv loadHTMLString:feed_ImgURL baseURL:nil];
        metacontentWv.frame = metaFeedRect;
        [FeedView addSubview:metacontentWv];
    }
    if (isDocument) {
        ImgFeed.hidden = YES;
        metacontentWv.hidden = YES;
        VideoImgFeed.hidden = NO;
        metalinkBtn.hidden =YES;
        documentfeedUrlLink = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"file_url"]?[feedDict objectForKey:@"file_url"]:@""];
       // documentfeedUrlLink = [ImageUrl stringByAppendingString:documentfeedUrlLink];
        
        NSString*document_thumUrl =  [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"video_image_url"]?[feedDict objectForKey:@"video_image_url"]:@""];
        
        //document_thumUrl = [ImageUrl stringByAppendingPathComponent:document_thumUrl];
        NSString *name = feedDict[@"file_name"];
        NSString *type = [name pathExtension];
        
        name = [name stringByReplacingOccurrencesOfString:type withString:@""];
        name = [name substringToIndex:name.length-(name.length>0)];
        lbl_doc_file_name.text = name;
        
        if([type isEqualToString:@"pdf"]){
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"pdf_placeholder.png"]
                                        options:SDWebImageRefreshCached];
            img_document_type.image = [UIImage imageNamed:@"pdf.png"];
        }else if([type containsString:@"xls"]){
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"xls_placeholder.png"]];
            img_document_type.image = [UIImage imageNamed:@"xls.png"];
        }else if([type containsString:@"ppt"]){
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"ppt_placeholder.png"]];
            img_document_type.image = [UIImage imageNamed:@"ppt.png"];
        }else if([type containsString:@"doc"]){
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"doc_placeholder.png"]];
            img_document_type.image = [UIImage imageNamed:@"doc.png"];
        }else if ([type isEqualToString:@"rtf"]){
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"rtf_placeholder.png"]];
            img_document_type.image = [UIImage imageNamed:@"rtf.png"];
        }else if ([type isEqualToString:@"txt"]){
            img_document_type.image = [UIImage imageNamed:@"txt.png"];
            [documentImgFeed sd_setImageWithURL:[NSURL URLWithString:document_thumUrl]
                               placeholderImage:[UIImage imageNamed:@"txt_placeholder.png"]];
        }
        UITapGestureRecognizer *tapondocumentImgFeed = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openDocument:)];
        [documentImgFeed setUserInteractionEnabled:YES];
        [documentImgFeed addGestureRecognizer:tapondocumentImgFeed];
    }
    if (isVideo) {
        ImgFeed.hidden = YES;
        metacontentWv.hidden = YES;
        VideoImgFeed.hidden = NO;
        metalinkBtn.hidden =YES;
        fileUrlLink = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"file_url"]?[feedDict objectForKey:@"file_url"]:@""];
        //fileUrlLink = [ImageUrl stringByAppendingString:fileUrlLink];
      
        NSString*video_thumUrl =  [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"video_image_url"]?[feedDict objectForKey:@"video_image_url"]:@""];
        
        //video_thumUrl = [ImageUrl stringByAppendingPathComponent:video_thumUrl];
        [VideoImgFeed sd_setImageWithURL:[NSURL URLWithString:video_thumUrl]
                        placeholderImage:[UIImage imageNamed:@"videoPlaceholder.png"]
                                 options:SDWebImageRefreshCached];
        
        UITapGestureRecognizer *taponvideoImgFeed = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openVideo:)];
        [VideoImgFeed setUserInteractionEnabled:YES];
        [VideoImgFeed addGestureRecognizer:taponvideoImgFeed];
        
        //Set Feed video
        VideoImgFeedRect.size.height = 250;
        //NSLog(@"Height : %f", VideoImgFeedRect.size.height);
        
        VideoImgFeed.frame = VideoImgFeedRect;
        [FeedView addSubview:VideoImgFeed];
        VideoImgFeed.contentMode = UIViewContentModeScaleAspectFill;
        VideoImgFeed.layer.masksToBounds  = YES;
    }
    UIView*Viewlikecomment;
    if (ismetaData) {
        metacontentWv.hidden = NO;
        metalinkBtn.hidden = NO;
        documentView.hidden = YES;
        Viewlikecomment = [[UIView alloc]initWithFrame:CGRectMake(0,  metacontentWv.frame.origin.y +  metacontentWv.frame.size.height+4, FeedView.frame.size.width, 30)];
    }
    else if (isImg) {
        metacontentWv.hidden = YES;
        metalinkBtn.hidden = YES;
        Viewlikecomment = [[UIView alloc]initWithFrame:CGRectMake(0,  ImgFeed.frame.origin.y +  ImgFeed.frame.size.height+4, FeedView.frame.size.width, 30)];
    }
    else if (isVideo) {
        metacontentWv.hidden = YES;
        metalinkBtn.hidden = YES;
        Viewlikecomment = [[UIView alloc]initWithFrame:CGRectMake(0,  VideoImgFeed.frame.origin.y +  VideoImgFeed.frame.size.height+4, FeedView.frame.size.width, 30)];
    }
    else if (isDocument) {
        metacontentWv.hidden = YES;
        metalinkBtn.hidden = YES;
        Viewlikecomment = [[UIView alloc]initWithFrame:CGRectMake(0,  documentView.frame.origin.y +  documentView.frame.size.height+4, FeedView.frame.size.width, 30)];
    }
    else{
        metacontentWv.hidden = YES;
        documentView.hidden = YES;
        metalinkBtn.hidden = YES;
        Viewlikecomment = [[UIView alloc]initWithFrame:CGRectMake(0, LblDesc.frame.origin.y + LblDesc.frame.size.height + 4, FeedView.frame.size.width, 30)];
    }
    Viewlikecomment.backgroundColor = [UIColor clearColor];
    Viewlikecomment.tag = kTag_viewlikecomment;
    [FeedView addSubview:Viewlikecomment];
    UILabel *lblSep = [[UILabel alloc]initWithFrame:CGRectMake(4, 0, FeedView.frame.size.width -8, 0.5)];
    lblSep.backgroundColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];
    [Viewlikecomment addSubview:lblSep];
    
    BtnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    BtnLike.backgroundColor = [UIColor clearColor];
    BtnLike.frame = CGRectMake(10, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    [BtnLike setTitle:@"Like" forState:UIControlStateNormal];
    [BtnLike setTitleColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    [BtnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    BtnLike.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    BtnLike.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    BtnLike.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    BtnLike.titleEdgeInsets = UIEdgeInsetsMake(6.0, 9.0 , 3.0, 0.0);
    BtnLike.imageEdgeInsets = UIEdgeInsetsMake(5.0, 6.0, 4.0, 5.0);
    myLikeStatus = [[feedDict objectForKey:@"like_status"]integerValue];
    if (myLikeStatus==0) {
        [BtnLike setTitleColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
        [BtnLike setImage:[UIImage imageNamed:@"trust-hover"] forState:UIControlStateNormal];
        [BtnLike setTitle:@"Like" forState:UIControlStateNormal];
        
        [BtnLike addTarget:self action:@selector(serviceCallingLike:) forControlEvents:UIControlEventTouchUpInside];
        }
    else if (myLikeStatus==1)
    {
        [BtnLike setTitleColor: [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1] forState:UIControlStateNormal];
        [BtnLike setImage:[UIImage imageNamed:@"trust"] forState:UIControlStateNormal];
        [BtnLike setTitle:@"Liked" forState:UIControlStateNormal];
    }
    
    UIButton *BtnComment = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_6_PLUS){
    BtnComment.frame= CGRectMake(BtnLike.frame.size.width+30, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    else if (IS_IPHONE_6){
     BtnComment.frame= CGRectMake(BtnLike.frame.size.width+20, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    else{
        BtnComment.frame= CGRectMake(BtnLike.frame.size.width+15, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    [BtnComment setTitle:@"Comment" forState:UIControlStateNormal];
    BtnComment.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [BtnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [BtnComment setTitleColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    [BtnComment addTarget:self action:@selector(openkeyboard) forControlEvents:UIControlEventTouchUpInside];
    UIButton *Btnshare = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_6_PLUS){
        Btnshare.frame= CGRectMake(BtnComment.frame.size.width+200, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    else if (IS_IPHONE_6){
        Btnshare.frame= CGRectMake(BtnComment.frame.size.width+180, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    else{
        Btnshare.frame= CGRectMake(BtnComment.frame.size.width+150, 4, (Viewlikecomment.frame.size.width-20)/3, 24);
    }
    [Btnshare setTitle:@"Share" forState:UIControlStateNormal];
    Btnshare.titleLabel.font = [UIFont systemFontOfSize:13.0];
    Btnshare.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [Btnshare setImage:[UIImage imageNamed:@"Shared"] forState:UIControlStateNormal];
    [Btnshare setTitleColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    Btnshare.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    Btnshare.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    Btnshare.titleEdgeInsets = UIEdgeInsetsMake(6.0, 10.0 , 3.0, 0.0);
    Btnshare.imageEdgeInsets = UIEdgeInsetsMake(9.0, 6.0, 3.0, 6.0);
    
    BtnComment.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    BtnComment.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    BtnComment.titleEdgeInsets = UIEdgeInsetsMake(6.0, 10.0, 3.0, 0.0);
    BtnComment.imageEdgeInsets = UIEdgeInsetsMake(9.0, 6.0, 3.0, 5.0);
    
    [Btnshare addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [Viewlikecomment addSubview:BtnLike];
    [Viewlikecomment addSubview:BtnComment];
    [Viewlikecomment addSubview:Btnshare];
    
    FeedRect.size.height = Viewlikecomment.frame.size.height + Viewlikecomment.frame.origin.y+4;
    FeedView.backgroundColor = [UIColor whiteColor];
    // ScrV.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    UIView *trustCountView = [[UIView alloc]initWithFrame:CGRectMake(0, Viewlikecomment.frame.size.height + Viewlikecomment.frame.origin.y +4, FeedRect.size.width, 35)];
    // trustCountView.tag = kt
    [FeedView addSubview:trustCountView];
    
    UILabel *uppersep =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, trustCountView.frame.size.width, 0.5)];
    uppersep.backgroundColor =  [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];
    [trustCountView addSubview:uppersep];
    
    LbltrustCount =[[UILabel alloc]initWithFrame:CGRectMake(10, uppersep.frame.size.height + uppersep.frame.origin.y+7, trustCountView.frame.size.width-20, 20)];
    LbltrustCount.backgroundColor = [UIColor clearColor];
    LbltrustCount.font = [UIFont boldSystemFontOfSize:12.0];
    
    UIImageView *arrow_icon;
    if (IS_IPHONE_6) {
        arrow_icon= [[UIImageView alloc]initWithFrame:CGRectMake(350, uppersep.frame.size.height + uppersep.frame.origin.y+12, 12, 12)];
    }
    else if(IS_IPHONE_6_PLUS){
        arrow_icon= [[UIImageView alloc]initWithFrame:CGRectMake(390, uppersep.frame.size.height + uppersep.frame.origin.y+12, 12, 12)];
    }
    else{
        arrow_icon= [[UIImageView alloc]initWithFrame:CGRectMake(300, uppersep.frame.size.height + uppersep.frame.origin.y+12, 12, 12)];
    }
    arrow_icon.image = [UIImage imageNamed:@"forward.png"];
    arrow_icon.backgroundColor = [UIColor clearColor];
    [trustCountView addSubview: arrow_icon];
    
    long int total_trust = ([t_likeStr integerValue]-1);
    NSString*t_trust = [NSString stringWithFormat:@"%ld", total_trust];
    
    if([t_trust integerValue] ==1 && [t_likeStatusStr integerValue] == 1)
    {
        LbltrustCount.text = [[@"You and " stringByAppendingString:t_trust] stringByAppendingString:@" Doctor likes this."];
        
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"likes this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    if([t_trust integerValue] > 1 && [t_likeStatusStr integerValue] == 1)
    {
        LbltrustCount.text = [[@"You and " stringByAppendingString:t_trust] stringByAppendingString:@" Doctors like this."];
         NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"like this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    if([t_likeStatusStr integerValue] == 1&& [t_likeStr integerValue] == 1)
    {
        LbltrustCount.text = [@"You" stringByAppendingString:@" like this."];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"like this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    if([t_likeStr integerValue] == 1 && [t_likeStatusStr integerValue] == 0)
    {
        LbltrustCount.text = [t_likeStr stringByAppendingString:@" Doctor likes this."];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"likes this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    if([t_likeStr integerValue] > 1 && [t_likeStatusStr integerValue] == 0)
    {
        LbltrustCount.text = [t_likeStr stringByAppendingString:@" Doctors like this."];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"like this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    if([t_likeStr integerValue] == 0 && [t_likeStatusStr integerValue] == 0)
    {
        LbltrustCount.text = @"Be the first doctor to like this.";
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
        NSString *boldString = @"like this.";
        NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
        [LbltrustCount setAttributedText: yourAttributedString];
    }
    UITapGestureRecognizer *likeLblgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openfeedLikeList:)];
    if([t_likeStr integerValue] == 0 && [t_likeStatusStr integerValue] == 0){
        [LbltrustCount setUserInteractionEnabled:NO];
    }
    else{
        [LbltrustCount setUserInteractionEnabled:YES];
    }
    [LbltrustCount addGestureRecognizer:likeLblgesture];
    
    uppersep.backgroundColor =  [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];
    [trustCountView addSubview:LbltrustCount];
    
    UILabel *lowersep =[[UILabel alloc]initWithFrame:CGRectMake(0, trustCountView.frame.size.height-1, trustCountView.frame.size.width, 0.5)];
    lowersep.backgroundColor =  [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];
    [trustCountView addSubview:lowersep];
    
    //FeedView.frame = FeedRect;
    viewHeight = trustCountView.frame.size.height + trustCountView.frame.origin.y;
    FeedRect.size.height = viewHeight;
    FeedView.frame = FeedRect;
    
    CGRect ContentViewRect = conView.frame;
    ContentViewRect.size.height = FeedView.frame.origin.y + FeedView.frame.size.height;
    conView.frame = ContentViewRect;
    conView.userInteractionEnabled = YES;
    
    //[self LikeCountView];
    return conView;
}

-(void)viewSingleImage:(UIButton*)sender{
    [photoView fadeInPhotoViewFromImageView:singleImage];
}

#pragma mark - Tableview Delegates and DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.commentArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     if([[[self.commentArray objectAtIndex:section]valueForKey:@"total_comment_reply"]integerValue]>3){
        return [[[self.commentArray objectAtIndex:section]valueForKey:@"reply"]count] + 1;
    }else{
        return [[[self.commentArray objectAtIndex:section]valueForKey:@"reply"]count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SectionCell *replyCell  = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    
    if (replyCell == nil){
        replyCell  = [[SectionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SectionCell"];
    }
    if(indexPath.row < [[[self.commentArray objectAtIndex:indexPath.section]valueForKey:@"reply"]count])
    {
        NSMutableArray *replyArr = [self.commentArray objectAtIndex:indexPath.section][@"reply"];
        NSMutableDictionary *secDic = [replyArr objectAtIndex:indexPath.row];
        NSString *profileImgURL = [NSString stringWithFormat:@"%@",[secDic valueForKey:@"profile_pic_path"]];
        [replyCell.imgUser sd_setImageWithURL:[NSURL URLWithString:profileImgURL] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
        
        replyCell.imgUser.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
        replyCell.imgUser.layer.borderWidth = 0.5;
        replyCell.imgUser.contentMode = UIViewContentModeScaleAspectFill;
        replyCell.imgUser.layer.masksToBounds = YES;
        replyCell.lbl_userName.text = [[[[secDic valueForKey:@"name"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities] capitalizedString];
        replyCell.lbl_time.text = [NSString stringWithFormat:@"%@ \u2022 ",[self setUpdateTimewithDic:secDic]];
        NSString *content =[NSString stringWithFormat:@"%@",[secDic valueForKey:@"reply_comment"]];
        content = [content stringByDecodingHTMLEntities];
        content = [content stringByDecodingHTMLEntities];
        content = [content stringByReplacingOccurrencesOfString: @"<br>" withString: @" "];
        content = [content stringByReplacingOccurrencesOfString:@"<br/>" withString: @" "];
        content=  [content stringByReplacingOccurrencesOfString:@"<br />" withString: @" "];
        
        NSURL *url;
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                url = [match URL];
                //NSLog(@"found URL: %@", url);
                //content = [url absoluteString];
            }
        }
        if ([content.lowercaseString containsString:[NSString stringWithFormat:@"%@",url]]) {
            // NSLog(@"mesg: %@",content);
            content =  [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",url] withString:[NSString stringWithFormat:@"%@",url] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        }
        else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
            
            content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
            
        }else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
            content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        }
        replyCell.txt_userComment.backgroundColor = [UIColor clearColor];
        replyCell.txt_userComment.text = content;
        [replyCell.txt_userComment setTextContainerInset:UIEdgeInsetsZero];
        CGFloat fixedWidth = replyCell.txt_userComment.frame.size.width;
        CGSize newSize = [replyCell.txt_userComment sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = replyCell.txt_userComment.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        replyCell.txt_userComment.frame = newFrame;
        replyCell.txt_userComment.dataDetectorTypes = UIDataDetectorTypeLink;
        if([[secDic valueForKey:@"reply_like_status"]integerValue]==0){
            [replyCell.btnLike setTitle:@"Like" forState:UIControlStateNormal];
        }else{
            [replyCell.btnLike setTitle:@"Liked" forState:UIControlStateNormal];
        }
        [replyCell.btnLike addTarget:self action:@selector(likeRepliedComment:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        singleTap.delegate = self;
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [replyCell addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *TaponReplyerImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openReplyerProfile:)];
        TaponReplyerImage.delegate = self;
        TaponReplyerImage.numberOfTapsRequired = 1;
        TaponReplyerImage.numberOfTouchesRequired = 1;
        replyCell.imgUser.userInteractionEnabled = YES;
        [replyCell.imgUser addGestureRecognizer:TaponReplyerImage];
        return replyCell;
      }
    else{
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (moreCell == nil) {
            moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            UIButton *moreReply = [UIButton buttonWithType:UIButtonTypeCustom];
            moreReply.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 30.0);
            moreReply.tag = 999;
            [moreReply setTitle:@"View more replies" forState:UIControlStateNormal];
            [moreCell.contentView addSubview:moreReply];
            moreReply.userInteractionEnabled = YES;
            UITapGestureRecognizer *moreReplyTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewmoreReply:)];
            moreReplyTap.numberOfTapsRequired = 1;
            moreReplyTap.numberOfTouchesRequired = 1;
            [moreCell addGestureRecognizer:moreReplyTap];
            moreCell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [moreReply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            moreReply.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
            [moreReply addTarget:self action:@selector(seeMoreReply:)
                forControlEvents:UIControlEventTouchUpInside];
        }
        UIButton *moreReply = (UIButton*)[moreCell.contentView viewWithTag:999];
        [moreReply setTitle:@"View more replies" forState:UIControlStateNormal];
        return moreCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedSection = indexPath.section;
    selectedRow =indexPath.row;
    [self subcommentAlertSheetForRow];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [self sectionHeaderViewForSection:section];
    view.tag = section+1;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self sectionHeaderViewForSection:section].frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return UITableViewAutomaticDimension;
    if(indexPath.row < [[[self.commentArray objectAtIndex:indexPath.section]valueForKey:@"reply"]count])
    {
        return UITableViewAutomaticDimension;
    }else{
        // NSLog(@"View more cell height = 30");
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row < [[[self.commentArray objectAtIndex:indexPath.section]valueForKey:@"reply"]count])
    {
    return UITableViewAutomaticDimension;
    }
    else{
        // NSLog(@"View more cell height = 30");
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // Removes extra padding in Grouped style
    return CGFLOAT_MIN;
}

#pragma mark - Custom View for Header for Section
-(UIView *)sectionHeaderViewForSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    header.backgroundColor = [UIColor whiteColor];
    CGRect headerFrame;
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    NSMutableDictionary *secDic = [[self.commentArray objectAtIndex:section] mutableCopy];
    
    UIImageView *commenterImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    NSString *imgFileUrl = [secDic valueForKey:@"profile_pic_path"];
    [commenterImg sd_setImageWithURL:[NSURL URLWithString:imgFileUrl] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
    commenterImg.layer.cornerRadius = 4.0;
    commenterImg.contentMode = UIViewContentModeScaleAspectFill;
    commenterImg.layer.masksToBounds = YES;
    commenterImg.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    commenterImg.layer.borderWidth = 0.5;
    
    //Set open profile View
    UITapGestureRecognizer *taponUserPic = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
    [commenterImg setUserInteractionEnabled:YES];
    [commenterImg addGestureRecognizer:taponUserPic];
    
    UILabel *lblname = [[UILabel alloc]initWithFrame:CGRectMake(commenterImg.frame.origin.x + commenterImg.frame.size.width + 10, commenterImg.frame.origin.y, totalWidth,16)];
    NSString*name = [secDic valueForKey:@"name"];
    lblname.text = [[[name stringByDecodingHTMLEntities] stringByDecodingHTMLEntities] capitalizedString];
    lblname.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    
    //Set open profile View
    UITapGestureRecognizer *taponUserNameLbl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
    [lblname setUserInteractionEnabled:YES];
    [lblname addGestureRecognizer:taponUserNameLbl];
    
    UITextView * mainComment = [[UITextView alloc]init];
    mainComment.frame = CGRectMake(lblname.frame.origin.x, lblname.frame.origin.y + lblname.frame.size.height + 3, totalWidth -(lblname.frame.origin.x + 4), 1);
    mainComment.textContainer.lineFragmentPadding = 0;
    [mainComment setTextContainerInset:UIEdgeInsetsZero];
    mainComment.font = [UIFont systemFontOfSize:13.0];
    NSString *content =[NSString stringWithFormat:@"%@",[secDic valueForKey:@"comment"]];
    
    content = [content stringByDecodingHTMLEntities];
    content = [content stringByDecodingHTMLEntities];
    content = [content stringByReplacingOccurrencesOfString: @"<br>" withString: @" "];
    content = [content stringByReplacingOccurrencesOfString:@"<br/>" withString: @" "];
    content=  [content stringByReplacingOccurrencesOfString:@"<br />" withString: @" "];
    
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            //NSLog(@"found URL: %@", url);
            //content = [url absoluteString];
        }
    }
    if ([content.lowercaseString containsString:[NSString stringWithFormat:@"%@",url]]) {
        // NSLog(@"mesg: %@",content);
        content =  [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",url] withString:[NSString stringWithFormat:@"%@",url] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
        
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        
    }
    else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    mainComment.backgroundColor = [UIColor clearColor];
    mainComment.text = content;
    CGFloat fixedWidth = mainComment.frame.size.width;
    CGSize newSize = [mainComment sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = mainComment.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    mainComment.frame = newFrame;
    
    mainComment.scrollEnabled = NO;
    mainComment.editable = NO;
    mainComment.backgroundColor = [UIColor clearColor];
    mainComment.editable = NO;
    mainComment.scrollEnabled = NO;
    mainComment.dataDetectorTypes = UIDataDetectorTypeAll;
    
    UILabel *lblTime = [[UILabel alloc]initWithFrame:CGRectMake(lblname.frame.origin.x, mainComment.frame.size.height + mainComment.frame.origin.y + 4, totalWidth, 21)];
    lblTime.text = [NSString stringWithFormat:@"%@  \u2022",[self setUpdateTimewithDic:secDic]];
    lblTime.font = [UIFont systemFontOfSize:11.0];
    lblTime.textColor = [UIColor lightGrayColor];
    
    CGRect rect = lblTime.frame;
    rect.size = [lblTime.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    lblTime.frame = rect;
    
    UIButton *likecomment = [[UIButton alloc]initWithFrame:CGRectMake(lblTime.frame.origin.x + lblTime.frame.size.width, lblTime.frame.origin.y, 100, lblTime.frame.size.height)];
    [likecomment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    likecomment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    if([[secDic valueForKey:@"comment_like_status"]integerValue] == 0){
        [likecomment setTitle:[NSString stringWithFormat:@"  Like  \u2022  "] forState:UIControlStateNormal];
        [likecomment addTarget:self action:@selector(likeComment:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [likecomment setTitle:[NSString stringWithFormat:@"  Liked  \u2022  "] forState:UIControlStateNormal];
    }
    rect = likecomment.frame;
    rect.size = [likecomment.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    likecomment.frame = rect;
    
    UIImageView *imgLiked = [[UIImageView alloc]initWithFrame:CGRectMake(likecomment.frame.origin.x + likecomment.frame.size.width, lblTime.frame.origin.y, 13, 13)];
    imgLiked.image = [UIImage imageNamed:@"liked.png"];
    [header addSubview:imgLiked];
    UILabel *lblTotallikeCount = [[UILabel alloc]initWithFrame:CGRectMake(imgLiked.frame.origin.x + imgLiked.frame.size.width + 4, lblTime.frame.origin.y, 20, 21)];
    // lblTotallikeCount.text = [NSString stringWithFormat:@"%@  ",[self setUpdateTimewithDic:secDic]];
    lblTotallikeCount.font = [UIFont systemFontOfSize:11.0];
    lblTotallikeCount.textColor = [UIColor lightGrayColor];
    [header addSubview:lblTotallikeCount];
    UIButton *likeCount = [[UIButton alloc]init];
    if([[secDic valueForKey:@"total_comment_like"]integerValue] == 0){
        CGRect reFrame = imgLiked.frame;
        reFrame.size.width = 0;
        imgLiked.frame = reFrame;
        
        reFrame = lblTotallikeCount.frame;
        reFrame.size.width = 0 ;
        lblTotallikeCount.frame = reFrame;
    }
    else{
         NSString *totalCmtlike = [secDic valueForKey:@"total_comment_like"];
        lblTotallikeCount.text = [NSString stringWithFormat:@"%@  \u2022",totalCmtlike];
        [likeCount addTarget:self action:@selector(likeCommentCount:) forControlEvents:UIControlEventTouchUpInside];
        rect = lblTotallikeCount.frame;
        rect.size = [lblTotallikeCount.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
        lblTotallikeCount.frame = rect;
    }
    likeCount.frame = CGRectMake(imgLiked.frame.origin.x, imgLiked.frame.origin.y, imgLiked.frame.size.width + lblTotallikeCount.frame.size.width, imgLiked.frame.size.height);
    
    UIButton *replycomment = [[UIButton alloc]initWithFrame:CGRectMake(likeCount.frame.origin.x + likeCount.frame.size.width, likecomment.frame.origin.y, 70, likecomment.frame.size.height)];
    [replycomment setTitle:@"  Reply" forState:UIControlStateNormal];
    [replycomment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    replycomment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [replycomment addTarget:self action:@selector(replyComment:) forControlEvents:UIControlEventTouchUpInside];
    rect = replycomment.frame;
    rect.size = [replycomment.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    replycomment.frame = rect;
    
    UILabel *lblSep = [[UILabel alloc]initWithFrame:CGRectMake(0, replycomment.frame.size.height + replycomment.frame.origin.y + 9, totalWidth, 0.5)];
    lblSep.backgroundColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];

    if(![[secDic valueForKey:@"reply"]count]){
        [header addSubview:lblSep];
    }

    headerFrame.size.width = totalWidth;
    headerFrame.size.height = replycomment.frame.size.height + replycomment.frame.origin.y + 10;
    headerFrame.origin.x = 0;
    headerFrame.origin.y = 0;
    
    header.frame = headerFrame;
    [header addSubview:commenterImg];
    [header addSubview:lblname];
    [header addSubview:mainComment];
    [header addSubview:lblTime];
    [header addSubview:likecomment];
    [header addSubview:likeCount];
    [header addSubview:replycomment];
    
    UITapGestureRecognizer *tapOnSection = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sectionAlertSheet:)];
    [header setUserInteractionEnabled:YES];
    [header addGestureRecognizer:tapOnSection];
    return header;
}

#pragma mark - set time
-(NSString *)setUpdateTimewithDic:(NSDictionary *)timeInfo{
    NSString *date1;
    NSString *exactDatestr;
    if(timeInfo!=nil && [timeInfo isKindOfClass:[NSDictionary class]]){ //check if bite dictionary exist
        date1=[timeInfo objectForKey:@"date_of_creation"];
        long long int timestamp = [date1 longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        exactDatestr = [self updatedTimeLabelWithDate:dates];
        
    }
    return exactDatestr;
}

#pragma mark - Calculating Posting Time
-(NSString *)updatedTimeLabelWithDate:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    //LblTime.text= [df stringFromDate:date];
    // NSLog(@"relative date for %@ = %@",date,[self relativeDateStringForDate:date]);
    NSString *calculatedStr= [self relativeDateStringForDate:date];
    return calculatedStr;
}

-(void)updateTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    //LblTime.text= [df stringFromDate:date];
    // NSLog(@"relative date for %@ = %@",date,[self relativeDateStringForDate:date]);
    LblTime.text = [self relativeDateStringForDate:date];
}

-(NSString *)setCommentUpdateTimewithDic:(NSDictionary *)commentimeInfo{
    NSString *date1;
    NSString *exactDatestr;
    if(commentimeInfo!=nil && [commentimeInfo isKindOfClass:[NSDictionary class]]){ //check if bite dictionary exist
        date1=[commentimeInfo objectForKey:@"date_of_creation"];
        long long int timestamp = [date1 longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter  stringFromDate:dates];
         if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){ //if date exist then calculate it
            // change of date formatter
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-10-21 03:19:32
            NSInteger seconds = [dates timeIntervalSinceDate:currentTime];
            NSInteger days = (int) (floor(seconds / (3600 * 24)));
            if(days) seconds -= days * 3600 * 24;
            NSInteger hours = (int) (floor(seconds / 3600));
            if(hours) seconds -= hours * 3600;
            
            NSInteger minutes = (int) (floor(seconds / 60));
            if(minutes) seconds -= minutes * 60;
            if(days) {
                if (days==-1) {
                    exactDatestr = @"Yesterday";
                }
                else{
                    exactDatestr = [NSString stringWithFormat:@"%ld Days ago", (long)days*-1];
                }
            }
            else if(hours) {
                
                if (hours==-1) {
                    exactDatestr = @"1 hour ago";
                }
                else {
                    exactDatestr = [NSString stringWithFormat: @"%ld hours ago", (long)hours*-1];
                }
            }
            else if(minutes){
                if (minutes==-1) {
                    exactDatestr = @"1 minute ago";
                }
                else
                { exactDatestr = [NSString stringWithFormat: @"%ld minutes ago", (long)minutes*-1];
                }
            }
            else if(seconds)
                exactDatestr= [NSString stringWithFormat: @"%lds", (long)seconds*-1];
            else
                exactDatestr= [NSString stringWithFormat: @"Just now"];
            return exactDatestr;
        }
    }
    return exactDatestr;
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitWeekOfYear;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components1];
    
    components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *thatdate = [cal dateFromComponents:components1];
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:thatdate
                                                                     toDate:today
                                                                    options:0];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years", (long)components.year];
    } else if (components.month > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.weekOfYear > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.day > 0) {
        if (components.day > 1) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* component = [calender components:NSCalendarUnitWeekday fromDate:thatdate];
            return [self getDay:[component weekday]];
        }
        else
        {
            return @"Yesterday";
        }
    }
    else
    {
        return [self getTodayCurrTime:date];
    }
}

-(NSString*)getDay:(NSInteger)dayInt{
    NSMutableArray *day= [[NSMutableArray alloc]initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [day objectAtIndex:dayInt-1];
}

-(NSString *)getTodayCurrTime:(NSDate*)date{
    NSString *exactDatestr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter  stringFromDate:date];
    
    if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){ //if date exist then calculate it
        // change of date formatter
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-10-21 03:19:32
        NSInteger seconds = [date timeIntervalSinceDate:currentTime];
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        
        NSInteger minutes = (int) (floor(seconds / 60));
        if(minutes) seconds -= minutes * 60;
        if(hours) {
            if (hours==-1) {
                exactDatestr = @"1 hr";
            }
            else {
                exactDatestr = [NSString stringWithFormat: @"%ld hrs", (long)hours*-1];
            }
        }
        else if(minutes){
            if (minutes==-1) {
                exactDatestr = @"1 min";
            }
            else
            { exactDatestr = [NSString stringWithFormat: @"%ld mins", (long)minutes*-1];
            }
        }
        else if(seconds)
            exactDatestr= [NSString stringWithFormat: @"%ld sec", (long)seconds*-1];
        else
            exactDatestr= [NSString stringWithFormat: @"Just now"];
    }
    return exactDatestr;
}

-(NSString *)getOnlyDate:(NSDate*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    // [df setDateFormat:@"dd/MM/YY"];
    [df setDateFormat:@"MMM dd, yyyy"];
    return [df stringFromDate:date];
}


#pragma mark - Hide Keyboard
-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)forceDownKeyboard{
    if(isReplyComment && [commentTextView hasText]){
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Discard Reply" message:@"Are you sure you want to discard reply?" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self.view endEditing:YES];
            [self resetCommentTextView];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self.view endEditing:YES];
        (![commentTextView hasText])?[self resetCommentTextView]:nil;
    }
}

#pragma mark - MultiPhoto View
-(UIView*)makeCollageViewInParentView:(UIView*)parentView withNumberOfCollage:(NSInteger)value ImageUrls:(NSArray *)imgUrlsArr{
    CGRect parentViewRect = parentView.frame;
    CGFloat width = parentViewRect.size.width;
    CGFloat height = parentViewRect.size.height;
    UIView *collage = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width ,height)];
    imageView = [[UIImageView alloc]init];
    imageView2 = [[UIImageView alloc]init];
    imageView3 = [[UIImageView alloc]init];
    imageView4 = [[UIImageView alloc]init];
    imageView.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    imageView.layer.borderWidth = 0.7;
    imageView2.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    imageView2.layer.borderWidth = 0.7;
    imageView3.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    imageView3.layer.borderWidth = 0.7;
    imageView4.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    imageView4.layer.borderWidth = 0.7;
    imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    imageView.userInteractionEnabled = YES;
    imageView2.userInteractionEnabled = YES;
    imageView3.userInteractionEnabled = YES;
    imageView4.userInteractionEnabled = YES;
    [imageView addSubview:imgBtn];
    [imageView2 addSubview:imgBtn2];
    [imageView3 addSubview:imgBtn3];
    [imageView4 addSubview:imgBtn4];
    [imgBtn addTarget:self action:@selector(imgTapped:) forControlEvents:UIControlEventTouchUpInside];
    [imgBtn2 addTarget:self action:@selector(img2Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [imgBtn3 addTarget:self action:@selector(img3Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [imgBtn4 addTarget:self action:@selector(img4Tapped:) forControlEvents:UIControlEventTouchUpInside];
    UIView *exceedImgView = [[UIView alloc]init];
    UILabel *extraCount = [[UILabel alloc]init];
    switch (value)
    {
        case 1:
            imageView.frame = CGRectMake(0, 0, width, height);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:0]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            [collage addSubview: imageView];
            imgBtn.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            break;
            
        case 2:
            imageView.frame = CGRectMake(0, 0, (width/2)-2, height);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:0]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imgBtn.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            [collage addSubview: imageView];
            
            imageView2.frame = CGRectMake((width/2)+2 , 0, (width/2)-2, height);
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:1]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView2.contentMode = UIViewContentModeScaleAspectFill;
            imageView2.layer.masksToBounds = YES;
            imgBtn2.frame = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
            [collage addSubview: imageView2];
            break;
            
        case 3:
            imageView.frame = CGRectMake(0, 0, (width/2)-2, height);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:0]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imgBtn.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            [collage addSubview: imageView];
            
            imageView2.frame = CGRectMake((width/2)+2 , 0, (width/2)-2, (height/2)-2);
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:1]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView2.contentMode = UIViewContentModeScaleAspectFill;
            imageView2.layer.masksToBounds = YES;
            imgBtn2.frame = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
            [collage addSubview: imageView2];
            imageView3.frame = CGRectMake((width/2)+2 , (height/2)+2, (width/2)-2, (height/2)-2);
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:2]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView3.contentMode = UIViewContentModeScaleAspectFill;
            imageView3.layer.masksToBounds = YES;
            imgBtn3.frame = CGRectMake(0, 0, imageView3.frame.size.width, imageView3.frame.size.height);
            [collage addSubview: imageView3];
            break;
        case 4:
            imageView.frame = CGRectMake(0, 0, (width/2)-2, (height/2)-2);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:0]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imgBtn.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            [collage addSubview: imageView];
            
            imageView2.frame = CGRectMake((width/2)+2 , 0, (width/2)-2, (height/2)-2);
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:1]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView2.contentMode = UIViewContentModeScaleAspectFill;
            imageView2.layer.masksToBounds = YES;
            imgBtn2.frame = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
            [collage addSubview: imageView2];
            
            imageView3.frame = CGRectMake(0 , (height/2)+2, (width/2)-2, (height/2)-2);
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:2]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView3.contentMode = UIViewContentModeScaleAspectFill;
            imageView3.layer.masksToBounds = YES;
            imgBtn3.frame = CGRectMake(0, 0, imageView3.frame.size.width, imageView3.frame.size.height);
            [collage addSubview: imageView3];
            
            imageView4.frame = CGRectMake((width/2)+2 , (height/2)+2, (width/2)-2, (height/2)-2);
            [imageView4 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:3]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView4.contentMode = UIViewContentModeScaleAspectFill;
            imageView4.layer.masksToBounds = YES;
            imgBtn4.frame = CGRectMake(0, 0, imageView4.frame.size.width, imageView4.frame.size.height);
            [collage addSubview: imageView4];
            break;
            
        default:
            imageView.frame = CGRectMake(0, 0, (width/2)-2, (height/2)-2);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:0]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imgBtn.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            [collage addSubview: imageView];
            
            imageView2.frame = CGRectMake((width/2)+2 , 0, (width/2)-2, (height/2)-2);
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:1]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView2.contentMode = UIViewContentModeScaleAspectFill;
            imageView2.layer.masksToBounds = YES;
            imgBtn2.frame = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
            [collage addSubview: imageView2];
            
            imageView3.frame = CGRectMake(0 , (height/2)+2, (width/2)-2, (height/2)-2);
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:2]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView3.contentMode = UIViewContentModeScaleAspectFill;
            imageView3.layer.masksToBounds = YES;
            imgBtn3.frame = CGRectMake(0, 0, imageView3.frame.size.width, imageView3.frame.size.height);
            [collage addSubview: imageView3];
            
            imageView4.frame = CGRectMake((width/2)+2 , (height/2)+2, (width/2)-2, (height/2)-2);
            [imageView4 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[imgUrlsArr objectAtIndex:3]valueForKey:@"multiple_file_url"]]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            imageView4.contentMode = UIViewContentModeScaleAspectFill;
            imageView4.layer.masksToBounds = YES;
            imgBtn4.frame = CGRectMake(0, 0, imageView4.frame.size.width, imageView4.frame.size.height);
            [collage addSubview: imageView4];
            exceedImgView.frame = CGRectMake((width/2)+2 , (height/2)+2, (width/2)-2, (height/2)-2);
            extraCount.frame = CGRectMake(0, ((height/2)-30)/2, (width/2)-2, 30);
            extraCount.text = [NSString stringWithFormat:@"+%ld",(long)value-3];
            exceedImgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
            extraCount.textColor = [UIColor whiteColor];
            extraCount.textAlignment = NSTextAlignmentCenter;
            extraCount.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
            [exceedImgView addSubview: extraCount];
            [collage addSubview: exceedImgView];
            break;
    }
    return  collage;
}

#pragma mark - Actions
-(void)likeComment:(UIButton *)sender{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Like Comment Click"];
    // NSLog(@"%d",sender.superview.tag);
    selectedSection = sender.superview.tag-1;
    //NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    [self setFeedCommentLikeRequest:[[self.commentArray objectAtIndex:selectedSection] mutableCopy]];
}

-(void)likeRepliedComment:(UIButton *)sender{
     [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Like Reply Click"];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    //    NSLog(@"%d",indexPath.row);
    //    NSLog(@"%d",indexPath.section);
    
    // NSLog(@"%d",sender.superview.tag);
    selectedSection = indexPath.section;
    selectedRow = indexPath.row;
    //   NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    NSMutableArray *replyarr = [[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"reply"] mutableCopy];
    [self setFeedCommentReplyLikeRequest:[[replyarr objectAtIndex:indexPath.row]mutableCopy]];
}

-(void)replyComment:(UIButton *)sender{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Reply Comment Click"];
    isReplyComment = YES;
    selectedSection = sender.superview.tag-1;
    // NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    [self openkeyboard];
    BOOL isSelfCommenter = NO;
    if([[[NSUserDefaults standardUserDefaults]valueForKey:userId]isEqualToString:[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"commented_by"]]){
        isSelfCommenter = YES;
    }
    NSString *commenterName = [self.commentArray objectAtIndex:selectedSection][@"name"];
    commenterName = isSelfCommenter?@"your comment":commenterName;
    placeholder.text = [NSString stringWithFormat:@"Replying to %@",[commenterName stringByDecodingHTMLEntities]];
}

-(void)likeCommentCount:(UIButton*)sender{
    selectedSection = sender.superview.tag-1;
    // NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    [Localytics tagEvent:@"WhatsTrending CommentScreen ViewCommentLikeList Click"];
    [[AppDelegate appDelegate] getPlaySound];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSString *xib = nil;
    if (IS_IPHONE_6) {
        xib = @"FeedLikeListVC-i6";
    }
    else if (IS_IPHONE_6_PLUS){
        xib = @"FeedLikeListVC-i6Plus";
    }
    else {
        xib = IS_IPHONE_5?@"FeedLikeListVC-i5":@"FeedLikeListVC";
    }
    FeedLikeListVC*feedlikevw = [[FeedLikeListVC alloc]initWithNibName:xib bundle:nil];
    feedlikevw.dataFor = @"comment";
    feedlikevw.feedCommentID = [self.commentArray objectAtIndex:selectedSection][@"comment_id"];
    feedlikevw.feedLikeIdStr = self.feedid;
    [self.navigationController pushViewController:feedlikevw animated:YES];
}

- (void)copyString {
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Copy Comment Click"];
    [Localytics tagEvent:@"WhatsTrending CommentScreen Copy Click"];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString: [selectedComment stringByDecodingHTMLEntities]];
}

-(void)editComment{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Edit Comment Click"];
    [Localytics tagEvent:@"WhatsTrending CommentScreen Edit Click"];
    [self.view endEditing:YES];
    selectedComment = [self.commentArray objectAtIndex:selectedSection][@"comment"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    editCommentVC *editCom = [storyboard instantiateViewControllerWithIdentifier:@"editCommentVC"];
    editCom.delegate = self;
    editCom.commentText = [selectedComment stringByDecodingHTMLEntities];
    editCom.FeedID = self.feedid;
    editCom.Action = @"Comment";
    editCom.commentID = [self.commentArray objectAtIndex:selectedSection][@"comment_id"];
    [self presentViewController:editCom animated:YES completion:nil];
}

-(void)editComment:(NSString*)comment feedComID:(NSString*)comID{
    NSMutableDictionary *comDic = [[self.commentArray objectAtIndex:selectedSection] mutableCopy];
    //    NSMutableArray *replyArr = [comDic valueForKey:@"reply"];
    [comDic setValue:comment forKey:@"comment"];
    
    [self.commentArray removeObjectAtIndex:selectedSection];
    [self.commentArray insertObject:comDic atIndex:selectedSection];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) deleteComment
{
     [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Delete Comment Click"];
    // NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *commentID =[self.commentArray objectAtIndex:selectedSection][@"comment_id"];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        [[DocquityServerEngine sharedInstance]feedcommentActionRequestWithAuthkey:[userDef valueForKey:userAuthKey] feed_id:self.feedid comment_id:commentID userid:[userDef valueForKey:userId] action:@"delete" app_version:[userDef valueForKey:kAppVersion] format:@"josn" userType:@"user" callback:^(NSDictionary *responceObject, NSError *error)
         {
             if(error){
                 [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
             }
             else{
                 NSMutableDictionary *responsePost =[[responceObject objectForKey:@"posts"] mutableCopy];
                 if ([responsePost isKindOfClass:[NSNull class]] || responsePost == nil)
                 {
                     // Response is null
                 }
                 else {
                     // NSLog(@"response from comment = %@",responsePost);
                     
                     if([[responsePost valueForKey:@"status"]integerValue] == 1)
                     {
                         long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                         updateTime = [NSString stringWithFormat:@"%lld",myInt];
                         [self.commentArray removeObjectAtIndex:selectedSection];
                         [self.tableView reloadData];
                         totalComment--;
                     }
                     else if([[responsePost valueForKey:@"status"]integerValue] == 9)
                     {
                         [[AppDelegate appDelegate] logOut];
                     }
                     else  if([[responsePost valueForKey:@"status"]integerValue] == 11)
                     {
                         NSString*userValidateCheck = @"readonly";
                         NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                         [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                         [userpref synchronize];
                         NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                         if ([u_permissionstus isEqualToString:@"readonly"]) {
                             [self getcheckedUserPermissionData];
                         }
                     }
                     else
                     {
                         [UIAppDelegate alerMassegeWithError:[responsePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
                     }
                 }
             }
         }];
    }
}

-(void)editCommentReply{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Edit Comment Click"];
    [Localytics tagEvent:@"WhatsTrending CommentScreen Edit Click"];
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    editCommentVC *editCom = [storyboard instantiateViewControllerWithIdentifier:@"editCommentVC"];
    editCom.delegate = self;
    editCom.commentText =  [selectedComment stringByDecodingHTMLEntities];
    editCom.FeedID = self.feedid;
    editCom.Action = @"Reply";
    editCom.commentID = [self.commentArray objectAtIndex:selectedSection][@"comment_id"];
    editCom.commentReplyID = [[self.commentArray objectAtIndex:selectedSection][@"reply"]objectAtIndex:selectedRow][@"comment_reply_id"];
    [self presentViewController:editCom animated:YES completion:nil];
}

-(void)editCommentReplyText:(NSString*)comment{
    //NSLog(@"Edited text = %@",comment);
    NSMutableDictionary *comDic = [[self.commentArray objectAtIndex:selectedSection] mutableCopy];
    NSMutableArray *replyArr = [[comDic valueForKey:@"reply"] mutableCopy];
    NSMutableDictionary *repDic = [[replyArr objectAtIndex:selectedRow] mutableCopy];
    [repDic setValue:comment forKey:@"reply_comment"];
    
    [replyArr removeObjectAtIndex:selectedRow];
    [replyArr insertObject:repDic atIndex:selectedRow];
    
    [comDic setObject:replyArr forKey:@"reply"];
    [self.commentArray removeObjectAtIndex:selectedSection];
    [self.commentArray insertObject:comDic atIndex:selectedSection];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)openkeyboard{
    [commentTextView becomeFirstResponder];
}

#pragma mark - Webservices Request
-(void)getFeedCommentRequest{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *str = [NSString stringWithFormat:@"%ld",(long)offset];
    [[DocquityServerEngine sharedInstance]feedlistcommentRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid device_type:kDeviceType app_version:kAppVersion lang:kLanguage offset:str limit:limit callback:^(NSDictionary *responceObject, NSError *error) {
       // NSLog(@"STR = %@",str);
        if(error){
            if([str isEqualToString:@"1"]){
                __weak NewCommentVC *weakSelf = self;
                [self.tableView addPullToRefreshWithActionHandler:^{
                    [Localytics tagEvent:@"Timeline Comment PullDown"];
                    //Call Feeds here
                    [weakSelf getFeedCommentRequest];
                }position:SVPullToRefreshPositionBottom];
            }
            [self.tableView.pullToRefreshView stopAnimating];
        }
        else {
            NSMutableDictionary *resposePost =[[responceObject objectForKey:@"posts"] mutableCopy];
            if ([resposePost isKindOfClass:[NSNull class]] || resposePost == nil)
            {
                // Response is null
            }
            else {
                // NSLog(@"response from comment = %@",resposePost);
                if([[resposePost valueForKey:@"status"]integerValue] == 1)
                {
                    NSMutableDictionary *dataDic = [[resposePost valueForKey:@"data"] mutableCopy];
                    NSMutableArray *tempArr = [[dataDic valueForKey:@"comment"] mutableCopy];
                    [str isEqualToString:@"1"]?[self.commentArray removeAllObjects]:nil;
                      for(NSMutableDictionary *comdic  in tempArr){
                        [self.commentArray addObject:comdic];
                    }
                    totalComment = self.commentArray.count;
                    self.tableView.tableFooterView = nil;
                    [self.tableView reloadData];
                    if([str isEqualToString:@"1"]){
                        __weak NewCommentVC *weakSelf = self;
                        [self.tableView addPullToRefreshWithActionHandler:^{
                            [Localytics tagEvent:@"Timeline comment PullDown"];
                            //Call Feeds here
                            [weakSelf getFeedCommentRequest];
                        }position:SVPullToRefreshPositionBottom];
                    }
                     isCheckviaRefreshComments = YES;
                    offset ++ ;
                    [self.tableView.pullToRefreshView stopAnimating];
                    if(tempArr.count<10){
                    [self.tableView setShowsPullToRefresh:NO];
                    }
                } else if([[resposePost valueForKey:@"status"]integerValue] == 7)
                {
                    //NSLog(@"Thanks it for now");
                    [self.tableView setShowsPullToRefresh:NO];
                    self.tableView.tableFooterView = nil;
                }
                else if([[resposePost valueForKey:@"status"]integerValue] == 9)
                {
                    [[AppDelegate appDelegate]logOut];
                }else if([[resposePost valueForKey:@"status"]integerValue] == 0)
                {
                    [UIAppDelegate alerMassegeWithError:[resposePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
                }
                else
                {
                    [self defaultAlertShow];
                }
            }
        }
    }];
}

-(void)setFeedCommentLikeRequest:(NSMutableDictionary*)likeDic{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    // NSLog(@"SelectedFeed in api = %@",[self.commentArray objectAtIndex:selectedSection]);
    [[DocquityServerEngine sharedInstance]feedcommentlikeRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid comment_id:[likeDic valueForKey:@"comment_id"] device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]])
        {
            // Response is null
        }
        else {
            [[AppDelegate appDelegate]hideIndicator];
            // NSLog(@"response from like comment = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                [likeDic setValue:@"1" forKey:@"comment_like_status"];
                NSInteger totallikeComment = [[likeDic valueForKey:@"total_comment_like"]integerValue];
                totallikeComment++;
                [likeDic setValue:[NSString stringWithFormat:@"%ld",(long)totallikeComment] forKey:@"total_comment_like"];

                long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                updateTime = [NSString stringWithFormat:@"%lld",myInt];
                [self.commentArray removeObjectAtIndex:selectedSection];
                [self.commentArray insertObject:likeDic atIndex:selectedSection];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
            [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

-(void)setFeedCommentReplyLikeRequest:(NSMutableDictionary*)replylikeDic{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    // NSLog(@"replylikeDic in api = %@",replylikeDic);
    [[DocquityServerEngine sharedInstance]feedcommentreplylikeRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:[replylikeDic valueForKey:@"feed_id"] comment_id:[replylikeDic valueForKey:@"comment_id"] comment_reply_id:[replylikeDic valueForKey:@"comment_reply_id"] device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || resposePost == nil)
        {
            // Response is null
        }
        else {
            // NSLog(@"response from like comment = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                [replylikeDic setValue:@"1" forKey:@"reply_like_status"];
                NSInteger totalReplikeComment = [[replylikeDic valueForKey:@"total_reply_like"]integerValue];
                totalReplikeComment++;
                [replylikeDic setValue:[NSString stringWithFormat:@"%ld",(long)totalReplikeComment] forKey:@"total_reply_like"];
                
                NSMutableArray *replyarr = [[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"reply"] mutableCopy];
                
                [replyarr removeObjectAtIndex:selectedRow];
                [replyarr insertObject:replylikeDic atIndex:selectedRow];
                
                NSMutableDictionary *commentDic = [[NSMutableDictionary alloc]init];
                commentDic = [[self.commentArray objectAtIndex:selectedSection] mutableCopy];
                [commentDic setObject:replyarr forKey:@"reply"];
                
                [self.commentArray removeObjectAtIndex:selectedSection];
                [self.commentArray insertObject:commentDic atIndex:selectedSection];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
                long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                updateTime = [NSString stringWithFormat:@"%lld",myInt];
            }
        }
    }];
}

#pragma mark - setCommentReplyAction
-(void)setCommentReplyAction:(NSString *)action replyID:(NSString*)comRepID{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    // NSLog(@"SelectedFeed in api = %@",[self.commentArray objectAtIndex:selectedSection]);
    NSMutableDictionary *replyDic = [[self.commentArray objectAtIndex:selectedSection] mutableCopy];
    NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[DocquityServerEngine sharedInstance]feedactioncommentreplyRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid comment_id:[replyDic valueForKey:@"comment_id"] comment_reply_id:comRepID action:action reply:result device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
            [[AppDelegate appDelegate]hideIndicator];
            //NSLog(@"response from comment reply = %@",resposePost);
        }
        else {
            //NSLog(@"response from comment reply = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 0){
                [[AppDelegate appDelegate]hideIndicator];
                [UIAppDelegate alerMassegeWithError:[resposePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate]hideIndicator];
                [[AppDelegate appDelegate]logOut];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 11){
                [[AppDelegate appDelegate]hideIndicator];
                [UIAppDelegate alerMassegeWithError:[resposePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                [[AppDelegate appDelegate]hideIndicator];
                if([action  isEqualToString:@"add"])
                {
                    isReplyComment = NO;
                    [self resetCommentTextView];
                    [self resetConstraintsForToolbar];
                    NSMutableArray *repArr = [[NSMutableArray alloc]init];
                    repArr = [[replyDic valueForKey:@"reply"]mutableCopy];
                    NSString *replyid = [resposePost valueForKey:@"data"][@"comment_reply_id"];
                    NSString *comID = [replyDic valueForKey:@"comment_id"];
                    long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                    NSString * timestamp = [NSString stringWithFormat:@"%lld",myInt];
                    updateTime = timestamp;
                    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
                    
                    NSMutableDictionary *commentReplyInfo = [[NSMutableDictionary alloc]init];
                    lastComment = [lastComment stringByDecodingHTMLEntities];
                    [commentReplyInfo setValue:lastComment forKey:@"reply_comment"];
                    [commentReplyInfo setValue:replyid forKey:@"comment_reply_id"];
                    [commentReplyInfo setValue:[userdef objectForKey:jabberId] forKey:@"comment_replyer_jabber_id"];
                    [commentReplyInfo setValue:[NSString stringWithFormat:@"%@",[userdef objectForKey:profileImage]] forKey:@"profile_pic_path"];
                    [commentReplyInfo setValue:[[NSString stringWithFormat:@"%@ %@",[userdef objectForKey:dc_firstName],[userdef objectForKey:dc_lastName]]stringByDecodingHTMLEntities] forKey:@"name"];
                    [commentReplyInfo setValue: timestamp forKey:@"date_of_creation"];
                    [commentReplyInfo setValue:[userdef objectForKey:ownerCustId] forKey:@"custom_id"];
                    [commentReplyInfo setValue:comID forKey:@"comment_id"];
                    [commentReplyInfo setValue:[feedDict valueForKey:@"feed_id"] forKey:@"feed_id"];
                    [commentReplyInfo setValue:[userdef valueForKey:userId] forKey:@"commented_by"];
                    [repArr insertObject:commentReplyInfo atIndex:0];
                    [replyDic setObject:repArr forKey:@"reply"];
                    [self.commentArray removeObjectAtIndex:selectedSection];
                    [self.commentArray insertObject:replyDic atIndex:selectedSection];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                  }
                else if ([action isEqualToString:@"delete"]){
                    NSMutableArray *repArr = [[NSMutableArray alloc]init];
                    repArr = [[replyDic valueForKey:@"reply"]mutableCopy];
                    [repArr removeObjectAtIndex:selectedRow];
                    [replyDic setObject:repArr forKey:@"reply"];
                    [self.commentArray removeObjectAtIndex:selectedSection];
                    [self.commentArray insertObject:replyDic atIndex:selectedSection];
                    long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                    updateTime = [NSString stringWithFormat:@"%lld",myInt];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }];
}

#pragma webservices methods
- (void) serviceCallingLike:(UIButton*)sender
{
    [[AppDelegate appDelegate] getPlaySound];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if([sender.titleLabel.text isEqualToString:@"Trusted"]){
            return;
        }
        else
        {
            NSString* tFeedLike = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"total_like"]?[feedDict objectForKey:@"total_like"]:@""];
            NSInteger trustCount = tFeedLike.integerValue+1;
            tFeedLike = [NSString stringWithFormat:@"%ld",(long)trustCount];
            [sender setTitleColor: [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1] forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"trust"] forState:UIControlStateNormal];
            [sender setTitle:@"Liked" forState:UIControlStateNormal];
            if([tFeedLike integerValue]>1)
            {
                LbltrustCount.text = [[@"You and " stringByAppendingString:t_likeStr]stringByAppendingString:@" Doctor like this."];
                NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
                NSString *boldString = @"like this.";
                NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
                [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
                [LbltrustCount setAttributedText: yourAttributedString];
            }
            if([tFeedLike integerValue] > 2)
            {
                LbltrustCount.text = [[@"You and " stringByAppendingString:t_likeStr]stringByAppendingString:@" Doctors like this."];
                NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
                NSString *boldString = @"like this.";
                NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
                [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
                [LbltrustCount setAttributedText: yourAttributedString];
            }
            if([tFeedLike integerValue] == 1)
            {
                LbltrustCount.text = @"You like this.";
                LbltrustCount.userInteractionEnabled =YES;
                NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:LbltrustCount.text];
                NSString *boldString = @"like this.";
                NSRange boldRange = [LbltrustCount.text rangeOfString:boldString];
                [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:boldRange];
                [LbltrustCount setAttributedText: yourAttributedString];
            }
            NSString* feedId= [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"feed_id"]?[feedDict objectForKey:@"feed_id"]:@""];
              [self setFeedLikeRequest:feedId];
        }
    }
}

#pragma mark - setCommentdata
-(void)setCommentdata{
    isCommentpost = YES;
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString* feedId= [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"feed_id"]?[feedDict objectForKey:@"feed_id"]:@""];
    NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString*encodedcommentString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (CFStringRef)result,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8 ));
 
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=post_comment"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"user_auth_key=%@&feed_id=%@&comments=%@&device_type=%@&app_version=%@&lang=%@",[userpref valueForKey:userAuthKey],feedId,encodedcommentString,kDeviceType,[userpref valueForKey:kAppVersion],kLanguage];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    __block NSError *e;
    NSURLSession *session = [NSURLSession sharedSession];
    [[AppDelegate appDelegate] showIndicator];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    // Code to run when the response completes...
                    if (!error) {
                        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
                        // NSLog(@"Async On_Start_Notification Response json data= %@",json);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // NSLog(@"responseObject sesson= %@",json);
                            [self performSelector:@selector(feedCommentResponse:) withObject:json afterDelay:.000];
                            //if([[[json valueForKey:@"posts"]valueForKey:@"status"]integerValue]==1)
                        });
                    } else {
                        // update the UI to indicate error
                        
                        // NSLog(@"error %@",e);
                        [[AppDelegate appDelegate] hideIndicator];
                    }
                }] resume];
}

- (void) feedCommentResponse:(NSMutableDictionary *)response
{
   // NSLog(@"ksetfeedcomment result");
    [[AppDelegate appDelegate] hideIndicator];
    NSMutableDictionary *resposeCode=[[response objectForKey:@"posts"] mutableCopy];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil)
    {
        // tel is null
    }
    else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                NSDictionary *dataDic=[resposeCode objectForKey:@"data"];
                if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                {
                    // tel is null
                }
            else {
        NSString *comID=[NSString stringWithFormat:@"%@", [dataDic objectForKey:@"comment_id"]?[dataDic  objectForKey:@"comment_id"]:@""];
       // NSString *total_comment=[NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"total_comment"]?[resposeCode  objectForKey:@"total_comment"]:@""];
            if (self.commentArray == nil)
            {
                self.commentArray = [[NSMutableArray alloc]init];
                [self.commentArray removeAllObjects];
            }
            [self resetCommentTextView];
            [self resetConstraintsForToolbar];
            
            long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
            NSString * timestamp = [NSString stringWithFormat:@"%lld",myInt];
            updateTime = [NSString stringWithFormat:@"%lld",myInt];
    
            NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *commentInfo = [[NSMutableDictionary alloc]init];
            lastComment = [lastComment stringByDecodingHTMLEntities];
            [commentInfo setValue:lastComment forKey:@"comment"];
            [commentInfo setValue:[userdef objectForKey:jabberId] forKey:@"commenter_jabber_id"];
            [commentInfo setValue:[NSString stringWithFormat:@"%@",[userdef objectForKey:profileImage]] forKey:@"profile_pic_path"];
            [commentInfo setValue:[[NSString stringWithFormat:@"%@ %@",[userdef objectForKey:dc_firstName],[userdef objectForKey:dc_lastName]]stringByDecodingHTMLEntities] forKey:@"name"];
            [commentInfo setValue: timestamp forKey:@"date_of_creation"];
            [commentInfo setValue:[userdef objectForKey:ownerCustId] forKey:@"custom_id"];
            [commentInfo setValue:comID forKey:@"comment_id"];
            [commentInfo setValue:[feedDict valueForKey:@"feed_id"] forKey:@"feed_id"];
            [commentInfo setValue:[userdef valueForKey:userId] forKey:@"commented_by"];
            NSMutableArray *replyArr = [[NSMutableArray alloc]init];
            [commentInfo setObject:replyArr forKey:@"reply"];
            [self.commentArray insertObject:commentInfo atIndex:0];
            [self.tableView reloadData];
            totalComment++;
       }
    }
       else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
    }
}

#pragma mark - open CME Actions
- (void)openCMEView:(UITapGestureRecognizer*)gesture
{
    [[AppDelegate appDelegate] navigateToTabBarScren:1];
}

#pragma mark - Gesture Actions
- (void)openProfileView:(UITapGestureRecognizer*)gesture
{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"View User Profile Click"];
    // NSLog(@"tapped section again = %d",gesture.view.superview.tag);
    selectedSection = gesture.view.superview.tag - 1;
    NSString*custom_uId = [self.commentArray objectAtIndex:selectedSection][@"custom_id"];
   // NSString*feedjabId = [self.commentArray objectAtIndex:selectedSection][@"commenter_jabber_id"];
    
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    //  NewProfile.userJabberId = feedjabId;
    NewProfile .custid=  custom_uId;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

- (void)openFeederProfileView:(UITapGestureRecognizer*)gesture
{
    // NSLog(@"tapped section again = %d",gesture.view.superview.tag);
    selectedSection = gesture.view.superview.tag - 1;
    
    NSString*custom_uId =  [self.feedDict valueForKey:@"custom_id"];
   // NSString*feedjabId =  [self.feedDict valueForKey:@"feeder_jabber_id"];
    
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    //  NewProfile.userJabberId = feedjabId;
    NewProfile .custid=  custom_uId;
    NewProfile.commentFeedid = [self.feedDict valueForKey:@"feed_id"];
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

- (void)openReplyerProfile:(UITapGestureRecognizer*)gesture
{
    //  NSLog(@"gesture.view.superview section = %d , Row = %d",gesture.view.superview.tag, )
    SectionCell *replyCell = (SectionCell*)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:replyCell];
    //NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPath.row,(long)indexPath.section);
    selectedRow = indexPath.row;
    selectedSection = indexPath.section;
    NSString*custom_uId =  [[self.commentArray objectAtIndex:selectedSection][@"reply"]objectAtIndex:selectedRow][@"custom_id"];
  //  NSString*feedjabId =  [[self.commentArray objectAtIndex:selectedSection][@"reply"]objectAtIndex:selectedRow][@"comment_replyer_jabber_id"];
    
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    //  NewProfile.userJabberId = feedjabId;
    NewProfile .custid=  custom_uId;
    NewProfile.commentFeedid = [self.feedDict valueForKey:@"feed_id"];
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

- (void)openDocument:(UITapGestureRecognizer*)gesture{
    [Localytics tagEvent:@"WhatsTrending CommentScreen DocumentOpen Click"];
    NSString* documentfeedTitle = [NSString stringWithFormat:@"%@",[feedDict objectForKey:@"file_name"]?[feedDict objectForKey:@"file_name"]:@""];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = documentfeedUrlLink;
    webvw.documentTitle = documentfeedTitle;
    [self presentViewController:webvw
                       animated:YES
                     completion:nil];
}

-(void)openMetadataUrlLink:(UIButton*)sender
{
    [Localytics tagEvent:@"WhatsTrending CommentScreen  Meta Click"];
    if (feedmetaUrlLink && (feedmetaUrlLink.length != 0)) {
        NSRange rng = [feedmetaUrlLink rangeOfString:@"http://"options:NSCaseInsensitiveSearch];
        NSRange rng1 = [feedmetaUrlLink rangeOfString:@"https://"options:NSCaseInsensitiveSearch];
        if (rng.location == NSNotFound && rng1.location == NSNotFound) {
            feedmetaUrlLink = [NSString stringWithFormat:@"http://%@" ,feedmetaUrlLink];
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = feedmetaUrlLink;
    [self presentViewController:webvw
                       animated:YES
                     completion:nil];
}

- (void)openVideo:(UITapGestureRecognizer*)gesture{
    [Localytics tagEvent:@"WhatsTrending CommentScreen VideoPlay Click"];
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

-(void)openfeedLikeList:(UITapGestureRecognizer*)gesture{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Click on Like List"];
    [Localytics tagEvent:@"WhatsTrending CommentScreen ViewLikeList Click"];
    [[AppDelegate appDelegate] getPlaySound];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSString *xib = nil;
    if (IS_IPHONE_6) {
        xib = @"FeedLikeListVC-i6";
    }
    else if (IS_IPHONE_6_PLUS){
        xib = @"FeedLikeListVC-i6Plus";
    }
    else {
        xib = IS_IPHONE_5?@"FeedLikeListVC-i5":@"FeedLikeListVC";
    }
    FeedLikeListVC*feedlikevw = [[FeedLikeListVC alloc]initWithNibName:xib bundle:nil];
    feedlikevw.dataFor = @"feed";
    feedlikevw.feedLikeIdStr = self.feedid;
    [self.navigationController pushViewController:feedlikevw animated:YES];
}

#pragma mark - section tapped
-(void)sectionAlertSheet:(UITapGestureRecognizer*)gesture{
    selectedSection = gesture.view.tag - 1;
    if (keyboardIsVisible){
        
        [self hideKeyboard];
    }else{
        BOOL isSelfCommenter = NO;
        selectedComment = [[self.commentArray objectAtIndex:selectedSection]valueForKey:@"comment"];
        if([[[NSUserDefaults standardUserDefaults]valueForKey:userId]isEqualToString:[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"commented_by"]]){
            isSelfCommenter = YES;
        }
        // NSLog(@"selectedSection Gesture %@",[self.commentArray objectAtIndex:selectedSection]);
        
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Reply" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            isReplyComment = YES;
            // NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
            [self openkeyboard];
            NSString *commenterName = [[self.commentArray objectAtIndex:selectedSection][@"name"]stringByDecodingHTMLEntities];
            commenterName = isSelfCommenter?@"your comment":commenterName;
            placeholder.text = [NSString stringWithFormat:@"Replying to %@",[commenterName stringByDecodingHTMLEntities]];
        }]];
        if(isSelfCommenter){
            [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self editComment];
            }]];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self copyString];
        }]];
        if(isSelfCommenter){
            [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                
                UIAlertController * confirmAlert= [UIAlertController alertControllerWithTitle:@"Delele comment" message:@"Are you sure you want to delete comment?" preferredStyle:UIAlertControllerStyleAlert];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self deleteComment];
                }]];
                [self presentViewController:confirmAlert animated:YES completion:nil];
                
            }]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)subcommentAlertSheetForRow{
    if (keyboardIsVisible){
        [self hideKeyboard];
    }else{
        BOOL isSelfReplyer = NO;
        selectedComment = [[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"reply"]objectAtIndex:selectedRow][@"reply_comment"];
        
        if([[[NSUserDefaults standardUserDefaults]valueForKey:userId]isEqualToString:[[[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"reply"]objectAtIndex:selectedRow] valueForKey:@"commented_by"]]){
            isSelfReplyer = YES;
        }
        //  NSLog(@"selected section cell Gesture %@",[self.commentArray objectAtIndex:selectedSection]);
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        if(isSelfReplyer){
            [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self editCommentReply];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self copyString];
        }]];
        if(isSelfReplyer){
            [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                
                UIAlertController * confirmAlert= [UIAlertController alertControllerWithTitle:@"Delele reply" message:@"Are you sure you want to delete reply?" preferredStyle:UIAlertControllerStyleAlert];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self setCommentReplyAction:@"delete" replyID:[[[self.commentArray objectAtIndex:selectedSection]valueForKey:@"reply"]objectAtIndex:selectedRow][@"comment_reply_id"]];
                }]];
                [self presentViewController:confirmAlert animated:YES completion:nil];
                
            }]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)shareBtnClicked:(UIButton*)sender{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Feed Share Click"];
    [Localytics tagEvent:@"WhatsTrending CommentScreen Share Click"];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        //[self ShowNoInternetView:YES];
        return;
    }
    else
    {
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
        if ([u_permissionstus isEqualToString:@"readonly"]) {
            isClickFromShare =YES;
            [self getcheckedUserPermissionData];
            // [AppDelegate appDelegate].ischeckedReadOnlyPermissionStus  =YES;
            // [[AppDelegate appDelegate] ischeckedreadOnly];
        }
        else{
            [self generateWhatsappActivity];
        }
    }
}

-(void)cellTapped:(UITapGestureRecognizer*)gesture{
    
    SectionCell *replyCell = (SectionCell*)gesture.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:replyCell];
    // NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPath.row,(long)indexPath.section);
    selectedRow = indexPath.row;
    selectedSection = indexPath.section;
    [self subcommentAlertSheetForRow];
}
-(void)seeMoreReply:(UIButton*)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPaths = [self.tableView indexPathForRowAtPoint:buttonPosition];
    selectedSection = indexPaths.section;
    //    NSLog(@"%d",indexPaths.row);
    //    NSLog(@"%d",indexPaths.section);
    [self pushToRepliesVCWithDic:[self.commentArray objectAtIndex:indexPaths.section]];
    
    // NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPaths.row,(long)indexPaths.section);
    
}
-(void)viewmoreReply:(UITapGestureRecognizer*)gesture{
    UITableViewCell *moreCell = (UITableViewCell*)gesture.view.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:moreCell];
 //   NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPath.row,(long)indexPath.section);
}

#pragma mark - Keybaord Action
- (void)subscribeToKeyboard {
     [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            //  UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.size.height, 0.0);
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
            [self animateTextView:YES withKBHeight:keyboardRect.size.height];
            keyboardIsVisible = YES;
        } else {
            CGRect inputviewFrame = self.toolbar.frame;
            //  inputviewFrame.origin.y = [UIScreen mainScreen].bounds.size.height - inputviewFrame.size.height;
            
            //  self.toolbar.frame = inputviewFrame;
            self.BottomConstraintsToolbar.constant = 0;
            [UIView commitAnimations];
            //  UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
            //            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, inputviewFrame.size.height - 44, 0.0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
            keyboardIsVisible = NO;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void) animateTextView:(BOOL)up withKBHeight:(float)kbheight
{
    const int movementDistance = kbheight; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    //   NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.BottomConstraintsToolbar.constant = kbheight;
    [UIView commitAnimations];
}

#pragma mark - Reset constraints
-(void)resetConstraintsForToolbar{
    self.BottomConstraintsToolbar.constant = 0;
    self.toolBarHeightConstraints.constant = 44;
    CGRect textviewrect = commentTextView.frame;
    textviewrect.size.height = 32;
    commentTextView.frame = textviewrect;
    [self.view endEditing:YES];
}

- (SSCWhatsAppActivity *)generateWhatsappActivity
{
    [[AppDelegate appDelegate] getPlaySound];
    MailActivity *mailActivity = [self generateMailActiviy];
    NSString*shareTitle = LblTitle.text;
    NSString* urlreflink;
    NSString*reflink;
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
//    if ([reflink rangeOfString:@"="].location != NSNotFound)
//    {
//        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, reflink.length)];
//        urlreflink  = [reflink substringFromIndex:range.location+1];
//    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedsshareUrl,reflink];
    
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
    //[self presentViewController:activityViewController animated:YES completion:nil];
    return whatsAppActivity;
}

- (MailActivity *) generateMailActiviy
{
    MailActivity *mailAct = [[MailActivity alloc] init];
    NSString* urlreflink;
    NSString*reflink;
    
    //Preparing vairous values for mail
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"] ;
    NSString*shareMsgLine1 = @"Hi,";
    
    NSString*shareMsgLine2  = @"Sharing with you some recent discussions on Docquity. The fastest growing private & secure doctors only professional network.";
    
    NSString*shareTitle = LblTitle.text;
    NSString*shareMsgLine6 = @"I hope you like it and expecting to connect with you on Docquity.";
    NSString*shareMsgLine7 = @"Thanks";
    NSString*shareMsgLine8 = @"<a href=\"https://itunes.apple.com/us/app/docquity/id1048947290?mt=8/path/to/link\">Download Docquity</a>\n";
    
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    reflink =[userpref objectForKey:shareRefLink];
    [userpref synchronize];
//    if ([reflink rangeOfString:@"="].location != NSNotFound)
//    {
//        NSRange range = [reflink rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, reflink.length)];
//        urlreflink  = [reflink substringFromIndex:range.location+1];
//    }
    urlreflink = [NSString stringWithFormat:@"%@%@",feedsshareUrl,reflink];
    
    NSURL *shareUrl = [NSURL URLWithString:urlreflink];
    [emailBody appendString:[NSString stringWithFormat:@"%@<br></br>%@\n <br><br>%@</br>\n %@\n <br><br>%@</br>\n <br>%@</br>\n %@",shareMsgLine1,shareMsgLine2,shareTitle,shareUrl,shareMsgLine6,shareMsgLine7,shareMsgLine8,nil]];
    
    NSString *subject = LblTitle.text;
    MFMailComposeViewController *mailComposer = mailAct.mMailComposer;
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:emailBody isHTML:YES];
    return mailAct;
}

-(void) showSuccessToastWithMsg:(NSString *) msg{
    [SVProgressHUD showSuccessWithStatus:msg];
}

-(NSString*)LikeCount:(NSString*)lCount CommentCount:(NSString*)cCount{
    NSString *str = @"";
    
    if ([lCount integerValue] > 0 || [cCount integerValue] > 0) {
        
        if ([lCount integerValue] == 1 && [cCount integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor like this    %@ Comment",lCount,cCount];
        }
        
        else if ([lCount integerValue] > 1 && [cCount integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this    %@ Comment",lCount,cCount];
        }
        
        else if ([lCount integerValue] > 1 && [cCount integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this    %@ Comments",lCount,cCount];
        }
        
        else if ([lCount integerValue] == 1 && [cCount integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor like this    %@ Comments",lCount,cCount];
        }
        
        else if([lCount integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor like this",lCount];
        }
        
        else if([lCount integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this",lCount];
        }
        
        else if([cCount integerValue] == 1)
        {
            str =[NSString stringWithFormat:@" %@ Comment",cCount];
        }
        
        else if([cCount integerValue] > 1)
        {
            str =[NSString stringWithFormat:@" %@ Comments",cCount];
        }
    }
    return  str;
}

-(void)resetCommentTextView{
    placeholder.hidden = NO;
    placeholder.text = @"Write a comment...";
    commentTextView.text = @"";
    postbtn.enabled = NO;
    isReplyComment = NO;
    CGRect inputviewFrame = self.toolbar.frame;
    self.BottomConstraintsToolbar.constant = 0;
    self.tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, inputviewFrame.size.height - 44, 0.0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

-(void)defaultAlertShow{
    [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
}

-(void)pushToRepliesVCWithDic:(NSMutableDictionary*)FeedDic{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    RepliesVC *commentReplies = [storyboard instantiateViewControllerWithIdentifier:@"RepliesVC"];
    commentReplies.delegate = self;
    commentReplies.commentDic = FeedDic.mutableCopy;
    commentReplies.feedid = self.feedid;
    [self.navigationController pushViewController:commentReplies animated:YES];
}

-(void)replyCommentResponseWitheditedDic:(NSMutableDictionary*)dic anyAction:(BOOL)Flag{
    if(Flag){
        [self.commentArray removeObjectAtIndex:selectedSection];
        [self.commentArray insertObject:dic atIndex:selectedSection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
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
            //int value = [status intValue];
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

- (CGRect)convertToWindow:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return [view convertRect:view.bounds toView:window];
}

-(void)imgTapped:(UIButton*)sender{
    [photoView fadeInPhotoViewFromImageView:imageView];
}

-(void)img2Tapped:(UIButton*)sender{
    [photoView fadeInPhotoViewFromImageView:imageView2];
}

-(void)img3Tapped:(UIButton*)sender{
    [photoView fadeInPhotoViewFromImageView:imageView3];
}

-(void)img4Tapped:(UIButton*)sender{
    [photoView fadeInPhotoViewFromImageView:imageView4];
}
-(void)setBackButton{
    if(_isNoifPView)
    {
        UIBarButtonItem *backButton;
        backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setroot)];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -8; // it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
}
-(void)setroot{
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
}


#pragma mark - setfeedLikeRequest
- (void)setFeedLikeRequest:(NSString*)latestFeedId
{
    [self callingGoogleAnalyticFunction:@"Feed Detail Screen" screenAction:@"Feed Like Click"];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetFeedLikeRequesttWithAuthKey:[userDef objectForKey:userAuthKey] feed_id:latestFeedId device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                totalLikes++;
                myLikeStatus++;
                isMyLike = true;
                BtnLike.userInteractionEnabled = NO;
                long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                updateTime = [NSString stringWithFormat:@"%lld",myInt];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate] logOut];
            }
            
            else  if([[resposePost valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                [userpref synchronize];;
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
            else{
            [self defaultAlertShow];
            }
        }
    }];
}

- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    link = [link stringByReplacingOccurrencesOfString:@"#" withString:@""];
    link = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self pushToSpecilityForID:[self getSpecilityIdByName:link ForIndexPath:nil] specilityName:link];
}

-(NSString *)getSpecilityIdByName:(NSString *)specName ForIndexPath:(NSIndexPath *)indexPath{
    specName = [specName stringByEncodingHTMLEntities];
    NSMutableArray *specArr = feedDict[@"speciality"];
    NSString *spcid = @"";
    for (NSMutableDictionary * dic in specArr) {
        if ([[dic valueForKey:@"speciality_name"] isEqualToString:specName]) {
            spcid = [dic valueForKey:@"speciality_id"];
            break;
        }
    }
 //   NSLog(@"Spec name = %@ and Spec id = %@",specName,spcid);
    return spcid;
}

-(void)pushToSpecilityForID:(NSString *)specid specilityName:(NSString *)specName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    SpecilityFeedVC *specilityfeed = [storyboard instantiateViewControllerWithIdentifier:@"SpecilityFeedVC"];
    specilityfeed.specId = specid;
    specilityfeed.specName = specName;
    specilityfeed.commentFeedid = [self.feedDict valueForKey:@"feed_id"];
    specilityfeed.delegate = self;
    [self.navigationController pushViewController:specilityfeed animated:YES];
}

-(void)specilityViewFindDelete:(BOOL)isDelete deleteFeedID:(NSMutableArray*)deleteFeedID {
    if(isDelete){
        [self checkFeedStat];
//        if([[UpdateFeed sharedInstance] deleteFeedArray].count>0){
//            for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
//                NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
//                if([delfeedid isEqualToString:[self.feedDict valueForKey:@"feed_id"]]){
//                    [self.navigationController popViewControllerAnimated:YES];
//                    [self.delegate isDeleteFeed:isDelete Feedid:[self.feedDict valueForKey:@"feed_id"]];
//                    break;
//                }
//            }
//        }
    }
}

-(void)checkFeedStat{
    if([[UpdateFeed sharedInstance] deleteFeedArray].count>0){
        for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
            NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
            if([delfeedid isEqualToString:[self.feedDict valueForKey:@"feed_id"]]){
                [self.navigationController popViewControllerAnimated:YES];
                [self.delegate isDeleteFeed:YES Feedid:[self.feedDict valueForKey:@"feed_id"]];
                break;
            }
        }
    }
    

    for (NSMutableDictionary *GtempDic in [AppDelegate appDelegate].ActivityArray){

        if ([[GtempDic valueForKey:@"feed_id"]isEqualToString:[feedDict valueForKey:@"feed_id"]]) {
            offset = 1;
            [self getFeedCommentRequest];
            [[AppDelegate appDelegate].ActivityArray removeAllObjects];
            break;
        }
    }
}

@end
