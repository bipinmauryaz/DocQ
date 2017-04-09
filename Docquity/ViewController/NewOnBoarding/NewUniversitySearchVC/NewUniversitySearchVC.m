//
//  NewUniversitySearchVC.m
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewUniversitySearchVC.h"

@interface NewUniversitySearchVC ()

@end

@implementation NewUniversitySearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Select Institute Name"];
     tfSearch.inputAccessoryView = self.keybAccessory;
    // Do any additional setup after loading the view.
    //[self  ServiceHitForGetUniversityList];
 }

-(void)viewWillAppear:(BOOL)animated
{
    [Localytics tagEvent:@"OnboardingSelectCollegeScreen Visit"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingSelectCollegeScreen" screenAction:@"OnboardingSelectCollegeScreen Visit"];
    [super viewWillAppear:animated];
    tfSearch.text =@"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableview Delegates and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  [_arrayUniSearch count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"newUniversityCell";
    NewUniversityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
     cell = [[NewUniversityCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.lblName.text = [_arrayUniSearch objectAtIndex:indexPath.row][@"university_id"];
    cell.lblUniversityName.text = [[_arrayUniSearch objectAtIndex:indexPath.row][@"university_name"]stringByDecodingHTMLEntities];;
    return cell;
}

#pragma mark - getUniversityListRequest
-(void)ServiceHitForGetUniversityList{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@association/get?rquest=university_list&version=%@&iso_code=&keyword=%@&lang=%@",NewWebUrl,kApiVersion,tfSearch.text,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error){
        if (response) {
           [SVProgressHUD dismiss];
            // NSLog(@"%@",response);
            NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
            // NSLog(@"%@",responseDict);
            if ([[responseDict valueForKeyPath:@"posts.msg"] isEqualToString:@"Success."] && [[responseDict valueForKeyPath:@"posts.status"] integerValue]== 1 && ![[responseDict valueForKeyPath:@"posts.data.university_list"] isKindOfClass:[NSNull class]]) {
                _arrayUniSearch = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.university_list"]];
                [tableViewSearch reloadData];
            }
             else if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 0)
            {
              [WebServiceCall showAlert:AppName andMessage:[responseDict valueForKeyPath:@"posts.msg"] withController:self];
            }
            else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
        else if (error)
        {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
        }
    }];
}

#pragma mark - UITextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [tfSearch resignFirstResponder];
    //DLog(@"singTap called");
    if([tfSearch.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please input any text to search University" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
     [self ServiceHitForGetUniversityList];
    }
     return YES;
}

//-(BOOL)textFieldShouldClear:(UITextField *)textField{
//    return YES;
//}

//-(BOOL)textFieldShouldClear:(UITextField *)textField{
//    isSearching = false;
//    [tableViewSearch reloadData];
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField.text.length==0 && [string isEqualToString:@" "]) {
//        isSearching = false;
//        return NO;
//    }
//    isSearching = true;
//    NSLog(@"%@",string);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"speciality_name CONTAINS[cd] %@", [textField.text stringByReplacingCharactersInRange:range withString:string]];
//    NSArray *filtered = [_arraySpeciality filteredArrayUsingPredicate:predicate];
//    if (filtered.count) {
//        _arrFiltered = [NSMutableArray arrayWithArray:filtered];
//        [tableViewSearch reloadData];
//    }
//    return true;
//}
//

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (IBAction)doneEditing:(id)sender
{
    [tfSearch resignFirstResponder];
     if([tfSearch.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please input any text to search University" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self ServiceHitForGetUniversityList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict;
    if (indexPath.section ==0) {
        if(indexPath.row<[self.arrayUniSearch count]){
        dict = [self.arrayUniSearch  objectAtIndex: indexPath.row];
        // NSString*  universityId  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"university_id"]];
        // NSString*  universityName  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"university_name"]];
           // [self dismissViewControllerAnimated:YES completion:nil];
            // [self.navigationController pushViewController:lv animated:YES];
        }
    }
    self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    SpecialityVC *specialityvw = [storyboard instantiateViewControllerWithIdentifier:@"SpecialityVC"];
    specialityvw.registered_userType = _registered_userType;
    specialityvw.universityDic = dict;
    [self.navigationController pushViewController:specialityvw animated:YES];
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
