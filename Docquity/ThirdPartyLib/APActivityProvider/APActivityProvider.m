//
//  APActivityProvider.m
//  Docquity
//
//  Created by Arimardan Singh on 15/07/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "APActivityProvider.h"
#import "DefineAndConstants.h"
 #import "SSCWhatsAppActivity.h"

@implementation APActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    NSUserDefaults*userpref = [NSUserDefaults standardUserDefaults];
    NSString*urlreflink=[userpref objectForKey:@"InvitereferelLink"];
    [userpref synchronize];
    NSURL *urlToShare;
  
    //Add activityType for Twitter
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] ){
        //urlreflink = [NSString stringWithFormat:@"%@/twitter",urlreflink];
        urlreflink = [NSString stringWithFormat:@"%@",urlreflink];
        urlToShare = [NSURL URLWithString:urlreflink];
        return  urlToShare;
    }
    
    //Add activityType for Facebook
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ){
       // urlreflink = [NSString stringWithFormat:@"%@/fb",urlreflink];
         urlreflink = [NSString stringWithFormat:@"%@",urlreflink];
        urlToShare = [NSURL URLWithString:urlreflink];
        return  urlToShare;
    }
    
    //Add activityType for Message
    if ( [activityType isEqualToString:UIActivityTypeMessage] ){
        //urlreflink = [NSString stringWithFormat:@"%@/sms",urlreflink];
        urlreflink = [NSString stringWithFormat:@"%@",urlreflink];
       urlToShare = [NSURL URLWithString:urlreflink];
       return  urlToShare;
    }
    
    //Add activityType for contact
    if ( [activityType isEqualToString:UIActivityTypeAssignToContact] ){
        //urlreflink = [NSString stringWithFormat:@"%@/contact",urlreflink];
        urlreflink = [NSString stringWithFormat:@"%@",urlreflink];
        urlToShare = [NSURL URLWithString:urlreflink];
        return  urlToShare;
    }
    
    //Add activityType for Whatsapp
    else{
       // urlreflink = [NSString stringWithFormat:@"%@/whatsapp",urlreflink];
        urlreflink = [NSString stringWithFormat:@"%@",urlreflink];
        urlToShare = [NSURL URLWithString:urlreflink];
        return  urlToShare;
    }
    return nil;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end
