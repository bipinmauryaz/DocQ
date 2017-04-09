//
//  CodeClaimVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "CodeClaimVC.h"

@interface CodeClaimVC ()

@end

@implementation CodeClaimVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:@"Membership ID"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    tfCode.leftView = paddingView;
    tfCode.leftViewMode = UITextFieldViewModeAlways;
    tfCode.layer.borderWidth = 1.0f;
    tfCode.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    count = 0;
    
    tfCode.placeholder = [NSString stringWithFormat:@"%@ (optional)",_strTfplaceholder];
  //  lbl_inviteCodeType.text = @"Input your Membership ID proving that you are a member of the chosen association.";
    NSString *newString;
    NSRange range = [_Strcode_invteType rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        newString = [_Strcode_invteType substringToIndex:range.location];
       lbl_inviteCodeType.text =  [[NSString stringWithFormat:@"Input your %@Number proving that you are a member of the chosen association.",newString]stringByDecodingHTMLEntities];
        // NSLog(@"New string = %@",newString);
    }
    else{
    lbl_inviteCodeType.text =  [[NSString stringWithFormat:@"Input your %@ Number proving that you are a member of the chosen association.",_Strcode_invteType]stringByDecodingHTMLEntities];
    }
  //  lbl_inviteCodeType.text =  [[NSString stringWithFormat:@"Input your %@ proving that you are a member of the chosen association.",_Strcode_invteType]stringByDecodingHTMLEntities];
    [cardImageView sd_setImageWithURL:[NSURL URLWithString:_StrCardFileUrl] placeholderImage:[UIImage imageNamed:@"CardImage.png"] options:SDWebImageRefreshCached];
    
    //Registering Touch event on scroll
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
     
    photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height) dateTitle:nil
                                               title:nil                                           subtitle:nil];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapped:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1.0;
    [cardImageView setUserInteractionEnabled:YES];
    [cardImageView addGestureRecognizer:gesture];
}



- (void)endEditing
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - setClaim AccountUserRequest
-(void)SetClaimAccountUserRequest
{
    NSMutableArray *AssoIdArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"AssociationIdArray"] mutableCopy];
   NSString* associationIdStr = [[AssoIdArray valueForKey:@"description"] componentsJoinedByString:@","];
   NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"country_code" :@"",@"mobile" :@"", @"ic_number" :tfCode.text,@"iso_code":@"",@"association_id":associationIdStr,@"ip_address" :[userpref valueForKey:ip_address1] ,@"device_type":kDeviceType,@"app_version":[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"registration/set?rquest=claim_account" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
            [SVProgressHUD dismiss];
            //NSLog(@"%@",response);
            NSString *newString;
            NSString*icNumberTitleMessage;
            NSDictionary *resposePost =[response objectForKey:@"posts"];
           // NSLog(@"set claim user request %@",resposePost);
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
                // Response is null
        }
        else
        {
        if([[resposePost valueForKey:@"status"]integerValue] == 1)
        {
        
        }
        else if([[resposePost valueForKey:@"status"]integerValue] == 2)
        {
            [self updateClaimUserDefaults:resposePost];
        }
       else if([[resposePost valueForKey:@"status"]integerValue] == 3)
        {
            NSRange range = [_Strcode_invteType rangeOfString:@"-"];
            if (range.location != NSNotFound) {
               newString = [_Strcode_invteType substringToIndex:range.location];
                icNumberTitleMessage = [[NSString stringWithFormat:@"%@Number is not linked to any account.",newString]stringByDecodingHTMLEntities];
                // NSLog(@"New string = %@",newString);
            }
            else{
                icNumberTitleMessage = [[NSString stringWithFormat:@"%@ Number is not linked to any account.",_Strcode_invteType]stringByDecodingHTMLEntities];
                // NSLog(@"New string = %@",newString);
            }
          // is not linked to an account. Click to complete your registration process.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:icNumberTitleMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:kReTryAgainMsg style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:kCountinueMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
                NewUserDetailsVC *newuserdetails = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
                    newuserdetails.registered_userType = _registered_userType;
                [self.navigationController pushViewController:newuserdetails animated:YES]; // Calim New User
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
         else  if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 0)
        {
            [WebServiceCall showAlert:AppName andMessage:[resposePost valueForKeyPath:@"posts.msg"] withController:self];
        }
        else  if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 9)
        {
           [[AppDelegate appDelegate]logOut];
        }
        }
       }
        else if (error)
        {
            [SVProgressHUD dismiss];
            //NSLog(@"%@",error);
        }
    }];
}

- (IBAction)didPressSkip:(id)sender
{
    if ([btnNext.titleLabel.text isEqualToString:@"SKIP"]) {
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
        NewUserDetailsVC *newuserdetails = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
        newuserdetails.registered_userType = _registered_userType;
        [self.navigationController pushViewController:newuserdetails animated:YES];
    }
    else
    {
    [self SetClaimAccountUserRequest];
  }
}

-(void)updateClaimUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *claimdataDic;
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || (resposeCode == nil))
    {
        // Response is null
    }
    else {
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
        // [self downloadWithNsurlconnection];     // Download Profile Picture
        //[self checkLoginUserForQuickblox];      // Checking the quickblox login
    }
    else if([[postDic valueForKey:@"status"] integerValue] == 2)
    {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewUserDetailsVC *newuserdetails = [storyboard instantiateViewControllerWithIdentifier:@"NewUserDetailsVC"];
       // newuserdetails.claimDataDict = claimdataDic;
    newuserdetails.registered_userType = _registered_userType;
    [self.navigationController pushViewController:newuserdetails animated:YES];
     //[self pushToVerifyAccountWithUserFlag:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"OnboardingAssociationInputScreen Visit"];
     [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingAssociationInputScreen" screenAction:@"OnboardingAssociationInputScreen Visit"];
    [tfCode addTarget:self action:@selector(mobileFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - mobile TextFiled
-(void)mobileFieldDidChange{
    if (count==0)
    {
        if ([tfCode hasText]) {
               [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];

           // [self nextBtnActivate:true];
        }
        else{
             [btnNext setTitle:@"SKIP" forState:UIControlStateNormal];
           // [self nextBtnActivate:false];
        }
    }
    else if (count==1){
        if ([tfCode hasText]) {
            [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
           // [self nextBtnActivate:true];
        }
        else{
              [btnNext setTitle:@"SKIP" forState:UIControlStateNormal];
           // [self nextBtnActivate:false];
        }
    }
}

-(void)imgTapped:(UITapGestureRecognizer*)tap{
    [self endEditing];
    [photoView fadeInPhotoViewFromImageView:cardImageView];
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
