/*============================================================================
 PROJECT: Docquity
 FILE:    DocquityNetworkEngine.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 30/08/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"
@implementation DocquityServerEngine

+ (DocquityServerEngine *)sharedInstance {
    static DocquityServerEngine *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[DocquityServerEngine alloc] init];
    });
    return __instance;
}

- (BOOL)isNetworkRechable {
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi)
            NSLog(@"Network reachable via WWAN");
        else
            NSLog(@"Network reachable via Wifi");
        return YES;
    }
    else {
        NSLog(@"Network is not reachable");
        return NO;
    }
}

#pragma mark -getAPI method
- (void) getAPI:(NSString *) urlString
         params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler {
    
    [[AFHTTPSessionManager manager] GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        // NSLog(@"Progress........");
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject,nil);
        // NSLog(@"Success: %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil,error);
        // NSLog(@"Error: %@", error);
     }];
}

#pragma mark -PostAPI method
- (void) postAPI:(NSString *) urlString
          params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler {
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [[AFHTTPSessionManager manager] setResponseSerializer:responseSerializer];
    
    [[AFHTTPSessionManager manager] POST:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        // NSLog(@"Progress........");
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil,error);
    }];
}

#pragma mark -PutAPI method
- (void) putAPI:(NSString *) urlString
         params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler {
    [[AFHTTPSessionManager manager] PUT:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil,error);
    }];
}

#pragma mark -deleteAPI method
- (void) deleteAPI:(NSString *) urlString
            params: (NSDictionary *)params
 completionHandler:(void (^)(id responseObject,NSError *error))completionHandler {
    [[AFHTTPSessionManager manager] DELETE:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil,error);
    }];
}

#pragma mark - getSearchDataApi
-(void)searchcheckingAPI :(NSString *)user_auth_key  offset:(NSString *)offset device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang keyword:(NSString *)keyword  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", offset,@"offset",device_type,@"device_type",app_version,@"app_version",lang,@"lang",keyword,@"keyword",@"10",@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=search_global_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - new SearchUserApi
-(void)newSearchUserAPI :(NSString *)user_auth_key device_type:(NSString *)device_type  type:(NSString *)type type_id:(NSString *)type_id offset:(NSString *)offset limit:(NSString *)limit callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", type, @"type",type_id, @"type_id",device_type,@"device_type",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=search_user_v2"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Update Device Token
-(void)UpdateDeviceTokenWithUserID :(NSString *)user_id device_type:(NSString *)device_type  deviceToken:(NSString *)device_token format:(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_id?user_id:@"", @"user_id",device_type?device_type:@"",@"device_type",format?format:@"",@"format",device_token?device_token:@"",@"device_token", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=UpdateDeviceToken"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - validate user Api
-(void)pendingUserValidateAuthKey :(NSString *)authkey countrycode:(NSString *)user_cCode  mobile:(NSString *)uMobile callback:(void (^)(NSDictionary *responceObject, NSError* error))callback {
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *ipAdd =   [userpref objectForKey:ip_address1];
    NSString *devType = @"ios";
    NSString *devToken = [AppDelegate appDelegate].deviceTokenString;
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *devicedetails =[self deviceInfodetails];
    devicedetails = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          
                                                                                          NULL,(CFStringRef)devicedetails,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:authkey?authkey:@"", @"user_auth_key",user_cCode?user_cCode:@"",@"country_code",uMobile?uMobile:@"",@"mobile",devToken?devToken:@"",@"device_token", ipAdd?ipAdd:@"", @"ip_address",devType?devType:@"",@"device_type",version?version:@"",@"app_version",devicedetails?devicedetails:@"",@"device_info", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=validated_user_on_splash"];
    // NSLog(@"parameters pendingUserValidateAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

-(NSString *)deviceInfodetails{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *platform = [UIDevice currentDevice].model;
    NSString *str = [NSString stringWithFormat:@"Version - %@,Build number - %@,Carrier - %@,Model - %@System Name - %@,SystemVersion - %@,SystemName - %@",version,build,[carrier carrierName],platform,[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion,[UIDevice currentDevice].systemName];
    return str;
}

#pragma mark - getFeedLikeListApi
-(void)feedLikeListAPI :(NSString *)user_auth_key feed_id :(NSString *)feed_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=feed_like_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getsingle_feed
-(void)singlefeedRequest :(NSString *)user_auth_key feed_id :(NSString *)feed_id device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",device_type,@"device_type",app_version,@"app_version",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=single_feed_v2"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getfeed_comment_like_list
-(void)feedcommentlikelistRequestWithAuthKey:(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=feed_comment_like_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getfeed_comment_reply_like_list
-(void)feedcommenreplytlikelistRequest :(NSString *)user_auth_key feed_id :(NSString *)feed_id  comment_id:(NSString *)comment_id comment_reply_id :(NSString *)comment_reply_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",comment_reply_id,@"comment_reply_id",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=feed_comment_reply_like_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getFeedlist_comment
-(void)feedlistcommentRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",device_type,@"device_type",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=list_comment"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getFeedlist_comment_reply
-(void)listCommentReplyRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id device_type :(NSString *)device_type  app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit  callback:(void (^)(NSDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",device_type,@"device_type",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=list_comment_reply"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - set Feed action_comment_reply
-(void)feedactioncommentreplyRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id comment_reply_id:(NSString *)comment_reply_id action:(NSString *)action reply:(NSString *)reply device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",comment_reply_id,@"comment_reply_id",action,@"action",reply,@"reply",device_type,@"device_type",app_version,@"app_version",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=action_comment_reply"];
   // NSLog(@"action_comment_reply = %@",parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - setFeedcomment_like
-(void)feedcommentlikeRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",device_type,@"device_type",app_version,@"app_version",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=comment_like"];
   // NSLog(@"parameter like commnet : %@",parameters);
   // NSLog(@"url like commnet : %@",urlString);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - setFeedcomment_reply_like
-(void)feedcommentreplylikeRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id comment_reply_id :(NSString *)comment_reply_id device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",comment_id,@"comment_id",comment_reply_id,@"comment_reply_id",device_type,@"device_type",app_version,@"app_version",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=comment_reply_like"];
   // NSLog(@"parameter Reply like commnet : %@",parameters);
   // NSLog(@"url Reply like commnet : %@",urlString);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - setFeedcomment
-(void)feedcommentActionRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id userid :(NSString *)user_id action:(NSString *)action app_version :(NSString *)app_version format:(NSString *)format userType:(NSString*)user_type callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", feed_id,@"feed_id",comment_id,@"comment_id",user_type,@"user_type",app_version,@"app_version",user_id,@"user_id",action,@"action",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=Action_Comment_Post"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - check_user_permission
-(void)check_user_permissionRequest :(NSString *)user_auth_key callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=check_user_permission"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - update_identification
-(void)update_identificationRequest :(NSString *)user_auth_key invite_code :(NSString *)invite_code identity_proof :(NSString *)identity_proof device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", invite_code,@"invite_code",identity_proof,@"identity_proof",device_type,@"device_type",app_version,@"app_version",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=update_identification"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get Country Code - OLD API
-(void)GetCountryListWithAccesscode :(NSString *)access_code format :(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:access_code, @"access_code", format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"getApi.php?rquest=Country_Details"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get Document List - OLD API
-(void)GetDocqumentListRequestWithAccessKey :(NSString *)access_key association_id:(NSString*)association_id format :(NSString *)format callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:access_key, @"access_key",association_id,@"association_id", format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"getApi.php?rquest=Document_List"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetProfile Request Old Api
-(void)SetProfileRequest :(NSString *)user_auth_key user_id:(NSString*)user_id firstname:(NSString*)firstname lastname:(NSString*)lastname email:(NSString*)email mobile:(NSString*)mobile country:(NSString *)country city:(NSString *)city state:(NSString *)state format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
     NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", [firstname stringByEncodingHTMLEntities],@"firstname", [lastname stringByEncodingHTMLEntities],@"lastname", email,@"email", mobile,@" mobile",[country stringByEncodingHTMLEntities] ,@"country", [city stringByEncodingHTMLEntities],@" city",[state stringByEncodingHTMLEntities],@"state",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=SetProfile"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetInterest Request Old Api
-(void)SetInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id interest_id:(NSString*)interest_id interest_name:(NSString*)interest_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", interest_id,@"interest_id", [interest_name stringByEncodingHTMLEntities],@"interest_name",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=SetInterest"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}
#pragma mark - SetRemoveInterest Request Old Api
-(void)SetRemoveInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id interest_id:(NSString*)interest_id  format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", interest_id,@"interest_id",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveInterest"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetCreateInterest Request Old Api
-(void)SetCreateInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  interest_name:(NSString*)interest_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", [interest_name stringByEncodingHTMLEntities],@"interest_name",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=CreateInterest"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetBiography Request Old Api
-(void)SetBiographyRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  bio:(NSString*)bio format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", [bio stringByEncodingHTMLEntities],@"bio",format,@"format", nil];
     NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=SetBiography"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set_Speciality Request Old Api
-(void)SetSpecialityRequest :(NSString *)user_auth_key user_id:(NSString*)user_id speciality_id:(NSString*)speciality_id speciality_name:(NSString*)speciality_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", speciality_id,@"speciality_id", [speciality_name  stringByEncodingHTMLEntities],@"speciality_name",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=Set_Speciality_New"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - GET Speciality Request Old Api
-(void)GetSpecialityRequest :(NSString *)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"getApi.php?rquest=Speciality_List"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetRemoveSpeciality Request Old Api
-(void)SetRemoveSpecialityRequest :(NSString *)user_auth_key user_id:(NSString*)user_id speciality_id:(NSString*)speciality_id  format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", speciality_id,@"speciality_id",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveSpeciality"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetRemoveEducation Request Old Api
-(void)SetRemoveEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  education_id:(NSString*)education_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", education_id,@"education_id",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveEducation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetRemoveAssociation Request Old Api
-(void)SetRemoveAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  association_id:(NSString*)association_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", association_id,@"association_id",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveAssociation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetUserPic Request Old Api
-(void)SetUserImgRequest :(NSString *)user_auth_key userpic:(NSString*)userpic  userpictype:(NSString*)userpictype app_version:(NSString*)app_version device_type:(NSString*)device_type  lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", userpic,@"userpic",userpictype,@"userpictype",app_version,@"app_version",device_type,@"device_type",lang,@"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=SetUserPic"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetCreateEducation Request Old Api
-(void)SetCreateEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  school_name:(NSString*)school_name  degree:(NSString*)degree  end_date:(NSString*)end_date current_pursuing:(NSString*)current_pursuing format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", [school_name stringByEncodingHTMLEntities],@"school_name",[degree stringByEncodingHTMLEntities],@"degree",end_date,@"end_date",current_pursuing,@"current_pursuing",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=CreateEducation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetEducation Request Old Api
-(void)SetEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id education_id:(NSString*)education_id school_name:(NSString*)school_name  degree:(NSString*)degree  end_date:(NSString*)end_date current_pursuing:(NSString*)current_pursuing format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id",education_id,@"education_id",[school_name stringByEncodingHTMLEntities],@"school_name",[degree stringByEncodingHTMLEntities],@"degree",end_date,@"end_date",current_pursuing,@"current_pursuing",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=SetEducation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetCreateAssociation Request Old Api
-(void)SetCreateAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id current_prof:(NSString*)current_prof association_name:(NSString*)association_name  position:(NSString*)position  location:(NSString*)location start_date:(NSString*)start_date end_date:(NSString*)end_date start_month:(NSString*)start_month end_month:(NSString*)end_month format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", current_prof,@"current_prof", [association_name stringByEncodingHTMLEntities],@"association_name",[position stringByEncodingHTMLEntities],@"position",[location stringByEncodingHTMLEntities],@"location",start_date,@"start_date",end_date,@"end_date",start_month,@"start_month",end_month,@"end_month",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=CreateAssociation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetAssociation Request Old Api
-(void)SetAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id association_id:(NSString*)association_id current_prof:(NSString*)current_prof association_name:(NSString*)association_name  position:(NSString*)position  location:(NSString*)location start_date:(NSString*)start_date end_date:(NSString*)end_date start_month:(NSString*)start_month end_month:(NSString*)end_month format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", user_id,@"user_id", association_id,@"association_id", current_prof,@"current_prof", [association_name stringByEncodingHTMLEntities],@"association_name",[position stringByEncodingHTMLEntities],@"position",[location stringByEncodingHTMLEntities],@"location",start_date,@"start_date",end_date,@"end_date",start_month,@"start_month",end_month,@"end_month",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=SetAssociation"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Send ConnectionFriend  Request Old Api
-(void)SendConnectionFriendRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", requester_id,@"requester_id", requestee_id,@"requestee_id",format,@"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RequestFriend"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set Connection Decline Friend Request Old Api
-(void)SetConnectionDeclineFriendRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", requester_id,@"requester_id", requestee_id,@"requestee_id",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=DeclineFriend"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark SetConnectionAcceptFriendRequest Request Old Api
-(void)SetConnectionAcceptFriendRequesRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
 
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", requester_id,@"requester_id", requestee_id,@"requestee_id",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=AcceptFriend"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set RemoveGroup exit Request Old Api
-(void)SetRemoveGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id member_id:(NSString*)member_id  removeby:(NSString*)removeby format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", group_id,@"group_id",member_id,@"member_id", removeby,@"removeby",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveMemberFromGroup"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set SetEdit/Update GroupRequest Old Api
-(void)SetEditGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id group_name:(NSString*)group_name owner_id:(NSString*)owner_id group_pic:(NSString*)group_pic group_pic_type:(NSString*)group_pic_type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", group_id,@"group_id", group_name,@"group_name", owner_id,@"owner_id", group_pic,@"group_pic",group_pic_type,@"group_pic_type",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=EditGroup"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Get Group Details Request Old Api
-(void)GetGroupDetailsRequest :(NSString *)user_auth_key user_id:(NSString*)user_id group_id:(NSString*)group_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key,@"authkey", user_id,@"user_id",group_id,@"group_id",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"getApi.php?rquest=GetGroupDetails"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set Remove MemberFromGroup  Request Old Api
-(void)SetRemoveMemberFromGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id member_id:(NSString*)member_id removeby:(NSString*)removeby format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", group_id,@"group_id",member_id,@"member_id", removeby,@"removeby",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=RemoveMemberFromGroup"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set Sender Image Chat Request Old Api
-(void)SetImgSenderChatRequest :(NSString *)image type:(NSString*)type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image", type,@"type",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=UploadImage"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set CreateGroup Request Old Api
-(void)SetCreateGroupRequest :(NSString *)user_auth_key  owner_id:(NSString*)owner_id group_name:(NSString*)group_name group_pic:(NSString*)group_pic  group_pic_type:(NSString*)group_pic_type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", owner_id,@"owner_id",group_name,@"group_name",group_pic,@"group_pic",group_pic_type,@"group_pic_type",owner_id,@"owner_id",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=CreateGroup"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set AddMemberToGroup Request Old Api
-(void)SetAddMemberToGroupRequest :(NSString *)user_auth_key  group_id:(NSString*)group_id member_id:(NSString*)member_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key,@"authkey", group_id,@"group_id",member_id,@"member_id",format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=AddMemberToGroup"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Get Friend List Request Old Api
-(void)GetFriendListRequest :(NSString *)user_auth_key user_id:(NSString*)user_id group_id:(NSString*)group_id discussion_id:(NSString*)discussion_id status:(NSString*)status format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key,@"authkey", user_id,@"user_id", group_id,@"group_id", discussion_id,@"discussion_id", status,@"status", format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"getApi.php?rquest=FriendList"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark Set BadgesZero Request Old Api
-(void)SetBadgeZerowithAuthKey:(NSString *)user_auth_key user_id:(NSString *)user_id device_info:(NSString *)device_info jabber_id:(NSString *)jabber_id custom_id:(NSString *)custom_id format:(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key,@"authkey", user_id,@"user_id", device_info,@"device_info", jabber_id,@"jabber_id", custom_id,@"custom_id", format,@"format", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=Set_Badge_Zero"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - get_user_course_list
-(void)GetUserCourseListRequest :(NSString *)user_auth_key device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang offset :(NSString *)offset limit:(NSString *)limit type:(NSString*)type callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",device_type,@"device_type",app_version,@"app_version",lang,@"lang",offset,@"offset",limit,@"limit",type,@"type", nil];
    NSString *urlString=[NSString stringWithFormat:CMEGetWebUrl@"get_user_course_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - subcribe_course Request
-(void)SubcribeCourseRequest :(NSString *)user_auth_key lesson_id:(NSString*)lesson_id device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang type:(NSString*)type issample:(NSString*)issample callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", lesson_id,@"lesson_id", device_type,@"device_type",app_version,@"app_version",lang,@"lang",type,@"type",issample,@"is_sample", nil];
    NSString *urlString=[NSString stringWithFormat:CMESetWebUrl@"subcribe_course"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}
#pragma mark - Set Submit Course Answer Request
-(void)SubmitAnswerRequestWithAuthKey :(NSString *)user_auth_key lesson_id:(NSString*)lesson_id association_id:(NSString*)association_id qa_json:(NSString*)qa_json device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", lesson_id, @"lesson_id", association_id,@"association_id",qa_json, @"qa_json",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:CMESetWebUrl@"submit_answer"];
  //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - get profile view Request
-(void)viewProfileWithAuthKey :(NSString *)user_auth_key custom_id :(NSString*)custom_id device_type:(NSString*)device_type ipAddress:(NSString*)ipAddress app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", custom_id, @"custom_id", device_type,@"device_type",ipAddress, @"ip_address", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=view_profile_v2"];
   // NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Feed post Request
-(void)setFeedPostWithTitle :(NSString *)title content :(NSString*)content posted_by:(NSString*)posted_by user_type:(NSString*)user_type feed_type :(NSString *)feed_type file_type :(NSString *)file_type file_url:(NSString*)file_url meta_url :(NSString *)meta_url feed_type_id :(NSString *)feed_type_id auth_key:(NSString*)auth_key format:(NSString *)format feed_kind:(NSString*)feed_kind video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString *)file_description callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", content, @"content", posted_by,@"posted_by",user_type, @"user_type", feed_type, @"feed_type", file_type, @"file_type",file_url, @"file_url", meta_url,@"meta_url",feed_type_id, @"feed_type_id", auth_key, @"auth_key", format, @"format",feed_kind,@"feed_kind",video_image_url,@"video_image_url",file_name,@"file_name",file_description,@"file_description", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=Post_Feed"];
   // NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
 }

#pragma mark - SetRegisterAccountReadOnlyRequest //status 3 check new user
-(void)SetRegisterAccountReadOnly:(NSString *)token_id first_name:(NSString*)first_name last_name:(NSString*)last_name  country:(NSString*)country email:(NSString*)email registration_id:(NSString*)registration_id invite_code:(NSString*)invite_code association_id:(NSString*)association_id user_type:(NSString*)user_type university_json:(NSString*)university_json speciality_id_json:(NSString*)speciality_id_json device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token_id, @"token_id", first_name,@"first_name",last_name,@"last_name",country,@"country",email,@"email",registration_id,@"registration_id",invite_code,@"invite_code",association_id,@"association_id",user_type,@"user_type",university_json,@"university_json",speciality_id_json,@"speciality_id_json",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=register_account_readonly_v2"];
   //   NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Claim Account Read Only Request // status 2 checking
-(void)SetClaimAccountReadOnlyWithToken:(NSString *)token_id  first_name:(NSString*)first_name last_name:(NSString*)last_name  country:(NSString*)country email:(NSString*)email registration_id:(NSString*)registration_id invite_code:(NSString*)invite_code  user_type:(NSString*)user_type university_json:(NSString*)university_json speciality_id_json:(NSString*)speciality_id_json device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token_id, @"token_id", first_name,@"first_name",last_name,@"last_name",country,@"country",email,@"email",registration_id,@"registration_id",invite_code,@"invite_code",user_type,@"user_type",university_json,@"university_json",speciality_id_json,@"speciality_id_json", device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=claim_account_readonly_v2"];
  //   NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - GetNotificationListRequest
-(void)getNotificationListRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset limit:(NSString*)limit device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", offset, @"offset", limit,@"limit", device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=notification_list_per_user"];
 //   NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetReadNotificationRequest
-(void)setReadNotificationRequestWithAuthKey :(NSString *)user_auth_key message_id_json:(NSString*)message_id_json  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", message_id_json, @"message_id_json", device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=notification_unread"];
 //   NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

/*
 Get Chat dialog credentials server for ONE 2 ONE Chat
 */
