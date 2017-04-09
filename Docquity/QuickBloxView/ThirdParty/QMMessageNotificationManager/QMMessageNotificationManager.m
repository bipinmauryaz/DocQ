//
//  QMMessageNotificationManager.m
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotificationManager.h"
#import "QMMessageNotification.h"
#import "UIImage+additions.h"
#import "Utils.h"

@implementation QMMessageNotificationManager

#pragma mark - Message notification

+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage {
    
    [messageNotification() showNotificationWithTitle:title
                                            subtitle:subtitle
                                               color:color
                                           iconImage:iconImage];
}

+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                             type:(QMMessageNotificationType)type {

    UIImage *iconImage = nil;
    UIColor * backgroundColor = [UIColor redColor];
    
    switch (type) {
        case QMMessageNotificationTypeInfo: {
            
            iconImage = [UIImage imageNamed:@"icon-29"]; //icon-info // Change By Ari
            backgroundColor =  [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:6.0f];
            //[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
           
            //[UIImage imageNamed:@"icon-29.png"];
            [iconImage makeRoundCornersWithRadius:8.0];
            
           //
            break;
        }
        case QMMessageNotificationTypeWarning: {
            
            iconImage = [UIImage imageNamed:@"icon-error"];
            backgroundColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0];
            break;
        }
        case QMMessageNotificationTypeError: {
            iconImage = [UIImage imageNamed:@"icon-error"];
            backgroundColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0];
            
            break;
        }
        default:
            break;
    }
    if (!title) {
        title = @"";
    }
    if (!subtitle) {
        subtitle = @"\U0001f4f7 photo";
    }
    // user custom qb notification show while app was in forground or active state
    if ([[UIApplication sharedApplication] applicationState]  == UIApplicationStateActive) {
     [self showNotificationWithTitle:title
                           subtitle:subtitle
                              color:backgroundColor
                          iconImage:iconImage];
        [Utils playClick2Sound];
    }
}

+ (void)oneByOneModeSetEnabled:(BOOL)enabled {
    messageNotification().oneByOneMode = enabled;
}

#pragma mark - Static notifications
QMMessageNotification *messageNotification() {
    static QMMessageNotification *messageNotification = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        messageNotification = [[QMMessageNotification alloc] init];
    });
    return messageNotification;
}

@end
