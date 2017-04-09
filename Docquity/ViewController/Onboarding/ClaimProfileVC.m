/*============================================================================
 PROJECT: Docquity
 FILE:    ClaimProfileVC.m
 AUTHOR:  Copyright © 2015 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 22/08/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "ClaimProfileVC.h"
#import "NewProfileImageVC.h"
#import "DefineAndConstants.h"
#import "AppDelegate.h"
#import "Localytics.h"
#import "NewUploadIdentityVC.h"
#import "ClaimCell.h"
#import "ClaimAccountModel.h"
#import "WebVC.h"
#import "ServicesManager.h"

/*============================================================================
 Interface:   ClaimProfileVC
 =============================================================================*/
@interface ClaimProfileVC ()
@property (strong,nonatomic) ClaimAccountModel *ClaimRecord;
@end

@implementation ClaimProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    isAccountClaimed = FALSE;
    UIEdgeInsets inset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.contentInset = inset;
    userdef = [NSUserDefaults standardUserDefaults];
    
    if (!_isNewUser) {
        _ClaimRecord = [ClaimAccountModel new];
        _ClaimRecord.firstName = [userdef valueForKey:dc_firstName];
        _ClaimRecord.lastName = [userdef valueForKey:dc_lastName];
        _ClaimRecord.medicalReg = [userdef valueForKey:UserRegNo];
        _ClaimRecord.emailID = [userdef valueForKey:emailId1];
    }else{
        _ClaimRecord = [[ClaimAccountModel alloc] initWithData:data_dic];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.title = @"Register";
    //    self.navigationItem.hidesBackButton = !self.isNewUser;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    
    [self registerForKeyboardNotification];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"help.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
    [Localytics tagEvent:@"Onboarding Register Screen"];
}

#pragma mark - Tableview Delegate and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClaimCell *cell = (ClaimCell*)[tableView dequeueReusableCellWithIdentifier:@"claimCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [[ClaimCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"claimCell"];
    }
    switch (indexPath.row) {
        case 0:
            cell.lblHint.text = @"First Name";
            cell.tfFields.placeholder = @"First Name";
            cell.tfFields.text = _ClaimRecord.firstName;
            cell.tfFields.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.tfFields.inputAccessoryView = self.keybAccessory;
            break;
            
        case 1:
            cell.lblHint.text = @"Last Name";
            cell.tfFields.placeholder = @"Last Name";
            cell.tfFields.text = _ClaimRecord.lastName;
            cell.tfFields.inputAccessoryView = self.keybAccessory;
            cell.tfFields.autocapitalizationType = UITextAutocapitalizationTypeWords;
            break;
            
        case 2:
            cell.lblHint.text = @"Medical Registration Number";
            cell.tfFields.placeholder = @"Medical Registration Number";
            cell.tfFields.inputAccessoryView = self.keybAccessory;
            cell.tfFields.text = _ClaimRecord.medicalReg;
            cell.tfFields.autocapitalizationType = UITextAutocapitalizationTypeWords;
            break;
            
        case 3:
            cell.lblHint.text = @"Email";
            cell.tfFields.placeholder = @"Email (optional)";
            cell.tfFields.text = _ClaimRecord.emailID;
            cell.tfFields.keyboardType = UIKeyboardTypeEmailAddress;
            cell.tfFields.inputAccessoryView = self.keybAccessory;
            break;
            
            
        case 4:
            cell.lblHint.text = @"University / College Name";
            cell.tfFields.placeholder = @"University / College Name (optional)";
            cell.tfFields.text = _ClaimRecord.emailID;
            cell.tfFields.keyboardType = UIKeyboardTypeEmailAddress;
            cell.tfFields.inputAccessoryView = self.keybAccessory;
            break;

            
        default:
            break;
    }
    return cell;
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)doneEditing:(id)sender{
    [self hideKeyboard];
}

