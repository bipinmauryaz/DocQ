/*============================================================================
 PROJECT: Docquity
 FILE:    EditInterestVC.m
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/05/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "EditInterestVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"
/*============================================================================
 Interface: EditInterestVC
 =============================================================================*/
@interface EditInterestVC (){
    NSString*interestId1; // interest id
    long  int curentindex; //current selected index
    NSString*interestName;
}
- (void) endEditing;
@end

@implementation EditInterestVC
@synthesize editIntListArray,editIntTV,editIntCell;
@synthesize addIntTF;
@synthesize keybAccessory,myToolbar;

- (void)viewDidLoad {
    self.addIntTF.inputAccessoryView = self.keybAccessory;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.addIntTF.userInteractionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editIntTV setEditing:NO];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - back Button Action
-(IBAction)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.editIntListArray count];
    //	NSLog(@"numberOfRowsInSection");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSArray *nib;
    NSString *cellID = @"editIntCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"EditIntTVCell" owner:self options:nil];
        if([nib count] > 0)
        {
            cell = self.editIntCell;
        }
    }
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *intName =nil;
    NSString*inteId = nil;
    if([self.editIntListArray count]>0)
    {
            if([self.editIntListArray objectAtIndex:indexPath.row]){
                InterestModel *interstModel=[self.editIntListArray objectAtIndex:indexPath.row];
                if(interstModel && [interstModel isKindOfClass:[InterestModel class]])
            {
                
           intName =   [NSString stringWithFormat:@"%@",interstModel.interest_name];
           inteId =   [NSString stringWithFormat:@"%@",interstModel.interest_id];
        }
            IntNameLbl= (UILabel *)[cell viewWithTag:102];
            if(intName != (id)[NSNull null])
                IntNameLbl.text=[intName stringByDecodingHTMLEntities];
            else
                IntNameLbl.text=@" ";
        }
    }
    return cell;
}

#pragma mark - add Button Action
-(IBAction)addBtn:(id)sender{
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
    if ((self.addIntTF.text.length==0) || [self.addIntTF.text isEqualToString:@""])
    {
        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please select from below to edit." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
        [alt show];
    }
    else if ([self.addIntTF.text isEqualToString:[interestName  stringByDecodingHTMLEntities]])
    {
        [self.navigationController popViewControllerAnimated:YES];
//        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"" message:@"Please change something to interest update." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
//        [alt show];
    }
    else {
      
        [self setInterestRequest:self.addIntTF.text interestbyId:interestId1];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        InterestModel *interstModel = [self.editIntListArray objectAtIndex:indexPath.row];
        if(interstModel && [interstModel isKindOfClass:[InterestModel class]])
        {
            NSString* interestId =   [NSString stringWithFormat:@"%@",interstModel.interest_id];
            //Update like status.. Check Network connection
            Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
            NetworkStatus internetStatus = [r currentReachabilityStatus];
            if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            [self setremoveInterestRequest:interestId];
            [self.editIntListArray removeObjectAtIndex:indexPath.row];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self.editIntTV reloadData];
    }
}

#pragma mark - update interest api calling
-(void)setInterestRequest:(NSString *)InterstTitle interestbyId:(NSString *)InterestId{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetInterestRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] interest_id:InterestId interest_name:InterstTitle format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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

#pragma mark - Remove interest api calling
-(void)setremoveInterestRequest:(NSString *)InterestId{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetRemoveInterestRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] interest_id:InterestId  format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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

#pragma mark - addButton Action
-(IBAction)AddBtnClick:(UIButton*)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:self.editIntTV];
    indexPath = [self.editIntTV indexPathForRowAtPoint: currentTouchPosition];
    InterestModel *interstModel = [self.editIntListArray objectAtIndex:indexPath.row];
    if(interstModel && [interstModel isKindOfClass:[InterestModel class]])
    {
        interestId1  =   [NSString stringWithFormat:@"%@",interstModel.interest_id];
        interestName =   [NSString stringWithFormat:@"%@",interstModel.interest_name];
    }
    if (indexPath != nil)
    {
        curentindex =indexPath.row;
        self.addIntTF.text = [interestName  stringByDecodingHTMLEntities];
        self.addIntTF.userInteractionEnabled = YES;
    }
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
