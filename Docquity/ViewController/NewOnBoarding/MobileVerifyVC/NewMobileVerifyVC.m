//
//  MobileVerifyVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewMobileVerifyVC.h"
#import "NewUserDetailsVC.h"
#import "NSString+MD5.h"
#import "ServicesManager.h"
#import "DocquityServerEngine.h"
#import "CodeClaimVC.h"

@interface NewMobileVerifyVC (){
   
}

@end

@implementation NewMobileVerifyVC
@synthesize btnResendOTP;

- (void)viewDidLoad {
    count =0;
    [super viewDidLoad];
    if ([_Otpregistered_userType isEqualToString:@"student"]||[_Otpregistered_userType isEqualToString:@"doctor"])
    {
        [self customizeNavigationBarWithHeaderLogoImageAndBackCheckBarButtonItems:@"Register"];
    }
    else {
        [self customizeNavigationBarWithHeaderLogoImageAndBackCheckBarButtonItems:@"Login"];
    }

    _lblOTPMessage.text = @"You will recieve One Time Password (OTP) Shortly.";//_verrifyOTPTitleMsg;
    [self ResendOTPBtnActivate:FALSE];
    isOTPResend = FALSE;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:YES];
    [timer fire];
 
    tfMobileView.layer.borderWidth = 1.0f;
    tfMobileView.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    lblCountryCode.text = [NSString stringWithFormat:@"%@",_strContactNumber];
      lbl_OTPcountryCode.text = _OtpcountryCode;
   // lblCountryCode.text = [NSString stringWithFormat:@"          %@",_strContactNumber];
    //[NSString stringWithFormat:@"   %@",_strContactNumber];
    [self SetTextFieldBorder:_tfOTP1 withColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]];

    [self SetTextFieldBorder:_tfOTP2 withColor:[UIColor lightGrayColor]];
    [self SetTextFieldBorder:_tfOTP3 withColor:[UIColor lightGrayColor]];
    [self SetTextFieldBorder:_tfOTP4 withColor:[UIColor lightGrayColor]];
    [self nextBtnActivate:false];
    [_tfOTP1 becomeFirstResponder];
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
//}

