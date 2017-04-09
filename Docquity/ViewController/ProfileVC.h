/*============================================================================
 PROJECT: Docquity
 FILE:    ProfileVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 22/04/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "Server.h"
#import "DBManager.h"
#import "XMPP.h"
#import "TURNSocket.h"
#import "XMPPSIFileTransfer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@protocol sliderImgUpdate <NSObject>
-(void)imageupdateforSlider;
-(void)nameupdateforSlider;

@end

/*============================================================================
 Interface: ProfileVC
 =============================================================================*/
@interface ProfileVC : UIViewController<UIScrollViewDelegate,UITextViewDelegate,ServerRequestFinishedProtocol>
{
    //web services request enum type
    ServerRequestType1 currentRequestType;
    NSInteger flg, indexnum; // index of flg
    NSMutableArray *editdatainfo; // edit info
    NSString *failedSelector;
    
    //data base
    NSArray *result; // result Array
    NSMutableArray *DataSource;
    NSMutableArray *resultArray;
    NSMutableString  *dataPath;
    NSString*summary;
    BOOL isConnectionSendRequest;
 }

@property(nonatomic,strong)  NSMutableArray*frndListArr;
@property (nonatomic,assign)id delegate;
@property (nonatomic,strong) DBManager *dbManager;
@property(nonatomic,strong) NSString*u_jabId;
@property(nonatomic,strong) NSString*customUserId;
@property(nonatomic,strong) NSDictionary *profileDetailDic;
@property(nonatomic, strong)NSString *docname;
@property(nonatomic, strong)NSString *docLoc;
@property(nonatomic, strong)NSString *docSkillsSet;
@property(nonatomic)BOOL isbackFromSaveMore;
@property (nonatomic, strong)NSMutableArray *NEWARRAYDATA;
@property (nonatomic, strong)NSMutableArray *commentArr;
@property (nonatomic)NSInteger ab;
@property (nonatomic)NSInteger bc;

@end
