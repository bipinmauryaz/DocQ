//
//  WebServiceCall.h
//  Zynbit
//
//  Created by ThinkSys User on 06/10/16.
//  Copyright © 2016 ThinkSys User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceCall : NSObject

+(void)connectedCompletionBlock:(void(^)(BOOL connected))block ;

+(NSString*) stringToSHA256:(NSString *)stringInput;

+(void) showAlert :(NSString *)alertTitle andMessage :(NSString *) alertMessage withController:(UIViewController *)view;

+(BOOL)validateEmail:(NSString *)strEmail;

//success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
//failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure

+ (void)callServiceWithPOSTName:(NSString *)serviceName withHeader:(NSString*)stringHeader postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock;


+(NSString *)encodeURLComponent:(NSString *)urlComp;

+(NSMutableDictionary*)methodForFetchValuesFromRedirectURL:(NSString*)stringAbsolute;

+(NSString*)stringWithRemoveCharacters:(NSString*)stringForUpdate;

+(NSString*)methodForDateConvert:(NSString *)dateString;
+(void)showHUD;

+ (void)callServiceGETWithName:(NSString *)serviceURL withHeader:(NSString *)stringHeader postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock;

+(NSString *)getDecodedStringFromUtf8Base64String:(NSString *)string;

+(NSString *)base64StringFromBase64UrlEncodedString:(NSString *)base64UrlEncodedString;

+(NSData *)dataFromBase64String:(NSString *)encoding;

+(NSString *)convertHTML:(NSString *)html;

+(NSString *)deviceInfodetails;

@end
