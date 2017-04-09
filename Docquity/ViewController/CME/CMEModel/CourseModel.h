//
//  CourseModel.h
//  Docquity
//
//  Created by Docquity-iOS on 12/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuesModel.h"
@interface CourseModel : NSObject
@property(nonatomic, copy)NSString *lesson_id;
@property(nonatomic, copy)NSString *lesson_code;
@property(nonatomic, copy)NSString *lesson_name;
@property(nonatomic, copy)NSString *lesson_summary;
@property(nonatomic, copy)NSString *file_type;
@property(nonatomic, copy)NSString *file_url;
@property(nonatomic, copy)NSString *date_of_creation;
@property(nonatomic, copy)NSString *expiry_date;
@property(nonatomic, copy)NSString *lesson_description;
@property(nonatomic, copy)NSString *topic_id;
@property(nonatomic, copy)NSString *course_id;
@property(nonatomic, copy)NSString *course_code;
@property(nonatomic, copy)NSString *resource_url;
@property(nonatomic, copy)NSString *isDownload;
@property(nonatomic, copy)NSString *isSubmitted;
@property(nonatomic, copy)NSString *speciality_ids;
@property(nonatomic, copy)NSString *association_name;
@property(nonatomic, copy)NSString *total_points;
@property(nonatomic, copy)NSString *subcription;
@property(nonatomic, copy)NSString *speciality_names;
@property(nonatomic, copy)NSString *see_more;
@property(nonatomic, copy)NSString *date_of_submission;
@property(nonatomic, copy)NSString *remark;
@property(nonatomic, copy)NSString *score;
@property(nonatomic, copy)NSString *isApiSync;
@property(nonatomic, copy)NSString *resouceFname;
@property(nonatomic, copy)NSString *documentName;
@property(nonatomic, copy)NSString *thumbnail;
@property(nonatomic, copy)NSString *documentTPage;
@property(nonatomic, copy)NSString *association_ids;
@property(nonatomic, copy)NSString *accreditation;
@property(nonatomic, copy)NSString *accreditation_url;
@property(nonatomic, copy)NSString *association_pic;
@property(nonatomic, copy)NSString *total_user;
@property(nonatomic, copy)NSString *pdf_result_url;
@property(nonatomic, copy)NSString *examAssoid;
@property(nonatomic)BOOL status;
//@property(nonatomic, copy)NSArray <QuesModel *>*queModel;
@end
