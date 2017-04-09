/*============================================================================
 PROJECT: Docquity
 FILE:    SSCWhatsAppActivity.h
 AUTHOR:  Copyright © 2016 Docquity. All rights reserved.
 DATE:    Created by Arimardan Singh on 19/04/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>

extern NSString * const SSCActivityTypePostToWhatsApp;

/*============================================================================
 Interface: SSCWhatsAppActivity
 =============================================================================*/
@interface SSCWhatsAppActivity : UIActivity

- (instancetype)initWithTextPreferred:(BOOL)preferText;

@end
