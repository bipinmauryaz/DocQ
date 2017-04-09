//
//  SpecialityVC.m
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "SpecialityVC.h"
#import "ServicesManager.h"
#import "DocquityServerEngine.h"

@interface SpecialityVC ()

@end

@implementation SpecialityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
         if ([_registered_userType isEqualToString:@"student"]){
             [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Select your Interest"];
         }
         if ([_registered_userType isEqualToString:@"doctor"]){
             [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems: @"Select your Specialization"];
     }
     */
    
     [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Select your Interest"];

    self.automaticallyAdjustsScrollViewInsets = NO;
    _arraySelectedCell = [[NSMutableArray alloc]init];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    tfSearch.leftView = paddingView;
    tfSearch.leftViewMode = UITextFieldViewModeAlways;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Do any additional setup after loading the view.
    [self ServiceHitForGetSpecialityList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [Localytics tagEvent:@"OnboardingSelectSpecialityScreen Visit"];
   [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingSelectSpecialityScreen" screenAction:@"OnboardingSelectSpecialityScreen Visit"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard Notifications
-(void)keyBoardShow:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    tableViewSpeciality.frame = CGRectMake(0, tableViewSpeciality.frame.origin.y, tableViewSpeciality.frame.size.width,tableViewSpeciality.frame.size.height-height);
}

-(void)keyBoardHide:(NSNotification *)notification{
    tableViewSpeciality.frame = CGRectMake(0, tableViewSpeciality.frame.origin.y, tableViewSpeciality.frame.size.width, self.view.frame.size.height-104);
}

#pragma mark - Tableview DataSource and Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearching)
        return _arrFiltered.count;
    else
    return _arraySpeciality.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"specialityCell";
    MedicalSpecialityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[MedicalSpecialityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSNumber *selectedID;
    if (isSearching)
    {
        cell.lblSpeciality.text = [[_arrFiltered objectAtIndex:indexPath.row][@"speciality_name"]stringByDecodingHTMLEntities];
        selectedID = [_arrFiltered objectAtIndex:indexPath.row][@"speciality_id"];
       // cell.lblSpecialityBrief.text =  [NSString stringWithFormat:@"With all member of %@", [_arrFiltered objectAtIndex:indexPath.row][@"speciality_name"]];
    }
    else{
       cell.lblSpeciality.text = [[_arraySpeciality objectAtIndex:indexPath.row][@"speciality_name"]stringByDecodingHTMLEntities];
        selectedID = [_arraySpeciality objectAtIndex:indexPath.row][@"speciality_id"];
        // cell.lblSpecialityBrief.text =  [NSString stringWithFormat:@"With all member of %@", [_arraySpeciality objectAtIndex:indexPath.row][@"speciality_name"]];
          // stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]]
        }
    //Create speciality default ImageView
    cell.imageView_Specialty.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView_Specialty.layer.cornerRadius = 4.0f;
    cell.imageView_Specialty.layer.masksToBounds = YES;
    cell.imageView_Specialty.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    cell.imageView_Specialty.layer.borderWidth = 0.5;
    cell.imageView_Specialty.clipsToBounds = YES;
    [cell.imageView_Specialty  setImageWithString:cell.lblSpeciality.text color:nil circular:NO];
    if ([_arraySelectedCell containsObject:selectedID]) {
        cell.checkUncheck.image = [UIImage imageNamed:@"CheckSelected"];
    }else
        cell.checkUncheck.image = [UIImage imageNamed:@"CheckUnselected"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber *selectedID;
    if (isSearching) {
        selectedID = [_arrFiltered objectAtIndex:indexPath.row][@"speciality_id"];
    }else{
        selectedID = [_arraySpeciality objectAtIndex:indexPath.row][@"speciality_id"];
    }
    if ([self.arraySelectedCell containsObject:selectedID])
    {
        [self.arraySelectedCell removeObject:selectedID];
    }
    else
    {
     [self.arraySelectedCell addObject:selectedID];
    }
    [tableView reloadData];
}

#pragma mark - UItextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    isSearching = false;
    [tableViewSpeciality reloadData];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length==0 && [string isEqualToString:@" "]) {
        isSearching = false;
        return NO;
    }
    isSearching = true;
   // NSLog(@"%@",string);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"speciality_name CONTAINS[cd] %@", [textField.text stringByReplacingCharactersInRange:range withString:string]];
    NSArray *filtered = [_arraySpeciality filteredArrayUsingPredicate:predicate];
    if (filtered.count) {
    _arrFiltered = [NSMutableArray arrayWithArray:filtered];
    [tableViewSpeciality reloadData];
    }
   return true;
}

#pragma mark - getSpecialityListRequest
-(void)ServiceHitForGetSpecialityList{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@association/get?rquest=speciality_list&version=%@&iso_code=&lang=%@",NewWebUrl,kApiVersion,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error){
        if (response) {
            [SVProgressHUD dismiss];
            NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
            if ([[responseDict valueForKeyPath:@"posts.msg"] isEqualToString:@"Success."] && [[responseDict valueForKeyPath:@"posts.status"] integerValue]== 1 && ![[responseDict valueForKeyPath:@"posts.data.speciality_list"] isKindOfClass:[NSNull class]]) {
                _arraySpeciality = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.speciality_list"]];
                [tableViewSpeciality reloadData];
            }
                else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 0)
                {
                    [WebServiceCall showAlert:AppName andMessage:[responseDict valueForKeyPath:@"posts.msg"] withController:self];
                }
                else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 9)
                {
                    [[AppDelegate appDelegate]logOut];
                }
            }
        else if (error){
            [SVProgressHUD dismiss];
            NSLog(@"%@",error);
        }
    }];
}

