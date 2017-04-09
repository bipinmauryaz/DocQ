/*============================================================================
 PROJECT: Docquity
 FILE:    ProfileVC.m
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 22/04/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "ProfileVC.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "EditProfileVC.h"
#import "UIImageView+WebCache.h"
#import "NewChatViewController.h"
#import "Reachability/Reachability.h"
#import "NSString+HTML.h"
#import "Localytics.h"
#import "ReportIssueVC.h"
#import "PermissionCheckYourSelfVC.h"
#import "DocquityServerEngine.h"
#import "NotificationVC.h"
#import "DocquityServerEngine.h"

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 Interface: ProfileVC
 =============================================================================*/
@interface ProfileVC ()
{
    NSString*u_authkey;                          // for get user_authkey when we are getting on profile
    NSString*uId;                               // for get user_id when we are getting on profile
    NSString*u_fName;                          // for get user_firstName when we are getting on profile
    NSString*u_lName;                         // for get user_lastName when we are getting on profile
    NSString*userPic;                        // for get user_Profile pic when we are getting on profile
    NSString*u_email;                       // for get user_email when we are getting on profile
    NSString*u_mobileNo;                   // for get user_MobileNo when we are getting on profile
    NSString*u_dob;                       // for get user_dob when we are getting on profile
    NSString*u_country;                  // for get user_country when we are getting on profile
    NSString*u_city;                    // for get user_city when we are getting on profile
    NSString*u_education;              // for get user_education when we are getting on profile
    NSString*u_award;                            // for get user_award when we are getting on profile
    NSString*u_association;                     // for get user_association when we are getting on profile
    NSString*u_interest;                       // for get user_interest when we are getting on profile
    NSString*u_research;                      // for get user_research when we are getting on profile
    NSString*u_speciality;                   // for get user_speciality when we are getting on profile
    NSString*u_bio;                         // for get user_bio when we are getting on profile
    NSString*u_state;                      // for get user_state when we are getting on profile
    NSString*u_summary;                   // for get user_summary when we are getting on profile
    NSString*u_title;                    // for get user_title when we are getting on profile
    NSString*u_gender;                  // for get user_gender when we are getting on profile
    NSString*u_language;               // for get user_language when we are getting on profile
    NSString*frndStus;                // for get user_frndStus when we are getting on profile
    UILabel *eduLbl1;                // for get user_eduLbl when we are getting on profile
    UILabel *basicInfoLbl;          // for get user_basicInfoLbl when we are getting on profile
    NSDictionary *resposeCode;    // for get user_country when we are getting on profile
    NSString*customId;           // for get user_country when we are getting on profile
    UILabel *DocAllSkillLbl;    // for get user_country when we are getting on profile
    UIImageView *assoImg;     // for get user_country when we are getting on profile
    UILabel *lblCompany;     // for get user_lblCompany when we are getting on profile
    UILabel *lblProfile;    // for get user_lblProfile when we are getting on profile
    UILabel *lblPeriod;    // for get user_lblPeriod when we are getting on profile
    UILabel *InterestEarnLbl;            // for get InterestEarnLbl when we are getting on profile
    UILabel *InterestLbl;               // for get user_InterestLbl when we are getting on profile
    UILabel *horizontalLine;          // for get horizontalLine when we are getting on profile
    
    int Frndvalue ;                 // for get user_Frndvalue when we are getting on profile
    NSString*t_frndCount;          // for get t_frndCount when we are getting on profile
    UILabel *EditProfile;         // for get EditProfile when we are getting on profile
    UIButton *EditProfileBtn;    // for get EditProfileBtn when we are getting on profile
    UIButton*callBtn;
    NSString* u_countryCode;
    UIButton *EditIcon;
    
    NSString * permstus; //check readonly permission
}

typedef enum{
    kTag_imgEditBtn =100,
    kTag_Profileimg,
    kTag_scroll,
    kTag_Topbar,
    kTag_DocSkillBarVW,
    kTag_flexview,
    kTag_EditProfileVw,
    kTag_SummaryView,
    kTag_ProffView,
    kTag_BasicinfoView,
    kTag_ChatVw,
    kTag_educationView,
    kTag_ContImg,
    kTag_Contlbl,
    kTag_ContNoLbl,
    kTag_EDUVIEW,
    kTag_emailImg,
    kTag_BdayImg,
    kTag_PersonalViewHolder,
    kTag_DocAllSkillLbL,
    kTag_edulineImg
}All_Tag;

@end
@implementation ProfileVC
@synthesize docname;
@synthesize docLoc;
@synthesize docSkillsSet;
@synthesize profileDetailDic,customUserId;
@synthesize u_jabId;

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream
{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).xmppStream;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    Frndvalue =2;
    self.navigationController.navigationBarHidden=YES;
    if([AppDelegate appDelegate].isComeFromEditGroup == YES){
        NSMutableDictionary* filldicdata;
        filldicdata = [self.NEWARRAYDATA objectAtIndex:self.ab];
        self.customUserId = [filldicdata valueForKey:@"member_id"];
        NSString*jbIDStr =  [filldicdata valueForKey:@"jabber_id"];
        u_jabId = [jbIDStr lowercaseString];
    }
    if([AppDelegate appDelegate].isComeFromCommentView == YES){
        NSMutableDictionary* filldicdata;
        filldicdata = [self.NEWARRAYDATA objectAtIndex:self.ab];
        self.customUserId = [filldicdata valueForKey:@"custom_id"];
        NSString*jbIDStr =  [filldicdata valueForKey:@"commenter_jabber_id"];
        u_jabId = [jbIDStr lowercaseString];
    }
    [self topbar];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [Localytics tagEvent:@"ProfileScreen Visited"];
}



#pragma  mark MainUI
-(void)MainUI{
    UIView *topbar = (UIView*)[self.view viewWithTag: kTag_Topbar];
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, topbar.frame.origin.y +topbar.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    scroll.backgroundColor = [UIColor whiteColor];
    scroll.tag = kTag_scroll;
    [self.view addSubview:scroll];
    userPic = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"profile_pic"]?[resposeCode  objectForKey:@"profile_pic"]:@""];
    NSString*u_Img = [ImageUrl stringByAppendingPathComponent:userPic];
    UIImageView *Profileimg = [[UIImageView alloc]initWithFrame:CGRectMake(scroll.frame.size.width/2-45, 10, 90, 90)];
    
    if (Frndvalue==0 || Frndvalue == 9 || Frndvalue == 1 || Frndvalue == 8) {
        [Profileimg sd_setImageWithURL:[NSURL URLWithString:u_Img]
                      placeholderImage:[UIImage imageNamed:@"avatar.png"]
                               options:SDWebImageRefreshCached];
    }
    else {
        Profileimg.image = [self getImage:@"MyProfileImage.png"];
    }
    Profileimg.contentMode = UIViewContentModeScaleAspectFill;
    Profileimg.layer.cornerRadius = 45.0;
    Profileimg.tag= kTag_Profileimg;
    Profileimg.layer.masksToBounds = YES;
    [scroll addSubview:Profileimg];
    
    u_fName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"first_name"]?[resposeCode  objectForKey:@"first_name"]:@""];
    u_lName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"last_name"]?[resposeCode  objectForKey:@"last_name"]:@""];
    
    NSString *f_Upper = [u_fName capitalizedString];
    NSString *l_Upper = [u_lName capitalizedString];
    NSString*d_name;
    if(f_Upper.length!=0){
        d_name = [[f_Upper stringByAppendingString:@" "]stringByAppendingString:l_Upper];
    }
    else {
        d_name =l_Upper;
    }
    u_country = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
    u_countryCode = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
    u_city = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
    
    NSString *city_Upper = [u_city capitalizedString];
    NSString *country_Upper = [u_country capitalizedString];
    NSString*d_loc;
    if(city_Upper.length!=0){
        d_loc = [[city_Upper stringByAppendingString:@", "]stringByAppendingString:country_Upper];
    }
    else {
        d_loc =country_Upper;
    }
    
    UILabel *DocNamelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, Profileimg.frame.origin.y + Profileimg.frame.size.height+8, self.view.frame.size.width, 20)];
    if(d_name!= (id)[NSNull null])
        DocNamelbl.text = d_name;
    
    else
        DocNamelbl.text = @"";
    DocNamelbl.font = [UIFont systemFontOfSize:16.0f];
    DocNamelbl.textAlignment = NSTextAlignmentCenter;
    DocNamelbl.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [scroll addSubview:DocNamelbl];
    NSString *DocSpecility;
    NSMutableArray *speciality;
    UILabel *DocLocationLbl = [[UILabel alloc]init];
    UILabel *DocSpecLbl = nil;
    if([resposeCode objectForKey:@"speciality"] == (id)[NSNull null]){
        DocSpecility = @"";
        NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
        [userpref setObject:DocSpecility?DocSpecility:@"" forKey:docSpecility];
        [userpref synchronize];
        DocLocationLbl.frame = CGRectMake(0, DocNamelbl.frame.size.height + DocNamelbl.frame.origin.y, self.view.frame.size.width, 15);
    }else{
        speciality = [resposeCode objectForKey:@"speciality"];
        DocSpecLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, DocNamelbl.frame.size.height + DocNamelbl.frame.origin.y, self.view.frame.size.width, 15)];
        if([speciality isKindOfClass:[NSNull class]]){
        }
        else {
            DocSpecility = [[speciality objectAtIndex:0]objectForKey:@"speciality_name"];
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            [userpref setObject:DocSpecility?DocSpecility:@"" forKey:docSpecility];
            [userpref synchronize];
        }
        NSString *spec_Upper = [DocSpecility capitalizedString];
        DocLocationLbl.frame = CGRectMake(0, DocSpecLbl.frame.size.height + DocSpecLbl.frame.origin.y, self.view.frame.size.width, 15);
        
        DocSpecLbl.text = spec_Upper;
        DocSpecLbl.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        DocSpecLbl.font = [UIFont systemFontOfSize:14.0f];
        DocSpecLbl.textAlignment = NSTextAlignmentCenter;
        [scroll addSubview:DocSpecLbl];
    }
    if(d_loc!= (id)[NSNull null])
        DocLocationLbl.text= d_loc;
    else
        DocLocationLbl.text=@"";
    DocLocationLbl.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
    DocLocationLbl.font = [UIFont systemFontOfSize:13.0f];
    DocLocationLbl.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:DocLocationLbl];
    UIView *DocSkillBarVW = [[UIView alloc]initWithFrame:CGRectMake(6, DocLocationLbl.frame.size.height + DocLocationLbl.frame.origin.y+8, self.view.frame.size.width-12, 35)];
    DocSkillBarVW.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    DocSkillBarVW.tag = kTag_DocSkillBarVW;
    [scroll addSubview:DocSkillBarVW];
    UILabel *DocConnCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, DocSkillBarVW.frame.size.width, 30)];
    if([t_frndCount isEqualToString:@""] || [t_frndCount isEqualToString:@"<null>"]){
        DocConnCountLbl.text = @"0+ Connections";
    }
    else {
        if(t_frndCount.length!=0){
            
            DocConnCountLbl.text  = [t_frndCount stringByAppendingString:@"+ Connections"];
        }
        else {
            DocConnCountLbl.text  = @"0+ Connections";
        }
    }
    DocConnCountLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    DocConnCountLbl.font = [UIFont boldSystemFontOfSize:15.0];
    DocConnCountLbl.textAlignment = NSTextAlignmentCenter;
    [DocSkillBarVW addSubview:DocConnCountLbl];
}

