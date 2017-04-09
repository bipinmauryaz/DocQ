/*============================================================================
 PROJECT: Docquity
 FILE:    AppDelegate.m
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/09/15.
 =============================================================================*/

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

//Add Localytics
#define Localytics_productionTOKEN @"a04cc771ffe7ebf72a97ac5-d56e0f92-c038-11e5-6098-002dea3c3994"
#define Localytics_stagingTOKEN @"99289a289f209aaf4aaffc2-f9c8fae8-2329-11e6-1784-00cef1388a40"
#define Localytics_demoTOKEN @"250ef1a4097c2a05d4d91dd3-0348db1e-2329-11e6-44a9-00adad38bc8d"

#define kTimerNameKey @"kNotifyLoginKey"
#define kName @"loginN"
/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "AppDelegate.h"
#import "UIWindow+Docquity.h"
#import "DefineAndConstants.h"
#import "SplashScreenViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "DefineAndConstants.h"
#import "Server.h"
#import "NSString+Utils.h"
#import "NewHomeVC.h"

#import <CFNetwork/CFNetwork.h>
#import "UpdateExam.h"

#import "FeedVC.h"
#import "WebVC.h"
#import "MobileVerifyVC.h"

//device details
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "NotificationView.h"

//Add Facebook SDK
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Localytics.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PopupVC.h"
#import "RFRateMe.h"
#import "DocquityServerEngine.h"
#import "PermissionCheckYourSelfVC.h"

#import "FeedVC.h"
#import "NotificationVC.h"
#import "SettingVC.h"
#import "AvailableCourseVC.h"
#import "Utils.h"

//Add Fabric Crashlytics
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

// IP Address Framework Supported
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#pragma mark - Quick Blox Dependencies Import
#import "QMServices.h"
#import "ServicesManager.h"
#import "ChatViewController.h"
#import "DialogsViewController.h"

#pragma mark - Google Analytics Dependencies Import
#import "Analytics.h"
#import "Firebase.h"
@import Firebase;
@import GoogleSignIn;



/*============================================================================
 Interface: AppDelegate
 =============================================================================*/
@interface AppDelegate ()<UIApplicationDelegate, GIDSignInDelegate,NotificationServiceDelegate>{
//@interface AppDelegate ()<NotificationServiceDelegate>{
   
    BOOL isEmpty;
    NSString*nickName;
    NSString *msg;
    NSString *from;
    NSString *grpName;
    NSString *grpPic;
    NSString *groupId;
    NSString*packtId;
    NSString*to;
    NSString *myJID;
    NotificationView *_notificationView;
    NSString *permstus;
    UpdateExam *updateExam;
}
@property (strong, nonatomic) QMMessagesMemoryStorage *messagesMemoryStorage;
@end
@implementation AppDelegate
@synthesize navigationController;
@synthesize dataPath;
@synthesize dbManager;
@synthesize remoteHostStatus;
@synthesize window;
@synthesize deviceTokenString;
@synthesize tabBarCtl;

//QB Server Details
const NSUInteger kApplicationID = qbAppid;
NSString *const kAuthKey        = qbAuthKey;
NSString *const kAuthSecret     = qbAuthSecret;
NSString *const kAccountKey     = qbAccountKey;

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return YES;
}


- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}


//- (BOOL)application:(nonnull UIApplication *)application
//            openURL:(nonnull NSURL *)url
//            options:(nonnull NSDictionary<NSString *, id> *)options {
//    return [self application:application
//                     openURL:url
//           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Handle App Invite requests
    FIRReceivedInvite *invite =
    [FIRInvites handleURL:url sourceApplication:sourceApplication annotation:annotation];
    if (invite) {
        NSString *matchType =
        (invite.matchType == FIRReceivedInviteMatchTypeWeak) ? @"Weak" : @"Strong";
        NSString *message =
        [NSString stringWithFormat:@"Deep link from %@ \nInvite ID: %@\nApp URL: %@\nMatch Type:%@",
         sourceApplication, invite.inviteId, invite.deepLink, matchType];
        
        [[[UIAlertView alloc] initWithTitle:@"Deep-link Data"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return YES;
    }
    
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // ...
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        // ...
    } else {
        // ...
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [FIRApp configure];
    
    //[GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
   // [GIDSignIn sharedInstance].delegate = self;

    //return YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // Initialize the default tracker. After initialization, [GAI sharedInstance].defaultTracker
    // returns this same tracker.
    
    /*
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release

    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"App launch"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    */

    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [userdef setObject:currentVersion forKey:kAppVersion]; //App version
    updateExam = [[UpdateExam alloc] init];
   // [Fabric with:@[[Crashlytics class]]];
    [self createDirectory:@"Media"];
    self.ActivityArray = [[NSMutableArray alloc]init];
    
#pragma mark - QB Settings
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    
    // enabling carbons for chat
    [QBSettings setCarbonsEnabled:YES];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelNothing];
    
    //Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    [ServicesManager enableLogging:NO];
    // app was launched from push notification, handling it
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        ServicesManager.instance.notificationService.pushDialogID = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][kPushNotificationDialogIdentifierKey];
    }

#pragma mark - Localytics Integration
    // Add Localytic token key
    [Localytics autoIntegrate:Localytics_TOKEN launchOptions:launchOptions]; // Localytics Implement
    [Localytics tagEvent:@"App opened"];
    // create database
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    
#pragma mark - Reachability Check
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    remoteHostStatus = [reachability currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    if(remoteHostStatus == NotReachable) {
        _isInternet = false;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        _isInternet = true;
        // NSLog(@"Connected via wifi");
        [self handleDataDetection:@"Wifi"];
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        _isInternet = true;
        [self getNetworkReport];
    }
    if(_isInternet){
        [updateExam submitExam];
    }
    
    // Handle launching from a notification -- Set Notification  // iOS 9 Notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    //call here method
    [self applicationDocumentsDirectory];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [userdef setObject:deviceId?deviceId:@"" forKey:DeviceID];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *xib = nil;
    xib = @"SplashScreenViewController";
    self.viewController = [[SplashScreenViewController alloc]initWithNibName:xib bundle:nil];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:self.viewController];
    
    self.navigationController=nav;
    [self.window addSubview:self.navigationController.view];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    // Setup the view controllers
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
  
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [RFRateMe showRateAlertAfterTimesOpened:100];
    [userdef setObject:[self getIPAddress:YES] forKey:ip_address1];
//    NSLog(@"my app version old = %@",[[NSUserDefaults standardUserDefaults]valueForKey:myAppVersion]);
//    NSLog(@"my app version new = %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]);
    if(![self isFirstLaunchInCurrentVersion]){
        //query the records you want to add , if records not exist, then insert them
//         NSLog(@"YES, Run first time in this version. Thanks");
        
        NSString* requiredVersion = @"1.5.4";
        NSString* oldVersion =  [[NSUserDefaults standardUserDefaults]valueForKey:myAppVersion];
        if ([requiredVersion compare:oldVersion options:NSNumericSearch] == NSOrderedDescending) {
            // NSLog(@"oldVersion is lower than the requiredVersion");
             if([userdef valueForKey:userAuthKey]){
                // NSLog(@"user is updating apps");
                [self deleteDuplicateEntry];
                [self createTableForCME];
            }
        }
        [self createTableForCME];
        [self createTableForChat];
        [self setCurrentVersionLaunched:YES];
    }else{
//        NSLog(@"NO, Run first time in this version. Thanks");
    }
     return YES;
}

