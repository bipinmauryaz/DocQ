//
//  UserSearchViewController.m
//  Docquity
//
//  Created by Docquity-iOS on 16/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "UserSearchViewController.h"
#import "SearchUserCell.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "DocquityServerEngine.h"
#import "ServicesManager.h"
#import "SVPullToRefresh.h"
#import "ChatViewController.h"
#import "NewProfileVC.h"
#import "DocquityServerEngine.h"
#import "PermissionCheckYourSelfVC.h"
#import "NSString+HTML.h"
#import "UserTimelineVC.h"
@interface UserSearchViewController ()
<UITableViewDelegate,
UITableViewDataSource
>
{
    NSString*selectedFCustid;
    int pageCount; //page number/number of cells visble to user now
}
@property (strong, nonatomic) NSArray *userList;
@end

@implementation UserSearchViewController
@synthesize selectedFCustid,selectedFStatus;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userList = [[NSArray alloc]init];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    pageCount = 1; //initial state of page
    __weak UserSearchViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf getsearchData];
        }position:SVPullToRefreshPositionBottom];
    [self getsearchData];
    self.tableView.tableFooterView = self.spinner;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    UIColor *thColor = kThemeColor;
    self.navigationController.navigationBar.barTintColor = thColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = self.keyword;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],NSForegroundColorAttributeName, nil]];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userList.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *UserCellIdentifier = @"SingleUserCell";
    SearchUserCell *u_cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    u_cell.HeightConstraintAssociation.constant = 17.5;
    u_cell.HeightConstraintSpeciality.constant = 14.5;
    u_cell.HeightConstraintCountry.constant = 14.5;
    NSString *fullName = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"name"]?[self.userList objectAtIndex:indexPath.row][@"name"]:@""];
    u_cell.lbl_fullname.text = [self parsingHTMLText:fullName];
    
//    u_cell.lbl_fullname.text = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"name"]?[self.userList objectAtIndex:indexPath.row][@"name"]:@""];
    
    [u_cell.img_doc sd_setImageWithURL:[NSURL URLWithString:[self.userList objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
    u_cell.lbl_country.text = [self parsingHTMLText:[self.userList objectAtIndex:indexPath.row][@"country"]];
    if([[self.userList objectAtIndex:indexPath.row][@"country"] isEqualToString:@""]){
        u_cell.HeightConstraintCountry.constant = 0;
    }
    u_cell.lbl_association.text =  [self parsingHTMLText:[self.userList objectAtIndex:indexPath.row][@"institution_name"]];
    if([[self.userList objectAtIndex:indexPath.row][@"institution_name"] isEqualToString:@""]){
        u_cell.HeightConstraintAssociation.constant = 0;
    }
    NSString *spcName = [self.userList objectAtIndex:indexPath.row][@"speciality_name"];
    if([spcName isKindOfClass:[NSNull class]]){
        spcName = @"";
        u_cell.HeightConstraintSpeciality.constant = 0;
    }
    u_cell.lbl_specialtity.text = [self parsingHTMLText:spcName];
    u_cell.img_doc.contentMode = UIViewContentModeScaleAspectFill;
    u_cell.img_doc.layer.masksToBounds = YES;
    u_cell.img_doc.layer.cornerRadius = 4.0;
    u_cell.img_doc.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    u_cell.img_doc.layer.borderWidth = 0.5;
    return u_cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fullName = @"";
    NSString *loginid = @"";
    NSUInteger chatID = 0;
    QBUUser *User = [QBUUser new];

//  fullName = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"name"]?[self.userList objectAtIndex:indexPath.row][@"name"]:@""];
//    
    fullName = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"name"]?[self.userList objectAtIndex:indexPath.row][@"name"]:@""];
    
    NSString *cid = [self.userList objectAtIndex:indexPath.row][@"chat_id"];
    selectedFCustid = [self.userList objectAtIndex:indexPath.row][@"custom_id"];
    if([cid isKindOfClass:[NSNull class]]){
        cid = @"0";
    }
    chatID = cid.integerValue;
    loginid = [self.userList objectAtIndex:indexPath.row][@"jabber_id"];
    if(chatID == 0){
        UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confAl.tag = 888;
        [confAl show];
        return;
    }
     User.ID = chatID;
    User.login = loginid;
    User.fullName = fullName;
    self.selectedFStatus = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"friend_status"]];
    self.selectedFCustid = [NSString stringWithFormat:@"%@",[self.userList objectAtIndex:indexPath.row][@"custom_id"]];
    [self joinChatWithUser:User];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (alertView.tag == 888){
        if (buttonIndex == 1) {
            [self didPressoOKforNotifyUpgradeChat];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 28)];
    footerLbl.text =[NSString stringWithFormat:@"%@ \uE312",@"That's All Folks."];
    footerLbl.textColor = [UIColor lightGrayColor];
    footerLbl.font = [UIFont systemFontOfSize:14];
    footerLbl.shadowColor = [UIColor whiteColor];
    footerLbl.shadowOffset = CGSizeMake(0, 1);
    footerLbl.textAlignment = NSTextAlignmentCenter;
    footerLbl.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    footerLbl.opaque = NO;
    return footerLbl;
}