- (IBAction)didPressNext:(id)sender {
    data_dic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<4; i++) {
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexpath];
        UITextField* textfield = [cell viewWithTag:101];
        switch (i) {
            case 0:
                if ([self ValidationWithText:textfield.text])
                {
                    if ([self textValidation:textfield.text])
                    {
                        [data_dic setObject:textfield.text forKey:dc_firstName];
                    }else {
                        [UIAppDelegate alerMassegeWithError:@"Please enter valid first name." withButtonTitle:@"OK" autoDismissFlag:NO];
                        return;
                    }
                }else {
                    [UIAppDelegate alerMassegeWithError:@"Please enter first name." withButtonTitle:OK_STRING autoDismissFlag:NO];
                    return;
                }
                break;
            case 1:
                if([textfield hasText]){
                    if ([self textValidation:textfield.text])
                    {
                        [data_dic setObject:textfield.text forKey:dc_lastName];
                    }else {
                        [UIAppDelegate alerMassegeWithError:@"Please enter valid last name." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                }else{
                    [data_dic setObject:@"" forKey:dc_lastName];
                }
                break;
            case 2:
                if([textfield hasText]){
                    
                    if ([self medRegValidation:textfield.text])
                    {
                        [data_dic setObject:textfield.text forKey:UserRegNo];
                    }else {
                        [UIAppDelegate alerMassegeWithError:@"Please enter valid medical registration number." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                }else{
                    [data_dic setObject:@"" forKey:UserRegNo];
                }
                break;
            case 3:
                if([textfield hasText]){
                    if([self emailValidation:textfield.text.lowercaseString]){
                        [data_dic setObject:textfield.text forKey:emailId1];
                    }else{
                        [UIAppDelegate alerMassegeWithError:@"Please enter valid email." withButtonTitle:OK_STRING autoDismissFlag:NO];
                        return;
                    }
                }else
                    [data_dic setObject:@"" forKey:emailId1];
                
                break;
            default:
                break;
        }
    }
    self.isNewUser?[self pushToUploadIdentity]:[self claimAccount];
}

-(void)pushToProfileImageUpload{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewProfileImageVC *NewProfileImage = [storyboard instantiateViewControllerWithIdentifier:@"NewProfileImageVC"];
    NewProfileImage.isAccountClaimed = isAccountClaimed;
    [self.navigationController pushViewController: NewProfileImage animated:YES];
}

-(void)pushToUploadIdentity{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewUploadIdentityVC *UploadIdentity = [storyboard instantiateViewControllerWithIdentifier:@"NewUploadIdentityVC"];
    UploadIdentity.userData = data_dic;
    UploadIdentity.selectedCountry = self.selectedCountry;
    UploadIdentity.selectedAssoID = self.selectedAssoID;
    [self.navigationController pushViewController: UploadIdentity animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.actifText = textField;
    //    CGPoint textfieldpos = [textField convertPoint:CGPointZero toView:self.tableView];
    //    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textfieldpos];
    //
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGPoint textfieldpos = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textfieldpos];
    switch (indexPath.row) {
        case 0:
            _ClaimRecord.firstName = textField.text;
            break;
        case 1:
            _ClaimRecord.lastName = textField.text;
            break;
        case 2:
            _ClaimRecord.medicalReg = textField.text;
            break;
        case 3:
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
    //    NSLog(@"Begin txtFieldPosition : %@",NSStringFromCGPoint(txtFieldPosition));
    NSIndexPath *currentRowIndex = [self.tableView indexPathForRowAtPoint:txtFieldPosition];
    
    //    NSLog(@"Begin txtFieldPosition = %ld",(long)currentRowIndex.row);
    [self.tableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    //   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [self.tableView setContentInset:contentInsets];
    [self.tableView setScrollIndicatorInsets:contentInsets];
}


#pragma mark - Web Service calling
- (void) claimAccount //Claming the account
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetClaimAccount], keyRequestType1,nil];
    NSMutableDictionary *dataDic;
    dataDic =[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[data_dic valueForKey:dc_firstName]],dc_firstName,[NSString stringWithFormat:@"%@",[data_dic valueForKey:dc_lastName]],dc_lastName,[NSString stringWithFormat:@"%@",[data_dic valueForKey:UserRegNo]?[data_dic valueForKey:UserRegNo]:@""],UserRegNo, [NSString stringWithFormat:@"%@",[data_dic valueForKey:emailId1]],emailId1,[NSString stringWithFormat:@"%@",self.selectedCountry],user_country,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetClaimAccount;
    // NSLog(@"claimAccount data dic = %@",dataDic);
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
    // NSLog(@"serviceCalling1");
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
    [[AppDelegate appDelegate] hideIndicator];
    switch (currentRequestType)
    {
        case kSetClaimAccount:
            [self performSelector:@selector(claimAccountResponse:) withObject:responseData afterDelay:0.000];
            break;
            
        case kGetFreiendlist:
            [self performSelector:@selector(getFriendListResponse:) withObject:responseData afterDelay:0.000];
            break;
        default:
            break;
    }
}

- (void)claimAccountResponse:(NSDictionary *)response{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    // NSLog(@"Claim Account Response: %@",resposeCode);
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:AppName message:defaultErrorMsg delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
     if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            isAccountClaimed = YES;
            [self updateUserDefaults:resposeCode];
          }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
            [alert show];
        }
    }
}

