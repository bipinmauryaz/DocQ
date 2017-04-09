/*============================================================================
 PROJECT: Docquity
 FILE:    MailActivity.m
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 09/07/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "MailActivity.h"

NSString *const UIActivityTypeMailCustom = @"customMailActivity";
@implementation MailActivity

- (id)init
{
    self = [super init];
    if (self) {
        self.mMailComposer = [[MFMailComposeViewController alloc] init];
    }
    return self;
}

-(NSString *)activityType{
    return UIActivityTypeMailCustom;
}

-(NSString *)activityTitle{
    return @"Mail";
}

-(UIImage *)activityImage{
    return [UIImage imageNamed:@"mail"];
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    if ([MFMailComposeViewController canSendMail]) {
        return YES;
    }else{
        return NO;
    }
}

-(UIViewController *)activityViewController{
    
    self.mMailComposer.mailComposeDelegate = self;
    
    self.mMailComposer.navigationBar.barStyle = UIBarStyleBlack;
    return self.mMailComposer;
}

#pragma mark MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    BOOL didFinishSuccessfully = NO;
    switch (result) {
        case MFMailComposeResultSaved:
        case MFMailComposeResultSent:
            didFinishSuccessfully = YES;
            break;
        default:
            break;
    }
    
    [self activityDidFinish:didFinishSuccessfully];
}
@end
