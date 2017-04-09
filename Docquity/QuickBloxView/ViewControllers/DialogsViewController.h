//
//  SecondViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
@interface DialogsViewController : UIViewController
{
    NSString *selectedFStatus;
    NSInteger totalUnread;
    NSInteger pageOffset;
    NSInteger limit;
}
@property (strong, nonatomic) QBChatDialog *createdDialog;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIView *view_noConversation;

@property (weak, nonatomic) IBOutlet UIButton *btn_startConv;
@property (nonatomic,strong) DBManager *dbManager;
@property (strong, nonatomic)NSArray *dialogInfo;
@property (strong, nonatomic)NSArray *connectionInfo;
@end
