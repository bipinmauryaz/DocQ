//
//  QBServiceManager.m
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ServicesManager.h"
#import "_CDMessage.h"
#import "QMMessageNotificationManager.h"
#import "AppDelegate.h"
@interface ServicesManager ()

@property (nonatomic, strong) QMContactListService* contactListService;

@end

@implementation ServicesManager

- (NSArray *)unsortedUsers
{
    return [self.usersService.usersMemoryStorage unsortedUsers];
}

- (instancetype)init {
	self = [super init];
    
	if (self) {
        _notificationService = [[NotificationService alloc] init];
        [QMMessageNotificationManager oneByOneModeSetEnabled:NO];
    }
    
	return self;
}

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
  //  NSLog(@"showNotificationForMessage for dialog = %@ and message = %@",dialogID, message);
    if ([self.currentDialogID isEqualToString:dialogID]){
        if([QBSession currentSession].currentUser.ID == message.senderID){
            return;
        }else{
            [self updateChatDialog:dialogID withMessage:message];
            return;
        }
    }
    
    if (message.senderID == self.currentUser.ID) return;
    
    NSString* dialogName = NSLocalizedString(@"SA_STR_NEW_MESSAGE", nil);
    
    QBChatDialog* dialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
 //   NSLog(@"Dialog = %@",dialog);
 //   NSLog(@"message = %@",message);
    if (dialog.type != QBChatDialogTypePrivate) {
        dialogName = dialog.name;
    } else {
        QBUUser* user = [self.usersService.usersMemoryStorage userWithID:dialog.recipientID];
        if (user != nil) {
            dialogName = user.login;
        }
    }
    dialogName = dialog.name;
    NSString * title = dialogName;
    NSString *subtitle = message.text;
   
    NSInteger chatid = dialog.userID;
    if (dialogID != nil) {
        
        if(![[AppDelegate appDelegate] checkTableInDialog:dialogID withRecpID:[NSString stringWithFormat:@"%ld",(long)chatid]]){
            [[AppDelegate appDelegate] getDialogById:dialogID];
        }else{
            
            if(title == nil)
            {
                title = [self getDialogNameFromDB:[NSString stringWithFormat:@"%@",self.lastMsgUID]];
                self.recpName = title;
            }
            [self updateChatDialog:dialog lastMsgTS:message.customParameters[@"date_sent"]];
            
        }
    }
    
    
    if(title == nil){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"DialogInserted" object:nil];
        self.lastMsgUID = [NSString stringWithFormat:@"%lu",(unsigned long)dialog.lastMessageUserID];
        self.lastMsg = subtitle;
    }else{
        [QMMessageNotificationManager showNotificationWithTitle:title
                                                       subtitle:subtitle
                                                           type:QMMessageNotificationTypeInfo];
    }
}

-(void) receiveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"DialogInserted"])
    {
        
        NSString* title = [self getDialogNameFromDB:[NSString stringWithFormat:@"%@",self.lastMsgUID]];
    //    NSLog(@"Fetched title = %@",title);
        [QMMessageNotificationManager showNotificationWithTitle:title
                                                   subtitle:self.lastMsg
                                                       type:QMMessageNotificationTypeInfo];
    
    }
}


- (void)handleErrorResponse:(QBResponse *)response {
    
    [super handleErrorResponse:response];
    
	if (![self isAuthorized]){
		return;
	}
	
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	if( response.status == 502 ) { // bad gateway, server error
		errorMessage = NSLocalizedString(@"SA_STR_BAD_GATEWAY", nil);
	}
	else if( response.status == 0 ) { // bad gateway, server error
		errorMessage = NSLocalizedString(@"SA_STR_NETWORK_ERROR", nil);
	}
    
    NSString * title  = NSLocalizedString(@"SA_STR_ERROR", nil);
    NSString * subtitle = errorMessage;

//    [QMMessageNotificationManager showNotificationWithTitle:title
//                                                   subtitle:subtitle
//                                                       type:QMMessageNotificationTypeWarning];
}

- (void)downloadCurrentEnvironmentUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak __typeof(self)weakSelf = self;
    [[self.usersService searchUsersWithTags:@[[self currentEnvironment]]] continueWithBlock:^id(BFTask *task) {
        //
        if (task.error != nil) {
            if (errorBlock) {
                errorBlock(task.error);
            }
        }
        else {
            
            if (successBlock != nil) {
                successBlock([weakSelf sortedUsers]);
            }
        }
        
        return nil;
    }];
}

- (NSArray *)sortedUsers {
    
    NSArray *users = [self.usersService.usersMemoryStorage unsortedUsers];
    
    NSMutableArray *mutableUsers = [users mutableCopy];
    [mutableUsers sortUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
        return [obj1.login compare:obj2.login options:NSNumericSearch];
    }];
    
    return [mutableUsers copy];
}

#pragma mark - Helpers
//
//- (NSString *)currentEnvironment {
//    NSString* environment = nil;
//#if DEV
//    environment = @"dev";
//#endif
//    
//#if QA
//    environment = @"qbqa";
//#endif
//    
//    return environment;
//}


