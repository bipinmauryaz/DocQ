//
//  SettingVC.m
//  Docquity
//
//  Created by Arimardan Singh on 19/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//
#import "SettingVC.h"
#import "AppSettings.h"
#import "Utils.h"
#import "ReportIssueVC.h"
#import "NewProfileVC.h"
#import "Localytics.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileData.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "FeedCell.h"
#import "UserTimelineVC.h"
#import "NSString+HTML.h"
#import "SSPopup.h"
#import "EarnVC.h"
#import "ReferandEarnVC.h"
#import "PostingVC.h"

@interface SettingVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) ProfileData *profileData;

//for popup
@property (weak, nonatomic) IBOutlet UIButton *englishBtn;
@property (weak, nonatomic) IBOutlet UIButton *indonesiaBtn;
@property (weak, nonatomic) IBOutlet UIView *popupView;

@end
@implementation SettingVC
@synthesize soundSwitch,cachingSwitch,lbls;
@synthesize profileData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundSwitch.layer.cornerRadius = 16.0; // you must import QuartzCore to do this
    if (soundSwitch.on) {
        lbl_sound.text = @"Sound / Notification";
    // NSLog(@"If switch on ");
    [soundSwitch setThumbTintColor:[UIColor whiteColor]];
    [soundSwitch setBackgroundColor:[UIColor colorWithRed:0/255.0 green:137/255.0 blue:202/255.0 alpha:1]];
    [soundSwitch setOnTintColor:[UIColor colorWithRed:0/255.0 green:137/255.0 blue:202/255.0 alpha:1]];
     }
    else{
        lbl_sound.text = @"Mute / Notification";
     // NSLog(@"Else switch off ");
        [soundSwitch setTintColor:[UIColor clearColor]];
        [soundSwitch setThumbTintColor:[UIColor whiteColor]];
        [soundSwitch setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    NSUserDefaults*userdef = [NSUserDefaults standardUserDefaults];
    NSString*firstname = [userdef valueForKey:dc_firstName];
    NSString*lastname = [userdef valueForKey:dc_lastName];
    [userdef synchronize];
    
    NSString *fullname = [NSString stringWithFormat:@"%@ %@",firstname,lastname];
    lbl_uName.text = [[fullname stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    userPImage.image = [self getImage:@"MyProfileImage.png"];
    userPImage.contentMode = UIViewContentModeScaleAspectFill;
    userPImage.layer.cornerRadius = 4.0f;
    userPImage.layer.masksToBounds = YES;
    userPImage.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    userPImage.layer.borderWidth = 0.5;
    
    //Notify View
    notify_View.layer.cornerRadius = notify_View.frame.size.height / 2;
    notify_View.clipsToBounds= YES;
    
    //reportIssue View
    report_View.layer.cornerRadius = notify_View.frame.size.height / 2;
    report_View.clipsToBounds= YES;
    
    //select language View
    language_View.layer.cornerRadius = language_View.frame.size.height / 2;
    language_View.clipsToBounds= YES;
    
    //referel View
    referelView.layer.cornerRadius = referelView.frame.size.height / 2;
    referelView.clipsToBounds= YES;
    
    //docquity points View
    pointsView.layer.cornerRadius = pointsView.frame.size.height / 2;
    pointsView.clipsToBounds= YES;
    
    //Redering the AppSettings
    [self.soundSwitch setOn:[AppSettings soundOn]];
    [self.cachingSwitch setOn:[AppSettings cachingOn]];
    
    UITapGestureRecognizer *taponView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openReportIssue)];
    [reportIssueView setUserInteractionEnabled:YES];
    [reportIssueView addGestureRecognizer:taponView];
    
    UITapGestureRecognizer *slectlangView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(languageSelect:)];
    [selectLanguage_View setUserInteractionEnabled:YES];
    [selectLanguage_View addGestureRecognizer:slectlangView];

    UITapGestureRecognizer *taponProfileView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfileView)];
    [profileView setUserInteractionEnabled:YES];
    [profileView addGestureRecognizer:taponProfileView];
    
    UITapGestureRecognizer *taponearnpointView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openEaernpointView)];
    [earnPoints_View setUserInteractionEnabled:YES];
    [earnPoints_View addGestureRecognizer:taponearnpointView];
    
    UITapGestureRecognizer *taponreferelView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRewardView)];
    [referel_View setUserInteractionEnabled:YES];
    [referel_View addGestureRecognizer:taponreferelView];
    //notification sound switch can only be used when permission is granted from IOS
    
    //for popup
    self.popupView.hidden=YES;
    
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor= [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor whiteColor];
 }

