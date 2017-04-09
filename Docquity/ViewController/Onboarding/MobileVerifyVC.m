/*============================================================================
 PROJECT: Docquity
 FILE:    MobileVerifyVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 8/22/16.
 =============================================================================*/


/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define MOBILE_NO_FIELD_MAX_CHAR_LENGTH 11
#define PASSWORD_MAX_CHAR_LENGTH 20

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "MobileVerifyVC.h"
#import "AppDelegate.h"
#import "VerifyYourSelfVC.h"
//#import "NSString+MD5.h"
#import "Localytics.h"
#import "FeedVC.h"
#import "ClaimProfileVC.h"
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "UserChooseVC.h"
#import "ServicesManager.h"
/*============================================================================
 Interface:   MobileVerifyVC
 =============================================================================*/
@interface MobileVerifyVC ()
@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@end

@implementation MobileVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:@"Mobile Verify"];
    didPresentCountry = FALSE;
    _btnResend.hidden = YES;
    _btnEditMobile.hidden = YES;
    isOTPResend = FALSE;
    _btnProceed.layer.cornerRadius = 25.0f;
    _mobileParentView.layer.cornerRadius = 25.0f;
    _tfOTP.layer.cornerRadius = 25.0f;
    [self proceedBtnActivate:FALSE];
    self.lblOTPMessage.text = docUserMsg;
    self.topLblTitleConst.constant = self.heightLblMessage.constant +  self.topLblTitleConst.constant + self.heightTfOTPConst.constant;
//    self.topMobileViewHolderConst.constant = -self.topMobileViewHolderConst.constant ;
    self.topBtnProceedConst.constant = -(self.heightTfOTPConst.constant) ;
    self.bottomLogoConst.constant = - self.topLblTitleConst.constant  + self.bottomLogoConst.constant;
    self.countryArr = [AppDelegate appDelegate].countryListArray;
    if (self.countryArr == nil || self.countryArr.count == 0)
    {
        if([AppDelegate appDelegate].isInternet){
         // [[AppDelegate appDelegate]GetCountryList];
            isCountryFound = NO;
            [self getCountryList];
        }
        else
      [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:@"OK"];
    }
    else
    {
        isCountryFound = YES;
        [self countryPopUp];
    }
    count = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1.0;
    [self.scrollView addGestureRecognizer:tap];
    // }
    if([AppDelegate appDelegate].isInternet){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGFloat halfButtonHeight = self.btnCountryCode.bounds.size.height / 2;
        CGFloat buttonWidth = self.btnCountryCode.bounds.size.width;
        indicator.center = CGPointMake((buttonWidth - halfButtonHeight)/2 , halfButtonHeight);
        [self.btnCountryCode addSubview:indicator];
        [indicator setHidesWhenStopped:YES];
        indicator.tag = 99;
        [indicator startAnimating];
        self.btnCountryCode.enabled = false;
    }else{
        UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
        [indicator stopAnimating];
        self.btnCountryCode.enabled = true;
    }
 }