#pragma mark - get search list api calling
-(void)getsearchData{
    NSString *pagestring = [NSString stringWithFormat:@"%d", pageCount];
    NSUserDefaults *userDef =[NSUserDefaults standardUserDefaults]; //mandatory
    [[DocquityServerEngine sharedInstance]newSearchUserAPI:[userDef valueForKey:userAuthKey] device_type:kDeviceType type:self.type type_id:self.typeID offset:pagestring limit:@"10" callback:^(NSDictionary* responceObject, NSError* error) {
        // NSLog(@"responceObject = %@",responceObject);
        [self.tableView.pullToRefreshView stopAnimating];
        NSMutableDictionary *resposeDic =[responceObject objectForKey:@"posts"];
      //  NSLog(@"Response for %@ = %@",self.typeID,resposeDic);
        if ([resposeDic isKindOfClass:[NSNull class]]|| resposeDic ==nil)
        {
            // Null response
        }
        else
        {
            self.tableView.tableFooterView = nil;
            if([[resposeDic valueForKey:@"status"]integerValue] == 1){
                NSArray *temparr =  [[NSArray alloc]init];
                temparr= [resposeDic objectForKey:@"user_list"];
                self.userList = [self.userList arrayByAddingObjectsFromArray:temparr];
                pageCount++;
                [self.tableView reloadData];
            }
            else if([[resposeDic valueForKey:@"status"]integerValue] == 7){
                self.tableView.tableFooterView = nil;
               // self.tableView.tableFooterView = [self tableView:self.tableView viewForFooterInSection:0];
                [self.tableView setShowsPullToRefresh:NO];
            }
            else if([[resposeDic valueForKey:@"status"]integerValue] == 5)
            {
                [[AppDelegate appDelegate]ShowPopupScreen];
            }
            else if([[resposeDic valueForKey:@"status"]integerValue] == 9){
               // [[AppDelegate appDelegate] hideIndicator];
                [[AppDelegate appDelegate] logOut];
            }
        }
    }];
}

#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressChatBtn:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (IBAction)didPressViewProfile:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    [self viewProfileWithCustId:[self.userList objectAtIndex:indexPath.row][@"custom_id"] UserJabberId:[self.userList objectAtIndex:indexPath.row][@"jabber_id"]];
}

- (void)navigateToChatViewControllerWithDialog:(QBChatDialog *)dialog {
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

-(void)joinChatWithUser:(QBUUser*)user {
    __weak __typeof(self) weakSelf = self;
    [self createChatWithName:nil selectedUser:user completion:^(QBChatDialog *dialog) {
        __typeof(self) strongSelf = weakSelf;
        if( dialog != nil ) {
            [strongSelf navigateToChatViewControllerWithDialog:dialog];
        }
        else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
        }
    }];
}

