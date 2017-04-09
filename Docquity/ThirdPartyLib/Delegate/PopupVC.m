/*============================================================================
 PROJECT: Docquity
 FILE:    PopupVC.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 11/06/16.
 =============================================================================*/

#import "PopupVC.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "InviteAllVC.h"
#import "Localytics.h"

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface PopupVC (){
    int value;
}
@end

@implementation PopupVC
@synthesize resposeCode;
@synthesize inviteArr;
- (void)viewDidLoad {
    [super viewDidLoad];
    if([[self.dataDic valueForKey:@"skip"]integerValue]==1) {
        self.btnCancel.hidden = false;
    }
    else{
        self.btnCancel.hidden = true;
    }
    self.lblTitle.text = [self.dataDic valueForKey:@"title"];
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblDesc.text = [self.dataDic valueForKey:@"content"];
    self.lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *bgcolor = [self.dataDic valueForKey:@"background_color"];
    bgcolor = [bgcolor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    self.view.backgroundColor = [self colorWithHexString:bgcolor];
    
    NSString *txtcolor = [self.dataDic valueForKey:@"text_color"];
    txtcolor = [txtcolor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    self.lblDesc.textColor = [self colorWithHexString:txtcolor];
    [self reframeOfLabels];
    [self.btnAction setTitleColor:[self colorWithHexString:bgcolor] forState:UIControlStateNormal];
    [self.imgSub sd_setImageWithURL:[NSURL URLWithString:[self.dataDic valueForKey:@"image"]] placeholderImage:nil];
    
    if([[self.dataDic objectForKey:@"button_name"]isEqualToString:@""]){
        self.btnAction.hidden = true;
        CGRect frame = self.lblTitle.frame;
        frame.origin.y = (self.centerView.frame.size.height-frame.size.height)/2;
        self.lblTitle.frame = frame;
        
        self.imgWithDescription.hidden = TRUE;
        self.centerView.hidden = FALSE;
        self.btnActionForBigImg.hidden = TRUE;
        self.imgSub.hidden = FALSE;
    }else{
        if([[self.dataDic valueForKey:@"title"]isEqualToString:@""]){
            self.imgWithDescription.hidden = false;
            self.centerView.hidden = YES;
            self.lblDesc.hidden = false;
            self.btnActionForBigImg.hidden = false;
            self.imgSub.hidden = YES;
            [self.imgWithDescription sd_setImageWithURL:[NSURL URLWithString:[self.dataDic valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"splashscreelogo.png"]
                                                options:SDWebImageRefreshCached];

            [self.btnActionForBigImg setTitle:[self.dataDic valueForKey:@"button_name"] forState:UIControlStateNormal];
            [self.btnActionForBigImg setTitleColor:[self colorWithHexString:bgcolor] forState:UIControlStateNormal];
            CGRect frame = self.lblDesc.frame;
            frame.origin.y = self.imgWithDescription.frame.size.height + self.imgWithDescription.frame.origin.y +15;
            frame.size.height = self.btnActionForBigImg.frame.origin.y - frame.origin.y-8;
            self.lblDesc.frame = frame;
        }
        else{
            [self.btnAction setTitle:[self.dataDic valueForKey:@"button_name"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - reframe of Label
-(void)reframeOfLabels{
    CGRect frame = self.lblTitle.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width-(frame.origin.x*2);
    self.lblTitle.frame = frame;
    frame = self.lblDesc.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width-(frame.origin.x*2);
    self.lblDesc.frame = frame;
    self.lblTitle.textAlignment= NSTextAlignmentCenter;
    self.lblDesc.textAlignment= NSTextAlignmentCenter;
    // NSLog(@"data dic = %@",self.dataDic);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - ActionBtnClick
- (IBAction)didPressActionBtn:(id)sender {
    if([[self.dataDic valueForKey:@"action"]isEqualToString:@"update"]){
        [Localytics tagEvent:@"Popup UpdateButton Click"];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://apple.co/1TJwLM6"]];
    }
   
    if([[self.dataDic valueForKey:@"action"]isEqualToString:@"CME"]){
        [Localytics tagEvent:@"Popup CME Button Click"];
        [[AppDelegate appDelegate] navigateToTabBarScren:1];
        [self timeIntveral];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - cancelBtnClick
- (IBAction)didPressCancelBtn:(id)sender {
   if([[self.dataDic valueForKey:@"action"]isEqualToString:@"notification"]){
        [Localytics tagEvent:@"Popup NotificationCancelButton Click"];
        [self timeIntveral];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if([[self.dataDic valueForKey:@"action"]isEqualToString:@"CME"]){
        [Localytics tagEvent:@"Popup CMECancelButton Click"];
        [self timeIntveral];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - time Interval Saved in Record for App
-(void)timeIntveral{
    NSString*gntime = [self.dataDic valueForKey:@"time_interval"];
    NSDate* today = [NSDate date];
    NSString*  timeINMS = [NSString stringWithFormat:@"%lld", [@(floor([today timeIntervalSince1970] * 1000)) longLongValue]];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setObject:timeINMS ?timeINMS :@"" forKey:timeInMS];
    [userpref setObject: gntime?gntime :@"" forKey:gn_timeset];
    [userpref synchronize];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma webservices methods
- (void) serviceCalling  //GetInvitationRequest
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        //[[AppDelegate appDelegate] showIndicator];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetInvitationRequest], keyRequestType1,nil];
        Server *obj = [[Server alloc] init];
        currentRequestType = kGetInvitationRequest;
        obj.delegate = self;
        [obj sendRequestToServer:aDic withDataDic:nil];
        //NSLog(@"serviceCalling");
    }
}
#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    switch (currentRequestType)
    {
        case kGetInvitationRequest:
            [self getInviteMemberList:responseData];
            break;
        default:
            break;
    }
}

#pragma mark result methods for get Friend request
- (void)getInviteMemberList:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
    {
        // tel is null
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            UIViewController *theTrick = self.presentingViewController;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            InviteAllVC*inviteall = [storyboard instantiateViewControllerWithIdentifier:@"InviteAllVC"];
            inviteall.inviteDic = resposeCode;
            [self dismissViewControllerAnimated:NO completion:^{
                [theTrick presentViewController:inviteall animated:YES completion:nil];
            }];
        }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 7){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 9){
            // [[AppDelegate appDelegate] logOut];
        }
        else{
            // [UIAppDelegate alerMassegeWithError:message withButtonTitle:OK_STRING autoDismissFlag:NO];
            //  return;
        }
    }
}

- (void) requestError
{
    // NSLog(@"LoginViewController error");
    [[AppDelegate appDelegate] hideIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
