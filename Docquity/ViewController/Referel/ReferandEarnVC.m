//
//  ReferandEarnVC.m

//  Docquity
//
//  Created by Arimardan Singh on 06/04/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "ReferandEarnVC.h"
#import "MailActivity.h"
#import "SSCWhatsAppActivity.h"
#import "APActivityProvider.h"
#import "NSString+HTML.h"
@import FirebaseAuth;
@import GoogleSignIn;
@import FirebaseInvites;
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
@interface ReferandEarnVC ()<GIDSignInUIDelegate,FIRInviteDelegate>
{
    
}

- (IBAction)btn_invite:(id)sender;
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *termLblHTConst;
@property (weak, nonatomic) IBOutlet UILabel *termLbl;
@end

@implementation ReferandEarnVC

- (void)viewDidLoad
{
   [super viewDidLoad];
    [self serviceHitForGetReferelContentRequest];
    
    // Do any additional setup after loading the view.
//    NSString *str=[NSString stringWithFormat:@"\u2022 %@\n\n\n\u2022 %@\n\n\n\u2022 %@",@"Use chapstick. Swipe some over your lips and press them together. (If you're a girl and you have flavored chapstick, all the better!) The only caveat is that you should apply lip balm or gloss an hour or more before you kiss, so your kissing partner feels your soft lips, not the thick layer of gloss over them.",@"Drink water. Dry lips are a sign of dehydration, so throw back a tall glass of water (or two). You should notice your lips starting to smooth out within 20 to 30 minutes.",@"Drink water. Dry lips are a sign of dehydration, so throw back a tall glass of water (or two). You should notice your lips starting to smooth out within 20 to 30 minutes."];
    self.navigationController.navigationBarHidden=YES;

    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        // [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        self.navigationItem.title = @"Refer and Earn";
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        
        // [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"button.png"] forBarMetrics:UIBarMetricsDefault];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
       // NSString*totalPoints  = [NSString stringWithFormat:@"%@ Points",user_totalPoints];
        pointsButton=[[UIBarButtonItem alloc]initWithTitle:@"130 Points" style:UIBarButtonItemStylePlain target:self action:nil
                      ];
         // [send setEnabled:false];
        self.navigationItem.rightBarButtonItem = pointsButton;
        //  [self textViewDidChange:self.tvReportText];
        [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                          [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                          [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    });
   }
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
 
    //[self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Refer and Earn"];
    // self.navigationController.navigationBarHidden=YES;
  /*
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_main_queue(), ^{
       // [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        self.navigationItem.title = @"Refer and Earn";
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        
        //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"button.png"] forBarMetrics:UIBarMetricsDefault];
        
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
    NSString*totalPoints  = [NSString stringWithFormat:@"%@ Points",user_totalPoints];
    pointsButton=[[UIBarButtonItem alloc]initWithTitle:totalPoints style:UIBarButtonItemStylePlain target:self action:nil
                  ];
    // [send setEnabled:false];
    self.navigationItem.rightBarButtonItem = pointsButton;
  //  [self textViewDidChange:self.tvReportText];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
 });

//   [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                                          [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
//                                                                          [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
        
   // });
   */
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_invite:(id)sender {
    //[Localytics tagEvent:@"Referel Invite Click"];
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
        [self generateWhatsappActivity];
    }
    /*
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
    
    id<FIRInviteBuilder> inviteDialog = [FIRInvites inviteDialog];
    [inviteDialog setInviteDelegate:self];
    
    // NOTE: You must have the App Store ID set in your developer console project
    // in order for invitations to successfully be sent.
    NSString *message =
    [NSString stringWithFormat:@"Try this out!\n -%@",
     [GIDSignIn sharedInstance].currentUser.profile.name];
    
    // A message hint for the dialog. Note this manifests differently depending on the
    // received invitation type. For example, in an email invite this appears as the subject.
    [inviteDialog setMessage:message];
    
    //Title for the dialog, this is what the user sees before sending the invites.
    [inviteDialog setTitle:@"Invite your Friends"];
    [inviteDialog setDeepLink:@"https://itunes.apple.com/us/app/docquity/id1048947290?mt=8"];
    [inviteDialog setCallToActionText:@"Install!"];
    [inviteDialog setCustomImage:@"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"];
    [inviteDialog open];
     */

    //    [[FIRAuth auth] signInWithCredential:credential
    //                              completion:^(FIRUser *user, NSError *error) {
    //                                  // ...
    //                                  if (error) {
    //                                      // ...
    //                                      return;
    //                                  }
    //
    //                              }
    
}