-(void)hideKeyboard{
   [self.view endEditing:YES];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [self registerNotification];
//}

-(void)viewWillAppear:(BOOL)animated{
    //    [self registerNotification];
    self.popupBackView.hidden = YES;
    // NSLog(@"viewWillAppear");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self registerForKeyboardNotifications];
    [self.tfMobileNumber addTarget:self action:@selector(mobileFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.tfOTP addTarget:self action:@selector(otpFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    self.frndListArr = [[NSMutableArray alloc]init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
}

-(void)viewDidDisappear:(BOOL)animated{
    //NSLog(@"viewDidDisappear");
    self.popupBackView.hidden = YES;
    if (!self.tfOTP.hidden) {
        [self resetConstraints];
    }
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mobileFieldDidChange{
    if (count==0)
    {
        if ([self.tfMobileNumber hasText]) {
            [self proceedBtnActivate:TRUE];
        }
        else{
        [self proceedBtnActivate:FALSE];
        }
     }
    else if (count==1){
        if ([self.tfMobileNumber hasText] && [self.tfOTP hasText]) {
            [self proceedBtnActivate:TRUE];
        }else{
            [self proceedBtnActivate:FALSE];
        }
    }
}

-(void)otpFieldDidChange{
    if ([self.tfMobileNumber hasText] && [self.tfOTP hasText]) {
        [self proceedBtnActivate:TRUE];
    }else{
        [self proceedBtnActivate:FALSE];
    }
}

- (IBAction)didPressProceed:(id)sender {
    if([AppDelegate appDelegate].isInternet){
        if(selectedCountrycode == nil){
            [self singleButtonAlertViewWithAlertTitle:AppName message:@"Please select your country code" buttonTitle:@"OK"];
            return;
        }else{
            [self proceedBtnActivate:FALSE];
            if (count==1) {
                if ([self ValidationForOTPMaching]) {
                    [self MatchOTPServiceCalling];
                }
            }else if(count==0){
                if ([self ValidationForOTPGeneration]) {
                    [self SendOTPServiceCalling];
                }
            }
        }
    }
    else
    {
        [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:@"OK"];
    }
}

-(void)timerCountdown{
    if (timerCount<0) {
        [timer invalidate];
        self.lblTimer.hidden = true;
        self.btnResend.hidden = isOTPResend;
    }else {
        _lblTimer.text = [NSString stringWithFormat:@"%ld",(long)timerCount];
        timerCount--;
    }
}

-(void)countryPopUp{
    //NSLog(@"countryPopUp");
    float paddingTopBottom = 40.0f;
    float paddingLeftRight = 20.0f;
    CGPoint point = CGPointMake(paddingLeftRight, paddingTopBottom);
    CGSize size = CGSizeMake((self.view.frame.size.width - (paddingLeftRight * 2)), self.view.frame.size.height - (paddingTopBottom * 2));
    LPPopupListView *listView = [[LPPopupListView alloc]initWithTitle:@"Select Country" list:self.countryArr selectedIndexes:self.selectedIndexes point:point size:size multipleSelection:NO disableBackgroundInteraction:NO];
    
    listView.delegate = self;
    [listView showInView:self.navigationController.view animated:YES];
    UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
    [indicator stopAnimating];
}

#pragma mark - LPPopupListViewDelegate
- (void)popupListView:(LPPopupListView *)popUpListView didSelectIndex:(NSInteger)index
{
    // NSLog(@"popUpListView - didSelectIndex: %ld", (long)index);
    //    [self showPopupBackView:NO];
   if (count==1) {
        self.btnResend.hidden = false;
        self.lblTimer.hidden = YES;
        [timer invalidate];
    }
    [self.btnCountryCode setTitle:[NSString stringWithFormat:@"+%@",[self.countryArr objectAtIndex:index][@"country_code"]] forState:UIControlStateNormal];
    [self.btnCountryCode setTitleColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    selectedCountry = [self.countryArr objectAtIndex:index][@"country"];
    selectedCountrycode = [self.countryArr objectAtIndex:index][@"country_code"];
    UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
    [indicator stopAnimating];
    didPresentCountry = YES;
    self.btnCountryCode.enabled = true;
    [Localytics tagEvent:@"Onboarding Select Country"];
}

- (void)popupListViewDidHide:(LPPopupListView *)popUpListView selectedIndexes:(NSIndexSet *)selectedIndexes
{
    // NSLog(@"popupListViewDidHide - selectedIndexes: %@", selectedIndexes.description);
    //    [self showPopupBackView:NO];
    didPresentCountry = NO;
    self.btnCountryCode.enabled = true;
    self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedIndexes];
    //  self.textView.text = @"";
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    // self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n", [[self list] objectAtIndex:idx]];
    }];
    UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
    [indicator stopAnimating];
}

- (void)popupListViewCancel{
    // NSLog(@"popupListViewCancel");
    didPresentCountry = NO;
    [UIView animateWithDuration:0.25 animations:^{
    // self.popupBackView.alpha = 0.0f;
    } completion:^(BOOL finished) {
    //[self showPopupBackView:NO];
    }];
    UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
    [indicator stopAnimating];
    self.btnCountryCode.enabled = true;
    //[self showPopupBackView:NO];
}

- (void)filterdCountry:(NSString *)country countrycode:(NSString *)ccode{
    didPresentCountry = NO;
    self.btnCountryCode.enabled = true;
      if (count==1) {
        self.btnResend.hidden = false;
        self.lblTimer.hidden = YES;
        [timer invalidate];
    }
    [self.btnCountryCode setTitle:[NSString stringWithFormat:@"+%@",ccode] forState:UIControlStateNormal];
    [self.btnCountryCode setTitleColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    selectedCountry = country;
    selectedCountrycode = ccode;
    UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
    [indicator stopAnimating];
    [Localytics tagEvent:@"Onboarding Select Country"];
}

#pragma mark - IBActions
- (IBAction)didPressCountryPick:(id)sender {
    [self hideKeyboard];
    if([AppDelegate appDelegate].isInternet){
        if (self.countryArr == nil) {
            [self getCountryList];
            UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
            [indicator startAnimating];
            self.btnCountryCode.enabled = false;
        }
    else
    {
        [self countryPopUp];
     }
    }
    else
      {
     [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:OK_STRING];
    }
}

- (IBAction)didPressResendOtp:(id)sender {
    if ([self ValidationForOTPGeneration]) {
        [self ResendOTPServiceCalling];
        self.btnResend.hidden = YES;
        isOTPResend = YES;
    }
}

- (IBAction)didPressEditMobileNumber:(id)sender {
    self.tfMobileNumber.enabled = YES;
    self.btnEditMobile.hidden = YES;
    [self.tfMobileNumber becomeFirstResponder];
}

- (IBAction)doneEditing:(id)sender{
    [self hideKeyboard];
}

#pragma web services methods
- (void) SendOTPServiceCalling
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kMobileVerificationOtpRequest], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",selectedCountrycode],user_country_code,[NSString stringWithFormat:@"%@",_tfMobileNumber.text],user_mobileNo,nil];
   // NSLog(@"SendOTPServiceCalling data dic= %@",dataDic);
    Server *obj = [[Server alloc] init];
    currentRequestType = kMobileVerificationOtpRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

- (void) ResendOTPServiceCalling
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kMobileResendOTP], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",selectedCountrycode],user_country_code,[NSString stringWithFormat:@"%@",_tfMobileNumber.text],user_mobileNo,nil];
    // NSLog(@"ResendOTPServiceCalling data dic= %@",dataDic);
    Server *obj = [[Server alloc] init];
    currentRequestType = kMobileResendOTP;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

- (void) MatchOTPServiceCalling
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kMobileVerification], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",selectedCountrycode],user_country_code,[NSString stringWithFormat:@"%@",_tfMobileNumber.text],user_mobileNo,[NSString stringWithFormat:@"%@",token_id],API_Token,[NSString stringWithFormat:@"%@",_tfOTP.text],user_OTP,nil];
    Server *obj = [[Server alloc] init];
    // NSLog(@"Data dic for otp ; %@",dataDic);
    // NSLog(@"MatchOTPServiceCalling data dic= %@",dataDic);
    currentRequestType = kMobileVerification;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

- (void) getFriendListServiceCalling //Get friend list Request
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetFreiendlist], keyRequestType1,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kGetFreiendlist;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:nil];
    // NSLog(@"serviceCalling1");
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    switch (currentRequestType)
    {
        case kMobileVerificationOtpRequest:
            [self performSelector:@selector(MobileVerificationOtpRequestResponse:) withObject:responseData afterDelay:0.000];
            break;
        case kMobileVerification:
            [self performSelector:@selector(MobileVerificationResponse:) withObject:responseData afterDelay:0.000];
            break;
        case kGetFreiendlist:
            [self performSelector:@selector(getFriendListResponse:) withObject:responseData afterDelay:0.000];
            break;
        case kMobileResendOTP:
            [self performSelector:@selector(ResendOTPRequestResponse:) withObject:responseData afterDelay:0.000];
            break;
        default:
            break;
    }
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
    [self proceedBtnActivate:TRUE];
    [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:@"OK"];
    //NSLog(@"requestError mobile");
}

