/*============================================================================
 PROJECT:  MyApplication.h
 FILE:    textviewLinkDetectorViewController.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 07/03/16.
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface MyApplication : UIApplication
-(BOOL)openURL:(NSURL *)url;

-(BOOL)openURL:(NSURL *)url forceOpenInSafari:(BOOL)forceOpenInSafari;
@end