#pragma mark - whatshapp Activity Controller
- (SSCWhatsAppActivity *)generateWhatsappActivity
{
    MailActivity *mailActivity = [self generateMailActiviy];
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
    NSString *stringToShare = @"Just joined Docquity – an exclusive doctor’s only network. Download & connect with me at";
    
    UIActivityViewController *  activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[stringToShare, ActivityProvider] applicationActivities:@[whatsAppActivity,mailActivity]];
    
    activityViewController.excludedActivityTypes =@[UIActivityTypePostToWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeMail,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToFlickr];
    [self presentActivityController:activityViewController];
    return whatsAppActivity;
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    };
}

- (MailActivity *) generateMailActiviy
{
    MailActivity *mailAct = [[MailActivity alloc] init];
    //Preparing vairous values for mail
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"] ;
    NSString*share = @"Hi,";
    NSString*shareText = @"I just joined Docquity – A Private & Secure Doctor’s only Professional Network. I think this will be useful for you also to join the network and connect with trusted doctors and peers on the network. This is an invite only network and I wanted to recommend you to join the network. We can keep our information secure, private and have discussions around cases. The What’s Trending feature is a good way to quickly be updated on cases, developments and advances in our field. Download Docquity from";
    
   // NSString* urlreflink= [NSString stringWithFormat:@"%@/mail",referlink];
    NSString* urlreflink= [NSString stringWithFormat:@"%@",referlink];
    NSString*sharetext = @"and lets connect on the network. Join me!";
    NSURL *shareUrl = [NSURL URLWithString:urlreflink];
    [emailBody appendString:[NSString stringWithFormat:@"%@<br><br>%@<br><br>%@<br><br>%@",share,shareText,shareUrl,sharetext,nil]];
    NSString *subject = @"Joined Docquity";
    MFMailComposeViewController *mailComposer = mailAct.mMailComposer;
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:emailBody isHTML:YES];
    return mailAct;
}

-(void) showSuccessToastWithMsg:(NSString *) msg{
    [SVProgressHUD showSuccessWithStatus:msg];
}

#pragma mark - Service GetReferelContentRequest
-(void)serviceHitForGetReferelContentRequest{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@registration/get.php?rquest=referal_content&version=%@&iso_code=%@&device_type=%@&app_version=%@&lang=%@",NewWebUrl,kApiVersion,@"",kDeviceType,kAppVersion,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
         if (response) {
             [SVProgressHUD dismiss];
             NSError *errorJson=nil;
             NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
              if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 1)
             {
                NSMutableDictionary *datadic = [responseDict valueForKeyPath:@"posts.data"];
                 referlink = [[[datadic valueForKey:@"referal_link"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
                NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
                [userpref setObject:referlink forKey:@"InvitereferelLink"];
                [userpref synchronize];
                referlMsg = [[[datadic valueForKey:@"referal_msg"]stringByStrippingTags]stringByDecodingHTMLEntities];
                referlTc = [[[datadic valueForKey:@"referal_tc"]stringByDecodingHTMLEntities]stringByStrippingTags];
  
                 user_totalPoints = [datadic valueForKey:@"total_point"];
                  lbl_msgreferel.text = [NSString stringWithFormat:@"%@",referlMsg];
                 NSString *str=[NSString stringWithFormat:@"%@",referlTc];
                   _termLbl.numberOfLines = 0;
                 CGSize size = CGSizeMake(SCREENWIDTH-60,9999);
                 CGRect langStrtextRect = [str
                                           boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:_termLbl.font}
                                           context:nil];
                 _termLbl.text=str;
                _termLblHTConst.constant = langStrtextRect.size.height+10;
             }
             if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 0)
             {
                 [WebServiceCall showAlert:AppName andMessage:[responseDict valueForKeyPath:@"posts.msg"] withController:self];
             }
             else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 9)
             {
                 [[AppDelegate appDelegate]logOut];
             }
         }
         else if (error){
             [SVProgressHUD dismiss];
             [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
             NSLog(@"%@",error);
         }
     }];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden=NO;
    
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