- (BOOL)isFirstLaunchInCurrentVersion{
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    return  [[NSUserDefaults standardUserDefaults] boolForKey:currentVersion];
}

- (void)setCurrentVersionLaunched:(BOOL)isFirstLaunched{
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:myAppVersion];
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLaunched forKey:currentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)deleteDuplicateEntry{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *deleteQuery= [NSString stringWithFormat:@"DELETE FROM contacts WHERE type IS NULL"];
    [self.dbManager executeQuery:deleteQuery];
    NSString *uniqueQuery= [NSString stringWithFormat:@"CREATE UNIQUE INDEX username ON contacts(username)"];
    [self.dbManager executeQuery:uniqueQuery];
}

-(void)createTableForCME{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *createAssociation = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"association\" (\"_id\" INTEGER PRIMARY KEY ,\"association_id\" TEXT,\"association_name\" TEXT, \"association_pic\" TEXT,unique(association_id))"];
    
    [self.dbManager executeQuery:createAssociation];
    NSString *createCmeLesson = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"cme_lesson\" (\"_id\" INTEGER PRIMARY KEY ,\"lesson_id\" TEXT,\"lesson_code\" TEXT,\"lesson_name\" TEXT,\"lesson_summary\" TEXT,\"file_type\" TEXT,\"file_url\" TEXT,\"date_of_creation\" TEXT DEFAULT (null) ,\"lesson_description\" TEXT,\"posted_by\" TEXT,\"topic_id\" TEXT,\"course_id\" TEXT,\"total_points\" TEXT DEFAULT (null) ,\"resource_url\" TEXT,\"isDownload\" INTEGER DEFAULT (0) ,\"isSubmit\" INTEGER DEFAULT (0) ,\"isApiSync\" INTEGER DEFAULT (0) ,\"specialities_Ids\" TEXT,\"association_name\" TEXT,\"expiry_date\" TEXT DEFAULT (null) ,\"subcription\" TEXT,\"course_code\" TEXT,\"date_of_submission\" TEXT,\"remarks\" TEXT,\"resouce_file_name\" TEXT,\"document_name\" TEXT,\"thumbnail\" TEXT,\"association\" TEXT,\"accreditation\" TEXT,\"exam_association\" TEXT,\"pdf_result_url\" TEXT,\"total_user\" TEXT DEFAULT (0) ,\"association_pic\" TEXT,\"accreditation_url\" TEXT,unique (lesson_id))"];
    
    [self.dbManager executeQuery:createCmeLesson];
    NSString *createCMEQuestion = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"cme_questions\" (\"question_id\" TEXT,\"lesson_id\" TEXT,\"question\" TEXT,\"question_type\" TEXT,\"answer_type\" TEXT,\"file_type\" TEXT,\"file_url\" TEXT DEFAULT (null) ,\"lesson_description\" TEXT,\"points\" TEXT,\"date_of_creation\" TEXT DEFAULT (null) ,\"status\" INTEGER,\"resource_url\" TEXT,\"isDownload\" INTEGER DEFAULT (0) , PRIMARY KEY (question_id,lesson_id))"];
    
    [self.dbManager executeQuery:createCMEQuestion];
    NSString *createQueAns = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"cme_questions_answer\" (\"question_id\" TEXT,\"option\" TEXT,\"answer\" TEXT, \"isDownload\" INTEGER DEFAULT 0, \"option_id\" TEXT, \"isSelected\" TEXT, PRIMARY KEY (question_id, option_id))"];
    
    [self.dbManager executeQuery:createQueAns];
    NSString *createSpeciality = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"speciality\" (\"_id\" INTEGER PRIMARY KEY ,\"speciality_id\" TEXT,\"speciality_name\" TEXT,unique(speciality_id))"];
     [self.dbManager executeQuery:createSpeciality];
}

-(void)createTableForChat{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *createChatDialog = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"qbChatDialog\" (\"dialogID\" TEXT UNIQUE  DEFAULT 0 ,\"created_at\" TEXT,\"last_message\" TEXT,\"last_message_date_sent\" TEXT,\"last_message_user_id\" TEXT,\"name\" TEXT,\"occupants_ids\" TEXT,\"photo\" TEXT,\"type\" TEXT,\"updated_at\" TEXT,\"user_id\" TEXT,\"xmpp_room_jid\" TEXT,\"unread_messages_count\" TEXT,\"isAccept\" TEXT,\"recipient_id\" TEXT,\"status\" TEXT NOT NULL  DEFAULT 1)"];
    
    [self.dbManager executeQuery:createChatDialog];
    NSString *createQbUser = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"qbUser\" (\"qid\"  TEXT NOT NULL  DEFAULT 0, \"owner_id\" TEXT, \"full_name\" TEXT, \"email\" TEXT, \"login\" TEXT UNIQUE, \"phone\" TEXT, \"created_at\" TEXT, \"updated_at\" TEXT, \"last_request_at\" TEXT, \"user_tags\" TEXT, \"profile_pic_path\" TEXT, \"city\" TEXT, \"country\" TEXT, \"custom_id\" TEXT, \"user_id\" TEXT, \"institution_name\" TEXT, \"friend_status\" TEXT, \"friend_status_message\" TEXT, \"speciality_name\" TEXT , \"status\" TEXT NOT NULL  DEFAULT 1)"];
    
    [self.dbManager executeQuery:createQbUser];
    NSString *createQbChat = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"qbChat\" (\"qid\" TEXT UNIQUE  DEFAULT 0, \"attachments_url\" TEXT, \"attachments_local_uri\" TEXT, \"attachments_type\" TEXT, \"attachments_id\" TEXT, \"chat_dialog_id\" TEXT, \"created_at\" TEXT, \"date_sent\" TEXT, \"delivered_ids\" TEXT, \"message\" TEXT, \"read_ids\" TEXT, \"recipient_id\" TEXT, \"sender_id\" TEXT, \"updated_at\" TEXT, \"read\" TEXT, \"status\" TEXT NOT NULL  DEFAULT 1)"];
    [self.dbManager executeQuery:createQbChat];
    [self updatechatCredentialToQuickblox];
}

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    // NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

- (void)showAlert:(NSString*)pushmessage withTitle:(NSString*)title
{
    
}

- (NSURL *)applicationDocumentsDirectory
{
//    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory     inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)isAppAlreadyLaunchedOnce {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAppAlreadyLaunchedOnce"])
    {
        return true;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAppAlreadyLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return false;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [ServicesManager.instance.chatService disconnectWithCompletionBlock:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*   if(![[NSUserDefaults standardUserDefaults]valueForKey:signInnormal])
     {
     // NSLog(@"applicationDidEnterBackground");
     
     UIApplication *app = [UIApplication sharedApplication];
     NSArray *eventArray = [app scheduledLocalNotifications];
     for (int i=0; i<[eventArray count]; i++)
     {
     UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
     NSDictionary *userInfoCurrent = oneEvent.userInfo;
     NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:kTimerNameKey]];
     if ([uid isEqualToString:kName])
     {
     //Cancelling local notification
     [app cancelLocalNotification:oneEvent];
     break;
     }
     }
     //create new uiBackgroundTask
     __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
     [app endBackgroundTask:bgTask];
     bgTask = UIBackgroundTaskInvalid;
     }];
     
     //and create new timer with async call:
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     //run function methodRunAfterBackground
     // NSLog(@"applicationDidEnterBackground dispatch_async");
     NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(methodGetNotification) userInfo:nil repeats:NO];
     [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
     [[NSRunLoop currentRunLoop] run];
     });
     
     }else{
     [self cancelLoginN];
     }*/
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.devTokForQB = deviceToken;
    deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    //NSLog(@"Did Register for Remote Notifications with Device Token DATA (%@) \n STRING token (%@)", deviceToken,deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokenString forKey:kDeviceTokenKey];
    if([[NSUserDefaults standardUserDefaults] valueForKey:signInnormal] && deviceTokenString.length>0){
        [self updateDeviceTokenToServer];
    }
    //If Same token received again dont take any action else save in NSUserdefaults or system and send to server to register against this device to send push notification on the token specified here.
    //    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //    // subscribing for push notifications
    //    QBMSubscription *subscription = [QBMSubscription subscription];
    //    subscription.notificationChannel = QBMNotificationChannelAPNS;
    //    subscription.deviceUDID = deviceIdentifier;
    //    subscription.deviceToken = deviceToken;
    //
    //    [QBRequest createSubscription:subscription successBlock:nil errorBlock:nil];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
