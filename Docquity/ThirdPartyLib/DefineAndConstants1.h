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
    kGetSpecialityRequest = 1,                                  //Get Speciality request
    kLoginRequest = 2,                                          //Get Login request
    kGetForgotPasswordRequest=3,                                //Get Forgot Password request
    kGetProfileRequest=4,                                       //Get Profile request
    kGetDoctorSearchListRequest=5,                              //Get DoctorList request
    kSetProfileRequest = 6,                                     //Set Profile request
    kSetCreateAssociationRequest = 7,                           //Set CreateAssociation request
    kSetCreateEducationRequest = 8,                             //Set CreateEducation request
    kSetCreateSpecialityRequest = 9,                            //Set CreateSpeciality request
    kSetCreateInterestRequest = 10,                             //Set CreateInterest request
    kSetCreateResearchRequest = 11,                             //Set CreateResearch request
    kSetCreateProjectRequest = 12,                              //Set CreateProject request
    kSetCreateAwardRequest = 13,                                //Set CreateAward request
    kSetRemoveAssociationRequest = 14,                          //Set RemoveAssociation request
    kSetRemoveEducationRequest = 15,                            //Set RemoveEducation request
    kSetRemoveResearchRequest = 16,                             //Set RemoveResearch request
    kSetRemoveProjectRequest = 17,                              //Set RemoveProject request
    kSetProfileImgRequest = 18,                                 //Set ProfilePic request
    kSetAssociationRequest = 19,                                //Set Association Profile request
    kSetEducationRequest = 20,                                  //Set Education Profile request
    kSetInterestRequest = 21,                                   //Set Interest Profile request
    kSetSummaryRequest = 22,                                    //Set  Profile Summary request
    kSetRemoveInterestRequest = 23,                             //Set RemoveInterest request
    kGetSearchListRequest = 24,                                 //Get Search request
    kGetFreiendlist = 25,                                       //Get FriendList For connection request
    kSetConnectionFriendRequest = 26,                           //Set Connection FriendRequest
    kSetConnectionAcceptFriendRequest = 27,                     //Set Connection AcceptFriend Request
    kSetConnectionDeclineFriendRequest = 28,                    //Set Connection Decline Friend Request
    kSetCreateDiscussionRequest = 29,                           //Set CreateDiscussion request
    kSetAddMemberToDiscussionRequest = 30,                      //Set AddMemberTo Discussion request
    kSetRemoveFromDiscussionRequest = 31,                       //Set Remove From Discussion request
    kSetCreateGroupRequest = 32,                                //Set Create Group request
    kSetAddMemberToGroupRequest = 33,                           //Set Add Member To Group request
    kSetRemoveMemberFromGroupRequest = 34,                      //Set Remove Member From  Group request
    kSetEditGroupRequest = 35,                                  //Set Edit  Group request
    kSetRemoveGroupRequest = 36,                                //Set Remove  Group request
    kGetGroupDetailsRequest = 37,                               //Get  Group Details request
    kSetSpecialityRequest = 38,                                 //Set Add Speciality request
    kSetRemoveSpecialityRequest = 39,                           //Set RemoveSpeciality request
    kGetDiscussionFriendListRequest = 40,                       //Get DiscussionFriend List request
    kSetImgSendonChatRequest = 41,                              //Set ImageSending request
    kGetGroupImgRequest = 42,                                   //Get GroupImgrequest
    kGetCheckInvitation = 43,                                   //Get CheckInvitation
    kSetCheckInvitationByInfo = 44,                             //Get CheckInvitationByInfo
    kSetActivateUserAccountOnInvite = 45,                       //Get Activate_User_Account_On_Invite
    kGetFeedRequest = 46,                                       //GetFeedRequest
    kGetFeedCommentRequest = 47,                                //GetFeedComment
    kSetFeedRequest = 48,                                       //SetFeedRequest
    kSetFeedCommentRequest = 49,                                //SetFeedCommentRequest
    kSetFeedLikeRequest = 50,                                   //SetFeedLikeRequest
    kSetTagMsgRequest = 51,                                     //SetTagMsgRequest
    kSetTagMsgDataRequest = 52,                                 //SetTagMsgDataRequest
    kSetUploadFileRequest = 53,                                 //SetUploadFileRequest
    kUpdateDeviceTokenRequest = 54,                             //UpdateDeviceTokenRequest
    kGetFeedLikeRequest = 55,                                   //getFeed Like List
    kSetBadgeZeroRequest = 56,                                  //set badge zero request
    kSetOTPRequest=57,                                          //Set OTP request
    kSetNewResetPasswordRequest=58,                             //set NewResetPasswordRequest
    kSetICNumberVerifyOtpRequest=59,                            //Set ICNumberVerifyOtpRequest
    kSetUpdateMobNoSendOtpRequest=60,                           //Set UpdateMobNoSendOtpRequest
    kGetMetaDataRequest=61,                                     //Set MetaDataRequest
    kGetAssociationListRequest = 62,                            //GetAssociationListRequest
    kSetDeleteFeedRequest = 63,                                 //SetDeleteFeedRequest
    kSetEditPostFeedRequest = 64,                               //SetEditPostFeedRequest
    kGetShareFeedPostRequest = 65,                              //GetShareFeedPostRequest
    kDeleteCommentRequest = 66,                                 //Delete Comment Request for the feed
    kEditCommentRequest = 67,                                   //Edit Comment Request for the feed
    kSetGrowYourNetworkRequest = 68,                            //SetGrowYourNetworkRequest
    kGetCountryDetailsRequest = 69,                             //GetCountryDetailsRequest
    kGetFeedCasesRequest = 70,                                  //GetFeedCasesRequest
    kGetInvitationRequest = 71,                                 //GetInvitationRequest
    kSetInviteMyAssociationMember = 72,                         //Send_Invite_My_Association_Member
    kGetClaimAccountByMobile = 73,                              //Get Claim Account By Mobile
    kOpenUserIdentityProof = 74,                                //Set Open User Identity Proof
    kGetDocumentList = 75,                                      //GetDocumentList Request
    kMactchOtpNewUser = 76,                                     //Match OTP For New User
    kSendOtpNewUser = 77,                                       //Set Send OTP To New User
    kUserTrackerRegistrationProcess = 78,                       //UserTrackerRegistrationProcess
    kReportBug =79,                                             //UserReportBug Request
    kNewSearchListRequest = 80,                                 //NewSearchList Request
    kNewUserSearchRequest = 81,                                  //NewUserSearch Request
    kAssociationListOpen = 82,                                  //Association List Open
    kMobileVerificationOtpRequest = 83,                         //mobile_verification_otp_request
    kMobileVerification  = 84,                                  // Mobile OTP Verification
    kSetClaimAccount = 85,                                      //Get Claim Account By Mobile
    kClaimByInviteCode = 86,                                    //Get Claim Account By Invite code
    kValidatedUserOnSplash = 87,                                //Get validated user
    kMobileResendOTP = 88,                                      //Get Resend OTP
    
