/*============================================================================
 PROJECT: Docquity
 FILE:    MailActivity.h
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 09/07/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

extern NSString *const UIActivityTypeMailCustom;

/*============================================================================
 Interface:   MailActivity
 =============================================================================*/
@interface MailActivity : UIActivity <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) MFMailComposeViewController *mMailComposer;
@end
