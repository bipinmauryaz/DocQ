/*============================================================================
 PROJECT: Docquity
 FILE:    VerifyYourSelfVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 01/09/16.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "VerifyYourSelfVC.h"
#import "AppDelegate.h"
#import "ClaimProfileVC.h"
#import "AssociationModel.h"
#import "Localytics.h"
#import "ClaimCell.h"
#import "ClaimAccountModel.h"
#import "WebVC.h"
#import "DocquityServerEngine.h"
#import "NewProfileImageVC.h"
#import "ServicesManager.h"
#import "UniversitySearchVC.h"
#import "DropDownListView.h"
#import "NewVerifySelfVC.h"

@interface VerifyYourSelfVC (){
    NSUserDefaults *userdef;
}

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@property (strong,nonatomic) ClaimAccountModel *ClaimRecord;

@end

@implementation VerifyYourSelfVC
@synthesize verifyCheckDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    //isForceShowPopup = false;
    self.popupBackView.hidden = YES;
    
    self.userType = [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"user_type"]];
    
    NSMutableArray *temparr = [[NSMutableArray alloc]init];
    temparr= [[verifyCheckDict objectForKey:@"association_list"] mutableCopy];
    if ([temparr count]==0) {
        
    }
    else {
       
        if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
        {
            //more data found
            for(int i=0; i<[temparr count]; i++){
//                NSDictionary *assoicationListInfo = temparr[i];
//                if (assoicationListInfo != nil && [assoicationListInfo isKindOfClass:[NSDictionary class]]) {
//                }

              inviteCodeType = [[temparr objectAtIndex:0]valueForKey: @"invite_code_type"];
              tfplachoder_inviteCodeEXample = [[temparr objectAtIndex:0]valueForKey: @"invite_code_example"];
              // [[assoicationListInfo valueForKey:@"invite_code_example"]objectAtIndex:0];
            }
        }
        
       

                /*
                "association_abbreviation" = "AIIMS Raipur";
                "association_id" = 12;
                "association_name" = "AIIMS Raipur";
                "association_type" = private;
                "custom_url" = "aiims_raipur";
                "invite_code_example" = "Eg : 8871205265";
                "invite_code_type" = Mobile;
                "profile_pic_path" = "https://docquity.com/images/association/AIIMSRAIPUR.jpg";
*/
               // [self.feedlikeListArr addObject:feedLikeListInfo];
            }

    
    
   // isAssociationPicked = false;
    //self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    UIEdgeInsets inset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.contentInset = inset;
    tfInvite.delegate = self;
    icType = @"";
    //[Localytics tagEvent:@"Onboarding New User Verifying Identity"];
    userdef = [NSUserDefaults standardUserDefaults];
    if (!_isNewUser) {
        _ClaimRecord = [ClaimAccountModel new];
        _ClaimRecord.medicalReg = [userdef valueForKey:kUserRegNo];
        _ClaimRecord.claimcode = [userdef valueForKey:inviteCode];
        _ClaimRecord.emailID = [userdef valueForKey:kemailId];
        _ClaimRecord.specializationName = [userdef valueForKey:kspeciality_name];
    }else{
        _ClaimRecord = [[ClaimAccountModel alloc] initWithData:data_dic];
    }
     [self registerForKeyboardNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    
  // tfInvite.inputAccessoryView = self.keybAccessory;
  //  [self.navigationController setNavigationBarHidden:NO animated:NO];
    if([self.userType isEqualToString:@"doctor"]){
      //  arryList = [[NSMutableArray alloc]init];
        //[self getSpecialitylistRequest];
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
     self.navigationItem.title = @"Verify Yourself";
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}


#pragma mark - Tableview Delegate and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    ClaimCell *claimcell = [tableView dequeueReusableCellWithIdentifier:@"claimCell"];
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cellIdentifier = @"claimCell";
            break;
           case 1:
            cellIdentifier = @"claimCell";
            break;
            case 2:
            cellIdentifier = @"claimCell";
            break;
           case 3:
             cellIdentifier = @"claimCell";
            break;
            
            default:
            break;
    }
    if(indexPath.row !=0){
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
   // UILabel *lblICType;
    switch (indexPath.row) {
          case 0:
            claimcell.lblHint.text = @"Medical Registration Number";
            claimcell.tfFields.placeholder = @"Enter Medical Registration Number";
            claimcell.tfFields.inputAccessoryView = self.keybAccessory;
            claimcell.tfFields.text = _ClaimRecord.medicalReg;
            claimcell.tfFields.autocapitalizationType = UITextAutocapitalizationTypeWords;
            return claimcell;
            
        case 1:
            
            claimcell.lblHint.text = inviteCodeType;
            claimcell.tfFields.placeholder = tfplachoder_inviteCodeEXample;
            claimcell.tfFields.inputAccessoryView = self.keybAccessory;
            claimcell.tfFields.text = _ClaimRecord.claimcode;
            claimcell.tfFields.autocapitalizationType = UITextAutocapitalizationTypeWords;
            return claimcell;

//            lblICType.text = [NSString stringWithFormat:@"Enter Your %@",icType];
//            tfInvite.placeholder = icExample;
//            cell.hidden = !isAssociationPicked;
//            tfInvite.text = [icType isEqualToString:@"Mobile"]?self.userMobile:_ClaimRecord.claimcode;
//            tfInvite.keyboardType = [icType isEqualToString:@"Mobile"]?UIKeyboardTypeNumberPad:UIKeyboardTypeDefault;
//            tfInvite.inputAccessoryView = self.keybAccessory;
//            return cell;
            
        case 2:
                claimcell.lblHint.text = @"Email";
                claimcell.tfFields.placeholder = @"Enter Your Email";
                claimcell.tfFields.text = _ClaimRecord.emailID;
                claimcell.tfFields.keyboardType = UIKeyboardTypeEmailAddress;
                claimcell.tfFields.inputAccessoryView = self.keybAccessory;
                return claimcell;
        case 3:
            claimcell.lblHint.text = @"Interest";
            claimcell.tfFields.placeholder = @"Select Your Interest";
            claimcell.tfFields.text = _ClaimRecord.specializationName;
            return claimcell;
            break;
            
        default:
            break;
    }
     return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if([self.userType isEqualToString:@"student"]) {
//        if(indexPath.row == 1){
//            return 0;
//           
//        }
//    }
//    else{
      _inviteCodeValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"claim_code"]];
      _emailValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"email"]];
      _medicalRegValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"registration_no"]];
       _specialityValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"specialization"]];
        
        if ([_medicalRegValue integerValue] == 0) {
            if(indexPath.row == 0){
                return 0;
            }
        }
    
        if ([_inviteCodeValue integerValue] == 0) {
            if(indexPath.row == 1){
                return 0;
            }
        }

    if ([_emailValue integerValue] == 0) {
        if(indexPath.row == 2){
            return 0;
        }
    }
    
    if ([_specialityValue integerValue] == 0) {
        if(indexPath.row == 3){
            return 0;
        }
    }
    return 90;
}