-(void)MobileVerificationOtpRequestResponse:(NSDictionary *)response{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    NSString *waitingTime = [postDic valueForKey:@"wait"];
    token_id = [postDic valueForKey:@"token_id"];
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [userdef setObject:token_id forKey:API_Token];
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [userdef setObject:currentVersion forKey:kAppVersion]; //App version
    timerCount = waitingTime.integerValue;
  //  NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil )
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
        [self proceedBtnActivate:YES];
    }else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue ];
        if (statusResponse==0) {
            [[AppDelegate appDelegate] hideIndicator];
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:@"OK"];
            [self proceedBtnActivate:TRUE];
        }
        else if (statusResponse==1){
            if (count==0) {
                [UIView animateWithDuration:0.5 animations:^{
                 //   self.lblOTPMessage.hidden = false;
                    self.tfOTP.hidden = false;
                    self.lblTimer.hidden = false;
                    self.tfMobileNumber.enabled = FALSE;
                    [self proceedBtnActivate:FALSE];
                    self.topLblTitleConst.constant = 10 ;
                    self.bottomLogoConst.constant =  30;
                    self.topMobileViewHolderConst.constant = 13;
                    self.topBtnProceedConst.constant =  25 ;
                    self.lblTitle.text = @"OTP";
                    self.btnEditMobile.hidden = false;
                    self.lblOTPMessage.text = [NSString stringWithFormat:@"You will recieve One Time Password (OTP) Shortly. This Process may take upto %ld Sec.",(long)waitingTime.integerValue];
                    count++;
                    [self.view layoutSubviews];
                    [self.view layoutIfNeeded];
                    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:YES];
                    [timer fire];
                }];
            }else{
                self.lblTimer.hidden = false;
                [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:@"OK"];
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:YES];
                [timer fire];
            }
         }
        else if(statusResponse==9)
        {
            [[AppDelegate appDelegate] logOut];
        }
    }
}

