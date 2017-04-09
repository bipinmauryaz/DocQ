//
//  NewVerifySelfVC.m
//  Docquity
//
//  Created by Arimardan Singh on 23/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewVerifySelfVC.h"
#import "MedicalSpecialityCell.h"

@interface NewVerifySelfVC ()

@end

@implementation NewVerifySelfVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.title = @"Select Your Interest";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _arraySelectedCell = [[NSMutableArray alloc]init];
    _arraySpecialityName = [[NSMutableArray alloc]init];
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
    // Do any additional setup after loading the view.
}

#pragma mark - Service Hit for update_user_personal_info
-(void)serviceHitForUpdateUserPersonalInfo{
    [WebServiceCall showHUD];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSDictionary *parameters = @ {@"version" :kApiVersion ,@"device_type" :kDeviceType,@"email":@"",@"registration_no":@"",@"claim_code":@"",@"speciality":@"", @"iso_code":@"" ,@"app_version" :[userpref valueForKey:kAppVersion],@"lang" :kLanguage };
    [WebServiceCall callServiceWithPOSTName:NewWebUrl@"profile/set?rquest=update_user_personal_info&version" withHeader:AuthorizationAppKey postData:parameters callBackBlock:^(id response, NSError *error){
        if (response) {
            [SVProgressHUD dismiss];
            NSError *errorJson=nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
            if ([[responseDict valueForKeyPath:@"posts.msg"] isEqualToString:@"Success."] && [[responseDict valueForKeyPath:@"posts.status"] integerValue]== 1)
            {
                
            }
        }
        else if (error){
            [SVProgressHUD dismiss];
            [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
           // NSLog(@"%@",error);
        }
    }];
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
    NSString*specialityName;
    if (isSearching) {
        selectedID = [_arrFiltered objectAtIndex:indexPath.row][@"speciality_id"];
        specialityName = [_arrFiltered objectAtIndex:indexPath.row][@"speciality_name"];
        
    }else{
        selectedID = [_arraySpeciality objectAtIndex:indexPath.row][@"speciality_id"];
        specialityName = [_arraySpeciality objectAtIndex:indexPath.row][@"speciality_name"];
    }
    if ([self.arraySelectedCell containsObject:selectedID])
    {
        [self.arraySelectedCell removeObject:selectedID];
        [self.arraySpecialityName removeObject:specialityName];
    }
    else
    {
        [self.arraySpecialityName addObject:specialityName];
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
           // NSLog(@"%@",error);
        }
    }];
}

-(IBAction)didPressDoneBtn:(id)sender{
     if (_arraySelectedCell.count==0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppName message:kInterestValidationMsg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
     [self.delegate selectedInterstName:self.arraySpecialityName InterestID:self.arraySelectedCell InterestArray:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
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
