//
//  ProfileData.h
//  Docquity
//
//  Created by Docquity-iOS on 06/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileAssoModel.h"
#import "EducationModel.h"
#import "InterestModel.h"
#import "ProfessionModel.h"
#import "SpecialityModel.h"
#import "FriendModel.h"
@interface ProfileData : NSObject
@property(nonatomic, copy)NSString *user_id;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *first_name;
@property(nonatomic, copy)NSString *last_name;
@property(nonatomic, copy)NSString *jabber_id;
@property(nonatomic, copy)NSString *chat_id;
@property(nonatomic, copy)NSString *custom_id;
@property(nonatomic, copy)NSString *jabber_name;
@property(nonatomic, copy)NSString *email;
@property(nonatomic, copy)NSString *mobile;
@property(nonatomic, copy)NSString *country_code;
@property(nonatomic, copy)NSString *country;
@property(nonatomic, copy)NSString *city;
@property(nonatomic, copy)NSString *state;
@property(nonatomic, copy)NSString *bio;
@property(nonatomic, copy)NSString *profile_pic_path;
@property(nonatomic, copy)NSString *total_cme_points;
@property(nonatomic, copy)NSString *total_connection;
@property(nonatomic, copy)NSString *total_refer_points;
@property(nonatomic)BOOL timeline_access;
@property(nonatomic, retain)NSMutableArray <ProfileAssoModel*>*assoMArr;
@property(nonatomic, retain)NSMutableArray <EducationModel*>*eduArr;
@property(nonatomic, retain)NSMutableArray <InterestModel*>*interestArr;
@property(nonatomic, retain)NSMutableArray <ProfessionModel*>*ProfessionArr;
@property(nonatomic, retain)NSMutableArray <SpecialityModel*>*SpecArr;
@property(nonatomic, retain) FriendModel *FriendDic;
@end
