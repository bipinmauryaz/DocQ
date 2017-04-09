//
//  NewUserMobileVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewUserMobileVC.h"
#import "NewHomeVC.h"

@interface NewUserMobileVC ()

@end

@implementation NewUserMobileVC

- (void)viewDidLoad {
    [super viewDidLoad];
     count = 0;
    if ([_registered_userType isEqualToString:@"student"]||[_registered_userType isEqualToString:@"doctor"])
    {
        if ([_registered_userType isEqualToString:@"student"]){
        titleLbl.text = kInputMobileLoginTitleMsg;
        }
        if ([_registered_userType isEqualToString:@"doctor"]){
            titleLbl.text = kInputMobileRegisterTitleMsg;
        }
        [self customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:@"Register"];
    }
    else {
        titleLbl.text = kInputMobileLoginTitleMsg;
        [self customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:@"Login"];
    }
//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
//    tfUserMobileNumber.leftView = paddingView;
//    tfUserMobileNumber.leftViewMode = UITextFieldViewModeAlways;
//    tfUserMobileNumber.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"          Mobile Number"] attributes:nil];
    lbl_countryCode.text = _strCountryCode;
    tfMobileView.layer.borderWidth = 1.0f;
    tfMobileView.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    [self nextBtnActivate:false];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length<= [self.strCountryCode length]+3) {
       // textField.text = [NSString stringWithFormat:@"%@  Mobile Number",lbl_countryCode.text];
    }
    [textField resignFirstResponder];
    return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    // Avoid user replacing characters from myString
//    if (range.location < [tfUserMobileNumber.text length]+1)
//    {
//    if (tfUserMobileNumber.text.length==1)
//    {
//     [self nextBtnActivate:false];
//    }
//    else
//    {
//    [self nextBtnActivate:true];
//    }
//    }
//    return YES;
//}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"OnboardingMobileScreen Visit"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingMobileScreen" screenAction:@"OnboardingMobileScreen Visit"];
     [tfUserMobileNumber  becomeFirstResponder];
    [tfUserMobileNumber addTarget:self action:@selector(mobileFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

-(void)mobileFieldDidChange{
    if (count==0)
    {
        if ([tfUserMobileNumber hasText]) {
             [self nextBtnActivate:true];
        }
        else{
           [self nextBtnActivate:false];
        }
    }
    else if (count==1){
        if ([tfUserMobileNumber hasText]) {
             [self nextBtnActivate:true];
        }else{
            [self nextBtnActivate:false];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = accessoryViewTool;
 //  textField.text = [NSString stringWithFormat:@"%@   ",lbl_countryCode.text];
    return YES;
}

#pragma mark - UIButton Actions
-(IBAction)btnDoneClicked:(id)sender{
[Localytics tagEvent:@"OnboardingMobileScreen OTP Request"];
[self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingMobileScreen" screenAction:@"OnboardingMobileScreen OTP Request"];
    if ([self ValidationForOTPGeneration]) {
        [self ServiceHitForSendOTPRequest];
    }
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

#pragma mark - Validations screen
-(BOOL)ValidationForOTPGeneration{

    NSInteger tfMobileIntVal = tfUserMobileNumber.text.integerValue;
    if (([tfUserMobileNumber.text length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please enter mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([tfUserMobileNumber.text length] < 4)|| ([tfUserMobileNumber.text length] > 15)){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (tfMobileIntVal<=999){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }
    return true;
}

#pragma mark - send OTP request
-(void)ServiceHitForSendOTPRequest{
 
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedSpacePhoneNo = [tfUserMobileNumber.text stringByTrimmingCharactersInSet:whitespace];
    [WebServiceCall showHUD];
    NSString * typeOfRequest;
    if ([_registered_userType isEqualToString:@"student"]||[_registered_userType isEqualToString:@"doctor"])
    {
       typeOfRequest = @"register";
    }
    else {
        typeOfRequest = @"Login";
    }
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"country_code" :_countryCode,@"mobile" : trimmedSpacePhoneNo, @"device_token" :[userpref valueForKey:kDeviceTokenKey],@"registered_user_type" :_registered_userType,@"ip_address" :[userpref valueForKey:ip_address1],@"request_type":typeOfRequest ,@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"registration/set?rquest=request_otp" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
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
                    else {
                        if ([typeOfRequest isEqualToString:@"register"]) {
                            [self updateOTPrequstData:resposePost]; // OTP Request
                        }
                        else{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:kMobileNotExistsMsg preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:kTryAgainMsg style:UIAlertActionStyleCancel handler:nil]];
                            [alert addAction:[UIAlertAction actionWithTitle:kSignUPMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                self.navigationController.navigationBar.hidden = YES;
                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
                                NewHomeVC *selfReg = [storyboard instantiateViewControllerWithIdentifier:@"NewHomeVC"];
                               // [userpref setBool:YES forKey:@"firstTimeLogin"];
                                [self.navigationController pushViewController:selfReg animated:YES];

                               // [self.navigationController popViewControllerAnimated:YES]; // New User
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }
                }
                 else if([[resposePost valueForKey:@"status"]integerValue] == 2)
                {
                    [self updateOTPrequstData:resposePost]; // OTP Request
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
        else if (error){
             [SVProgressHUD dismiss];
            NSLog(@"%@",error);
        }
    }];
}

#pragma mark - Store values
-(void)updateOTPrequstData:(NSDictionary*)postDic{
    NSMutableDictionary *dataDic = [postDic objectForKey:@"data"];
    if ([dataDic isKindOfClass:[NSNull class]] || (dataDic == nil))
    {
        // Response is when data dic null checking
    }
    else {
        tokenId =    dataDic[@"token_id"];
        trackId =    dataDic[@"track_id"];
        otpTimer =   dataDic[@"wait"];
        NSUserDefaults*userdef = [NSUserDefaults standardUserDefaults];
        [userdef setObject:tokenId forKey:@"kAppTokenId"];
        [userdef setObject: trackId forKey:@"kAppTrackId"];
        [userdef synchronize];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
        NewMobileVerifyVC *mobileVerify = [storyboard instantiateViewControllerWithIdentifier:@"NewMobileVerifyVC"];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
        NSString *trimmedString = [tfUserMobileNumber.text stringByTrimmingCharactersInSet:whitespace];
        mobileVerify.strContactNumber = trimmedString;
        mobileVerify.OtpcountryCode = _strCountryCode;
        mobileVerify.countryCode = _countryCode;
        mobileVerify.Otpregistered_userType = _registered_userType;
        mobileVerify.assoIdCountNumber = _assoIdCountNumber;
        mobileVerify.Arr_associationId = _assoIdArr.mutableCopy;
        mobileVerify.timerCount = [otpTimer integerValue];
        mobileVerify.OTPassociationDic = _associationDic;
        mobileVerify.verrifyOTPTitleMsg = [NSString stringWithFormat:@"You will recieve One Time Password (OTP) Shortly. This Process may take upto %ld Sec.",(long)otpTimer.integerValue];
        //[postDic valueForKey:@"msg"];
        [self.navigationController pushViewController:mobileVerify animated:YES];
    }
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
