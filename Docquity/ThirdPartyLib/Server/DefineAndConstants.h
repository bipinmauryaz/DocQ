/*============================================================================
 PROJECT: Docquity
 FILE:    DefineAndConstant.h
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 13/08/15.
 =============================================================================*/

/*============================================================================
 PRIVATE MACRO
 =============================================================================*/
#define	ReleaseObject(obj)					if (obj != nil) { [obj release]; obj = nil; }

typedef enum TheRequestTypes1
{
    kGetFreiendlist = 1,                                       //Get friendlist
    kGetGroupImgRequest = 2,                                   //Get GroupImgrequest
    kGetFeedRequest = 3,                                       //GetFeedRequest
    kSetFeedRequest = 4,                                       //SetFeedRequest
    kSetFeedLikeRequest = 5,                                   //SetFeedLikeRequest
    kSetUploadFileRequest = 6,                                 //SetUploadFileRequest
    kGetMetaDataRequest= 7,                                    //Set MetaDataRequest
    kGetAssociationListRequest = 8,                            //GetAssociationListRequest
    kSetDeleteFeedRequest = 9,                                 //SetDeleteFeedRequest
    kSetEditPostFeedRequest = 10,                              //SetEditPostFeedRequest
    kEditCommentRequest = 11,                                  //Edit Comment Request for the feed
    kGetCountryDetailsRequest = 12,                            //GetCountryDetailsRequest
    kGetFeedCasesRequest = 13,                                 //GetFeedCasesRequest
    kGetInvitationRequest = 14,                                //GetInvitationRequest
    kSetInviteMyAssociationMember = 15,                        //Send_Invite_My_Association_Member
    kGetDocumentList = 16,                                     //GetDocumentList Request
    kReportBug =17,                                            //UserReportBug Request
    kAssociationListOpen = 18,                                 //Association List Open
    kMobileVerificationOtpRequest = 19,                        //mobile_verification_otp_request
    kMobileVerification  = 20,                                 // Mobile OTP Verification
    kSetClaimAccount = 21,                                     //Get Claim Account By Mobile
    kClaimByInviteCode = 22,                                   //Get Claim Account By Invite code
    kValidatedUserOnSplash = 23,                               //Get validated user
    kMobileResendOTP = 24,                                     //Get Resend OTP
    kSetProfileImgRequest = 25,                                //Set Profile Image
    
}ServerRequestType1;

/*============================================================================
 PRIVATE MACRO
 =============================================================================*/
#define keyRequestType1	@"RequestType"
#define EXPIRATION_STRING  @"Background session will expire in one minute."
#define OK_STRING @"OK"

#pragma mark - Demo Server
//#define Localytics_TOKEN @"250ef1a4097c2a05d4d91dd3-0348db1e-2329-11e6-44a9-00adad38bc8d"
//#define  registrationUrl @"https://demo.docquity.com/join.php"
//#define WebUrl @"https://demo.docquity.com/connect/webservice/"
//#define CMEGetWebUrl  @"https://demo.docquity.com/connect/webservice/cmeGet.php?rquest="
//#define CMESetWebUrl  @"https://demo.docquity.com/connect/webservice/cmeSet.php?rquest="
//#define InviteShareUrl @"https://demo.docquity.com/invite/"
//#define ImageUrl @"https://demo.docquity.com/"
//#define chatServer @"@conference.demo.docquity.com"
//#define serverKeyword @"@demo"
//#define qbAppid 47664
//#define qbAuthKey @"6FtbNYrLz7edAEV"
//#define qbAuthSecret @"8J4JyAuBHeW48Gw"
//#define qbAccountKey @"xpx7sirbqFjMZzNiNq6r"

