/*============================================================================
 PROJECT: Docquity
 FILE:    EditSkillVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 16/06/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "EditSkillVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"

/*============================================================================
 Interface:EditSkillVC
 =============================================================================*/
@interface EditSkillVC (){
    NSString*skillId1; // skill id
    long  int curentindex; //current selected index
    NSString*skillName;
}

@end
@implementation EditSkillVC
@synthesize editSkillListArray,editSkillTV,editSkillCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editSkillTV setEditing:NO];
         self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    return [self.editSkillListArray count];
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
    NSString *cellID = @"editSkillCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"EditSkillTVCell" owner:self options:nil];
        if([nib count] > 0)
        {
            cell = self.editSkillCell;
        }
    }
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *skillsName =nil;
    NSString*skillsId = nil;
    if([self.editSkillListArray count]>0)
    {
        if([self.editSkillListArray objectAtIndex:indexPath.row]){
            SpecialityModel *speclModel = [self.editSkillListArray objectAtIndex:indexPath.row];
            if(speclModel && [speclModel isKindOfClass:[SpecialityModel class]])
            {
                skillsName  =   [NSString stringWithFormat:@"%@",speclModel.speciality_name];
                skillsId=   [NSString stringWithFormat:@"%@",speclModel.speciality_id];
            }
            skillNameLbl= (UILabel *)[cell viewWithTag:102];
            if(skillsName != (id)[NSNull null])
                skillNameLbl.text= [skillsName stringByDecodingHTMLEntities];
            else
                skillNameLbl.text=@" ";
        }
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //DLog(@"textFieldShouldReturn called");
    [textField resignFirstResponder];
    return YES;
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if([self.editSkillListArray objectAtIndex:indexPath.row]){
            SpecialityModel *speclModel = [self.editSkillListArray objectAtIndex:indexPath.row];
            if(speclModel && [speclModel isKindOfClass:[SpecialityModel class]])
            {
                skillId1=   [NSString stringWithFormat:@"%@",speclModel.speciality_id];
                //Update like status.. Check Network connection
                Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
                NetworkStatus internetStatus = [r currentReachabilityStatus];
                if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                [self setremoveSpecialityRequest:skillId1];
                [self.editSkillListArray removeObjectAtIndex:indexPath.row];
            }
        }
    }
      else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self.editSkillTV reloadData];
    }
}

#pragma mark - set remove speciality api calling
-(void)setremoveSpecialityRequest:(NSString *)specialityId{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetRemoveSpecialityRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] speciality_id:specialityId  format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
