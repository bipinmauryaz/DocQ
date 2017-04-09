/*============================================================================
 PROJECT: Docquity
 FILE:    EditProfileVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 30/04/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "EditProfileVC.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "AddInterestVC.h"
#import "EditInterestVC.h"
#import "AddSkillVC.h"
#import "EditSkillVC.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "SummaryViewC.h"
#import "NewAddEducationVC.h"
#import "NewAddAssociationVC.h"
#import "NewProfileInfoVC.h"

typedef enum{
    kTAG_Scrollview=111,
    kTAG_EducationInfo,
    kTAG_AddAssoImg,
    kTag_Profileimg,
    KTag_NameLbel,
    KTag_bioTxtVw,
    KTag_specilityLbl,
    KTag_locationLbl,
    kTag_SchoolLbl,
    kTag_degLbl,
    kTag_passYearLbl,
    
}ALLTAGS;

/*============================================================================
 Interface: EditProfileVC
 =============================================================================*/

@interface EditProfileVC ()
{
    UILabel *schoolLbl;
    UILabel *degLbl;
    UILabel *eduTmeLbl;
    UILabel *interestVallbl;
    NSString*u_authkey;                        // for get user_authkey when we are getting on edit profile
    NSString*uId;                             // for get user_id when we are getting on edit profile
    NSString*u_fName;                        // for get user_firstName when we are getting on edit profile
    NSString*u_lName;                       // for get user_lastName when we are getting on edit profile
    NSString*userPic;                      // for get user_Profile pic when we are getting on edit profile
    NSString*u_email;                     // for get user_email when we are getting on edit profile
    NSString*u_mobileNo;                 // for get user_MobileNo when we are getting on edit profile
    NSString*u_dob;                     // for get user_dob when we are getting on edit profile
    NSString*u_country;                // for get user_country when we are getting on edit profile
    NSString*u_city;                  // for get user_city when we are getting on edit profile
    NSString*u_education;            // for get user_education when we are getting on edit profile
    NSString*u_award;               // for get user_award when we are getting on edit profile
    NSString*u_association;        // for get user_association when we are getting on edit profile
    NSString*u_interest;          // for get user_interest when we are getting on edit profile
    NSString*u_speciality;       // for get user_speciality when we are getting on edit profile
    NSString*u_bio;                    // for get user_bio when we are getting on edit profile
    NSString*u_state;                 // for get user_state when we are getting on edit profile
    NSString*u_summary;              // for get user_summary when we are getting on edit profile
    UILabel *Educationlbl;       // for get educationLbl when we are getting on edit profile
    UILabel *basicInfoLbl;      // for get basicInformation when we are getting on edit profile
    NSString *f_Upper;         // for get user_firstNameUpperCase when we are getting on edit profile
    NSString *l_Upper;        // for get user_lastNameUpperCase when we are getting on edit profile
    NSString*d_loc;          // for get user_location when we are getting on edit profile
    UIView *assoView;       // for get assoview when we are getting on edit profile
    NSMutableArray*associationArr;        // for get user_associationArr when we are getting on edit profile
    NSMutableArray*eduArr;               // for get user_eduArr when we are getting on edit profile
    NSMutableArray*interestArr;         // for get user_interestArr when we are getting on edit profile
    NSString*intString;                // for get intString when we are getting on edit profile
    NSString*firstString;             // for get Profilelbl when we are getting on edit profile
    UILabel *Profilelbl;             // for get user_country when we are getting on edit profile
    UILabel *Addresslbl;            // for get Addresslbl when we are getting on edit profile
    UILabel *BasicInfolbl;
    NSMutableArray*spclArr;
    UILabel *Namelbl;
}
@end

