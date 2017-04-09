/*============================================================================
 PROJECT: Docquity
 FILE:    NotificationView.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 07/12/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
@interface NotificationView : UIView
@property (nonatomic, strong) NSString *userjid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) NSInteger threadId;
@property (nonatomic, strong) NSString *message;

@end