#pragma mark - Get Chat Credential create Dialogue
-(void)getChatCredentialCreateWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version device_type:(NSString *)device_type  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",app_version,@"app_version", lang,@"lang",device_type, @"device_type", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=get_chat_credential"];
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get Chat Dialogue
-(void)getChatDialogueWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version offset:(NSString *)offset limit:(NSString *)limit DOUpdate:(NSString *)date_of_updation callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",app_version,@"app_version", lang,@"lang",offset,@"offset",limit,@"limit",date_of_updation,@"date_of_updation", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=get_chat_dialogue"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get Specific Chat Dialogue
-(void)getSingleChatDialogueWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version dialog:(NSString *)dialogue_id callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",app_version,@"app_version", lang,@"lang",dialogue_id,@"dialogue_id", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=get_specific_chat_dialogue"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Chat Dialogue
-(void)setDialogWithAuthkey:(NSString *)authkey oppCustID :(NSString*)custom_id lang:(NSString *)lang app_version:(NSString *)app_version dialogue:(NSString*)dialogue callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:authkey, @"user_auth_key", custom_id, @"custom_id", lang,@"lang",app_version, @"app_version", dialogue, @"dialogue",nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=enter_dialogue"];
  //   NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set User Block Unblock
-(void)setUserActionWithAuthkey:(NSString *)authkey oppCustID :(NSString*)custom_id lang:(NSString *)lang app_version:(NSString *)app_version action:(NSString*)action callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:authkey, @"user_auth_key", custom_id, @"requester_custom_id", lang,@"lang",app_version, @"app_version", action, @"action",nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=update_connection"];
  //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Claim Account Read Only Request
