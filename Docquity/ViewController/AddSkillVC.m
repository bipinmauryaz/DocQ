/*============================================================================
 PROJECT: Docquity
 FILE:    AddSkillVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 16/06/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "AddSkillVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "UserTimelineVC.h"
#import "NewProfileVC.h"

/*============================================================================
 Interface: AddSkillVC
 =============================================================================*/
@interface AddSkillVC (){
    NSString*spId;
}
- (void) endEditing;
@end

@implementation AddSkillVC
@synthesize addSkillTF;
@synthesize myToolbar,keybAccessory;
@synthesize scroll,scvwContentView;
@synthesize isSaveBtnClicked;
@synthesize sepclListArr;
@synthesize pickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Registering Touch event on scroll
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.scroll addGestureRecognizer:singleTap];
    // Do any additional setup after loading the view from its nib.
    
    self.sepclListArr = [[NSMutableArray alloc]init];
    self.addSkillTF.inputAccessoryView = self.keybAccessory;
    
    pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [self getSpecialitylistRequest];
  }

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scroll.contentSize=self.scvwContentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}


#pragma mark properties setters and getters methods
-(void)setOptions:(NSMutableArray *)options{
    options = [options copy];
    //Updating the picker DS
    self.sepclListArr = nil;
    self.sepclListArr = (nil == options)?[NSMutableArray array]:options;
    
    //Updating the pickerView
    pickerView = (UIPickerView *)self.inputView;
    [pickerView reloadAllComponents];
}

-(void)setSelIndex:(NSInteger)selIndex{
    long int maxIdx =  self.sepclListArr.count - 1;
    int minIdx = 0;
    selIndex = (selIndex < minIdx)?minIdx:((selIndex > maxIdx)?maxIdx:selIndex);
    
    //Updating the selectedRow pickerView
    pickerView = (UIPickerView *)self.inputView;
    [pickerView selectRow:selIndex inComponent:1 animated:NO];
}

#pragma mark UIPickerViewDataSource methods
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  self.sepclListArr.count;
}

#pragma mark UIPickerViewDelegate methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *spclDic=[self.sepclListArr objectAtIndex:row];
    return [spclDic objectForKey:@"speciality_name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSDictionary *spclDic=[self.sepclListArr objectAtIndex:row];
    addSkillTF.text = [spclDic objectForKey:@"speciality_name"];
    spId =[NSString stringWithFormat:@"%@", [spclDic objectForKey:@"speciality_id"]?[spclDic objectForKey:@"speciality_id"]:@""];
//    NSLog(@"speciality=%@",spId);
    NSInteger selIndex = row;
//    NSLog(@"selected index=%ld",(long)selIndex);
}

#pragma mark - save & AddMore Button Action
-(IBAction)saveAndMoreBtn:(id)sender{
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
    isSaveBtnClicked = NO;
    if ((self.addSkillTF.text.length==0) || [self.addSkillTF.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Field can not be empty." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSString *trimmedString = [self.addSkillTF.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@""]) {
            [self setCreateSpecialityRequest:self.addSkillTF.text specialitybyId:spId];
        }
    }
}

#pragma mark - back Button Action
-(IBAction)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.sepclListArr count]>0) {
    if (addSkillTF.editing ==YES) {
        addSkillTF.tag = 155;
        addSkillTF.text = [[self.sepclListArr objectAtIndex:0]valueForKey:@"speciality_name"];
        spId = [[self.sepclListArr objectAtIndex:0]valueForKey:@"speciality_id"];
     }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //activeField = nil;
    // NSLog(@"textFieldDidEndEditingcalled");
}

#pragma mark - save Button Action
-(IBAction)saveBtn:(id)sender{
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
    isSaveBtnClicked = YES;
    if ((self.addSkillTF.text.length==0) || [self.addSkillTF.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Field can not be empty." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        NSString *trimmedString = [self.addSkillTF.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@""]) {
            [self setCreateSpecialityRequest:self.addSkillTF.text specialitybyId:spId];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

#pragma mark - create speciality api calling
-(void)setCreateSpecialityRequest:(NSString *)SpecialityName specialitybyId:(NSString*)specilityIds {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetSpecialityRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] speciality_id:specilityIds speciality_name:SpecialityName format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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
                if (isSaveBtnClicked){
                    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                    NSString *custmId=[userpref objectForKey:ownerCustId];
                    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                    NewProfile .custid=  custmId;
                    NewProfile.hidesBottomBarWhenPushed = YES;
                    [AppDelegate appDelegate].isComeFromSettingVC = NO;
                    [self.navigationController pushViewController:NewProfile animated:YES];              }
                else{
                    self.addSkillTF.text = @"";
                }
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

#pragma mark - get speciality list api calling
-(void)getSpecialitylistRequest{
    [[DocquityServerEngine sharedInstance]GetSpecialityRequest:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                self.sepclListArr =[resposePost objectForKey:@"speciality"];
                //Setting pickerView as inputView
                self.addSkillTF.inputView =pickerView;
                
                for (int index = 0; index<=[self.sepclListArr count]; index++)
                {
                    if(index<[self.sepclListArr count]){
                        NSDictionary *spclDic = [self.sepclListArr objectAtIndex:index];
                        NSString*spclName =[NSString stringWithFormat:@"%@", [spclDic objectForKey:@"speciality_name"]?[spclDic objectForKey:@"speciality_name"]:@""];
//                       NSLog(@"speciality=%@",spclName);
                    NSString* spclityId =[NSString stringWithFormat:@"%@", [spclDic objectForKey:@"speciality_id"]?[spclDic objectForKey:@"speciality_id"]:@""];
  //                      NSLog(@"speciality=%@",spclityId);
                    }
                }
                
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