@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    userdef = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor =  [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
    
    u_authkey= [userdef valueForKey:userAuthKey];
    uId= self.data.user_id;
    u_fName = [NSString stringWithFormat:@"%@", [self.data.first_name stringByDecodingHTMLEntities]?[self.data.first_name stringByDecodingHTMLEntities]:@""];
    u_lName = [NSString stringWithFormat:@"%@", [self.data.last_name stringByDecodingHTMLEntities]?[self.data.last_name stringByDecodingHTMLEntities]:@""];
    
    f_Upper = [u_fName capitalizedString];
    l_Upper = [u_lName capitalizedString];
    
    userPic = [NSString stringWithFormat:@"%@", self.data.profile_pic_path?self.data.profile_pic_path:@""];
    u_country = [NSString stringWithFormat:@"%@", [self.data.country stringByDecodingHTMLEntities]?[self.data.country stringByDecodingHTMLEntities]:@""];
    u_city = [NSString stringWithFormat:@"%@", [self.data.city stringByDecodingHTMLEntities]?[self.data.city stringByDecodingHTMLEntities]:@""];
    
    NSString *city_Upper = [u_city capitalizedString];
    NSString *country_Upper = [u_country capitalizedString];
    if(city_Upper.length!=0){
        d_loc = [[city_Upper stringByAppendingString:@", "]stringByAppendingString:country_Upper];
    }
    else {
        d_loc =country_Upper;
    }
    u_bio = [NSString stringWithFormat:@"%@", [self.data.bio stringByDecodingHTMLEntities]?[self.data.bio stringByDecodingHTMLEntities]:@""];
    u_state = [NSString stringWithFormat:@"%@", [self.data.state stringByDecodingHTMLEntities]?[self.data.state stringByDecodingHTMLEntities]:@""];
    u_mobileNo = [NSString stringWithFormat:@"%@",self.data.mobile?self.data.mobile:@""];
    [self MainUILoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self imgupdates:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated {
    UIScrollView *mainScrollview = (UIScrollView*)[self.view viewWithTag:kTAG_Scrollview];
    UITextView*bioTxtView= (UITextView*)[mainScrollview viewWithTag:KTag_bioTxtVw];
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    [self.delegate ProfileViewCallWithCustomid:[userpref  objectForKey:custId] update_summary:bioTxtView.text];
    [self.delegate ProfileViewCallWithCustomid:[userdef objectForKey:custId] update_firstName:self.data.first_name  update_lastName:self.data.last_name update_email:self.data.email update_city:self.data.city update_country:self.data.country update_state:self.data.state];
}

#pragma mark MainUILoad
-(void)MainUILoad{
    UIView *topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    topbar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    UIButton *backBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBarbtn.frame =CGRectMake(8, 28, 28, 28);
    [backBarbtn addTarget:self action:@selector(BackView:) forControlEvents:UIControlEventTouchUpInside];
    [backBarbtn setImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal];
    [topbar addSubview:backBarbtn];
    [self.view addSubview:topbar];
    UILabel *titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 34)];
    titlelbl.textColor = [UIColor whiteColor];
    titlelbl.text = @"Edit Profile";
    titlelbl.font  = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titlelbl.backgroundColor = [UIColor clearColor];
    titlelbl.textAlignment =  NSTextAlignmentCenter;
    UITapGestureRecognizer *singletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(BackView:)];
    singletap.numberOfTapsRequired = 1;
    [topbar addGestureRecognizer:singletap];
    [topbar addSubview:titlelbl];
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, topbar.frame.origin.y+topbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    scroll.backgroundColor =  [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
    scroll.tag = kTAG_Scrollview;
    [self.view addSubview:scroll];
    UIImageView *Profileimg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 90, 90)];
    [scroll addSubview:Profileimg];
    
    Profileimg.image = [self getImage:@"MyProfileImage.png"];
    Profileimg.contentMode = UIViewContentModeScaleAspectFill;
    Profileimg.tag= kTag_Profileimg;
    Profileimg.layer.cornerRadius = Profileimg.frame.size.height / 2;
    Profileimg.clipsToBounds= YES;
    
    UIView *userinfo = [[UIView alloc]initWithFrame:CGRectMake(Profileimg.frame.origin.x + Profileimg.frame.size.width +10, Profileimg.frame.origin.y +10, [UIScreen mainScreen].bounds.size.width - Profileimg.frame.origin.x - Profileimg.frame.size.width -20 , Profileimg.frame.size.height-20)];
    userinfo.backgroundColor = [UIColor whiteColor];
    userinfo.layer.cornerRadius = 5.0f;
    [scroll addSubview: userinfo];
    
    UIButton *profileEditbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    profileEditbtn.frame = CGRectMake(10, 10, userinfo.frame.origin.x + userinfo.frame.size.width-10, 90);
    [profileEditbtn addTarget:self action:@selector(basicInfoFunction:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:profileEditbtn];
    Namelbl= [[UILabel alloc]initWithFrame:CGRectMake(10, 10, userinfo.frame.size.width-10, 17)];
    if(f_Upper.length!=0){
        Namelbl.text = [[f_Upper stringByAppendingString:@" "]stringByAppendingString:l_Upper];
    }
    else {
        Namelbl.text =l_Upper;
    }
    Namelbl.textColor= [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    Namelbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    Namelbl.tag= KTag_NameLbel;
    Namelbl.backgroundColor = [UIColor clearColor];
    [userinfo addSubview:Namelbl];
    Profilelbl= [[UILabel alloc]initWithFrame:CGRectMake(Namelbl.frame.origin.x,Namelbl.frame.origin.y + Namelbl.frame.size.height+2, userinfo.frame.size.width-10, 15)];
    
    Profilelbl.font = [UIFont systemFontOfSize:14.0f];
    Profilelbl.backgroundColor = [UIColor clearColor];
    Profilelbl.textColor= [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
    Profilelbl.tag = KTag_specilityLbl;
    [userinfo addSubview:Profilelbl];
    NSString* DocSpecility;
    if([self.data.SpecArr count]>0){
        DocSpecility = [self.data.SpecArr objectAtIndex:0].speciality_name;
        Profilelbl.text = DocSpecility;
        Profilelbl.backgroundColor = [UIColor clearColor];
    }else{
        Profilelbl.hidden = YES;
    }
    
    Addresslbl= [[UILabel alloc]initWithFrame:CGRectMake(Namelbl.frame.origin.x,Profilelbl.frame.origin.y + Profilelbl.frame.size.height+2, userinfo.frame.size.width-10, 15)];
    Addresslbl.text = d_loc;
    Addresslbl.textColor= [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
    Addresslbl.font = [UIFont systemFontOfSize:14.0f];
    Addresslbl.backgroundColor = [UIColor clearColor];
    Addresslbl.tag = KTag_locationLbl;
    [userinfo addSubview:Addresslbl];
    
    UILabel *summarylbl= [[UILabel alloc]initWithFrame:CGRectMake(6, userinfo.frame.origin.y + userinfo.frame.size.height+20, scroll.frame.size.width-12, 17)];
    summarylbl.text = @"Summary";
    summarylbl.textColor= [UIColor darkGrayColor];
    summarylbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    summarylbl.backgroundColor = [UIColor clearColor];
    [scroll addSubview:summarylbl];
    
    UIImageView *AddSummImg = [[UIImageView alloc]initWithFrame:CGRectMake(78,userinfo.frame.origin.y + userinfo.frame.size.height+20, 17, 17)];
    AddSummImg.image = [UIImage imageNamed:@"add_more.png"];
    AddSummImg.layer.masksToBounds = YES;
    [scroll addSubview:AddSummImg];
    
    UIButton *AddnewSumBtn = [[UIButton alloc]initWithFrame:CGRectMake(5,userinfo.frame.origin.y + userinfo.frame.size.height+20, summarylbl.frame.size.width, 15)];
    
    [AddnewSumBtn addTarget:self action:@selector(EditSummFunction:) forControlEvents:UIControlEventTouchUpInside];
    [scroll  addSubview:AddnewSumBtn];
    
    UITextView *sumview =[[UITextView alloc]initWithFrame:CGRectMake(6,summarylbl.frame.size.height + summarylbl.frame.origin.y +5, scroll.frame.size.width-12, 100)];
    [sumview setFont:[UIFont systemFontOfSize:14.0]];
    sumview.backgroundColor= [UIColor whiteColor];
    sumview.userInteractionEnabled =YES;
    sumview.delegate = self;
    sumview.scrollEnabled =YES;
    sumview.bounces =YES;
    sumview.tag = KTag_bioTxtVw;
    sumview.textColor= [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
    [scroll addSubview:sumview];
    
    if(u_bio!= (id)[NSNull null])
        sumview.text = u_bio;
    else
        sumview.text=@"";
    UIButton *prosummEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    prosummEdit.frame = CGRectMake(6,summarylbl.frame.size.height + summarylbl.frame.origin.y +5, scroll.frame.size.width-12, 100);
    [prosummEdit  addTarget:self action:@selector(EditSummFunction:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:prosummEdit];
    
    UILabel *Associationlbl= [[UILabel alloc]initWithFrame:CGRectMake(6, sumview.frame.origin.y + sumview.frame.size.height+10, [UIScreen mainScreen].bounds.size.width-12, 17)];
    Associationlbl.text = @"Professional Experience";
    Associationlbl.textColor= [UIColor darkGrayColor];
    Associationlbl.backgroundColor = [UIColor clearColor];
    Associationlbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [scroll addSubview:Associationlbl];
    
    UIView *AssociationInfo = [[UIView alloc]initWithFrame:CGRectMake(Associationlbl.frame.origin.x, Associationlbl.frame.origin.y +Associationlbl.frame.size.height+5, [UIScreen mainScreen].bounds.size.width - 12 , 60)];
    AssociationInfo.backgroundColor = [UIColor whiteColor];
    AssociationInfo.tag = 200;
    [scroll addSubview: AssociationInfo];
    
    UIImageView *AddAssoImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 17, 17)];
    AddAssoImg.image = [UIImage imageNamed:@"add_more.png"];
    AddAssoImg.layer.masksToBounds = YES;
    AddAssoImg.tag = kTAG_AddAssoImg;
    [AssociationInfo addSubview:AddAssoImg];
    
    UILabel *AddNewAssolbl= [[UILabel alloc]initWithFrame:CGRectMake(AddAssoImg.frame.origin.x + AddAssoImg.frame.size.width + 5, AddAssoImg.frame.origin.y, AssociationInfo.frame.size.width - AddAssoImg.frame.origin.x - AddAssoImg.frame.size.width -10, 15)];
    AddNewAssolbl.text = @"Add a new professional experience";
    AddNewAssolbl.backgroundColor = [UIColor clearColor];
    AddNewAssolbl.textColor=  [UIColor colorWithRed:105.0/255.0 green:121.0/255.0 blue:128.0/255.0 alpha:1.0];
    AddNewAssolbl.font =  [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [AssociationInfo addSubview:AddNewAssolbl];
    UIButton *AddnewAssoBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 10, AddNewAssolbl.frame.size.width, 15)];
    [AddnewAssoBtn addTarget:self action:@selector(AddAssociationFunction:) forControlEvents:UIControlEventTouchUpInside];
    [AssociationInfo addSubview:AddnewAssoBtn];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(6, AddNewAssolbl.frame.origin.y + AddNewAssolbl.frame.size.height+10,[UIScreen mainScreen].bounds.size.width - AddAssoImg.frame.origin.x - AddAssoImg.frame.size.width ,1)];
    horizontalLine.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    [AssociationInfo addSubview:horizontalLine];
    
    u_education = @"";
    for (EducationModel *edm in self.data.eduArr) {
        if([u_education isEqualToString:@""]){
            u_education =[edm.school stringByDecodingHTMLEntities];
        }else{
            u_education = [NSString stringWithFormat:@"%@, %@",[u_education stringByDecodingHTMLEntities],[edm.school stringByDecodingHTMLEntities]];
        }
    }
    u_association = @"";
    
    for (ProfileAssoModel *pam in self.data.assoMArr) {
        if([u_association isEqualToString:@""]){
            u_association = [pam.assoName stringByDecodingHTMLEntities];
        }else{
            u_association = [NSString stringWithFormat:@"%@, %@",[u_association stringByDecodingHTMLEntities] ,[pam.assoName stringByDecodingHTMLEntities]];
        }
    }
    if ([u_association isEqualToString:@""] || [u_association isEqualToString:@"<null>"]) {
    }
    else {
        if([self.data.ProfessionArr count]>0){
            int count=0;
            for(int i =0; i<self.data.ProfessionArr.count; i++)
            {
                assoView = [[UIView alloc]init];
                assoView.backgroundColor = [UIColor whiteColor];
                assoView.frame = CGRectMake(0, horizontalLine.frame.origin.y + horizontalLine.frame.size.height + count,[UIScreen mainScreen].bounds.size.width -12, 73);
                [AssociationInfo addSubview:assoView];
                UILabel *lblFname = [[UILabel alloc]initWithFrame:CGRectMake(42, 3, 255, 21)];
                lblFname.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                lblFname.textColor = [UIColor blackColor];
                lblFname.backgroundColor = [UIColor clearColor];
                [assoView addSubview:lblFname];
                
                UILabel *lblcomp = [[UILabel alloc]initWithFrame:CGRectMake(42, lblFname.frame.size.height + lblFname.frame.origin.y + 0.2, 255, 21)];
                lblcomp .font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
                lblcomp .textColor = [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
                lblcomp.backgroundColor = [UIColor clearColor];
                [assoView addSubview:lblcomp];
                
                UILabel *lblAssoTime = [[UILabel alloc]initWithFrame:CGRectMake(42, lblcomp.frame.size.height + lblcomp.frame.origin.y + 0.3, 255, 21)];
                lblAssoTime .font = [UIFont systemFontOfSize:12.0f];
                lblAssoTime.textColor = [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
                lblAssoTime.backgroundColor = [UIColor clearColor];
                [assoView addSubview:lblAssoTime];
                
                UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, lblAssoTime.frame.size.height + lblAssoTime.frame.origin.y , assoView.frame.size.width-10, 0.3)];
                lineImg.image = [UIImage imageNamed:@"lines.png"];
                [assoView addSubview:lineImg];
                
                UIImageView *assImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 30, 30)];
                assImg.image = [UIImage imageNamed:@"exp_default.png"];
                assImg.layer.cornerRadius =4.0;
                assImg.layer.masksToBounds = YES;
                [assoView addSubview:assImg];
                
                UIButton *proExEdit = [UIButton buttonWithType:UIButtonTypeCustom];
                proExEdit.frame = CGRectMake(0, 0, assoView.frame.size.width, assoView.frame.size.height);
                proExEdit.tag = i;
                [proExEdit addTarget:self action:@selector(EditAssociationFunction:) forControlEvents:UIControlEventTouchUpInside];
                [assoView addSubview:proExEdit];
                ProfessionModel *proModel = [self.data.ProfessionArr objectAtIndex:i];
                if(proModel && [proModel isKindOfClass:[ProfessionModel class]])
                {
                    NSString*asso_id =[NSString stringWithFormat:@"%@",proModel.profession_id];
                //    NSLog(@"association_id= %@",asso_id);
                    NSString*asso_name =[NSString stringWithFormat:@"%@",[proModel.profession_name stringByDecodingHTMLEntities]];
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
                    
                    NSString*asso_endDate =[NSString stringWithFormat:@"%@",proModel.end_date];
                    NSString*asso_StartDate =[NSString stringWithFormat:@"%@",proModel.start_date];
                    NSString*asso_endMonth =[NSString stringWithFormat:@"%@",proModel.end_month];
                    NSString*asso_StartMonth =[NSString stringWithFormat:@"%@",proModel.start_month];
                    NSString*asso_loc =[NSString stringWithFormat:@"%@",[proModel.location stringByDecodingHTMLEntities]];
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
                    NSString*asso_pos =[NSString stringWithFormat:@"%@",[proModel.position stringByDecodingHTMLEntities]];
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
                    count =count+assoView.frame.size.height;
                }//end of dic
                CGRect newframe = AssociationInfo.frame;
                newframe.size.width =AssociationInfo.frame.size.width;
                newframe.size.height = assoView.frame.size.height + assoView.frame.origin.y;
                //assoView.frame.origin.y+ assoView.frame.size.height;
                AssociationInfo.frame = newframe;
            }
        }
    }
    Educationlbl = [[UILabel alloc]initWithFrame:CGRectMake(6, AssociationInfo.frame.size.height+ AssociationInfo.frame.origin.y+10, 308, 21)];
    Educationlbl.text = @"Education";
    Educationlbl.backgroundColor = [UIColor clearColor];
    Educationlbl.textColor = [UIColor darkGrayColor];
    Educationlbl.font =  [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [scroll addSubview: Educationlbl];
    UIView *EducationInfo = [[UIView alloc]initWithFrame:CGRectMake(Educationlbl.frame.origin.x, Educationlbl.frame.origin.y +Educationlbl.frame.size.height + 2, [UIScreen mainScreen].bounds.size.width - 12 , 60)];
    EducationInfo.backgroundColor = [UIColor whiteColor];
    EducationInfo.tag = kTAG_EducationInfo;
    [scroll addSubview: EducationInfo];
    
    UIImageView *AddEduImg = [[UIImageView alloc]initWithFrame:CGRectMake(AddAssoImg.frame.origin.x, AddAssoImg.frame.origin.y, AddAssoImg.frame.size.width, AddAssoImg.frame.size.height)];
    AddEduImg.image = [UIImage imageNamed:@"add_more.png"];
    AddEduImg.layer.masksToBounds = YES;
    [EducationInfo addSubview:AddEduImg];
    
    UILabel *AddNewEdulbl= [[UILabel alloc]initWithFrame:CGRectMake(AddEduImg.frame.origin.x + AddEduImg.frame.size.width + 5, AddEduImg.frame.origin.y, [UIScreen mainScreen].bounds.size.width - AddEduImg.frame.origin.x - AddEduImg.frame.size.width-20, 15)];
    AddNewEdulbl.text = @"Add a new education";
    AddNewEdulbl.textColor= [UIColor colorWithRed:105.0/255.0 green:121.0/255.0 blue:128.0/255.0 alpha:1.0];
    AddNewEdulbl.backgroundColor = [UIColor clearColor];
    AddNewEdulbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [EducationInfo addSubview:AddNewEdulbl];
    UITapGestureRecognizer *edu = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(AddEduFunction:)];
    edu.numberOfTapsRequired =1;
    [AddNewEdulbl addGestureRecognizer:edu];
    
    UIButton *AddnewEduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    AddnewEduBtn.frame= CGRectMake(AddEduImg.frame.origin.x, 0, AddNewEdulbl.frame.size.width, AddNewEdulbl.frame.size.height+AddNewEdulbl.frame.origin.y+5);
    [AddnewEduBtn addTarget:self action:@selector(AddEduFunction:) forControlEvents:UIControlEventTouchUpInside];
    [EducationInfo addSubview:AddnewEduBtn];
    
    UIView *EduhorizontalLine = [[UIView alloc]initWithFrame:CGRectMake(AddEduImg.frame.origin.x, AddNewEdulbl.frame.origin.y + AddNewEdulbl.frame.size.height+10,horizontalLine.frame.size.width,1)];
    EduhorizontalLine.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    [EducationInfo addSubview:EduhorizontalLine];
    if ([u_education isEqualToString:@""] || [u_education isEqualToString:@"<null>"]) {
        [self basicInfoScreenAdd];
    }
    else {
        if([self.data.eduArr count]>0){
            int heightEduView=0;
            UIView *educationView;
            for(int i =0; i<self.data.eduArr.count; i++)
            {
                educationView = [[UIView alloc]init];
                educationView.backgroundColor = [UIColor whiteColor];
                educationView.frame = CGRectMake(6, EduhorizontalLine.frame.origin.y + EduhorizontalLine.frame.size.height + heightEduView,[UIScreen mainScreen].bounds.size.width -  EducationInfo.frame.origin.x -20, 73);
                [EducationInfo addSubview:educationView];
                
                schoolLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, 3, 255, 21)];
                schoolLbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                schoolLbl.textColor = [UIColor blackColor];
                schoolLbl.tag= kTag_SchoolLbl;
                schoolLbl.backgroundColor = [UIColor clearColor];
                [educationView addSubview:schoolLbl];
                
                degLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, schoolLbl.frame.size.height + schoolLbl.frame.origin.y + 0.3, 255, 21)];
                degLbl .font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
                degLbl .textColor = [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
                degLbl.tag= kTag_degLbl;
                degLbl.backgroundColor = [UIColor clearColor];
                [educationView addSubview:degLbl];
                
                eduTmeLbl = [[UILabel alloc]initWithFrame:CGRectMake(42, degLbl.frame.size.height + degLbl.frame.origin.y + 0.3, 255, 21)];
                eduTmeLbl .font = [UIFont systemFontOfSize:12.0f];
                eduTmeLbl.textColor = [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
                eduTmeLbl.backgroundColor = [UIColor clearColor];
                eduTmeLbl.tag= kTag_passYearLbl;
                [educationView addSubview:eduTmeLbl];
                
                UIImageView *edulineImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, eduTmeLbl.frame.size.height + eduTmeLbl.frame.origin.y+0.3 , educationView.frame.size.width, 1)];
                edulineImg.image = [UIImage imageNamed:@"lines.png"];
                [educationView addSubview:edulineImg];
                
                UIImageView *eduDefaultImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 30, 30)];
                eduDefaultImg.image = [UIImage imageNamed:@"edu_default.png"];
                eduDefaultImg.layer.cornerRadius =4.0;
                eduDefaultImg.layer.masksToBounds = YES;
                [educationView addSubview:eduDefaultImg];
                
                UIButton *proExEdit = [UIButton buttonWithType:UIButtonTypeCustom];
                proExEdit.frame = CGRectMake(0, 0, educationView.frame.size.width, educationView.frame.size.height);
                proExEdit.tag = i;
                [proExEdit addTarget:self action:@selector(EditEducationFunction:) forControlEvents:UIControlEventTouchUpInside];
                [educationView addSubview:proExEdit];
                EducationModel *eduModel=[self.data.eduArr objectAtIndex:i];
                if(eduModel && [eduModel isKindOfClass:[EducationModel class]])
                {
                    NSString*edu_id =[NSString stringWithFormat:@"%@",eduModel.education_id];
                 //   NSLog(@"edu_id= %@",edu_id);
                    
                    NSString*edu_name =[NSString stringWithFormat:@"%@",[eduModel.school stringByDecodingHTMLEntities]];
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
                    NSString*edu_endDate =[NSString stringWithFormat:@"%@",eduModel.end_date];
                    NSString*edu_StartDate =[NSString stringWithFormat:@"%@",eduModel.start_date];
                //    NSLog(@"edu_StartDate= %@",edu_StartDate);
                    
                    //ari change new 20 sep 2015
                    NSString* currPur = [NSString stringWithFormat:@"%@",eduModel.current_pursuing];
                    if (edu_endDate.length!=0){
                        
                        if ([currPur isEqualToString:@"1"]) {
                            eduTmeLbl.text = @"Currently Pursuing";
                        }
                        else{
                            if ([edu_endDate isEqualToString:@"0"]) {
                                eduTmeLbl.text = @"";
                            }
                            else{
                                eduTmeLbl.text = edu_endDate;
                            }
                        }
                    }
                    else {
                    }
                    NSString*edu_study =[NSString stringWithFormat:@"%@",[eduModel.field_of_study stringByDecodingHTMLEntities]];
                    NSMutableString *final_eduStudy = [edu_study mutableCopy];
                    [final_eduStudy enumerateSubstringsInRange:NSMakeRange(0, [final_eduStudy length])
                                                       options:NSStringEnumerationByWords
                                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                        [final_eduStudy replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                                    }];
                    NSString*edu_deg =[NSString stringWithFormat:@"%@",[eduModel.degree stringByDecodingHTMLEntities]];
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
                    heightEduView = heightEduView +educationView.frame.size.height;
                }
                CGRect newEduframe = EducationInfo.frame;
                newEduframe.size.width =EducationInfo.frame.size.width;
                newEduframe.size.height = educationView.frame.origin.y+ educationView.frame.size.height;
                EducationInfo.frame = newEduframe;
            }
        }
        [self basicInfoScreenAdd];
    }
}