-(void)ResendOTPRequestResponse:(NSDictionary *)response{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    NSString *waitingTime = [postDic valueForKey:@"wait"];
    token_id = [postDic valueForKey:@"token_id"];
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [userdef setObject:token_id forKey:API_Token];
    timerCount = waitingTime.integerValue;
    //NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil )
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        [self proceedBtnActivate:YES];
    }
    else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue ];
        if (statusResponse==0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            [self proceedBtnActivate:TRUE];
         }
        else if (statusResponse==1){
            if (count==0) {
                [UIView animateWithDuration:0.5 animations:^{
//                  self.lblOTPMessage.hidden = false;
                    self.tfOTP.hidden = false;
                    self.lblTimer.hidden = false;
                    self.tfMobileNumber.enabled = FALSE;
                    [self proceedBtnActivate:FALSE];
                    self.topLblTitleConst.constant = 10 ;
                    self.bottomLogoConst.constant =  30;
                    self.topMobileViewHolderConst.constant = 13;
                    self.topBtnProceedConst.constant =  25 ;
                    self.lblTitle.text = @"OTP";
                    self.btnEditMobile.hidden = false;
                    self.lblOTPMessage.text = [NSString stringWithFormat:@"You will recieve One Time Password (OTP) Shortly. This Process may take upto %ld Sec.",(long)waitingTime.integerValue];
                    count++;
                    //[self.view updateConstraints];
                    [self.view layoutSubviews];
                    [self.view layoutIfNeeded];
                    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:YES];
                    [timer fire];
                }];
            }else{
                self.lblTimer.hidden = false;
                [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:YES];
                [timer fire];
            }
        } else if(statusResponse==9){
            [[AppDelegate appDelegate] logOut];
        }
    }
}