-(void)Getsearch_university:(NSString *)token_id keyword:(NSString *)keyword device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token_id, @"token",  keyword, @"keyword", device_type, @"device_type",app_version, @"app_version", lang,@"lang" ,nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=search_university"];
  //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - ViewFeedFiltered Request
-(void)ViewFeed_FilteredRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset feed_kind:(NSString*)feed_kind  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", offset, @"offset", feed_kind,@"feed_kind", device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=View_Feed_Filtered"];
  //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - ViewCaseFiltered Request
-(void)ViewCase_FilteredRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset feed_kind:(NSString*)feed_kind  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", offset, @"offset", feed_kind,@"feed_kind", device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=View_Feed_Filtered"];
  //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Delete FeedRequest
-(void)DeleteFeedRequesttWithAuthKey :(NSString *)user_auth_key user_id:(NSString*)user_id feed_id:(NSString*)feed_id action:(NSString*)action user_type:(NSString*)user_type device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang format:(NSString *)format  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"authkey", user_id, @"user_id", feed_id, @"feed_id", action,@"action", user_type, @"user_type",device_type, @"device_type", app_version, @"app_version", lang, @"lang", format, @"format", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"setApi.php?rquest=Action_Feed_Post"];
    //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetFeedLikeRequest
-(void)SetFeedLikeRequesttWithAuthKey :(NSString *)user_auth_key feed_id:(NSString*)feed_id device_type:(NSString*)device_type app_version:(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", feed_id,@"feed_id",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=like_feed"];
    //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - SetSetNotify_to_upgrade_for_chat
