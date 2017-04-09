//
//  NewProfileVC.m
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NewProfileVC.h"
#import "UIImageView+LBBlurredImage.h"
//#import "UITableView+ZZStretchableHeader.h"
#import "UINavigationBar+ZZHelper.h"
#import "connectionCell.h"
#import "SummaryCell.h"
#import "EducationCell.h"
#import "BasicInfoCell.h"
#import "statusCell.h"
#import "ProfessionalCell.h"
#import "PersonalInfoCell.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "AppDelegate.h"
#import "ProfileAssoModel.h"
#import "EducationModel.h"
#import "InterestModel.h"
#import "ProfessionModel.h"
#import "SpecialityModel.h"
#import "FriendModel.h"
#import "UIImageView+WebCache.h"
#import "EditProfileVC.h"
#import "Localytics.h"
#import "PermissionCheckYourSelfVC.h"
#import "NSString+HTML.h"
#import "ChatViewController.h"
#import "ServicesManager.h"
#import "EarnVC.h"

#define kTableHeaderHeight 186
#define kNaviBarHeight 64
#define kHeight      [[UIScreen mainScreen] bounds].size.height
#define kWidth       [[UIScreen mainScreen] bounds].size.width
@interface NewProfileVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSString*selectedFCustid;
}

@end

@implementation NewProfileVC
@synthesize profileData,isDataGet;

- (void)viewDidLoad {
    [super viewDidLoad];
    headerViewCreated = NO;
  //  self.profileData = [ProfileData new];
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        isOwnProfile = YES;
    }else{
        isOwnProfile = NO;
    }
    self.avatarImg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImg.layer.borderWidth = 1.0f;
//    isDataGet = false;
    self.transparentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor = [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshProfile)
              forControlEvents:UIControlEventValueChanged];
    [self.TableView insertSubview: refreshControl atIndex:0];
   // [self initUI];
    self.navTitle.text = [[[self.profileData.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString];
   
}

-(void)refreshProfile{
    [self getProfileServiceWithCustId:self.customUserId];
    if (refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = @"Refreshing...";
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"ProfileScreen Visited"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self initUI];
  //  [self navigationsetup];
    [self setupHeader];
    [self scrollViewDidScroll:self.TableView];
    isDataGet?nil: [self getProfileServiceWithCustId:self.customUserId];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]]){
        [self PicimageUpdate];
    }
    self.TableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)initUI {
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];

    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:0.0], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    
  //  self.headerBackImg.image = [self blurWithCoreImage:self.headerBackImg.image];
    [self setupHeader];
 }

- (IBAction)didPressNavbarBackButton:(id)sender {
 //   NSLog(@"didPressNavbarBackButton");
 //   [self.delegate SettingViewCallWithCustomid:self.customUserId update_firstName:profileData.first_name update_lastName:profileData.last_name];
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    [self.delegate TimeLineViewCallWithCustomid:[userpref  objectForKey:custId] update_firstName:self.profileData.first_name  update_lastName:self.profileData.last_name update_email:self.profileData.email update_city:self.profileData.city update_country:self.profileData.country update_state:self.profileData.state];

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupHeader{

    [self blurimageP:self.userProfileImage];
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    self.headerBackImg.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width/2;
    self.avatarImg.layer.masksToBounds = YES;
    self.headerBackImg.layer.masksToBounds = YES;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self addBackButtonWithAnimation:NO];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    });
//    self.navTitle.text = [[[self.profileData.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString];
    self.avatarImg.image = self.userProfileImage;
    self.headerBackImg.image = self.userProfileImage;
    [self headerviewSetup];
    
    self.view_status.backgroundColor = kNewCOAColor;
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        self.view_action.hidden = false;
        self.lbl_status.text = @"EDIT PROFILE";
        self.img_status.image = [UIImage imageNamed:@"profile-edit.png"];
    }else{
        //FriendModel *fmodal = profileData.FriendDic;
        self.view_action.hidden = false;
        [self friendStatusLabelUpdate];
    }
}