-(void)MobileVerificationResponse:(NSDictionary *)response{
    [Localytics tagEvent:@"Onboarding Verified OTP"];
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
     //NSLog(@"MobileVerification Response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        [self proceedBtnActivate:YES];
    }else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue];
        if (statusResponse == 0) {
            [[AppDelegate appDelegate]hideIndicator];
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            [self proceedBtnActivate:TRUE];
        }
        else if (statusResponse == 1){
            [self updateUserDefaults:postDic];
        }else if (statusResponse == 2){
            [self updateUserDefaults:postDic];
        }else if (statusResponse == 3){
            [[AppDelegate appDelegate]hideIndicator];
            [[NSUserDefaults standardUserDefaults]setObject:self.tfMobileNumber.text forKey:user_mobileNo];
            [[NSUserDefaults standardUserDefaults]setObject:selectedCountrycode forKey:user_country_code];
//            [self pushToVerifyAccount];
            [self pushToUserChoice];
        }
        else if(statusResponse == 5){
            [[AppDelegate appDelegate]hideIndicator];
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            [self resetConstraints];
        }
        else if(statusResponse == 9){
            [[AppDelegate appDelegate]hideIndicator];
            [[AppDelegate appDelegate] logOut];
        }
    }
}

- (void) getFriendListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
    {
        // response is null
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            self.frndListArr = [resposeCode objectForKey:@"friendlist"];
            if(self.frndListArr !=nil || [self.frndListArr isKindOfClass:[NSMutableArray class]])
                for(int i =0; i<[self.frndListArr count];i++)
                {
                    NSDictionary*frndDic =[self.frndListArr objectAtIndex:i];
                    if(frndDic && [frndDic isKindOfClass:[NSDictionary class]])
                    {
                        NSString *usernName = [NSString stringWithFormat:@"%@", [frndDic objectForKey:@"first_name"]?[frndDic  objectForKey:@"first_name"]:@""];
                        NSString *jid = [NSString stringWithFormat:@"%@", [frndDic objectForKey:@"jabber_id"]?[frndDic  objectForKey:@"jabber_id"]:@""];
                        [self insertContactWithUserName:usernName andJid:jid];
                    }
                }
        }
    }
   // [self pushToFeedVc];
}

#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Keyboard Actions
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Notification handlers
- (void)keyboardWasShown:(NSNotification*)notif
{
    NSDictionary* info = [notif userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+10, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    //scrolling the active field to visible area
    if ((nil != activeField) && (keyboardHasAppeard == NO))
        [self.scrollView scrollRectToVisible:[self getPaddedFrameForView:activeField] animated:YES];
    keyboardHasAppeard = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)notif
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
    keyboardHasAppeard = NO;
}

#pragma mark private methods
- (CGRect) getPaddedFrameForView:(UIView *) view
{
    CGFloat padding = 5;
    CGRect frame = view.frame;
    frame.size.height += 2 * padding;
    frame.origin.y -= padding;
    return frame;
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    activeField.inputAccessoryView = self.keybAccessory;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(count==1){
        if (textField.tag==199) {
            [UIView animateWithDuration:1.5 animations:^{
                UIEdgeInsets contentInsets = self.scrollView.contentInset ;
                self.topLblTitleConst.constant = self.heightLblMessage.constant +  self.topLblTitleConst.constant + self.heightTfOTPConst.constant;
            //    self.topMobileViewHolderConst.constant = -self.topMobileViewHolderConst.constant ;
                self.topBtnProceedConst.constant = -(self.heightTfOTPConst.constant) ;
                self.bottomLogoConst.constant = - self.topLblTitleConst.constant  + self.bottomLogoConst.constant;
                count = 0;
                [timer invalidate];
                //self.lblOTPMessage.hidden = true;
                self.lblOTPMessage.text = docUserMsg;
                self.tfOTP.hidden = true;
                self.lblTimer.hidden = true;
                self.tfMobileNumber.enabled = true;
                self.lblTitle.text = @"Verify Number";
                CGPoint contentOffset;
                contentOffset = self.scrollView.contentOffset;
                CGPoint newOffset;
                newOffset.x = contentOffset.x;
                newOffset.y = contentInsets.top + 50+44;
                //check push return in keyboar
                [self.scrollView setContentOffset:newOffset animated:YES];
                self.tfOTP.text = @"";
             }];
        }
    }
    return YES;
}

