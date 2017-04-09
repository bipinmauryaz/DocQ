/*============================================================================
 PROJECT: Docquity
 FILE:    MobileVerifyVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 22/08/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "LPPopupListView.h"
#import "Server.h"
#import "DBManager.h"
@interface MobileVerifyVC : UIViewController<UITextFieldDelegate,LPPopupListViewDelegate,ServerRequestFinishedProtocol>{
    NSInteger count;
    NSString *selectedCountry;
    NSString *selectedCountrycode;
    NSTimer *timer;
    NSInteger timerCount;
    ServerRequestType1 currentRequestType;
    NSInteger statusResponse;
    UITextField *activeField;
    BOOL keyboardHasAppeard;
    NSString *token_id;
    BOOL isOTPResend;
    NSString* customId;
    NSString*userType;
    NSString*uId;                       // Store user id when we are login
    NSString*u_fName;                   // Store user First name when we are login
    NSString*u_lName;                   // Store user last name when we are login
    NSString*u_email;                   // fStore user email when we are login
    NSString*userPic;                   // Store user Profile pic when we are login
    NSString*refLink;                   // Store user refereal link
    NSString* JabberName;               // Store user jabber Name
    NSString* JabberID;                 // Store user jabber id
    NSString* jabberPassword;           // User jabber password
    NSString* chatId;                    // User chat ID
    NSString*userState;                 // Store user state when we are login
    NSString*userCity;                  // Store user city when we are login
    NSString*userCountry;               // Store user country
    NSString*userCountryCode;           // Store user country code
    NSString*userMobNo;                 // Store user MobNo when we are login
    NSString*userRegNo;                 // Store user regNo when we are login
    NSString*userDob;                   // Store user Dob when we are login
    NSString*userGender;                // Store user Gender when we are login
    NSString*u_authkey;                 // Store user authkey when we are login
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    BOOL didPresentCountry;
    BOOL isCountryFound;
}
@property (weak, nonatomic) IBOutlet UIView *popupBackView;
@property (weak, nonatomic) IBOutlet UIView *mobileParentView;
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *tfMobileNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnEditMobile;
@property (weak, nonatomic) IBOutlet UIButton *btnProceed;
@property (weak, nonatomic) IBOutlet UITextField *tfOTP;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UILabel *lblOTPMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLblTitleConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTfOTPConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMobileViewHolderConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBtnProceedConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLogoConst;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic,strong)NSMutableArray *countryArr;
- (IBAction)didPressCountryPick:(id)sender;

@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property(nonatomic,strong)  NSMutableArray*frndListArr;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;

//keyboard Accessory Toolbar method
- (IBAction)doneEditing:(id)sender;

//DB
@property (nonatomic,strong) DBManager *dbManager;

@end