- (void)createChatWithName:(NSString *)name selectedUser:(QBUUser*)user completion:(void(^)(QBChatDialog *dialog))completion {
    
    // Creating private chat dialog.
    [ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:user completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        if (!response.success && createdDialog == nil) {
            if (completion) {
                completion(nil);
            }
        }
        else {
            if (completion) {
                completion(createdDialog);
            }
        }
    }];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* viewController = segue.destinationViewController;
        viewController.dialog = sender;
        viewController.friendStatus = self.selectedFStatus;
        viewController.oppCustid = self.selectedFCustid;
    }
}

-(void)viewProfileWithCustId:(NSString *)custid UserJabberId:(NSString *)userJabId{
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custid;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];;
  }

-(void)didPressoOKforNotifyUpgradeChat{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetNotify_to_upgrade_for_chatWithAuthKey:[userdef objectForKey:userAuthKey] custom_id:selectedFCustid device_type:kDeviceType app_version:[userdef objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
            }
        }
    }];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
        {
            //tel is null
        }
        else {
            NSString * stusmsg =[NSString stringWithFormat:@"%@",[postDic objectForKey:@"msg"]?[postDic objectForKey:@"msg"]:@""];
            NSString * ICNumber;
            NSString * Identity;
            NSString *InviteCodeExample;
            NSString * InviteCodeTyp;
            NSString * IdentityMsg;
            NSDictionary *dataDic=[postDic objectForKey:@"data"];
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
            {
                // tel is null
            }
            else {
                permstus = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"permission"]?[dataDic objectForKey:@"permission"]:@""];
                NSDictionary *reqDic=[dataDic objectForKey:@"requirement"];
                if ([reqDic isKindOfClass:[NSNull class]]|| reqDic ==nil)
                {
                    // tel is null
                }
                else {
                    ICNumber =[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"ic_number"]?[reqDic objectForKey:@"ic_number"]:@""];
                    
                    Identity=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity"]?[reqDic objectForKey:@"identity"]:@""];
                    
                    IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    if ([IdentityMsg  isEqualToString:@""] || [IdentityMsg isEqualToString:@"<null>"]) {
                    }
                    else {
                        IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    }
                    NSDictionary *IC_reqDic=[reqDic objectForKey:@"ic_requirement"];
                    if ([IC_reqDic isKindOfClass:[NSNull class]]||IC_reqDic ==nil)
                    {
                        // tel is null
                    }
                    else {
                        InviteCodeExample =[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_example"]?[IC_reqDic objectForKey:@"invite_code_example"]:@""];
                        InviteCodeTyp=[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_type"]?[IC_reqDic objectForKey:@"invite_code_type"]:@""];
                    }
                }
            }
            if([[postDic valueForKey:@"status"]integerValue] == 1){
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:permstus?permstus:@"" forKey:user_permission];//mandatory
                [userpref synchronize];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 11){
                [self pushToVerifyAccount:stusmsg invite_codeType:InviteCodeTyp invite_code_example:InviteCodeExample ic_number:ICNumber identity:Identity identity_message:IdentityMsg];
            }
            else{
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:@"OK" autoDismissFlag:NO];
            }
        }
    }];
}


-(void)pushToVerifyAccount:(NSString*)stusmsg invite_codeType:(NSString*)InviteCodeTyp invite_code_example:(NSString*)InviteCodeExample ic_number:(NSString*)ICNumber identity:(NSString*)Identity identity_message:(NSString*)IdentityMsg{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    PermissionCheckYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"PermissionCheckYourSelfVC"];
    selfVerify.titleMsg = stusmsg;
    selfVerify.titledesc = InviteCodeTyp;
    selfVerify.tf_placeholder = InviteCodeExample;
    selfVerify.IcnumberValue = ICNumber;
    selfVerify.idetityValue = Identity;
    selfVerify.identityTypMsg = IdentityMsg;
    [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

-(NSString*)parsingHTMLText:(NSString*)text{
    text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}


@end
