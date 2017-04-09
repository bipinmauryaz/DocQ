/*============================================================================
 PROJECT: Docquity
 FILE:    PopupVC.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 11/06/16.
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "Server.h"

@interface PopupVC : UIViewController<ServerRequestFinishedProtocol>{
    //web services request enum type
    ServerRequestType1 currentRequestType;
}

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIImageView *imgSub;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnAction;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;

- (IBAction)didPressActionBtn:(id)sender;
- (IBAction)didPressCancelBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic)NSMutableDictionary *dataDic;
@property (strong, nonatomic)   NSDictionary *resposeCode;
@property (strong, nonatomic)   NSMutableArray *inviteArr;
@property (strong, nonatomic) IBOutlet UIButton *btnActionForBigImg;
@property (strong, nonatomic) IBOutlet UIImageView *imgWithDescription;

@end