//#pragma mark - Production Server
/*
#define Localytics_TOKEN @"a04cc771ffe7ebf72a97ac5-d56e0f92-c038-11e5-6098-002dea3c3994"
#define  registrationUrl @"https://docquity.com/join.php"
#define AuthorizationAppKey @"9A@I$SR6!P$0#I@5?S@8?H"
#define NewWebUrl @"https://docquity.com/connect/services/"
#define WebUrl  @"https://docquity.com/connect/webservice/"
#define CMEGetWebUrl  @"https://docquity.com/connect/webservice/cmeGet.php?rquest="
#define CMESetWebUrl  @"https://docquity.com/connect/webservice/cmeSet.php?rquest="
#define InviteShareUrl @"https://docquity.com/invite/"
#define ImageUrl @"https://docquity.com/"
#define tncUrl @"https://docquity.com/privacy.php"
#define qbAppid 52212
#define qbAuthKey @"V-jLcBzARm4UpZO"
#define qbAuthSecret @"NPnGG4HS4agamKc"
#define qbAccountKey @"pPSNVTgqjGKxHy5hvt76"
*/

//#pragma mark - Staging Server

#define AuthorizationAppKey @"H2OH2SO4OOHCH4H2O2"
#define NewWebUrl @"http://dev.docquity.com/connect/services/"
#define Localytics_TOKEN @"99289a289f209aaf4aaffc2-f9c8fae8-2329-11e6-1784-00cef1388a40"
#define registrationUrl @"http://dev.docquity.com/join.php"
#define WebUrl @"http://dev.docquity.com/connect/webservice/"
#define CMEGetWebUrl @"http://dev.docquity.com/connect/webservice/cmeGet.php?rquest="
#define CMESetWebUrl @"http://dev.docquity.com/connect/webservice/cmeSet.php?rquest="
#define InviteShareUrl @"http://staging.docquity.com/invite/"
#define ImageUrl @"http://dev.docquity.com/"
#define tncUrl @"http://docquity.com/privacy.php"
#define qbAppid 47664
#define qbAuthKey @"6FtbNYrLz7edAEV"
#define qbAuthSecret @"8J4JyAuBHeW48Gw"
#define qbAccountKey @"xpx7sirbqFjMZzNiNq6r"


// Amazon Testing server
//#define Localytics_TOKEN @"9289a289f209aaf4aaffc2-f9c8fae8-2329-11e6-1784-00cef1388a40"
//#define registrationUrl @"http://52.220.199.16/join.php"
//#define WebUrl          @"http://52.220.199.16/connect/webservice/"
//#define CMEGetWebUrl    @"http://52.220.199.16/connect/webservice/cmeGet.php?rquest="
//#define CMESetWebUrl    @"http://52.220.199.16/connect/webservice/cmeSet.php?rquest="
//#define InviteShareUrl  @"http://54.179.140.53/invite/"
//#define ImageUrl        @"http://52.220.199.16/"
//#define chatServer @"@conference.staging.docquity.com"
//#define serverKeyword @"@staging"
//#define qbAppid 47664
//#define qbAuthKey @"6FtbNYrLz7edAEV"
//#define qbAuthSecret @"8J4JyAuBHeW48Gw"
//#define qbAccountKey @"xpx7sirbqFjMZzNiNq6r"

