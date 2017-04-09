/*============================================================================
 PROJECT: Docquity
 FILE:    editCommentVC.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "editCommentVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "Localytics.h"
#import "DocquityServerEngine.h"
/*============================================================================
 Interface: editCommentVC
 =============================================================================*/
@interface editCommentVC ()
@end

@implementation editCommentVC
@synthesize BtnUpdate, ImgUser;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.ContentTV.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:222.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor ;
    self.ContentTV.layer.borderWidth = 1.0f;
    self.ContentTV.layer.cornerRadius= 3.0;
    [self UpdateBtnActivate:NO];
    self.ContentTV.text = self.commentText;
    self.ImgUser.image = [self getImage:@"MyProfileImage.png"];
    [self.ContentTV becomeFirstResponder];
    self.navTitle.text = [NSString stringWithFormat:@"Edit %@",self.Action];
}

#pragma mark - Post Btn Activate
-(void)UpdateBtnActivate:(BOOL)Active{
    if (Active) {
        BtnUpdate.enabled = true;
        [BtnUpdate setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else
    {
        BtnUpdate.enabled = false;
        [BtnUpdate setTitleColor:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    }
}

#pragma mark - didPressUpdate Btn Action
- (IBAction)didPressUpdate:(id)sender {
    [Localytics tagEvent:@"WhatsTrending EditCommentScreen UpdateCommentPost Click"];
    [self.view endEditing:YES];
    [self updateComment];
}

#pragma mark - didPressCancel Btn Action
- (IBAction)didPressCancel:(id)sender {
    [Localytics tagEvent:@"WhatsTrending EditCommentScreen CancelCommentPost Click"];
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)textViewDidChange:(UITextView *)textView{
     if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""]) {
        [self UpdateBtnActivate:NO];
    }else if (![textView.text isEqualToString:self.commentText]){
        [self UpdateBtnActivate:YES];
    }else{
        //NSLog (@"old text");
        [self UpdateBtnActivate:NO];
    }
}

- (UIImage*)getImage: (NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"Media"];
    NSString *getImagePath = [dataPath stringByAppendingPathComponent:filename];
  //  NSLog(@"Get image path: %@",getImagePath);
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    if (img == nil && img == NULL)
    {
        img = [UIImage imageNamed:@"avatar.png"];
        // NSLog(@"no underlying data");
    }
    return img;
}

#pragma web services methods for Delete Comment
- (void) updateComment
{
    [[AppDelegate appDelegate]showIndicator];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else if([self.Action isEqualToString:@"Comment"])
    {
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kEditCommentRequest], keyRequestType1, nil];
        NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:self.FeedID?self.FeedID:@"",feedID,self.commentID?self.commentID:@"",CommentID,self.ContentTV.text,feedComment,nil];
        Server *obj = [[Server alloc] init];
        currentRequestType = kEditCommentRequest;
        obj.delegate = self;
        [obj sendRequestToServer:aDic withDataDic:dataDic];
    }else if([self.Action isEqualToString:@"Reply"]){
        [self updateCommentReplyAction:@"edit" replyID:self.commentReplyID];
    }
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    switch (currentRequestType)
    {
        case kEditCommentRequest:
            [self performSelector:@selector(getEditCommentRequest:) withObject:responseData afterDelay:.000];
            break;
        default:
            break;
    }
}

#pragma mark getEditCommentResponse
- (void) getEditCommentRequest:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    // NSLog(@"Response for get edit comment = %@",response);
    NSDictionary *responseCode=[response objectForKey:@"posts"];
    if ([responseCode isKindOfClass:[NSNull class]] || responseCode == nil)
    {
        [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
    }
    else {
        // NSLog(@"%@",response);
        NSString *message=  [NSString stringWithFormat:@"%@",[responseCode objectForKey:@"msg"]?[responseCode objectForKey:@"msg"]:@""];
        if([[responseCode valueForKey:@"status"]integerValue] == 1){
            [self.delegate editComment:self.ContentTV.text feedComID:self.commentID];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if([[responseCode valueForKey:@"status"]integerValue] == 0){
            [UIAppDelegate alerMassegeWithError:message withButtonTitle:OK_STRING autoDismissFlag:NO];
        }
        else if([[responseCode valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
    }
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateCommentReplyAction:(NSString *)action replyID:(NSString*)comRepID{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* result =[_ContentTV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   [[DocquityServerEngine sharedInstance]feedactioncommentreplyRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.FeedID comment_id:self.commentID comment_reply_id:comRepID action:action reply:result device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
            [[AppDelegate appDelegate]hideIndicator];
            // NSLog(@"response from comment reply = %@",resposePost);
        }
        else {
            //  NSLog(@"response from comment reply edit = %@",resposePost);
             if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                [[AppDelegate appDelegate]hideIndicator];
                [self.delegate editCommentReplyText:self.ContentTV.text];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
             else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                [[AppDelegate appDelegate]hideIndicator];
                [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
              }
        }
    }];
}

@end
