//
//  NSString+Date.m
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "NSString+Utils.h"


@implementation NSString (Utils)

+ (NSString *) getCurrentTime {

	NSDate *nowUTC = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    dateFormatter.dateFormat = @"HH:mm";
	return [dateFormatter stringFromDate:nowUTC];
	
}

- (NSString *) substituteEmoticons {
	
	//See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
	
	NSString *res = [self stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];	
	res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
	res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
	res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
	
	return res;
	
}


+ (NSString *) mediaPrefix {
    
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    dateFormatter.dateFormat = @"YYYYMMdd";
    
    NSString *media = @"IMG-";
    
    media = [media stringByAppendingString:[dateFormatter stringFromDate:nowUTC]];
    
    //NSLog(@"Media Print: %@",media);
    
    return media;
}

+(NSString *)trim:(NSString *) strInput{
    return [strInput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