#pragma  mark DocProfile
-(void)DocProfile{
    UIView* flexview;
    flexview = [[UIView alloc]init];
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *skillBarVW = (UIView *)[ScrV viewWithTag:kTag_DocSkillBarVW];
    flexview.frame = CGRectMake(skillBarVW.frame.origin.x, skillBarVW.frame.origin.y + skillBarVW.frame.size.height+ 2, [UIScreen mainScreen].bounds.size.width - skillBarVW.frame.origin.x*2, 78);
    flexview.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    flexview.tag = kTag_flexview;
    [ScrV addSubview:flexview];
    assoImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 30, 30)];
    assoImg.image = [UIImage imageNamed:@"exp_default.png"];
    [flexview addSubview:assoImg];
    lblCompany = [[UILabel alloc]initWithFrame:CGRectMake(assoImg.frame.origin.x + assoImg.frame.size.width +10, assoImg.frame.origin.y+3, flexview.frame.size.width - (assoImg.frame.origin.x*3+assoImg.frame.size.width+20), 20)];
    lblCompany.font = [UIFont systemFontOfSize:14.0f];
    [flexview addSubview:lblCompany];
    lblProfile = [[UILabel alloc]initWithFrame:CGRectMake(lblCompany.frame.origin.x, lblCompany.frame.size.height + lblCompany.frame.origin.y, lblCompany.frame.size.width, 20)];
    lblProfile.font = [UIFont systemFontOfSize:13.0f];
    lblProfile .textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [flexview addSubview:lblProfile];
    lblPeriod = [[UILabel alloc]initWithFrame:CGRectMake(lblProfile.frame.origin.x, lblProfile.frame.size.height + lblProfile.frame.origin.y, lblProfile.frame.size.width, 20)];
    lblPeriod.font = [UIFont systemFontOfSize:13.0f];
    lblPeriod.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
    [flexview addSubview:lblPeriod];
}

