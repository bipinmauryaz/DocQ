/*============================================================================
 PROJECT: Docquity
 FILE:    DocquityServerEngine.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 30/08/16.
 =============================================================================*/

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DocquityServerEngine : NSObject

+ (DocquityServerEngine *)sharedInstance;

- (BOOL)isNetworkRechable;

#pragma mark - getAPI method
- (void) getAPI:(NSString *) urlString
         params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler;

#pragma mark - PostAPI method
- (void) postAPI:(NSString *) urlString
          params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler;

#pragma mark - PutAPI method
- (void) putAPI:(NSString *) urlString
         params: (NSDictionary *)params
completionHandler:(void (^)(id responseObject,NSError *error))completionHandler;

#pragma mark - deleteAPI method
- (void) deleteAPI:(NSString *) urlString
            params: (NSDictionary *)params
 completionHandler:(void (^)(id responseObject,NSError *error))completionHandler;

#pragma mark - getSearchDataApi
-(void)searchcheckingAPI :(NSString *)user_auth_key  offset:(NSString *)offset device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang keyword:(NSString *)keyword  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - new SearchUserApi
-(void)newSearchUserAPI :(NSString *)user_auth_key device_type:(NSString *)device_type  type:(NSString *)type type_id:(NSString *)type_id offset:(NSString *)offset limit:(NSString *)limit callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - updatedeviceToken
-(void)UpdateDeviceTokenWithUserID :(NSString *)user_id device_type:(NSString *)device_type  deviceToken:(NSString *)device_token format:(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - validate user Api
-(void)pendingUserValidateAuthKey :(NSString *)authkey countrycode:(NSString *)user_cCode  mobile:(NSString *)uMobile callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedLikeListApi
-(void)feedLikeListAPI :(NSString *)user_auth_key feed_id :(NSString *)feed_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getsingle_feed
-(void)singlefeedRequest :(NSString *)user_auth_key feed_id :(NSString *)feed_id device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getfeed_comment_like_list
-(void)feedcommentlikelistRequestWithAuthKey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getfeed_comment_reply_like_list
-(void)feedcommenreplytlikelistRequest :(NSString *)user_auth_key feed_id :(NSString *)feed_id  comment_id:(NSString *)comment_id comment_reply_id :(NSString *)comment_reply_id app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedlist_comment
-(void)feedlistcommentRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedlist_comment_reply
-(void)listCommentReplyRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id device_type :(NSString *)device_type  app_version :(NSString *)app_version lang:(NSString *)lang offset:(NSString *)offset limit:(NSString *)limit   callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedaction_comment_reply
-(void)feedactioncommentreplyRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id:(NSString *)comment_id comment_reply_id:(NSString *)comment_reply_id action:(NSString *)action reply:(NSString *)reply device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedcomment_like
-(void)feedcommentlikeRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - getFeedcomment_reply_like
-(void)feedcommentreplylikeRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id comment_reply_id :(NSString *)comment_reply_id device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - set Feed Action comment
-(void)feedcommentActionRequestWithAuthkey :(NSString *)user_auth_key feed_id :(NSString *)feed_id comment_id :(NSString *)comment_id userid :(NSString *)user_id action:(NSString *)action app_version :(NSString *)app_version format:(NSString *)format userType:(NSString*)user_type callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - check_user_permission
-(void)check_user_permissionRequest :(NSString *)user_auth_key callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - update_identification
-(void)update_identificationRequest :(NSString *)user_auth_key invite_code :(NSString *)invite_code identity_proof :(NSString *)identity_proof device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString *)lang  callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - Get Country Code - OLD API
-(void)GetCountryListWithAccesscode :(NSString *)access_code format :(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;

#pragma mark - Get Document List - OLD API
-(void)GetDocqumentListRequestWithAccessKey :(NSString *)access_key association_id:(NSString*)association_id format :(NSString *)format callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetUserPic Request Old Api
-(void)SetUserImgRequest :(NSString *)user_auth_key userpic:(NSString*)userpic  userpictype:(NSString*)userpictype app_version:(NSString*)app_version device_type:(NSString*)device_type  lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetProfile Request Old Api
-(void)SetProfileRequest :(NSString *)user_auth_key user_id:(NSString*)user_id firstname:(NSString*)firstname lastname:(NSString*)lastname email:(NSString*)email mobile:(NSString*)mobile country:(NSString *)country city:(NSString *)city state:(NSString *)state format:(NSString*)format callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetCreateInterest Request Old Api
-(void)SetCreateInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  interest_name:(NSString*)interest_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetInterest Request Old Api
-(void)SetInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id interest_id:(NSString*)interest_id interest_name:(NSString*)interest_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;


#pragma mark - SetRemoveInterest Request Old Api
-(void)SetRemoveInterestRequest :(NSString *)user_auth_key user_id:(NSString*)user_id interest_id:(NSString*)interest_id  format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;


#pragma mark - SetBiography Request Old Api
-(void)SetBiographyRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  bio:(NSString*)bio format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set Speciality Request Old Api
-(void)SetSpecialityRequest :(NSString *)user_auth_key user_id:(NSString*)user_id speciality_id:(NSString*)speciality_id speciality_name:(NSString*)speciality_name format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetRemoveSpeciality Request Old Api
-(void)SetRemoveSpecialityRequest :(NSString *)user_auth_key user_id:(NSString*)user_id speciality_id:(NSString*)speciality_id  format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;


#pragma mark - GET Speciality Request Old Api
-(void)GetSpecialityRequest :(NSString *)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetCreateEducation Request Old Api
-(void)SetCreateEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  school_name:(NSString*)school_name  degree:(NSString*)degree  end_date:(NSString*)end_date current_pursuing:(NSString*)current_pursuing format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetEducation Request Old Api
-(void)SetEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id education_id:(NSString*)education_id school_name:(NSString*)school_name  degree:(NSString*)degree  end_date:(NSString*)end_date current_pursuing:(NSString*)current_pursuing format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetRemoveEducation Request Old Api
-(void)SetRemoveEducationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  education_id:(NSString*)education_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetCreateAssociation Request Old Api
-(void)SetCreateAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id current_prof:(NSString*)current_prof association_name:(NSString*)association_name  position:(NSString*)position  location:(NSString*)location start_date:(NSString*)start_date end_date:(NSString*)end_date start_month:(NSString*)start_month end_month:(NSString*)end_month  format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetAssociation Request Old Api
-(void)SetAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id association_id:(NSString*)association_id current_prof:(NSString*)current_prof association_name:(NSString*)association_name  position:(NSString*)position  location:(NSString*)location start_date:(NSString*)start_date end_date:(NSString*)end_date start_month:(NSString*)start_month end_month:(NSString*)end_month format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetRemoveAssociation Request Old Api
-(void)SetRemoveAssociationRequest :(NSString *)user_auth_key user_id:(NSString*)user_id  association_id:(NSString*)association_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Send ConnectionFriend  Request Old Api
-(void)SendConnectionFriendRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set Connection Decline Friend Request Old Api
-(void)SetConnectionDeclineFriendRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - SetConnectionAcceptFriendRequest Request Old Api
-(void)SetConnectionAcceptFriendRequesRequest :(NSString *)user_auth_key requester_id:(NSString*)requester_id  requestee_id:(NSString*)requestee_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set RemoveGroup exit Request Old Api
-(void)SetRemoveGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id member_id:(NSString*)member_id  removeby:(NSString*)removeby format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set SetEdit/Update GroupRequest Old Api
-(void)SetEditGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id group_name:(NSString*)group_name owner_id:(NSString*)owner_id group_pic:(NSString*)group_pic group_pic_type:(NSString*)group_pic_type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Get Group Details Request Old Api
-(void)GetGroupDetailsRequest :(NSString *)user_auth_key user_id:(NSString*)user_id group_id:(NSString*)group_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set Remove MemberFromGroup Request Old Api
-(void)SetRemoveMemberFromGroupRequest :(NSString *)user_auth_key group_id:(NSString*)group_id member_id:(NSString*)member_id removeby:(NSString*)removeby format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set Sender Image Chat Request Old Api
-(void)SetImgSenderChatRequest :(NSString *)image type:(NSString*)type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set CreateGroup Request Old Api
-(void)SetCreateGroupRequest :(NSString *)user_auth_key  owner_id:(NSString*)owner_id group_name:(NSString*)group_name group_pic:(NSString*)group_pic  group_pic_type:(NSString*)group_pic_type format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set AddMemberToGroup Request Old Api
-(void)SetAddMemberToGroupRequest :(NSString *)user_auth_key  group_id:(NSString*)group_id member_id:(NSString*)member_id format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Get Friend List Request Old Api
-(void)GetFriendListRequest :(NSString *)user_auth_key user_id:(NSString*)user_id group_id:(NSString*)group_id discussion_id:(NSString*)discussion_id status:(NSString*)status format:(NSString*)format  callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set BadgesZero Request Old Api
-(void)SetBadgeZerowithAuthKey:(NSString *)user_auth_key user_id:(NSString *)user_id device_info:(NSString *)device_info jabber_id:(NSString *)jabber_id custom_id:(NSString *)custom_id format:(NSString *)format callback:(void (^)(NSDictionary *responceObject, NSError* error))callback;



#pragma mark - get_user_course_list
-(void)GetUserCourseListRequest :(NSString *)user_auth_key device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang offset :(NSString *)offset limit:(NSString *)limit type:(NSString*)type callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - subcribe_course
-(void)SubcribeCourseRequest :(NSString *)user_auth_key lesson_id:(NSString*)lesson_id device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang type:(NSString*)type issample:(NSString*)issample callback:(void (^)(NSMutableDictionary *responceObject, NSError* error))callback;

#pragma mark - Set Submit Course Answer Request
-(void)SubmitAnswerRequestWithAuthKey :(NSString *)user_auth_key lesson_id:(NSString*)lesson_id association_id:(NSString*)association_id qa_json:(NSString*)qa_json device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set Pdf generate testing aPI
-(void)viewProfileWithAuthKey :(NSString *)user_auth_key custom_id :(NSString*)custom_id device_type:(NSString*)device_type ipAddress:(NSString*)ipAddress app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set New Feed request
-(void)setFeedPostWithTitle :(NSString *)title content :(NSString*)content posted_by:(NSString*)posted_by user_type:(NSString*)user_type feed_type :(NSString *)feed_type file_type :(NSString *)file_type file_url:(NSString*)file_url meta_url :(NSString *)meta_url feed_type_id :(NSString *)feed_type_id auth_key:(NSString*)auth_key format:(NSString *)format feed_kind:(NSString*)feed_kind video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString *)file_description callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - GetNotificationListRequest
-(void)getNotificationListRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset limit:(NSString*)limit device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - SetReadNotificationRequest
-(void)setReadNotificationRequestWithAuthKey :(NSString *)user_auth_key message_id_json:(NSString*)message_id_json  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - SetRegisterAccountReadOnlyRequest
-(void)SetRegisterAccountReadOnly:(NSString *)token_id  first_name:(NSString*)first_name last_name:(NSString*)last_name  country:(NSString*)country email:(NSString*)email registration_id:(NSString*)registration_id invite_code:(NSString*)invite_code association_id:(NSString*)association_id user_type:(NSString*)user_type university_json:(NSString*)university_json speciality_id_json:(NSString*)speciality_id_json device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set Claim Account Read Only Request
-(void)SetClaimAccountReadOnlyWithToken:(NSString *)token_id  first_name:(NSString*)first_name last_name:(NSString*)last_name  country:(NSString*)country email:(NSString*)email registration_id:(NSString*)registration_id invite_code:(NSString*)invite_code user_type:(NSString*)user_type university_json:(NSString*)university_json speciality_id_json:(NSString*)speciality_id_json device_type :(NSString *)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

