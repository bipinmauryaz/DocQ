/*============================================================================
 PROJECT: Docquity
 FILE:    AppSettings.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 20/12/16.
 =============================================================================*/

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

+(BOOL) soundOn;
+(BOOL) cachingOn;

+(void) setSoundOn:(BOOL) val;
+(void) setCachingOn:(BOOL) val;

+(void) load;
@end