#pragma  mark EditProfile
-(void)EditProfile{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *skillBarVW = (UIView *)[ScrV viewWithTag:kTag_DocSkillBarVW];
    UIView *flexVW = (UIView *)[ScrV viewWithTag:kTag_flexview];
    UIView *EditProfileVw = [[UIView alloc]initWithFrame:CGRectMake(skillBarVW.frame.origin.x, flexVW.frame.origin.y+flexVW.frame.size.height+5, skillBarVW.frame.size.width, 42)];
    EditProfileVw.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    EditProfileVw.tag = kTag_EditProfileVw;
    [ScrV addSubview:EditProfileVw];
    UIView*container = [[UIView alloc]initWithFrame:CGRectMake(EditProfileVw.frame.size.width/2-60, 0, 120, 42)];
    [EditProfileVw addSubview:container];
    EditIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if((Frndvalue ==1)||(Frndvalue ==0)){
        EditIcon.frame = CGRectMake(0, 10, 20, 20);
    }
    else {
        EditIcon.frame = CGRectMake(-5, 10, 20, 20);
    }
    if([AppDelegate appDelegate].comefromsearch == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    // check from comment view
    if([AppDelegate appDelegate].isComeFromCommentView == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    // check from Trusts
    if([AppDelegate appDelegate].isComeFromTrustList == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    // check from connections
    else if([AppDelegate appDelegate].isComeFromConnections == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    // check from trending
    if([AppDelegate appDelegate].isComeFromTrending == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    
    // check from edit group
    else if([AppDelegate appDelegate].isComeFromEditGroup == YES){
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    else{
        if(Frndvalue ==1){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==9){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else if (Frndvalue==8){
            [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
        }
        else{
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            }
            else {
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"AddSingleFrnd.png"] forState:UIControlStateNormal];
            }
        }
    }
    [container addSubview: EditIcon];
    EditProfile = [[UILabel alloc]initWithFrame:CGRectMake(EditIcon.frame.origin.x+EditIcon.frame.size.width+5, 0, 200, 42)];
    EditProfileBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    EditProfileBtn.frame = CGRectMake(skillBarVW.frame.origin.x, flexVW.frame.origin.y+flexVW.frame.size.height+5, skillBarVW.frame.size.width, 42);
    [ScrV addSubview: EditProfileBtn];
    if([AppDelegate appDelegate].comefromsearch == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    
    //check from TrustList
    else if([AppDelegate appDelegate].isComeFromTrustList == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    
    //check from comment
    else if([AppDelegate appDelegate].isComeFromCommentView == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    //check from connection
    else if([AppDelegate appDelegate].isComeFromConnections == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    //check from if come from feed view
    else if([AppDelegate appDelegate].isComeFromEditGroup == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    // check from edit Group
    else if([AppDelegate appDelegate].isComeFromTrending == YES){
        if(Frndvalue ==1){
            EditProfile.text = @"Start Chat";
            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (Frndvalue==9){
            EditProfile.text = @"Request Sent";
            [EditProfileBtn addTarget:self action:@selector(PendingRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else if (Frndvalue==8){
            EditProfile.text = @"Accept Request";
            [EditProfileBtn addTarget:self action:@selector(AcceptRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            callBtn.hidden = YES;
        }
        else {
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            NSString *u_id=[userpref objectForKey:userId];
            if ([uId isEqualToString:u_id])
            {
                EditProfile.text = @"Edit Profile";
                [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
            else {
                EditProfile.text = @"Connect";
                [EditProfileBtn addTarget:self action:@selector(frndRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                callBtn.hidden = YES;
            }
        }
    }
    else{
        EditProfile.text = @"Edit Profile";
        [EditProfileBtn addTarget:self action:@selector(editProfileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        callBtn.hidden = YES;
    }
    EditProfile.textAlignment = NSTextAlignmentLeft;
    EditProfile.textColor= [UIColor whiteColor];
    EditProfile.font = [UIFont systemFontOfSize:17.0f];
    [container addSubview:EditProfile];
}

#pragma mark Edit Profile Action
-(void)editProfileBtnClick:(id)sender{
    EditProfileVC *editP = [[EditProfileVC  alloc]init];
   // editP.profileDic = resposeCode;
    editP.delegate = self;
    editP.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:editP animated:YES];
}

#pragma mark callingBtn Action
-(void)callingBtnClick:(UIButton*)sender{
    
    NSString*u_callingNo =[[@"+" stringByAppendingString:u_countryCode] stringByAppendingString:u_mobileNo];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",u_callingNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Call facility is not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [calert show];
    }
}

#pragma mark chatBtn Action
-(void)chatBtnClick:(id)sender{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM contacts WHERE username ='%@' AND type ='1'", u_jabId];
    
    NSArray *DBRESULT =  [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if(DBRESULT.count!=0){
        //        NSString *UpdQuery= [NSString stringWithFormat:@"UPDATE contacts SET type='1' WHERE username= '%@'",u_jabId];
        //         [self.dbManager executeQuery:UpdQuery];
    }
    else {
        
        NSString *UpdQuery= [NSString stringWithFormat:@"UPDATE contacts SET type='1' WHERE username= '%@'",u_jabId];
        [self.dbManager executeQuery:UpdQuery];
        
        //        NSString *query1= [NSString stringWithFormat:@"INSERT INTO contacts (nickname, username,type) VALUES ('%@','%@','%d');",u_fName, u_jabId,1];
        //        [self.dbManager executeQuery:query1];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewChatViewController *grpchat  = [storyboard instantiateViewControllerWithIdentifier:@"newChatController"];
    grpchat.roomJid = u_jabId;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *query2= [NSString stringWithFormat:@"SELECT nickname,_id FROM  contacts WHERE username ='%@'",u_jabId];
    NSArray *DBRESULTS =  [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query2]];
    NSInteger indexofid = [self.dbManager.arrColumnNames indexOfObject:@"_id"];
    NSString *th_id = [[DBRESULTS objectAtIndex:0]objectAtIndex:indexofid];
    grpchat.ThreadID = [th_id integerValue];
    [AppDelegate appDelegate].checkcustomNotificonWindow = YES;
    [AppDelegate appDelegate].isComeFromGroup = NO;
    [self.navigationController pushViewController:grpchat animated:YES];
}

#pragma  Frnd Request Action
-(void)frndRequestBtnClick:(id)sender{
    [Localytics tagEvent:@"Profile ConnectionRequestSend"];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        isConnectionSendRequest =YES;
        [self getcheckedUserPermissionData];
    }
    else{
        [self sendFriendConnectionRequest:uId u_jabberId:u_jabId user_fname:u_fName];
        //[self serviceCalling1];
    }
}

#pragma  Pending Request Action
-(void)PendingRequestBtnClick:(id)sender{
}

#pragma  Accept Request Action
-(void)AcceptRequestBtnClick:(id)sender{
    [Localytics tagEvent:@"Profile ConnectionAccept"];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        isConnectionSendRequest = NO;
        [self getcheckedUserPermissionData];
    }
    else{
         [self AcceptFriendConnectionRequest:uId u_jabberId:u_jabId user_fname:u_fName];
       // [self serviceCalling2];
    }
}

#pragma  mark Summary
-(void)Summary{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *SummaryView;
    UIView *EditPVW;
    
    EditPVW = (UIView *)[ScrV viewWithTag:kTag_EditProfileVw];
    SummaryView = [[UIView alloc]initWithFrame:CGRectMake(EditPVW.frame.origin.x, EditPVW.frame.origin.y+EditPVW.frame.size.height+5, EditPVW.frame.size.width, 20)];
    [ScrV addSubview:SummaryView];
    UILabel *summaryLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SummaryView.frame.size.width, 20)];
    summaryLbl.font= [UIFont systemFontOfSize:16.0f];
    summaryLbl.text = @"Summary";
    [SummaryView addSubview:summaryLbl];
    
    UITextView *summaryTV;
    summaryTV = [[UITextView alloc]initWithFrame:CGRectMake(summaryLbl.frame.origin.x, summaryLbl.frame.origin.y+summaryLbl.frame.size.height+5, EditPVW.frame.size.width, 100)];
    
    summaryTV.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    summaryTV.editable = NO;
    //summaryTV.dataDetectorTypes = UIDataDetectorTypeAll;
    
    summaryTV.scrollEnabled= YES;
    summaryTV.showsVerticalScrollIndicator = YES;
    
    summary  = [u_summary stringByReplacingOccurrencesOfString:@"<br>" withString: @"\n"];
    summary = [u_summary stringByReplacingOccurrencesOfString:@"<br/>" withString: @"\n"];
    summary = [u_summary stringByReplacingOccurrencesOfString:@"<br />" withString: @"\n"];
    //summary =  [u_summary stringByDecodingHTMLEntities];
    if(summary!= (id)[NSNull null])
        summaryTV.text=summary;
    
    else
        summaryTV.text=@"";
    summaryTV.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
    summaryTV.font = [UIFont systemFontOfSize:13.0f];
    [SummaryView addSubview:summaryTV];
    CGRect newframe = SummaryView.frame;
    newframe.size.height = summaryTV.frame.origin.y+ summaryTV.frame.size.height+5;
    SummaryView.frame = newframe;
    SummaryView.tag = kTag_SummaryView;
    
}

#pragma  mark Proffesional
-(void)Proffesional{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *editpVw = (UIView* )[ScrV viewWithTag:kTag_EditProfileVw];
    UIView *SummaryVW = (UIView *)[ScrV viewWithTag:kTag_SummaryView];
    UIView *ProffView=  [[UIView alloc]init];
    if([u_summary isEqualToString:@""] || [u_summary isEqualToString:@"<null>"]){
        
        ProffView.frame = CGRectMake(editpVw.frame.origin.x, editpVw.frame.origin.y+editpVw.frame.size.height+5, editpVw.frame.size.width, 20);
    }
    else{
        ProffView.frame =  CGRectMake(SummaryVW.frame.origin.x, SummaryVW.frame.origin.y+SummaryVW.frame.size.height+5, SummaryVW.frame.size.width, 20);
        
    }
    ProffView.tag= kTag_ProffView;
    [ScrV addSubview:ProffView];
    
    UILabel *ProfLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ProffView.frame.size.width, 20)];
    ProfLbl.text = @"Professional Experience";
    ProfLbl.font= [UIFont systemFontOfSize:16.0f];
    [ProffView addSubview:ProfLbl];
    
    NSMutableArray*associationArr = nil;
    // = [[NSMutableArray alloc]init];
    associationArr = [resposeCode objectForKey:@"association"];
    //NSLog(@"%@",associationArr);
    if([associationArr count] && [associationArr isKindOfClass:[NSMutableArray class]]){
        UIView *assoView;
        int count=0;
        for(int i =0; i<associationArr.count; i++)
        {
            assoView = [[UIView alloc]init];
            assoView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
            assoView.frame = CGRectMake(0, ProfLbl.frame.origin.y+2 + ProfLbl.frame.size.height +  count, [UIScreen mainScreen].bounds.size.width-ProffView.frame.origin.x*2, 73);
            
            [ProffView addSubview:assoView];
            UILabel *lblFname = [[UILabel alloc]initWithFrame:CGRectMake(42, 8, 255, 21)];
            lblFname.font = [UIFont systemFontOfSize:14.0f];
            lblFname.backgroundColor = [UIColor clearColor];
            lblFname.textColor = [UIColor blackColor];
            [assoView addSubview:lblFname];
            
            UILabel *lblcomp = [[UILabel alloc]initWithFrame:CGRectMake(42, lblFname.frame.size.height + lblFname.frame.origin.y + 0.2, 255, 21)];
            lblcomp .font = [UIFont systemFontOfSize:14.0f];
            lblcomp.backgroundColor = [UIColor clearColor];
            lblcomp .textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
            
            [assoView addSubview:lblcomp];
            UILabel *lblAssoTime = [[UILabel alloc]initWithFrame:CGRectMake(42, lblcomp.frame.size.height + lblcomp.frame.origin.y + 0.3, 255, 21)];
            lblAssoTime .font = [UIFont systemFontOfSize:13.0f];
            lblAssoTime.backgroundColor = [UIColor clearColor];
            lblAssoTime.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
            
            [assoView addSubview:lblAssoTime];
            
            UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, lblAssoTime.frame.size.height + lblAssoTime.frame.origin.y , assoView.frame.size.width-10, 0.3)];
            
            lineImg.image = [UIImage imageNamed:@"lines.png"];
            [assoView addSubview:lineImg];
            
            UIImageView *assImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 30, 30)];
            assImg.image = [UIImage imageNamed:@"exp_default.png"];
            [assoView addSubview:assImg];
            
            NSDictionary*assoDic1=[associationArr objectAtIndex:0];
            
            if(assoDic1 && [assoDic1 isKindOfClass:[NSDictionary class]])
            {
                
                NSString*currasso_id =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"association_id"]];
                NSLog(@"association_id= %@",currasso_id);
                NSString*currasso_name =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"association_name"]];
                // NSLog(@"currassociation_name= %@",currasso_name);
                NSMutableString *currfinal_asoName = [currasso_name mutableCopy];
                [currfinal_asoName enumerateSubstringsInRange:NSMakeRange(0, [currfinal_asoName length])
                                                      options:NSStringEnumerationByWords
                                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                       [currfinal_asoName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                        withString:[[substring substringToIndex:1] uppercaseString]];
                                                   }];
                if(currfinal_asoName!= (id)[NSNull null])
                    lblCompany.text=currfinal_asoName;
                else
                    lblCompany.text=@"";
                NSString*currasso_desc =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"description"]];
                NSLog(@"currassociation_Desc= %@",currasso_desc);
                NSString*currasso_endDate =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"end_date"]];
                NSString*currasso_StartDate =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"start_date"]];
                NSString*currasso_endMonth =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"end_month"]];
                NSString*currasso_StartMonth =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"start_month"]];
                NSString*currasso_loc =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"location"]];
                // NSLog(@"location= %@",currasso_loc);
                NSMutableString *currfinal_asoloc = [currasso_loc mutableCopy];
                [currfinal_asoloc enumerateSubstringsInRange:NSMakeRange(0, [currfinal_asoloc length])
                                                     options:NSStringEnumerationByWords
                                                  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                      [currfinal_asoloc replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                                  }];
                NSString*assoStr =@"";
                if(currasso_StartDate.length!=0){
                    if(currasso_endDate.length!=0){
                        if ([currasso_endDate isEqualToString:@" "]){
                            assoStr = @"";
                        }
                        else{
                            assoStr = [[[[[[currasso_StartMonth stringByAppendingString:@" "]stringByAppendingString:currasso_StartDate]stringByAppendingString:@"-"]stringByAppendingString:currasso_endMonth]stringByAppendingString:@" "]stringByAppendingString:currasso_endDate];
                        }
                    }
                    else{
                        assoStr = [[currasso_StartMonth stringByAppendingString:@" "]stringByAppendingString:currasso_StartDate];
                    }
                }
                else {
                    if(currasso_endDate.length!=0){
                        if ([currasso_endDate isEqualToString:@" "]){
                            assoStr = @"";
                        }
                        else {
                            assoStr = currasso_endDate;
                        }
                    }
                }
                if(currfinal_asoloc.length!=0){
                    if(assoStr.length!=0){
                        lblPeriod.text = [[assoStr stringByAppendingString:@", "] stringByAppendingString:currfinal_asoloc];
                    }
                    else{
                        lblPeriod.text = currfinal_asoloc;
                    }
                }
                else{
                    lblPeriod.text = assoStr;
                }
                [lblPeriod sizeToFit];
                NSString*currasso_pos =[NSString stringWithFormat:@"%@",[assoDic1 objectForKey:@"position"]];
                // NSLog(@"currassociation_position= %@",currasso_pos);
                NSMutableString *currfinal_asopos = [currasso_pos mutableCopy];
                [currfinal_asopos enumerateSubstringsInRange:NSMakeRange(0, [currfinal_asopos length])
                                                     options:NSStringEnumerationByWords
                                                  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                      [currfinal_asopos replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                                  }];
                if(currfinal_asopos!= (id)[NSNull null])
                    lblProfile.text=currfinal_asopos;
                else
                    lblProfile.text=@"";
            }
            NSDictionary*assoDic=[associationArr objectAtIndex:i];
            if(assoDic && [assoDic isKindOfClass:[NSDictionary class]])
            {
                //                    "association_pic" = "<null>";
                //                    "education_pic" = "<null>";
                
                NSString*asso_id =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"association_id"]];
                NSLog(@"association_id= %@",asso_id);
                NSString*asso_name =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"association_name"]];
                //NSLog(@"association_name= %@",asso_name);
                NSMutableString *final_asoName = [asso_name mutableCopy];
                [final_asoName enumerateSubstringsInRange:NSMakeRange(0, [final_asoName length])
                                                  options:NSStringEnumerationByWords
                                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                   [final_asoName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                               }];
                if(final_asoName!= (id)[NSNull null])
                    lblcomp.text=final_asoName;
                else
                    lblcomp.text=@"";
                NSString*asso_desc =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"description"]];
                NSLog(@"association_Desc= %@",asso_desc);
                NSString*asso_endDate =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"end_date"]];
                //NSLog(@"association_endDate= %@",asso_endDate);
                NSString*asso_StartDate =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"start_date"]];
                // NSLog(@"association_StartDate= %@",asso_StartDate);
                NSString*asso_endMonth =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"end_month"]];
                NSString*asso_StartMonth =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"start_month"]];
                NSString*asso_loc =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"location"]];
                //NSLog(@"location= %@",asso_loc);
                NSMutableString *final_asoloc = [asso_loc mutableCopy];
                [final_asoloc enumerateSubstringsInRange:NSMakeRange(0, [final_asoloc length])
                                                 options:NSStringEnumerationByWords
                                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                  [final_asoloc replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                              withString:[[substring substringToIndex:1] uppercaseString]];
                                              }];
                
                NSString*assoStr =@"";
                if(asso_StartDate.length!=0){
                    if(asso_endDate.length!=0){
                        if ([asso_endDate isEqualToString:@" "]){
                            assoStr = @"";
                        }
                        else{
                            assoStr = [[[[[[asso_StartMonth stringByAppendingString:@" "]stringByAppendingString:asso_StartDate]stringByAppendingString:@"-"]stringByAppendingString:asso_endMonth]stringByAppendingString:@" "]stringByAppendingString:asso_endDate];
                        }
                    }
                    else{
                        assoStr = [[asso_StartMonth stringByAppendingString:@" "]stringByAppendingString:asso_StartDate];
                    }
                }
                else {
                    if(asso_endDate.length!=0){
                        if ([asso_endDate isEqualToString:@" "]){
                            assoStr = @"";
                        }
                        else {
                            assoStr = asso_endDate;
                        }
                    }
                }
                if(final_asoloc.length!=0){
                    if(assoStr.length!=0){
                        lblAssoTime.text = [[assoStr stringByAppendingString:@", "] stringByAppendingString:final_asoloc];
                    }
                    else{
                        lblAssoTime.text = final_asoloc;
                    }
                }
                
                else{
                    lblAssoTime.text = assoStr;
                }
                [lblAssoTime sizeToFit];
                NSString*asso_pos =[NSString stringWithFormat:@"%@",[assoDic objectForKey:@"position"]];
                //NSLog(@"association_position= %@",asso_pos);
                
                NSMutableString *final_asopos = [asso_pos mutableCopy];
                [final_asopos enumerateSubstringsInRange:NSMakeRange(0, [final_asopos length])
                                                 options:NSStringEnumerationByWords
                                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                  [final_asopos replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                              withString:[[substring substringToIndex:1] uppercaseString]];
                                              }];
                
                if(final_asopos!= (id)[NSNull null])
                    lblFname.text=final_asopos;
                
                else
                    lblFname.text=@"";
                count =count+73;
            }
        }
        CGRect newProffVw = ProffView.frame;
        newProffVw.size.height = assoView.frame.size.height+assoView.frame.origin.y+2;
        ProffView.frame = newProffVw;
    }
}

