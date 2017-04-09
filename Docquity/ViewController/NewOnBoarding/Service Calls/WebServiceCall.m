//
//  WebServiceCall.m
//  Zynbit
//
//  Created by ThinkSys User on 06/10/16.
//  Copyright © 2016 ThinkSys User. All rights reserved.


#import "WebServiceCall.h"
#import "AFNetworkReachabilityManager.h"
#import "AFHTTPSessionManager.h"

@implementation WebServiceCall

+(void)connectedCompletionBlock:(void(^)(BOOL connected))block {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
     [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
          BOOL networkStatus = NO;
        //        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                networkStatus = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                // -- Not reachable -- //
                networkStatus = NO;
                break;
        }
        //        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //
        //            networkStatus = YES;
        //        }else if (status == AFNetworkReachabilityStatusNotReachable) {
        //
        //            networkStatus = NO;
        //        }
        
        if (block) {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            block(networkStatus);
        }
       }];
  }

+ (void)callServiceGETWithName:(NSString *)serviceURL withHeader:(NSString *)stringHeader postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSUserDefaults*userdef = [NSUserDefaults standardUserDefaults];
    NSString*u_Authkey  = [userdef valueForKey:userAuthKey];
    if (u_Authkey!=nil) {
    [manager.requestSerializer setValue:u_Authkey forHTTPHeaderField:@"user_auth_key"];
    }
    if (stringHeader != nil) {
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:stringHeader password:@""];
    }
    [manager GET:serviceURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        responeBlock(responseObject,nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        responeBlock(nil,error);
    }];
}

//+(NSString*) stringToSHA256:(NSString *)stringInput{
//    const char *s=[stringInput cStringUsingEncoding:NSASCIIStringEncoding];
//    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
//    
//    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
//    CC_SHA256(keyData.bytes, keyData.length, digest);
//    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
//    NSString *hash=[out description];
//    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
//    return hash;
//    
//}

+(void) showAlert :(NSString *)alertTitle andMessage :(NSString *) alertMessage withController:(UIViewController *)view{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    //We add buttons to the alert controller by creating UIAlertActions:
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [view presentViewController:alertController animated:YES completion:nil];
}

//+(BOOL)validateEmail:(NSString *)strEmail
//{
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexEmailValidate];
//    
//    if ([emailTest evaluateWithObject:strEmail] == NO)
//        return NO;
//    else
//        return YES;
//}

