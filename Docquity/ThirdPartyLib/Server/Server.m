/*============================================================================
 PROJECT: Docquity
 FILE:    Server.m
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 04/08/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "Server.h"
#import "Reachability.h"
//#import "NSString+SBJSON.h"
#import "DefineAndConstants.h"
#import "Json.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NSString+Utils.h"
//#import "Base64.h"
@implementation Server
@synthesize delegate;

//https://developers.google.com/places/documentation/autocomplete

//- (NSMutableURLRequest*) cmacRequestForAllEventsList:(NSDictionary*)userInfo
//{
//	NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:cmacUrl1] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
//
//    [request setHTTPMethod:@"GET"];
//	return request;
//
//}

#pragma mark MetaData Request
- (NSMutableURLRequest*) DocquitygetMetaDataRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json";
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *metaUrl= [userpref objectForKey:metaURLs];
    NSString *typeUrl= @"feed";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=MetaData"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"meta_url=%@&type_url=%@&format=%@",metaUrl,typeUrl,frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}


#pragma mark SetFeedRequest Request
- (NSMutableURLRequest*) DocquitySetFeedRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json";
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *metaurl=   [userInfo objectForKey:metaDataURL];
    NSString *u_authkey = [userpref objectForKey:userAuthKey];
    NSString *passoId =  [userInfo objectForKey:associationID];
    NSString *title= [userInfo objectForKey:feedPostTitle];
    NSString*encodedtitleString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)title,
                                                                                                        NULL,
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8 ));
    NSString*content = [userInfo objectForKey:feedPostContent];
    NSString*encodedcontentString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (CFStringRef)content,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8 ));
    
    encodedtitleString = [NSString trim:encodedtitleString];
    encodedcontentString = [NSString trim:encodedcontentString];
    NSString*postBy = [userpref valueForKey:userId];
    NSString*u_typ = @"user";
    NSString*feedTyp = @"association";
    NSString*fileTyp = [userInfo objectForKey:feedFileTyp];
    NSString*fileURL = [userpref objectForKey:feedFileURL];
    NSString*feedkind = [userInfo objectForKey:feedKind];
    NSString *thumbURL = [userInfo objectForKey:feedVideoThumbURL];
    NSString *filename = [userInfo objectForKey:docFileName];
    NSString*encodedfileURLString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (CFStringRef)fileURL,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8 ));
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=Post_Feed"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"title=%@&content=%@&posted_by=%@&user_type=%@&feed_type=%@&file_type=%@&file_url=%@&meta_url=%@&feed_type_id=%@&auth_key=%@&format=%@&feed_kind=%@&video_image_url=%@&file_name=%@&file_description=",encodedtitleString?encodedtitleString:@"",encodedcontentString?encodedcontentString:@"",postBy?postBy:@"",u_typ?u_typ:@"",feedTyp?feedTyp:@"",fileTyp?fileTyp:@"",encodedfileURLString?encodedfileURLString:@"",metaurl?metaurl:@"",passoId,u_authkey,frmt,feedkind?feedkind:@"",thumbURL?thumbURL:@"",filename?filename:@""];
    //NSLog(@"post string for Add New feed: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark SetUploadFile Request
- (NSMutableURLRequest*) DocquitySetUploadFileRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json";
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *file=    [userInfo valueForKey:base64Str1];
    NSString *fileType=    [userInfo objectForKey:Image1];
    [userpref synchronize];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=UploadFile"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:600.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"file=%@&type=%@&format=%@",file?file:@"",fileType?fileType:@"",frmt];
    //NSLog(@"post string for SetUploadFileRequest %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark get User_Association_List Request
- (NSMutableURLRequest*)DocquityUser_Association_ListRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *uId=    [userpref objectForKey:userId];    //mandatory
    NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=User_Association_List"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"user_id=%@&authkey=%@&format=%@",uId?uId:@"",u_authkey?u_authkey:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}


#pragma mark Set Edit Action Feed Post Request
- (NSMutableURLRequest*) DocquityEditActionFeedPostRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json";
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *metaurl=   [userInfo objectForKey:metaDataURL];
    NSString *u_authkey = [userpref objectForKey:userAuthKey];
    NSString *passoId =  [userInfo objectForKey:associationID];
    NSString *title= [userInfo objectForKey:feedPostTitle];
    NSString *feedkind =  [userInfo objectForKey:feedKind];
    NSString *filename = [userInfo objectForKey:docFileName];
    NSString*encodedtitleString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)title,
                                                                                                        NULL,
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8 ));
    NSString*content = [userInfo objectForKey:feedPostContent];
    NSString*encodedcontentString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (CFStringRef)content,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8 ));
    
    encodedtitleString = [NSString trim:encodedtitleString];
    encodedcontentString = [NSString trim:encodedcontentString];
    NSString*postBy = [userpref valueForKey:userId];
    NSString*u_typ =   @"user";
    NSString*feedTyp = @"association";;
    NSString*fileTyp = [userInfo objectForKey:feedFileTyp];
    NSString*fileURL = [userInfo objectForKey:feedFileURL];
    NSString *feedId=    [userpref objectForKey:feedID];
    NSString *thumbURL = [userInfo objectForKey:feedVideoThumbURL];
    NSString*encodedfileURLString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (CFStringRef)fileURL,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8 ));
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=Edit_Post_Feed"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    // NSLog(@"request url: %@",request);
    NSString *postString =  [NSString stringWithFormat:@"feed_id=%@&title=%@&content=%@&posted_by=%@&user_type=%@&feed_type=%@&file_type=%@&file_url=%@&meta_url=%@&feed_type_id=%@&auth_key=%@&format=%@&feed_kind=%@&video_image_url=%@&file_name=%@&file_description=",feedId?feedId:@"",encodedtitleString?encodedtitleString:@"",encodedcontentString?encodedcontentString:@"",postBy?postBy:@"",u_typ?u_typ:@"",feedTyp?feedTyp:@"",fileTyp?fileTyp:@"",encodedfileURLString?encodedfileURLString:@"",metaurl?metaurl:@"",passoId,u_authkey,frmt,feedkind?feedkind:@"",thumbURL?thumbURL:@"",filename?filename:@""];
    //NSLog(@"post string for edit feed: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}


#pragma mark Set Edit comment Feed Post Request
- (NSMutableURLRequest*)DocquityEditCommentRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *uId=    [userpref objectForKey:userId];    //mandatory
    NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
    NSString *feedId=    [userInfo objectForKey:feedID];
    NSString *comId=    [userInfo objectForKey:CommentID];
    NSString *newComment=    [userInfo objectForKey:feedComment];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=Edit_Comment_Feed"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"feed_id=%@&comment_id=%@&content=%@&commented_by=%@&user_type=user&authkey=%@&format=%@",feedId?feedId:@"",comId?comId:@"",newComment?newComment:@"",uId?uId:@"",u_authkey?u_authkey:@"",frmt];
    // NSLog(@"postString for edit comment = %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Country_Details
- (NSMutableURLRequest*)DocquityCountryDetailsRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSString*accessCode = @"d3aeebaa5a03986262f51ced95b4ccac";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=Country_Details"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"access_code=%@&format=%@",accessCode?accessCode:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Invitation_List
- (NSMutableURLRequest*)DocquityInvitationRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *uId=    [userpref objectForKey:userId]; //mandatory
    NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=Invitation_List"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"user_id=%@&user_auth_key=%@&format=%@",uId?uId:@"",u_authkey?u_authkey:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Set Send_Invite_My_Association_Member
- (NSMutableURLRequest*)DocquityInviteMyAssociationMemberRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *invitee_uId =  [userpref objectForKey:userId]; //mandatory
    NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
    NSString *contactUserId= [userInfo objectForKey:inviteMemberId]; //mandatory
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=Send_Invite_My_Association_Member"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"invitee_user_id=%@&contact_list=%@&authkey=%@&format=%@",invitee_uId?invitee_uId:@"",contactUserId?contactUserId:@"",u_authkey?u_authkey:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark - DocquityGetDocqumentListRequest
- (NSMutableURLRequest*)DocquityGetDocqumentListRequest:(NSDictionary*)userInfo
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString*frmt =@"json"; //mandatory
    NSString*accessCode = @"d3aeebaa5a03986262f51ced95b4ccac";
    NSString *associationId = [userpref objectForKey:documentbasedAssoId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=Document_List"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"access_key=%@&association_id=%@&format=%@",accessCode?accessCode:@"",associationId?associationId:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark submit ReportBug
- (NSMutableURLRequest*)DocquityReportBug:(NSDictionary*)userInfo
{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString*frmt =@"json"; //mandatory
    NSString *auth_key= [userpref objectForKey:userAuthKey];
    NSString *uid =  [userpref objectForKey:userId];
    NSString *device_type = @"ios";
    NSString *message =  [userInfo objectForKey:@"msg"];
    NSString*encodedMsgString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                      NULL,
                                                                                                      (CFStringRef)message,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                      kCFStringEncodingUTF8 ));
    
    encodedMsgString = [NSString trim:encodedMsgString];
    NSString *screenshot =   [userInfo objectForKey:profileImage];
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString *sysname  = [UIDevice currentDevice].systemName;
    NSString *model = [userInfo valueForKey:@"iPhoneModel"];
    NSString *sysVer = [UIDevice currentDevice].systemVersion;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=Report_Bug"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"user_auth_key=%@&user_id=%@&device_type=%@&message=%@&screenshot=%@&app_version=%@&build=%@&system_version=%@&system_name=%@&model=%@&format=%@",auth_key?auth_key:@"",uid?uid:@"",device_type?device_type:@"",encodedMsgString?encodedMsgString:@"",screenshot?screenshot:@"",version?version:@"",build?build:@"",sysVer?sysVer:@"",sysname?sysname:@"",model?model:@"",frmt];
    // NSLog(@"Post string = %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Association List Open
- (NSMutableURLRequest*)DocquityAssociationListOpen:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSString*accessCode = @"d3aeebaa5a03986262f51ced95b4ccac";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WebUrl@"getApi.php?rquest=Association_List_Open"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"access_key=%@&format=%@",accessCode?accessCode:@"",frmt];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Mobile Verification Otp Code
- (NSMutableURLRequest*)DocquityMobileVerificationOtpRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *mobile =  [userInfo objectForKey:user_mobileNo];
    NSString *cCode = [userInfo objectForKey:user_country_code];
    NSString *ip_add =   [userpref objectForKey:ip_address1];
    NSString *device_type = @"ios";
    NSString *devicedetails =[self adddeviceInfodetails:nil];
    NSString *devToken = [AppDelegate appDelegate].deviceTokenString;
    NSString *app_version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    devicedetails = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,(CFStringRef)devicedetails,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=mobile_verification_otp_request"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"country_code=%@&mobile=%@&device_info=%@&format=%@&ip_address=%@&device_type=%@&app_version=%@&device_token=%@",cCode?cCode:@"",mobile?mobile:@"",devicedetails?devicedetails:@"",frmt,ip_add,device_type,app_version,devToken];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Mobile Reset Otp Code
- (NSMutableURLRequest*)DocquityMobileResendOTPRequest:(NSDictionary*)userInfo
{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *mobile =  [userInfo objectForKey:user_mobileNo];
    NSString *cCode = [userInfo objectForKey:user_country_code];
    NSString *token =   [userpref objectForKey:API_Token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=resend_otp"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"country_code=%@&mobile=%@&token_id=%@",cCode?cCode:@"",mobile?mobile:@"",token];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Get Mobile Verification Otp Code
- (NSMutableURLRequest*)DocquityMobileVerificationRequest:(NSDictionary*)userInfo
{
    NSString*frmt =@"json"; //mandatory
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *mobile =  [userInfo objectForKey:user_mobileNo];
    NSString *tokenid =  [userInfo objectForKey:API_Token];
    NSString *otpCode =  [userInfo objectForKey:user_OTP];
    NSString *cCode = [userInfo objectForKey:user_country_code];
    NSString *ip_add =   [userpref objectForKey:ip_address1];
    NSString *device_type = @"ios";
    NSString *devicedetails =[self adddeviceInfodetails:nil];
    NSString *devToken = [AppDelegate appDelegate].deviceTokenString;
    NSString *app_version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    devicedetails = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,(CFStringRef)devicedetails,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=mobile_verification_v2"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"token_id=%@&otp=%@&country_code=%@&mobile=%@&device_info=%@&format=%@&ip_address=%@&device_type=%@&app_version=%@&device_token=%@",tokenid,otpCode,cCode?cCode:@"",mobile?mobile:@"",devicedetails?devicedetails:@"",frmt,ip_add,device_type,app_version,devToken];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark Set Claim Account
- (NSMutableURLRequest*)DocquitySetClaimAccount:(NSDictionary*)userInfo
{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *tokenid =  [userpref objectForKey:API_Token];
    NSString *fname =  [userInfo objectForKey:dc_firstName];
    NSString *lname =  [userInfo objectForKey:dc_lastName];
    NSString *country = [userInfo objectForKey:user_country];
    NSString *email =  [userInfo objectForKey:emailId1];
    NSString *medReg =  [userInfo objectForKey:UserRegNo];
    NSString *idproof =  [userInfo objectForKey:Image1];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=claim_account_readonly"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"token_id=%@&first_name=%@&last_name=%@&country=%@&email=%@&registration_id=%@&validate_url=%@",tokenid,fname?fname:@"",lname?lname:@"",country?country:@"",email?email:@"",medReg?medReg:@"",idproof?idproof:@""];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

#pragma mark - Claim By Invite Code
- (NSMutableURLRequest*)DocquityClaimByInviteCode:(NSDictionary*)userInfo
{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *tokenid =  [userpref objectForKey:API_Token];
    NSString *icCode =  [userInfo objectForKey:inviteCode];
    NSString *assoID = [userInfo objectForKey:assoId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"set?rquest=claim_by_invite_code"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"token_id=%@&invite_code=%@&association_id=%@",tokenid,icCode?icCode:@"",assoID?assoID:@""];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}


#pragma mark *******************************************************************************************
#pragma mark sendRequestToServer
- (void) sendRequestToServer:(NSDictionary *)userInfo withDataDic:(NSDictionary *)datadic
{
    // if Device is not connected with internet
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView* aAlert = [[UIAlertView alloc] initWithTitle:@"Data Connection Status" message:@"Your Wi-Fi is not working.\nYour Cellular data is not working." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
        if (currentRequestType==kGetAssociationListRequest) {
        }
        
        else if (currentRequestType==kGetCountryDetailsRequest) {
        }
        
        else{
            [aAlert show];
        }
        
        [[AppDelegate appDelegate] hideIndicator];//todo
        return;
    }
    // Request
    NSMutableURLRequest *request;
    currentRequestType = ((NSNumber*)[userInfo objectForKey:keyRequestType1]).intValue;
    switch (currentRequestType)
    {
            
        case kSetFeedRequest:
            request = [self  DocquitySetFeedRequest:datadic];
            break;
  
        case kEditCommentRequest:
            request = [self  DocquityEditCommentRequest:datadic];
            break;
            
        case kSetUploadFileRequest :
            request = [self DocquitySetUploadFileRequest:datadic];
            break;
            
        case kGetAssociationListRequest:
            request = [self  DocquityUser_Association_ListRequest:datadic];
            break;
        
        case kSetEditPostFeedRequest:
            request = [self  DocquityEditActionFeedPostRequest:datadic];
            break;
            
        case kGetMetaDataRequest:
            request = [self  DocquitygetMetaDataRequest:userInfo];
            break;
            
        case kGetCountryDetailsRequest:
            request = [self  DocquityCountryDetailsRequest:userInfo];
            break;
            
        case kGetInvitationRequest:
            request = [self  DocquityInvitationRequest:userInfo];
            break;
            
        case kSetInviteMyAssociationMember:
            request = [self DocquityInviteMyAssociationMemberRequest:datadic];
            break;
            
        case kGetDocumentList:
            request = [self DocquityGetDocqumentListRequest:datadic];
            break;
            
        case kReportBug:
            request = [self DocquityReportBug:datadic];
            break;
            
        case kAssociationListOpen:
            request = [self DocquityAssociationListOpen:datadic];
            break;
            
        case kMobileVerificationOtpRequest:
            request = [self DocquityMobileVerificationOtpRequest:datadic];
            break;
            
        case kMobileVerification:
            request = [self DocquityMobileVerificationRequest:datadic];
            break;
            
        case kSetClaimAccount:
            request = [self DocquitySetClaimAccount:datadic];
            break;

        case kMobileResendOTP:
            request = [self DocquityMobileResendOTPRequest:datadic];
            break;
            
        default:
            break;
    }
    
    NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection)
    {
        receivedData=[[NSMutableData alloc]init];
    }
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)connError
{
    //UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not connect to Docquity service.\nPlease try again later." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
    
    if (currentRequestType==kGetAssociationListRequest) {
    }
    else if (currentRequestType==kGetCountryDetailsRequest) {
    }
 
    else if (currentRequestType==  kSetUploadFileRequest) {
    }
    else if (currentRequestType==  kGetMetaDataRequest) {
    }
    else {
    // [av show];
    }
    [self.delegate requestError];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSString *string = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
    //  NSLog(@"received data fro ws ==%@",string);
    SBJsonParser *obj = [[SBJsonParser alloc] init];
    NSDictionary *jsonDic =  [obj objectWithString:string];
    //  NSLog(@"Json after parsing =%@",jsonDic);
    //        daataArray = [[NSMutableArray alloc] init];
    //        if(jsonArray)
    //            [daataArray addObject:jsonArray];
    //  [self.delegate requestFinished:<#(NSMutableArray *)#>];
    [self.delegate requestFinished:jsonDic];
}

-(NSMutableArray*)getResults
{
    return daataArray;
}

-(NSString *)replcaeSpecialCharacterFromString:(NSString *)originalStr
{
    NSString *str=[originalStr stringByReplacingOccurrencesOfString:@"&" withString:@"\\u0026"];
    return str;
}

-(NSString *)adddeviceInfodetails:(NSString *)deviceInfoStr{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    //NSLog(@"Carrier Name: %@", [carrier carrierName]);
    NSString *platform = [UIDevice currentDevice].model;
    NSString *str = [NSString stringWithFormat:@"Version - %@,Build number - %@,Carrier - %@,Model - %@System Name - %@,SystemVersion - %@,SystemName - %@",version,build,[carrier carrierName],platform,[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion,[UIDevice currentDevice].systemName];
    return str;
}

//-(NSString *)replcaeSpecialCharacterFromString:(NSString *)originalStr
//{
//    NSString *str=[originalStr stringByReplacingOccurrencesOfString:@"-" withString:@"\\u002D"];
//    return str;
//}

@end