-(void) getFriendListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode == nil)
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
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
}

#pragma mark - Store values
-(void)updateUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil)
    {
        // resposeCode is null
    }
    else {
        
        NSString *userCity = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        [userpref setObject:userCity?userCity:@"" forKey:user_city];
        NSString *userCountry = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
        NSString *userCountryCode = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
        
        NSString *customId =[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"custom_id"]?[resposeCode  objectForKey:@"custom_id"]:@""];
        [Localytics setCustomerId:customId];
        [userpref setObject:customId?customId:@"" forKey:ownerCustId];
        [userpref setObject:customId?customId:@"" forKey:custId];
        
        NSString *u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        [Localytics setCustomerEmail:u_email];
        [userpref setObject:u_email?u_email:@"" forKey:emailId1];
        
        NSString *u_fName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"first_name"]?[resposeCode  objectForKey:@"first_name"]:@""];
        [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
        
        NSString *JabberID = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_id"]?[resposeCode  objectForKey:@"jabber_id"]:@""];
        [userpref setObject:JabberID?JabberID:@"" forKey:jabberId];
        
        jabberName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_name"]?[resposeCode  objectForKey:@"jabber_name"]:@""];
        [userpref setObject:jabberName?jabberName:@"" forKey:kjabberName];
        
        NSString *u_lName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"last_name"]?[resposeCode  objectForKey:@"last_name"]:@""];
        [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
        
        NSString *userMobNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
        
        userPic = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"profile_pic_path"]?[resposeCode  objectForKey:@"profile_pic_path"]:@""];
        [userpref setObject:userPic?userPic:@"" forKey:profileImage];
        
        NSString *userRegNo = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"registration_no"]?[resposeCode  objectForKey:@"registration_no"]:@""];
        [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        
        NSString *userState = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        [userpref setObject:userState?userState:@"" forKey:user_state];
        
        NSString *uId=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"user_id"]?[resposeCode  objectForKey:@"user_id"]:@""];
        [userpref setObject:uId?uId:@"" forKey:userId];
        
        NSString *refLink = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"referal_link"]?[resposeCode  objectForKey:@"referal_link"]:@""];
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
        [userpref setBool:YES forKey:signInnormal];
        NSString *u_authkey=[NSString stringWithFormat:@"%@", [usrAuthkey objectForKey:@"auth_key"]?[usrAuthkey objectForKey:@"auth_key"]:@""];
        [userpref setObject:u_authkey?u_authkey:@"" forKey:userAuthKey];
        [userpref synchronize];
    }
     NSMutableDictionary*usrjabber  = [postDic objectForKey:@"jabber"];
    if ([usrjabber  isKindOfClass:[NSNull class]] || usrjabber == nil)
    {
        // usrjabber is null
    }
    else {
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
        [self downloadWithNsurlconnection];
       // [[AppDelegate appDelegate] connect];
        [self loginInQuickblox];
        [self getFriendListServiceCalling];
        [self pushToProfileImageUpload];
    }
}

#pragma mark - download profile
-(void)downloadWithNsurlconnection
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",userPic]];
    // NSLog(@"Login IMG URL : %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
  //  NSLog(@"connection : %@",connection);
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

#pragma mark - Mail Service
-(void)openMail{
    if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:AppName message:@"Mail services are not available. Please configure your mail service first." buttonTitle:OK_STRING];
        return;
    }else{
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[SupportEmail]];
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

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

-(void)loginInQuickblox{
    QBUUser *selectedUser = [QBUUser new];
    selectedUser.login = jabberName;
    selectedUser.password = jabberPassword;
    // __weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            //            __typeof(self) strongSelf = weakSelf;
            
           // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            //            [strongSelf registerForRemoteNotifications];
            //            [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
           // NSLog(@"Succss login in quikblox");
           // [self pushToFeedVc];
        } else {
           // [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}

@end