-(void)Education{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *EditPVw = (UIView *)[ScrV viewWithTag:kTag_EditProfileVw];
    UIView *SummaryVW = (UIView *)[ScrV viewWithTag:kTag_SummaryView];
    UIView *ProffView = (UIView *)[ScrV viewWithTag:kTag_ProffView];
    UIView *eduView = [[UIView alloc]init];
    if([u_association isEqualToString:@""] || ([u_association isEqualToString:@"<null>"] && [u_summary isEqualToString:@""])||[u_summary isEqualToString:@"<null>"])
    {
        eduView.frame = CGRectMake(EditPVw.frame.origin.x, EditPVw.frame.origin.y+EditPVw.frame.size.height+5, EditPVw.frame.size.width, 20);
    }
    else if([u_association isEqualToString:@""] || [u_association isEqualToString:@"<null>"])
    {
        eduView.frame = CGRectMake(SummaryVW.frame.origin.x, SummaryVW.frame.origin.y+SummaryVW.frame.size.height+5, SummaryVW.frame.size.width, 20);
    }
    else if([u_summary isEqualToString:@""]||[u_summary isEqualToString:@"<null>"])
    {
        eduView.frame = CGRectMake(ProffView.frame.origin.x, ProffView.frame.origin.y+ProffView.frame.size.height+5, ProffView.frame.size.width, 20);
    }
    else{
        eduView.frame = CGRectMake(ProffView.frame.origin.x, ProffView.frame.origin.y+ProffView.frame.size.height+5, ProffView.frame.size.width, 20);
    }
    [ScrV addSubview:eduView];
    eduLbl1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, eduView.frame.size.width, 20)];
    eduLbl1.text = @"Education";
    eduLbl1.textColor = [UIColor blackColor];
    eduLbl1.font = [UIFont systemFontOfSize:16.0f];
    [eduView addSubview: eduLbl1];
    NSMutableArray*eduArr = nil;
    // [[NSMutableArray alloc]init];
    eduArr = [resposeCode objectForKey:@"education"];
    // NSLog(@"%@",eduArr);
    // NSLog(@"%@",eduArr);
    if([eduArr count] && [eduArr isKindOfClass:[NSMutableArray class]]){
        UIView *educationView;
        int count=0;
        for(int i =0; i<eduArr.count; i++)
        {
            educationView = [[UIView alloc]init];
            educationView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
            educationView.frame =  CGRectMake(0, eduLbl1.frame.origin.y+2 + eduLbl1.frame.size.height + count, [UIScreen mainScreen].bounds.size.width-EditPVw.frame.origin.x*2, 73);
            educationView.tag= kTag_educationView;
            [eduView addSubview:educationView];
            UILabel *schoolLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, 8, 255, 21)];
            schoolLbl.font = [UIFont systemFontOfSize:14.0f];
            schoolLbl.textColor = [UIColor blackColor];
            schoolLbl.backgroundColor = [UIColor clearColor];
            [educationView addSubview:schoolLbl];
            UILabel *degLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, schoolLbl.frame.size.height + schoolLbl.frame.origin.y + 0.3, 255, 21)];
            degLbl .font = [UIFont systemFontOfSize:13.0f];
            degLbl .textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
            degLbl.backgroundColor = [UIColor clearColor];
            [educationView addSubview:degLbl];
            UILabel *eduTmeLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, degLbl.frame.size.height + degLbl.frame.origin.y + 0.3, 255, 21)];
            eduTmeLbl .font = [UIFont systemFontOfSize:13.0f];
            eduTmeLbl.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
            eduTmeLbl.backgroundColor = [UIColor clearColor];
            [educationView addSubview:eduTmeLbl];
            UIImageView *edulineImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, eduTmeLbl.frame.size.height + eduTmeLbl.frame.origin.y+0.3 , educationView.frame.size.width-10, 1)];
            edulineImg.image = [UIImage imageNamed:@"lines.png"];
            edulineImg.tag = kTag_edulineImg;
            [educationView addSubview:edulineImg];
            UIImageView *eduDefaultImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 30, 30)];
            eduDefaultImg.image = [UIImage imageNamed:@"edu_default.png"];
            [educationView addSubview:eduDefaultImg];
            NSDictionary*eduDic=[eduArr objectAtIndex:i];
            if(eduDic && [eduDic isKindOfClass:[NSDictionary class]])
            {
                NSString*edu_id =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"education_id"]];
                NSLog(@"edu_id= %@",edu_id);
                NSString*edu_name =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"school"]];
                //NSLog(@"edu_name= %@",edu_name);
                NSMutableString *final_eduName = [edu_name mutableCopy];
                [final_eduName enumerateSubstringsInRange:NSMakeRange(0, [final_eduName length])
                                                  options:NSStringEnumerationByWords
                                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                   [final_eduName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                               }];
                if(final_eduName!= (id)[NSNull null])
                    schoolLbl.text=final_eduName;
                else
                    schoolLbl.text=@"";
                NSString*edu_desc =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"description"]];
                NSLog(@"edu_Desc= %@",edu_desc);
                NSString*edu_endDate =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"end_date"]];
                // NSLog(@"edu_endDate= %@",edu_endDate);
                NSString*edu_StartDate =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"start_date"]];
                NSLog(@"edu_StartDate= %@",edu_StartDate);
                NSString*eduStr =@"";
                if(edu_endDate.length!=0){
                    eduStr = edu_endDate;
                }
                NSString* currPur = [NSString stringWithFormat:@"%@",[eduDic objectForKey:@"current_pursuing"]];
                if ([currPur isEqualToString:@"1"]) {
                    eduTmeLbl.text = @"Currently Pursuing";
                }
                else{
                    if ([edu_endDate isEqualToString:@"0"]) {
                        eduTmeLbl.text = @"";
                    }
                    else{
                        eduTmeLbl.text = eduStr;
                    }
                }
                NSString*edu_study =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"field_of_study"]];
                // NSLog(@"edu_study= %@",edu_study);
                NSMutableString *final_eduStudy = [edu_study mutableCopy];
                [final_eduStudy enumerateSubstringsInRange:NSMakeRange(0, [final_eduStudy length])
                                                   options:NSStringEnumerationByWords
                                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                    [final_eduStudy replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                  withString:[[substring substringToIndex:1] uppercaseString]];
                                                }];
                NSString*edu_deg =[NSString stringWithFormat:@"%@",[eduDic objectForKey:@"degree"]];
                //NSLog(@"education_deg= %@",edu_deg);
                NSMutableString *final_edudeg = [edu_deg mutableCopy];
                [final_edudeg enumerateSubstringsInRange:NSMakeRange(0, [final_edudeg length])
                                                 options:NSStringEnumerationByWords
                                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                  [final_edudeg replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                              withString:[[substring substringToIndex:1] uppercaseString]];
                                              }];
                
                if(final_edudeg!= (id)[NSNull null])
                    degLbl.text=final_edudeg;
                else
                    degLbl.text=@"";
                count =count+73;
            }
        }
        CGRect newframe = eduView.frame;
        //NSLog(@"%f %f",eduView.frame.origin.y, eduView.frame.size.height);
        newframe.size.height = educationView.frame.origin.y+ educationView.frame.size.height+5;
        eduView.frame = newframe;
        // NSLog(@"%f %f",eduView.frame.origin.y, eduView.frame.size.height);
        eduView.tag = kTag_EDUVIEW;
    }
}

