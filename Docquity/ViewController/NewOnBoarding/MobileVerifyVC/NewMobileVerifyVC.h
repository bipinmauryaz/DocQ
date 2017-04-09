//
//  MobileVerifyVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeClaimVC.h"
#import "NewUserDetailsVC.h"

@interface NewMobileVerifyVC : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *btnNeedHelp;
    //IBOutlet UIButton *btnResendOTP;
    IBOutlet UILabel *lblCountryCode;
    IBOutlet UILabel *lblTimer;
    IBOutlet UIButton *btnEditNumber;
    IBOutlet UIToolbar *accessoryViewTool;
    NSTimer *timer;
    BOOL isOTPResend;
    NSString* JabberName;               // Store user jabber Name
    NSString* JabberID;                 // Store user jabber id
    NSString* jabberPassword;           // User jabber password
    NSString* chatId;                   // User chat ID
    NSInteger waitingtimerCount;//
    IBOutlet UILabel*lbl_OTPcountryCode;
    NSString*cardImgUrl;
    NSString*inviteExample;
    NSString*invideCodeType;
    NSString*associationId;
    IBOutlet UITextField *tfUserMobileNumber;
    IBOutlet UIView* tfMobileView;
    NSInteger count;
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    NSString*userPic;                   // Store user Profile pic when we are login
}

@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;

@property (nonatomic,strong) NSArray *OTPassoIdArr;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP1;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP2;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP3;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP4;
@property (weak, nonatomic) IBOutlet UIButton *btnResendOTP;
@property (weak, nonatomic) IBOutlet UILabel *lblOTPMessage;
@property(strong,nonatomic)NSString *strContactNumber;
@property (nonatomic,strong) NSString *countryCode;
@property (nonatomic,strong) NSString *assoIdCountNumber;
@property (nonatomic,strong) NSString *verrifyOTPTitleMsg;
@property (nonatomic) NSInteger timerCount;
@property(strong,nonatomic)NSMutableArray *Arr_associationId;
@property (nonatomic,strong) NSString *OtpcountryCode;
@property(strong,nonatomic)NSDictionary *OTPassociationDic;
@property (nonatomic,strong) NSString *Otpregistered_userType;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;

-(IBAction)btnResendOTP:(id)sender;
-(IBAction)btnEditButtonClicked:(id)sender;
-(IBAction)btnNextClicked:(id)sender;

@end