//NSString * result = [array description];
#pragma mark - setRegisterUserRequest
-(void)SetRegisterUserRequest
{
    [WebServiceCall showHUD];
    NSString *University_jsonString;
    NSString*josn_specialityId;
    NSString*associationIdStr;
    if([_registered_userType isEqualToString:@"student"]){
    NSString*  universityId  = [NSString stringWithFormat:@"%@", [_universityDic valueForKey:@"university_id"]];
         NSString*  universityName  = [NSString stringWithFormat:@"%@", [_universityDic valueForKey:@"university_name"]];
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",universityId?universityId:@""],@"university_id",[NSString stringWithFormat:@"%@",universityName?universityName:@""],@"university_name",nil];
    NSError * error;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    University_jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",University_jsonString);
   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.arraySelectedCell options:NSJSONWritingPrettyPrinted error:&error];
        josn_specialityId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        josn_specialityId = [[josn_specialityId componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
   // NSLog(@"josn_specialityId =%@",josn_specialityId);
        associationIdStr = @"30";
}
    else{
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.arraySelectedCell options:NSJSONWritingPrettyPrinted error:&error];
        josn_specialityId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        josn_specialityId = [[josn_specialityId componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
       // NSLog(@"josn_specialityId =%@",josn_specialityId);
        NSMutableArray *AssoIdArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"AssociationIdArray"] mutableCopy];
        if ([AssoIdArray count] == 0)
        {
            associationIdStr  = @"34";
        }
        else
        {
        associationIdStr = [[AssoIdArray valueForKey:@"description"] componentsJoinedByString:@","];
        }
    }
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"first_name" :[userpref valueForKey:@"userFirstName"],@"last_name":[userpref valueForKey:@"userLastName"], @"registration_no" :[userpref valueForKey:@"userMedicalNumber"],@"email":[userpref valueForKey:@"userEmail"],@"iso_code":@"",@"registered_user_type":_registered_userType,@"speciality" :josn_specialityId,@"university" :University_jsonString?University_jsonString:@"",@"country":[userpref valueForKey:@"NameCountry"],@"association_id":associationIdStr,@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"registration/set?rquest=register_user" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
           // [SVProgressHUD dismiss];
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
                    [self updateUserDefaults:resposePost];
                    /*
                    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                    [userpref removeObjectForKey:@"AssociationIdArray"];
                     */
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
           //NSLog(@"%@",error);
        }
    }];
}

- (IBAction)didPressNext:(id)sender {
    if (_arraySelectedCell.count==0) {
          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppName message:kInterestValidationMsg preferredStyle:UIAlertControllerStyleAlert];
          [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
          [self presentViewController:alertController animated:YES completion:nil];
          return;
    }
    [self SetRegisterUserRequest];
}