/*
 Get Chat dialog credentials server for ONE 2 ONE Chat
 */
#pragma mark - Get Chat Credential Update
-(void)getChatCredentialCreateWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version device_type:(NSString *)device_type  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

/*
 Get Chat dialog entry From Docquity server for ONE 2 ONE Chat
 */
#pragma mark - Get Chat Dialogue
-(void)getChatDialogueWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version offset:(NSString *)offset limit:(NSString *)limit DOUpdate:(NSString *)date_of_updation callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


/*
 Get Specific Chat dialog From Docquity server for ONE 2 ONE Chat
 */
#pragma mark - Get Specific Chat Dialogue
-(void)getSingleChatDialogueWithAuthKey:(NSString *)user_auth_key lang:(NSString *)lang app_version:(NSString *)app_version dialog:(NSString *)dialogue_id callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

/*
  Set Chat dialog entry to Docquity server with single user for ONE 2 ONE Chat
 */
#pragma mark - Set Chat Dialogue
-(void)setDialogWithAuthkey:(NSString *)authkey oppCustID :(NSString*)custom_id lang:(NSString *)lang app_version:(NSString *)app_version dialogue:(NSString*)dialogue callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

/*
 Set Block or Unblock user for Chat to Docquity server with single user for ONE 2 ONE Chat
 */