#pragma  mark Basic Information
-(void)BasicInfo{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *EduVw = (UIView *)[ScrV viewWithTag:kTag_EDUVIEW];
    UIView *EditPVw = (UIView *)[ScrV viewWithTag:kTag_EditProfileVw];
    UIView *SummaryVW = (UIView *)[ScrV viewWithTag:kTag_SummaryView];
    UIView *ProffView = (UIView *)[ScrV viewWithTag:kTag_ProffView];
    UIView *BasicinfoView = [[UIView alloc]init];
    if(([u_association isEqualToString:@""] || (([u_association isEqualToString:@"<null>"]) && ([u_summary isEqualToString:@""]||[u_summary isEqualToString:@"<null>"]) && ([u_education isEqualToString:@""]||[u_education isEqualToString:@"<null>"])) ))
    {
        BasicinfoView.frame = CGRectMake(EditPVw.frame.origin.x, EditPVw.frame.origin.y+EditPVw.frame.size.height+5, EditPVw.frame.size.width, 20);
    }
    else if(([u_association isEqualToString:@""] || [u_association isEqualToString:@"<null>"] )&& ([u_education isEqualToString:@""] || [u_education isEqualToString:@"<null>"] ) )
    {
        BasicinfoView.frame = CGRectMake(SummaryVW.frame.origin.x, SummaryVW.frame.origin.y+SummaryVW.frame.size.height+5, SummaryVW.frame.size.width, 20);
    }
    else if([u_education isEqualToString:@""] || [u_education isEqualToString:@"<null>"] )
    {
        BasicinfoView.frame = CGRectMake(ProffView.frame.origin.x, ProffView.frame.origin.y+ProffView.frame.size.height+5, ProffView.frame.size.width, 20);
    }
    else{
        BasicinfoView.frame = CGRectMake(EduVw.frame.origin.x, EduVw.frame.origin.y+EduVw.frame.size.height+5, EduVw.frame.size.width, 20);
    }
    // NSLog(@"%f ",BasicinfoView.frame.origin.y);
    [ScrV addSubview:BasicinfoView];
    UILabel *BasicInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, BasicinfoView.frame.size.width, 20)];
    BasicInfoLbl.text = @"Basic Information";
    BasicInfoLbl.font= [UIFont systemFontOfSize:16.0f];
    [BasicinfoView addSubview:BasicInfoLbl];
    UIView *BasicInfoContainer = [[UIView alloc]initWithFrame:CGRectMake(BasicInfoLbl.frame.origin.x, BasicInfoLbl.frame.origin.y+BasicInfoLbl.frame.size.height+5, BasicInfoLbl.frame.size.width, 20)];
    BasicInfoContainer.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    [BasicinfoView addSubview:BasicInfoContainer];
    u_interest = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"interest"]?[resposeCode  objectForKey:@"interest"]:@""];
    if ([u_interest isEqualToString:@""] || [u_interest isEqualToString:@"<null>"]) {
    }
    else {
        InterestLbl = [[UILabel alloc]initWithFrame:CGRectMake(BasicinfoView.frame.origin.x, 10, BasicinfoView.frame.size.width, 20)];
        InterestLbl.text = @"Interests";
        InterestLbl.font= [UIFont systemFontOfSize:14.0f];
        [BasicInfoContainer addSubview:InterestLbl];
        InterestEarnLbl = [[UILabel alloc]initWithFrame:CGRectMake(InterestLbl.frame.origin.x, InterestLbl.frame.origin.y +InterestLbl.frame.size.height,BasicinfoView.frame.size.width-10, 20)];
        // NSLog(@"%f",InterestEarnLbl.frame.size.width);
        [BasicInfoContainer addSubview:InterestEarnLbl];
        // NSLog(@"%f",InterestEarnLbl.frame.size.width);
        NSMutableArray*interestArr = nil;
        //= [[NSMutableArray alloc]init];
        interestArr = [resposeCode objectForKey:@"interest"];
        // NSLog(@"%@",interestArr);
        if([interestArr count] && [interestArr isKindOfClass:[NSMutableArray class]]){
            NSString*intString =@"";
            NSMutableString *final_intName;
            for(int i =0; i<interestArr.count; i++)
            {
                NSDictionary*interstDic=[interestArr objectAtIndex:i];
                if(interstDic && [interstDic isKindOfClass:[NSDictionary class]])
                {
                    NSString*int_id =[NSString stringWithFormat:@"%@",[interstDic objectForKey:@"interest_id"]];
                    NSLog(@"interest_id= %@",int_id);
                    NSString*int_name =[NSString stringWithFormat:@"%@",[interstDic objectForKey:@"interest_name"]];
                    // NSLog(@"interest_name= %@",int_name);
                    final_intName = [int_name mutableCopy];
                    [final_intName enumerateSubstringsInRange:NSMakeRange(0, [final_intName length])
                                                      options:NSStringEnumerationByWords
                                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                       [final_intName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                    withString:[[substring substringToIndex:1] uppercaseString]];
                                                   }];
                    
                    NSString*st;
                    if(i==(interestArr.count -1)){
                        st = final_intName;
                    }
                    else {
                        
                        st = [final_intName stringByAppendingString:@", "];
                    }
                    intString = [intString stringByAppendingString:st];
                    
                    if(intString!= (id)[NSNull null])
                        InterestEarnLbl.text=intString;
                    else
                        InterestEarnLbl.text=@"";
                    [[InterestEarnLbl layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
                    InterestEarnLbl.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
                    InterestEarnLbl.font = [UIFont systemFontOfSize:13.0f];
                    InterestEarnLbl.numberOfLines = 0;
                    InterestEarnLbl.lineBreakMode = NSLineBreakByWordWrapping;
                }
            }
        }
        [InterestEarnLbl sizeToFit];
        horizontalLine = [[UILabel alloc]initWithFrame:CGRectMake(InterestLbl.frame.origin.x, InterestEarnLbl.frame.origin.y+InterestEarnLbl.frame.size.height+15, BasicInfoContainer.frame.size.width- InterestLbl.frame.origin.x*2, 1)];
        horizontalLine.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        [BasicInfoContainer addSubview:horizontalLine];
    }
    u_speciality = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"speciality"]?[resposeCode  objectForKey:@"speciality"]:@""];
    UILabel *skillLbl;
    if ([u_speciality isEqualToString:@""] || [u_speciality isEqualToString:@"<null>"]) {
    }
    else {
        skillLbl = [[UILabel alloc]initWithFrame:CGRectMake(assoImg.frame.origin.x, horizontalLine.frame.origin.y+horizontalLine.frame.size.height+15, BasicInfoContainer.frame.size.width, 20)];
        skillLbl.text = @"Specialization";
        skillLbl.font= [UIFont systemFontOfSize:14.0f];
        [BasicInfoContainer addSubview:skillLbl];
        DocAllSkillLbl  = [[UILabel alloc]initWithFrame:CGRectMake(skillLbl.frame.origin.x, skillLbl.frame.origin.y +skillLbl.frame.size.height,BasicinfoView.frame.size.width-10, 20)];
        // NSLog(@"%f",DocAllSkillLbl.frame.size.width);
        DocAllSkillLbl.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
        DocAllSkillLbl.font = [UIFont systemFontOfSize:13.0f];
        DocAllSkillLbl.textAlignment = NSTextAlignmentLeft;
        [BasicInfoContainer addSubview:DocAllSkillLbl];
        NSMutableArray*spclArr = nil;
        //= [[NSMutableArray alloc]init];
        spclArr = [resposeCode objectForKey:@"speciality"];
        // NSLog(@"%@",spclArr);
        if([spclArr count] && [spclArr isKindOfClass:[NSMutableArray class]]){
            NSString*firstString =@"";
            NSMutableString *final_spclName;
            for(int i =0; i<spclArr.count; i++)
            {
                NSDictionary*spclDic=[spclArr objectAtIndex:i];
                if(spclDic && [spclDic isKindOfClass:[NSDictionary class]])
                {
                    NSString*spcl_id =[NSString stringWithFormat:@"%@",[spclDic objectForKey:@"speciality_id"]];
                    NSLog(@"spcl_id= %@",spcl_id);
                    NSString*spcl_name =[NSString stringWithFormat:@"%@",[spclDic objectForKey:@"speciality_name"]];
                    // NSLog(@"speciality_name= %@",spcl_name);
                    final_spclName = [spcl_name mutableCopy];
                    [final_spclName enumerateSubstringsInRange:NSMakeRange(0, [final_spclName length])
                                                       options:NSStringEnumerationByWords
                                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                        [final_spclName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                                    }];
                }
                NSString*st;
                if(i==(spclArr.count -1)){
                    st = final_spclName;
                }
                else {
                    st = [final_spclName stringByAppendingString:@", "];
                }
                firstString = [firstString stringByAppendingString:st];
                
                if(firstString!= (id)[NSNull null])
                    DocAllSkillLbl.text=firstString;
                else
                    DocAllSkillLbl.text=@"";
                [[DocAllSkillLbl layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
                DocAllSkillLbl.numberOfLines = 0;
                DocAllSkillLbl.lineBreakMode = NSLineBreakByWordWrapping;
            }
        }
    }
    [DocAllSkillLbl sizeToFit];
    DocAllSkillLbl.tag = kTag_DocAllSkillLbL;
    if ([u_speciality isEqualToString:@""] || [u_speciality isEqualToString:@"<null>"]) {
    }
    else {
        horizontalLine = [[UILabel alloc]initWithFrame:CGRectMake(skillLbl.frame.origin.x, DocAllSkillLbl.frame.origin.y+DocAllSkillLbl.frame.size.height+15, BasicInfoContainer.frame.size.width- skillLbl.frame.origin.x*2, 1)];
        
        horizontalLine.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        [BasicInfoContainer addSubview:horizontalLine];
    }
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *u_id=[userpref objectForKey:userId];
    if(Frndvalue == 1)
    {
        
        UIView *PersonalViewHolder = [[UIView alloc]initWithFrame:CGRectMake(0, horizontalLine.frame.origin.y+horizontalLine.frame.size.height+15, BasicInfoContainer.frame.size.width, 20)];
        PersonalViewHolder.tag= kTag_PersonalViewHolder;
        [BasicInfoContainer addSubview:PersonalViewHolder];
        UILabel *PersonalInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PersonalViewHolder.frame.size.width, 20)];
        PersonalInfoLbl.text = @"Personal Information";
        PersonalInfoLbl.font= [UIFont systemFontOfSize:14.0f];
        [PersonalViewHolder addSubview:PersonalInfoLbl];
        u_country = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        u_city = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        // NSString *city_Upper = [u_city capitalizedString];
        u_state = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        u_countryCode = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        
        u_mobileNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        u_dob = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"dob"]?[resposeCode  objectForKey:@"dob"]:@""];
        
        UIButton *callFrndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        callFrndBtn.frame = CGRectMake(0, 0, PersonalViewHolder.frame.size.width, 40);
        [callFrndBtn setTitle:[NSString stringWithFormat:@"Call %@",u_fName] forState:UIControlStateNormal];
        [callFrndBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        callFrndBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        callFrndBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [callFrndBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0]];
        [PersonalViewHolder addSubview:callFrndBtn];
        
        [callFrndBtn addTarget:self action:@selector(didPressCallBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect PersonalViewHolderNewFrame = PersonalViewHolder.frame;
        PersonalViewHolderNewFrame.size.height = callFrndBtn.frame.origin.y+ callFrndBtn.frame.size.height;
        PersonalViewHolder.frame = PersonalViewHolderNewFrame;
        CGRect newframeBasicInfoCont = BasicInfoContainer.frame;
        newframeBasicInfoCont.size.height = PersonalViewHolder.frame.origin.y+ PersonalViewHolder.frame.size.height;
        BasicInfoContainer.frame = newframeBasicInfoCont;
        CGRect newframeBasicInfo = BasicinfoView.frame;
        newframeBasicInfo.size.height = BasicInfoContainer.frame.origin.y+ BasicInfoContainer.frame.size.height;
        BasicinfoView.frame = newframeBasicInfo;
        BasicinfoView.tag = kTag_BasicinfoView;
    }
    else if ((Frndvalue == 9)|| (Frndvalue == 8) || (Frndvalue == 0 && ![uId isEqualToString:u_id])) {
        CGRect newframeBasicInfoCont = BasicInfoContainer.frame;
        UILabel *DocAllSkillLbL = (UILabel*)[ScrV viewWithTag:kTag_DocAllSkillLbL];
        newframeBasicInfoCont.size.height = DocAllSkillLbL.frame.origin.y+ DocAllSkillLbL.frame.size.height+10;
        BasicInfoContainer.frame = newframeBasicInfoCont;
        CGRect newframeBasicInfo = BasicinfoView.frame;
        newframeBasicInfo.size.height = BasicInfoContainer.frame.origin.y+ BasicInfoContainer.frame.size.height;
        BasicinfoView.frame = newframeBasicInfo;
        BasicinfoView.tag = kTag_BasicinfoView;
    }
    else {
        UIView *PersonalViewHolder = [[UIView alloc]initWithFrame:CGRectMake(assoImg.frame.origin.x, horizontalLine.frame.origin.y+horizontalLine.frame.size.height+15, BasicInfoContainer.frame.size.width, 20)];
        PersonalViewHolder.tag= kTag_PersonalViewHolder;
        [BasicInfoContainer addSubview:PersonalViewHolder];
        UILabel *PersonalInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PersonalViewHolder.frame.size.width, 20)];
        PersonalInfoLbl.text = @"Personal Information";
        PersonalInfoLbl.font= [UIFont systemFontOfSize:14.0f];
        [PersonalViewHolder addSubview:PersonalInfoLbl];
        u_country = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        u_city = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        NSString *city_Upper = [u_city capitalizedString];
        u_state = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        u_mobileNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        u_countryCode = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        u_dob = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"dob"]?[resposeCode  objectForKey:@"dob"]:@""];
        UIImageView *BdayImg;
        UILabel *BdayLbl;
        UILabel *BdaydateLbl;
        if ([u_dob isEqualToString:@""] || [u_dob isEqualToString:@"<null>"] || [u_dob isEqualToString:@"0000-00-00"])
        {
            //if Birthday not available, this portion should not be show
        }
        else {
            BdayImg = [[UIImageView alloc]initWithFrame:CGRectMake(PersonalInfoLbl.frame.origin.x, PersonalInfoLbl.frame.origin.y + PersonalInfoLbl.frame.size.height +10, 15, 18)];
            BdayImg.tag = kTag_BdayImg;
            BdayImg.image= [UIImage imageNamed:@"birthday.png"];
            [PersonalViewHolder addSubview:BdayImg];
            BdayLbl = [[UILabel alloc]initWithFrame:CGRectMake(BdayImg.frame.origin.x*2 + BdayImg.frame.size.width+2, BdayImg.frame.origin.y, 100, 20)];
            BdayLbl.text = @"Birthday";
            BdayLbl.font= [UIFont systemFontOfSize:13.0f];
            BdayLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:BdayLbl];
            BdaydateLbl = [[UILabel alloc]initWithFrame:CGRectMake(BdayLbl.frame.origin.x + BdayLbl.frame.size.width, BdayLbl.frame.origin.y, 180, 20)];
            if(u_dob!= (id)[NSNull null])
                BdaydateLbl.text=u_dob;
            else
                BdaydateLbl.text=@"";
            BdaydateLbl.font= [UIFont systemFontOfSize:13.0f];
            BdaydateLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:BdaydateLbl];
        }
        if ([u_dob isEqualToString:@""] || [u_dob isEqualToString:@"<null>"] || [u_dob isEqualToString:@"0000-00-00"])
        {
            if ([u_mobileNo isEqualToString:@""] || [u_mobileNo isEqualToString:@"<null>"] )
            {
                UIImageView *EmailImg = [[UIImageView alloc]initWithFrame:CGRectMake(PersonalInfoLbl.frame.origin.x, PersonalInfoLbl.frame.origin.y + PersonalInfoLbl.frame.size.height +14, 15, 15)];
                EmailImg.image= [UIImage imageNamed:@"email.png"];
                EmailImg.tag = kTag_emailImg;
                [PersonalViewHolder addSubview:EmailImg];
                UILabel *EmailLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailImg.frame.origin.x*2 + EmailImg.frame.size.width+2, EmailImg.frame.origin.y, 100, 20)];
                EmailLbl.text = @"Email Id";
                EmailLbl.font= [UIFont systemFontOfSize:13.0f];
                EmailLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
                [PersonalViewHolder addSubview:EmailLbl];
                UILabel *EmailIDLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailLbl.frame.origin.x + EmailLbl.frame.size.width, EmailLbl.frame.origin.y, 180, 20)];
                if(u_email!= (id)[NSNull null])
                    EmailIDLbl.text=u_email;
                else
                    EmailIDLbl.text=@"";
                EmailIDLbl.font= [UIFont systemFontOfSize:13.0f];
                EmailIDLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
                [PersonalViewHolder addSubview:EmailIDLbl];
            }
            else{
                UIImageView *ContImg = [[UIImageView alloc]initWithFrame:CGRectMake(PersonalInfoLbl.frame.origin.x, PersonalInfoLbl.frame.origin.y + PersonalInfoLbl.frame.size.height +14, 15, 15)];
                ContImg.image= [UIImage imageNamed:@"contact.png"];
                ContImg.tag = kTag_ContImg;
                [PersonalViewHolder addSubview:ContImg];
                UILabel *ContLbl = [[UILabel alloc]initWithFrame:CGRectMake(ContImg.frame.origin.x*2 + ContImg.frame.size.width+2, ContImg.frame.origin.y, 100, 20)];
                ContLbl.tag = kTag_Contlbl;
                ContLbl.text = @"Contact";
                ContLbl.font= [UIFont systemFontOfSize:13.0f];
                ContLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
                [PersonalViewHolder addSubview:ContLbl];
                UILabel *ContNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(ContLbl.frame.origin.x + ContLbl.frame.size.width, ContLbl.frame.origin.y, 180, 20)];
                ContNoLbl.tag = kTag_ContNoLbl;
                if(u_mobileNo!= (id)[NSNull null])
                    ContNoLbl.text=u_mobileNo;
                else
                    ContNoLbl.text=@"";
                ContNoLbl.font= [UIFont systemFontOfSize:13.0f];
                ContNoLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
                [PersonalViewHolder addSubview:ContNoLbl];
            }
        }
        else{
            UIImageView *ContImg = [[UIImageView alloc]initWithFrame:CGRectMake(BdayImg.frame.origin.x, BdayImg.frame.origin.y + BdayImg.frame.size.height +14, 15,15)];
            ContImg.tag = kTag_ContImg;
            ContImg.image= [UIImage imageNamed:@"contact.png"];
            [PersonalViewHolder addSubview:ContImg];
            UILabel *ContLbl = [[UILabel alloc]initWithFrame:CGRectMake(ContImg.frame.origin.x*2 + ContImg.frame.size.width+2, ContImg.frame.origin.y, 100, 20)];
            ContLbl.tag = kTag_Contlbl;
            ContLbl.text = @"Contact";
            ContLbl.font= [UIFont systemFontOfSize:13.0f];
            ContLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:ContLbl];
            UILabel *ContNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(ContLbl.frame.origin.x + ContLbl.frame.size.width, ContLbl.frame.origin.y, 180, 20)];
            ContNoLbl.tag = kTag_ContNoLbl;
            if(u_mobileNo!= (id)[NSNull null])
                ContNoLbl.text=u_mobileNo;
            else
                ContNoLbl.text=@"";
            ContNoLbl.font= [UIFont systemFontOfSize:13.0f];
            ContNoLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:ContNoLbl];
        }
        if ([u_mobileNo isEqualToString:@""] || [u_mobileNo isEqualToString:@"<null>"] )
        {
            UIImageView *EmailImg = [[UIImageView alloc]initWithFrame:CGRectMake(PersonalInfoLbl.frame.origin.x, PersonalInfoLbl.frame.origin.y + PersonalInfoLbl.frame.size.height +14, 15, 15)];
            EmailImg.image= [UIImage imageNamed:@"email.png"];
            EmailImg.tag = kTag_emailImg;
            [PersonalViewHolder addSubview:EmailImg];
            UILabel *EmailLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailImg.frame.origin.x*2 + EmailImg.frame.size.width+2, EmailImg.frame.origin.y, 100, 20)];
            EmailLbl.text = @"Email Id";
            EmailLbl.font= [UIFont systemFontOfSize:13.0f];
            EmailLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:EmailLbl];
            UILabel *EmailIDLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailLbl.frame.origin.x + EmailLbl.frame.size.width, EmailLbl.frame.origin.y, 190, 20)];
            if(u_email!= (id)[NSNull null])
                EmailIDLbl.text=u_email;
            else
                EmailIDLbl.text=@"";
            EmailIDLbl.font= [UIFont systemFontOfSize:13.0f];
            EmailIDLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:EmailIDLbl];
        }
        else
        {
            UIImageView *ContImg = (UIImageView*)[self.view viewWithTag:kTag_ContImg];
            UIImageView *EmailImg = [[UIImageView alloc]initWithFrame:CGRectMake(ContImg.frame.origin.x, ContImg.frame.origin.y + ContImg.frame.size.height +14, 15, 15)];
            EmailImg.image= [UIImage imageNamed:@"email.png"];
            EmailImg.tag = kTag_emailImg;
            [PersonalViewHolder addSubview:EmailImg];
            UILabel *EmailLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailImg.frame.origin.x*2 + EmailImg.frame.size.width+2, EmailImg.frame.origin.y, 100, 20)];
            EmailLbl.text = @"Email Id";
            EmailLbl.font= [UIFont systemFontOfSize:13.0f];
            EmailLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:EmailLbl];
            UILabel *EmailIDLbl = [[UILabel alloc]initWithFrame:CGRectMake(EmailLbl.frame.origin.x + EmailLbl.frame.size.width, EmailLbl.frame.origin.y, 180, 20)];
            if(u_email!= (id)[NSNull null])
                EmailIDLbl.text=u_email;
            else
                EmailIDLbl.text=@"";
            EmailIDLbl.font= [UIFont systemFontOfSize:13.0f];
            EmailIDLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
            [PersonalViewHolder addSubview:EmailIDLbl];
        }
        UIImageView *EmailImg = (UIImageView*)[self.view viewWithTag:kTag_emailImg];
        UIImageView *CityImg = [[UIImageView alloc]initWithFrame:CGRectMake(EmailImg.frame.origin.x, EmailImg.frame.origin.y + EmailImg.frame.size.height +10, 15, 18)];
        CityImg.image= [UIImage imageNamed:@"city.png"];
        [PersonalViewHolder addSubview:CityImg];
        UILabel *cityLbl = [[UILabel alloc]initWithFrame:CGRectMake(CityImg.frame.origin.x*2 + CityImg.frame.size.width+2, CityImg.frame.origin.y, 100, 20)];
        cityLbl.text = @"Location";
        cityLbl.font= [UIFont systemFontOfSize:13.0f];
        cityLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
        [PersonalViewHolder addSubview:cityLbl];
        UILabel *CityNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(cityLbl.frame.origin.x + cityLbl.frame.size.width, cityLbl.frame.origin.y, 190, 20)];
        if(city_Upper!= (id)[NSNull null])
            CityNameLbl.text= city_Upper;
        else
            CityNameLbl.text =@"";
        CityNameLbl.font= [UIFont systemFontOfSize:13.0f];
        CityNameLbl.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
        [PersonalViewHolder addSubview:CityNameLbl];
        CGRect PersonalViewHolderNewFrame = PersonalViewHolder.frame;
        PersonalViewHolderNewFrame.size.height = CityNameLbl.frame.origin.y+ CityNameLbl.frame.size.height+10;
        PersonalViewHolder.frame = PersonalViewHolderNewFrame;
        CGRect newframeBasicInfoCont = BasicInfoContainer.frame;
        newframeBasicInfoCont.size.height = PersonalViewHolder.frame.origin.y+ PersonalViewHolder.frame.size.height+10;
        BasicInfoContainer.frame = newframeBasicInfoCont;
        CGRect newframeBasicInfo = BasicinfoView.frame;
        newframeBasicInfo.size.height = BasicInfoContainer.frame.origin.y+ BasicInfoContainer.frame.size.height-100;
        BasicinfoView.frame = newframeBasicInfo;
        BasicinfoView.tag = kTag_BasicinfoView;
    }
}