validated_user_on_splash
}ServerRequestType1;

/*============================================================================
 PRIVATE MACRO
 =============================================================================*/
#define keyRequestType1	@"RequestType"
#define EXPIRATION_STRING  @"Background session will expire in one minute."
#define OK_STRING @"OK"
#define myAppVersion @"appVersion"

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

#pragma mark - Production Server
#define Localytics_TOKEN @"a04cc771ffe7ebf72a97ac5-d56e0f92-c038-11e5-6098-002dea3c3994"
#define  registrationUrl @"https://docquity.com/join.php"
#define WebUrl  @"https://docquity.com/connect/webservice/"
#define CMEGetWebUrl  @"https://docquity.com/connect/webservice/cmeGet.php?rquest="
#define CMESetWebUrl  @"https://docquity.com/connect/webservice/cmeSet.php?rquest="
#define InviteShareUrl @"https://docquity.com/invite/"
#define ImageUrl @"https://docquity.com/"
#define chatServer @"@conference.chat.docquity.com"
#define tncUrl @"https://docquity.com/terms-and-condition.php"
#define serverKeyword @"@chat"


//#pragma mark - Staging Server
//#define Localytics_TOKEN @"99289a289f209aaf4aaffc2-f9c8fae8-2329-11e6-1784-00cef1388a40"
//#define registrationUrl @"https://staging.docquity.com/join.php"
//#define WebUrl  @"https://staging.docquity.com/connect/webservice/"
//#define CMEGetWebUrl  @"https://staging.docquity.com/connect/webservice/cmeGet.php?rquest="
//#define CMESetWebUrl  @"https://staging.docquity.com/connect/webservice/cmeSet.php?rquest="
//#define InviteShareUrl @"https://staging.docquity.com/invite/"
//#define ImageUrl @"https://staging.docquity.com/"
//#define chatServer @"@conference.staging.docquity.com"
//#define tncUrl @"https://docquity.com/terms-and-condition.php"
//#define serverKeyword @"@staging"


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
#define submitOfflineMsg @"You seem to be offline. Your course will be auto-submitted as soon as you are connecteed to the internet."
#define NotSubmitted @"Not Submitted"
#define backConfirmationTitle @"Do you really want to go back?"
#define backConfirmationMsg @"You will lose all your previous responses."
#define resultNotificationMsg @"Your course has been submitted. Click to view result"
#define postCertDocqMsg @"Hey, I just succesfully completed this CME course on Docquity..."