-(void)setBackButton{
    // NSLog(@"setBackButton");
    UIBarButtonItem *backButton;
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(GoToBackView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  }

-(void)GoToBackView{
  //  NSLog(@"GoToBackView");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)headerviewSetup{
    if ([AppDelegate appDelegate].isComeFromTimeline ==YES) {
        //self.profileData.first_name
        self.lbl_userName.text = [[NSString stringWithFormat:@"%@ %@",self.profileData.first_name ,self.profileData.last_name]stringByDecodingHTMLEntities];
     if([[self.profileData.city stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0){
        self.lbl_city.text = [NSString stringWithFormat:@"%@, %@",[self.profileData.city stringByDecodingHTMLEntities],[[self.profileData.country stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
    }else {
        self.lbl_city.text = [[self.profileData.country stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    }
    }
    self.lbl_userName.backgroundColor = [UIColor clearColor];
    self.lbl_city.backgroundColor = [UIColor clearColor];
    if([profileData.SpecArr count]>0){
        self.lbl_Speciality.text = [profileData.SpecArr objectAtIndex:0].speciality_name;
        self.lbl_Speciality.backgroundColor = [UIColor clearColor];
    }else{
        self.lbl_Speciality.hidden = YES;
    }
    [self blurimageP:self.userProfileImage];
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
    // NSLog(@"%f",contentY);
//    [self.navigationController.navigationBar zz_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[[UIColor whiteColor]colorWithAlphaComponent:alpha], NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    //    self.navigationController.navigationBar.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:alpha];
    self.navigationBarView.backgroundColor = [color colorWithAlphaComponent:alpha];
    self.navTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
}

#pragma mark -- TableViewDataSoure
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isOwnProfile)
    {
    return 7;
    }
    else
    {
    return 6;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // NSLog(@"viewForHeaderInSection");
    UIView *header =  [self clone:self.sectionHeader];
    UILabel *lbl_title = [header viewWithTag:99];
    NSString *titleLbl = @"";
    if(!isDataGet){
        lbl_title.text = titleLbl;
        return header;
    }
    switch (section) {
        case 1:
            for(ProfessionModel *PrM in profileData.ProfessionArr){
                if([PrM.current_prof isEqualToString:@"1"]){
                    titleLbl = @"Current Working";
                    break;
                }
            }
            break;
        case 2:
            titleLbl = @"Summary";
            break;
        case 3:
            titleLbl = @"Education";
            break;
        case 4:
            titleLbl = @"Professional Experience";
            break;
        case 5:
            titleLbl = @"Basic Information";
            break;
        case 6:
            titleLbl = @"Personal Information";
            break;
        default:
            titleLbl = @"";
            break;
    }
    lbl_title.text = titleLbl;
    return header; //  [self.sectionHeader clone];
}

- (UIView*)clone :(UIView*)view{
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: view];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // NSLog(@"numberOfRowsInSection");
    NSInteger totalCell = 0;
    switch (section) {
        case 0:
            totalCell = 1;
            break;
        case 1:
            for(ProfessionModel *PrM in profileData.ProfessionArr){
                if([PrM.current_prof isEqualToString:@"1"]){
                    totalCell = 1;
                    break;
                }
            }
            break;
        case 2:
            totalCell = 1;
            break;
        case 3:
            totalCell = [profileData.eduArr count];
            break;
        case 4:
            totalCell = [profileData.ProfessionArr count];
            break;
        case 5:
            totalCell = 1;
            break;
        case 6:
            totalCell = 1;
            break;
        default:
            totalCell= 1;
            break;
    }
    return totalCell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *connCellIdentifier = @"connectionCell";
    static NSString *bioCellIdentifier = @"summaryCell";
    static NSString *eduCellIdentifier = @"educationCell";
    static NSString *bInfoCellIdentifier = @"basicInfoCell";
//  static NSString *chatCellIdentifier = @"chatCell";
    static NSString *profCellIdentifier = @"ProfessionalCell";
    static NSString *pInofCellIdentifier = @"PersonalCell";
    connectionCell *ccell = [tableView dequeueReusableCellWithIdentifier:connCellIdentifier];
    SummaryCell *sumCell = [tableView dequeueReusableCellWithIdentifier:bioCellIdentifier];
    EducationCell *eduCell = [tableView dequeueReusableCellWithIdentifier:eduCellIdentifier];
    BasicInfoCell *bInfoCell = [tableView dequeueReusableCellWithIdentifier:bInfoCellIdentifier];
    PersonalInfoCell *pInfoCell = [tableView dequeueReusableCellWithIdentifier:pInofCellIdentifier];
    ProfessionalCell *profCell = [tableView dequeueReusableCellWithIdentifier:profCellIdentifier];
    NSString *specility = @"";
    NSString *Interest = @"";
    
    //     if (indexPath.section == 7) {
    //        self.TableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //    }
    
    switch (indexPath.section) {
        case 0:
            if (ccell==nil) {
                ccell = [[connectionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:connCellIdentifier];
            }
            if(isDataGet){
           ccell.lbl_total_cme.text = profileData.total_cme_points;
           NSString*referpoints     = self.profileData.total_refer_points?self.profileData.total_refer_points:@"0";
                
            ccell.lbl_total_connection.text   =  [NSString stringWithFormat:@"%.0f",[referpoints floatValue]];
                ccell.lbl_total_cme.backgroundColor = [UIColor whiteColor];
                ccell.lbl_total_connection.backgroundColor = [UIColor whiteColor];
                ccell.lbl_CmeStatic.text = @"CME POINTS";
                ccell.lbl_connection_static.text = @"REFERRAL POINTS";
                ccell.lbl_CmeStatic.backgroundColor = [UIColor clearColor];
                ccell.lbl_connection_static.backgroundColor = [UIColor clearColor];
            }
            return ccell;
            break;
            
        case 1:
            if (profCell==nil) {
                profCell = [[ProfessionalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profCellIdentifier];
            }
            if(isDataGet) {
                for(ProfessionModel *PrM in profileData.ProfessionArr) {
                    if([PrM.current_prof isEqualToString:@"1"]) {
                        profCell.lbl_companyName.text = [PrM.profession_name stringByDecodingHTMLEntities];
                        profCell.lbl_Position.text = [PrM.position stringByDecodingHTMLEntities];
                        profCell.lbl_duration.text = [NSString stringWithFormat:@"%@ %@ - Present \u2022 %@",PrM.start_month, PrM.start_date,[PrM.location stringByDecodingHTMLEntities]];
                        profCell.img_company.image =[UIImage imageNamed:@"exp_default.png"];
                        profCell.img_company.backgroundColor =[UIColor clearColor];
                        profCell.lbl_companyName.backgroundColor = [UIColor whiteColor];
                        profCell.lbl_Position.backgroundColor = [UIColor whiteColor];
                        profCell.lbl_duration.backgroundColor = [UIColor whiteColor];
                        break;
                    }
                }
            }
            return profCell;
            break;
            
        case 2:
            if (sumCell==nil) {
                sumCell = [[SummaryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:connCellIdentifier];
            }
            if(isDataGet){
                NSString*summary   = [profileData.bio  stringByDecodingHTMLEntities];
                sumCell.tv_bio.text = summary; // show Summary
                sumCell.tv_bio.backgroundColor = [UIColor whiteColor];
                sumCell.lbl_summaryStatic.text = @"Summary";
                sumCell.lbl_summaryStatic.backgroundColor = [UIColor whiteColor];
                [sumCell.tv_bio setTextContainerInset:UIEdgeInsetsZero];
                sumCell.tv_bio.textContainer.lineFragmentPadding = 0;
            }
            return sumCell;
            break;
        case 3:
            if (eduCell==nil) {
                eduCell = [[EducationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:connCellIdentifier];
            }
            if(isDataGet){
                EducationModel *eduM = [profileData.eduArr objectAtIndex:indexPath.row];
                eduCell.lbl_Edu_name.text = [eduM.school stringByDecodingHTMLEntities];
                if([eduM.current_pursuing isEqualToString:@"1"]){
                    eduCell.lbl_degree.text = [NSString stringWithFormat:@"%@ (Pursuing)",[eduM.degree stringByDecodingHTMLEntities]];
                }else if([eduM.end_date isEqualToString:@"0"]){
                    eduCell.lbl_degree.text = [NSString stringWithFormat:@"%@",[eduM.degree stringByDecodingHTMLEntities]];
                }else{
                    eduCell.lbl_degree.text = [NSString stringWithFormat:@"%@  (%@)",[eduM.degree stringByDecodingHTMLEntities],eduM.end_date];
                }
                eduCell.img_edu.image = [UIImage imageNamed:@"edu_default.png"];
                eduCell.img_edu.backgroundColor =[UIColor clearColor];
                // NSLog(@"edu cell");
                eduCell.lbl_degree.backgroundColor = [UIColor whiteColor];
                eduCell.lbl_Edu_name.backgroundColor = [UIColor whiteColor];
            }
            return eduCell;
            break;
            
        case 4:
            if (profCell==nil) {
                profCell = [[ProfessionalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profCellIdentifier];
            }
            if(isDataGet){
                ProfessionModel *PrM  =  [profileData.ProfessionArr objectAtIndex:indexPath.row];
                profCell.lbl_companyName.text = [PrM.profession_name stringByDecodingHTMLEntities];
                profCell.lbl_companyName.backgroundColor = [UIColor whiteColor];
                profCell.lbl_Position.text =  [PrM.position stringByDecodingHTMLEntities];
                profCell.lbl_Position.backgroundColor = [UIColor whiteColor];
                if([PrM.current_prof isEqualToString:@"1"]){
                    profCell.lbl_duration.text = [NSString stringWithFormat:@"%@ %@ - Present \u2022 %@",PrM.start_month, PrM.start_date,[PrM.location stringByDecodingHTMLEntities]];
                }else{
                    profCell.lbl_duration.text = [NSString stringWithFormat:@"%@ %@ - %@ %@ \u2022 %@",PrM.start_month, PrM.start_date,PrM.end_month,PrM.end_date,[PrM.location stringByDecodingHTMLEntities]];
                }
                profCell.lbl_duration.backgroundColor = [UIColor whiteColor];
                profCell.img_company.image =[UIImage imageNamed:@"exp_default.png"];
                profCell.img_company.backgroundColor =[UIColor clearColor];
            }
            return profCell;
            break;
            
        case 5:
            if (bInfoCell==nil) {
                bInfoCell = [[BasicInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:connCellIdentifier];
            }
            for(SpecialityModel *spM in profileData.SpecArr){
                if([specility isEqualToString:@""]){
                    specility = spM.speciality_name;
                }else{
                    specility = [NSString stringWithFormat:@"%@, %@",specility,spM.speciality_name];
                }
            }
            for(InterestModel *intM in profileData.interestArr){
                if([Interest isEqualToString:@""]){
                    Interest = intM.interest_name;
                }else{
                    Interest = [NSString stringWithFormat:@"%@, %@",Interest,intM.interest_name];
                }
            }
            if(isDataGet){
                bInfoCell.lbl_speciality.text = [specility  stringByDecodingHTMLEntities];
                bInfoCell.lbl_Interest.text = [Interest  stringByDecodingHTMLEntities];
                bInfoCell.lbl_speciality.backgroundColor = [UIColor whiteColor];
                bInfoCell.lbl_Interest.backgroundColor = [UIColor whiteColor];
                bInfoCell.lbl_basicInfoStatic.text = @"Basic Information";
                bInfoCell.lbl_specializationStatic.text = @"Specialization";
                bInfoCell.lbl_interestStatic.text = @"Interest";
                bInfoCell.lbl_specializationStatic.backgroundColor = [UIColor whiteColor];
                bInfoCell.lbl_interestStatic.backgroundColor = [UIColor whiteColor];
                bInfoCell.lbl_basicInfoStatic.backgroundColor = [UIColor whiteColor];
            }
            return bInfoCell;
            break;
            
        default:
            if (pInfoCell==nil) {
                pInfoCell = [[PersonalInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pInofCellIdentifier];
            }
             if(isDataGet){
                pInfoCell.lbl_emailInfo.text = [profileData.email stringByDecodingHTMLEntities];
                pInfoCell.lbl_contactInfo.text = [profileData.mobile  stringByDecodingHTMLEntities];
                pInfoCell.lbl_emailInfo.backgroundColor = [UIColor whiteColor];
                pInfoCell.lbl_contactInfo.backgroundColor = [UIColor whiteColor];
                pInfoCell.lbl_Contact.text = @"Contact";
                pInfoCell.lbl_email.text = @"Email";
                pInfoCell.lbl_Contact.backgroundColor = [UIColor whiteColor];
                pInfoCell.lbl_email.backgroundColor = [UIColor whiteColor];
                pInfoCell.img_email.image = [UIImage imageNamed:@"email.png"];
                pInfoCell.img_contact.image = [UIImage imageNamed:@"contact"];
                pInfoCell.img_email.backgroundColor = [UIColor clearColor];
                pInfoCell.img_contact.backgroundColor = [UIColor clearColor];
            }
            return pInfoCell;
            break;
     }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // NSLog(@"heightForHeaderInSection");
    NSInteger sectionHeight = 0;
    switch (section) {
        case 0:
            sectionHeight = 0;
            break;
        case 1:
            for(ProfessionModel *PrM in profileData.ProfessionArr){
                if([PrM.current_prof isEqualToString:@"1"]){
                    sectionHeight = 50;
                    break;
                }
            }
            break;
        case 2:
            sectionHeight = 50;
            break;
        case 3:
            if([profileData.eduArr count]>0){
                sectionHeight = 50;
            }
            break;
        case 4:
            if([profileData.ProfessionArr count]>0){
                sectionHeight = 50;
            }
            break;
        case 5:
            sectionHeight = 50;
            break;
        case 6:
            sectionHeight = 50;
            break;
        default:
            sectionHeight = 15;
            break;
    }
    return sectionHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // NSLog(@"Sec = %ld, row = %ld",(long)indexPath.section,(long)indexPath.row);
    if (indexPath.section==6) {
        // [self.TableView add];
        if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
            [self editProfileBtnClick];
        }
        else{
            FriendModel *fmodal = profileData.FriendDic;
            if([fmodal.friend_status isEqualToString:@"1"])
            {
               // [self chatBtnClick];  //Start Chat
                
            }else if([fmodal.friend_status isEqualToString:@"0"]){
                
              //  [self frndRequestBtnClick];   // Add a new Friend
                
            }
            else if([fmodal.friend_status isEqualToString:@"8"]){
                //StatusCell.img_status.image = [UIImage imageNamed:@"accept-req.png"];//Accept
               // [self AcceptRequestBtnClick];     // Accept Friend request
            }
            else if([fmodal.friend_status isEqualToString:@"9"]){
                //StatusCell.img_status.image = [UIImage imageNamed:@"req-sent.png"];//req sent
            }
        }
    }
}


#pragma mark - Recieve Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get userCourseListRequest
-(void)getProfileServiceWithCustId:(NSString*)custid{
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[DocquityServerEngine sharedInstance]viewProfileWithAuthKey:[userPref valueForKey:userAuthKey] custom_id:custid device_type:kDeviceType ipAddress:[userPref valueForKey:ip_address1] app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
        //  NSLog(@"responseObject get profile:%@",responseObject);
         [refreshControl endRefreshing];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if(error){
             if (error.code == NSURLErrorTimedOut) {
                 //time out error here
                 [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];

             }else{
                // [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }
         }else
         {
             // NSLog(@"responseObject get profile:%@",responseObject);
             NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
             if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil)
             {
                 // tel is null
             }else
             {
                 if([[resposeDic valueForKey:@"status"]integerValue] == 1)
                 {
                     NSMutableDictionary *dataDic=[resposeDic objectForKey:@"data"];
                     if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                     {
                         // tel is null
                     }else{
                         
                         //Profile Data Entry Start
                         profileData.assoMArr = [[NSMutableArray alloc]init];
                         profileData.eduArr = [[NSMutableArray alloc]init];
                         profileData.interestArr = [[NSMutableArray alloc]init];
                         profileData.ProfessionArr = [[NSMutableArray alloc]init];
                         profileData.SpecArr = [[NSMutableArray alloc]init];
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
                                 [profileData.assoMArr addObject:proAss];
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
                                 [profileData.eduArr addObject:eduModel];
                             }
                         }
                         
                         if([intArr isKindOfClass:[NSMutableArray class]] || intArr !=nil){
                             for(NSMutableDictionary *intDic in intArr){
                                 InterestModel *intModel = [InterestModel new];
                                 intModel.interest_id = [intDic valueForKey:@"interest_id"];
                                 intModel.interest_name = [intDic valueForKey:@"interest_name"];
                                 [profileData.interestArr addObject:intModel];
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
                                 [profileData.ProfessionArr addObject:profModel];
                             }
                         }
                         if([specArr isKindOfClass:[NSMutableArray class]] || specArr !=nil){
                             for(NSMutableDictionary *specDic in specArr){
                                 SpecialityModel *specModel = [SpecialityModel new];
                                 specModel.speciality_id = [specDic valueForKey:@"speciality_id"];
                                 specModel.speciality_name = [specDic valueForKey:@"speciality_name"];
                                 [profileData.SpecArr addObject:specModel];
                             }
                         }
                         if([frndDic isKindOfClass:[NSMutableDictionary class]] || frndDic !=nil){
                             FriendModel *frndModel = [FriendModel new];
                             frndModel.friend_status = [NSString stringWithFormat:@"%@",[frndDic valueForKey:@"friend_status"]];
                             frndModel.frnd_stmsg = [frndDic valueForKey:@"friend_status_message"];
                             profileData.FriendDic = frndModel;
                         }
                         if([profileDic isKindOfClass:[NSMutableDictionary class]] || profileDic !=nil){
                             profileData.user_id = [profileDic valueForKey:@"user_id"];
                             profileData.name = [profileDic valueForKey:@"name"];
                             profileData.first_name = [profileDic valueForKey:@"first_name"];
                             profileData.custom_id = [profileDic valueForKey:@"custom_id"];
                             profileData.last_name = [profileDic valueForKey:@"last_name"];
                             profileData.chat_id =   [profileDic valueForKey:@"chat_id"];
                             profileData.jabber_id = [profileDic valueForKey:@"jabber_id"];
                             profileData.jabber_name =   [profileDic valueForKey:@"jabber_name"];
                             profileData.email = [profileDic valueForKey:@"email"];
                             profileData.country_code = [profileDic valueForKey:@"country_code"];
                             profileData.mobile = [profileDic valueForKey:@"mobile"];
                             profileData.country = [profileDic valueForKey:@"country"];
                             profileData.city = [profileDic valueForKey:@"city"];
                             profileData.state = [profileDic valueForKey:@"state"];
                             profileData.bio = [profileDic valueForKey:@"bio"];
                            
                             profileData.bio  = [profileData.bio stringByReplacingOccurrencesOfString:@"<br>" withString: @""];
                             profileData.bio = [profileData.bio stringByReplacingOccurrencesOfString:@"<br/>" withString: @""];
                             profileData.bio = [profileData.bio stringByReplacingOccurrencesOfString:@"<br />" withString: @""];
                             profileData.profile_pic_path = [profileDic valueForKey:@"profile_pic_path"];
                             if([[profileDic valueForKey:@"total_cme_points"] isKindOfClass:[NSNull class]]){
                                 profileData.total_cme_points = @"0";
                             }else {
                                 profileData.total_cme_points = [profileDic valueForKey:@"total_cme_points"];
                             }
                             if([[profileDic valueForKey:@"total_point"] isKindOfClass:[NSNull class]]){
                                 profileData.total_refer_points = @"0";
                             }else {
                                 profileData.total_refer_points = [profileDic valueForKey:@"total_point"];
                             }
                             profileData.total_connection = [profileDic valueForKey:@"total_connection"];
                             [self.avatarImg sd_setImageWithURL:[NSURL URLWithString:[profileDic valueForKey:@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"default_profile.png"] options:SDWebImageRefreshCached];
                             
                             self.navTitle.text = [[[self.profileData.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString];
                             
                             self.lbl_userName.text = [profileData.name stringByDecodingHTMLEntities];
                             self.lbl_city.text = [profileData.city stringByDecodingHTMLEntities];
                             self.lbl_userName.backgroundColor = [UIColor clearColor];
                             self.lbl_city.backgroundColor = [UIColor clearColor];
                             if([profileData.SpecArr count]>0){
                                 self.lbl_Speciality.text = [profileData.SpecArr objectAtIndex:0].speciality_name;
                                 self.lbl_Speciality.backgroundColor = [UIColor clearColor];
                             }else{
                                 self.lbl_Speciality.hidden = YES;
                             }
                         }
                     }
                     
                     //Profile Data Entry End
                     isDataGet = YES;
                     [self.TableView reloadData];
                     [self.headerBackImg sd_setImageWithURL:[NSURL URLWithString:profileData.profile_pic_path]
                                           placeholderImage:[UIImage imageNamed:@""]
                                                    options:SDWebImageRefreshCached
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                      self.headerBackImg.image = [self blurWithCoreImage:self.headerBackImg.image];
                                                  }];
                    if(isDataGet){
                        self.view_status.backgroundColor = kNewCOAColor;
                         if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
                             self.view_action.hidden = false;
                             self.lbl_status.text = @"EDIT PROFILE";
                             self.img_status.image = [UIImage imageNamed:@"profile-edit.png"];
                         }else{
                             //FriendModel *fmodal = profileData.FriendDic;
                             self.view_action.hidden = false;
                             [self friendStatusLabelUpdate];/*
                             self.lbl_status.text = fmodal.frnd_stmsg;
                             if([fmodal.friend_status isEqualToString:@"1"])
                             {
                                 self.img_status.image = [UIImage imageNamed:@"whitechat.png"]; // friend
                             }else if([fmodal.friend_status isEqualToString:@"0"]){
                                 self.img_status.image = [UIImage imageNamed:@"add-friend.png"]; //Add friend
                             }else if([fmodal.friend_status isEqualToString:@"8"]){
                                 self.img_status.image = [UIImage imageNamed:@"accept-req.png"];//Accept friend
                             }else if([fmodal.friend_status isEqualToString:@"9"]){
                                 self.img_status.image = [UIImage imageNamed:@"req-sent.png"]; //req sent
                             }*/
                         }
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
                     
                 }
             }
         }
     }];
}

-(void)friendStatusLabelUpdate{
     FriendModel *fmodal = profileData.FriendDic;
    self.lbl_status.text = @"Start Chat";//fmodal.frnd_stmsg;
    if([fmodal.friend_status isEqualToString:@"1"])
    {
        self.img_status.image = [UIImage imageNamed:@"whitechat.png"]; // friend
    }else if([fmodal.friend_status isEqualToString:@"0"]){
        self.img_status.image = [UIImage imageNamed:@"whitechat.png"]; //Add friend
    }else if([fmodal.friend_status isEqualToString:@"8"]){
        self.img_status.image = [UIImage imageNamed:@"whitechat.png"];//Accept friend
    }else if([fmodal.friend_status isEqualToString:@"9"]){
        self.img_status.image = [UIImage imageNamed:@"whitechat.png"]; //req sent
    }
}

-(void)addBackButtonWithAnimation:(BOOL)animated{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(GobackView)];
    //  self.navigationItem.leftBarButtonItem = backButton;
    // backButton.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -6;
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton] animated:animated];
}

-(void)GobackView
{
//    if ([AppDelegate appDelegate].comefromsearch == YES) {
//        [AppDelegate appDelegate].isbackUpdateCheckFromSearch = YES;
//    }
//    else if ([AppDelegate appDelegate].isComeFromSettingVC == NO) {
//        [[AppDelegate appDelegate] navigateToTabBarScren:4];
//    }
//    else{
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
-(void)backView:(UIBarButtonItem*)sender{
   }
 */

-(void)editProfileBtnClick{
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
        EditProfileVC *editP = [[EditProfileVC  alloc]init];
        editP.data = profileData;
        editP.delegate = self;
       // _isopenEditProfile = YES;
       // editP.hidesBottomBarWhenPushed =YES;
        [self.navigationController pushViewController:editP animated:YES];
    }
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
    self.avatarImg.image = [self getImage:@"MyProfileImage.png"];
    self.headerBackImg.image = [self getImage:@"MyProfileImage.png"];
}

- (IBAction)didPressActionBtn:(id)sender {
    // [self.TableView add];
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        [self editProfileBtnClick];
    }
    else{
        [self qbStartChat];
        return;
        FriendModel *fmodal = profileData.FriendDic;
        if([fmodal.friend_status isEqualToString:@"1"])
        {
           // [self chatBtnClick];  //Start Chat
            NSString *fullName = @"";
            NSString *loginid = @"";
            NSUInteger chatID = 0;
            QBUUser *User = [QBUUser new];
            NSString *cid =  profileData.chat_id;
         
            if([cid isKindOfClass:[NSNull class]]){
                cid = @"0";
            }
            chatID = cid.integerValue;
            loginid = profileData.jabber_id;
            fullName = [NSString stringWithFormat:@"%@ %@",profileData.first_name, profileData.last_name];
            selectedFCustid  = [NSString stringWithFormat:@"%@",profileData.custom_id];
            selectedFStatus = fmodal.friend_status;
            if(chatID == 0){
//                [self singleButtonAlertViewWithAlertTitle:AppName message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] buttonTitle:@"OK"];
//                return;
                UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                confAl.tag = 888;
                [confAl show];
                return;
             }
            User.ID = chatID;
            User.login = loginid;
            User.fullName = fullName;
            selectedFStatus = @"1";
//            [self joinChatWithUser:User];
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
            else{
                [self joinChatWithUser:User];
            }
         }
        else if([fmodal.friend_status isEqualToString:@"0"]){
            
            NSString *fullName = @"";
            NSString *loginid = @"";
            NSUInteger chatID = 0;
            QBUUser *User = [QBUUser new];
            NSString *cid =  profileData.chat_id;
            
            if([cid isKindOfClass:[NSNull class]]){
                cid = @"0";
            }
            chatID = cid.integerValue;
            loginid = profileData.jabber_id;
            fullName = [NSString stringWithFormat:@"%@ %@",profileData.first_name, profileData.last_name];
            selectedFCustid  = [NSString stringWithFormat:@"%@",profileData.custom_id];
            if(chatID == 0){
                //                [self singleButtonAlertViewWithAlertTitle:AppName message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] buttonTitle:@"OK"];
                //                return;
                UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                confAl.tag = 888;
                [confAl show];
                return;
            }
            User.ID = chatID;
            User.login = loginid;
            User.fullName = fullName;
            selectedFStatus = @"1";
            //[self joinChatWithUser:User];
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
            else{
                [self joinChatWithUser:User];
            }
            // [self frndRequestBtnClick];   // Add a new Friend
            
        }else if([fmodal.friend_status isEqualToString:@"8"]){
            NSString *fullName = @"";
            NSString *loginid = @"";
            NSUInteger chatID = 0;
            QBUUser *User = [QBUUser new];
            NSString *cid =  profileData.chat_id;
            
            if([cid isKindOfClass:[NSNull class]]){
                cid = @"0";
            }
            chatID = cid.integerValue;
            loginid = profileData.jabber_id;
            fullName = [NSString stringWithFormat:@"%@ %@",profileData.first_name, profileData.last_name];
            selectedFCustid  = [NSString stringWithFormat:@"%@",profileData.custom_id];
            if(chatID == 0){
                //                [self singleButtonAlertViewWithAlertTitle:AppName message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] buttonTitle:@"OK"];
                //                return;
                UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                confAl.tag = 888;
                [confAl show];
                return;
            }
            User.ID = chatID;
            User.login = loginid;
            User.fullName = fullName;
            selectedFStatus = @"1";
//            [self joinChatWithUser:User];
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
            else{
                [self joinChatWithUser:User];
            }
            //StatusCell.img_status.image = [UIImage imageNamed:@"accept-req.png"];//Accept
           // [self AcceptRequestBtnClick];     // Accept Friend request
        }else if([fmodal.friend_status isEqualToString:@"9"]){
            NSString *fullName = @"";
            NSString *loginid = @"";
            NSUInteger chatID = 0;
            QBUUser *User = [QBUUser new];
            NSString *cid =  profileData.chat_id;
            
            if([cid isKindOfClass:[NSNull class]]){
                cid = @"0";
            }
            chatID = cid.integerValue;
            loginid = profileData.jabber_id;
            fullName = [NSString stringWithFormat:@"%@ %@",profileData.first_name, profileData.last_name];
            selectedFCustid  = [NSString stringWithFormat:@"%@",profileData.custom_id];
            if(chatID == 0){
                //                [self singleButtonAlertViewWithAlertTitle:AppName message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] buttonTitle:@"OK"];
                //                return;
                UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                confAl.tag = 888;
                [confAl show];
                return;
            }
            User.ID = chatID;
            User.login = loginid;
            User.fullName = fullName;
            selectedFStatus = @"1";
//            [self joinChatWithUser:User];
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
            else{
                [self joinChatWithUser:User];
            }
            //StatusCell.img_status.image = [UIImage imageNamed:@"req-sent.png"];//req sent
        }
    }
}

-(void)qbStartChat{
    FriendModel *fmodal = profileData.FriendDic;
    NSString *fullName = @"";
    NSString *loginid = @"";
    NSUInteger chatID = 0;
    QBUUser *User = [QBUUser new];
    NSString *cid =  profileData.chat_id;
    
    if([cid isKindOfClass:[NSNull class]]){
        cid = @"0";
    }
    chatID = cid.integerValue;
    loginid = profileData.jabber_id;
    fullName = [NSString stringWithFormat:@"%@ %@",profileData.first_name, profileData.last_name];
    selectedFCustid  = [NSString stringWithFormat:@"%@",profileData.custom_id];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (alertView.tag == 888){
        if (buttonIndex == 1) {
            [self didPressoOKforNotifyUpgradeChat];
        }
    }
}

- (IBAction)didPressConnection:(id)sender {
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        /*
        UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"DocquityMain" bundle:nil];
        EarnVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"EarnVC"];
      //  NewProfile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:NewProfile animated:YES];
       // [[AppDelegate appDelegate]navigateToTabBarScren:2];
         */
    }
 }

- (IBAction)didPressCME:(id)sender {
    if([self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [self.customUserId isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        [[AppDelegate appDelegate]navigateToTabBarScren:1];
    }
}

#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
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
            chatController.oppCustid = selectedFCustid;
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

-(void)didPressoOKforNotifyUpgradeChat{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetNotify_to_upgrade_for_chatWithAuthKey:[userdef objectForKey:userAuthKey] custom_id:selectedFCustid device_type:kDeviceType app_version:[userdef objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
          }
        }
    }];
}

-(void)ProfileViewCallWithCustomid:(NSString*)custom_id update_summary:(NSString *)update_summary;
{
   // NSLog(@"custom_id = %@, update_summary = %@" ,custom_id,update_summary);
    self.profileData.bio =   update_summary.mutableCopy;
    [self.TableView reloadData];
}

-(void)ProfileViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state{

    self.profileData.first_name = update_firstName.mutableCopy;
    self.profileData.last_name = update_lastName.mutableCopy;
    self.lbl_userName.text= [NSString stringWithFormat:@"%@ %@",update_firstName.mutableCopy,update_lastName.mutableCopy];
   // self.navTitle.text = [NSString stringWithFormat:@"%@ %@",update_firstName.mutableCopy,update_lastName.mutableCopy];
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

    self.navTitle.text = self.lbl_userName.text;
    
//    if(update_country.length!=0){
//         self.lbl_city.text = [NSString stringWithFormat: @"%@, %@",update_city.mutableCopy,update_country.mutableCopy];
//    }
//    else {
//          self.lbl_city.text = update_city.mutableCopy;
//    }
     [self.TableView reloadData];
}

@end

