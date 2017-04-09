/*============================================================================
 PROJECT: Docquity
 FILE:    ClaimProfileVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 22/08/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "Server.h"
#import "DBManager.h"
@import MessageUI;
@interface ClaimProfileVC : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,ServerRequestFinishedProtocol,MFMailComposeViewControllerDelegate>{
//    UILabel *lblField;
//    UITextField *tfField;
    
    NSUserDefaults *userdef;
    ServerRequestType1 currentRequestType;
    NSInteger statusResponse;
    NSMutableDictionary *data_dic;
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    NSString*userPic;                   // Store user Profile pic when we are login
    BOOL isAccountClaimed;
    NSString* jabberName;
    NSString* jabberPassword;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *actifText;
@property (nonatomic)BOOL isNewUser;
@property (nonatomic,strong)NSString *selectedCountry;
@property (nonatomic,strong)NSString *selectedAssoID;

- (IBAction)TermsBtnClicked:(id)sender;
@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property(nonatomic,strong)  NSMutableArray*frndListArr;


//DB
@property (nonatomic,strong) DBManager *dbManager;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;

//keyboard Accessory Toolbar method

- (IBAction)doneEditing:(id)sender;
@end
