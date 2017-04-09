/*============================================================================
 PROJECT: Docquity
 FILE:    AppSettings.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 20/12/16.
 =============================================================================*/

#import "AppSettings.h"
#import "Utils.h"
#define kSound @"Sound"
#define kCaching @"Caching"

@interface AppSettings ()
+(void) commitChanges;
+(void) renderCachingOnPropety;
@end

BOOL soundOn,cachingOn;
@implementation AppSettings

+(BOOL) soundOn{
  return soundOn;
}

+(BOOL) cachingOn{
    return cachingOn;
}

+(void) setSoundOn:(BOOL) val{
    soundOn = val;
    [AppSettings commitChanges];
}
+(void) setCachingOn:(BOOL) val{
    if (cachingOn == val) { //No change case
        return;
    }
    cachingOn = val;
    [AppSettings commitChanges];
    //Render the property
    [AppSettings renderCachingOnPropety];
}

+(void) load{
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    //Initialzing userPrefences
    if(NO == [userPref boolForKey:@"Initialized"]){
        //[userPref setBool:YES forKey:kICal];
        [userPref setBool:YES forKey:kSound];
        [userPref setBool:YES forKey:kCaching];
        [userPref setBool:YES forKey:@"Initialized"];
        [userPref synchronize];
    }
    soundOn = [userPref boolForKey:kSound];
    cachingOn = [userPref boolForKey:kCaching];
    [self renderCachingOnPropety];
}

#pragma mark private methods
+(void) commitChanges{
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [userPref setBool:soundOn forKey:kSound];
    [userPref setBool:cachingOn forKey:kCaching];
    [userPref synchronize];
}

+(void) renderCachingOnPropety
{
    //Initializing urlCache
    if (![NSURLCache sharedURLCache]) {
       // DLog(@"Initializing URLCache");
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity: 4 * 1024 * 1024
                                                          diskCapacity: 20 * 1024 * 1024
                                                              diskPath:nil];
        [NSURLCache setSharedURLCache:cache];
    }
    //Rendering the cachingOn property
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    if (cachingOn) { // 4MB memory, 20MB disk cache
//        [urlCache setMemoryCapacity: 4 * 1024 * 1024];
//        [urlCache setDiskCapacity: 20 * 1024 * 1024];
        
//        urlCache = [[NSURLCache alloc] initWithMemoryCapacity: 4 * 1024 * 1024
//                                                 diskCapacity: 20 * 1024 *1024
//                                                     diskPath:nil];
    }
    else{ // 0MB memory, 0MB disk cache
    [urlCache removeAllCachedResponses];
//  [urlCache setMemoryCapacity: 0 * 1024 * 1024];
//  [urlCache setDiskCapacity: 0 * 1024 * 1024];
//  urlCache = [[NSURLCache alloc] initWithMemoryCapacity:0 * 1024 * 1024
//                                                 diskCapacity:0 * 1024 * 1024
//                                                     diskPath:nil];
    }
}

@end