#pragma mark - Validations
-(BOOL)ValidationForOTPGeneration{
    NSInteger tfMobileIntVal = self.tfMobileNumber.text.integerValue;
    if (([self.tfMobileNumber.text length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please enter mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([self.tfMobileNumber.text length] < 4)|| ([self.tfMobileNumber.text length] > 15)){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (tfMobileIntVal<=999){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }
     return true;
}

-(BOOL)ValidationForOTPMaching{
    NSInteger tfMobileIntVal = self.tfMobileNumber.text.integerValue;
    if (([self.tfMobileNumber.text length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please enter mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([self.tfMobileNumber.text length] < 4)|| ([self.tfMobileNumber.text length] > 15)){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (tfMobileIntVal<=999){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if ([self.tfOTP.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter OTP." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([self.tfOTP.text length] < 4)|| ([self.tfOTP.text length] > 4)){
        [UIAppDelegate alerMassegeWithError:@"Please enter a valid OTP." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }
      return true;
}

-(void)getCountryList{
    //  NSLog(@"getCountryList:");
    [[DocquityServerEngine sharedInstance]GetCountryListWithAccesscode:@"d3aeebaa5a03986262f51ced95b4ccac" format:jsonformat callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *response=[responceObject objectForKey:@"posts"];
        // NSLog(@"resposeCode = %@",resposeCode);
        if ([response isKindOfClass:[NSNull class]] || response==nil)
        {
            // NSLog(@"API Response: %@",response);
            [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];
            self.btnCountryCode.enabled = true;
            UIActivityIndicatorView *indicator = [self.btnCountryCode viewWithTag:99];
            [indicator stopAnimating];
        }
        else {
           if([[response valueForKey:@"status"]integerValue] == 1){
                //NSLog(@"getCountryList: = 1");
                [[AppDelegate appDelegate]hideIndicator];
                self.countryArr = [[NSMutableArray alloc]init];
                self.countryArr =[response objectForKey:@"country_details"];
                if([AppDelegate appDelegate].countryListArray == nil){
                    [AppDelegate appDelegate].countryListArray = self.countryArr;
                }
                [self countryPopUp];
            }
            else if([[response valueForKey:@"status"]integerValue] == 0){
                [[AppDelegate appDelegate]hideIndicator];
                [[AppDelegate appDelegate]alerMassegeWithError:[response valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
        }
     }];
}

//#pragma mark - Private Method
//-(void)showPopupBackView:(BOOL)flag{
//    self.popupBackView.alpha = 1.0f;
//    self.popupBackView.backgroundColor = [[UIColor colorWithRed:15.0/255.0 green:39.0/255.0 blue:60.0/255.0 alpha:1.0]colorWithAlphaComponent:0.95];
//    self.popupBackView.hidden = !flag;
//
//}

#pragma mark - Store values
-(void)updateUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil || (![[postDic objectForKey:@"data"] isKindOfClass:[NSMutableDictionary class]]))
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        [self proceedBtnActivate:YES];
        return;
    }
    else {
        NSString*userpermision = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"permission"]?[resposeCode  objectForKey:@"permission"]:@""];
         [userpref setObject:userpermision?userpermision:@"" forKey:user_permission];
        userCity = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        [userpref setObject:userCity?userCity:@"" forKey:user_city];
        userCountry = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
        userCountryCode = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
        userType  = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"user_type"]?[resposeCode  objectForKey:@"user_type"]:@""];
        customId =[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"custom_id"]?[resposeCode  objectForKey:@"custom_id"]:@""];
        [Localytics setCustomerId:customId];
        [userpref setObject:customId?customId:@"" forKey:ownerCustId];
        [userpref setObject:customId?customId:@"" forKey:custId];
        u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        [Localytics setCustomerEmail:u_email];
        [userpref setObject:u_email?u_email:@"" forKey:emailId1];
        
        u_fName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"first_name"]?[resposeCode  objectForKey:@"first_name"]:@""];
        [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
        
        JabberID = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_id"]?[resposeCode  objectForKey:@"jabber_id"]:@""];
        [userpref setObject:JabberID?JabberID:@"" forKey:jabberId];
        
        JabberName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_name"]?[resposeCode  objectForKey:@"jabber_name"]:@""];
        [userpref setObject:JabberName?JabberName:@"" forKey:kjabberName];
        
        u_lName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"last_name"]?[resposeCode  objectForKey:@"last_name"]:@""];
        [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
        
        userMobNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
        
        userPic = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"profile_pic_path"]?[resposeCode  objectForKey:@"profile_pic_path"]:@""];
        [userpref setObject:userPic?userPic:@"" forKey:profileImage];
        
        userRegNo = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"registration_no"]?[resposeCode  objectForKey:@"registration_no"]:@""];
        [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        
        userState = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        [userpref setObject:userState?userState:@"" forKey:user_state];
        
        uId=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"user_id"]?[resposeCode  objectForKey:@"user_id"]:@""];
        [userpref setObject:uId?uId:@"" forKey:userId];
        refLink = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"referal_link"]?[resposeCode  objectForKey:@"referal_link"]:@""];
        [userpref setObject:refLink?refLink:@"" forKey:shareRefLink];
        [userpref synchronize];
    }
    NSMutableDictionary*usrAuthkey  = [postDic objectForKey:@"user_auth_key"];
    if ([usrAuthkey  isKindOfClass:[NSNull class]] || usrAuthkey == nil)
    {
        // usrAuthkey is null
    }
    else
    {
        u_authkey=[NSString stringWithFormat:@"%@", [usrAuthkey objectForKey:@"auth_key"]?[usrAuthkey objectForKey:@"auth_key"]:@""];
        [userpref setObject:u_authkey?u_authkey:@"" forKey:userAuthKey];
        [userpref synchronize];
    }
    NSMutableDictionary*usrjabber  = [postDic objectForKey:@"jabber"];
    if ([usrjabber  isKindOfClass:[NSNull class]] || usrjabber == nil)
    {
        // usrjabber is null
    }
    else {
        chatId =[NSString stringWithFormat:@"%@", [usrjabber objectForKey:@"chat_id"]?[usrjabber objectForKey:@"chat_id"]:@""];
        [userpref setObject:chatId?chatId:@"" forKey:chatId1];
        jabberPassword=[NSString stringWithFormat:@"%@", [usrjabber objectForKey:@"password"]?[usrjabber objectForKey:@"password"]:@""];
        [userpref setObject:jabberPassword?jabberPassword:@"" forKey:password1];
        [userpref synchronize];
    }
    NSMutableDictionary *spclDic = [postDic objectForKey:@"speciality_list"];
    if([[spclDic  valueForKey:@"status"]integerValue] == 1){
        NSString *DocSpecility;
        if ([spclDic  isKindOfClass:[NSNull class]] || spclDic==nil)
        {
            // usrAuthkey is null
        }
        else {
            NSMutableArray *mainSpeciality =[[NSMutableArray alloc]init];
            mainSpeciality  = [spclDic objectForKey:@"speciality"];
            if(mainSpeciality !=nil || [mainSpeciality isKindOfClass:[NSMutableArray class]]){
                DocSpecility = [[mainSpeciality  objectAtIndex:0] valueForKey:@"speciality_name"];
                [userpref setObject:DocSpecility?DocSpecility:@"" forKey:docSpecility];
                [userpref synchronize];
            }
        }
    }
    statusResponse = [[postDic valueForKey:@"status"]integerValue];
    if (statusResponse==1) {
        [self downloadWithNsurlconnection];     // Download Profile Picture
        [self checkLoginUserForQuickblox];      // Checking the quickblox login
    }
    else if(statusResponse==2){
        [self pushToVerifyAccountWithUserFlag:NO];
    }
}