#if TARGET_IPHONE_SIMULATOR
    deviceTokenString = @"iOS Simulator";
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokenString forKey:kDeviceTokenKey];
#endif
    // NSLog(@"APN device token: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString*appUpgrade  =   userInfo[@"aps"][@"identifier"];
    NSString*cmetapOpen  =   userInfo[@"aps"][@"identifier"];
    NSString*targetLessonId  =     userInfo[@"aps"][@"target"];
    NSString *userPermissionTyp    =   userInfo[@"aps"][@"identifier"];
    NSString *notify_type = userInfo[@"aps"][@"identifier"];
    NSString *feedIdentifier = userInfo[@"aps"][@"identifier"];
    NSString *senderId = userInfo[@"aps"][@"sender_jabber_id"];
    NSString *sendername =  userInfo[@"aps"][@"sender_name"];
    
   // NSString*targetId = userInfo[@"target"];
    NSString *message = @"";
    if([userInfo[@"aps"][@"alert"] isKindOfClass:[NSDictionary class]]){
        message = userInfo[@"aps"][@"alert"][@"body"];
    }
    NSString*grpId =  userInfo[@"aps"][@"group_id"];
    NSString *feedid =  userInfo[@"aps"][@"target"];
    NSString*grpcreteword  = @"added you to the group";
  /*
    //////////START OF QB///////////
    NSString*chatIndetifier = userInfo[@"identifier"];
     if ([chatIndetifier isEqualToString:@"chat121"]) {
    NSString *dialogID = userInfo[@"target"];
    NSString *chatid = userInfo[@"user_id"];
        UIApplicationState state = [application applicationState];
        // user tapped notification while app was in background
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
    if (dialogID != nil) {
        if(![self checkTableInDialog:dialogID withRecpID:chatid]){
             [self getDialogById:dialogID];
        }
        NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
        if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
        ServicesManager.instance.notificationService.pushDialogID = dialogID;
        // calling dispatch async for push notification handling to have priority in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [ServicesManager.instance.notificationService handlePushNotificationWithDelegate:self];
        });
    }
    }
}
*/
    NSString *dialogID = userInfo[@"dialog_id"];
    if (dialogID != nil) {
        NSString *chatid = userInfo[@"user_id"];
        UIApplicationState state = [application applicationState];
     // user tapped notification while app was in background
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            if (dialogID != nil) {
                if(![self checkTableInDialog:dialogID withRecpID:chatid]){
                    [self getDialogById:dialogID];
                }
                NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
                if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
                ServicesManager.instance.notificationService.pushDialogID = dialogID;
                // calling dispatch async for push notification handling to have priority in main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ServicesManager.instance.notificationService handlePushNotificationWithDelegate:self];
                });
            }
        }
    }
    //////////END OF QB///////////
    /////////EARLIER//////////////
    if ([message rangeOfString:grpcreteword].location != NSNotFound){
        if (grpId>0) {
            NSInteger grpID = [grpId integerValue];
            NSString *InstQuery= [NSString stringWithFormat:@"INSERT INTO  contacts (username,type,nickname,phpId,groupImg) VALUES ('%@','2','%@','%ld','%@')",senderId,[sendername capitalizedString],(long)grpID,grpPic?grpPic:@"NA"];
            [self.dbManager executeQuery:InstQuery];
        }
    }

    if ([userPermissionTyp isEqualToString:@"permission"]) {
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString*userValidateCheck = userInfo[@"aps"][@"target"];
        [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
        [userpref synchronize];
        [self navigateToTabBarScren:0];
    }
    
    if ([notify_type isEqualToString:@"logout"]) {
        [self logOut];
    }
    if ([appUpgrade isEqualToString:@"upgrade"]) {
        UIApplicationState state = [application applicationState];
        // user tapped notification while app was in background
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
         [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://apple.co/1TJwLM6"]];
        }
    }
    
     if ([cmetapOpen isEqualToString:@"cme"]) {
         UIApplicationState state = [application applicationState];
         // user tapped notification while app was in background
         if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
         [self openCourseDetailViewForPush:targetLessonId];
        }
         else{
             if (state == UIApplicationStateActive) {
                [self addCustomPushForgroundCMENotificationViewWithMessage:message fromUser:targetLessonId controlEnable:YES];
              }
         }
     }
    
    if ([feedIdentifier isEqualToString:@"feed"]) {
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            
            if(feedid == nil || [feedid isEqualToString:@""]){
                [self navigateToTabBarScren:0];
            }
            else
            {
                [self getFeedDetailsRequest:feedid];
            }
        }
        else{
            if (state == UIApplicationStateActive) {
                [self addCustomFeedNotificationViewWithMessage:message fromUser:feedid controlEnable:YES];
            }
        }
    }
   /*
    NSString *wordStr = @"Connection";
    if ([message rangeOfString:wordStr].location != NSNotFound)
    {
        UIApplicationState state = [application applicationState];
        // user tapped notification while app was in background
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            [AppDelegate appDelegate].isComeFromGrowNwAction = NO;
            [AppDelegate appDelegate].isCheckComeFromRemoteNotification= YES;
            [self navigateToTabBarScren:3];
        }
    }
    else{
        UIApplicationState state = [application applicationState];
        // user tapped notification while app was in background
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            // go to screen relevant to Notification content
            if (senderId != nil && _notificationView==nil) {
                [self openChatViewcontrollerforUser:senderId name:sendername threadId:-1 withMessage:message];
            }
        } else {
            
            // App is in UIApplicationStateActive (running in foreground)
            // perhaps show an UIAlertView
        }
    }
    */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // NSLog(@"Local Notif data : %@",notification.userInfo);
    UIApplicationState state = [application applicationState];
    if([[[notification userInfo]valueForKey:@"action"]isEqualToString:@"resultSubmit"])
    {
        if (state == UIApplicationStateActive) {
            [self addCustomCMENotificationViewWithMessage:notification.alertBody fromUser:[notification userInfo][@"lesson_id"] controlEnable:YES];
        }else{
            application.applicationIconBadgeNumber = 0; // Set icon badge number to zero
            [self openCourseDetailView:[notification userInfo][@"lesson_id"]];
        }
    }
}