#pragma mark - add peronsal information
-(void)basicInfoScreenAdd{
    UIScrollView *Scrv = (UIScrollView*)[self.view viewWithTag:kTAG_Scrollview];
    UIView *educationInfoView= (UIView *)[Scrv viewWithTag:kTAG_EducationInfo];
    UIView *AssociationInfo =(UIView *)[Scrv viewWithTag:200];
    UIImageView *AddAssoImg = (UIImageView*)[AssociationInfo viewWithTag:kTAG_AddAssoImg];
    BasicInfolbl= [[UILabel alloc]initWithFrame:CGRectMake(Educationlbl.frame.origin.x, educationInfoView.frame.origin.y + educationInfoView.frame.size.height+10, [UIScreen mainScreen].bounds.size.width-Educationlbl.frame.origin.x*2, 15)];
    BasicInfolbl.text = @"Interests";
    BasicInfolbl.textColor= [UIColor darkGrayColor];
    BasicInfolbl.backgroundColor = [UIColor clearColor];
    BasicInfolbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [Scrv addSubview:BasicInfolbl];
    UIView *InterestInfo = [[UIView alloc]initWithFrame:CGRectMake(BasicInfolbl.frame.origin.x, BasicInfolbl.frame.origin.y +BasicInfolbl.frame.size.height + 5, [UIScreen mainScreen].bounds.size.width , 60)];
    InterestInfo.backgroundColor = [UIColor whiteColor];
    [Scrv addSubview: InterestInfo];
    
    UIImageView *AddIntImg = [[UIImageView alloc]initWithFrame:CGRectMake(AddAssoImg.frame.origin.x, AddAssoImg.frame.origin.y, AddAssoImg.frame.size.width, AddAssoImg.frame.size.height)];
    AddIntImg.image = [UIImage imageNamed:@"add_more.png"];
    AddIntImg.layer.masksToBounds = YES;
    [InterestInfo addSubview:AddIntImg];
    
    UILabel *AddNewIntlbl= [[UILabel alloc]initWithFrame:CGRectMake(AddIntImg.frame.origin.x +AddIntImg.frame.size.width + 5, AddIntImg.frame.origin.y, [UIScreen mainScreen].bounds.size.width - AddIntImg.frame.origin.x - AddIntImg.frame.size.width-20, 15)];
    AddNewIntlbl.text = @"Add a new interest";
    AddNewIntlbl.backgroundColor = [UIColor clearColor];
    AddNewIntlbl.textColor= [UIColor colorWithRed:105.0/255.0 green:121.0/255.0 blue:128.0/255.0 alpha:1.0];
    
    AddNewIntlbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [InterestInfo addSubview:AddNewIntlbl];
    
    UIButton *AddnewIntBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, AddNewIntlbl.frame.size.width, 18)];
    [AddnewIntBtn addTarget:self action:@selector(AddIntFunction:) forControlEvents:UIControlEventTouchUpInside];
    [InterestInfo addSubview:AddnewIntBtn];
    
    UIView *InthorizontalLine = [[UIView alloc]initWithFrame:CGRectMake(AddIntImg.frame.origin.x, AddNewIntlbl.frame.origin.y + AddNewIntlbl.frame.size.height+10,InterestInfo.frame.size.width - AddIntImg.frame.origin.x - AddIntImg.frame.size.width,1)];
    InthorizontalLine.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    [InterestInfo addSubview:InthorizontalLine];
    UIView *BasicInfoDetailsV = [[UIView alloc]initWithFrame:CGRectMake(0, InthorizontalLine.frame.origin.y +InthorizontalLine.frame.size.height + 5, InterestInfo.frame.size.width- InterestInfo.frame.origin.x*2, 5)];
    
    BasicInfoDetailsV.backgroundColor = [UIColor whiteColor];
    [InterestInfo addSubview: BasicInfoDetailsV];
    if (self.data.interestArr.count == 0) {
    }
    else {
        if(self.data.interestArr.count>0){
            intString = @"";
            NSMutableString *final_intName;
            for(int i =0; i<self.data.interestArr.count; i++)
            {
                InterestModel *interstModel=[self.data.interestArr objectAtIndex:i];
                if(interstModel && [interstModel isKindOfClass:[InterestModel class]])
                {
                    //  NSString*int_id =[NSString stringWithFormat:@"%@",interstModel.interest_id];
                    
                    NSString*int_name =[NSString stringWithFormat:@"%@",[interstModel.interest_name stringByDecodingHTMLEntities]];
                    final_intName = [int_name mutableCopy];
                    [final_intName enumerateSubstringsInRange:NSMakeRange(0, [final_intName length])
                                                      options:NSStringEnumerationByWords
                                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                       [final_intName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                    withString:[[substring substringToIndex:1] uppercaseString]];
                                                   }];
                    NSString*st;
                    if(i==(self.data.interestArr.count -1)){
                        st = final_intName;
                    }
                    else {
                        st = [final_intName stringByAppendingString:@", "];
                    }
                    intString = [intString stringByAppendingString:st];
                }
            }
        }
        interestVallbl= [[UILabel alloc]initWithFrame:CGRectMake(10, 0, BasicInfoDetailsV.frame.size.width-20, 60)];
        interestVallbl.text = intString;
        interestVallbl.textColor= [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
        interestVallbl.numberOfLines = 0;
        interestVallbl.backgroundColor = [UIColor clearColor];
        interestVallbl.lineBreakMode = NSLineBreakByWordWrapping;
        [interestVallbl sizeToFit];
        interestVallbl.font = [UIFont systemFontOfSize:14.0f];
        [BasicInfoDetailsV addSubview:interestVallbl];
        
        CGRect newBasicInfoDetailsVframe = BasicInfoDetailsV.frame;
        newBasicInfoDetailsVframe.size.width = BasicInfoDetailsV.frame.size.width;
        newBasicInfoDetailsVframe.size.height = interestVallbl.frame.origin.y+ interestVallbl.frame.size.height+5;
        BasicInfoDetailsV.frame = newBasicInfoDetailsVframe;
        UITapGestureRecognizer *intEdit = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(InterestEdit:)];
        intEdit.numberOfTapsRequired =1;
        [BasicInfoDetailsV addGestureRecognizer:intEdit];
        
        CGRect newintframe = InterestInfo.frame;
        newintframe.size.width = BasicInfoDetailsV.frame.size.width;
        newintframe.size.height = BasicInfoDetailsV.frame.origin.y+ BasicInfoDetailsV.frame.size.height;
        InterestInfo.frame = newintframe;
    }
    UILabel *SkilInfolbl= [[UILabel alloc]initWithFrame:CGRectMake(BasicInfolbl.frame.origin.x, InterestInfo.frame.origin.y + InterestInfo.frame.size.height+10, [UIScreen mainScreen].bounds.size.width-BasicInfolbl.frame.origin.x*2, 15)];
    SkilInfolbl.text = @"Specialization";
    SkilInfolbl.textColor= [UIColor darkGrayColor];
    SkilInfolbl.backgroundColor = [UIColor clearColor];
    SkilInfolbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [Scrv addSubview:SkilInfolbl];
    UIView *skillInfo = [[UIView alloc]initWithFrame:CGRectMake(SkilInfolbl.frame.origin.x, SkilInfolbl.frame.origin.y +SkilInfolbl.frame.size.height + 5, [UIScreen mainScreen].bounds.size.width , 60)];
    skillInfo.backgroundColor = [UIColor whiteColor];
    [Scrv addSubview: skillInfo];
    
    UIImageView *AddSkillImg = [[UIImageView alloc]initWithFrame:CGRectMake(AddAssoImg.frame.origin.x, AddAssoImg.frame.origin.y, AddAssoImg.frame.size.width, AddAssoImg.frame.size.height)];
    AddSkillImg.image = [UIImage imageNamed:@"add_more.png"];
    AddSkillImg.layer.masksToBounds = YES;
    [skillInfo addSubview:AddSkillImg];
    
    UILabel *AddNewSkilllbl= [[UILabel alloc]initWithFrame:CGRectMake(AddSkillImg.frame.origin.x +AddSkillImg.frame.size.width + 5, AddSkillImg.frame.origin.y, [UIScreen mainScreen].bounds.size.width - AddSkillImg.frame.origin.x - AddSkillImg.frame.size.width-20, 15)];
    AddNewSkilllbl.text = @"Add a new specialization";
    AddNewSkilllbl.backgroundColor = [UIColor clearColor];
    AddNewSkilllbl.textColor= [UIColor colorWithRed:105.0/255.0 green:121.0/255.0 blue:128.0/255.0 alpha:1.0];
    
    AddNewSkilllbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [skillInfo addSubview:AddNewSkilllbl];
    
    UIButton *AddnewSkillBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, AddNewSkilllbl.frame.size.width, 18)];
    [AddnewSkillBtn addTarget:self action:@selector(AddSkillFunction:) forControlEvents:UIControlEventTouchUpInside];
    [skillInfo addSubview:AddnewSkillBtn];
    
    UILabel *skillhorizontalLine = [[UILabel alloc]initWithFrame:CGRectMake(AddSkillImg.frame.origin.x, AddNewSkilllbl.frame.origin.y + AddNewSkilllbl.frame.size.height+10,skillInfo.frame.size.width - AddSkillImg.frame.origin.x - AddSkillImg.frame.size.width,1)];
    skillhorizontalLine.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    [skillInfo addSubview:skillhorizontalLine];
    
    UIView *skillInfoDetailsV = [[UIView alloc]initWithFrame:CGRectMake(0, skillhorizontalLine.frame.origin.y +skillhorizontalLine.frame.size.height + 5, skillInfo.frame.size.width- skillInfo.frame.origin.x*2, 70)];
    
    skillInfoDetailsV.backgroundColor = [UIColor whiteColor];
    [skillInfo addSubview: skillInfoDetailsV];
    if (self.data.SpecArr.count == 0) {
        
    }
    else {
        if([self.data.SpecArr count]){
            firstString =@"";
            NSMutableString *final_spclName;
            for(int i =0; i<self.data.SpecArr.count; i++)
            {
                SpecialityModel *spclModel = [self.data.SpecArr objectAtIndex:i];
                if([spclModel isKindOfClass:[SpecialityModel class]])
                {
                    NSString*spcl_name =[NSString stringWithFormat:@"%@",[spclModel.speciality_name stringByDecodingHTMLEntities]];
                    
                    final_spclName = [spcl_name mutableCopy];
                    [final_spclName enumerateSubstringsInRange:NSMakeRange(0, [final_spclName length])
                                                       options:NSStringEnumerationByWords
                                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                        [final_spclName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                                    }];
                }
                NSString*st;
                if(i==(self.data.SpecArr.count -1)){
                    st = final_spclName;
                }
                else {
                    st = [final_spclName stringByAppendingString:@", "];
                }
                firstString = [firstString stringByAppendingString:st];
                Profilelbl.text = firstString;
                Profilelbl.font = [UIFont systemFontOfSize:14.0f];
                Profilelbl.numberOfLines =1;
                //[Profilelbl sizeToFit];
            }
        }
    }
    UILabel *skillVallbl= [[UILabel alloc]initWithFrame:CGRectMake(10, 0, skillInfoDetailsV.frame.size.width-20, 60)];
    skillVallbl.text = firstString;
    skillVallbl.textColor= [UIColor colorWithRed:103.0/255.0 green:104.0/255.0 blue:105.0/255.0 alpha:1.0];
    skillVallbl.numberOfLines = 0;
    skillVallbl.backgroundColor = [UIColor clearColor];
    skillVallbl.lineBreakMode = NSLineBreakByWordWrapping;
    skillVallbl.font = [UIFont systemFontOfSize:14.0f];
    [skillInfoDetailsV addSubview:skillVallbl];
    UITapGestureRecognizer *skillEdit = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(EditSkill:)];
    skillEdit.numberOfTapsRequired =1;
    [skillInfoDetailsV addGestureRecognizer:skillEdit];
    UIView *skillInfohorLine = [[UIView alloc]initWithFrame:CGRectMake(skillVallbl.frame.origin.x, skillVallbl.frame.origin.y + skillVallbl.frame.size.height +5,skillVallbl.frame.origin.x,1)];
    skillInfohorLine.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    [skillInfoDetailsV addSubview:skillInfohorLine];
    CGRect newskillframe = skillInfo.frame;
    newskillframe.size.width =skillInfoDetailsV.frame.size.width;
    newskillframe.size.height = skillInfoDetailsV.frame.origin.y+ skillInfoDetailsV.frame.size.height;
    skillInfo.frame = newskillframe;
    Scrv.contentSize = CGSizeMake(Scrv.frame.size.width, skillInfo.frame.size.height + skillInfo.frame.origin.y+skillVallbl.frame.size.height+5);
}

