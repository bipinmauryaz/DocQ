//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import <Quickblox/QBASession.h>
#import "ServicesManager.h"
#import "EditDialogTableViewController.h"
#import "ChatViewController.h"
#import "DialogTableViewCell.h"
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Localytics.h"
#import "QBSearchFriendsViewController.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
@interface DialogsViewController ()
<
QMChatServiceDelegate,
QMAuthServiceDelegate,
QMChatConnectionDelegate,
NotificationServiceDelegate
>

@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, strong) NSArray *dialogs;
@property (nonatomic, strong) NSMutableArray *dialogsAll;
@property (nonatomic, strong) NSArray *callDialogs;

@end

@implementation DialogsViewController

-(void)checkingLogin{
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    if (currentUser != nil) {
        // loggin in with previous user
        currentUser.password = [[NSUserDefaults standardUserDefaults]valueForKey:password1];
        
        NSString *userName = currentUser.login.length ? currentUser.login : @"user";
        
       // [SVProgressHUD showWithStatus:[NSLocalizedString(@"SA_STR_LOGGING_IN_AS", nil) stringByAppendingString:userName] maskType:SVProgressHUDMaskTypeClear];
        
      //  __weak __typeof(self)weakSelf = self;
        [servicesManager logInWithUser:currentUser completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
             //   __typeof(self) strongSelf = weakSelf;
                //[strongSelf registerForRemoteNotifications];
               // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
                
                if (servicesManager.notificationService.pushDialogID == nil) {
                //    [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
                }
                else {
                    [servicesManager.notificationService handlePushNotificationWithDelegate:self];
                }
                
            } else {
                //[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR", nil)];
            }
        }];
    }else{
        [self loginInQuickblox];
        [self loadDialogs];
    }

}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self getDialogs:@""];
    totalUnread = 0;
    pageOffset = 0;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    self.dialogs = [[NSArray alloc]init];
    self.callDialogs = [[NSArray alloc]init];
    self.dialogsAll = [[NSMutableArray alloc]init];
    self.btn_startConv.layer.borderColor = [UIColor grayColor].CGColor;
    [self checkingLogin];
    // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
    [[ServicesManager instance].chatService addDelegate:self];
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     if (![[QBChat instance] isConnected]) {
                                                                                        // [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_CONNECTING_TO_CHAT", nil) maskType:SVProgressHUDMaskTypeNone];
                                                                                     }
                                                                                 }];
    
    if ([ServicesManager instance].isAuthorized) {
        [self loadDialogs];
    }else{
        [self loginInQuickblox];
    }
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //NSLog(@"deviceIdentifier= %@",deviceIdentifier);
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [AppDelegate appDelegate].devTokForQB;
   // NSLog(@"[AppDelegate appDelegate].devTokForQB = %@",[AppDelegate appDelegate].devTokForQB);
    [QBRequest createSubscription:subscription successBlock:nil errorBlock:nil];
    //self.navigationItem.title = [ServicesManager instance].currentUser.login;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [Localytics tagEvent:@"Chat Tab Click"];
    [self registerNotification];
	//[self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];
    self.navigationItem.title = @"Chats";
    self.navigationController.navigationBar.barTintColor = kThemeColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    UIBarButtonItem * rightitem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushToSearchUser)];
    self.navigationItem.rightBarButtonItem = rightitem;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    
    
    
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    self.btn_startConv.layer.borderColor = [UIColor grayColor].CGColor;
    self.btn_startConv.layer.borderWidth = 1.0;
    if (currentUser != nil) {
       // NSLog(@"user not nil");
      //  [self checkingLogin];
        if ([ServicesManager instance].isAuthorized) {
            //[self loadDialogs];
            [self fetchDialogsFromTable];
        }
    }else{
       // NSLog(@"user nil");
        [self loginInQuickblox];
    }
    [self.tableview reloadData];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
   
}

-(void)pushToSearchUser{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QBStoryboard" bundle:nil];
    QBSearchFriendsViewController *searchQB = [storyboard instantiateViewControllerWithIdentifier:@"QBSearchFriendsViewController"];
    [self.navigationController pushViewController:searchQB animated:NO];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"chatDialogTableupdate" object:nil];
}