- (void)openCourseDetailView:(NSString*)lessionID{
    if (_courseDetailControllerRefrence != nil) {
        //First remove _courseDetailControllerRefrence without animation and push
        [_courseDetailControllerRefrence.navigationController popViewControllerAnimated:NO];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CourseDetailVC *courseDetail = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:courseDetail];
    courseDetail.lessionID = lessionID;
    courseDetail.btnShow = YES;
    courseDetail.hidesBottomBarWhenPushed = YES;
    courseDetail.isShowdownloadedData = @"1";
    courseDetail.isNoifPView = YES;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    self.window.rootViewController = nav;
}

- (void)openCourseDetailViewForPush:(NSString*)lessionID{
    if (_courseDetailControllerRefrence != nil) {
        //First remove _courseDetailControllerRefrence without animation and push
        [_courseDetailControllerRefrence.navigationController popViewControllerAnimated:NO];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CourseDetailVC *courseDetail = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:courseDetail];
    courseDetail.lessionID = lessionID;
    courseDetail.btnShow = YES;
    CourseModel *cModel = [CourseModel new];
    cModel.lesson_id = lessionID;
    courseDetail.model = cModel;
    courseDetail.hidesBottomBarWhenPushed = YES;
    courseDetail.isShowdownloadedData = @"0";
    courseDetail.isNoifPView = YES;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
      self.window.rootViewController = nav;
}


#pragma mark - cancel Login Notification Action
-(void)cancelLoginN{
    //NSLog(@"Cancel Notification");
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* notification = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = notification.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:kTimerNameKey]];
        if ([uid isEqualToString:kName])
        {
            //Cancelling local notification
            [app cancelLocalNotification:notification];
            //NSLog(@"Notification Cancelled");
            break;
        }
    }
}

#pragma - mark Play Sound
-(void)playSound
{
    SystemSoundID soundToPlay;
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"iphonenotification" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &soundToPlay);
    //playback
    AudioServicesPlaySystemSound(soundToPlay);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self updateSetBadgeZeroToServer]; //set badge zero
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    [self cancelLoginN];
    //[self updatechatCredentialToQuickblox];
    [ServicesManager.instance.chatService connectWithCompletionBlock:nil];
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    [self GetAssociationList];
   // [self getSpecialityRequestWithAuthkey];
    [self cancelLoginN];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   // Logout from chat
    [ServicesManager.instance.chatService disconnectWithCompletionBlock:nil];
    [[NSUserDefaults standardUserDefaults]valueForKey:signInnormal]?nil:[self cancelLoginN];
    //[self methodGetNotification];
}

#pragma - mark Class Methods
+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

-(void)alerMassegeWithError:(NSString *)errorMassege withButtonTitle:(NSString *)title autoDismissFlag:(BOOL)flag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:errorMassege
                                                       delegate:nil
                                              cancelButtonTitle:title
                                              otherButtonTitles:nil];
    [alertView show];
    if (flag) {
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:2];
    }
}

-(void)dismissAlert:(UIAlertView*)x{
    [x dismissWithClickedButtonIndex:-1 animated:YES];
}

-(void) showIndicator
{
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
}

-(void) hideIndicator
{
    [MBProgressHUD hideHUDForView:self.window animated:NO];
}

-(void)logOut{
   // NSLog(@"Logout");
    [AppDelegate appDelegate].navigationController=nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewHomeVC *logout = [storyboard instantiateViewControllerWithIdentifier:@"NewHomeVC"];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:logout];
    for (UIView *view in window.subviews) {
        [view removeFromSuperview];
    }
    self.navigationController = nav;
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [window setRootViewController:navigationController];
   
    [self removeImage:@"MyProfileImage"];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //put on logout method
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *cQuery = @"DELETE FROM contacts";       // delete all data From contacts Table
    NSString *mQuery = @"DELETE FROM messages";     // delete all data From messages Table
    NSString *clQuery = @"DELETE FROM cme_lesson";       // delete all data From contacts Table
    NSString *cqQuery = @"DELETE FROM cme_questions";     // delete all data From messages Table
    NSString *cqaQuery = @"DELETE FROM cme_questions_answer"; // delete all data From contacts Table
    
    NSString *qbchatQuery = @"DELETE FROM qbChat";       // delete all data From qbChat Table
    NSString *qbDialog = @"DELETE FROM qbChatDialog";   // delete all data From qbChatDialog Table
    NSString *qbUser = @"DELETE FROM qbUser";          // delete all data From qbUser Table
    
    [self.dbManager loadDataFromDB:cQuery];
    [self.dbManager loadDataFromDB:mQuery];
    [self.dbManager loadDataFromDB:clQuery];
    [self.dbManager loadDataFromDB:cqQuery];
    [self.dbManager loadDataFromDB:cqaQuery];
    [self.dbManager loadDataFromDB:qbchatQuery];
    [self.dbManager loadDataFromDB:qbDialog];
    [self.dbManager loadDataFromDB:qbUser];
}

#pragma mark - playsound
-(void)getPlaySound{
    SystemSoundID soundToPlay;
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"docquity_Popup" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &soundToPlay);
    //playback
    AudioServicesPlaySystemSound(soundToPlay);
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [AppDelegate appDelegate].ischeckSelfVerifyScreen = YES;
    WebVC   *bvc = [[WebVC alloc] initWithUrls:URL];
    [[[AppDelegate appDelegate].window visibleViewController] presentViewController:bvc animated:YES completion:nil];
    //UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    // [self.viewController presentViewController:bvc animated:YES completion:nil];
    return YES;
    
    NSLog(@"urls is :- %@",URL);
    return FALSE;
}


#pragma mark - Open Url
-(BOOL)openURL:(NSURL*)url
{
     [AppDelegate appDelegate].ischeckSelfVerifyScreen = YES;
    WebVC   *bvc = [[WebVC alloc] initWithUrls:url];
    [[[AppDelegate appDelegate].window visibleViewController] presentViewController:bvc animated:YES completion:nil];
     //UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    // [self.viewController presentViewController:bvc animated:YES completion:nil];
    return YES;
}

#pragma mark - Create Directory
-(void) createDirectory : (NSString *) dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:dirName];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
        //NSLog(@"Couldn't create directory error: %@", error);
    }
    else {
        //NSLog(@"directory created!");
    }
    // NSLog(@"dataPath : %@ ",dataPath); // Path of folder created
}

- (void)swipUp:(UISwipeGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeMessageNotificationwithView:) object:nil];
        [self removeMessageNotificationwithView:_notificationView];
    }
}

- (void)closeMessageNotificationwithView:(UIView*)notifyView {
    [UIView animateWithDuration:0.0f animations:^{
        CGRect frame = _notificationView.frame;
        frame.origin.y = 0;
        notifyView.frame = frame;
    } completion:^(BOOL finished) {
        [_notificationView removeFromSuperview];
        _notificationView = nil;
    }];}

- (void)removeMessageNotificationwithView:(UIView*)notifyView {
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = _notificationView.frame;
        frame.origin.y = 0;
        notifyView.frame = frame;
    } completion:^(BOOL finished) {
         [_notificationView removeFromSuperview];
        _notificationView = nil;
    }];
}

//Return a current viewcontroller
- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *tempNavigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[tempNavigationController viewControllers] lastObject];
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        return [self visibleViewController:selectedViewController];
    }
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self visibleViewController:presentedViewController];
}

#pragma mark WebService Calls GetAssociationList
- (void) GetAssociationList
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    BOOL AlreadysignIn=[userpref boolForKey:signInnormal]; //already loggedIn
    if (AlreadysignIn) {
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetAssociationListRequest], keyRequestType1, nil];
        Server *server = [[Server alloc] init];
        currentRequestType = kGetAssociationListRequest;
        server.delegate = self;
        [server sendRequestToServer:aDic withDataDic:nil];
    }
}