#pragma mark AddAssociationFunction
- (void)AddAssociationFunction: (UIButton *)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewAddAssociationVC *addasso  = [storyboard instantiateViewControllerWithIdentifier:@"NewAddAssociationVC"];
    [self.navigationController pushViewController:addasso animated:YES];
}

#pragma mark AddAssociationFunction
- (void)AddEduFunction:(UIButton *)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewAddEducationVC *AEVC   = [storyboard instantiateViewControllerWithIdentifier:@"NewAddEducationVC"];
    //AEVC.delegate = self;
    [self.navigationController pushViewController:AEVC   animated:YES];
}

#pragma mark AddAssociationFunction
- (void)AddIntFunction:(UIButton *)sender{
    AddInterestVC*lv=[[AddInterestVC alloc]initWithNibName:IS_IPHONE_5?@"AddInterestVC-i5":@"AddInterestVC" bundle:nil];
    [self.navigationController pushViewController:lv animated:YES];
}

#pragma mark AddSkillFunction
- (void)AddSkillFunction:(UIButton *)sender{
    AddSkillVC*lv=[[AddSkillVC alloc]initWithNibName:IS_IPHONE_5?@"AddSkillVC-i5":@"AddSkillVC" bundle:nil];
    [self.navigationController pushViewController:lv animated:YES];
}