#pragma mark - Chat
-(void)Chat{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIView *BasicInfoV = (UIView *)[ScrV viewWithTag:kTag_BasicinfoView];
    UIView *ChatVW = [[UIView alloc]initWithFrame:CGRectMake(BasicInfoV.frame.origin.x, BasicInfoV.frame.origin.y+BasicInfoV.frame.size.height+5, BasicInfoV.frame.size.width, 42)];
    ChatVW.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    ChatVW.tag = kTag_ChatVw;
    [ScrV addSubview:ChatVW];
    UIView*Chatcontainer = [[UIView alloc]initWithFrame:CGRectMake(ChatVW.frame.size.width/2-60, 0, 120, 42)];
    [ChatVW addSubview:Chatcontainer];
    UIButton*ChatIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ChatIcon.frame = CGRectMake(0, 10, 25, 25);
    [ChatIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
    [Chatcontainer addSubview: ChatIcon];
    UILabel *ChatNowLbl = [[UILabel alloc]initWithFrame:CGRectMake(ChatIcon.frame.origin.x+ChatIcon.frame.size.width+5, 0, 100, 42)];
    ChatNowLbl.text = @"Start Chat";
    ChatNowLbl.textAlignment = NSTextAlignmentLeft;
    ChatNowLbl.textColor= [UIColor whiteColor];
    ChatNowLbl.font = [UIFont systemFontOfSize:18.0f];
    [Chatcontainer addSubview:ChatNowLbl];
}

#pragma mark - scrollVResize
-(void)scrollVResize{
    UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    ScrV.scrollEnabled = YES;
    UIView *ChatVw = (UIView *)[ScrV viewWithTag:kTag_BasicinfoView];
    ScrV.contentSize = CGSizeMake(ScrV.frame.size.width, ChatVw.frame.size.height+ChatVw.frame.origin.y+5+144);
}

#pragma mark - Topbar
-(void)topbar{
    UIView *topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    topbar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    UILabel *titlelbl =  titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 34)];
    if ([AppDelegate appDelegate].isOpenFromProfiletabCntlr == YES) {
        
    }
    else{
        UIButton *backBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBarbtn.frame =CGRectMake(8, 28, 28, 28);
        [backBarbtn addTarget:self action:@selector(Back:) forControlEvents:UIControlEventTouchUpInside];
        
        [backBarbtn setImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal];
        [topbar addSubview:backBarbtn];
        // titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(backBarbtn.frame.size.width+backBarbtn.frame.origin.x+7 , 25, 250, 34)];
    }
    CGRect myImageRect1 = CGRectMake(topbar.frame.size.width -40, 28.0f, 28.0f, 28.0f);
    UIImageView *myImage1 = [[UIImageView alloc] initWithFrame:myImageRect1];
    [myImage1 setImage:[UIImage imageNamed:@"repot.png"]];
    myImage1.contentMode = UIViewContentModeScaleAspectFit;
    [topbar addSubview:myImage1];
    
    UIButton *reportIssuebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reportIssuebtn.frame =CGRectMake(topbar.frame.size.width -60, 20, 50, 44);
    [reportIssuebtn addTarget:self action:@selector(openReportIssue:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:reportIssuebtn];
    
    titlelbl.textColor = [UIColor whiteColor];
    titlelbl.font  = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titlelbl.backgroundColor = [UIColor clearColor];
    titlelbl.textAlignment = NSTextAlignmentCenter;
    titlelbl.text = @"Profile";
    
    [topbar addSubview:titlelbl];
    topbar.tag = kTag_Topbar;
    [self.view addSubview:topbar];
    [self serviceCalling];
}