#pragma mark - download profile
-(void)downloadWithNsurlconnection
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",userPic]];
    // NSLog(@"Login IMG URL : %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
 //   NSLog(@"connection : %@",connection);
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

#pragma mark - Database handling
-(void)insertContactWithUserName:(NSString*)usernName andJid:(NSString*)jid
{
    NSString *insertQuery= [NSString stringWithFormat:@"INSERT INTO  contacts (username,nickname) VALUES ('%@','%@')",jid,usernName];
    [self.dbManager executeQuery:insertQuery];
}

#pragma mark - Pushing to views
-(void)pushToFeedVc{
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
    [[AppDelegate appDelegate] cancelLoginN];
}

-(void)pushToUserChoice{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserChooseVC *userchoice = [storyboard instantiateViewControllerWithIdentifier:@"UserChooseVC"];
    userchoice.userMobile = self.tfMobileNumber.text;
    userchoice.selectedCountry = selectedCountry;
    userchoice.selectedCountryID = selectedCountrycode;
    userchoice.isNewUser = YES;
    [self.navigationController pushViewController:userchoice animated:YES];
}

-(void)pushToVerifyAccountWithUserFlag:(BOOL)flag{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    VerifyYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"verifyYourSelfVC"];
    selfVerify.selectedCountry = selectedCountry;
    selfVerify.selectedCountryID = selectedCountrycode;
    selfVerify.userMobile = self.tfMobileNumber.text;
    selfVerify.isNewUser = flag;
    selfVerify.userType = userType;
    [self.navigationController pushViewController:selfVerify animated:YES];
}