-(void)viewWillAppear:(BOOL)animated{
  [Localytics tagEvent:@"OnboardingMobileScreen Verify OTP"];  
    [_tfOTP4 addTarget:self action:@selector(mobileFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

-(void)mobileFieldDidChange{
    if (count==0)
    {
        if ([_tfOTP4 hasText]) {
            [self nextBtnActivate:true];
        }
        else{
            [self nextBtnActivate:false];
        }
    }
    else if (count==1){
        if ([_tfOTP4 hasText]) {
            [self nextBtnActivate:true];
        }else{
            [self nextBtnActivate:false];
        }
    }
}

-(void)ResendOTPBtnActivate:(BOOL)flag{
    self.btnResendOTP.enabled = flag;
    if(!flag)
        self.btnResendOTP.alpha = 0.5;
    else
        self.btnResendOTP.alpha = 1.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)timerCountdown{
    if (_timerCount<0) {
        [timer invalidate];
        self.btnResendOTP.hidden = isOTPResend;
    }
    else {
         lblTimer.text = [NSString stringWithFormat:@"00:%02ld",(long)_timerCount];
        _timerCount--;
        if (_timerCount==0) {
         [self ResendOTPBtnActivate:TRUE];
        }
    }
}

-(void)ResendOTPtimerCountdown{
     if (waitingtimerCount<0) {
        [timer invalidate];
       // self.btnResendOTP.hidden = isOTPResend;
    }
    else {
        lblTimer.text = [NSString stringWithFormat:@"00:%02ld",(long)waitingtimerCount];
        waitingtimerCount--;
    }
}

#pragma mark - Textfield Bottom Layer Color
-(void)SetTextFieldBorder :(UITextField *)textField withColor:(UIColor *)color{
    CALayer *border = [CALayer layer];
    border.borderColor = color.CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - 2, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = 2;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
}

#pragma mark - btnResendOTP
-(IBAction)btnResendOTP:(id)sender{
     [Localytics tagEvent:@"OnboardingMobileScreen Resend OTP"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingMobileScreen" screenAction:@"OnboardingMobileScreen Resend OTP"];
    if ([self ValidationForOTPGeneration]) {
        [self ServiceHitForReSendOTPRequest];
        [self ResendOTPBtnActivate:FALSE];
        isOTPResend = YES;
    }
}

#pragma mark - Validations screen
-(BOOL)ValidationForOTPGeneration{
    NSInteger tfMobileIntVal = lblCountryCode.text.integerValue;
    if (([lblCountryCode.text length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please enter mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([lblCountryCode.text length] < 4)|| ([lblCountryCode.text length] > 15)){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (tfMobileIntVal<=999){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }
    return true;
}

-(IBAction)btnEditButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UItextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.inputAccessoryView = accessoryViewTool;
    [self SetTextFieldBorder:textField withColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]];
//  [textField becomeFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self SetTextFieldBorder:textField withColor:[UIColor lightGrayColor]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length>1) {
        return NO;
    }else if (newString.length == 0){
        [self SetTextFieldBorder:textField withColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]];
        return YES;
    }
    if (newString.length>0) {
        switch (textField.tag) {
            case 11:
                [self performSelector:@selector(setNextResponder:) withObject:_tfOTP2 afterDelay:0.01];
                break;
             case 22:
                [self performSelector:@selector(setNextResponder:) withObject:_tfOTP3 afterDelay:0.01];
                break;
            case 33:
                [self performSelector:@selector(setNextResponder:) withObject:_tfOTP4 afterDelay:0.01];
                break;
            case 44:
                [self performSelector:@selector(removeKeyBoard:) withObject:_tfOTP4 afterDelay:0.1];
                break;
            default:
                break;
        }
    }
    [self SetTextFieldBorder:textField withColor:[UIColor lightGrayColor]];
    return YES;
}

- (void)setNextResponder:(UITextField *)nextResponder
{
    [nextResponder becomeFirstResponder];
    [self SetTextFieldBorder:nextResponder withColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]];
}

-(void)removeKeyBoard:(UITextField *)nextResponder{
    //[_tfOTP4 resignFirstResponder];
    [self SetTextFieldBorder:nextResponder withColor:[UIColor lightGrayColor]];
}

-(IBAction)btnNextClicked:(id)sender{
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingMobileScreen" screenAction:@"OnboardingMobileScreen OTP Verified"];
    [ self SetMobileVerifyRequest];
 }

#pragma mark - uploadBtnActive
-(void)nextBtnActivate:(BOOL)flag{
   self.btnNext.enabled = flag;
    if(!flag){
    accessoryViewTool.barTintColor = [UIColor colorWithRed:46.0/255.0 green:194.0/255.0 blue:123.0/255.0 alpha:1.0];
    self.nextBarBt.enabled = NO;
    }
    else{
    accessoryViewTool.barTintColor =  [UIColor colorWithRed:43.0/255.0 green:181.0/255.0 blue:115.0/255.0 alpha:1.0];
    self.nextBarBt.enabled = YES;
}
   //self.btnNext.alpha = 1.0;
}

#pragma mark - Resend OTP request
-(void)ServiceHitForReSendOTPRequest{
    [WebServiceCall showHUD];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"country_code" :_countryCode,@"mobile" :lblCountryCode.text, @"iso_code":@"",@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"registration/set?rquest=resend_otp" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
           [SVProgressHUD dismiss];
           // NSLog(@"%@",response);
            NSDictionary *resposePost =[response objectForKey:@"posts"];
          //  NSLog(@"post data %@",resposePost);
            if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
            {
                // Response is null
            }
            else
            {
                if([[resposePost valueForKey:@"status"]integerValue] == 1)
                {
                    NSMutableDictionary *dataDic = [resposePost objectForKey:@"data"];
                    if ([dataDic isKindOfClass:[NSNull class]] || (dataDic == nil))
                    {
                        // Response is when data dic null checking
                    }
                    else
                    {
                        NSString* waitingTime =  dataDic[@"wait"];
                        waitingtimerCount = waitingTime.integerValue;
                        [UIView animateWithDuration:0.5 animations:^{
                            _tfOTP1.text = @"";
                            _tfOTP2.text = @"";
                            _tfOTP3.text = @"";
                            _tfOTP4.text = @"";
                            [self ResendOTPBtnActivate:FALSE];
                         //  self.lblOTPMessage.text = [NSString stringWithFormat:@"You will recieve One Time Password (OTP) Shortly. This Process may take upto %ld Sec.",(long)waitingTime.integerValue];
                            [self SetTextFieldBorder:_tfOTP1 withColor:[UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0]];
                            [self SetTextFieldBorder:_tfOTP2 withColor:[UIColor lightGrayColor]];
                            [self SetTextFieldBorder:_tfOTP3 withColor:[UIColor lightGrayColor]];
                            [self SetTextFieldBorder:_tfOTP4 withColor:[UIColor lightGrayColor]];
                            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ResendOTPtimerCountdown) userInfo:nil repeats:YES];
                            [timer fire];
                        }];
                    }
                }
                else  if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 0)
                {
                    [WebServiceCall showAlert:AppName andMessage:[resposePost valueForKey:@"msg"] withController:self];
                }
                else if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 9)
                {
                    [[AppDelegate appDelegate]logOut];
                }
            }
        }
        else if (error)
        {
        [SVProgressHUD dismiss];
        // NSLog(@"%@",error);
        }
    }];
}

