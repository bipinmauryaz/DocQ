/*============================================================================
 PROJECT: Docquity
 FILE:    AddInterestVC.m
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/05/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "AddInterestVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"

/*============================================================================
 Interface: AddInterestVC
 =============================================================================*/

@interface AddInterestVC ()
- (void) endEditing;
@end

@implementation AddInterestVC
@synthesize addIntTF;
@synthesize myToolbar,keybAccessory;
@synthesize scroll,scvwContentView;
@synthesize isSaveBtnClicked;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Registering Touch event on scroll
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    addIntTF.inputAccessoryView = self.keybAccessory;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scroll.contentSize=self.scvwContentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - Save&AddMoreButtonAction
-(IBAction)saveAndMoreBtn:(id)sender{
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    isSaveBtnClicked = NO;
    if ((self.addIntTF.text.length==0) || [self.addIntTF.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Field can not be empty." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSString *trimmedString = [self.addIntTF.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@""]) {
            [self setCreateInterestRequest:self.addIntTF.text];        }
    }
}

#pragma mark - backButtonAction
-(IBAction)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - saveButtonAction
-(IBAction)saveBtn:(id)sender{
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    isSaveBtnClicked = YES;
    if ((self.addIntTF.text.length==0) || [self.addIntTF.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Field can not be empty." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        NSString *trimmedString = [self.addIntTF.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@""]) {
            [self setCreateInterestRequest:self.addIntTF.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

#pragma mark - create interest api calling
-(void)setCreateInterestRequest:(NSString *)InterstTitle {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetCreateInterestRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] interest_name:InterstTitle format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                if (isSaveBtnClicked){
                    //Profile Tab Config
                    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                    NSString *custmId=[userpref objectForKey:ownerCustId];
                    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                    NewProfile .custid=  custmId;
                    NewProfile.hidesBottomBarWhenPushed = YES;
                    [AppDelegate appDelegate].isComeFromSettingVC = NO;
                    [self.navigationController pushViewController:NewProfile animated:YES];
                }
                else{
                    self.addIntTF.text = @"";
                }
             } else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