-(void)setUserActionWithAuthkey:(NSString *)authkey oppCustID :(NSString*)custom_id lang:(NSString *)lang app_version:(NSString *)app_version action:(NSString*)action callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


#pragma mark - Getsearch_university Request
-(void)Getsearch_university:(NSString *)token_id keyword:(NSString *)keyword device_type:(NSString *)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


#pragma mark - GetViewFeedFiltered Request
-(void)ViewFeed_FilteredRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset feed_kind:(NSString*)feed_kind  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - GetViewCaseFiltered Request
-(void)ViewCase_FilteredRequestWithAuthKey :(NSString *)user_auth_key offset:(NSString*)offset feed_kind:(NSString*)feed_kind  device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Delete FeedRequest
-(void)DeleteFeedRequesttWithAuthKey :(NSString *)user_auth_key user_id:(NSString*)user_id feed_id:(NSString*)feed_id action:(NSString*)action user_type:(NSString*)user_type device_type:(NSString*)device_type app_version :(NSString *)app_version lang :(NSString *)lang format:(NSString *)format  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - SetFeedLikeRequest
-(void)SetFeedLikeRequesttWithAuthKey :(NSString *)user_auth_key  feed_id:(NSString*)feed_id device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - SetSetNotify_to_upgrade_for_chat
-(void)SetNotify_to_upgrade_for_chatWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Get meta_preview
-(void)GetMetaPreviewWithAuthKey :(NSString *)user_auth_key  meta_url:(NSString*)meta_url type_for:(NSString*)type_for device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set edit_feed_v2
-(void)SetEditFeedWithAuthKey :(NSString *)user_auth_key feed_id:(NSString*)feed_id title:(NSString*)title content:(NSString*)content feed_type:(NSString*)feed_type file_type:(NSString*)file_type file_url:(NSString*)file_url  feed_type_id:(NSString*)feed_type_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url  video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString*)file_description classification:(NSString*)classification meta_array:(NSString*)meta_array speciality_json_array:(NSString*)speciality_json_array device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