#pragma mark basicInfoFunction
- (void)basicInfoFunction:(UIButton *)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewProfileInfoVC *profdetails  = [storyboard instantiateViewControllerWithIdentifier:@"NewProfileInfoVC"];
    profdetails.data = profdetails.delegate = self.data;
    profdetails.delegate = self;
    [self.navigationController pushViewController:profdetails animated:YES];
}

#pragma mark - backButton Action
-(void)BackView:(UIButton*)sender{
    [AppDelegate appDelegate].isComeFromTimeline = NO;
    [self.delegate PicimageUpdate];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - edit Association
- (void) EditAssociationFunction:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewAddAssociationVC *editasso  = [storyboard instantiateViewControllerWithIdentifier:@"NewAddAssociationVC"];
    NSInteger tt = sender.tag;
   // editasso.delegate = self;
    [editasso setData:self.data.ProfessionArr withindex:tt flag:1];
    [self.navigationController pushViewController:editasso animated:YES];
}

#pragma mark - edit Education
- (void) EditEducationFunction:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewAddEducationVC *addEDU  = [storyboard instantiateViewControllerWithIdentifier:@"NewAddEducationVC"];
    NSInteger tt = sender.tag;
   // addEDU.delegate = self;
    [addEDU setData:self.data.eduArr withindex:tt flag:1];
    [self.navigationController pushViewController:addEDU animated:YES];
}

