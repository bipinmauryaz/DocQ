//
//  RFRateMe.m
//  RFRateMeDemo
//
//  Created by Ricardo Funk on 1/2/14.
//  Copyright (c) 2014 Ricardo Funk. All rights reserved.
//

#import "RFRateMe.h"
#import "UIAlertView+NSCookbook.h"
#import "BrowserViewController.h"
#import "Localytics.h"
#define kNumberOfDaysUntilShowAgain 3
#define kAppStoreAddress @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1048947290"
#define kAppName @"Docquity"

@implementation RFRateMe

+(void)showRateAlert {
    //If rate was completed, we just return if True
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RFRateCompleted"];
    if (rateCompleted) return;
    //Check if the user asked not to be prompted again for 3 days (remind me later)
    BOOL remindMeLater = [[NSUserDefaults standardUserDefaults] boolForKey:@"RFRemindMeLater"];
    if (remindMeLater) {
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"RFStartDate"];
        NSString *end = [DateFormatter stringFromDate:[NSDate date]];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        if ((long)[components day] <= kNumberOfDaysUntilShowAgain) return;
     }
    
    //Show rate alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rate "kAppName, @"")
                                                        message:[NSString stringWithFormat:@"If you enjoy using %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!",kAppName]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"No, Thanks", @"")
                                              otherButtonTitles:NSLocalizedString(@"Rate It Now", @""),NSLocalizedString(@"Remind Me Later",@""), nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0:
                [Localytics tagEvent:@"Rate No"];
               // NSLog(@"No, thanks");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFRateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                 break;
            case 1:
                [Localytics tagEvent:@"Rate Yes"];
               // NSLog(@"Rate it now");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFRateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:kAppStoreAddress] forceOpenInSafari:YES];
                    break;
            case 2:
                [Localytics tagEvent:@"Rate Later"];
               // NSLog(@"Remind me later");
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"RFStartDate"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFRemindMeLater"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                break;
        }
    }];
}

+(void)showRateAlertAfterTimesOpened:(int)times {
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RFRateCompleted"];
    if (rateCompleted) return;
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger timesOpened = [defaults integerForKey:@"timesOpened"];
    [defaults setInteger:timesOpened+1 forKey:@"timesOpened"];
    [defaults synchronize];
   // NSLog(@"App has been opened %ld times", (long)[defaults integerForKey:@"timesOpened"]);
    if([defaults integerForKey:@"timesOpened"] >= times){
        [RFRateMe showRateAlert];
    }
}

+(void)showRateAlertAfterDays:(int)times {
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RFRateCompleted"];
    if (rateCompleted) return;
    BOOL showAfterXdays = [[NSUserDefaults standardUserDefaults] boolForKey:@"RFShowAfterXDays"];
    
    if (!showAfterXdays) {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *now = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"RFGeneralStartDate"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFShowAfterXDays"];
        [[NSUserDefaults standardUserDefaults] synchronize];
}
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd"];
     NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"RFGeneralStartDate"];
     NSString *end = [DateFormatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
     if ((long)[components day] <= times) return;
}

@end
