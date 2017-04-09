//
//  NewCountryVC.m
//  Docquity
//
//  Created by Docquity-iOS on 24/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewCountryVC.h"
#import "NewUserMobileVC.h"
#import "NewAssoicationVC.h"


@interface NewCountryVC ()

@end

@implementation NewCountryVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Select Your Country"];
    [self serviceHitForCountryList];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    tfSerchCountry.leftView = paddingView;
    tfSerchCountry.leftViewMode = UITextFieldViewModeAlways;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [Localytics tagEvent:@"OnboardingPickCountryScreen Visit"];
  [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingPickCountryScreen" screenAction:@"OnboardingPickCountryScreen Visit"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notifications
-(void)keyBoardShow:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    tableViewCountry.frame = CGRectMake(0, tableViewCountry.frame.origin.y, tableViewCountry.frame.size.width,tableViewCountry.frame.size.height-height);
}

-(void)keyBoardHide:(NSNotification *)notification{
    tableViewCountry.frame = CGRectMake(0, tableViewCountry.frame.origin.y, tableViewCountry.frame.size.width, self.view.frame.size.height-104);
 }

#pragma mark - Service Hit
-(void)serviceHitForCountryList{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@registration/get?rquest=countrylist&version=%@&registered_user_type=%@&lang=%@",NewWebUrl,kApiVersion,_userType,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
        if (response) {
            [SVProgressHUD dismiss];
            NSError *errorJson=nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
             _arrDataSource = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.list"]];
            if (_arrDataSource.count==0) {
                [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
            }
            [tableViewCountry reloadData];
                    }else if (error){
                        [SVProgressHUD dismiss];
                        [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
            NSLog(@"%@",error);
        }
     }];
}

