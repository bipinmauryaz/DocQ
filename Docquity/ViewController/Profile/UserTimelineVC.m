//
//  UserTimelineVC.m
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//
#import "UserTimelineVC.h"
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
#import "ChatViewController.h"
#import "ServicesManager.h"
#import "MailActivity.h"

#define kTableHeaderHeight 186
#define kNaviBarHeight 64
#define kHeight      [[UIScreen mainScreen] bounds].size.height
#define kWidth       [[UIScreen mainScreen] bounds].size.width


@interface UserTimelineVC ()
<
timelineCellDelegate,
TLPhotoCellDelegate,
TLTextFeedCellDelegate,
TLImageFeedCellDelegate,
SDPhotoBrowserDelegate
>
@property(nonatomic, strong) ProfileData *profileData;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic,retain) UpdateFeed *updateArr;
@property (nonatomic, strong) NSArray *imagesArray;
@property (weak, nonatomic) IBOutlet UIButton *editProfileBtn;


@end

@implementation UserTimelineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedBtnString=@"Feeds";
    
    
    _editProfileBtn.layer.borderWidth=2.0f;
    _editProfileBtn.layer.borderColor=[UIColor colorWithRed:51/255.0 green:182/255.0 blue:118/255.0 alpha:1.0f].CGColor;
    _editProfileBtn.layer.masksToBounds=YES;
    
    
    
    isDataGet = false;
    timelinePhoto = [[NSMutableArray alloc]init];
    timelineFeedArr = [[NSMutableArray alloc]init];
    pageCount = 1;
    [self getProfileServiceWithCustId:self.custid];
    
    headerViewCreated = NO;
    self.profileData = [ProfileData new];
    if([self.custid isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.custid isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        isOwnProfile = YES;
        [self viewStatusSetup];
    }else{
        isOwnProfile = NO;
    }
    self.avatarImg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImg.layer.borderWidth = 1.0f;
    isDataGet = false;
    self.transparentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor = [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshProfile)
              forControlEvents:UIControlEventValueChanged];
    [self.tableview insertSubview: refreshControl atIndex:0];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    self.tableview.tableFooterView = self.spinner ;
   // [self initUI];
    [self scrollViewDidScroll:self.tableview];
    __weak UserTimelineVC *weakSelf = self;
   
    [self.tableview addPullToRefreshWithActionHandler:^{
        [Localytics tagEvent:@"WhatsTrending PullDown"];
        [weakSelf getProfileTimelineRequestWithCustId:self.custid];
    }position:SVPullToRefreshPositionBottom];
    
    self.tableview.showsPullToRefresh = NO;
    [self registerNotification];
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    self.headerBackImg.contentMode = UIViewContentModeScaleAspectFill;
    //self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width/2;
   // self.avatarImg.layer.masksToBounds = YES;
    self.headerBackImg.layer.masksToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self callingGoogleAnalyticFunction:@"Profile Screen" screenAction:@"Feed Screen Visit"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [Localytics tagEvent:@"ProfileScreen Visited"];
   //[self initUI];
    [self scrollViewDidScroll:self.tableview];
//   isDataGet?nil: [self getProfileServiceWithCustId:self.custid];
}

-(void)viewDidAppear:(BOOL)animated{
    if([self.custid isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]]){
        [self userPicupdates];
    }
  }

-(void)viewWillDisappear:(BOOL)animated{
    if(self.profileData.first_name.length >0){
        [self.delegate SettingViewCallWithCustomid:self.custid update_firstName:self.profileData.first_name update_lastName:self.profileData.last_name];
    }
}
- (IBAction)editProfileBtnAction:(id)sender {
    [self openProfile];
}

- (void)initUI {
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
  //  self.navigationController.navigationBar.translucent = YES;
    /*
     if(![self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]]){
     
     UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView:)];
     
     UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
     
     negativeSpacer.width = -8; // it was -6 in iOS 6
     
     [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton] animated:NO];
     }
     */
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:0.0], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    
    self.headerBackImg.image = [self blurWithCoreImage:self.headerBackImg.image];
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    self.headerBackImg.contentMode = UIViewContentModeScaleAspectFill;
   // self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width/2;
   // self.avatarImg.layer.masksToBounds = YES;
    self.headerBackImg.layer.masksToBounds = YES;
    // self.TableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self addBackButtonWithAnimation:NO];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
   });
}