#define unableCertMsg @"Unable to fetch your transcript. Please send us an email by clicking on \'Write us\' and we will get back to you shortly."

#define cmePostMsg @"Posted successfully. Please view post."


//-------URL login Services---------//
#define regspcelId @"specialityId"          //it will store specel_id
#define regspcelName @"specialityName"     //it will store specel_name
#define shareRefLink @"referal_link"      //it will store inviteReflink
#define shareDeepLink @"sharedeeplink"   //it will store DeepReflink
#define AppName @"Docquity"             //it will store App Name for show anywhere we want.
#define jsonformat @"json";

//-------OTP Verification---------//
#define user_OTP @"OTP"
#define ic_verify_OTP @"verifyOTP"
#define dataContactArray @"contact_list"

//-------Update Mobile No---------//
#define user_MobUpdatecustId @"mobUpdate_custId"

//-------change New Password---------//
#define user_newpassword @"newpassword"
#define user_custId @"u_custId"
#define kDeviceTokenKey @"devicetoken"

//-------Registeration View---------//
#define profileImage @"profile_pic"                   //it will store user profile picture
#define profileImageTyp @"profile_pic_type"          //it will store user profile picture type
#define UserRegNo @"registration_no"                //it will store user registration no
#define pageContentShows @"fromindex1"
#define casepageContentShows @"fromindex2"
#define commentpageContentShows @"fromindex3"

#define firstName1 @"first_name"
#define dc_firstName @"firstname"                                 //it will store user first name
#define dc_lastName @"lastname"
#define ip_address @"ipadd"
#define API_Token @"token"  //it will store token
//it will store user first name
#define lastName1 @"last_name"                                  //it will store user last name
#define aptContact @"appointment_contact"                      //it will store appoinment date
#define practiceSince1 @"practice_since"                      //it will store practice since
#define officeContact1 @"office_contact"                     //it will store office contact
#define user_mobileNo @"mobile"                             //it will store mobile no
#define user_age  @"dob"                                   //it will store date of birth
#define user_gender @"gender"                             //it will store gender
#define user_country  @"country"                         //it will store country
#define  user_city  @"city"                             //it will store city
#define  user_state  @"state"                          //it will store state
#define user_language @"language"                     //it will store language
#define user_youtube_url @"youtube_url"              //it will store youtube_url
#define user_twitter_url @"twitter_url"             //it will store twitter_url
#define user_linkedin_url @"linkedin_url"          //it will store linkedin_url
#define DeviceID   @"deviceId"                    //it will store device Id
#define SystemName   @"Source"                   //it will store source type like ios/android/windows
#define userStatus @"Status"                    //it will store user status
#define userId1 @"user_id"                     //it will store user Id
#define user_spcl @"speciality"               //it will store specialization
#define ccode @"country_code"

//-------Set Education---------//
#define QuaLevel1 @"QuaLevel"                    //it will store qualification
#define EduSpe1 @"EduSpe"                       //it will store education specialization
#define InstName1 @"InstName"                  //it will store institution name
#define course1 @"course"                     //it will store course type
#define YOP1 @"YOP"                          //it will store year of passing
#define stYear @"fromYear"                  //it will store start year of passing
#define eduId @"education_id"              //it will store education_id
#define currPurInfo @"current_pursuing"   //it will store education valve currently pursuing or not

//-------Set Association---------//
#define associationID @"pickedassoId"             //it will store education valve currently pursuing or not
#define compName1 @"compName"                    // it will store company name
#define title1    @"title"                      //  it will store company title
#define comploc1  @"comploc"                   //   it will store company location
#define assoId    @"association_id"           //    it will store association id
#define assoStartMonth @"start_month"        //     it will store association start_month
#define assoEndMonth    @"end_month"        //      it will store  association end_month
#define assoStartDate @"start_date"        //       it will store association start_year
#define assoEndDate    @"end_date"        //        it will store  association end_year
#define assoDesc    @"description"       //         it will store association description
#define checkBoxInfo  @"currProf"       //          it will store association description
#define dMemberId    @"removeMember"   //           it will store association description


//-------Set Interest---------//
#define interest1 @"interestName"     //it will store interest name
#define intId @"interest_id"         //it will store interest_id

//-------Set Speciality---------//
#define spcl1 @"speciality_name"      //it will store speciality_name
#define spclId @"speciality_id"      //it will store speciality_id

//-------Image Upload---------//
#define Image1 @"image"                 //it will store image type
#define base64Str1 @"base64Encode"     //it will store image base64codestring
#define localimg @"localimgurl"       //it will store local image path

//-------Search----//
#define search1 @"search"                   //it will store search string
#define searchType1 @"searchType"          //it will store search type str
#define custId @"custom_id"               //it will store association id
#define ownerCustId @"login_custom_id"   //it will store association id
#define multiJabId    @"multiJabberId"  //it will store association description