#pragma mark - edit summary
- (void)EditSummFunction:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SummaryViewC *sumvc  = [storyboard instantiateViewControllerWithIdentifier:@"SummaryViewC"];
    summary = [u_bio stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];
    summary = [u_bio stringByReplacingOccurrencesOfString:@"<br/>" withString: @"\n"];
    summary = [u_bio stringByReplacingOccurrencesOfString:@"<br />" withString: @"\n"];
    sumvc.data =  self.data;
    sumvc.summary = summary;
    sumvc.delegate = self;
    [self.navigationController pushViewController:sumvc animated:YES];
}

#pragma mark - interest edit
-(void)InterestEdit:(UITapGestureRecognizer*)sender{
    EditInterestVC*lv=[[EditInterestVC alloc]initWithNibName:IS_IPHONE_5?@"EditInterestVC-i5":@"EditInterestVC" bundle:nil];
    //lv.delegate = self;
    lv.editIntListArray = self.data.interestArr;
    [self.navigationController pushViewController:lv animated:YES];
}

#pragma mark - edit skill
-(void)EditSkill:(UITapGestureRecognizer*)sender{
    
    //Checking Device-----Iphone 5 or other
    EditSkillVC*lv=[[EditSkillVC alloc]initWithNibName:IS_IPHONE_5?@"EditSkillVC-i5":@"EditSkillVC" bundle:nil];
    lv.editSkillListArray = self.data.SpecArr;
    [self.navigationController pushViewController:lv animated:YES];
}