- (void) receiveNotification:(NSNotification *) notification
{
    [self fetchDialogsFromTable];
//    [self.tableview reloadData];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
   // [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOGOUTING", nil) maskType:SVProgressHUDMaskTypeClear];
    
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
      __weak __typeof(self)weakSelf = self;
    dispatch_group_notify(logoutGroup,dispatch_get_main_queue(),^{
        // logging out
        [[QMServicesManager instance] logoutWithCompletion:^{
            
            __typeof(self) strongSelf = weakSelf;
            
//            [strongSelf.tableView reloadData];
            [strongSelf.tableview reloadData];
            
            [[NSNotificationCenter defaultCenter] removeObserver:strongSelf.observerDidBecomeActive];
            strongSelf.observerDidBecomeActive = nil;
            [strongSelf performSegueWithIdentifier:@"kBackToLoginViewController" sender:nil];
            //[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
        }];
    });
}


- (void)loadDialogs {
    __weak __typeof(self) weakSelf = self;
	
    if ([ServicesManager instance].lastActivityDate != nil) {
        [[ServicesManager instance].chatService fetchDialogsUpdatedFromDate:[ServicesManager instance].lastActivityDate andPageLimit:kDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            //
//            [weakSelf.tableView reloadData];
            [weakSelf.tableview reloadData];
        } completionBlock:^(QBResponse *response) {
            //
            if ([ServicesManager instance].isAuthorized && response.success) {
                [ServicesManager instance].lastActivityDate = [NSDate date];
            }
        }];
    }
    else {
       // [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_DIALOGS", nil) maskType:SVProgressHUDMaskTypeClear];
        [[ServicesManager instance].chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
//            [weakSelf.tableView reloadData];
            [weakSelf.tableview reloadData];
        } completion:^(QBResponse *response) {
            if ([ServicesManager instance].isAuthorized) {
                if (response.success) {
                   // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
                    [ServicesManager instance].lastActivityDate = [NSDate date];
                }
                else {
                   // [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_FAILED_LOAD_DIALOGS", nil)];
                }
            }
        }];
    }
}