#pragma mark WebService Calls GetCountryList
- (void)GetCountryList
{
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetCountryDetailsRequest], keyRequestType1, nil];
    Server *server = [[Server alloc] init];
    currentRequestType = kGetCountryDetailsRequest;
    server.delegate = self;
    [server sendRequestToServer:aDic withDataDic:nil];
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    if(currentRequestType == kGetAssociationListRequest)
    {
        [self GetAssociationListRequest:responseData];
    }
    else if(currentRequestType == kGetCountryDetailsRequest)
    {
        [self GetCountryDetailsRequest:responseData];
    }
    // NSLog(@"requestFinished");
}

- (void) GetAssociationListRequest:(NSDictionary *)response
{
    //NSLog(@"GetAssociationList response =%@",response);
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
    {
        // posts is null
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1)
        {
            NSMutableArray *assoarr = [[NSMutableArray alloc]init];
            assoarr =[resposeCode objectForKey:@"association"];
            if ([assoarr count]==0) {
            }else if ([assoarr count]==1)
            {
                self.myAssociationList = [[NSMutableArray alloc]init];
                self.myAssociationList =[resposeCode objectForKey:@"association"];
            }
            else if ([assoarr count]>1)
            {
                self.myAssociationList = [[NSMutableArray alloc]init];
                self.myAssociationList =[resposeCode objectForKey:@"association"];
                NSMutableString *asId;
                NSString*assoIdString = @"";
                for(int i=0; i<[self.myAssociationList count]; i++)
                {
                    NSDictionary *assoInfo = self.myAssociationList[i];
                    if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
                    {
                        asId = assoInfo[@"association_id"];
                        // NSLog(@"associationId =%@",asId);
                        NSString*str;
                        if(i==(self.myAssociationList.count -1)){
                            str = asId;
                        }
                        else {
                            str = [asId stringByAppendingString:@"|"];
                        }
                        assoIdString= [assoIdString stringByAppendingString:str];
                    }
                }
                /*
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:assoIdString forKey:@"association_id"];
                [dict setValue:@"Everyone" forKey:@"association_name"];
                [self.myAssociationList insertObject:dict atIndex:0];
                 */
            }
        }else if([[resposeCode  valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
        else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
        {
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
        }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 7){
            self.myAssociationList = [[NSMutableArray alloc]init];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:@"0" forKey:@"association_id"];
            [dict setValue:@"Public" forKey:@"association_name"];
            [self.myAssociationList addObject:dict];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gotMyAssociation" object:self];
    }
}

#pragma mark - get country DetailsList Api calling
- (void) GetCountryDetailsRequest:(NSDictionary *)response
{
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    // NSLog(@"resposeCode = %@",resposeCode);
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode==nil)
    {
        // tel is null
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1) {
            _countryListArray = [[NSMutableArray alloc]init];
            _countryListArray =[resposeCode objectForKey:@"country_details"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gotCountryList" object:self];
        }
        else{
            // [UIAppDelegate alerMassegeWithError:message withButtonTitle:OK_STRING autoDismissFlag:NO];
        }
    }
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
    if (currentRequestType==kGetAssociationListRequest) {
        [self GetAssociationList];
    }
}

//Seperate method
#pragma mark - Handle Network Change
- (void) handleNetworkChange:(NSNotification *)notice
{
    remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {
        _isInternet = false;
    }else if (remoteHostStatus == ReachableViaWiFi)
    {
        _isInternet = true;
    }else if (remoteHostStatus == ReachableViaWWAN)
    {
        _isInternet = true;
        [self getNetworkReport];
    }
    if(_isInternet){
        [updateExam submitExam];
    }
}

#pragma mark - getNetworkReport
-(void)getNetworkReport{
    _isInternet = true;
    NSString *dataType;
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *Tcarrier = [[netinfo subscriberCellularProvider] carrierName];
    NSLog(@"tcarrier = %@",Tcarrier);
    if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        //NSLog(@"2G");
        dataType = @"2G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        // NSLog(@"2G");
        dataType = @"2G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        // NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        //NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        // NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        // NSLog(@"2G");
        dataType = @"2G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        // NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        //NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        // NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        // NSLog(@"3G");
        dataType = @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        // NSLog(@"4G");
        dataType = @"4G";
    }
    [self handleDataDetection:dataType];
}

-(void)handleDataDetection:(NSString*)dataType{
    if ([dataType isEqualToString:@"2G"]) {
        _is2GData = YES;
        _is3GData = NO;
        _is4GData = NO;
        _isWifiData = NO;
    }else if ([dataType isEqualToString:@"3G"]) {
        _is2GData = NO;
        _is3GData = YES;
        _is4GData = NO;
        _isWifiData = NO;
    }
    else if ([dataType isEqualToString:@"4G"])
    {
        _is2GData = NO;
        _is3GData = NO;
        _is4GData = YES;
        _isWifiData = NO;
    }
    else if ([dataType isEqualToString:@"Wifi"]) {
        _is2GData = NO;
        _is3GData = NO;
        _is4GData = NO;
        _isWifiData = YES;
    }
    else {
        _is2GData = NO;
        _is3GData = NO;
        _is4GData = NO;
        _isWifiData = NO;
        _isInternet = FALSE;
    }
}

#pragma mark - call On_Start_Notification Webservice
-(void)ShowPopupScreen{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    NSString *userid=  [userdef objectForKey:userId];
    NSString *authkey =  [userdef objectForKey:userAuthKey];
    NSString *format =  @"json";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *device_type = @"ios";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ]initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=On_Start_Notification"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    // NSLog(@"string: %@",request);
    NSString *postString =  [NSString stringWithFormat:@"user_id=%@&user_auth_key=%@&format=%@&device_type=%@&version=%@",userid?userid:@"",authkey?authkey:@"",format?format:@"",device_type?device_type:@"",version?version:@""];
    //NSLog(@"string: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    __block NSError *e;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    // Code to run when the response completes...
                    //NSLog(@"Async On_Start_Notification Response= %@",response);
                    if (!error) {
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
                        // NSLog(@"Async On_Start_Notification Response json data= %@",json);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([[[json valueForKey:@"posts"]valueForKey:@"status"]integerValue]==1)
                                [self PopupScreenPresent:[[json valueForKey:@"posts"]valueForKey:@"data"]];
                        });
                    } else {
                        // update the UI to indicate error
                    }
                }] resume];
}

#pragma mark - show popup screen
-(void)PopupScreenPresent:(NSMutableDictionary*)info
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* temp = [defaults objectForKey:timeInMS];
    NSString* timetempValve = [defaults objectForKey:gn_timeset];
    int timeInterval = [timetempValve intValue];
    [defaults synchronize];
    long long int  previousTime = [temp  longLongValue];
    NSDate* today = [NSDate date];
    NSString* currentTime = [NSString stringWithFormat:@"%lld", [@(floor([today timeIntervalSince1970] * 1000)) longLongValue]];
    long long int currTime = [currentTime longLongValue];
    if([[info valueForKey:@"action"]isEqualToString:@"network"]){
        if ((previousTime+timeInterval*60*60*1000)>currTime)
        {
        }
        else{
            [self callPopupScreen:info];
        }
    }
    else if([[info valueForKey:@"action"]isEqualToString:@"connection"])
    {
        if ((previousTime+timeInterval*60*60*1000)>currTime)
        {
        }
        else
        {
            [self callPopupScreen:info];
        }
    }
    else if([[info valueForKey:@"action"]isEqualToString:@"notification"])
    {
        if ((previousTime+timeInterval*60*60*1000)>currTime)
        {
        }
        else
        {
            [self callPopupScreen:info];
        }
    }
    else
    {
        [self callPopupScreen:info];
    }
}