-(void)openReportIssue: (UIButton*)sender{
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    NotificationVC *VC5  = [storyboard instantiateViewControllerWithIdentifier:@"NotificationVC"];
//    VC5.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:VC5  animated:YES];
    
        UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        ReportIssueVC *VC5  = [mstoryboard instantiateViewControllerWithIdentifier:@"ReportIssueVC"];
        VC5.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC5  animated:YES];
}

#pragma  mark Back
-(void)Back: (UIButton*)sender{
    if ([AppDelegate appDelegate].isComeFromTrending ==YES) {
        [[AppDelegate appDelegate] getPlaySound];
        [AppDelegate appDelegate].isbackFromPostFeed = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([AppDelegate appDelegate].isComeFromTrustList ==YES) {
        [[AppDelegate appDelegate] getPlaySound];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([AppDelegate appDelegate].isComeFromConnections ==YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([AppDelegate appDelegate].isComeFromEditGroup ==YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([AppDelegate appDelegate].isComeFromCommentView ==YES) {
        [[AppDelegate appDelegate] getPlaySound];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([AppDelegate appDelegate].comefromsearch == YES){
        [AppDelegate appDelegate].isbackUpdateCheckFromSearch =YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma webservices methods
- (void) serviceCalling  //Get Profile Request
{   Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
        [userpref setObject:self.customUserId forKey:custId];
        [[AppDelegate appDelegate] showIndicator];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetProfileRequest], keyRequestType1,nil];
        if([AppDelegate appDelegate].comefromsearch == YES){
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
        if([AppDelegate appDelegate].isComeFromEditGroup == YES){
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
        if([AppDelegate appDelegate].isComeFromTrending == YES){
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
        if([AppDelegate appDelegate].isComeFromTrustList == YES){
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
        if([AppDelegate appDelegate].isComeFromCommentView == YES){
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
        if([AppDelegate appDelegate].isComeFromLeftSlider == YES) {
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:nil];
        }
        if([AppDelegate appDelegate].isComeFromConnections == YES) {
            NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.customUserId?self.customUserId:@"",custId,nil];
            Server *obj = [[Server alloc] init];
            currentRequestType = kGetProfileRequest;
            obj.delegate = self;
            [obj sendRequestToServer:aDic withDataDic:dataDic];
        }
    }
}

//// send request friend
//- (void) serviceCalling1
//{
//    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
//    NetworkStatus internetStatus = [r currentReachabilityStatus];
//    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    else
//    {
//        NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
//        [userpref setObject:uId forKey:requesteeID];
//        [[AppDelegate appDelegate] showIndicator];
//        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetConnectionFriendRequest], keyRequestType1, nil];
//        //set send to request friend to another friend
//        NSDictionary *dataDic;
//        dataDic = [NSDictionary dictionaryWithObjectsAndKeys:uId?uId:@"",requesteeID,nil];
//
//        Server *obj = [[Server alloc] init];
//        currentRequestType = kSetConnectionFriendRequest;
//        obj.delegate = self;
//        [obj sendRequestToServer:aDic withDataDic:dataDic];
//        //NSLog(@"serviceCalling1");
//    }
//}

//Connection AcceptFriendRequest
- (void) serviceCalling2
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
        [userpref setObject:uId forKey:requesteeID];
        [[AppDelegate appDelegate] showIndicator];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetConnectionAcceptFriendRequest], keyRequestType1, nil];
        //set accept friend in profile list.
        NSDictionary *dataDic;
        dataDic = [NSDictionary dictionaryWithObjectsAndKeys:uId?uId:@"",requesteeID,nil];
        
        Server *obj = [[Server alloc] init];
        currentRequestType = kSetConnectionAcceptFriendRequest;
        obj.delegate = self;
        [obj sendRequestToServer:aDic withDataDic:dataDic];
        // NSLog(@"serviceCalling2");
    }
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    switch (currentRequestType)
    {
        case kGetProfileRequest:
            [self getProfileRequestResponse:responseData];
            break;
        case kSetConnectionFriendRequest:
            
        default:
            break;
    }
    // NSLog(@"requestFinished");
}

#pragma mark result methods for login service
- (void) getProfileRequestResponse:(NSDictionary *)response
{
    //NSLog(@"resp =%@",response);
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary*resp = [[NSDictionary alloc] initWithDictionary:[response objectForKey:@"posts"]];
    if ([resp isKindOfClass:[NSNull class]] || resp==nil)
    {
        // tel is null
    }
    else {
        t_frndCount = [NSString stringWithFormat:@"%@", [resp objectForKey:@"total_friends"]?[resp objectForKey:@"total_friends"]:@""];
        if([AppDelegate appDelegate].comefromsearch == YES){
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            //NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromLeftSlider == YES){
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            //NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromConnections == YES){
            
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            // NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromCommentView == YES){
            
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            // NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromEditGroup == YES){
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            // NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromTrending == YES){
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            // NSLog(@"Frndvalue = %d",Frndvalue);
        }
        if([AppDelegate appDelegate].isComeFromTrustList == YES){
            frndStus =  [NSString stringWithFormat:@"%@", [resp objectForKey:@"friend_status"]?[resp objectForKey:@"friend_status"]:@""];
            Frndvalue = [frndStus intValue];
            // NSLog(@"Frndvalue = %d",Frndvalue);
        }
    }
    resposeCode = [resp objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode==nil)
    {
        // resposeCode is null
    }
    NSString *message=  [NSString stringWithFormat:@"%@",[resp objectForKey:@"msg"]?[resp objectForKey:@"msg"]:@""];
    NSString *status=[NSString stringWithFormat:@"%@",[resp objectForKey:@"status"]?[resp objectForKey:@"status"]:@""];
    int value = [status intValue];
    if(value==1){
        u_authkey=[NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"user_auth_key"]?[resposeCode objectForKey:@"user_auth_key"]:@""];
        uId=[NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"user_id"]?[resposeCode  objectForKey:@"user_id"]:@""];
        u_gender = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"gender"]?[resposeCode  objectForKey:@"gender"]:@""];
        u_language = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"language"]?[resposeCode  objectForKey:@"language"]:@""];
        u_title = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"title"]?[resposeCode  objectForKey:@"title"]:@""];
        u_award = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"award"]?[resposeCode  objectForKey:@"award"]:@""];
        if ([u_award  isEqualToString:@""] || [u_award  isEqualToString:@"<null>"]) {
        }
        else {
        }
        u_research = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"research"]?[resposeCode  objectForKey:@"research"]:@""];
        if ([u_research  isEqualToString:@""] || [u_research  isEqualToString:@"<null>"]) {
        }
        else {
        }
        [self MainUI];
        [self DocProfile];
        [self EditProfile];
        u_summary = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"bio"]?[resposeCode  objectForKey:@"bio"]:@""];
        if ([u_summary isEqualToString:@""] || [u_summary isEqualToString:@"<null>"]) {
        }
        else {
            [self Summary];
        }
        u_association = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"association"]?[resposeCode  objectForKey:@"association"]:@""];
        if ([u_association isEqualToString:@""] || [u_association isEqualToString:@"<null>"]) {
        }
        else {
            [self Proffesional];
        }
        u_education = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"education"]?[resposeCode  objectForKey:@"education"]:@""];
        if ([u_education isEqualToString:@""] || [u_education isEqualToString:@"<null>"]) {
        }
        else {
            [self Education];
        }
        [self BasicInfo];
        [self scrollVResize]; //for set contentsize on scrolling based on content size.
    }
    else if(value==9){
        [[AppDelegate appDelegate] logOut];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

//- (void) setConnectionFriendRequestResponse:(NSDictionary *)response
//{
//    // NSLog(@"resp =%@",response);
//    [[AppDelegate appDelegate] hideIndicator];
//    resposeCode=[response objectForKey:@"posts"];
//    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode==nil)
//    {
//        // tel is null
//    }
//    else {
//        NSString *message =  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode  objectForKey:@"msg"]:@""];
//        NSString *status= [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"status"]?[resposeCode  objectForKey:@"status"]:@""];
//        int value = [status intValue];
//        if(value==1){
//            [self insertContactData];
//            NSString*finalMsgStr = [@"??friend_request??" stringByAppendingString:u_fName];
//            NSString*messageStr = finalMsgStr;
//            if([messageStr length] > 0 ){
//                [self updateWithConnectionRequestMesssage:messageStr];
//            }
//            EditProfile.text = @"Request Sent";
//            EditProfileBtn.enabled = NO;
//        }
//        else if(value==9){
//            [[AppDelegate appDelegate] logOut];
//        }
//        else{
//            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//        }
//    }
//}


#pragma mark - send connection request
-(void)sendFriendConnectionRequest:(NSString *)requesterId u_jabberId:(NSString*)jabId user_fname:(NSString*)user_fName  {
    
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SendConnectionFriendRequest:[userDef objectForKey:userAuthKey] requester_id:[userDef objectForKey:userId] requestee_id:requesterId format:@"json" callback:^(NSMutableDictionary *responceObject, NSError *error) {
        
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                [self insertContactData:user_fName userjabId:jabId];
                
                NSString*finalMsgStr = [@"??friend_request??" stringByAppendingString:u_fName];
                NSString*messageStr = finalMsgStr;
                if([messageStr length] > 0 ){
                    [self updateWithConnectionRequestMesssage:messageStr];
                }
                EditProfile.text = @"Request Sent";
                EditProfileBtn.enabled = NO;
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - send connection request
-(void)AcceptFriendConnectionRequest:(NSString *)requesterId u_jabberId:(NSString*)jabId user_fname:(NSString*)user_fName  {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetConnectionAcceptFriendRequesRequest:[userDef objectForKey:userAuthKey] requester_id:requesterId requestee_id:[userDef objectForKey:userId] format:@"json" callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                // [self insertContactData:user_fName userjabId:jabId];
                NSString*finalMsgStr = [@"??Connection Accepted??" stringByAppendingString:u_fName];
                NSString*messageStr = finalMsgStr;
                if([messageStr length] > 0 ){
                    [self updateWithConnectionAccepetedMesssage:messageStr];
                }
                [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
                EditProfile.text = @"Start Chat";
                EditProfileBtn.enabled = YES;
                [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

- (void)updateWithConnectionRequestMesssage:(NSString*)msgString
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msgString];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:u_jabId];
    [message addChild:body];
    [self.xmppStream sendElement:message];
}

- (void)updateWithConnectionAccepetedMesssage:(NSString*)msgString
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msgString];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:u_jabId];
    [message addChild:body];
    [self.xmppStream sendElement:message];
}