#define SupportEmail @"support@docquity.com"
//-----------NO Internet text -------- //
#define NoInternetTitle @"No Internet Connection"
#define NoInternetMessage @"It seems like you don't have internet connection, please check your internet connection."
#define Thankmsg @"thankmsg"
#define defaultErrorMsg @"Something went wrong. Please try again."
#define InternetSlow @"Connection Timeout"
#define InternetSlowMessage @"Network connection was lost."
#define courseIncompletedTitle @"Course not completed"
#define cmeExpireMsg @"This course is no longer valid."
#define examReviewMsg @"You have completed all the questions for this course."
#define submitOfflineMsg @"You seem to be offline. Your course will be auto-submitted as soon as you are connected to the internet."
#define NotSubmitted @"Not Submitted"
#define backConfirmationTitle @"Do you really want to go back?"
#define backConfirmationMsg @"You will lose all your previous responses."
#define resultNotificationMsg @"Your course has been submitted. Click to view result"
#define postCertDocqMsg @"Fellow Doctors, I earned CPD credits on Docquity CME for the above course. Click here to get your CPD credits now."
#define unableCertMsg @"Unable to fetch your transcript. Please send us an email by clicking on \'Write us\' and we will get back to you shortly."
#define cmePostMsg @"Posted successfully. Please view post."
#define QBUserNotExistMsg @"needs to update Docquity for you to chat. Click OK to remind him."
#define cmeCompletedEmpty @"You have not completed any CME course yet!"
#define cmeAvailEmpty @"No CME course available. We will notify you on new course listing."
#define docUserMsg @"If you are a doctor, please input the mobile number which you have provided to your country's medical association."
#define kquestionValidationMsg @"Please choose at least one answer."
#define kdeletePostConfirmation @"Are you sure you want to permanently remove this post from Docquity?"
#define kdeletePostTitle @"Delete Post"
#define kMobileNotExistsMsg @"Mobile number is not linked to any account."
#define kSignUPMsg @"Sign up to Docquity"
#define kTryAgainMsg @"Try Again"
#define kCountinueMsg @"Countinue"
#define kReTryAgainMsg @"Retry"
#define kMailTitle @"No Mail Accounts"
#define kMailMsg @"Please set up a Mail account in order to send email."
#define kvalidateFirstname @"Please enter valid first name."
#define kvalidateEnterFirstname @"Please enter first name."
#define kvalidatelastname @"Please enter valid last name."
#define kvalidateEmail @"Please enter valid email."
#define kInterestValidationMsg @"Please select at least one interest."
#define kInputMobileRegisterTitleMsg @"Please input the mobile number that you have provided to your country's medical association."
#define kInputMobileLoginTitleMsg   @"Enter your mobile number."

//-------OTP Verification---------//
#define user_OTP @"OTP"

//-------Registeration View---------//
#define profileImage @"profile_pic"                        //it will store user profile picture
#define profileImageTyp @"profile_pic_type"               //it will store user profile picture type
#define UserRegNo @"registration_no"                     //it will store user registration no
#define kUserRegNo @"registrationNumber"                //it will store user registration no
#define pageContentShows @"fromindex1"
#define casepageContentShows @"fromindex2"
#define commentpageContentShows @"fromindex3"
#define dc_firstName @"firstname"                              //it will store user first name
#define dc_lastName @"lastname"
#define ip_address1 @"ipadd"
#define API_Token @"token"                                   //it will store token
#define user_mobileNo @"mobile"                             //it will store mobile no
#define user_age  @"dob"                                   //it will store date of birth
#define user_gender @"gender"                             //it will store gender
#define user_country  @"country"                         //it will store country
#define  user_city  @"city"                             //it will store city
#define  user_state  @"state"                          //it will store state
#define DeviceID   @"deviceId"                        //it will store device Id
#define userId1 @"user_id"                           //it will store user Id
#define kinvitecode @"iccode"

//-------Set Association---------//
#define associationID @"pickedassoId"    //it will store education valve currently pursuing or not
#define assoId    @"association_id"     //it will store association id

//-------Image Upload---------//
#define Image1 @"image"                  //it will store image type
#define base64Str1 @"base64Encode"      //it will store image base64codestring
#define localimg @"localimgurl"        //it will store local image path *

//-------user record--------------//
#define custId @"custom_id"               //it will store association id
#define ownerCustId @"login_custom_id"   //it will store association id
#define multiJabId    @"multiJabberId"  //it will store association description
#define kDeviceType @"ios"
#define kAppVersion @"appVersion"
#define kLanguage @"en"
#define shareRefLink @"referal_link"      //it will store inviteReflink
#define AppName @"Docquity"              //it will store App Name for show anywhere we want.
#define jsonformat @"json"
#define kDeviceTokenKey @"devicetoken"
#define myAppVersion @"appVersion"
#define kApiVersion @"2.0"

//------login types--------//
#define signInnormal @"signIn"                      //first check that sign in or not
#define emailId1 @"emailId"                        //it will store user email address
#define kemailId @"email"                        //it will store user email address