-(void)pushToClaimProfileWithUserFlag:(BOOL)flag{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    ClaimProfileVC *ClaimProfile = [storyboard instantiateViewControllerWithIdentifier:@"ClaimProfileVC"];
    ClaimProfile.isNewUser = flag;
    ClaimProfile.selectedCountry = selectedCountry;
    [self.navigationController pushViewController:ClaimProfile animated:YES];
}

-(void)resetConstraints{
    [UIView animateWithDuration:2.5 animations:^{
        [timer invalidate];
        self.lblOTPMessage.text = docUserMsg;
        self.topLblTitleConst.constant = self.heightLblMessage.constant +  self.topLblTitleConst.constant + self.heightTfOTPConst.constant;
//        self.topMobileViewHolderConst.constant = -self.topMobileViewHolderConst.constant ;
        self.topBtnProceedConst.constant = -(self.heightTfOTPConst.constant) ;
        self.bottomLogoConst.constant = - self.topLblTitleConst.constant  + self.bottomLogoConst.constant;
        count = 0;
        timerCount = 0;
  //      self.lblOTPMessage.hidden = true;
        self.tfOTP.hidden = true;
        self.lblTimer.hidden = true;
        self.tfMobileNumber.enabled = true;
        self.btnEditMobile.hidden = YES;
        self.btnResend.hidden = YES;
        self.lblTitle.text = @"Verify Number";
        self.tfOTP.text = @"";
        self.tfMobileNumber.text = @"";
        [self proceedBtnActivate:FALSE];
    }];
}

-(void)proceedBtnActivate:(BOOL)flag{
    self.btnProceed.enabled = flag;
    if(!flag)
        self.btnProceed.alpha = 0.5;
    else
    self.btnProceed.alpha = 1.0;
}

-(void)checkLoginUserForQuickblox{
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    
    if (currentUser != nil) {
     //   NSLog(@"user loggedin... Logging Out...");
        [self logoutFromQuickblox];
    }else{
     //   NSLog(@"user not logged in... Logging In...");
        if ([chatId isEqualToString:@""] && [jabberPassword isEqualToString:@""]) {
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
        [[AppDelegate appDelegate] hideIndicator];
        if (success) {
            // __typeof(self) strongSelf = weakSelf;
            
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            [userpref setBool:YES forKey:signInnormal];
          //  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            // [strongSelf registerForRemoteNotifications];
            // [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
       //     NSLog(@"Succss login in quikblox");
            [self pushToFeedVc];
        } else {
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
//                    NSLog(@"chatId_update = %@",chatId);
//                    NSLog(@"jabber_name_update = %@",JabberName);
//                    NSLog(@"jabberPassword  = %@",jabberPassword );
                    
                    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
                    [userpref setObject:chatId?chatId:@"" forKey:chatId1];
                    [userpref setObject:JabberName?JabberName:@"" forKey:kjabberName];
                     [userpref setObject:jabberPassword?jabberPassword:@"" forKey:password1];
                    [userpref synchronize];
                    [self loginInQuickblox];
                    
                    // "chat_id" = 22726015;
                    // "jabber_name" = 12345;
                    //  "jabber_password" = zoUzaBPo6X;
                    
                    // NSLog(@"response from device token update = %@",resposeCode);
                }
            }
      }];
}

@end
