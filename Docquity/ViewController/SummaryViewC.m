//
//  SummaryViewC.m
//  Docquity
//
//  Created by Arimardan Singh on 15/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "SummaryViewC.h"
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"

@implementation SummaryViewC
@synthesize placeholderLabel,txtvw_summary,summary;
@synthesize delegate,data;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ((summary==0) || [summary isEqualToString:@""]){
        headerLabel.text = @"Add Summary";
    }
    else{
        headerLabel.text = @"Edit Summary";
        
        self.txtvw_summary.text  = [self.data.bio stringByDecodingHTMLEntities];
    }
    //Registering Touch event on scroll
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    [txtvw_summary becomeFirstResponder];
    self.txtvw_summary.inputAccessoryView = self.keybAccessory;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - back
-(IBAction)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (isback==YES) {
        NSUserDefaults*userdef = [NSUserDefaults standardUserDefaults];
        [self.delegate EditProfileViewCallWithCustomid:[userdef objectForKey:custId] update_summary:txtvw_summary.text];
    }
}

#pragma mark - save Button Action
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
    if ((self.txtvw_summary.text.length==0) || [self.txtvw_summary.text isEqualToString:@""])
    {
        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"" message:@"Field can not be empty." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
        [alt show];
    }
    
    if([self.txtvw_summary.text isEqualToString:summary]){
        
        [self.navigationController popViewControllerAnimated:YES];
        //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please change something to update." delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
        //
        //        [alert show];
    }
    else
    {
        [self updateSummarydata];
    }
}

#pragma mark - TextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    placeholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![self.txtvw_summary hasText]) {
        //placeholderLabel.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    placeholderLabel.hidden = YES;
}

#pragma mark - Done Button Action
- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

#pragma mark - update profile summary/bio api calling
-(void)updateSummarydata{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* result =[txtvw_summary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[DocquityServerEngine sharedInstance]SetBiographyRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] bio:result  format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                isback = YES;
               [self.navigationController popViewControllerAnimated:YES];
               }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                // [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //NSUInteger length = self.msgTV.text.length - range.length + text.length;
    if([textView.text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}@end