#pragma mark - callPopup method
-(void)callPopupScreen:(NSMutableDictionary*)infoDic{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];;
    // UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    PopupVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"PopupVC"];
    vc.dataDic = infoDic;
    [[[AppDelegate appDelegate].window visibleViewController] presentViewController:vc animated:YES completion:nil];
}

-(void)removeImage:(NSString*)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", fileName]];
    NSError *error = nil;
    if(![fileManager removeItemAtPath: fullPath error:&error]) {
        // NSLog(@"Delete failed:%@", error);
    } else {
        //  NSLog(@"image removed: %@", fullPath);
    }
    // NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
    //  NSLog(@"Directory Contents:\n%@", [fileManager directoryContentsAtPath: appFolderPath]);
}

- (void)ischeckedreadOnly{
    [self getcheckedUserPermissionData];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic==nil)
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
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic== nil)
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
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:OK_STRING autoDismissFlag:NO];
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

#pragma mark private methods- customized
-(void)navigateToTabBarScren:(NSInteger)selectedIndex{
    
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.tabBarCtl = [[UITabBarController alloc] init];
    self.tabBarCtl.delegate = self;
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0]
     ];

    NSMutableArray *vcArr = [[NSMutableArray alloc] initWithCapacity:4];
    //What's Trending Tab Config
    NSString *xib = nil;
    if (IS_IPHONE_6) {
        xib = @"FeedVC-i6";
    }
    else if (IS_IPHONE_6_PLUS){
        xib = @"FeedVC-i6Plus";
    }
    else {
        xib = IS_IPHONE_5?@"FeedVC-i5":@"FeedVC";
    }
    FeedVC *VC1 = [[FeedVC alloc]initWithNibName:xib bundle:nil];
    UINavigationController *nVC1 = [[UINavigationController alloc] initWithRootViewController:VC1];
    nVC1.tabBarItem.title = @"Trends";
    nVC1.tabBarItem.image = [UIImage imageNamed:@"trends.png"];
    nVC1.tabBarItem.selectedImage =[UIImage imageNamed:@"trendsblue.png"];
    nVC1.tabBarItem.tag = 1;
    [vcArr addObject:nVC1];
    
    //CME Tab Config
    UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    AvailableCourseVC *VC2  = [mstoryboard instantiateViewControllerWithIdentifier:@"AvailableCourseVC"];
    UINavigationController *nVC2 = [[UINavigationController alloc] initWithRootViewController:VC2];
    nVC2.tabBarItem.title = @"CME";
    nVC2.tabBarItem.image = [UIImage imageNamed:@"CME"];
    nVC2.tabBarItem.selectedImage =[UIImage imageNamed:@"CMEblue.png"];
    nVC2.tabBarItem.tag = 2;
    [vcArr addObject:nVC2];
    
    //My Connection Network Tab Config // chats via Quickblox
    UIStoryboard *qbstoryboard = [UIStoryboard storyboardWithName:@"QBStoryboard" bundle:nil];
    DialogsViewController *VC3  = [qbstoryboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    UINavigationController *nVC3 = [[UINavigationController alloc] initWithRootViewController:VC3];
    nVC3.tabBarItem.title = @"Chats";
    nVC3.tabBarItem.tag = 3;
    nVC3.tabBarItem.selectedImage =[UIImage imageNamed:@"chatblue.png"];
    nVC3.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
    [vcArr addObject:nVC3];
    
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotificationVC *VC4  = [mainstoryboard instantiateViewControllerWithIdentifier:@"NotificationVC"];
    UINavigationController *nVC4 = [[UINavigationController alloc] initWithRootViewController:VC4];
    nVC4.tabBarItem.title = @"Notifications";
    nVC4.tabBarItem.selectedImage =[UIImage imageNamed:@"notificationsblue.png"];
    nVC4.tabBarItem.image = [UIImage imageNamed:@"notifications"];
    nVC4.tabBarItem.tag = 4;
    [vcArr addObject:nVC4];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingVC *VC5 = [storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
    UINavigationController *nVC5 = [[UINavigationController alloc] initWithRootViewController:VC5];
    nVC5.tabBarItem.title = @"Account";
    nVC5.tabBarItem.image = [UIImage imageNamed:@"accounts_unselected.png"];
    nVC5.tabBarItem.selectedImage =[UIImage imageNamed:@"accounts_selected.pngse"];
    nVC5.tabBarItem.tag = 5;
    [vcArr addObject:nVC5];
    
    //Navigaiton Bar Customization
    for (UINavigationController *nVC in vcArr) {
        nVC.navigationBar.barStyle =  UIBarStyleBlackTranslucent;
        self.tabBarCtl.tabBar.barTintColor = [UIColor whiteColor];
    }
    [self.tabBarCtl setViewControllers:vcArr];
    self.tabBarCtl.selectedIndex = selectedIndex;
    [[[AppDelegate appDelegate].window visibleViewController] presentViewController:self.tabBarCtl animated:NO completion:nil];
}

#pragma mark - update device token Server
-(void)updateDeviceTokenToServer{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]UpdateDeviceTokenWithUserID:[userdef valueForKey:userId] device_type:kDeviceType deviceToken:deviceTokenString format:jsonformat callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            // NSLog(@"response from device token update = %@",resposeCode);
        }
    }];
}

#pragma mark - update badge zero on Server api calling
-(void)updateSetBadgeZeroToServer{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    NSString*devicedetails = [self adddeviceInfodetails:nil];
   // NSString *authkey =  [userdef objectForKey:userAuthKey];
    //mandatory
    // devicedetails = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
    //                                                                                          NULL,(CFStringRef)devicedetails,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    [[DocquityServerEngine sharedInstance]SetBadgeZerowithAuthKey:[userdef valueForKey:userAuthKey] user_id:[userdef valueForKey:userId] device_info:devicedetails jabber_id:@"" custom_id:@"" format:@"json" callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // if postsdic is null
        }
        else {
            
             if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                NSDictionary *notifyInfoDic=[resposeCode objectForKey:@"data"];
                if ([notifyInfoDic isKindOfClass:[NSNull class]]||notifyInfoDic == nil)
                {
                    // datadic is null
                }
                else {
                    NSString*notification_count  = [notifyInfoDic objectForKey:@"count"];
                    if([notification_count isEqualToString:@"0"]){
                        [[[AppDelegate appDelegate].tabBarCtl.tabBar.items objectAtIndex:3]setBadgeValue:nil];
                    }
                    else {
                        [[[AppDelegate appDelegate].tabBarCtl.tabBar.items objectAtIndex:3] setBadgeValue:notification_count];
                        //NSLog(@"response from total notification_count = %@",notification_count);
                    }
                }
            }
        }
    }];
}

#pragma mark - get local notification
-(void)methodGetNotification{
    // NSLog(@"timerDidFire");
    if(![[NSUserDefaults standardUserDefaults]valueForKey:signInnormal]){
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:300];
        localNotification.alertBody = @"It seems like you don't have login to Docquity. Please login and enjoy the doctor's only network.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName = @"default";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:kName forKey:kTimerNameKey];
        localNotification.userInfo = userInfo;
        // NSLog(@"Notification Schedule");
    }else{
        // NSLog(@"Already loggedin");
    }
}