-(void)SetNotify_to_upgrade_for_chatWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", custom_id,@"custom_id",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=notify_to_upgrade_for_chat"];
    //  NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get meta_preview
-(void)GetMetaPreviewWithAuthKey :(NSString *)user_auth_key  meta_url:(NSString*)meta_url type_for:(NSString*)type_for device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key", meta_url,@"meta_url",type_for,@"type_for",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=meta_preview"];
 //     NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set edit_feed_v2
-(void)SetEditFeedWithAuthKey :(NSString *)user_auth_key feed_id:(NSString*)feed_id title:(NSString*)title content:(NSString*)content feed_type:(NSString*)feed_type file_type:(NSString*)file_type file_url:(NSString*)file_url  feed_type_id:(NSString*)feed_type_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url  video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString*)file_description classification:(NSString*)classification meta_array:(NSString*)meta_array speciality_json_array:(NSString*)speciality_json_array device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",feed_id,@"feed_id",title,@"title", content,@"content",feed_type,@"feed_type", file_type,@"file_type",file_url,@"file_url",feed_type_id, @"feed_type_id",feed_kind,@"feed_kind",meta_url,@"meta_url",video_image_url,@"video_image_url", file_name,@"file_name",file_url,@"file_url",file_description,@"file_description",classification,@"classification",meta_array,@"meta_array",speciality_json_array,@"speciality_json_array",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=edit_feed_v2"];
 //     NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set post_feed_v2