#pragma mark - setVerifyMobileRequest
-(void)SetMobileVerifyRequest
{
    NSString*finalOTP = [NSString stringWithFormat:@"%@%@%@%@",_tfOTP1.text,_tfOTP2.text,_tfOTP3.text,_tfOTP4.text];
     [WebServiceCall showHUD];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"country_code" :_OtpcountryCode,@"mobile" :lblCountryCode.text, @"device_token" :[userpref valueForKey:kDeviceTokenKey],@"device_info":[WebServiceCall deviceInfodetails],@"user_type":@"",@"otp":[finalOTP MD5],@"iso_code":@"",@"registered_user_type":_Otpregistered_userType,@"ip_address" :[userpref valueForKey:ip_address1] ,@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"registration/set.php?rquest=verify_mobile" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
           // [SVProgressHUD dismiss];
           // NSLog(@"%@",response);
            // NSLog(@"%@",responseDict);
            NSDictionary *resposePost =[response objectForKey:@"posts"];
           // NSLog(@"set mobile request %@",resposePost);
            if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
            {
                // Response is null
            }
            else
            {
                if([[resposePost valueForKey:@"status"]integerValue] == 1)
                {
                    [self updateUserDefaults:resposePost]; // Login
                    // NSLog(@"%check sucuess@",tes)
                }
                else if([[resposePost valueForKey:@"status"]integerValue] == 2)
                {
                    [self updateClaimUserDefaults:resposePost]; // Claim User
                }
                 else if([[resposePost valueForKey:@"status"]integerValue] == 3)
                 {
                    [self callingViewController];
                   //[self pushToVerifyAccountWithUserFlag:NO];
                 }
                else  if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 0)
                {
                [SVProgressHUD dismiss];
                [WebServiceCall showAlert:AppName andMessage:[resposePost valueForKey:@"msg"] withController:self];
                }
                else if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 9)
                {
                    [SVProgressHUD dismiss];
                    [[AppDelegate appDelegate]logOut];
                }
            }
        }
        else if (error){
          [SVProgressHUD dismiss];
            //NSLog(@"%@",error);
        }
    }];
}

