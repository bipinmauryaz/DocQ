/*============================================================================
 PROJECT: Docquity
 FILE:    ThankYouVC.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 01/09/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "Server.h"
#import "DBManager.h"
@import MessageUI;

/*============================================================================
 Interface:   ThankYouVC
 =============================================================================*/
@interface ThankYouVC : UIViewController<MFMailComposeViewControllerDelegate,ServerRequestFinishedProtocol>{
    ServerRequestType1 currentRequestType;
    NSInteger statusResponse;
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    NSString*userPic;                   // Store user Profile pic when we are login
}
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (nonatomic,strong)NSString *welcomeMsg;
@property (nonatomic) BOOL checkforUser;

@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property(nonatomic,strong)  NSMutableArray*frndListArr;

//DB
@property (nonatomic,strong) DBManager *dbManager;


@end