#pragma mark - Set post_feed_v2
-(void)SetPostFeedWithAuthKey :(NSString *)user_auth_key title:(NSString*)title content:(NSString*)content feed_type:(NSString*)feed_type file_type:(NSString*)file_type file_url:(NSString*)file_url  feed_type_id:(NSString*)feed_type_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url  video_image_url:(NSString*)video_image_url file_name:(NSString*)file_name file_description:(NSString*)file_description classification:(NSString*)classification meta_array:(NSString*)meta_array speciality_json_array:(NSString*)speciality_json_array device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


#pragma mark - get Speciality Request New Api
-(void)getSpecialityRequestWithAuthKey :(NSString *)user_auth_key  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - getUserTimeLineRequest
-(void)getUserTimeLineRequestWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - get_timeline_photoRequest
-(void)getUserTimeLinePhotoRequestWithAuthKey :(NSString *)user_auth_key  custom_id:(NSString*)custom_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - get_view_feed_by_specialityRequest
-(void)getViewFeedBySpecialityRequestWithAuthKey :(NSString *)user_auth_key  speciality_id
:(NSString*)speciality_id limit:(NSString*)limit offset:(NSString*)offset device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;


#pragma mark - Set_OTPRequest
-(void)setOTPRequestWithAppKey :(NSString *)app_key  version
                               :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code device_token:(NSString*)device_token registered_user_type:(NSString*)registered_user_type  ip_address:(NSString*)ip_address device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set Resend OTP request
-(void)setResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code token_id:(NSString*)token_id  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Get country list
-(void)getResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code token_id:(NSString*)token_id  device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Get association list by country
-(void)getResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version country_code:(NSString*)country_code mobile:(NSString*)mobile iso_code:(NSString*)iso_code device_type:(NSString*)device_type app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set Verify mobile request
-(void)setResendOTPRequestWithAppKey :(NSString *)app_key  version
                                     :(NSString*)version token_id:(NSString*)token_id country_code:(NSString*)country_code mobile:(NSString*)mobile device_type:(NSString*)device_type device_token:(NSString*)device_token  device_info:(NSString*)device_info ip_address:(NSString*)ip_address user_type:(NSString*)user_type app_version :(NSString *)app_version otp:(NSString*)otp iso_code:(NSString*)iso_code  lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

#pragma mark - Set Claim Account request
-(void)setClaimAccountRequestWithVersion
                                     :(NSString*)version token_id:(NSString*)token_id country_code:(NSString*)country_code mobile:(NSString*)mobile device_type:(NSString*)device_type ic_number:(NSString*)ic_number  association_id:(NSString*)association_id  iso_code:(NSString*)iso_code app_version :(NSString *)app_version lang:(NSString*)lang  callback:(void (^)(NSMutableDictionary *responseObject, NSError* error))callback;

@end