#pragma mark - Store values
-(void)updateUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || (resposeCode == nil))
    {
        // Response is null
    }
    else {
        NSMutableDictionary *logindataDic = [resposeCode objectForKey:@"login_data"];
        if ([logindataDic isKindOfClass:[NSNull class]] || (logindataDic == nil))
        {
            // Response is null
        }
        else
        {
    NSString*userpermision = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"permission"]?[logindataDic  objectForKey:@"permission"]:@""];
    [userpref setObject:userpermision?userpermision:@"" forKey:user_permission];
      NSString* userCity = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"city"]?[logindataDic  objectForKey:@"city"]:@""];
        [userpref setObject:userCity?userCity:@"" forKey:user_city];
       NSString* userCountry = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"country"]?[logindataDic  objectForKey:@"country"]:@""];
        [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
        NSString* userCountryCode = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"country_code"]?[logindataDic  objectForKey:@"country_code"]:@""];
        [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
       NSString* userType  = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"user_type"]?[logindataDic  objectForKey:@"user_type"]:@""];
        NSString*  customId =[NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"custom_id"]?[logindataDic  objectForKey:@"custom_id"]:@""];
        [userpref setObject:customId?customId:@"" forKey:ownerCustId];
        [userpref setObject:customId?customId:@"" forKey:custId];
        NSString* u_email = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"email"]?[logindataDic  objectForKey:@"email"]:@""];
        [userpref setObject:u_email?u_email:@"" forKey:emailId1];
        NSString*  u_fName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"first_name"]?[logindataDic  objectForKey:@"first_name"]:@""];
        [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
       JabberName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"jabber_name"]?[logindataDic objectForKey:@"jabber_name"]:@""];
        [userpref setObject:JabberName?JabberName:@"" forKey:kjabberName];
       NSString*   u_lName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"last_name"]?[logindataDic  objectForKey:@"last_name"]:@""];
        [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
         NSString*   userMobNo = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"mobile"]?[logindataDic  objectForKey:@"mobile"]:@""];
        [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
         userPic = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"profile_pic_path"]?[logindataDic  objectForKey:@"profile_pic_path"]:@""];
        [userpref setObject:userPic?userPic:@"" forKey:profileImage];
        NSString* userRegNo = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"registration_no"]?[logindataDic  objectForKey:@"registration_no"]:@""];
        [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        
        NSString*  userState = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"state"]?[logindataDic  objectForKey:@"state"]:@""];
        [userpref setObject:userState?userState:@"" forKey:user_state];
        
       NSString*  uId=[NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"user_id"]?[logindataDic  objectForKey:@"user_id"]:@""];
        [userpref setObject:uId?uId:@"" forKey:userId];
        NSString* refLink = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"referal_id"]?[logindataDic  objectForKey:@"referal_id"]:@""];
        [userpref setObject:refLink?refLink:@"" forKey:shareRefLink];
        [userpref synchronize];
      NSString* u_authkey = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"user_auth_key"]?[logindataDic objectForKey:@"user_auth_key"]:@""];
        [userpref setObject:u_authkey?u_authkey:@"" forKey:userAuthKey];
        [userpref synchronize];
            
        chatId =[NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"chat_id"]?[logindataDic objectForKey:@"chat_id"]:@""];
        [userpref setObject:chatId?chatId:@"" forKey:chatId1];
        jabberPassword=[NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"password"]?[logindataDic objectForKey:@"password"]:@""];
        [userpref setObject:jabberPassword?jabberPassword:@"" forKey:password1];
        [userpref synchronize];
    }
}
    if([[postDic valueForKey:@"status"] integerValue] == 1)
   {
       [self downloadWithNsurlconnection]; // Download Profile Picture
        [self checkLoginUserForQuickblox];  // Checking the quickblox login
      // [self pushToFeedVc];
    }
   else if([[postDic valueForKey:@"status"] integerValue] == 2)
   {
       [self pushToVerifyAccountWithUser:postDic];
  }
}

