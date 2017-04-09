/*============================================================================
 PROJECT: Docquity
 FILE:    UIViewController+navigationBar.h
 AUTHOR:  Copyright © 2017 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 19/03/17.
 =============================================================================*/

#import <UIKit/UIKit.h>
//#import "SideMenuController.h"

@interface UIViewController (navigationBar)<MFMailComposeViewControllerDelegate>
-(void)customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:(NSString*)title;
-(void)customizeNavigationBarWithHeaderLogoImageAndBackCheckBarButtonItems:(NSString*)title;
-(void)customizeNavigationBarWithHeaderLogoImageAndBackCheckFromOtherBarButtonItems:(NSString*)title;
-(void)customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:(NSString*)title;

//-(void)customizeNavigationBarWithHeaderLogoImage;
//-(void)customizeNavigationBarWithHeaderLogoImageOnly;
//-(void)customizeNavigationBarWithCancel;

-(void)callingGoogleAnalyticFunction:(NSString *)screenName screenAction:(NSString *)actionName;
-(void)callingGoogleAnalyticFunctionWithOutTrackerId:(NSString *)screenName screenAction:(NSString *)actionName;

@end
