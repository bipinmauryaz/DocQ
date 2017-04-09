/*============================================================================
 PROJECT: Docquity
 FILE:    AppDelegate.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/06/15.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define UIAppDelegate \
((AppDelegate *)[UIApplication sharedApplication].delegate)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Server.h"
#import "CourseDetailVC.h"
#import "NewCommentVC.h"
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//DB
#import "DBManager.h"

@class SplashScreenViewController;
@class HomeVC;
@class NewChatViewController;
@class FeedVC;
@class NewCommentVC;
@class ChatViewController;

/*============================================================================
 Interface: AppDelegate
 =============================================================================*/
@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLConnectionDelegate,ServerRequestFinishedProtocol,UITabBarControllerDelegate>{
    
    //web services request enum type
    ServerRequestType1 currentRequestType;
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    BOOL isGrpUpdate;
    UIWindow *window;
    UINavigationController *navigationController;
    SplashScreenViewController *obj;
    //alert view for wait
    UIAlertView             *aAlert;
    UIActivityIndicatorView *activityIndicator;
    
    //DB
    NSMutableArray *DataSource;
    NSMutableArray *groupIdArr;
    NSMutableArray *userNameArr;
    
    //pushnotification
    NSString *deviceTokenString;
    BOOL isSendDeviceToken;
    NSString *responseMsg;
    AVAudioPlayer *audioPlayer;
    BOOL testapplaunchfirst;

    //tesitng push
    NSMutableData *receivedData;
    NSString*couponIdForPush;
    BOOL isLogin;
    BOOL isinviteGroup;
    NSInteger th_id;
   //NSMutableString *dataPath;
   CTCarrier *carrier;
Reachability* reachability;
}
@property (nonatomic)BOOL is2GData;
@property (nonatomic)BOOL is3GData;
@property (nonatomic)BOOL is4GData;
@property (nonatomic)BOOL isWifiData;
@property (nonatomic)BOOL isInternet;
@property (nonatomic)NetworkStatus remoteHostStatus;
@property (nonatomic, weak)FeedVC *feebVCRef;
@property(nonatomic,strong) NSMutableString *dataPath;
@property (strong, nonatomic) SplashScreenViewController *viewController;
@property (weak)ChatViewController *newchatViewControllerRefrence;
@property (weak)CourseDetailVC *courseDetailControllerRefrence;
@property (weak) NewCommentVC *NewCommentRefrence;
@property(strong,nonatomic) UINavigationController *navigationController;
@property(nonatomic)BOOL comefromsearch;                             //iscomefrom search
@property (nonatomic)BOOL ispostingWIthTagged;                      // is come from tagged
@property (nonatomic)BOOL isComeFromTrending;                      // is come from Trending
@property (nonatomic)BOOL isbackFromPostFeed;                     // is back from post feed
@property (nonatomic)BOOL isMetaData;                            // is metaData
@property (nonatomic)BOOL isCases_Feed;                         // is cases
@property (nonatomic)BOOL isOpenAppFirstTime;                 // isOpenAppFirstTime
@property (nonatomic)BOOL ischeckedReadOnlyPermissionStus;   //  isReadOnlyPermissionStus
@property (nonatomic)BOOL isbackUpdateCheckFromSearch;      // isbackUpdateCheckFromSearch;
@property (nonatomic)BOOL isComeFromNotificationScreen;    // isCheckComeFromRemoteNotification
@property (nonatomic)BOOL isComeFromSettingVC;            // isComeFromSettingVC
@property (nonatomic)BOOL isComeFromTimeline;            // isComeFromTimeline;
@property (nonatomic)BOOL isCheckComeFromSkipOrNext;    // isCheckComeFromSkipOrNext;
@property (nonatomic)BOOL isComeFromReviewListScreen;  // isComeFromReviewListScreen;
@property (nonatomic)BOOL isSubmitBtnCallingFromScreen;  //isSubmitBtnCallingFromScreen;
@property (nonatomic)BOOL ischeckSelfVerifyScreen;      //ischeckSelfVerifyScreen;

//Push notification
@property(nonatomic,strong) NSString *deviceTokenString;
@property(nonatomic,strong) NSData *devTokForQB;
+ (AppDelegate *)appDelegate;

-(void)alerMassegeWithError:(NSString *)errorMassege withButtonTitle:(NSString *)title autoDismissFlag:(BOOL)flag;
- (void) showIndicator;
- (void) hideIndicator;
- (void)logOut;
- (void)getPlaySound;

//DB
@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic) BOOL isSendNotification;
@property(nonatomic,strong)NSMutableArray *myAssociationList;
@property(nonatomic,strong)NSMutableArray *mySpecialityList;
@property(nonatomic,strong)NSMutableArray *countryListArray;

-(void) GetAssociationList;
-(void)GetCountryList;
-(BOOL)openURL:(NSURL*)url;
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;

-(BOOL)isAppAlreadyLaunchedOnce;
-(void)ShowPopupScreen;
-(void)ischeckedreadOnly;
-(void)cancelLoginN;

@property (nonatomic,strong) UITabBarController *tabBarCtl;
-(void)navigateToTabBarScren:(NSInteger)selectedIndex;
@property (nonatomic,assign)UIBackgroundTaskIdentifier backgroundUpdateTask;

//QB
@property (strong, nonatomic)NSArray *dialogInfo;
-(BOOL)checkTableInDialog:(NSString *)dialogid withRecpID:(NSString *)recpId;
-(void)getDialogById:(NSString *)dialogid;
@property (nonatomic,retain) NSMutableArray *ActivityArray;


@end