+(NSString*)encodeURLComponent:(NSString *)urlComp{
    
    return [urlComp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
}

+(NSMutableDictionary*)methodForFetchValuesFromRedirectURL:(NSString*)stringAbsolute{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    stringAbsolute = [stringAbsolute stringByReplacingOccurrencesOfString:@"#" withString:@"&"];
    NSArray *urlComponents = [stringAbsolute componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
     return queryStringDictionary;
 }

+(NSMutableArray*)methodForSorting:(NSArray*)arrayForSort{
    //Sorting array on behalf of DisplayOrder
    //Suggested by Prem - 03082016
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray * sortedArray = [arrayForSort sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSMutableArray *mutableArrayLeadFields = [[NSMutableArray alloc]init];
    
    //Field is visible if Display == 1 && Hidden == 0
    //Suggested by Prem - 03082016
    for (NSDictionary *dict in [[NSMutableArray alloc]initWithArray:sortedArray]) {
        if ([[dict valueForKey:@"display"]integerValue]==1&&[[dict valueForKey:@"hidden"]integerValue]==0) {
            [mutableArrayLeadFields addObject:dict];
        }
    }
    return mutableArrayLeadFields;
}

+(NSString*)stringWithRemoveCharacters:(NSString*)stringForUpdate{
    return  [stringForUpdate stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

+(NSString*)methodForDateConvert:(NSString *)dateString
{
    NSDateFormatter *dateFormatterType = [[NSDateFormatter alloc] init];
    [dateFormatterType setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    //                    [dateFormatterType setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatterType dateFromString:dateString];
    [dateFormatterType setDateFormat:@"MMM d, yyyy  hh:mm a"];
    
    NSString *stringNewDate=[dateFormatterType stringFromDate:date];
    return stringNewDate;
}

+(void)showHUD{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

+ (void)callServiceWithPOSTName:(NSString *)serviceName withHeader:(NSString*)stringHeader postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    AFHTTPSessionManager *managerPost = [AFHTTPSessionManager manager];
    managerPost.requestSerializer  = [AFHTTPRequestSerializer serializer];
    NSUserDefaults*userdef = [NSUserDefaults standardUserDefaults];
    NSString*tokenValue  =  [userdef valueForKey:@"kAppTokenId"];
    NSString*u_Authkey  = [userdef valueForKey:userAuthKey];
    if (u_Authkey!=nil) {
    [managerPost.requestSerializer setValue:u_Authkey forHTTPHeaderField:@"user_auth_key"];
    }
    else {
    if (tokenValue!=nil) {
    [managerPost.requestSerializer setValue:tokenValue forHTTPHeaderField:@"token_id"];
    }
    }
    if (stringHeader!=nil)
    {
        [managerPost.requestSerializer setAuthorizationHeaderFieldWithUsername:stringHeader password:@""];
    }
    [managerPost POST:serviceName parameters:postData progress:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        responeBlock(responseObject,nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        responeBlock(nil,error);

//        if (error.code == -1009 || error.code == -1001) {
//            NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription,@"message", nil];
//            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:dictInfo];
//            responeBlock(nil,newError);
//            return ;
//        }
//
//        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//
//        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//        
//        NSError *newError = [NSError errorWithDomain:error.domain code:response.statusCode userInfo:serializedData];
//        
//        if (response.statusCode == 401) {
//            if (![USER_CACHE objectForKey:kRefreshToken]) {
//                responeBlock(nil,newError);
//                return ;
//            }else{
//            [self serviceForRefreshTokenCallBackBlock:^(id response , NSError *NSError){
//                if (response) {
//                    responeBlock(nil,newError);
//                }else if(NSError){
//                    responeBlock(nil,NSError);
//                }
//            }];
//            }
//        }else
//            responeBlock(nil,newError);
    }];
}

#pragma mark Code to decode base64 string
+(NSString *)getDecodedStringFromUtf8Base64String:(NSString *)string{
    NSString *string1 = [self base64StringFromBase64UrlEncodedString:string];
    NSData *data = [self dataFromBase64String:string1];
    NSString *raw = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return raw;
  }

+(NSString *)base64StringFromBase64UrlEncodedString:(NSString *)base64UrlEncodedString
{
    NSString *s = base64UrlEncodedString;
    s = [s stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    s = [s stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    switch (s.length % 4) {
        case 2:
            s = [s stringByAppendingString:@"=="];
            break;
        case 3:
            s = [s stringByAppendingString:@"="];
            break;
        default:
            break;
    }
    return s;
}

+(NSData *)dataFromBase64String:(NSString *)encoding
{
    NSData *data = nil;
    unsigned char *decodedBytes = NULL;
    @try {
#define __ 255
        static char decodingTable[256] = {
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
            __,__,__,__, __,__,__,__, __,__,__,62, __,__,__,63,  // 0x20 - 0x2F
            52,53,54,55, 56,57,58,59, 60,61,__,__, __, 0,__,__,  // 0x30 - 0x3F
            __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x40 - 0x4F
            15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x50 - 0x5F
            __,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,  // 0x60 - 0x6F
            41,42,43,44, 45,46,47,48, 49,50,51,__, __,__,__,__,  // 0x70 - 0x7F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
        };
        encoding = [encoding stringByReplacingOccurrencesOfString:@"=" withString:@""];
        NSData *encodedData = [encoding dataUsingEncoding:NSASCIIStringEncoding];
        unsigned char *encodedBytes = (unsigned char *)[encodedData bytes];
        
        NSUInteger encodedLength = [encodedData length];
        if( encodedLength >= (NSUIntegerMax - 3) ) return nil; // NSUInteger overflow check
        NSUInteger encodedBlocks = (encodedLength+3) >> 2;
        NSUInteger expectedDataLength = encodedBlocks * 3;
        
        unsigned char decodingBlock[4];
        
        decodedBytes = malloc(expectedDataLength);
        if( decodedBytes != NULL ) {
            
            NSUInteger i = 0;
            NSUInteger j = 0;
            NSUInteger k = 0;
            unsigned char c;
            while( i < encodedLength ) {
                c = decodingTable[encodedBytes[i]];
                i++;
                if( c != __ ) {
                    decodingBlock[j] = c;
                    j++;
                    if( j == 4 ) {
                        decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                        decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                        decodedBytes[k+2] = (decodingBlock[2] << 6) | (decodingBlock[3]);
                        j = 0;
                        k += 3;
                    }
                }
            }
            // Process left over bytes, if any
            if( j == 3 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                k += 2;
            } else if( j == 2 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                k += 1;
            }
            data = [[NSData alloc] initWithBytes:decodedBytes length:k];
        }
    }
    @catch (NSException *exception) {
        data = nil;
        NSLog(@"WARNING: error occured while decoding base 32 string: %@", exception);
    }
    @finally {
        if( decodedBytes != NULL ) {
            free( decodedBytes );
        }
    }
    return data;
}

+(NSString *)convertHTML:(NSString *)html
{
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
     while ([myScanner isAtEnd] == NO) {
         [myScanner scanUpToString:@"<" intoString:NULL] ;
          [myScanner scanUpToString:@">" intoString:&text] ;
         html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return html;
}

+(NSString *)deviceInfodetails{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *platform = [UIDevice currentDevice].model;
    NSString *str = [NSString stringWithFormat:@"Version - %@,Build number - %@,Carrier - %@,Model - %@System Name - %@,SystemVersion - %@,SystemName - %@",version?version:@"",build?build:@"",[carrier carrierName]?[carrier carrierName]:@"",platform?platform:@"",[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion,[UIDevice currentDevice].systemName];
    return str;
}

@end