-(void)insertContactData:(NSString*)user_fName userjabId:(NSString*)jabId{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM contacts where username = ('%@')", u_jabId];
    NSArray *DBRESULT =  [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (!DBRESULT || !DBRESULT.count){
    }
    else {
        NSString *InstQuery= [NSString stringWithFormat:@"INSERT INTO  contacts (username,nickname) VALUES ('%@','%@')",u_jabId,u_fName];
        [self.dbManager executeQuery:InstQuery];
    }
}

//- (void) setConnectionAcceptFriendRequestResponse:(NSDictionary *)response
//{
//    //NSLog(@"resp =%@",response);
//    [[AppDelegate appDelegate] hideIndicator];
//    NSDictionary *resposeCode1=[response objectForKey:@"posts"];
//    if ([resposeCode1 isKindOfClass:[NSNull class]] || resposeCode1 ==nil)
//    {
//        // tel is null
//    }
//    else {
//        //        NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode1 objectForKey:@"msg"]?[resposeCode1 objectForKey:@"msg"]:@""];
//        NSString *status=[NSString stringWithFormat:@"%@",[resposeCode1 objectForKey:@"status"]?[resposeCode1 objectForKey:@"status"]:@""];
//        int value = [status intValue];
//        if(value==1){
//            NSString*finalMsgStr = [@"??Connection Accepted??" stringByAppendingString:u_fName];
//            NSString*messageStr = finalMsgStr;
//            if([messageStr length] > 0 ){
//               // [self insertContactData];
//                [self updateWithConnectionAccepetedMesssage:messageStr];
//            }
//            [EditIcon setBackgroundImage:[UIImage imageNamed:@"whitechat.png"] forState:UIControlStateNormal];
//            EditProfile.text = @"Start Chat";
//            EditProfileBtn.enabled = YES;
//            [EditProfileBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else if(value==9){
//            [[AppDelegate appDelegate] logOut];
//        }
//        else{
//
//            //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            //
//            //            [alert show];
//        } }
//}

- (void) requestError
{
    // NSLog(@"LoginViewController error");
    [[AppDelegate appDelegate] hideIndicator];
    //[self noInternetView];
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

-(void)PicimageUpdate{
    UIScrollView *mainScrollview = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
    UIImageView *PimgView= (UIImageView*)[mainScrollview viewWithTag:kTag_Profileimg];
    PimgView.image = [self getImage:@"MyProfileImage.png"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)didPressCallBtn:(UIButton*)sender{
    [Localytics tagEvent:@"ProfileCall Button Click"];
    [self callMyFriend:[NSString stringWithFormat:@"+%@%@",u_countryCode,u_mobileNo]];
}
-(void)callMyFriend:(NSString*)phoneNumber{
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *phNum = [@"tel://" stringByAppendingString:phoneNumber];
    // NSLog(@"phoneNumber = %@, phNum=%@",phoneNumber,phNum);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phNum]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//            NSString *status=[NSString stringWithFormat:@"%@",[postDic objectForKey:@"status"]?[postDic objectForKey:@"status"]:@""];
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
    //[[[AppDelegate appDelegate].window visibleViewController] presentViewController:selfVerify animated:YES completion:nil];
    [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

@end