// Do any additional setup after loading the view from its nib.
-(void)viewWillAppear:(BOOL)animated
{
    [Localytics tagEvent:@"Account Tab Click"];
    [self userPicupdates];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Account";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica SemiBold" size:16.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - userPic Updates
-(void)userPicupdates
{
    userPImage.image = [self getImage:@"MyProfileImage.png"];
 }

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (IBAction)soundSwitchValChanged:(UISwitch *)sender
{
    if (sender.isOn) {
        soundImage.image = [UIImage imageNamed:@"notification.png"];
        lbl_sound.text = @"Sound / Notification";
        //NSLog(@"If switch on ");
        [sender setThumbTintColor:[UIColor whiteColor]];
        [sender setBackgroundColor:[UIColor colorWithRed:0/255.0 green:137/255.0 blue:202/255.0 alpha:1]];
        [sender setOnTintColor:[UIColor colorWithRed:0/255.0 green:137/255.0 blue:202/255.0 alpha:1]];
    }
    else
    {
        //NSLog(@"Else switch off ");
        [sender setTintColor:[UIColor clearColor]];
        [sender setThumbTintColor:[UIColor whiteColor]];
        [sender setBackgroundColor:[UIColor lightGrayColor]];
        lbl_sound.text = @"Mute / Notification";
        soundImage.image = [UIImage imageNamed:@"notification_disabled.png"];
    }
    [AppSettings setSoundOn:sender.isOn];
    [Utils playClick2Sound];
}

- (IBAction)cachingSwitchValChanged:(UISwitch *)sender
{
    [AppSettings setCachingOn:sender.isOn];
    [Utils playClick2Sound];
}

#pragma mark - openReportIssue
-(void)openReportIssue
{
    UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    ReportIssueVC *VC5  = [mstoryboard instantiateViewControllerWithIdentifier:@"ReportIssueVC"];
    VC5.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC5 animated:YES];
}

#pragma mark - language Select
-(void)languageSelect:(id)sender
{
   // [self.tabBarController.tabBar setHidden:YES];
   // self.popupView.hidden=NO;
//   // self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"DocquityMain" bundle:nil];
    PostingVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"PostingVC"];
    NewProfile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];

    /*
    UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CMEReviewVC *VC5  = [mstoryboard instantiateViewControllerWithIdentifier:@"CMEReviewVC"];
    VC5.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC5 animated:YES];
    */
    
    /*
    UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewVerifySelfVC *VC5  = [mstoryboard instantiateViewControllerWithIdentifier:@"NewVerifySelfVC"];
    VC5.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC5 animated:YES];
     */

    /*
    NSArray *langArray=[[NSArray alloc]initWithObjects:@"English",@"Bahasa Indonesia", nil];
    SSPopup* selection=[[SSPopup alloc]init];
    selection.backgroundColor=[UIColor colorWithWhite:0.00 alpha:0.4];
    selection.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    selection.SSPopupDelegate=self;
    [self.view  addSubview:selection];
    [selection CreateTableview:langArray withSender:sender  withTitle:@"Select Language" setCompletionBlock:^(int tag){
    NSLog(@"Tag--->%d",tag);
    }];
     */
}

#pragma mark - openEaernpointView
-(void)openEaernpointView{
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"DocquityMain" bundle:nil];
    EarnVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"EarnVC"];
    NewProfile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

#pragma mark - OpenProfileView
-(void)openRewardView
{
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"DocquityMain" bundle:nil];
    ReferandEarnVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"ReferandEarnVC"];
    NewProfile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

#pragma mark - OpenProfileView
-(void)openProfileView
{
    //Profile Tab Config
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *custmId=[userpref objectForKey:ownerCustId];
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custmId;
    NewProfile.delegate = self;
    NewProfile.hidesBottomBarWhenPushed = YES;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

#pragma mark - getImage
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
      // NSLog(@"no underlying data");
    }
    return img;
}

-(void)SettingViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName{
    lbl_uName.text = [NSString stringWithFormat:@"%@ %@", update_firstName.mutableCopy,update_lastName.mutableCopy];
}

//for popup
- (IBAction)englishbtnAction:(id)sender {
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor whiteColor];
}

- (IBAction)indonesiaBtnAction:(id)sender {
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor=[UIColor whiteColor];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
}

- (IBAction)cancelAtion:(id)sender {
    [self.tabBarController.tabBar setHidden:NO];
    self.popupView.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
