/*============================================================================
 PROJECT: Docquity
 FILE:    InviteAllVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 15/07/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "Server.h"

/*============================================================================
 Interface: InviteAllVC
 =============================================================================*/
@interface InviteAllVC : UIViewController<UITableViewDelegate, UITableViewDataSource,MGSwipeTableCellDelegate,ServerRequestFinishedProtocol>{
    
    //web services request enum type
    ServerRequestType1 currentRequestType;
    NSMutableArray *indexArray;
    NSString *InviteStr;
}

@property(nonatomic,strong)NSDictionary *inviteDic;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *inviteListArr;
@property (strong, nonatomic) IBOutlet UIView *viewThanks;
@property (nonatomic, weak) UIButton *btnInvite;;
@property (strong, nonatomic) IBOutlet UIButton *btnInviteAll;

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressInviteAll:(id)sender;
- (IBAction)inviteBtnClicked:(UIButton*)sender event:(id)event;

@end
