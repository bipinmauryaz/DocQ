//
//  ChatViewController.h
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatViewController.h"
#import "DBManager.h"
@interface ChatViewController : QMChatViewController{
    NSInteger recepID;
    UIButton *blockChatBtn;
    UIButton *acceptChatBtn;
}
@property (nonatomic,strong) DBManager *dbManager;
@property (strong, nonatomic)NSArray *dialogInfo;
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) NSString *friendStatus;
@property (nonatomic, strong) NSString *oppCustid;
@end