-(void)SetPostFeedWithAuthKey :(NSString *)user_auth_key title:(NSString*)title content:(NSString*)content feed_type:(NSString*)feed_type file_type:(NSString*)file_type file_url:(NSString*)file_url  feed_type_id:(NSString*)feed_type_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url  video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString*)file_description classification:(NSString*)classification meta_array:(NSString*)meta_array speciality_json_array:(NSString*)speciality_json_array device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user_auth_key, @"user_auth_key",title,@"title", content,@"content",feed_type,@"feed_type", file_type,@"file_type",file_url,@"file_url",feed_type_id, @"feed_type_id",feed_kind,@"feed_kind",meta_url,@"meta_url",video_image_url,@"video_image_url", file_name,@"file_name",file_url,@"file_url",file_description,@"file_description",classification,@"classification",meta_array,@"meta_array",speciality_json_array,@"speciality_json_array",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"set?rquest=post_feed_v2"];
//      NSLog(@"url string: %@, Parameters = %@",urlString,parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - get Speciality Request New Api
-(void)getSpecialityRequestWithAuthKey :(NSString *)user_auth_key  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
     NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: user_auth_key,@"user_auth_key",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=speciality_list"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - getUserTimeLineRequest
-(void)getUserTimeLineRequestWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: user_auth_key,@"user_auth_key",custom_id,@"custom_id",limit,@"limit",offset,@"offset",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=get_timeline"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - get_timeline_photoRequest
-(void)getUserTimeLinePhotoRequestWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: user_auth_key,@"user_auth_key",custom_id,@"custom_id",limit,@"limit",offset,@"offset",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=get_timeline_photo"];
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - get_view_feed_by_specialityRequest
-(void)getViewFeedBySpecialityRequestWithAuthKey :(NSString *)user_auth_key  speciality_id
                                                 :(NSString*)speciality_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: user_auth_key,@"user_auth_key",speciality_id,@"speciality_id",limit,@"limit",offset,@"offset",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"get?rquest=view_feed_by_speciality"];
  //  NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set_OtpRequest
