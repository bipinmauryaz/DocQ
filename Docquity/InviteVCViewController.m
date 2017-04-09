//
//  InviteVCViewController.m
//  Docquity
//
//  Created by Gaurav Pandey on 05/04/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "InviteVCViewController.h"
@import FirebaseAuth;
@import GoogleSignIn;
@import FirebaseInvites;


@interface InviteVCViewController ()<GIDSignInUIDelegate,FIRInviteDelegate>
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

- (IBAction)btn_invite:(id)sender;


@end

@implementation InviteVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_invite:(id)sender {
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
    
    // Title for the dialog, this is what the user sees before sending the invites.
    [inviteDialog setTitle:@"Invites Example"];
    [inviteDialog setDeepLink:@"https://itunes.apple.com/us/app/docquity/id1048947290?mt=8"];
    [inviteDialog setCallToActionText:@"Install!"];
    [inviteDialog setCustomImage:@"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"];
    [inviteDialog open];
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

//    }

@end
