//
//  NewAddEducationVC.m
//  Docquity
//
//  Created by Arimardan Singh on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NewAddEducationVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "NSString+HTML.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"

typedef enum {
    kTAG_datePicker,
    kTAG_MonthPick,
    
}AllTag;

@interface NewAddEducationVC (){
    BOOL checked;
    BOOL Monthclick;
    NSMutableArray *Years;
    NSMutableArray *Months;
    NSInteger btnTag;
    NSString*u_education;
    NSString*u_authkey;
    NSString*uId;
    NSString*edu_id;
    NSMutableArray *yearArr;
    NSString*CheckDetails;
    
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
@implementation NewAddEducationVC
@synthesize filldicdata;
@synthesize pickerView,myToolbar;
@synthesize isSaveBtnCliked;
@synthesize QuaLevelTF,InstNameTf,EndYearBtn;
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];

    //Registering Touch event on view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    checked = NO;
    //Get Current Year into i
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int CurrYear  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    //Create Years Array from 1960 to This year
    Years = [[NSMutableArray alloc] init];
    for (int i=1960; i<=CurrYear; i++) {
        [Years addObject:[NSString stringWithFormat:@"%d",i]];
    }
    Months = [[NSMutableArray alloc] initWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct",@"Nov",@"Dec", nil];
    
    EducationModel *eduModel = [editdatainfo objectAtIndex:indexnum];
    if(eduModel && [eduModel isKindOfClass:[EducationModel class]])
    {
        schoolinfo =   [NSString stringWithFormat:@"%@",[eduModel.school stringByDecodingHTMLEntities]];
         yop =   [NSString stringWithFormat:@"%@",eduModel.end_date];
         degree =   [NSString stringWithFormat:@"%@",[eduModel.degree stringByDecodingHTMLEntities]];
         edu_id =   [NSString stringWithFormat:@"%@",eduModel.education_id];
         currPur =   [NSString stringWithFormat:@"%@",eduModel.current_pursuing];
     }
     if (flg==1) {
        if([currPur isEqualToString:@"1"]){
            _CheckBoxCWH.image= [UIImage imageNamed:@"check_box.png"];
            [EndYearBtn setTitle:@"Select Your Date" forState:UIControlStateNormal];
            EndYearBtn.enabled = NO;
            checked = true;
        }
        else {
            _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
            EndYearBtn.enabled = YES;
            checked = false;
        }
    }
    else {
        EndYearBtn.enabled = YES;
        _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
        checked = false;
    }
     UITapGestureRecognizer *taponView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    [_currentPur_eduView setUserInteractionEnabled:YES];
    [_currentPur_eduView addGestureRecognizer:taponView];
    
    UITapGestureRecognizer *taponcheckbox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    [_CheckBoxCWH setUserInteractionEnabled:YES];
    [_CheckBoxCWH addGestureRecognizer:taponcheckbox];
    
    //Initializing the array for inputItems
    inputItems = [NSArray arrayWithObjects:self.QuaLevelTF, self.InstNameTf,nil];
    //Create inputAccessoryView for all inputItems
    for (UITextField *tf in inputItems) {
        tf.inputAccessoryView = self.keybAccessory;
    }
    //Registring for keyboard notifications
    [self registerForKeyboardNotifications];
    keyboardHasAppeard = NO;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    if ([currPur isEqualToString:@"1"]) {
        CheckDetails = @"1";
    }
    else{
        CheckDetails = @"0";
    }
    self.scrollView.contentSize=self.scvwContentView.frame.size;
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];
    if (flg==1) {
        self.navigationItem.title = @"Edit Education";
        _add_eduView.hidden = YES;
        _edit_eduView.hidden = NO;
        QuaLevelTF.text = degree;
        InstNameTf.text = schoolinfo;
        if ([yop isEqualToString:@"0"]) {
            [EndYearBtn setTitle:@"Select Your Date" forState:UIControlStateNormal];
        }
        else{
            [EndYearBtn setTitle:yop forState:UIControlStateNormal];
        }
    }
    else{
        _add_eduView.hidden = NO;
        _edit_eduView.hidden = YES;
        self.navigationItem.title = @"Add Education";
    }
    [EndYearBtn addTarget:self action:@selector(SelectTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - back Button Action
-(void)BackView:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - add more and save Button Action
-(IBAction)addmore:(UIButton*)sender{
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
    isSaveBtnCliked =NO;
    if ([InstNameTf.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter your University / Institute Name." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    else {
        [self setCreateEducationRequest:QuaLevelTF.text InstituteName:InstNameTf.text dateOfgraduation:EndYearBtn.titleLabel.text currPursuing:CheckDetails];
    }
}

#pragma mark - save Button Action
-(IBAction)Save:(UIButton*)sender{
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
    isSaveBtnCliked =YES;
    if ([InstNameTf.text length] == 0){
         [UIAppDelegate alerMassegeWithError:@"Please enter your University / Institute Name." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    if (flg==1) {
         if ([QuaLevelTF.text isEqualToString:degree] && [InstNameTf.text isEqualToString:schoolinfo] &&[EndYearBtn.titleLabel.text isEqualToString:yop]&&[CheckDetails isEqualToString:currPur]) {
               [self.navigationController popViewControllerAnimated:YES];

        }
         else if (([QuaLevelTF.text isEqualToString:[NSString stringWithFormat:@"%@", degree?degree:@""]])&& ([InstNameTf.text  isEqualToString:[NSString stringWithFormat:@"%@",schoolinfo?schoolinfo:@""]])&&([EndYearBtn.titleLabel.text isEqualToString:@"Select Your Date"])&&([CheckDetails isEqualToString:[NSString stringWithFormat:@"%@",currPur?currPur:@""]])){
             [self.navigationController popViewControllerAnimated:YES];
             return;
         }
        else {
            QuaLevelTF.text =  [QuaLevelTF.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            InstNameTf.text =  [InstNameTf.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
          //calling webservice for Edit Education
            [self setEducationRequest:QuaLevelTF.text InstituteName:InstNameTf.text dateOfgraduation:EndYearBtn.titleLabel.text currPursuing:CheckDetails educationId:edu_id];
        }
    }
    else{
        QuaLevelTF.text =  [QuaLevelTF.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        InstNameTf.text =  [InstNameTf.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
         //calling webservice for Add new Education
        [self setCreateEducationRequest:QuaLevelTF.text InstituteName:InstNameTf.text dateOfgraduation:EndYearBtn.titleLabel.text currPursuing:CheckDetails];
    }
}

#pragma mark - Delete button Action
-(IBAction)deleteBtn:(UIButton*)sender{
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
    //calling webservice for delete Education
    [self setRemoveEducationRequest:edu_id];
}

#pragma mark - tap on check Box Action
-(void)tapDetected: (UIImageView *)sender{
    //  NSLog(@"Image view Tap");
    if (checked) {
        CheckDetails = @"0";
        EndYearBtn.enabled = YES;
        _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
        checked = NO;
    }
    else{
        CheckDetails = @"1";
        EndYearBtn.enabled = NO;
        _CheckBoxCWH.image= [UIImage imageNamed:@"check_box.png"];
        checked = YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - select Date of Graduation Year
-(void)SelectTimePeriod:(UIButton *)sender{
    if (viewopen) {
        return;
    }
    else {
        Monthclick = NO;
        newviewforPicker= [[UIView alloc]init];
        newviewforPicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/3);
        newviewforPicker.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        [self.view addSubview:newviewforPicker];
        
        UILabel *StatusLbl = [[UILabel alloc]init];
        StatusLbl.frame = CGRectMake(20, 10, newviewforPicker.frame.size.width/3, 30);
        StatusLbl.textColor = [UIColor whiteColor];
        StatusLbl.backgroundColor = [UIColor clearColor];
        StatusLbl.font= [UIFont systemFontOfSize:15.0];
        [newviewforPicker addSubview:StatusLbl];
        
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnDone.frame = CGRectMake(newviewforPicker.frame.size.width- StatusLbl.frame.size.width - StatusLbl.frame.origin.x, 10, newviewforPicker.frame.size.width/3, 30);
        [btnDone setTitle:@"Done" forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDone.titleLabel.font= [UIFont systemFontOfSize:16.0];
        btnDone.titleLabel.backgroundColor = [UIColor clearColor];
        btnDone.layer.cornerRadius = 5.0f;
        [btnDone addTarget:self action:@selector(closeview:) forControlEvents:UIControlEventTouchUpInside];
        [newviewforPicker addSubview:btnDone];
        if (Monthclick) {
            UIPickerView *monthPick= [[UIPickerView alloc]initWithFrame:CGRectMake(0, StatusLbl.frame.origin.y + StatusLbl.frame.size.height+10, newviewforPicker.frame.size.width, newviewforPicker.frame.size.height)];
            monthPick.backgroundColor = [UIColor whiteColor];
            monthPick.delegate=self;
            [newviewforPicker addSubview:monthPick];
            StatusLbl.text = @"Select Month";
        }
        else
        {
            StatusLbl.text = @"Select Year";
            UIPickerView *YearPick= [[UIPickerView alloc]initWithFrame:CGRectMake(0, StatusLbl.frame.origin.y + StatusLbl.frame.size.height+10, newviewforPicker.frame.size.width, newviewforPicker.frame.size.height)];
            YearPick.backgroundColor = [UIColor whiteColor];
            YearPick.delegate=self;
            [newviewforPicker addSubview:YearPick];
        }
        [self openview:sender];
    }
}

#pragma mark - open Picker view for Year of passing
-(void)openview: (UIButton*)sender
{
    if (viewopen) {
        return;
    }
    else{  CGRect newFrame = newviewforPicker.frame;
        newFrame.origin.y = [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.height/3-40;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             newviewforPicker.frame = newFrame;
                         }];
        NSString *choosen = @"1960";
        [EndYearBtn  setTitle:choosen forState:UIControlStateNormal];
        viewopen=YES;
    }
}

#pragma mark - close Picker View
-(void)closeview: (UIButton *)sender{
    CGRect newFrame = newviewforPicker.frame;
    newFrame.origin.y = [UIScreen mainScreen].bounds.size.height;   // shift down by 500pts
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         newviewforPicker.frame = newFrame;
                     }];
    viewopen=NO;
}

#pragma mark - PickerView Delegate Methods
- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    if (Monthclick) {
        return [Months count];
    }
    return [Years count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [self endEditing];
    
    if (Monthclick) {
        return [Months objectAtIndex:row];
    }
    else{
        return [Years objectAtIndex:row];
    }
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (Monthclick) {
        
    }
    else{
        NSString *val = [Years objectAtIndex:row];
        [EndYearBtn  setTitle:val forState:UIControlStateNormal];
    }
}

-(void)setData:(NSMutableArray *)Filldata withindex:(NSInteger)index flag:(NSInteger)flag{
    editdatainfo = Filldata;
    indexnum = index;
    flg = flag;
}

#pragma mark - create education api calling
-(void)setCreateEducationRequest:(NSString *)u_degree  InstituteName:(NSString *)schoolname dateOfgraduation:(NSString*)yearOfPassing currPursuing:(NSString*)currPursuing {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetCreateEducationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] school_name:schoolname degree:u_degree  end_date:yearOfPassing current_pursuing:currPursuing format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        
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
                if(isSaveBtnCliked==YES){
                    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                    NSString *custmId=[userpref objectForKey:ownerCustId];
                    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                    NewProfile .custid=  custmId;
                    NewProfile.hidesBottomBarWhenPushed = YES;
                    [AppDelegate appDelegate].isComeFromSettingVC = NO;
                    [self.navigationController pushViewController:NewProfile animated:YES];
                }
                else {
                    _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
                    QuaLevelTF.text = @"";
                    InstNameTf.text = @"";
                    [EndYearBtn setTitle:@"Select Your Date" forState:UIControlStateNormal];
                }
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - set edit/update education api calling
-(void)setEducationRequest:(NSString *)u_degree  InstituteName:(NSString *)schoolname dateOfgraduation:(NSString*)yearOfPassing currPursuing:(NSString*)currPursuing  educationId:(NSString*)edu_Id {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetEducationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId]  education_id:edu_Id school_name:schoolname degree:u_degree end_date:yearOfPassing current_pursuing:currPursuing format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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
                NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                NSString *custmId=[userpref objectForKey:ownerCustId];
                UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                NewProfile .custid=  custmId;
                NewProfile.hidesBottomBarWhenPushed = YES;
                [AppDelegate appDelegate].isComeFromSettingVC = NO;
                [self.navigationController pushViewController:NewProfile animated:YES];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - remove education api calling
-(void)setRemoveEducationRequest:(NSString *)edu_Id  {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetRemoveEducationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] education_id:edu_Id format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
 
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
                NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                NSString *custmId=[userpref objectForKey:ownerCustId];
                UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                NewProfile .custid=  custmId;
                NewProfile.hidesBottomBarWhenPushed = YES;
                [AppDelegate appDelegate].isComeFromSettingVC = NO;
                [self.navigationController pushViewController:NewProfile animated:YES];
                
            }else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - next Button Action
- (IBAction)nextInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *nextInputField = [inputItems objectAtIndex:(idx + 1)];
    [nextInputField becomeFirstResponder];
}

#pragma mark - previous Button Action
- (IBAction)previousInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *prevInputField = [inputItems objectAtIndex:(idx - 1)];
    [prevInputField becomeFirstResponder];
}

#pragma mark - Done Button Action
- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    //Adjust he inputAccessory according to the position of textField in inputItems
    NSUInteger idx = [inputItems indexOfObject:textField];
    self.previousBarBt.enabled = YES;
    self.nextBarBt.enabled = YES;
    if (idx == 0) {
        self.previousBarBt.enabled = NO;
    }else if(idx == (inputItems.count - 1)){
        self.nextBarBt.enabled = NO;
    }
    //scrolling the textField to visible area
    if (keyboardHasAppeard)
        [self.scrollView scrollRectToVisible:[self getPaddedFrameForView:textField] animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    // NSLog(@"textFieldDidEndEditingcalled");
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

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setQuaLevelTF:nil];
    [self setInstNameTf:nil];
    
    inputItems = nil;
    [self setScvwContentView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