#pragma mark - Text Field Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.actifText = textField;
    if([textField.placeholder isEqualToString:@"Select Your Interest"])
    {
         UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         NewVerifySelfVC *VC5  = [mstoryboard instantiateViewControllerWithIdentifier:@"NewVerifySelfVC"];
         VC5.delegate = self;
         [self.navigationController pushViewController:VC5 animated:YES];
     }
     //    CGPoint textfieldpos = [textField convertPoint:CGPointZero toView:self.tableView];
    //    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textfieldpos];
 }

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGPoint textfieldpos = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textfieldpos];
    switch (indexPath.row) {
        case 0:
            _ClaimRecord.medicalReg = textField.text;
            break;
        case 1:
            _ClaimRecord.claimcode = textField.text;
            break;
        case 2:
            _ClaimRecord.emailID = textField.text;
            break;
          default:
            break;
    }
    self.actifText = nil;
 }

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

-(void)hideKeyboard{
    [self. view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressNext:(UIButton*)sender {
    
    _inviteCodeValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"claim_code"]];
    _emailValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"email"]];
    _medicalRegValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"registration_no"]];
    _specialityValue =  [NSString stringWithFormat:@"%@", [verifyCheckDict valueForKey:@"specialization"]];
    _userType =  [NSString stringWithFormat:@"%@",[verifyCheckDict valueForKey:@"user_type"]];

    data_dic = [[NSMutableDictionary alloc]init];
    [data_dic setObject:_ClaimRecord.medicalReg?_ClaimRecord.medicalReg:@"" forKey:kUserRegNo];
    [data_dic setObject:_ClaimRecord.claimcode?_ClaimRecord.claimcode:@"" forKey:kinvitecode];
    [data_dic setObject:_ClaimRecord.emailID?_ClaimRecord.emailID:@"" forKey:kemailId];
    [data_dic setObject:_ClaimRecord.specializationName?_ClaimRecord.specializationName:@"" forKey:kspeciality_name];
    for (int i=0; i<4; i++) {
        switch (i) {
            case 0:
                if([self.userType isEqualToString:@"student"]){
                    break;
                }
                if ([_medicalRegValue integerValue] == 0) {
                }
                
                else{
                if([data_dic valueForKey:kUserRegNo]){
                    if([[data_dic valueForKey:kUserRegNo] isEqualToString:@""] || [data_dic valueForKey:kUserRegNo] == nil){
                        [UIAppDelegate alerMassegeWithError:@"Please enter medical registration number." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                    if (![self medRegValidation:[data_dic valueForKey:kUserRegNo]])
                    {
                        [UIAppDelegate alerMassegeWithError:@"Please enter valid medical registration number." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                }else{
                    [data_dic setObject:@"" forKey:kUserRegNo];
                }
                }
                break;
                
            case 1:
                if([self.userType isEqualToString:@"student"]){
                    break;
                }
                
                if ([_inviteCodeValue integerValue] == 0) {
                }

                else {
                if([data_dic valueForKey:kinvitecode]){
                    NSString*alertTitlemesg;
                    NSRange range = [inviteCodeType rangeOfString:@"-"];
                    if (range.location != NSNotFound) {
                        inviteCodeType = [inviteCodeType substringToIndex:range.location];
                        alertTitlemesg = [[NSString stringWithFormat:@"Please enter %@Number.",inviteCodeType]stringByDecodingHTMLEntities];
                        // NSLog(@"New string = %@",newString);
                    }
                    else{
                        alertTitlemesg  = [[NSString stringWithFormat:@"Please enter %@ Number.",inviteCodeType]stringByDecodingHTMLEntities];
                        // NSLog(@"New string = %@",newString);
                    }
                     if([[data_dic valueForKey:kinvitecode] isEqualToString:@""] || [data_dic valueForKey:kinvitecode] == nil){
                        [UIAppDelegate alerMassegeWithError:alertTitlemesg withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                    // NSString*  text = [[data_dic valueForKey:kinvitecode] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    // [data_dic setObject:text forKey:kinvitecode];
                    
                }else{
                    //[data_dic setObject:@"" forKey:kinvitecode];
                }
                }
                break;
   
            case 2:
                
                if ([_emailValue integerValue] == 0) {
                }
                else{
                    if([[data_dic valueForKey:kemailId] isEqualToString:@""] || [data_dic valueForKey:kemailId] == nil){
                    [UIAppDelegate alerMassegeWithError:@"Please enter email." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                   if([data_dic valueForKey:kemailId]){
                    if(![[data_dic valueForKey:kemailId]isEqualToString:@""])
                    {
                        if(![self emailValidation:[NSString stringWithFormat:@"%@",[data_dic valueForKey:kemailId]].lowercaseString]){
                            [UIAppDelegate alerMassegeWithError:@"Please enter valid email." withButtonTitle:OK_STRING autoDismissFlag:NO];
                            return;
                        }
                    }
                }else
                    [data_dic setObject:@"" forKey:kemailId];
                }
                break;
                   case 3:
                if ([_specialityValue integerValue] == 0) {
                }
                else{
                    if([[data_dic valueForKey:kspeciality_name] isEqualToString:@""] || [data_dic valueForKey:kspeciality_name] == nil){
                        [UIAppDelegate alerMassegeWithError:@"Please select your interest." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                }
                break;
                
            default:
                break;
        }
    }
     [self SetUpdateUserPersonalInfoRequest];
  //  self.isNewUser?[self newUserReg]:[self claimUser];
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
    ////for Email
    if ([regextest evaluateWithObject:[text lowercaseString]] == YES) {
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)doneEditing:(id)sender{
    [self hideKeyboard];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Keyboard Function
-(void)registerForKeyboardNotification{
    {
        // Register notification when the keyboard will be show
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        // Register notification when the keyboard will be hide
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    [self.tableView setContentInset:contentInsets];
    [self.tableView setScrollIndicatorInsets:contentInsets];
    
    // NSIndexPath *currentRowIndex = [NSIndexPath indexPathForRow:self.actifText.tag inSection:0];
    CGPoint txtFieldPosition = [self.actifText convertPoint:CGPointZero toView:self.tableView];
    // NSLog(@"Begin txtFieldPosition : %@",NSStringFromCGPoint(txtFieldPosition));
    NSIndexPath *currentRowIndex = [self.tableView indexPathForRowAtPoint:txtFieldPosition];
    
    // NSLog(@"Begin txtFieldPosition = %ld",(long)currentRowIndex.row);
    [self.tableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    //   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [self.tableView setContentInset:contentInsets];
    [self.tableView setScrollIndicatorInsets:contentInsets];
}

-(BOOL)ValidationForMobile:(NSString*)str{
    NSInteger tfMobileIntVal = str.integerValue;
    if (([str length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please enter mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (([str length] < 4)|| ([str length] > 15)){
        [UIAppDelegate alerMassegeWithError:@"Mobile number should be 4 to 15 digit long." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }else if (tfMobileIntVal<=999){
        [UIAppDelegate alerMassegeWithError:@"Please enter valid mobile number" withButtonTitle:OK_STRING autoDismissFlag:NO];
        return false;
    }
    return true;
}

#pragma mark - terms and Btn click
- (IBAction)TermsBtnClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    if(![AppDelegate appDelegate].isInternet){
        [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:OK_STRING];
    }
    webvw.documentTitle = tncUrl;
    webvw.fullURL = tncUrl;
    [self presentViewController:webvw animated:YES completion:nil];
}


#pragma mark - SetUpdateUserPersonalInfoRequest
-(void)SetUpdateUserPersonalInfoRequest
{
    [WebServiceCall showHUD];
    NSString*josn_specialityId;
    
    if (_ClaimRecord.specializationId == nil) {
        josn_specialityId = @"";
    }
    else{
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_ClaimRecord.specializationId options:NSJSONWritingPrettyPrinted error:&error];
    josn_specialityId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    josn_specialityId = [[josn_specialityId componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
    }
     NSLog(@"josn_specialityId =%@",josn_specialityId);
    
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"email" :[NSString stringWithFormat:@"%@",[data_dic valueForKey:kemailId]],@"registration_no":[NSString stringWithFormat:@"%@",[data_dic valueForKey:kUserRegNo]],@"claim_code":[NSString stringWithFormat:@"%@",[data_dic valueForKey:kinvitecode]],@"iso_code":@"",@"speciality" :josn_specialityId,@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"profile/set?rquest=update_user_personal_info" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
            [SVProgressHUD dismiss];
            NSDictionary *resposePost =[response objectForKey:@"posts"];
            //  NSLog(@"set register user request %@",resposePost);
            if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
            {
                // Response is null
            }
            else
            {
                if([[resposePost valueForKey:@"status"]integerValue] == 1)
                {
                    [self dismissViewControllerAnimated:NO completion:nil];
                }
                else if([[resposePost valueForKeyPath:@"posts.status"] integerValue] == 0)
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
            //NSLog(@"%@",error);
        }
    }];
}

-(IBAction)didPressSubmitBtn:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)selectedInterstName:(NSMutableArray*)Name InterestID:(NSMutableArray*)interestId InterestArray:(NSMutableArray*)interestxMainArr{
    NSString * myspeciality = [[Name valueForKey:@"description"] componentsJoinedByString:@", "];
    // NSLog(@"Speciality Name: %@",myspeciality);
   // Arr_specialityId =  interestId.mutableCopy;
    // NSLog(@"Speciality ID: %@",Arr_specialityId);
    
    //  self.ImgSelectedAsso.image = assoImage;
   // ClaimCell.tfFields.text =  [myspeciality stringByDecodingHTMLEntities];
    _ClaimRecord.specializationId =   interestId.mutableCopy;
    _ClaimRecord.specializationName = [myspeciality stringByDecodingHTMLEntities];
    [self.tableView reloadData];
   // specSelectedMainArray = specMainArr;
}


-(void)dismissView{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