#pragma mark - profile image updates
-(void)imgupdates:(NSString*)UpdateImageUrl{
    //NSLog(@"img url edit profileVc: %@",UpdateImageUrl);
    userPic = UpdateImageUrl;
    UIScrollView *mainScrollview = (UIScrollView*)[self.view viewWithTag:kTAG_Scrollview];
    UIImageView *PimgView= (UIImageView*)[mainScrollview viewWithTag:kTag_Profileimg];
    PimgView.image = [self getImage:@"MyProfileImage.png"];
    //[self MainUILoad];
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
        //NSLog(@"no underlying data");
    }
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)EditProfileViewCallWithCustomid:(NSString*)custom_id update_summary:(NSString *)update_summary;
{
  //  NSLog(@"custom_id = %@, update_summary = %@" ,custom_id,update_summary);
    UIScrollView *mainScrollview = (UIScrollView*)[self.view viewWithTag:kTAG_Scrollview];
    UITextView*bioTxtView= (UITextView*)[mainScrollview viewWithTag:KTag_bioTxtVw];
    self.data.bio =   update_summary.mutableCopy;
    bioTxtView.text = update_summary.mutableCopy;
}

-(void)EditProfileViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state{
    
    //NSLog(@"firstname = %@, lastname = %@" ,update_firstName,update_lastName);
    f_Upper = update_firstName.mutableCopy;
    l_Upper = update_lastName.mutableCopy;
    self.data.first_name = f_Upper;
    self.data.last_name = l_Upper;
    self.data.city = [NSString stringWithFormat:@"%@",update_city.mutableCopy];
    self.data.country = [NSString stringWithFormat:@"%@",update_country.mutableCopy];
    self.data.email = [NSString stringWithFormat:@"%@",update_email.mutableCopy];
    
    //self.data
    UIScrollView *mainScrollview = (UIScrollView*)[self.view viewWithTag:kTAG_Scrollview];
    UILabel*fullName= (UILabel*)[mainScrollview viewWithTag:KTag_NameLbel];
    UILabel*locationLbl = (UILabel*)[mainScrollview viewWithTag:KTag_locationLbl];
 
    if(update_country.length ==0 && update_city.length == 0)
    {
        locationLbl.text = @"";
    }else  if(update_country.length !=0 && update_city.length != 0){
        locationLbl.text = [NSString stringWithFormat: @"%@, %@",update_city.mutableCopy,update_country.mutableCopy];
    }else  if(update_country.length != 0){
        locationLbl.text = [NSString stringWithFormat: @"%@",update_country.mutableCopy];
    }else  if(update_city.length != 0){
        locationLbl.text = [NSString stringWithFormat: @"%@",update_city.mutableCopy];
    }
    
    fullName.text = [NSString stringWithFormat: @"%@ %@",f_Upper,l_Upper];
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