//- (NSArray *)dialogs {
//    // Retrieving dialogs sorted by updatedAt date from memory storage.
//    if(self.segment.selectedSegmentIndex == 1)
//        return self.dialogs;
//    else
//        return self.callDialogs;
//}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dialogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     DialogTableViewCell *cell = (DialogTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"
                                                                                    forIndexPath:indexPath];

    if (indexPath.row + 1 > self.dialogs.count) return cell;
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate: {
            if ([chatDialog.lastMessageText isEqualToString:@""]) {
                cell.lastMessageTextLabel.text = @"\U0001f4f7 photo";
            }
            else{
                cell.lastMessageTextLabel.text = [[chatDialog.lastMessageText stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            }
//            cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:chatDialog.recipientID];
//            cell.dialogNameLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
            cell.dialogNameLabel.text = [[chatDialog.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            [cell.dialogImageView sd_setImageWithURL:[NSURL URLWithString:chatDialog.photo]
                                    placeholderImage:[UIImage imageNamed:@"chatRoomIcon"]
                                             options:SDWebImageRefreshCached];
            //set cell Image View Radius corner
            cell.dialogImageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.dialogImageView.layer.cornerRadius = cell.dialogImageView.frame.size.width / 2;
            cell.dialogImageView.clipsToBounds = YES;
         
            //cell.unreadCountLabel.text = chatDialog.unreadMessagesCount;
         }
            break;
        case QBChatDialogTypeGroup: {
            cell.lastMessageTextLabel.text = [[chatDialog.lastMessageText stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            cell.dialogNameLabel.text = [[chatDialog.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            cell.dialogImageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup: {
            cell.lastMessageTextLabel.text = [[chatDialog.lastMessageText stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            cell.dialogNameLabel.text = [[chatDialog.name stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            cell.dialogImageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
            
        default:
            break;
    }
    
    BOOL hasUnreadMessages = chatDialog.unreadMessagesCount > 0;
    cell.unreadContainerView.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString *unreadText = nil;
        if (chatDialog.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        }
        cell.unreadCountLabel.text = unreadText;
    } else {
        cell.unreadCountLabel.text = nil;
    }
	
    return cell;
}

- (void)deleteDialogWithID:(NSString *)dialogID {
	__weak __typeof(self) weakSelf = self;
    // Deleting dialog from Quickblox and cache.
	[ServicesManager.instance.chatService deleteDialogWithID:dialogID
                                                  completion:^(QBResponse *response) {
														if (response.success) {
															__typeof(self) strongSelf = weakSelf;
//															[strongSelf.tableView reloadData];
                                                            [strongSelf.tableview reloadData];
															[SVProgressHUD dismiss];
														} else {
															//[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR_DELETING", nil)];
															NSLog(@"can not delete dialog: %@", response.error);
														}
                                                    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = self.dialogs[indexPath.row];
    selectedFStatus = [self fetchConnectionForRecipient:[NSString stringWithFormat:@"%@",dialog.ID]];
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.friendStatus = selectedFStatus;
        chatViewController.dialog = sender;
    }
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	
	QBChatDialog *chatDialog = self.dialogs[indexPath.row];
	
	// remove current user from occupants
	NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
	for (NSNumber *identifier in chatDialog.occupantIDs) {
		if (![identifier isEqualToNumber:@(ServicesManager.instance.currentUser.ID)]) {
			[occupantsWithoutCurrentUser addObject:identifier];
		}
	}
	chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_DELETING", nil) maskType:SVProgressHUDMaskTypeClear];
	
	if (chatDialog.type == QBChatDialogTypeGroup) {
		NSString *notificationText = [NSString stringWithFormat:@"%@ %@", [ServicesManager instance].currentUser.login, NSLocalizedString(@"SA_STR_USER_HAS_LEFT", nil)];
		__weak __typeof(self) weakSelf = self;
		
		// Notifying user about updated dialog - user left it.
		[[ServicesManager instance].chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:notificationText completion:^(NSError  *error) {
			[weakSelf deleteDialogWithID:chatDialog.ID];
		}];
	}
	else {
		[self deleteDialogWithID:chatDialog.ID];
		
	}
}
*/
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"SA_STR_DELETE", nil);
}

#pragma mark -
#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
//	[self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
	//[self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
//	[self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray *)dialogs {
//    [self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
//	[self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
//    [self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
//    [self.tableView reloadData];
    [self.tableview reloadData];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
//    [self.tableView reloadData];
    [self.tableview reloadData];
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
   // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_CONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
   // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_RECONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService {
   // [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_DISCONNECTED", nil)];
}

- (void)chatService:(QMChatService *)chatService chatDidNotConnectWithError:(NSError *)error {
   // [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_DID_NOT_CONNECT_ERROR", nil), [error localizedDescription]]];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error {
    //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_FAILED_TO_CONNECT_WITH_ERROR", nil), [error localizedDescription]]];
}

#pragma mark - NotificationServiceDelegate protocol
- (void)notificationServiceDidStartLoadingDialogFromServer {
  //  [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_DIALOG", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)notificationServiceDidFinishLoadingDialogFromServer {
    [SVProgressHUD dismiss];
}

- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    DialogsViewController *dialogsController = (DialogsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    ChatViewController *chatController = (ChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.dialog = chatDialog;
    
    NSMutableArray * viewControllers = self.navigationController.viewControllers.mutableCopy;
    [viewControllers addObjectsFromArray:@[dialogsController,chatController]];
    self.navigationController.viewControllers = viewControllers;
 }
- (void)notificationServiceDidFailFetchingDialog {
    // TODO: maybe segue class should be ReplaceSegue?
    [self performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
}

-(void)loginInQuickblox{
   // NSLog(@"loginInQuickblox");
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    QBUUser *selectedUser = [QBUUser new];
    selectedUser.login = [userdef valueForKey:kjabberName];
    selectedUser.password = [userdef valueForKey:password1];
  //  NSLog(@"%@ - %@",[userdef valueForKey:kjabberName],[userdef valueForKey:password1]);
    // __weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
          //  NSLog(@"loginInQuickblox sucess");
            // __typeof(self) strongSelf = weakSelf;
            
           // [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            // [strongSelf registerForRemoteNotifications];
            //[strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
           // NSLog(@"Succss login in quikblox");
           
        } else {
        //    NSLog(@"loginInQuickblox error = %@",errorMessage);
           // [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}
- (IBAction)didChangeState:(UISegmentedControl*)sender {
    if(sender.selectedSegmentIndex == 0){
        self.dialogs = self.callDialogs;
    }else{
        self.dialogs = [self.dialogsAll copy];
    }
    [self.tableview reloadData];
    if(self.dialogs.count == 0){
        self.view_noConversation.hidden = false;
    }else{
        self.view_noConversation.hidden = true;
    }
}

-(void)getDialogs:(NSString *)DOU{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getChatDialogueWithAuthKey:[userdef valueForKey:userAuthKey] lang:kLanguage app_version:[userdef valueForKey:kAppVersion] offset:@"1" limit:@"100" DOUpdate:DOU callback:^(NSMutableDictionary *responceObject, NSError *error) {
        if(error){
            [self fetchDialogsFromTable];
        }
       // NSLog(@"responceObject = %@",responceObject);
        NSInteger resStat = [[responceObject valueForKey:@"posts"][@"status"]integerValue];
        if(resStat == 1){
            NSArray *list = [responceObject valueForKey:@"posts"][@"data"][@"list"];
            if([list isKindOfClass:[NSArray class]]){
              //  NSLog(@"list = %@",[list objectAtIndex:0]);
                [self insertDialogs:list];
                if(list.count == 50){
                    pageOffset ++;
                }
            }
        }else if(resStat == 0){
            [self fetchDialogsFromTable];
        }else if(resStat == 9){
            [[AppDelegate appDelegate]logOut];
        }
    }];
}

#pragma mark - Database handling
-(void)insertDialogs:(NSArray*)dialog
{
    for(NSMutableDictionary *dic in dialog)
    {
        NSMutableArray *occID = [dic valueForKey:@"occupants_ids"];
        NSString *ocid = @"";
        for(NSString *str in occID)
        {
            if([ocid isEqualToString:@""]){
                ocid = [NSString stringWithFormat:@"%@",str];
            }else{
                ocid = [NSString stringWithFormat:@"%@,%@",ocid,str];
            }
        }
        NSMutableArray *partcipants = [dic valueForKey:@"participant"];
        if(partcipants.count == 0){
            break;
        }else
        {
            for(NSMutableDictionary *dic in partcipants)
            {
                NSString *partChatid        =   [dic valueForKey:@"chat_id"];
                NSString *partCid           =   [dic valueForKey:@"custom_id"];
                NSString *partName          =   [dic valueForKey:@"name"];
                NSString *partEmail         =   [dic valueForKey:@"email"];
                NSString *partJName         =   [dic valueForKey:@"jabber_name"];
                NSString *partMob           =   [dic valueForKey:@"mobile"];
                NSString *partCreation      =   [dic valueForKey:@"created_at"];
                NSString *partUpdate        =   [dic valueForKey:@"updated_at"];
                NSString *partLastReq       =   [dic valueForKey:@"last_request_at"];
                NSString *partTag           =   [dic valueForKey:@"user_tags"];
                NSString *partPhoto         =   [dic valueForKey:@"profile_pic_path"];
                NSString *partcity          =   [dic valueForKey:@"city"];
                NSString *partCounty        =   [dic valueForKey:@"country"];
                NSString *partInstitution   =   [dic valueForKey:@"institution_name"];
                NSString *partConnection    =   [dic valueForKey:@"connection"];
                NSString *partFMsg          =   [dic valueForKey:@"friend_status_message"];
                NSString *partSpec          =   [dic valueForKey:@"speciality_name"];
                NSString *userinsertQuery= [NSString stringWithFormat:@"INSERT INTO qbUser (qid,owner_id,full_name,email,login,phone,created_at,updated_at,last_request_at,user_tags,profile_pic_path,city,country,custom_id,user_id,institution_name,friend_status,friend_status_message,speciality_name) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",partChatid?partChatid:@"",partCid?partCid:@"",partName?partName:@"",partEmail?partEmail:@"",partJName?partJName:@"",partMob?partMob:@"",partCreation?partCreation:@"",partUpdate?partUpdate:@"",partLastReq?partLastReq:@"",partTag?partTag:@"",partPhoto?partPhoto:@"",partcity?partcity:@"",partCounty?partCounty:@"",partCid?partCid:@"",@"",partInstitution?partInstitution:@"",partConnection?partConnection:@"",partFMsg?partFMsg:@"",partSpec?partSpec:@""];
                [self.dbManager executeQuery:userinsertQuery];
                if([self.dbManager affectedRows] == 0){
                    NSString *userupdateQuery= [NSString stringWithFormat:@"UPDATE qbUser SET full_name = '%@',profile_pic_path = '%@', friend_status = '%@' WHERE login = '%@'",partName?partName:@"",partPhoto?partPhoto:@"",partConnection?partConnection:@"",partJName];
                    [self.dbManager executeQuery:userupdateQuery];
                }
             }
        
            NSString *oppName             =   [partcipants objectAtIndex:0][@"name"];
            NSString *recpid              =   [partcipants objectAtIndex:0][@"chat_id"];
            NSString *recpConnection      =   [partcipants objectAtIndex:0][@"connection"];
            NSString *dialogid            =   [dic valueForKey:@"_id"];
            NSString *dialogCreation      =   [dic valueForKey:@"created_at"];
            NSString *dialogLMsg          =   [dic valueForKey:@"last_message"];
            NSString *dialogLMsgDate      =   [dic valueForKey:@"last_message_date_sent"];
            NSString *dialogLMsgUid       =   [dic valueForKey:@"last_message_user_id"];
            NSString *dialogPhoto         =   [partcipants objectAtIndex:0][@"profile_pic_path"];
    //[dic valueForKey:@"profile_pic_path"];
            NSString *dialogType          =   [dic valueForKey:@"type"];
            NSString *dialogupdate        =   [dic valueForKey:@"update_at"];
            NSString *dialogRoomJID       =   [dic valueForKey:@"xmpp_room_jid"];
            NSString *dialogUnreadCount   =   [dic valueForKey:@"unread_messages_count"];
         
            NSString *insertQuery= [NSString stringWithFormat:@"INSERT INTO qbChatDialog (dialogID,created_at,last_message,last_message_date_sent,last_message_user_id,name,occupants_ids,photo,type,updated_at,user_id,xmpp_room_jid,unread_messages_count,isAccept,recipient_id) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",dialogid?dialogid:@"",dialogCreation?dialogCreation:@"",dialogLMsg?dialogLMsg:@"",dialogLMsgDate?dialogLMsgDate:@"",dialogLMsgUid?dialogLMsgUid:@"",oppName?oppName:@"",ocid?ocid:@"",dialogPhoto?dialogPhoto:@"",dialogType?dialogType:@"",dialogupdate?dialogupdate:@"",@"",dialogRoomJID?dialogRoomJID:@"",dialogUnreadCount?dialogUnreadCount:@"",recpConnection?recpConnection:@"",recpid];
            [self.dbManager executeQuery:insertQuery];
             if([self.dbManager affectedRows] == 0){
                NSString *dialogupdateQuery= [NSString stringWithFormat:@"UPDATE qbChatDialog SET name = '%@',photo = '%@' WHERE dialogID = '%@'",oppName?oppName:@"",dialogPhoto?dialogPhoto:@"",dialogid];
                [self.dbManager executeQuery:dialogupdateQuery];
             }
        }
    }
    
    [self fetchDialogsFromTable];
}

-(void)fetchDialogsFromTable{
    NSLog(@"fetchDialogsFromTable");
    totalUnread = 0;
    NSString *fetchQuery= [NSString stringWithFormat:@"SELECT dialogID,created_at,updated_at,last_message,last_message_date_sent,last_message_user_id,name,photo,type,xmpp_room_jid,unread_messages_count,isAccept,recipient_id FROM qbChatDialog ORDER BY last_message_date_sent DESC" ];
    
    // Get the results.
    if (self.dialogInfo != nil) {
        self.dialogInfo = nil;
    }
    self.dialogInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:fetchQuery]];
    
    NSInteger indexOfOppName        =   [self.dbManager.arrColumnNames indexOfObject:@"name"];
    NSInteger indexOfLastMsg        =   [self.dbManager.arrColumnNames indexOfObject:@"last_message"];
    NSInteger indexOfLastUID        =   [self.dbManager.arrColumnNames indexOfObject:@"last_message_user_id"];
    NSInteger indexOfLastMsgDate    =   [self.dbManager.arrColumnNames indexOfObject:@"last_message_date_sent"];
    NSInteger indexOfDialogPhoto    =   [self.dbManager.arrColumnNames indexOfObject:@"photo"];
    NSInteger indexOfDialogType     =   [self.dbManager.arrColumnNames indexOfObject:@"type"];
    NSInteger indexOfRoomJID        =   [self.dbManager.arrColumnNames indexOfObject:@"xmpp_room_jid"];
    NSInteger indexOfUnreadMsg      =   [self.dbManager.arrColumnNames indexOfObject:@"unread_messages_count"];
    NSInteger indexOfDialogAccept   =   [self.dbManager.arrColumnNames indexOfObject:@"isAccept"];
    NSInteger indexOfDialogRecpID   =   [self.dbManager.arrColumnNames indexOfObject:@"recipient_id"];
    NSInteger indexOfDialogCreate   =   [self.dbManager.arrColumnNames indexOfObject:@"created_at"];
    NSInteger indexOfDialogUpdate   =   [self.dbManager.arrColumnNames indexOfObject:@"updated_at"];

 //   NSLog(@"dialogInfo = %@",self.dialogInfo);
    [self.dialogsAll removeAllObjects];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//    NSDate *myDate = [df dateFromString: myDateAsAStringValue];
    
    for(int i = 0; i<self.dialogInfo.count; i++){
        QBChatDialog *chatDialog = [[QBChatDialog alloc]initWithDialogID:[[self.dialogInfo objectAtIndex:i] objectAtIndex:0] type:[[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogType] integerValue]];
        chatDialog.name = [[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfOppName];
        chatDialog.lastMessageText = [[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfLastMsg];
        chatDialog.lastMessageUserID = [[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfLastUID] integerValue];
        chatDialog.lastMessageDate = [[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfLastMsgDate];
        chatDialog.photo = [[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogPhoto];
        chatDialog.unreadMessagesCount = [[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfUnreadMsg] integerValue];
        chatDialog.createdAt = [df dateFromString:[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogCreate]];
        chatDialog.updatedAt = [df dateFromString:[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogUpdate]];
        NSUInteger senderid = [QBSession currentSession].currentUser.ID;
        NSUInteger recpid = [[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogRecpID] integerValue];
//        NSMutableArray  *arr = [[NSMutableArray alloc]init];
//        [arr addObject:[NSNumber numberWithInt:senderid]];
//        NSArray *occID = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%lu",(unsigned long)senderid],[NSString stringWithFormat:@"%lu",(unsigned long)recpid], nil];
        chatDialog.occupantIDs = @[@(senderid),@(recpid)];
//        chatDialog.recipientID = [[[self.dialogInfo objectAtIndex:i] objectAtIndex:indexOfDialogRecpID] integerValue];
//        chatDialog.name = [[self.dialogInfo objectAtIndex:i] objectAtIndex:0];
        totalUnread = chatDialog.unreadMessagesCount + totalUnread;
        [self.dialogsAll addObject:chatDialog];
    }
    self.dialogs = [self.dialogsAll copy];
    
    if(self.dialogs.count == 0){
        self.view_noConversation.hidden = false;
    }else{
        self.view_noConversation.hidden = true;
    }
    [self updateChatBadge:[NSString stringWithFormat:@"%ld",(long)totalUnread]];
    [self.tableview reloadData];
    
    
}

-(NSString*)fetchConnectionForRecipient:(NSString *)diaID{
    NSString *fetchQuery= [NSString stringWithFormat:@"SELECT full_name,friend_status FROM qbUser t1 INNER JOIN qbChatDialog t2 ON t1.qid = t2.recipient_id WHERE t2.dialogID = '%@'",diaID];
    
    // Get the results.
    if (self.connectionInfo != nil) {
        self.connectionInfo = nil;
    }
    self.connectionInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:fetchQuery]];
    //NSInteger indexOfFName      =   [self.dbManager.arrColumnNames indexOfObject:@"full_name"];
    NSInteger indexOfFStatus      =   [self.dbManager.arrColumnNames indexOfObject:@"friend_status"];
 
    NSString *fstatus = [NSString stringWithFormat:@"%@",[[self.connectionInfo objectAtIndex:0] objectAtIndex:indexOfFStatus]];
    return fstatus;
}
-(void)updateChatBadge:(NSString *)chat_count{
    if([chat_count isEqualToString:@"0"]){
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    }else
        [[[AppDelegate appDelegate].tabBarCtl.tabBar.items objectAtIndex:2] setBadgeValue:chat_count];

}


@end
