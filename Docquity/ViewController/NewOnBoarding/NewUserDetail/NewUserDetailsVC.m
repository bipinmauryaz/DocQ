//
//  NewUserDetailsVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewUserDetailsVC.h"
#import "SpecialityVC.h"
#import "NewUniversitySearchVC.h"
#import "WebVC.h"

@interface NewUserDetailsVC (){
    UITextField *activeField;
    BOOL keyboardHasAppeard;
    NSArray *inputItems;
   
}
//private method of keyboard Accessory view
- (void) registerForKeyboardNotifications;
- (void) keyboardWasShown:(NSNotification *)notif;
- (void) keyboardWillBeHidden:(NSNotification *)notif;
- (CGRect) getPaddedFrameForView:(UIView *) view;
- (void) endEditing;

@end

@implementation NewUserDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithHeaderLogoImageAndBackCheckFromOtherBarButtonItems:@"Personal Details"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    tfFirstName.leftView = paddingView;
    tfFirstName.leftViewMode = UITextFieldViewModeAlways;
    tfFirstName.layer.borderWidth = 1.0f;
    tfFirstName.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    
    tfLastName.leftView = paddingView1;
    tfLastName.leftViewMode = UITextFieldViewModeAlways;
    tfLastName.layer.borderWidth = 1.0f;
    tfLastName.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;

    tfEmail.leftView = paddingView2;
    tfEmail.leftViewMode = UITextFieldViewModeAlways;
    tfEmail.layer.borderWidth = 1.0f;
    tfEmail.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    
    tfMedicalRegNo.leftView = paddingView3;
    tfMedicalRegNo.leftViewMode = UITextFieldViewModeAlways;
    tfMedicalRegNo.layer.borderWidth = 1.0f;
    tfMedicalRegNo.layer.borderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
    
    if ([_registered_userType isEqualToString:@"doctor"]) {
        tfEmail.placeholder = @"Enter your Email (optional)";
        medicalView.hidden =NO;
       // tfMedicalRegNo.hidden = NO;
       // lbl_MedicalRegNo.hidden = NO;
    }
    else if ([_registered_userType isEqualToString:@"student"]) {
        tfEmail.placeholder = @"Enter your Email";
           medicalView.hidden = YES;
       // tfMedicalRegNo.hidden = YES;
     // lbl_MedicalRegNo.hidden = YES;
    }
    //Initializing the array for inputItems
    inputItems = [NSArray arrayWithObjects:tfFirstName,tfLastName,tfEmail,nil];
    //Create inputAccessoryView for all inputItems
    for (UITextField *tf in inputItems) {
        tf.inputAccessoryView = self.keybAccessory;
    }
    //Registring for keyboard notifications
    [self registerForKeyboardNotifications];
    keyboardHasAppeard = NO;
    
    //Registering Touch event on scroll
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.scroll addGestureRecognizer:singleTap];
 
    if (_claimDataDict>0) {
    NSString* u_email = [NSString stringWithFormat:@"%@", [_claimDataDict objectForKey:@"email"]?[_claimDataDict  objectForKey:@"email"]:@""];
     tfEmail.text = u_email;
    //[userpref setObject:u_email?u_email:@"" forKey:emailId1];
    NSString*  u_fName = [NSString stringWithFormat:@"%@", [_claimDataDict objectForKey:@"first_name"]?[_claimDataDict  objectForKey:@"first_name"]:@""];
    tfFirstName.text = u_fName;
    //[userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
    NSString* u_lName = [NSString stringWithFormat:@"%@", [_claimDataDict objectForKey:@"last_name"]?[_claimDataDict  objectForKey:@"last_name"]:@""];
      tfLastName.text = u_lName;
  
    NSString*medicalregNo = [NSString stringWithFormat:@"%@", [_claimDataDict objectForKey:@"registration_number"]?[_claimDataDict  objectForKey:@"registration_number"]:@""];
        tfMedicalRegNo.text = medicalregNo;
    //[userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
   
    }
  
      // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingNameInputScreen" screenAction:@"OnboardingNameInputScreen Visit"];
    [super viewWillAppear:animated];
    self.scroll.contentSize=self.scvwContentView.frame.size;
}

-(BOOL)ValidationWithText:(NSString*)text{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (([text length] == 0)){
        return false;
    }else{
        return true;
    }
}