- (NSString *)currentEnvironment {
    NSString* environment = nil;
#if DEV
    environment = @"docquitydev";
#endif
    
#if QA
    environment = @"qbqa";
#endif
    environment = @"docquitydev";
    return environment;
}

#pragma mark - Last activity date
- (void)setLastActivityDate:(NSDate *)lastActivityDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastActivityDate forKey:kLastActivityDateKey];
    [defaults synchronize];
}

- (NSDate *)lastActivityDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastActivityDateKey];
}

#pragma mark QMChatServiceCache delegate
- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [super chatService:chatService didAddMessageToMemoryStorage:message forDialogID:dialogID];
    
    if (self.authService.isAuthorized) {
        [self showNotificationForMessage:message inDialogID:dialogID];
    }
}

-(void)updateChatDialog:(NSString*)dialogid withMessage:(QBChatMessage*)message{
    if([message.text isEqualToString:@"d0cq1ty*#@block*U"] || [message.text isEqualToString:@"d0cq1ty*#@unblock*U"]){
        return;
    }
    NSString *dialogLMsg          =   message.text;
    NSString *dialogLMsgDate      =   message.customParameters[@"date_sent"] ;
    NSString *dialogLMsgUid       =   [NSString stringWithFormat:@"%lu",(unsigned long)message.senderID];
    NSString *dialogUnreadCount   =   @"0";
    dialogLMsg = [dialogLMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"'"];
    dialogLMsg = [[dialogLMsg componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"''"];
    // create database
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    
    NSString *dialogupdateQuery= [NSString stringWithFormat:@"UPDATE qbChatDialog SET last_message = '%@',last_message_date_sent = '%@',unread_messages_count = '%@', last_message_user_id = '%@' WHERE dialogID = '%@'",dialogLMsg?dialogLMsg:@"",dialogLMsgDate?dialogLMsgDate:@"",dialogUnreadCount?dialogUnreadCount:@"",dialogLMsgUid?dialogLMsgUid:@"",dialogid];
//    NSLog(@"dialogupdateQuery in service manager if same dialog");
    [self.dbManager executeQuery:dialogupdateQuery];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatDialogTableupdate" object:self];
    
}

-(void)updateChatDialog:(QBChatDialog*)dialog lastMsgTS:(NSString *)msgTS{
    if([dialog.lastMessageText isEqualToString:@"d0cq1ty*#@block*U"] || [dialog.lastMessageText isEqualToString:@"d0cq1ty*#@unblock*U"]){
        return;
    }
    NSString *oppName             =   dialog.name;
    if(dialog.name == nil){
       // NSLog(@"dialog.name  nil");
        oppName = self.recpName;
    }
    NSString *dialogid            =   dialog.ID;
    NSString *dialogLMsg          =   dialog.lastMessageText;
    NSString *dialogLMsgDate      =   msgTS;
    NSString *dialogLMsgUid       =   [NSString stringWithFormat:@"%lu",(unsigned long)dialog.lastMessageUserID];
    NSString *dialogUnreadCount   =   [NSString stringWithFormat:@"%lu",(unsigned long)dialog.unreadMessagesCount];
    dialogLMsg = [dialogLMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"'"];
    dialogLMsg = [[dialogLMsg componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"''"];
    // create database
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];

    NSString *dialogupdateQuery= [NSString stringWithFormat:@"UPDATE qbChatDialog SET name = '%@',last_message = '%@',last_message_date_sent = '%@',unread_messages_count = '%@', last_message_user_id = '%@' WHERE dialogID = '%@'",oppName?oppName:@"",dialogLMsg?dialogLMsg:@"",dialogLMsgDate?dialogLMsgDate:@"",dialogUnreadCount?dialogUnreadCount:@"",dialogLMsgUid?dialogLMsgUid:@"",dialogid];
 //   NSLog(@"dialogupdateQuery in service manager");
    [self.dbManager executeQuery:dialogupdateQuery];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatDialogTableupdate" object:self];
    
}

-(NSString*)getDialogNameFromDB:(NSString *)chatID{
 //   NSLog(@"getDialogNameFromDB for chatID = %@",chatID);
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *fetchQuery= [NSString stringWithFormat:@"SELECT profile_pic_path,full_name FROM qbUser WHERE qid = '%@'",chatID];
    
    // Get the results.
    if (self.dialogInfo != nil) {
        self.dialogInfo = nil;
    }
    self.dialogInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:fetchQuery]];
 //   NSLog(@"dialog name in getDialogNameFromDB %@", self.dialogInfo);
    if(self.dialogInfo.count == 0)
    {
        return nil;
    }
    NSInteger indexOfFName        =   [self.dbManager.arrColumnNames indexOfObject:@"full_name"];
    //NSInteger indexOfPic          =   0;
    return [[self.dialogInfo objectAtIndex:0] objectAtIndex:indexOfFName];
}


@end
