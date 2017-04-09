/*============================================================================
 PROJECT: Docquity
 FILE:    SplashScreenViewController.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd  on 10/04/15.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "SplashScreenViewController.h"
#import "AppDelegate.h"
#import "DefineAndConstants.h"
#import "FeedVC.h"
#import "MobileVerifyVC.h"
#import "NewHomeVC.h"

/*============================================================================
 Interface:   SplashScreenViewController
 =============================================================================*/
@interface SplashScreenViewController ()
{
    
}
@end
@implementation SplashScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden=YES;
    //[self.activityIndicator startAnimating];
    [self performSelector:@selector(navigatetohomeview) withObject:nil afterDelay:2.0];
}

#pragma mark - navigate to home screen
-(void)navigatetohomeview
{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    BOOL isfirsttimelogin=[userpref boolForKey:@"firstTimeLogin"];
    BOOL AlreadysignIn=[userpref boolForKey:signInnormal];//already loggedin
    if(!isfirsttimelogin)
    {
        self.navigationController.navigationBar.hidden = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
        NewHomeVC *selfReg = [storyboard instantiateViewControllerWithIdentifier:@"NewHomeVC"];
        [userpref setBool:YES forKey:@"firstTimeLogin"];
        [self.navigationController pushViewController:selfReg animated:YES];
    }
    else if (AlreadysignIn)
    {
        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
        if([userdef valueForKey:signInnormal]){
            [[AppDelegate appDelegate] navigateToTabBarScren:0];
            [[AppDelegate appDelegate] ShowPopupScreen];
        }else{
            [[AppDelegate appDelegate] navigateToTabBarScren:0];
        }
    }
    else
    {
        self.navigationController.navigationBar.hidden = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
        NewHomeVC *selfReg = [storyboard instantiateViewControllerWithIdentifier:@"NewHomeVC"];
        [userpref setBool:YES forKey:@"firstTimeLogin"];
        [self.navigationController pushViewController:selfReg animated:YES];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
