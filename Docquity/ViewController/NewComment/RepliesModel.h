//
//  RepliesModel.h
//  Docquity
//
//  Created by Docquity-iOS on 28/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepliesModel : NSObject
@property(nonatomic, copy)NSString *userImgUrl;
@property(nonatomic, copy)NSString *userName;
@property(nonatomic, copy)NSString *commentDate;
@property(nonatomic, copy)NSString *commentContent;
@property(nonatomic, copy)NSString *commentLikeStatus;
@property(nonatomic, copy)NSString *reply_id;
@property(nonatomic, copy)NSString *replyer_user_id;
@property(nonatomic, copy)NSString *replyer_jabber_id;
@property(nonatomic, copy)NSString *custom_id;
@property(nonatomic, copy)NSString *total_reply_like;
@property(nonatomic, copy)NSString *like_status;

@end