-(void)setOTPRequestWithAppKey :(NSString *)app_key  version
                               :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code device_token:(NSString*)device_token registered_user_type:(NSString*)registered_user_type  ip_address:(NSString*)ip_address device_type:(NSString*)device_type app_version :(NSString *)app_version registered_user_typelang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
     NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: app_key,@"app_key",version,@"version",country_code,@"country_code",mobile,@"mobile",iso_code,@"iso_code",device_token,@"device_token",registered_user_type,@"registered_user_type",ip_address,@"ip_address",device_type, @"device_type", app_version, @"app_version",lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/set?rquest=request_otp"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set_ResendOtpRequest
-(void)setResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code token_id:(NSString*)token_id  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: app_key,@"app_key",version,@"version",country_code,@"country_code",mobile,@"mobile",iso_code,@"iso_code",token_id,@"token_id",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/set?rquest=resend_otp"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get_CountryListRequest
-(void)getResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code token_id:(NSString*)token_id  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: app_key,@"app_key",version,@"version",country_code,@"country_code",mobile,@"mobile",iso_code,@"iso_code",token_id,@"token_id",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/get?rquest=countrylist"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Get association list by Country
-(void)getResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: app_key,@"app_key",version,@"version",country_code,@"country_code",mobile,@"mobile",iso_code,@"iso_code",device_type, @"device_type", app_version, @"app_version", lang, @"lang", nil];
    NSString *urlString=[NSString stringWithFormat:WebUrl@"association/get?rquest=association_list_by_country"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Verify mobile request
-(void)setVerifyMobileRequestWithVersion:(NSString*)version token_id:(NSString*)token_id country_code:(NSString*)country_code mobile:(NSString*)mobile device_type:(NSString*)device_type device_token:(NSString*)device_token  device_info:(NSString*)device_info ip_address:(NSString*)ip_address user_type:(NSString*)user_type app_version :(NSString *)app_version otp:(NSString*)otp iso_code:(NSString*)iso_code  lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: version,@"version",token_id,@"token_id",country_code,@"country_code",mobile,@"mobile",device_type, @"device_type",device_token,@"device_token",device_info,@"device_info",ip_address,@"ip_address",user_type,@"user_type", app_version, @"app_version",otp, @"otp",iso_code,@"iso_code",lang, @"lang", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/set.php?rquest=verify_mobile"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set Claim Account request
-(void)setClaimAccountRequestWithVersion
:(NSString*)version token_id:(NSString*)token_id country_code:(NSString*)country_code mobile:(NSString*)mobile device_type:(NSString*)device_type ic_number:(NSString*)ic_number  association_id:(NSString*)association_id  iso_code:(NSString*)iso_code app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: version,@"version",token_id,@"token_id",country_code,@"country_code",mobile,@"mobile",device_type, @"device_type",ic_number,@"ic_number",association_id,@"association_id",app_version, @"app_version",iso_code,@"iso_code",lang, @"lang", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/set.php?rquest=claim_account"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] getAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

#pragma mark - Set referal_track request
-(void)setReferalTrackRequestWithVersion
:(NSString*)version invitation_code:(NSString*)invitation_code device_type:(NSString*)device_type user_auth_key:(NSString*)user_auth_key  iso_code:(NSString*)iso_code app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: version,@"version",@"invitation_code",invitation_code, device_type, @"device_type",user_auth_key,@"user_auth_key",app_version, @"app_version",iso_code,@"iso_code",lang, @"lang", nil];
    
    NSString *urlString=[NSString stringWithFormat:WebUrl@"registration/set?rquest=referal_track"];
    // NSLog(@"parameters getViewFeedBySpecialityRequestWithAuthKey = %@",parameters);
    [[DocquityServerEngine sharedInstance] postAPI:urlString params:parameters completionHandler:^(id responseObject, NSError *error) {
        callback(responseObject,error);
    }];
}

@end