-(void)updateClaimUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *claimdataDic;
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || (resposeCode == nil))
    {
        // Response is null
    }    else {
        claimdataDic = [resposeCode objectForKey:@"claim_data"];
        if ([claimdataDic isKindOfClass:[NSNull class]] || (claimdataDic == nil))
        {
            // Response is null
        }
        else
        {
            NSString* userCity = [NSString stringWithFormat:@"%@", [claimdataDic objectForKey:@"city"]?[claimdataDic  objectForKey:@"city"]:@""];
            [userpref setObject:userCity?userCity:@"" forKey:user_city];
            NSString* userCountry = [NSString stringWithFormat:@"%@",[claimdataDic objectForKey:@"country"]?[claimdataDic  objectForKey:@"country"]:@""];
            [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
            NSString* userCountryCode = [NSString stringWithFormat:@"%@",[claimdataDic objectForKey:@"country_code"]?[claimdataDic  objectForKey:@"country_code"]:@""];
            [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
            NSString*  userType  = [NSString stringWithFormat:@"%@",[claimdataDic objectForKey:@"user_type"]?[claimdataDic  objectForKey:@"user_type"]:@""];
            NSString* u_email = [NSString stringWithFormat:@"%@", [claimdataDic objectForKey:@"email"]?[claimdataDic  objectForKey:@"email"]:@""];
            [userpref setObject:u_email?u_email:@"" forKey:emailId1];
            NSString*  u_fName = [NSString stringWithFormat:@"%@", [claimdataDic objectForKey:@"first_name"]?[claimdataDic  objectForKey:@"first_name"]:@""];
            [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
           NSString* u_lName = [NSString stringWithFormat:@"%@", [claimdataDic objectForKey:@"last_name"]?[claimdataDic  objectForKey:@"last_name"]:@""];
            [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
            NSString* userMobNo = [NSString stringWithFormat:@"%@",[claimdataDic objectForKey:@"mobile"]?[claimdataDic  objectForKey:@"mobile"]:@""];
            [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
                NSString*  userRegNo = [NSString stringWithFormat:@"%@", [claimdataDic objectForKey:@"registration_no"]?[claimdataDic  objectForKey:@"registration_no"]:@""];
            [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        }
    }
     if([[postDic valueForKey:@"status"] integerValue] == 1)
    {
        [self downloadWithNsurlconnection];  // Download Profile Picture
      [self checkLoginUserForQuickblox];    // Checking the quickblox login
      // [self pushToFeedVc];
    }
    else if([[postDic valueForKey:@"status"] integerValue] == 2)
    {
        [self pushToVerifyAccountWithUser:claimdataDic];
    }
}

-(void)checkLoginUserForQuickblox{
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    if (currentUser != nil) {
      //NSLog(@"user loggedin... Logging Out...");
        [self logoutFromQuickblox];
    }else{
        //   NSLog(@"user not logged in... Logging In...");
        if (([chatId  isEqualToString:@""] || [chatId isEqualToString:@"<null>"]) && ([jabberPassword  isEqualToString:@""] || [jabberPassword isEqualToString:@"<null>"])) {
            [self updatechatCredentialToQuickblox];
        }
        else{
            [self loginInQuickblox];
        }
    }
}

-(void)loginInQuickblox{
    QBUUser *selectedUser = [QBUUser new];
    selectedUser.login = JabberName;
    selectedUser.password = jabberPassword;
    // __weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        [SVProgressHUD dismiss];
        if (success) {
            // __typeof(self) strongSelf = weakSelf;
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            [userpref setBool:YES forKey:signInnormal];
            //  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            //  [strongSelf registerForRemoteNotifications];
            //  [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
            //     NSLog(@"Succss login in quikblox");
            [self pushToFeedVc];
        }
        else
        {
          // [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}

-(void)logoutFromQuickblox{
    dispatch_group_t logoutGroup = dispatch_group_create();
    dispatch_group_enter(logoutGroup);
    // unsubscribing from pushes
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
        //
        dispatch_group_leave(logoutGroup);
    } errorBlock:^(QBError *error) {
        //
        dispatch_group_leave(logoutGroup);
    }];

    // resetting last activity date
    [ServicesManager instance].lastActivityDate = nil;
     dispatch_group_notify(logoutGroup,dispatch_get_main_queue(),^{
        // logging out
        [[QMServicesManager instance] logoutWithCompletion:^{
            if ([chatId isEqualToString:@""] && [jabberPassword isEqualToString:@""]) {
                [self updatechatCredentialToQuickblox];
            }
            else{
                [self loginInQuickblox];
            }
           //[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
        }];
    });
}

#pragma mark -update chatCredentialTo Quickblox Server
-(void)updatechatCredentialToQuickblox{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getChatCredentialCreateWithAuthKey:[userdef objectForKey:userAuthKey] lang:kLanguage app_version:[userdef objectForKey:kAppVersion] device_type:kDeviceType callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            NSDictionary *dataDic=[resposeCode objectForKey:@"data"];
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
            {
                // tel is null
            }
            else {
                chatId  =    dataDic[@"chat_id"];
                JabberName  = dataDic[@"jabber_name"];
                jabberPassword  = dataDic[@"jabber_password"];
                NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
                [userpref setObject:chatId?chatId:@"" forKey:chatId1];
                [userpref setObject:JabberName?JabberName:@"" forKey:kjabberName];
                [userpref setObject:jabberPassword?jabberPassword:@"" forKey:password1];
                [userpref synchronize];
                [self loginInQuickblox];
                //NSLog(@"response from device token update = %@",resposeCode);
            }
        }
    }];
}

#pragma mark - Pushing to views
-(void)pushToFeedVc{
    [SVProgressHUD dismiss];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setBool:YES forKey:signInnormal];
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
}

-(void)pushToVerifyAccountWithUser:(NSDictionary*)userdetailsDic{
    [SVProgressHUD dismiss];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewUserDetailsVC *newuserdetails = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
    newuserdetails.claimDataDict = userdetailsDic;
    newuserdetails.registered_userType = _Otpregistered_userType;
    newuserdetails.associationIdArr = _Arr_associationId.mutableCopy;
    [self.navigationController pushViewController:newuserdetails animated:YES];
}

-(void)callingViewController{
    [SVProgressHUD dismiss];
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    cardImgUrl = [NSString stringWithFormat:@"%@", [_OTPassociationDic valueForKey:@"file_url"]];
    inviteExample  = [NSString stringWithFormat:@"%@", [_OTPassociationDic valueForKey:@"invite_code_example"]];
    invideCodeType  = [NSString stringWithFormat:@"%@", [_OTPassociationDic valueForKey:@"invite_code_type"]];
    if ([_assoIdCountNumber isEqualToString:@"0"]) {
        self.navigationController.navigationBar.hidden = NO;
        NewUserDetailsVC*userdetail = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
         userdetail.registered_userType = _Otpregistered_userType;
        [self.navigationController pushViewController:userdetail animated:YES];
    }
    else if([_Arr_associationId count]>0){
        if ([invideCodeType isEqualToString:@"Mobile"]) {
            self.navigationController.navigationBar.hidden = NO;
            NewUserDetailsVC*userdetail = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
             userdetail.registered_userType = _Otpregistered_userType;
            [self.navigationController pushViewController:userdetail animated:YES];
        }
        else {
            self.navigationController.navigationBar.hidden = NO;
            CodeClaimVC*claimCode = [storyboard instantiateViewControllerWithIdentifier:@"CodeClaimVC"];
            claimCode.StrCardFileUrl = cardImgUrl;
            claimCode.strTfplaceholder = inviteExample;
            claimCode.Strcode_invteType =  invideCodeType;
            claimCode.Claim_MobileNumber = lblCountryCode.text;
            claimCode.Calim_countryCode =  _countryCode;
            claimCode.registered_userType = _Otpregistered_userType;
            [self.navigationController pushViewController:claimCode animated:YES];
        }
    }
    else
    {
            self.navigationController.navigationBar.hidden = NO;
            NewUserDetailsVC*userdetail = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
             userdetail.registered_userType = _Otpregistered_userType;
            [self.navigationController pushViewController:userdetail animated:YES];
    }
}

#pragma mark - download profile
-(void)downloadWithNsurlconnection
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",userPic]];
    // NSLog(@"Login IMG URL : %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    //NSLog(@"connection : %@",connection);
}

#pragma mark - NSURL Connection Delegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    self.RecvimageData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.RecvimageData appendData:data];
    self.receivedBytes += data.length;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *savedImagePath = [[[AppDelegate appDelegate]dataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"MyProfileImage.png"]];
    mediaPath = [NSString stringWithFormat:@"MyProfileImage.png"];
    // NSLog(@"Media Path : %@",mediaPath);
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    UIImage *SaveImage = [UIImage imageWithData:self.RecvimageData];
    NSData *imageData = UIImageJPEGRepresentation(SaveImage, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(SaveImage, compression);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [imageData writeToFile:savedImagePath atomically:NO];
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
