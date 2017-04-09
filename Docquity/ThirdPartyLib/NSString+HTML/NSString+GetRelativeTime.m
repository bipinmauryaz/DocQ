//
//  NSString+GetRelativeTime.m
//  Docquity
//
//  Created by Docquity-iOS on 08/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NSString+GetRelativeTime.h"

@implementation NSString (GetRelativeTime)
// show exp time for courses
+ (NSString*)setUpdateTimewithString:(NSString*)expdate
{
    //    NSString *expdate;
    //    if(timeInfo!=nil && [timeInfo isKindOfClass:[NSDictionary class]]){
    //        //check if bite dictionary exist
    //        expdate=[timeInfo objectForKey:@"expiry_date"];
    //        long long int timestamp = [expdate longLongValue]/1000;
    //        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //        [self updateTimeLabelWithDate:dates];
    //    }
    
    long long int timestamp = [expdate longLongValue]/1000;
    NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self updateTimeLabelWithDate:dates];
    
}

+(NSString*)updateTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    return [self relativeDateStringForDate:date];
}

+ (NSString *)relativeDateStringForDate:(NSDate *)date
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
        return [NSString stringWithFormat:@"%ld years", (long)components.year];
    } else if (components.month > 0) {
        return [self getOnlyDate:thatdate];
        //return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [self getOnlyDate:thatdate];
    }
    //return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    //    } else if (components.day > 0) {
    //        if (components.day > 1) {
    //            NSCalendar* calender = [NSCalendar currentCalendar];
    //            NSDateComponents* component = [calender components:NSCalendarUnitWeekday fromDate:thatdate];
    //            return [self getDay:[component weekday]];
    //            // return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
    //        } else {
    //            return @"Yesterday";
    //        }
    //}
    else {
        
        return [self getOnlyDate:thatdate];
        //[self getTodayCurrTime:date];
    }
    
}

+(NSString*)getDay:(NSInteger)dayInt{
    // NSLog(@"%ld",(long)dayInt);
    NSMutableArray *day= [[NSMutableArray alloc]initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [day objectAtIndex:dayInt-1];
}

+(NSString *)getTodayCurrTime:(NSDate*)date{
    NSString *exactDatestr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter  stringFromDate:date];
    if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){ //if date exist then calculate it
        // change of date formatter
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-10-21 03:19:32
        NSInteger seconds = [date timeIntervalSinceDate:currentTime];
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        NSInteger minutes = (int) (floor(seconds / 60));
        //if(minutes) seconds -= minutes * 60;
        //            if(days) {
        //                if (days==-1) {
        //                    exactDatestr = @"Yesterday";
        //                }
        //                else{
        //                    exactDatestr = [NSString stringWithFormat:@"%ld Days ago", (long)days*-1];
        //                }
        //            }
        if(hours) {
            if (hours==-1) {
                exactDatestr = @"1 hr";
            }
            else {
                exactDatestr = [NSString stringWithFormat: @"%ld hrs", (long)hours*-1];
            }
        }
        else if(minutes){
            if (minutes==-1) {
                exactDatestr = @"1 min";
            }
            else
            {
                exactDatestr = [NSString stringWithFormat: @"%ld mins", (long)minutes*-1];
            }
        }
        else if(seconds)
            exactDatestr= [NSString stringWithFormat: @"%ld sec", (long)seconds*-1];
        else
            exactDatestr= [NSString stringWithFormat: @"Just now"];
        return exactDatestr;
    }
    return exactDatestr;
}

//\u2022 \u002E
+(NSString *)getOnlyDate:(NSDate*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd, yyyy"];
    return [df stringFromDate:date];
}


@end
