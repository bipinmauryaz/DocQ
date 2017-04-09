/*============================================================================
 PROJECT: Docquity
 FILE:    UIViewController+navigationBar.m
 AUTHOR:  Copyright © 2017 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 19/03/17.
 =============================================================================*/

#import "UIViewController+navigationBar.h"
#import "AppDelegate.h"

@implementation UIViewController (navigationBar)

-(void)customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:(NSString *)title{
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]
//     ];
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.title = title;
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbarback@2x.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(btnBackClicked:)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"newhelp.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;

//Code for add slideButton
//    UIButton *backButton= [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
//    [backButton setBackgroundImage:[UIImage imageNamed:@"navbarback@2x.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    
//    self.navigationItem.leftBarButtonItem = backButton;

    //Code for add header logo image
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeaderIcon]];
    
    //JIRA Task iOS/IOS-31
    //Setting icon will appear on top right hand side on contact feed screen.
//    UIButton *iconSettings = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
//    [iconSettings setBackgroundImage:[UIImage imageNamed:kSettingsIcon] forState:UIControlStateNormal];
//    [iconSettings addTarget:self action:@selector(methodSettings:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconSettings];
//    
//    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

-(void)customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:(NSString *)title{
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.title = title;
    if ([title isEqualToString:@"Profile Picture"]) {
        
    }
   else if ([title isEqualToString:@"Proof of Identity"])
   {
        
   }
   else{
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbarback@2x.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(btnBackClicked:)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
   }
}

-(void)customizeNavigationBarWithHeaderLogoImageAndBackCheckBarButtonItems:(NSString*)title{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0]
    //     ];
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
    }
 
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.title = title;
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbarback@2x.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backViewFromOTP)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"newhelp.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
}

-(void)customizeNavigationBarWithHeaderLogoImageAndBackCheckFromOtherBarButtonItems:(NSString*)title {    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
}
    
[self.navigationController setNavigationBarHidden:NO animated:YES];
self.navigationItem.hidesBackButton =YES;
self.navigationItem.title = title;
UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbarback@2x.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backViewFromOther)];
[self.navigationItem setLeftBarButtonItem:barButtonItem];
}

#pragma mark - btnBackClicked
-(void)btnBackClicked:(UIButton *)sender{
   [self.navigationController popViewControllerAnimated:YES];
}

-(void)backViewFromOTP{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Number?" message:@"Are you sure you want to go back?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)backViewFromOther{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:backConfirmationTitle  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Mail Services sent
-(void)openMail{
    if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email." buttonTitle:OK_STRING];
        return;
        /*
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kMailTitle  message:kMailMsg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
         */
        return;
    }
    else{
         MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[SupportEmail]];
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
     // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)customizeNavigationBarWithHeaderLogoImage{

//    self.navigationItem.hidesBackButton =NO;
//    self.navigationController.navigationBar.topItem.title = @" ";
//    self.navigationController.navigationBar.backItem.title = @" ";
//    UIImage *backButtonImage = [[UIImage imageNamed:@"navbarback@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    self.navigationController.navigationBar.backIndicatorImage = backButtonImage;
//    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeaderIcon]];
//    
//  }
//
//-(void)customizeNavigationBarWithHeaderLogoImageOnly{
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationController.navigationBar.topItem.title = @"";
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeaderIcon]];
//}

//-(void)customizeNavigationBarWithCancel{
//    self.navigationItem.hidesBackButton =YES;
//    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeaderIcon]];
//    
//    //JIRA Task iOS/IOS-31
//    //Setting icon will appear on top right hand side on contact feed screen.
//    UIButton *iconSettings = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
//    [iconSettings setTitle:@"X" forState:UIControlStateNormal];
//    [iconSettings setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [iconSettings addTarget:self action:@selector(btnCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconSettings];
//    
//    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
//}
//

//-(IBAction)methodHomeButtonPress:(id)sender{
//    
//    SideMenuController *settingView = [self.storyboard instantiateViewControllerWithIdentifier:@"sideMenu"];
//    
//    [[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController.view endEditing:true];
//    
//    [[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController addChildViewController:settingView];
//    
////    [settingView didMoveToParentViewController:[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController];
//    
//    [[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController.view addSubview:settingView.view];
//
//    [settingView.view setFrame:CGRectMake(-(self.view.bounds.size.width), 0,self.view.bounds.size.width,self.view.bounds.size.height)];
//    
//    [UIView animateWithDuration:.5 animations:^{
//        [settingView.view setFrame:CGRectMake(0, 0,self.view.bounds.size.width,self.view.bounds.size.height)];
//        
//    }completion:^(BOOL finished) {
//        [settingView didMoveToParentViewController:[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController];
//
//    } ];
//}
//
//-(void)btnCancelClicked:(id)sender{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}
//
//
//-(IBAction)methodSettings:(id)sender{
//    
//    //JIRA Task iOS/IOS-26
//    //The top right icon should be a cog (or gear)
//    //Also, when the gear is clicked, a menu should appear from the bottom that is a standard menu like the Twitter screenshot I attached with two options "Sign out" and "Cancel".
//    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:kSettings message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    [actionSheet addAction:[UIAlertAction actionWithTitle:kCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//        // Cancel button tappped.
//        [self dismissViewControllerAnimated:YES completion:^{
//        }];
//    }]];
//    
//    [actionSheet addAction:[UIAlertAction actionWithTitle:kSignout style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//        [self removeKeyChain];
//        [self dismissViewControllerAnimated:YES completion:^{
//            
//        }];
//    }]];
//    
//    [self presentViewController:actionSheet animated:YES completion:nil];
//    
//}

//-(void)removeKeyChain{
//    NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
//                                (__bridge id)kSecClassInternetPassword,
//                                (__bridge id)kSecClassCertificate,
//                                (__bridge id)kSecClassKey,
//                                (__bridge id)kSecClassIdentity];
//    for (id secItemClass in secItemClasses) {
//        NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
//        SecItemDelete((__bridge CFDictionaryRef)spec);
//    }
//    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    [[NSNotificationCenter defaultCenter]postNotificationName:kLogOutNotification object:self];
//}
//

-(void)callingGoogleAnalyticFunction:(NSString *)screenName screenAction:(NSString *)actionName
{
    
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:screenName
                                                          action:actionName
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:@"&uid"
           value:[userpref valueForKey:@"kAppTrackId"]];
  
}

-(void)callingGoogleAnalyticFunctionWithOutTrackerId:(NSString *)screenName screenAction:(NSString *)actionName
{
    /*
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:screenName
                                                          action:actionName
                                                           label:nil
                                                           value:nil] build]];
     */
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