-(BOOL)textValidation:(NSString *)text{
    NSString *regex = @"[A-Z0-9a-z ,.]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    ////for special char
    if ([regextest evaluateWithObject:[text lowercaseString]] == YES) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)medRegValidation:(NSString *)text{
    NSString *regex = @"[A-Z0-9a-z-_//,.#\\[\\]\\{\\}\\(\\)]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    ////for special char
    if ([regextest evaluateWithObject:[text lowercaseString]] == YES) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)emailValidation:(NSString *)text{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //for Email
    if ([regextest evaluateWithObject:[text lowercaseString]] == YES) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Next Click
- (IBAction)didPressNext:(id)sender {
     if ([self ValidationWithText:tfFirstName.text])
    {
        if (![self textValidation:tfFirstName.text])
        {
            [UIAppDelegate alerMassegeWithError:kvalidateFirstname withButtonTitle:OK_STRING autoDismissFlag:NO];
            return;
        }
    }
    else {
       [UIAppDelegate alerMassegeWithError:kvalidateEnterFirstname withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
        if (![self textValidation:tfLastName.text])
        {
            [UIAppDelegate alerMassegeWithError:kvalidatelastname withButtonTitle:OK_STRING autoDismissFlag:NO];
            return;
        }
    if([_registered_userType isEqualToString:@"student"]){
        if([tfEmail.text isEqualToString:@""] || tfEmail.text== nil){
            [UIAppDelegate alerMassegeWithError:@"Please enter email." withButtonTitle:OK_STRING autoDismissFlag:NO];
            return;
        }
    }
    if(![tfEmail.text isEqualToString:@""])
    {
      if(![self emailValidation:[NSString stringWithFormat:@"%@",tfEmail.text].lowercaseString]){
        [UIAppDelegate alerMassegeWithError:kvalidateEmail withButtonTitle:OK_STRING autoDismissFlag:NO];
                return;
        }
    }
    if ([_registered_userType isEqualToString:@"doctor"]) {
            self.navigationController.navigationBar.hidden = NO;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
            SpecialityVC *specialityvw = [storyboard instantiateViewControllerWithIdentifier:@"SpecialityVC"];
            specialityvw.registered_userType = _registered_userType;
            [self.navigationController pushViewController:specialityvw animated:YES];
    }
    else if ([_registered_userType isEqualToString:@"student"]){
            self.navigationController.navigationBar.hidden = NO;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
            NewUniversitySearchVC *universityvw = [storyboard instantiateViewControllerWithIdentifier:@"NewUniversitySearchVC"];
           universityvw.registered_userType = _registered_userType;
            [self.navigationController pushViewController:universityvw animated:YES];
    }
    [[NSUserDefaults standardUserDefaults] setObject:tfFirstName.text forKey:@"userFirstName"];
    [[NSUserDefaults standardUserDefaults] setObject:tfLastName.text forKey:@"userLastName"];
    [[NSUserDefaults standardUserDefaults] setObject:tfEmail.text forKey:@"userEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:tfMedicalRegNo.text forKey:@"userMedicalNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (keyboardHasAppeard)
        [self.scroll scrollRectToVisible:[self getPaddedFrameForView:textField] animated:YES];

}

-(BOOL)textFieldShouldClear:(UITextField *)textField{

    return YES;
}

#pragma mark - terms and Btn click
- (IBAction)TermsBtnClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    if(![AppDelegate appDelegate].isInternet){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    webvw.documentTitle = tncUrl;
    webvw.fullURL = tncUrl;
    [self presentViewController:webvw animated:YES completion:nil];
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

- (void)endEditing
{
    [self.view endEditing:YES];
}

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark Notification handlers
- (void)keyboardWasShown:(NSNotification*)notif
{
    NSDictionary* info = [notif userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scroll.contentInset = contentInsets;
    self.scroll.scrollIndicatorInsets = contentInsets;
    //scrolling the active field to visible area
    if ((nil != activeField) && (keyboardHasAppeard == NO))
        [self.scroll scrollRectToVisible:[self getPaddedFrameForView:activeField] animated:YES];
    keyboardHasAppeard = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)notif
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.scroll.contentInset = UIEdgeInsetsZero;
    self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
    keyboardHasAppeard = NO;
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
