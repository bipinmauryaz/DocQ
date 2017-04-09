//
//  NotificationTVCell.m
//  Docquity
//
//  Created by Arimardan Singh on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NotificationTVCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"

@implementation NotificationTVCell


// set Info data on Notification list
- (void)setInfo:(NSDictionary*)notifyInfo
{
    NSString* notify_msg = [NSString stringWithFormat:@"%@", [notifyInfo objectForKey:@"message"]?[notifyInfo objectForKey:@"message"]:@""];
    NSString* notify_identifier = [NSString stringWithFormat:@"%@", [notifyInfo objectForKey:@"identifier"]?[notifyInfo objectForKey:@"identifier"]:@""];
    NSString* notify_status =[NSString stringWithFormat:@"%@",[notifyInfo objectForKey:@"read_status"]?[notifyInfo objectForKey:@"read_status"]:@""];
   NSString* notify_Pic = notify_Pic  = [NSString stringWithFormat:@"%@",[notifyInfo objectForKey:@"notification_pic"]?[notifyInfo objectForKey:@"notification_pic"]:@""];
    if ([notify_identifier isEqualToString:@"cme"]) {
        [_userImg sd_setImageWithURL:[NSURL URLWithString:notify_Pic]
        placeholderImage:[UIImage imageNamed:@"cme_notify.png"]
                             options:SDWebImageRefreshCached];
         }
    if ([notify_identifier isEqualToString:@"upgrade"]) {
        [_userImg sd_setImageWithURL:[NSURL URLWithString:notify_Pic]
                    placeholderImage:[UIImage imageNamed:@"docquity_upgrade.png"]
                             options:SDWebImageRefreshCached];
    }
    if ([notify_identifier isEqualToString:@"feed"]) {
        [_userImg sd_setImageWithURL:[NSURL URLWithString:notify_Pic]
                    placeholderImage:[UIImage imageNamed:@"avatar.png"]
                             options:SDWebImageRefreshCached];
    }
    
    if ([notify_identifier isEqualToString:@"profile"]) {
        [_userImg sd_setImageWithURL:[NSURL URLWithString:notify_Pic]
                    placeholderImage:[UIImage imageNamed:@"avatar.png"]
                             options:SDWebImageRefreshCached];
    }
    if ([notify_status isEqualToString:@"unread"]) {
         //backgroundView = [UIColor colorWithRed:236.0/255.0 green:245.0/255.0 blue:254.0/255.0 alpha:1.0];
    }
    _userImg.contentMode = UIViewContentModeScaleAspectFill;
   _userImg.layer.cornerRadius = 4.0f;
   _userImg.layer.masksToBounds = YES;
    _userImg.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    _userImg.layer.borderWidth = 0.5;
    [self showtimeFromDict:notifyInfo];
    
    
    
    
    /*
    NSError* error;
    NSString * htmlString =  [notify_msg stringByAppendingString:[NSString stringWithFormat:@"<style>strong{font-family: 'Helvetica Neue' '%@';font-size: %fpx;}</style>",self.font.fontName,
                                                                  48.0]];
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                           NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}
                                                                      documentAttributes:nil error:&error];
    _lbl_notifydetail.attributedText = attrStr;
     */
    
    _lbl_notifydetail.text =   [[notify_msg stringByDecodingHTMLEntities]stringByStrippingTags];

}

// show time on feed
- (void)showtimeFromDict:(NSDictionary*)timeInfo
{
    NSString *date;
    if(timeInfo!=nil && [timeInfo isKindOfClass:[NSDictionary class]]){
        //check if timeinfo dictionary exist
        date=[timeInfo objectForKey:@"date_of_creation"];
        long long int timestamp = [date longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [self updateTimeLabelWithDate:dates];
    }
}

-(void)updateTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    _lbl_time.text = [self relativeDateStringForDate:date];
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitWeekOfYear;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components1];
    components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *thatdate = [cal dateFromComponents:components1];
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:thatdate
                                                                     toDate:today
                                                                    options:0];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.weekOfYear > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.day > 0) {
        if (components.day > 1) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* component = [calender components:NSCalendarUnitWeekday fromDate:thatdate];
            return [self getDay:[component weekday]];
        } else {
            return @"Yesterday";
        }
    } else {
        return [self getTodayCurrTime:date];
    }
}

-(NSString*)getDay:(NSInteger)dayInt{
    NSMutableArray *day= [[NSMutableArray alloc]initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [day objectAtIndex:dayInt-1];
}

-(NSString *)getTodayCurrTime:(NSDate*)date{
    NSString *exactDatestr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter  stringFromDate:date];
    if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){
        //if date exist then calculate change of date formatter
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSInteger seconds = [date timeIntervalSinceDate:currentTime];
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        NSInteger minutes = (int) (floor(seconds / 60));
        if(hours) {
            if (hours==-1) {
                exactDatestr = @"1 hr ago";
            }
            else {
                exactDatestr = [NSString stringWithFormat: @"%ld hrs ago", (long)hours*-1];
            }
        }
        else if(minutes){
            if (minutes==-1) {
                exactDatestr = @"1 min ago";
            }
            else
            {
                exactDatestr = [NSString stringWithFormat: @"%ld mins ago", (long)minutes*-1];
            }
        }
        else if(seconds)
            exactDatestr= [NSString stringWithFormat: @"%ld sec ago", (long)seconds*-1];
        else
            exactDatestr= [NSString stringWithFormat: @"Just now"];
        return exactDatestr;
    }
    return exactDatestr;
}

-(NSString *)getOnlyDate:(NSDate*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd, yyyy"];
    return [df stringFromDate:date];
}

@end