#pragma mark - get device details
-(NSString *)adddeviceInfodetails:(NSString *)deviceInfoStr{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *tcarrier = [netinfo subscriberCellularProvider];
    //NSLog(@"Carrier Name: %@", [carrier carrierName]);
    NSString *platform = [UIDevice currentDevice].model;
    NSString *str = [NSString stringWithFormat:@"Version - %@,Build number - %@,Carrier - %@,Model - %@System Name - %@,SystemVersion - %@,SystemName - %@",version,build,[tcarrier carrierName],platform,[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion,[UIDevice currentDevice].systemName];
    return str;
}

#pragma mark - getFeedDetailsRequest api calling
-(void)getFeedDetailsRequest:(NSString*)feedId{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]singlefeedRequest:[userdef valueForKey:userAuthKey] feed_id:feedId device_type:kDeviceType app_version:[userdef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
         //   NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                //NSLog(@"Feed response for feed_id %@ = %@",feedId,resposePost);
                [self openSingleFeedView:resposePost.mutableCopy];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
               // UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
               // [alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
            
            else  if([[resposePost valueForKey:@"status"]integerValue] == 11)
            {
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
        }
    }];
}

#pragma mark- local CME NotificationView
- (void)addCustomPushForgroundCMENotificationViewWithMessage:(NSString*)msgString fromUser:(NSString*)lessonId  controlEnable:(BOOL)enable
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeMessageNotificationwithView:) object:nil];
    if (_notificationView != nil)
    {
        [_notificationView removeFromSuperview];
        _notificationView = nil;
    }
    _notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, -64, CGRectGetWidth(self.window.bounds), 64)];
    
    //To hold the notification info
    _notificationView.userjid = lessonId;
    _notificationView.message = msgString;
    _notificationView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    [self.window addSubview:_notificationView];
    //[self playSound];
     [Utils playClick2Sound];
    UIImageView* notifyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 18, 18)];
    notifyIcon.image = [UIImage imageNamed:@"icon-29.png"];
    notifyIcon.layer.cornerRadius = 4.0;
    notifyIcon.layer.masksToBounds = YES;
    [_notificationView addSubview:notifyIcon];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+5, 10, CGRectGetWidth(self.window.bounds)-(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+50), 40)];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = msgString;
    [label setFont:[UIFont systemFontOfSize:12]];
    label.numberOfLines = 0;
    label.alpha = 0.0f;
    UIButton *crossbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    crossbutton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-30,(label.frame.size.height + label.frame.origin.y)/2, 20, 20);
    [crossbutton setBackgroundImage:[UIImage imageNamed:@"crossbtn.png"] forState:UIControlStateNormal];[crossbutton addTarget:self action:@selector(closeMessageNotificationwithView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_notificationView addSubview:crossbutton];
    UIImage *barImage = [UIImage imageNamed:@"swipe_line"];
    UIImageView *barImageview = [[UIImageView alloc]initWithFrame:CGRectMake(_notificationView.frame.size.width/2-barImage.size.width/2, _notificationView.frame.size.height-barImage.size.height/2, barImage.size.width, barImage.size.height)];
    [barImageview setImage:barImage];
    [_notificationView addSubview:barImageview];
    [_notificationView addSubview:label];
    
    if (enable) {
        //Add gesture on View
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(PushForegroundcme_notificationTapped:)];
        [_notificationView addGestureRecognizer:gesture];
    }
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipUp:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [_notificationView addGestureRecognizer:swipeGesture];
    [UIView animateWithDuration:0.5f animations:^{
        label.alpha = 1.0f;
        CGRect frame = _notificationView.frame;
        frame.origin.y = 0;
        _notificationView.frame = frame;
    } completion:^(BOOL finished) {
    }];
    [self performSelector:@selector(removeMessageNotificationwithView:) withObject:_notificationView afterDelay:5.0];
}

- (void)PushForegroundcme_notificationTapped:(UITapGestureRecognizer*)gesture
{
    _notificationView = (NotificationView*)gesture.view;
    if (_notificationView != nil && gesture.state == UIGestureRecognizerStateRecognized)
    {
        [self openCourseDetailViewForPush:_notificationView.userjid];
        [self removeMessageNotificationwithView:_notificationView];
    }
}

- (void)openSingleFeedView:(NSMutableDictionary*)feedDict{
    if (_NewCommentRefrence != nil) {
        //First remove NewCommentRefrence without animation and push
        [_NewCommentRefrence.navigationController popViewControllerAnimated:NO];
    }
    NSMutableDictionary *feed = [feedDict valueForKey:@"data"][@"feed"];
    NSString *tlike =  [feed objectForKey:@"total_like"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewCommentVC *newcomment = [storyboard instantiateViewControllerWithIdentifier:@"NewCommentVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newcomment];
    newcomment.feedDict = feed;
    newcomment.isNoifPView = YES;
    newcomment.t_likeStr = tlike;
    newcomment.hidesBottomBarWhenPushed = YES;
    newcomment.delegate = self;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    self.window.rootViewController = nav;
}

#pragma mark- local CME NotificationView
- (void)addCustomCMENotificationViewWithMessage:(NSString*)msgString fromUser:(NSString*)lessonId  controlEnable:(BOOL)enable
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeMessageNotificationwithView:) object:nil];
    if (_notificationView != nil)
    {
        [_notificationView removeFromSuperview];
        _notificationView = nil;
    }
    _notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, -64, CGRectGetWidth(self.window.bounds), 64)];
    
    //To hold the notification info
    _notificationView.userjid = lessonId;
    _notificationView.message = msgString;
    _notificationView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    [self.window addSubview:_notificationView];
   // [self playSound];
     [Utils playClick2Sound];
    UIImageView* notifyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 18, 18)];
    notifyIcon.image = [UIImage imageNamed:@"icon-29.png"];
    notifyIcon.layer.cornerRadius = 4.0;
    notifyIcon.layer.masksToBounds = YES;
    [_notificationView addSubview:notifyIcon];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+5, 10, CGRectGetWidth(self.window.bounds)-(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+50), 40)];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = msgString;
    [label setFont:[UIFont systemFontOfSize:12]];
    label.numberOfLines = 0;
    label.alpha = 0.0f;
    UIButton *crossbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    crossbutton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-30,(label.frame.size.height + label.frame.origin.y)/2, 20, 20);
    [crossbutton setBackgroundImage:[UIImage imageNamed:@"crossbtn.png"] forState:UIControlStateNormal];[crossbutton addTarget:self action:@selector(closeMessageNotificationwithView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_notificationView addSubview:crossbutton];
    UIImage *barImage = [UIImage imageNamed:@"swipe_line"];
    UIImageView *barImageview = [[UIImageView alloc]initWithFrame:CGRectMake(_notificationView.frame.size.width/2-barImage.size.width/2, _notificationView.frame.size.height-barImage.size.height/2, barImage.size.width, barImage.size.height)];
    [barImageview setImage:barImage];
    [_notificationView addSubview:barImageview];
    [_notificationView addSubview:label];

    if (enable) {
        //Add gesture on View
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cme_notificationTapped:)];
        [_notificationView addGestureRecognizer:gesture];
    }
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipUp:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [_notificationView addGestureRecognizer:swipeGesture];
    [UIView animateWithDuration:0.5f animations:^{
        label.alpha = 1.0f;
        CGRect frame = _notificationView.frame;
        frame.origin.y = 0;
        _notificationView.frame = frame;
    } completion:^(BOOL finished) {
    }];
    [self performSelector:@selector(removeMessageNotificationwithView:) withObject:_notificationView afterDelay:5.0];
}