-(void)viewStatusSetup{
    self.viewStatusHeightConstraints.constant = 0;
    self.lblStatusTopConstraints.constant = 0;
    self.lblStatusBottomConstraints.constant = 0;
    self.imgStatusHeightConstraints.constant = 0;
    self.imgStatusBottomConstraints.constant = 0;
    self.imgStatusTopConstraints.constant = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        if(timelinePhoto.count == 0){
            return 0;
        }
    }else if(section == 2){
        return timelineFeedArr.count;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0) {
        TLSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLSummaryCell"forIndexPath:indexPath];
        cell.delegate = self;
        if(isDataGet)
        [cell configureUserInfoWithData:self.profileData];
        return cell;
    }else if(indexPath.section == 1){
        TLPhotosCell *photoCell;
        if(timelinePhoto.count >5) {
            photoCell = [tableView dequeueReusableCellWithIdentifier:@"TLPhotosCell5"  forIndexPath:indexPath];
        }else if(timelinePhoto.count >1){
            photoCell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"TLPhotosCell%lu",(unsigned long)timelinePhoto.count] forIndexPath:indexPath];
        }else if(timelinePhoto.count == 1){
            photoCell = [tableView dequeueReusableCellWithIdentifier:@"TLPhotosCell" forIndexPath:indexPath];
        }
        [photoCell configureUserInfoWithData:timelinePhoto];
        photoCell.delegate = self;
        return photoCell;
        
    }else if(indexPath.section == 2){
        if([[[timelineFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeNormal])
        {
            TLTextFeedCell *tlTextCell = [tableView dequeueReusableCellWithIdentifier:@"TLTextFeedCell" forIndexPath:indexPath];
            [tlTextCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlTextCell.delegate = self;
            return tlTextCell;
        }else if([[[timelineFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeImage])
        {
            TLImageFeedCell *tlImageCell = [tableView dequeueReusableCellWithIdentifier:@"TLImageFeedCell" forIndexPath:indexPath];
            [tlImageCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlImageCell.delegate = self;
            return tlImageCell;
        } else if([[[timelineFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeVideo])
        {
            TLImageFeedCell *tlImageCell = [tableView dequeueReusableCellWithIdentifier:@"TLImageFeedCell" forIndexPath:indexPath];
            if(tlImageCell == nil){
                tlImageCell = [[TLImageFeedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TLImageFeedCell"];
            }
            [tlImageCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlImageCell.delegate = self;
            return tlImageCell;
        }
        else if([[[timelineFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeMeta])
        {
            TLTextFeedCell *tlMetaCell;
            if ([[timelineFeedArr objectAtIndex:indexPath.row] objectForKey:@"meta_array"]) {
                tlMetaCell = [tableView dequeueReusableCellWithIdentifier:@"TLMetaFeedCell" forIndexPath:indexPath];
            } else {
                tlMetaCell = [tableView dequeueReusableCellWithIdentifier:@"TLOldMetaFeedCell" forIndexPath:indexPath];
                tlMetaCell.webview.scrollView.bounces = false;
                tlMetaCell.webview.scrollView.scrollEnabled = false;
                NSString * urslStrig = [timelineFeedArr objectAtIndex:indexPath.row][@"file_url"];
                urslStrig = [urslStrig stringByDecodingHTMLEntities];
                tlMetaCell.webview.opaque = NO;
                tlMetaCell.webview.backgroundColor = [UIColor clearColor];
                [tlMetaCell.webview loadHTMLString:urslStrig baseURL:nil];
                tlMetaCell.lbl_feed_title.text = [[[[timelineFeedArr objectAtIndex:indexPath.row] valueForKey:@"title"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
                tlMetaCell.lbl_desc.text = [[[[timelineFeedArr objectAtIndex:indexPath.row] valueForKey:@"content"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
            }
            [tlMetaCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlMetaCell.metaview_container.layer.borderColor = [UIColor lightGrayColor].CGColor;
            tlMetaCell.metaview_container.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
            tlMetaCell.metaview_container.layer.shadowOpacity = 0.5;
            tlMetaCell.metaview_container.layer.shadowRadius = 1.0;
            tlMetaCell.metaview_container.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            tlMetaCell.delegate = self;
            return tlMetaCell;
        }else if([[[timelineFeedArr objectAtIndex:indexPath.row]valueForKey:@"file_type"]isEqualToString:kFeedTypeDoc])
        {
            TLTextFeedCell *tlDocCell = [tableView dequeueReusableCellWithIdentifier:@"TLDocFeedCell"];
            [tlDocCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlDocCell.pdf_backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
            tlDocCell.delegate = self;
            return tlDocCell;
        }else{
            TLTextFeedCell *tlTextCell = [tableView dequeueReusableCellWithIdentifier:@"TLTextFeedCell" forIndexPath:indexPath];
            [tlTextCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
            tlTextCell.delegate = self;
            return tlTextCell;
        }
    }else{
        TLTextFeedCell *tlTextCell = [tableView dequeueReusableCellWithIdentifier:@"TLTextFeedCell" forIndexPath:indexPath];

        [tlTextCell configureCellForRowAtIndexPath:indexPath withData:[timelineFeedArr objectAtIndex:indexPath.row]];
        tlTextCell.delegate = self;
        return tlTextCell;
    }
  }

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2){
        if([[[timelineFeedArr objectAtIndex:indexPath.row] valueForKey:@"classification"] isEqualToString:@"cme"])
        {
            [[AppDelegate appDelegate] navigateToTabBarScren:1];
        }else{
            clickedIndexPath = indexPath;
            [self pushToCommentView];
        }
     }
 }

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableview.frame.size.width, 50)];
    headerView.backgroundColor=[UIColor whiteColor];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    UIButton *feedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    feedBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [feedBtn addTarget:self
               action:@selector(feedBtnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [feedBtn setTitle:@"Feeds" forState:UIControlStateNormal];
    feedBtn.frame = CGRectMake(0, 0, (screenSize.width/3.0), 50.0);
    [headerView addSubview:feedBtn];
    
    UIButton *mediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mediaBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [mediaBtn addTarget:self
               action:@selector(mediaBtnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [mediaBtn setTitle:@"Media" forState:UIControlStateNormal];
    mediaBtn.frame = CGRectMake(feedBtn.frame.size.width, 0, feedBtn.frame.size.width, 50.0);
    [headerView addSubview:mediaBtn];
    
    UIButton *archiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    archiveBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [archiveBtn addTarget:self
               action:@selector(archiveBtnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [archiveBtn setTitle:@"Archive" forState:UIControlStateNormal];
    archiveBtn.frame = CGRectMake((feedBtn.frame.size.width*2), 0, feedBtn.frame.size.width, 50.0);
    [headerView addSubview:archiveBtn];
    
    UIView *bottomBorderFeed;
    UIView *bottomBorderMedia;
    UIView *bottomBorderArchive;
    if ([selectedBtnString isEqualToString:@"Feeds"]) {
        [feedBtn setTitleColor:[UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [mediaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [archiveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        bottomBorderFeed = [[UIView alloc] initWithFrame:CGRectMake(0, feedBtn.frame.size.height - 2.5f, feedBtn.frame.size.width, 2.5f)];
        bottomBorderFeed.backgroundColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        [feedBtn addSubview:bottomBorderFeed];
        
        bottomBorderMedia = [[UIView alloc] initWithFrame:CGRectMake(0, mediaBtn.frame.size.height, mediaBtn.frame.size.width, 0)];
        [mediaBtn addSubview:bottomBorderMedia];
        
        bottomBorderArchive = [[UIView alloc] initWithFrame:CGRectMake(0, archiveBtn.frame.size.height, archiveBtn.frame.size.width, 0)];
        [archiveBtn addSubview:bottomBorderArchive];
    }
    else if ([selectedBtnString isEqualToString:@"Media"]) {
        [feedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [mediaBtn setTitleColor:[UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [archiveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        bottomBorderFeed = [[UIView alloc] initWithFrame:CGRectMake(0, feedBtn.frame.size.height, feedBtn.frame.size.width, 0)];
        [feedBtn addSubview:bottomBorderFeed];
        
        bottomBorderMedia = [[UIView alloc] initWithFrame:CGRectMake(0, mediaBtn.frame.size.height - 2.5f, mediaBtn.frame.size.width, 2.5f)];
        bottomBorderMedia.backgroundColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        [mediaBtn addSubview:bottomBorderMedia];
        
        bottomBorderArchive = [[UIView alloc] initWithFrame:CGRectMake(0, archiveBtn.frame.size.height, archiveBtn.frame.size.width, 0)];
        [archiveBtn addSubview:bottomBorderArchive];
        
    }
    else if ([selectedBtnString isEqualToString:@"Archive"]) {
        [feedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [mediaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [archiveBtn setTitleColor:[UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        bottomBorderFeed = [[UIView alloc] initWithFrame:CGRectMake(0, feedBtn.frame.size.height , feedBtn.frame.size.width, 0)];
        [feedBtn addSubview:bottomBorderFeed];
        
        bottomBorderMedia = [[UIView alloc] initWithFrame:CGRectMake(0, mediaBtn.frame.size.height , mediaBtn.frame.size.width, 0)];
        [mediaBtn addSubview:bottomBorderMedia];
        
        bottomBorderArchive = [[UIView alloc] initWithFrame:CGRectMake(0, archiveBtn.frame.size.height - 2.5f, archiveBtn.frame.size.width, 2.5f)];
        bottomBorderArchive.backgroundColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        [archiveBtn addSubview:bottomBorderArchive];
        
    }
    


    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section==2) {
        return 50;
    }
    else{
        return 0;
    }
}

-(void)feedBtnAction:(id)sender{
    selectedBtnString=@"Feeds";
    [self.tableview reloadData];
}

-(void)mediaBtnAction:(id)sender{
    selectedBtnString=@"Media";
    [self.tableview reloadData];
}

-(void)archiveBtnAction:(id)sender{
    selectedBtnString=@"Archive";
    [self.tableview reloadData];

}




-(void)openWebviewWithURL:(NSString *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WebVC *webview = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webview.fullURL = url;
    [self presentViewController:webview animated:YES completion:nil];
}

-(void)clickedUrl:(NSString *)url{
    [self openWebviewWithURL: url];
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@30 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:0 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIColor *color        = [UIColor colorWithRed:0 green:137/255.0 blue:202/255.0 alpha:1];
    CGFloat contentY      = scrollView.contentOffset.y;
    CGFloat alpha         = contentY / (kTableHeaderHeight - kNaviBarHeight);
//    NSLog(@" contentY %f",contentY);
//    NSLog(@"alpha %f",contentY);
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:alpha];
//    [self.navigationController.navigationBar zz_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[[UIColor whiteColor]colorWithAlphaComponent:alpha], NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    self.navigationBarView.backgroundColor = [color colorWithAlphaComponent:alpha];
    self.navTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    
    //    self.navigationController.navigationBar.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:alpha];
}

-(void)addBackButtonWithAnimation:(BOOL)animated{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -6;
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton] animated:animated];
}

-(void)backView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"docquitySetFeedUploaded" object:nil];
    if ([AppDelegate appDelegate].comefromsearch == YES) {
        [AppDelegate appDelegate].isbackUpdateCheckFromSearch = YES;
    }
    else if ([AppDelegate appDelegate].isComeFromSettingVC == NO) {
        [[AppDelegate appDelegate] navigateToTabBarScren:4];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - get userCourseListRequest
-(void)getProfileServiceWithCustId:(NSString*)custid{

    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[DocquityServerEngine sharedInstance]viewProfileWithAuthKey:[userPref valueForKey:userAuthKey] custom_id:custid device_type:kDeviceType ipAddress:[userPref valueForKey:ip_address1] app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
       //  NSLog(@"responseObject get profile:%@",responseObject);
         if(responseObject == nil){
         //    NSLog(@"Response is null");
             [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             self.tableview.tableFooterView = nil;
             return ;
         }
         [refreshControl endRefreshing];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if(error){
             if (error.code == NSURLErrorTimedOut) {
                 //time out error here
                 [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];
                 self.tableview.tableFooterView = nil;
                 
             }else{
                 // [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }
         }else {
             NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
             if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil) {
                 // tel is null
             }else {
                 if([[resposeDic valueForKey:@"status"]integerValue] == 1)
                 {
                     NSMutableDictionary *dataDic=[resposeDic objectForKey:@"data"];
                     if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                     {
                         // tel is null
                     }else {
                         
                         //Profile Data Entry Start
                         self.profileData.assoMArr = [[NSMutableArray alloc]init];
                         self.profileData.eduArr = [[NSMutableArray alloc]init];
                         self.profileData.interestArr = [[NSMutableArray alloc]init];
                         self.profileData.ProfessionArr = [[NSMutableArray alloc]init];
                         self.profileData.SpecArr = [[NSMutableArray alloc]init];
                         self.profileData.timeline_access =(BOOL)[dataDic valueForKey:@"timeline_access"];
                         timelinePhoto = [dataDic valueForKey:@"timeline_photo"];
                         NSMutableArray *assoarr = [dataDic valueForKey:@"association"];
                         NSMutableArray *eduarr = [dataDic valueForKey:@"education"];
                         NSMutableArray *intArr = [dataDic valueForKey:@"interest"];
                         NSMutableArray *profArr = [dataDic valueForKey:@"profession"];
                         NSMutableArray *specArr = [dataDic valueForKey:@"speciality"];
                         NSMutableDictionary *frndDic = [dataDic valueForKey:@"friend"];
                         NSMutableDictionary *profileDic = [dataDic valueForKey:@"profile"];
                         if([assoarr isKindOfClass:[NSMutableArray class]] || assoarr !=nil){
                             for(NSMutableDictionary *assoDic in assoarr){
                                 ProfileAssoModel *proAss = [ProfileAssoModel new];
                                 proAss.associationId = [assoDic valueForKey:@"association_id"];
                                 proAss.assoPic = [assoDic valueForKey:@"association_pic"];
                                 proAss.assoName = [assoDic valueForKey:@"association_name"];
                                 [self.profileData.assoMArr addObject:proAss];
                             }
                         }
                         if([eduarr isKindOfClass:[NSMutableArray class]] || eduarr !=nil){
                             for(NSMutableDictionary *eduDic in eduarr){
                                 EducationModel *eduModel = [EducationModel new];
                                 eduModel.education_id = [eduDic valueForKey:@"education_id"];
                                 eduModel.school = [eduDic valueForKey:@"school"];
                                 eduModel.start_date = [eduDic valueForKey:@"start_date"];
                                 eduModel.end_date = [eduDic valueForKey:@"end_date"];
                                 eduModel.degree = [eduDic valueForKey:@"degree"];
                                 eduModel.field_of_study = [eduDic valueForKey:@"field_of_study"];
                                 eduModel.grade = [eduDic valueForKey:@"grade"];
                                 eduModel.activities_and_societies = [eduDic valueForKey:@"activities_and_societies"];
                                 eduModel.edu_description = [eduDic valueForKey:@"description"];
                                 eduModel.course_type = [eduDic valueForKey:@"course_type"];
                                 eduModel.current_pursuing = [eduDic valueForKey:@"current_pursuing"];
                                 [self.profileData.eduArr addObject:eduModel];
                             }
                         }
                         
                         if([intArr isKindOfClass:[NSMutableArray class]] || intArr !=nil){
                             for(NSMutableDictionary *intDic in intArr){
                                 InterestModel *intModel = [InterestModel new];
                                 intModel.interest_id = [intDic valueForKey:@"interest_id"];
                                 intModel.interest_name = [intDic valueForKey:@"interest_name"];
                                 [self.profileData.interestArr addObject:intModel];
                             }
                         }
                         if([profArr isKindOfClass:[NSMutableArray class]] || profArr !=nil){
                             for(NSMutableDictionary *profDic in profArr){
                                 ProfessionModel *profModel = [ProfessionModel new];
                                 profModel.profession_id = [profDic valueForKey:@"profession_id"];
                                 profModel.profession_name = [profDic valueForKey:@"profession_name"];
                                 profModel.position = [profDic valueForKey:@"position"];
                                 profModel.location = [profDic valueForKey:@"location"];
                                 profModel.start_date = [profDic valueForKey:@"start_date"];
                                 profModel.end_date = [profDic valueForKey:@"end_date"];
                                 profModel.start_month = [profDic valueForKey:@"start_month"];
                                 profModel.end_month = [profDic valueForKey:@"end_month"];
                                 profModel.prof_description = [profDic valueForKey:@"description"];
                                 profModel.current_prof = [profDic valueForKey:@"current_prof"];
                                 [self.profileData.ProfessionArr addObject:profModel];
                             }
                         }
                         if([specArr isKindOfClass:[NSMutableArray class]] || specArr !=nil){
                             for(NSMutableDictionary *specDic in specArr){
                                 SpecialityModel *specModel = [SpecialityModel new];
                                 specModel.speciality_id = [specDic valueForKey:@"speciality_id"];
                                 specModel.speciality_name = [specDic valueForKey:@"speciality_name"];
                                 [self.profileData.SpecArr addObject:specModel];
                             }
                         }
                         if([frndDic isKindOfClass:[NSMutableDictionary class]] || frndDic !=nil){
                             FriendModel *frndModel = [FriendModel new];
                             frndModel.friend_status = [NSString stringWithFormat:@"%@",[frndDic valueForKey:@"friend_status"]];
                             frndModel.frnd_stmsg = [frndDic valueForKey:@"friend_status_message"];
                             self.profileData.FriendDic = frndModel;
                         }
                         if([profileDic isKindOfClass:[NSMutableDictionary class]] || profileDic !=nil){
                             self.profileData.user_id = [profileDic valueForKey:@"user_id"];
                             self.profileData.name = [[profileDic valueForKey:@"name"]stringByDecodingHTMLEntities];
                             self.profileData.first_name = [[profileDic valueForKey:@"first_name"]stringByDecodingHTMLEntities];
                             self.profileData.custom_id = [profileDic valueForKey:@"custom_id"];
                             self.profileData.last_name = [[profileDic valueForKey:@"last_name"]stringByDecodingHTMLEntities];
                             self.profileData.chat_id =   [profileDic valueForKey:@"chat_id"];
                             self.profileData.jabber_id = [profileDic valueForKey:@"jabber_id"];
                             self.profileData.jabber_name =   [profileDic valueForKey:@"jabber_name"];
                             self.profileData.email = [profileDic valueForKey:@"email"];
                             self.profileData.country_code = [profileDic valueForKey:@"country_code"];
                             self.profileData.mobile = [profileDic valueForKey:@"mobile"];
                             self.profileData.country = [[profileDic valueForKey:@"country"]stringByDecodingHTMLEntities];
                             self.profileData.city = [[profileDic valueForKey:@"city"]stringByDecodingHTMLEntities];
                             self.profileData.state = [[profileDic valueForKey:@"state"]stringByDecodingHTMLEntities];
                             self.profileData.bio = [[profileDic valueForKey:@"bio"]stringByDecodingHTMLEntities];
                             
                             
                             self.profileData.bio  = [self.profileData.bio stringByReplacingOccurrencesOfString:@"<br>" withString: @""];
                             self.profileData.bio = [self.profileData.bio stringByReplacingOccurrencesOfString:@"<br/>" withString: @""];
                             self.profileData.bio = [self.profileData.bio stringByReplacingOccurrencesOfString:@"<br />" withString: @""];
                             self.profileData.profile_pic_path = [profileDic valueForKey:@"profile_pic_path"];
                             
                             if([[profileDic valueForKey:@"total_point"] isKindOfClass:[NSNull class]]){
                                 self.profileData.total_refer_points = @"0";
                             }else {
                                 self.profileData.total_refer_points = [profileDic valueForKey:@"total_point"];
                             }
                             
                             if([[profileDic valueForKey:@"total_cme_points"] isKindOfClass:[NSNull class]]){
                                 self.profileData.total_cme_points = @"0";
                             }else {
                                 self.profileData.total_cme_points = [profileDic valueForKey:@"total_cme_points"];
                             }
                             self.profileData.total_connection = [profileDic valueForKey:@"total_connection"];
                             [self.avatarImg sd_setImageWithURL:[NSURL URLWithString:[profileDic valueForKey:@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"default_profile.png"] options:SDWebImageRefreshCached];
                             
                             self.navTitle.text = [[[self.profileData.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString];
                             
                             self.lbl_userName.text = [[[self.profileData.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString];
                             if([[self.profileData.city stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0){
                             self.lbl_city.text = [NSString stringWithFormat:@"%@, %@",[self.profileData.city stringByDecodingHTMLEntities],[[self.profileData.country stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
                             }else {
                                 self.lbl_city.text = [[self.profileData.country stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
                             }
                             self.lbl_userName.backgroundColor = [UIColor clearColor];
                             
                             self.lbl_city.backgroundColor = [UIColor clearColor];
                             if([self.profileData.SpecArr count]>0){
                                 self.lbl_Speciality.text = [[self.profileData.SpecArr objectAtIndex:0].speciality_name stringByDecodingHTMLEntities];
                                 self.lbl_Speciality.backgroundColor = [UIColor clearColor];
                             }else{
                                 self.lbl_Speciality.hidden = YES;
                             }
                         }
                     }
                     //Profile Data Entry End
                     isDataGet = YES;
                     timelinePhoto.count>0?[self photoViewSetup]:nil;
                     [self.tableview reloadData];
                     [self.headerBackImg sd_setImageWithURL:[NSURL URLWithString:self.profileData.profile_pic_path]
                                           placeholderImage:[UIImage imageNamed:@""]
                                                    options:SDWebImageRefreshCached
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                                      self.headerBackImg.image = [self blurWithCoreImage:self.headerBackImg.image];
                                                      //self.headerBackImg.image = image;;
                                                      self.imgUser = image;
                                                      [self blurimageP:image];
                                                  }];
                     
                     if(self.profileData.timeline_access){
                         [self getProfileTimelineRequestWithCustId:self.profileData.custom_id];
                     }else{
                         self.tableview.tableFooterView = nil;
                     }
                      if(isDataGet){
                         self.view_status.backgroundColor = kNewCOAColor;
                         self.view_action.hidden = false;
                         self.img_status.image = [UIImage imageNamed:@"whitechat.png"];
                     }
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 9)
                 {
                     [[AppDelegate appDelegate] logOut];
                 }
                 else  if([[resposeDic valueForKey:@"status"]integerValue] == 11)
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
                 
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 5)
                 {
                     [[AppDelegate appDelegate]ShowPopupScreen];
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 0)
                 {
                     [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                 }
             }
         }
     }];
}

-(void)blurimageP:(UIImage *)image{
    
    self.headerBackImg.image = image;
    
    // create blur effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // create vibrancy effect
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
    
    // add blur to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.transparentView.frame;
    
    // add vibrancy to yet another effect view
    UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
    vibrantView.frame = self.transparentView.frame;
    
    // add both effect views to the image view
    [self.headerBackImg addSubview:effectView];
    [self.headerBackImg addSubview:vibrantView];
    
    
    
        // make some UI changes
        // ...
        // show actionSheet for example
          // self.headerBackImg.image = [self blurWithCoreImage:image];
    
 
}

#pragma mark - get userProfileTimeLineRequest
-(void)getProfileTimelineRequestWithCustId:(NSString*)custid{
 //   NSLog(@"getProfileTimelineRequestWithCustId");
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[DocquityServerEngine sharedInstance]getUserTimeLineRequestWithAuthKey:[userPref valueForKey:userAuthKey] custom_id:custid limit:@"10" offset:[NSString stringWithFormat:@"%ld",(long)pageCount] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.tableview.tableFooterView = nil;
        self.tableview.showsPullToRefresh = YES;
//        NSLog(@"responseObject get profile timeline:%@ error=  %@",responseObject,error);
        if(responseObject == nil){
         //   NSLog(@"Response is null");
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
            [self.tableview.pullToRefreshView stopAnimating];
            
            self.tableview.tableFooterView = nil;
            return ;
        }
        if(error){
            if (error.code == NSURLErrorTimedOut) {
                
                //time out error here
                
            } else{
                self.tableview.tableFooterView = nil;
                 [self singleButtonAlertViewWithAlertTitle:AppName message:InternetSlowMessage buttonTitle:OK_STRING];
            }
            
        }else {
            NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
            if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil) {
                [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                // tel is null
            } else {
                if([[resposeDic valueForKey:@"status"]integerValue] == 1) {
                    pageCount ==1?[timelineFeedArr removeAllObjects]:nil;
                    NSMutableArray *feedDataArr= [resposeDic objectForKey:@"feed"];
                    if([feedDataArr count]) {
                        for(int i=0; i<[feedDataArr count]; i++)
                        {
                            NSMutableDictionary *feedDic = [[NSMutableDictionary alloc] initWithDictionary:feedDic = feedDataArr[i]];
                            if (feedDic != nil && [feedDic isKindOfClass:[NSMutableDictionary class]]) {
                                [timelineFeedArr addObject:feedDic];
                            }
                        }
                       // NSLog(@"pageCount = %ldd, timelineFeedArr count = %lu",(long)pageCount,(unsigned long)timelineFeedArr.count);
                    }
                    self.tableview.tableFooterView = nil;
                    pageCount ++ ;
                    [self.tableview reloadData];
                    [self.tableview.pullToRefreshView stopAnimating];
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 7) {
                    self.tableview.showsPullToRefresh = NO;
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 9) {
                    [[AppDelegate appDelegate] logOut];
                } else  if([[resposeDic valueForKey:@"status"]integerValue] == 11) {
                    self.tableview.showsPullToRefresh = NO;
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 5) {
                    [[AppDelegate appDelegate]ShowPopupScreen];
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 0) {
                    self.tableview.showsPullToRefresh = NO;
                    
                }
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



-(void)refreshProfile{
    pageCount = 1;
    [self getProfileServiceWithCustId:self.custid];
    if (refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        //        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSString *title = @"Refreshing...";
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}




#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)TLTableViewCell:(TLTextFeedCell *)cell didTapOnHashTag:(NSString *)hashTag {
    NSString *message = [NSString stringWithFormat:@"You have tapped hashTag = %@!",hashTag];
    [self singleButtonAlertViewWithAlertTitle:@"Hashtag Tapped" message:message buttonTitle:@"OK"];
}

- (void)TLImageFeedCell:(TLImageFeedCell *)cell didTapOnHashTag:(NSString *)hashTag{
    NSString *message = [NSString stringWithFormat:@"You have tapped hashTag = %@!",hashTag];
    [self singleButtonAlertViewWithAlertTitle:@"Hashtag Tapped" message:message buttonTitle:@"OK"];
}

- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    link = [link stringByReplacingOccurrencesOfString:@"#" withString:@""];
    link = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self pushToSpecilityForID:[self getSpecilityIdByName:link ForIndexPath:indexPath] specilityName:link];
}

- (IBAction)didPressSeeAllPhoto:(id)sender {
   // NSLog(@"didPressSeeAllPhoto");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CollectionViewController *gridView = [storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    gridView.userName = self.profileData.name;
    gridView.custmid = self.profileData.custom_id;
    [self.navigationController pushViewController:gridView animated:YES];
    
}

- (void)didPressLikeBtn:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
///    NSLog(@"like indexpath row %ld",(long)clickedIndexPath.row);
    
    NSMutableDictionary *dict = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
   // NSLog(@"Like stauts indexpath section %ld = %@",(long)clickedIndexPath.section,[dict valueForKey: @"like_status"]);
    if([[dict valueForKey: @"like_status"]isEqualToString:@"0"]){
        [self setFeedLikeRequest:[dict valueForKey:@"feed_id"]];
        [self reloadTableForLikeFeed:true];
    }else{
  //      NSLog(@"Already liked");
    
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
    feedShareUrl = [timelineFeedArr objectAtIndex:clickedIndexPath.row][@"feed_share_url"];
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:OK_STRING];
    }
    else
    {
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
        if ([u_permissionstus isEqualToString:@"readonly"]) {
            [self getcheckedUserPermissionData];
        }
        else{
            [self shareFeed];
        }
    }
    

   // [self shareFeed];
}
- (void)didPressDocumentBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
   // NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
   // NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self openDocument];
}

- (void)didPressMetaBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
  //  NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
   // NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self openMetadataUrl];
}

- (void)didPressFeedAction:(UIButton*)sender atPoint:(CGPoint)point{
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
  //  NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
   // NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    [self actionOnFeed];
}


- (void)didPressUserBtn:(UIButton*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
   // NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
   // NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    if([[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"custom_id"]isEqualToString:self.custid]){
    //    NSLog(@"same Profile");
    }else{
        [self pushToOthersTimeline];
    }
}

- (void)didTapUserImage:(UIImageView*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
  //  NSLog(@"Document indexpath row %ld",(long)clickedIndexPath.row);
  //  NSLog(@"indexpath section %ld",(long)clickedIndexPath.section);
    if([[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"custom_id"]isEqualToString:self.custid]){
    //    NSLog(@"same Profile");
    }else{
        [self pushToOthersTimeline];
    }
}


- (IBAction) didPressStartChat:(UIButton*)sender {
    if([self.comefrom isEqualToString:@"chat"]){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self qbStartChat];
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
//                NSDictionary *dict = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
//                NSInteger total_like = [dict[@"total_like"]integerValue];
//                total_like -= 1;
//                NSString *likeString = [NSString stringWithFormat:@"%ld", (long)total_like];
//                [dict setValue:@"0" forKey:@"like_status"];
//                [dict setValue:likeString forKey:@"total_like"];
//                [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:clickedIndexPath.row inSection:clickedIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

-(void)reloadTableForLikeFeed:(BOOL)likeStatus{

    NSMutableDictionary *dict = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
    NSInteger total_like = [dict[@"total_like"]integerValue];
 //   NSLog(@"Total Like = %ld",(long)total_like);
    total_like = likeStatus?++total_like:--total_like;
  //  NSLog(@"Total Like cond = %ld",(long)total_like);
    NSString *tLikeString = [NSString stringWithFormat:@"%ld", (long)total_like];
    likeStatus?[dict setValue:@"1" forKey:@"like_status"]:[dict setValue:@"0" forKey:@"like_status"];
    [dict setValue:tLikeString forKey:@"total_like"];
   // NSLog(@"like_status = %@",[dict valueForKey: @"like_status"]);
    [self.tableview reloadData];
    [[AppDelegate appDelegate].ActivityArray addObject: [timelineFeedArr objectAtIndex:clickedIndexPath.row]];
//    [self.tableview beginUpdates];
//    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:clickedIndexPath.row inSection:clickedIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];

//    [self.tableview endUpdates];
}

-(void)pushToCommentView{
    NSMutableDictionary *dict = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
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

-(void)commentviewReturnsForFeedid:(NSString*)feedid commentCount:(NSString*)TotalComment LikesCount:(NSString*)TotalLikes ilike:(BOOL)flag updatedTimeStamp:(NSString *)updateTimeStamp{
 //   NSLog(@"commentviewReturnsForFeedid");
    
  //   NSLog(@"Feedid = %@, comment count = %@, Like count = %@" ,feedid,TotalComment,TotalLikes);

    for (NSMutableDictionary *tempDic in timelineFeedArr){
        if ([[tempDic valueForKey:@"feed_id"]isEqualToString:feedid]) {
            [tempDic setObject:TotalLikes forKey:@"total_like"];
            [tempDic setObject:TotalComment forKey:@"total_comments"];
            flag==true?[tempDic setObject:@"1" forKey:@"like_status"]:nil;
            if (![updateTimeStamp isEqualToString:@""]) {
                [tempDic setObject:updateTimeStamp forKey:@"date_of_updation"];
            }
            [self.tableview reloadData];
            [[AppDelegate appDelegate].ActivityArray addObject: [timelineFeedArr objectAtIndex:clickedIndexPath.row]];
            
            break;
        }
    }
}



//-(void)specilityViewReturns{
//    for (NSMutableDictionary *GtempDic in [UpdateFeed sharedInstance].ActivityArray){
//    NSUInteger index = 0;
//        for (NSMutableDictionary *tempDic in timelineFeedArr)
//        {
//            if ([[tempDic valueForKey:@"feed_id"]isEqualToString:[GtempDic valueForKey:@"feed_id"]]) {
//                
//                [timelineFeedArr removeObjectAtIndex:index];
//                [timelineFeedArr insertObject:GtempDic atIndex:index];
//            }
//            index ++;
//        }
//    }
//}

-(void)specilityViewFindDelete:(BOOL)isDelete deleteFeedID:(NSMutableArray*)deleteFeedID {
      //  NSLog(@"specilityViewFindDelete : %@",deleteFeedID);
      //  NSLog(@"ActivityArray : %@",[AppDelegate appDelegate].ActivityArray);
    
    for (NSMutableDictionary *GtempDic in [AppDelegate appDelegate].ActivityArray){
        NSUInteger index = 0;
        [[[UpdateFeed sharedInstance]activityArray]addObject:GtempDic];
        for (NSMutableDictionary *tempDic in timelineFeedArr)
        {
            if ([[tempDic valueForKey:@"feed_id"]isEqualToString:[GtempDic valueForKey:@"feed_id"]]) {
//                NSLog(@"tempDic eqal to activity aaray : ");
                [timelineFeedArr removeObjectAtIndex:index];
                [timelineFeedArr insertObject:GtempDic atIndex:index];
                
                break;
            }
            index ++;
        }
    }
    
    [AppDelegate appDelegate].ActivityArray = [[NSMutableArray alloc]init];
/*    if(isDelete){
        for (NSString *feedid in deleteFeedID)
        {
            NSUInteger index = 0;
            for (NSMutableDictionary *tempDic in timelineFeedArr)
            {
                if ([[tempDic valueForKey:@"feed_id"]isEqualToString:feedid]) {
                    
                    [timelineFeedArr removeObjectAtIndex:index];
                }
                index ++;
            }
            
        }
    }
    */
    if([[UpdateFeed sharedInstance] deleteFeedArray].count>0){
        for (NSUInteger i = 0; i < [[UpdateFeed sharedInstance] deleteFeedArray].count; i++) {
            NSString *delfeedid = [[[UpdateFeed sharedInstance] deleteFeedArray]objectAtIndex:i];
            for (NSUInteger k = 0; k < timelineFeedArr.count; k++) {
                NSDictionary *data = timelineFeedArr[k];
                if ([data[@"feed_id"] isEqualToString:delfeedid]) {
                    [timelineFeedArr removeObjectAtIndex:k];
                    break;
                }
            }
        }
    }

    [self.tableview reloadData];
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
    [[AppDelegate appDelegate] getPlaySound];
    MailActivity *mailActivity = [self generateMailActiviy];
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    
    NSString *shareTitle = [NSString stringWithFormat:@"%@",[[[timelineFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"title"]stringByDecodingHTMLEntities]];
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
    NSString *shareTitle = [NSString stringWithFormat:@"%@",[[[timelineFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"title"]stringByDecodingHTMLEntities]];
    
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
    urlreflink = [NSString stringWithFormat:@"%@%@",feedShareUrl, reflink];
    
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
    
    if(![[[timelineFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"classification"] isEqualToString:@"cme"]){
    
        [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
           // NSLog(@"Edit");
            ///Edit Feed here
            
            NSDictionary*feedInformation = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
            [self setEditFeedWithFeedID:feedInformation];
            //[self setEditFeedWithFeedID:[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
       // NSLog(@"Delete");
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:kdeletePostTitle message:kdeletePostConfirmation preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
           //  NSLog(@"Delete sure");
            [self setDeleteFeedRequest:[timelineFeedArr objectAtIndex:clickedIndexPath.row][@"feed_id"]];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
 
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setEditFeedWithFeedID:(NSDictionary *)feeddicInfo{
    
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        
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
                 }
                 else  if([[responsePost valueForKey:@"status"]integerValue] == 0)
                 {
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                     [self presentViewController:alertController animated:YES completion:nil];
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

-(void)reloadTableForDeleteFeed{
    [timelineFeedArr removeObjectAtIndex:clickedIndexPath.row];
    [self.tableview reloadData];
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
    specilityfeed.delegate = self;
    [self.navigationController pushViewController:specilityfeed animated:YES];
}

-(void)pushToOthersTimeline{
    NSMutableDictionary *dict = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *otherTimeline = [storyboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];

//    [self.navigationController.navigationBar setTranslucent:NO];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    UIColor *color    = kThemeColor;
//    self.navigationController.navigationBar.barTintColor = color;
    otherTimeline.custid = [dict valueForKey:@"custom_id"];
    [self.navigationController pushViewController:otherTimeline animated:YES];
}


-(NSString *)getSpecilityIdByName:(NSString *)specName ForIndexPath:(NSIndexPath *)indexPath{
    specName = [specName stringByEncodingHTMLEntities];
    NSMutableArray *specArr = [timelineFeedArr objectAtIndex:indexPath.row][@"speciality"];
    NSString *spcid = @"";
    for (NSMutableDictionary * dic in specArr) {
        if ([[dic valueForKey:@"speciality_name"] isEqualToString:specName]) {
            spcid = [dic valueForKey:@"speciality_id"];
            break;
        }
    }
   // NSLog(@"Spec name = %@ and Spec id = %@",specName,spcid);
    return spcid;
}


-(void)photoViewSetup{
    NSString *subtitle = @"";
    if([self.profileData.SpecArr count]>0){
        subtitle = [self.profileData.SpecArr objectAtIndex:0].speciality_name;
    }else{
        subtitle = self.profileData.country;
    }
    photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) dateTitle:@"" title:self.profileData.name subtitle:subtitle];
}

-(void)imgviewTapped:(UIImageView*)sender{
    [photoView fadeInPhotoViewFromImageView:sender];
}

- (void)imgviewTapped:(UIImageView*)sender atPoint:(CGPoint)point {
    CGPoint rootViewPoint = [sender.superview convertPoint:point toView:self.tableview];
    clickedIndexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    NSString *activity =@"";
    NSString *comment = [timelineFeedArr objectAtIndex:clickedIndexPath.row][@"total_comments"];
    NSString *likes = [timelineFeedArr objectAtIndex:clickedIndexPath.row][@"total_like"];
    NSString *update = [NSString setUpdateTimewithString:[[timelineFeedArr objectAtIndex:clickedIndexPath.row] valueForKey:@"date_of_updation"]];
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
    NSString *subtitle = [timelineFeedArr objectAtIndex:clickedIndexPath.row][@"content"];
    NSString *title = [timelineFeedArr objectAtIndex:clickedIndexPath.row][@"title"];
    [photoView fadeInPhotoViewFromImageView:sender withTitle:title subTitle:subtitle dateTitle:activity];
    
}


-(void)showPhotosForCurrentPhotoID:(NSInteger)idx{

    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = idx;
    photoBrowser.imageCount = self.imagesArray.count;
    photoBrowser.sourceImagesContainerView = self.tableview;
    
    [photoBrowser show];

}


#pragma mark - openMetaDataLink Clicked Action
-(void)openMetadataUrl
{
    [Localytics tagEvent:@"WhatsTrending Meta Click"];
    
    NSMutableDictionary *feed = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
  
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

#pragma mark - documentBtn Clicked Action
-(void)openDocument
{
    [Localytics tagEvent:@"WhatsTrending DocumentUpload Click"];
    NSMutableDictionary *feed = [timelineFeedArr objectAtIndex:clickedIndexPath.row];
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

-(void)openProfile{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        
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
        [self getcheckedUserPermissionData];
    }
    else{
        [self pushToProfileDetailsView];
    }

}
-(void)pushToProfileDetailsView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewProfileVC *openProfile = [storyboard instantiateViewControllerWithIdentifier:@"NewProfileVC"];
    openProfile.profileData = self.profileData;
    openProfile.customUserId = self.profileData.custom_id;
    openProfile.isDataGet = true;
    openProfile.userProfileImage = self.imgUser;
    [AppDelegate appDelegate].isComeFromTimeline =YES;
    openProfile.delegate = self;
    [self.navigationController pushViewController:openProfile animated:YES];
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

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"docquitySetFeedUploaded" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    pageCount = 1;
    [self getProfileTimelineRequestWithCustId:self.profileData.custom_id];
}

//- (IBAction)didPressNavbarBackButton:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (IBAction)didPressNavbarBackButton:(id)sender {
    if ([AppDelegate appDelegate].comefromsearch == YES) {
        [AppDelegate appDelegate].isbackUpdateCheckFromSearch = YES;
    }
    else if ([AppDelegate appDelegate].isComeFromSettingVC == NO) {
        [[AppDelegate appDelegate] navigateToTabBarScren:4];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)TimeLineViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state{
    
    self.profileData.first_name = update_firstName.mutableCopy;
    self.profileData.last_name = update_lastName.mutableCopy;
    self.lbl_userName.text= [NSString stringWithFormat:@"%@ %@",update_firstName.mutableCopy,update_lastName.mutableCopy];
    self.navTitle.text = [NSString stringWithFormat:@"%@ %@",update_firstName.mutableCopy,update_lastName.mutableCopy];
    self.profileData.email = update_email.mutableCopy;
    if(update_country.length ==0 && update_city.length == 0)
    {
        self.lbl_city.text = @"";
    }else  if(update_country.length !=0 && update_city.length != 0){
        self.lbl_city.text = [NSString stringWithFormat: @"%@, %@",update_city.mutableCopy,update_country.mutableCopy];
    }else  if(update_country.length != 0){
        self.lbl_city.text = [NSString stringWithFormat: @"%@",update_country.mutableCopy];
    }else  if(update_city.length != 0){
        self.lbl_city.text = [NSString stringWithFormat: @"%@",update_city.mutableCopy];
    }
    
    [self.tableview reloadData];
}
- (UIImage*)getImage: (NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"Media"];
    NSString *getImagePath = [dataPath stringByAppendingPathComponent:filename];
    // NSLog(@"Get image path: %@",getImagePath);
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    if (img == nil && img == NULL)
    {
        img = [UIImage imageNamed:@"avatar.png"];
        //NSLog(@"no underlying data");
    }
    return img;
}

-(void)userPicupdates{
    self.avatarImg.image = [self getImage:@"MyProfileImage.png"];
    self.headerBackImg.image = [self getImage:@"MyProfileImage.png"];
}


@end