#define useremail1 @"email"                       //it will store user email address
#define password1 @"password"                    //it will store user password
#define chatId1 @"chat_id"                      //it will store user chatId
#define userAuthKey @"user_auth_key"            //it will store user authkey
#define userId @"user_id"                      //it will store user id
#define jabberId @"jabber_id"                 //it will store jabeer id
#define kjabberName @"jabber_name"                 //it will store jabeer id
#define docSpecility @"docSpecilities"       //it will stored docspecilites

//-----create discussion for chat------//
#define    memberId  @"member_id"           //it will store member_id
#define    groomJabberId  @"groomJID"      //it will store room Jabber Id

//--------Create Group---------//
#define  groupName  @"group_name"       //it will store group_name
#define  groupID  @"group_id"          //it will store group_id

//--------invite code-----------//
#define    inviteCode  @"invite_code"                                   // it will store invite_code

//--------Whats Trending Feed------------//
#define    feedID  @"feed_id"                                          //it will store feed_id
#define    feedPostType  @"feed_type"                                 //it will store feed_type
#define    feedPostTitle  @"title"                                   //it will store title
#define    feedPostContent  @"content"                              //it will store content
#define    feedComment  @"comment"                                 //it will store comment
#define    CommentID  @"comment_id"                               //it will store comment ID
#define    feedFileImg  @"FeedImg"                               //it will store Feed Image
#define    feedFileTyp  @"file_type"                            //it will store file_type
#define    feedFileURL  @"file_url"                            //it will store file_url
#define    feedVideoThumbURL @"VideoThumbURL"                 //it will have video thumb
#define    feedKind  @"feed_kind"                            //it will Feed kind either post or cases
#define    metaURLs @"metaurl"                              //it will store meta url
#define    metaDataURL @"meta_url"                         //it will store data url
#define    timeInMS @"time"                               //first check current time
#define    gn_timeset @"time_interval"                   //first check time interval
#define    inviteMemberId @"id"                         //it will store invite member user id
#define    user_country_code  @"country_code"          //it will store country code
#define    documentbasedAssoId  @"association_id"     //it will store association_id
#define    docFileName  @"file_name"                 //it will File Name of document
#define    user_permission  @"permission"           //it will store check validate for readoOnly user
#define    kuniversity_name  @"university_name"     //it will store check validate for university_name
#define    kuniversity_id  @"university_id"        //it will store check validate for university_id
#define    kspeciality_name  @"speciality_name"     //it will store check validate for speciality_name
#define    kspeciality_id  @"speciality_id"        //it will store check validate for speciality_id
#define    kassociationName  @"association_name"   //it will store check validate for association_name


//--------App colors code------------//
#define kFontDescColor [UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0];
#define kFontTitleColor [UIColor colorWithRed:39.0/255.0 green:43.0/255.0 blue:45.0/255.0 alpha:1.0];
#define kFontDeactivateColor [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1.0];
#define kThemeColor [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
#define kLayerDeactivateColor [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1.0].CGColor;
#define korangeColor [UIColor colorWithRed:251.0/255.0 green:127.0/255.0 blue:0.0/255.0 alpha:1.0];
#define kYellowColor [UIColor colorWithRed:252.0/255.0 green:206.0/255.0 blue:0.0/255.0 alpha:1.0];
#define kCOAColor [UIColor colorWithRed:103.0/255.0 green:195.0/255.0 blue:90.0/255.0 alpha:1.0];
#define kNewCOAColor [UIColor colorWithRed:43.0/255.0 green:181.0/255.0 blue:115.0/255.0 alpha:1.0];
#define kBorderLayerColor [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1.0].CGColor;
#define kBorderBGColor [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1.0];

//-------- Feed Type Identifier ------------//

#define    kFeedTypeImage   @"image"
#define    kFeedTypeNormal  @""
#define    kFeedTypeVideo   @"video"
#define    kFeedTypeMeta    @"link"
#define    kFeedTypeDoc     @"document"
#define    kfeedImgPlaceholder [UIImage imageNamed:@"img-not.png"]