- (void)cme_notificationTapped:(UITapGestureRecognizer*)gesture
{
    _notificationView = (NotificationView*)gesture.view;
    if (_notificationView != nil && gesture.state == UIGestureRecognizerStateRecognized)
    {
        [self openCourseDetailView:_notificationView.userjid];
        [self removeMessageNotificationwithView:_notificationView];
    }
}

#pragma mark- local Feed NotificationView
- (void)addCustomFeedNotificationViewWithMessage:(NSString*)msgString fromUser:(NSString*)feedId  controlEnable:(BOOL)enable
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeMessageNotificationwithView:) object:nil];
    if (_notificationView != nil)
    {
        [_notificationView removeFromSuperview];
        _notificationView = nil;
    }
    _notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, -64, CGRectGetWidth(self.window.bounds), 64)];
    
    //To hold the notification info
    _notificationView.userjid = feedId;
    _notificationView.message = msgString;
    _notificationView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    [self.window addSubview:_notificationView];
   // [self playSound];
     [Utils playClick2Sound];
    UIImageView* notifyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 18, 18)];
    notifyIcon.image = [UIImage imageNamed:@"icon-29.png"];
    notifyIcon.layer.cornerRadius = 4.0;
    notifyIcon.layer.masksToBounds = YES;
    [_notificationView addSubview:notifyIcon];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+5, 10, CGRectGetWidth(self.window.bounds)-(notifyIcon.frame.origin.x+notifyIcon.frame.size.width+50), 40)];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = msgString;
    [label setFont:[UIFont systemFontOfSize:12]];
    label.numberOfLines = 0;
    label.alpha = 0.0f;
    UIButton *crossbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    crossbutton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-30,(label.frame.size.height + label.frame.origin.y)/2, 20, 20);
    [crossbutton setBackgroundImage:[UIImage imageNamed:@"crossbtn.png"] forState:UIControlStateNormal];[crossbutton addTarget:self action:@selector(closeMessageNotificationwithView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_notificationView addSubview:crossbutton];
    UIImage *barImage = [UIImage imageNamed:@"swipe_line"];
    UIImageView *barImageview = [[UIImageView alloc]initWithFrame:CGRectMake(_notificationView.frame.size.width/2-barImage.size.width/2, _notificationView.frame.size.height-barImage.size.height/2, barImage.size.width, barImage.size.height)];
    [barImageview setImage:barImage];
    [_notificationView addSubview:barImageview];
    [_notificationView addSubview:label];
    
    if (enable) {
        //Add gesture on View
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feed_notificationTapped:)];
        [_notificationView addGestureRecognizer:gesture];
    }
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipUp:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [_notificationView addGestureRecognizer:swipeGesture];
    [UIView animateWithDuration:0.5f animations:^{
        label.alpha = 1.0f;
        CGRect frame = _notificationView.frame;
        frame.origin.y = 0;
        _notificationView.frame = frame;
    } completion:^(BOOL finished) {
    }];
    [self performSelector:@selector(removeMessageNotificationwithView:) withObject:_notificationView afterDelay:5.0];
}

- (void)feed_notificationTapped:(UITapGestureRecognizer*)gesture
{
    _notificationView = (NotificationView*)gesture.view;
    if (_notificationView != nil && gesture.state == UIGestureRecognizerStateRecognized)
    {
        [self getFeedDetailsRequest:_notificationView.userjid];
        [self removeMessageNotificationwithView:_notificationView];
    }
}

#pragma mark - NotificationServiceDelegate protocol
- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    if (_newchatViewControllerRefrence != nil) {
        //First remove NewCommentRefrence without animation and push
        [_newchatViewControllerRefrence.navigationController popViewControllerAnimated:NO];
    }
    ChatViewController *chatController = (ChatViewController *)[[UIStoryboard storyboardWithName:@"QBStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatController];
    chatController.hidesBottomBarWhenPushed = YES;
    chatController.dialog = chatDialog;
    
        NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
        if (dialogWithIDWasEntered != nil) {
            // some chat already opened, return to dialogs view controller first
            [nav popViewControllerAnimated:NO];
        }
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    self.window.rootViewController = nav;
}


-(BOOL)checkTableInDialog:(NSString *)dialogid withRecpID:(NSString *)recpId{
  //  NSLog(@"checkDialogInTable in App delegate");
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *fetchQuery= [NSString stringWithFormat:@"SELECT dialogID,recipient_id FROM qbChatDialog WHERE dialogID ='%@'",dialogid];
    
    // Get the results.
    if (self.dialogInfo != nil) {
        self.dialogInfo = nil;
    }
    
    self.dialogInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:fetchQuery]];
   // NSLog(@"dialogInfo = %@",self.dialogInfo);
    if(self.dialogInfo.count != 0)
    {
        return YES;
    }
    return NO;
}

-(void)getDialogById:(NSString *)dialogid{
  //  NSLog(@"getDialogById in app delegate");
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getSingleChatDialogueWithAuthKey:[userdef valueForKey:userAuthKey] lang:kLanguage app_version:[userdef valueForKey:kAppVersion] dialog:dialogid callback:^(NSMutableDictionary *responseObject, NSError *error) {
        //NSLog(@"responceObject for getDialogById  = %@",responseObject);
        NSInteger resStat = [[responseObject valueForKey:@"posts"][@"status"]integerValue];
        if(resStat == 1){
            NSArray *list = [responseObject valueForKey:@"posts"][@"data"][@"list"];
            if([list isKindOfClass:[NSArray class]]){
                //  NSLog(@"list = %@",[list objectAtIndex:0]);
                [self insertDialog:list];
            }
        }else if(resStat == 9){
            [self logOut];
        }
    }];
}

#pragma mark - Database handling
-(void)insertDialog:(NSArray*)dialog
{
  //  NSLog(@"insertDialog by getDialogById API");
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
        NSString *dialogPhoto         =   [partcipants objectAtIndex:0][@"profile_pic_path"];//[dic valueForKey:@"photo"];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatDialogTableupdate" object:self];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DialogInserted" object:self];
  }

#pragma mark - update device token Server
-(void)updatechatCredentialToQuickblox{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getChatCredentialCreateWithAuthKey:[userdef objectForKey:userAuthKey] lang:kLanguage app_version:[userdef objectForKey:kAppVersion] device_type:kDeviceType callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
            NSDictionary *dataDic=[resposeCode objectForKey:@"data"];
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
            {
                // tel is null
            }
            else
            {
                NSString*chatId  = dataDic[@"chat_id"];
                NSString*jabberName  = dataDic[@"jabber_name"];
                NSString*jabberPassword  = dataDic[@"jabber_password"];
//                 NSLog(@"chatId_update = %@",chatId);
//                 NSLog(@"jabber_name_update = %@",jabberName);
//                 NSLog(@"jabberPassword  = %@",jabberPassword );

                [userdef setObject:chatId?chatId:@"" forKey:chatId1];
                [userdef setObject:jabberName?jabberName:@"" forKey:kjabberName];
                [userdef setObject:jabberPassword?jabberPassword:@"" forKey:password1];
                [userdef synchronize];
              //  [self loginInQuickblox];

            // NSLog(@"response from device token update = %@",resposeCode);
            }
        }
        }
    }];
}


@end
