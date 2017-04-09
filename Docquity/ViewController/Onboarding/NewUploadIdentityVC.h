/*============================================================================
 PROJECT: Docquity
 FILE:    NewUploadIdentityVC.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 27/08/16.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define MOBILE_NO_FIELD_MAX_CHAR_LENGTH 11
#define PASSWORD_MAX_CHAR_LENGTH 20

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "LPPopupListView.h"
#import "Server.h"
#import "DBManager.h"
@import MessageUI;
/*============================================================================
 Interface:   NewUploadIdentityVC
 =============================================================================*/
@interface NewUploadIdentityVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LPPopupListViewDelegate,UITableViewDataSource,UITableViewDelegate,ServerRequestFinishedProtocol,MFMailComposeViewControllerDelegate>{
    NSString *u_ImgType;
    NSString *base64EncodedString;
    NSMutableArray *documentList;
    ServerRequestType1 currentRequestType;
    NSInteger responseStatus;
    BOOL isImgUpload;
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    NSString*userPic;                   // Store user Profile pic when we are login
}

@property (weak, nonatomic) IBOutlet UIButton *btn_skip;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *chooseImgHolder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popupParentView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic,strong) NSMutableDictionary *userData;

- (IBAction)didPressGotIT:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (nonatomic,strong)NSString *selectedCountry;
@property (nonatomic,strong)NSString *selectedAssoID;


@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property(nonatomic,strong)  NSMutableArray*frndListArr;

//DB
@property (nonatomic,strong) DBManager *dbManager;

@end