#pragma mark - Store dictionary Value
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
            NSString* userCity = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"city"]?[logindataDic  objectForKey:@"city"]:@""];
            [userpref setObject:userCity?userCity:@"" forKey:user_city];
            NSString* userCountry = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"country"]?[logindataDic  objectForKey:@"country"]:@""];
            [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
            NSString* userCountryCode = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"country_code"]?[logindataDic  objectForKey:@"country_code"]:@""];
            [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
            NSString* userType = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"user_type"]?[logindataDic  objectForKey:@"user_type"]:@""];
            NSString* customId =[NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"custom_id"]?[logindataDic  objectForKey:@"custom_id"]:@""];
            [userpref setObject:customId?customId:@"" forKey:ownerCustId];
            [userpref setObject:customId?customId:@"" forKey:custId];
            NSString* u_email = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"email"]?[logindataDic  objectForKey:@"email"]:@""];
            [userpref setObject:u_email?u_email:@"" forKey:emailId1];
            NSString*  u_fName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"first_name"]?[logindataDic  objectForKey:@"first_name"]:@""];
            [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
            JabberName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"jabber_name"]?[logindataDic objectForKey:@"jabber_name"]:@""];
            [userpref setObject:JabberName?JabberName:@"" forKey:kjabberName];
            NSString* u_lName = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"last_name"]?[logindataDic  objectForKey:@"last_name"]:@""];
            [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
            NSString*   userMobNo = [NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"mobile"]?[logindataDic  objectForKey:@"mobile"]:@""];
            [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
            userPic = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"profile_pic_path"]?[logindataDic  objectForKey:@"profile_pic_path"]:@""];
            [userpref setObject:userPic?userPic:@"" forKey:profileImage];
            NSString*userRegNo = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"registration_no"]?[logindataDic  objectForKey:@"registration_no"]:@""];
            [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
            NSString*  userState = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"state"]?[logindataDic  objectForKey:@"state"]:@""];
            [userpref setObject:userState?userState:@"" forKey:user_state];
            NSString*  uId=[NSString stringWithFormat:@"%@",[logindataDic objectForKey:@"user_id"]?[logindataDic  objectForKey:@"user_id"]:@""];
            [userpref setObject:uId?uId:@"" forKey:userId];
            NSString*  refLink = [NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"referal_id"]?[logindataDic  objectForKey:@"referal_id"]:@""];
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
            trackId =[NSString stringWithFormat:@"%@", [logindataDic objectForKey:@"trackId"]?[logindataDic objectForKey:@"trackId"]:@""];
            [userpref setObject:trackId?trackId:@"" forKey:@"kAppTrackId"];
        }
    }
    if([[postDic valueForKey:@"status"] integerValue] == 1)
    {
        [self downloadWithNsurlconnection]; // Download Profile Picture
       // [self checkLoginUserForQuickblox];  // Checking the quickblox login
        [self pushToUserImageUploadVC];
    }
    else if([[postDic valueForKey:@"status"] integerValue] == 2)
    {
       // [self pushToVerifyAccountWithUserFlag:NO];
    }
}

-(void)pushToUserImageUploadVC{
    [SVProgressHUD dismiss];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    UserImageUploadVC *imgUpload = [storyboard instantiateViewControllerWithIdentifier:@"UserImageUploadVC"];
    imgUpload.registeredUserType = _registered_userType;
    [self.navigationController pushViewController:imgUpload animated:YES];
}

-(void)checkLoginUserForQuickblox{
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    if (currentUser != nil)
    {
        //NSLog(@"user loggedin... Logging Out...");
        [self logoutFromQuickblox];
    }else{
        //   NSLog(@"user not logged in... Logging In...");
        if (([chatId  isEqualToString:@""] || [chatId isEqualToString:@"<null>"]) && ([jabberPassword  isEqualToString:@""] || [jabberPassword isEqualToString:@"<null>"])) {
            [self updatechatCredentialToQuickblox];
        }
        else
        {
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
        //[[AppDelegate appDelegate] hideIndicator];
        [SVProgressHUD dismiss];
        if (success) {
            // __typeof(self) strongSelf = weakSelf;
            NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
            [userpref setBool:YES forKey:signInnormal];
            //  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            //  [strongSelf registerForRemoteNotifications];
            //  [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
            //     NSLog(@"Succss login in quikblox");
           // [self pushToFeedVc];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
            UserImageUploadVC *imgUpload = [storyboard instantiateViewControllerWithIdentifier:@"UserImageUploadVC"];
            imgUpload.registeredUserType = _registered_userType;
            [self.navigationController pushViewController:imgUpload animated:YES];
        }
        else {
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
                chatId  =        dataDic[@"chat_id"];
                JabberName  =    dataDic[@"jabber_name"];
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
//


@end