//------login types--------//
#define signInnormal @"signIn"                      //first check that sign in or not
#define emailId1 @"emailId"                        //it will store user email address
#define useremail1 @"email"                       //it will store user email address
#define password1 @"password"                    //it will store user password
#define userAuthKey @"user_auth_key"            //it will store user authkey
#define userId @"user_id"                      //it will store user id
#define jabberId @"jabber_id"                 //it will store jabeer id
#define djabberId @"dJabId"                  //it will store jabeer id

//------summary-------------//
#define mesg @"bio"                         //it will store user summary text
#define defaultLate @"defaultLate"         //users default latitude get from getuserdetail webservice
#define defaultLong @"defaultLong"        //users default longitude get from getuserdetail
#define curIndex  @"curindex"            //it will stored curr index
#define docSpecility @"docSpecilities"   //it will stored docspecilites

//-------Edit Profile---------//
#define    interestID  @"interest_activity"
#define    abtData  @"about_user"
#define    pickUserAge  @"age"
#define    pickUserGender  @"gender"

//-----create discussion for chat------//
#define    discussid  @"discussion_id"        //it will store disscussion_id
#define    discussName  @"discussion_name"   //it will store disscussion_name
#define    memberId  @"member_id"           //it will store member_id
#define    groomJabberId  @"groomJID"      //it will store room Jabber Id
#define    droomJabberId  @"droomJID"     //it will store discussion room Jabber Id
#define    chatSenderImg  @"chatImg"     //it will store sender Image

//--------Create Group---------//
#define  groupName  @"group_name"       //it will store group_name
#define  groupID  @"group_id"          //it will store group_id
#define  groupOwnerID @"owner_id"     //it will store owner_id

//--------Edit Group Drtails-------//
#define  metaURLs @"metaurl"         //it will store owner_id
#define  metaDataURL @"meta_url"    //it will store owner_id

//--------Connection-------------//
#define    requesteeID  @"request"       //it will store requestee_id

//--------invite code-----------//
#define    inviteCode  @"invite_code"         //it will store invite_code
#define    instNumber  @"registeration_no"   //it will store instiute_No

//--------Whats Trending Feed------------//
#define    feedID  @"feed_id"                  //it will store feed_id
#define    feedPostType  @"feed_type"         //it will store feed_id
#define    feedPostTitle  @"title"           //it will store title
#define    feedPostContent  @"content"      //it will store content
#define    feedComment  @"comment"         //it will storecomment
#define    CommentID  @"comment_id"       //it will store comment ID
#define    feedFileImg  @"FeedImg"       //it will storecomment
#define    feedFileTyp  @"file_type"    //it will file_type
#define    feedFileURL  @"file_url"    //it will file_url
#define    feedVideoThumbURL @"VideoThumbURL"  //it will have video thumb
#define    feedKind  @"feed_kind"     //it will Feed kind either post or cases

#define timeInMS @"time"  //first check current time
#define gn_timeset @"time_interval"  //first check current time
#define inviteMemberId @"id"  //first check current time
#define user_country_code  @"country_code" //it will store country code
#define documentbasedAssoId  @"association_id" //it will store association_id
#define docFileName  @"file_name" //it will File Name of document

#define user_permission  @"permission" //it will File Name of document
#define kDeviceType @"ios"
#define kAppVersion @"appVersion"
#define kLanguage @"en"


#define kFontDescColor [UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0];
#define kFontTitleColor [UIColor colorWithRed:39.0/255.0 green:43.0/255.0 blue:45.0/255.0 alpha:1.0];
#define kFontDeactivateColor [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1.0];
#define kThemeColor [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];

#define kLayerDeactivateColor [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1.0].CGColor;

#define korangeColor [UIColor colorWithRed:251.0/255.0 green:127.0/255.0 blue:0.0/255.0 alpha:1.0];
#define kYellowColor [UIColor colorWithRed:252.0/255.0 green:206.0/255.0 blue:0.0/255.0 alpha:1.0];
#define kCOAColor [UIColor colorWithRed:103.0/255.0 green:195.0/255.0 blue:90.0/255.0 alpha:1.0];

#define kBorderLayerColor [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1.0].CGColor;

#define kBorderBGColor [UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1.0];



//-------- Tagging Feed-------------//
//#define    feedtagData  @"FeedImg"   //it will storecomment
//#define    feedmsgData  @"FeedImg"   //it will storecomment
//#define    feedtagType  @"FeedImg"   //it will storecomment
//#define    feedpktId @"FeedImg"   //it will storecomment
//#define    feedkeyJId  @"FeedImg"   //it will storecomment
//
//tagData
//msgData
//tagType
//pktId
//keyJId