#pragma mark - UItableView Delegates and DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearching) {
        return _arrFiltered.count;
    }
    else
    return self.arrDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"countryCell";
    CountryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[CountryCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
     if (isSearching) {
        [cell.imageCountryFlag sd_setImageWithURL:[NSURL URLWithString:[_arrFiltered objectAtIndex:indexPath.row][@"country_pic"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
         
         cell.imageCountryFlag.layer.cornerRadius = cell.imageCountryFlag.frame.size.height / 2;
         cell.imageCountryFlag.clipsToBounds= YES;
        cell.lblCountryName.text = [[[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country"]stringByDecodingHTMLEntities];
        cell.lblCountryCode.text = [NSString stringWithFormat:@"+%@",[[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country_code"]];
    }
    else
    {
        [cell.imageCountryFlag sd_setImageWithURL:[NSURL URLWithString:[_arrDataSource objectAtIndex:indexPath.row][@"country_pic"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
        cell.imageCountryFlag.layer.cornerRadius = cell.imageCountryFlag.frame.size.height / 2;
        cell.imageCountryFlag.clipsToBounds= YES;
        cell.lblCountryName.text = [[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country"]stringByDecodingHTMLEntities];
        cell.lblCountryCode.text = [NSString stringWithFormat:@"+%@",[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country_code"]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NSUserDefaults*userdef = [ NSUserDefaults standardUserDefaults];
     if (isSearching) {
         countryCode =  [NSString stringWithFormat:@"%@",[[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country_code"]];
        associationCount = [NSString stringWithFormat:@"%@",[[_arrFiltered  objectAtIndex:indexPath.row]objectForKey:@"association_count"]];
        countryId = [NSString stringWithFormat:@"%@",[[_arrFiltered  objectAtIndex:indexPath.row]objectForKey:@"country_id"]];
        countryName = [[[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country"]stringByDecodingHTMLEntities];
    }
    else{
    countryCode =  [NSString stringWithFormat:@"%@",[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country_code"]];
    associationCount = [NSString stringWithFormat:@"%@",[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"association_count"]];
    countryId = [NSString stringWithFormat:@"%@",[[_arrDataSource
                                                   objectAtIndex:indexPath.row]objectForKey:@"country_id"]];
    countryName = [[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country"]stringByDecodingHTMLEntities];
    }
    [userdef setObject:countryCode forKey:@"CountryCodeName"];
    [userdef setObject:countryName forKey:@"NameCountry"];
    [userdef synchronize];
     if ([associationCount isEqualToString:@"0"]) {
        NewUserMobileVC *newMobile = [storyboard instantiateViewControllerWithIdentifier:@"NewUserMobileVC"];
        newMobile.registered_userType = _userType;
        newMobile.countryCode = countryCode;
        newMobile.strCountryCode = [NSString stringWithFormat:@"+%@",countryCode];
        newMobile.assoIdCountNumber = associationCount;
        [self.navigationController pushViewController:newMobile animated:YES];
   }
   else
    {
    NewAssoicationVC *newassovw = [storyboard instantiateViewControllerWithIdentifier:@"NewAssoicationVC"];
    newassovw.registered_userType = _userType;
    newassovw.asso_countryCode = countryCode;
    newassovw.Id_country = countryId;
    [self.navigationController pushViewController:newassovw animated:YES];
    }
 }

#pragma mark - UItextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    isSearching = false;
    [tableViewCountry reloadData];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length==0 && [string isEqualToString:@" "]) {
        isSearching = false;
        return NO;
    }
    isSearching = true;
   // NSLog(@"%@",string);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@", [textField.text stringByReplacingCharactersInRange:range withString:string]];
    NSArray *filtered = [_arrDataSource filteredArrayUsingPredicate:predicate];
    if (filtered.count) {
        _arrFiltered = [NSMutableArray arrayWithArray:filtered];
        [tableViewCountry reloadData];
    }
    return true;
}

#pragma mark - Service Get Feedlist
-(void)serviceHitForGetFeedlist{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@feed/get?rquest=feed_list&version=%@&offset=%@&limit=%@&filter=%@&iso_code=%@&device_type=%@&app_version=%@&lang=%@",NewWebUrl,kApiVersion,@"1",@"10",@"post",@"",kDeviceType,kAppVersion,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
         if (response) {
             [SVProgressHUD dismiss];
             NSError *errorJson=nil;
             NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
             _arrDataSource = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.list"]];
             if (_arrDataSource.count==0) {
                 [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
             }
             [tableViewCountry reloadData];
         }else if (error){
             [SVProgressHUD dismiss];
             [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
             NSLog(@"%@",error);
         }
     }];
}

#pragma mark - Service Get singleFeedDetails
-(void)serviceHitForGetSingleFeedDetails{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@feed/get.php?rquest=single_feed&version=%@&feed_id=%@&iso_code=%@&device_type=%@&app_version=%@&lang=%@",NewWebUrl,kApiVersion,@"1",@"",kDeviceType,kAppVersion,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
         if (response) {
             [SVProgressHUD dismiss];
             NSError *errorJson=nil;
             NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
             _arrDataSource = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.list"]];
             if (_arrDataSource.count==0) {
                 [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
             }
             [tableViewCountry reloadData];
         }else if (error){
             [SVProgressHUD dismiss];
             [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
             NSLog(@"%@",error);
         }
     }];
}

#pragma mark - Service GetArchiveFeedRequest
-(void)serviceHitForGetArchiveFeedRequest{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@feed/get.php?rquest=archive_feed_list&version=%@&offset=%@&limit=%@&filter=%@&iso_code=%@&device_type=%@&app_version=%@&lang=%@",NewWebUrl,kApiVersion,@"1",@"10",@"",@"",kDeviceType,kAppVersion,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
         if (response) {
             [SVProgressHUD dismiss];
             NSError *errorJson=nil;
             NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
             _arrDataSource = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.list"]];
             if (_arrDataSource.count==0) {
                 [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
             }
             [tableViewCountry reloadData];
         }else if (error){
             [SVProgressHUD dismiss];
             [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
             NSLog(@"%@",error);
         }
     }];
}

#pragma mark - SetArchiveFeedRequest
-(void)SetArchiveFeedRequest
{
    [WebServiceCall showHUD];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"feed_id" :@"",@"iso_code":@"",@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"feed/set?rquest=archive_feed" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
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


#pragma mark - SetUndoArchiveFeedRequest
-(void)SetUndoArchiveFeedRequest
{
    [WebServiceCall showHUD];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion, @"feed_id" :@"",@"iso_code":@"",@"device_type" :kDeviceType,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"feed/set?rquest=undo_archive_feed" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
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


@end
