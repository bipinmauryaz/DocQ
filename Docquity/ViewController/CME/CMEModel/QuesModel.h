//
//  QuesModel.h
//  Docquity
//
//  Created by Docquity-iOS on 10/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptionModel.h"

@interface QuesModel : NSObject

@property(nonatomic, copy)NSString *ques_ID;
@property(nonatomic, copy)NSString *ques_Title;
@property(nonatomic, copy)NSString *question_type;
@property(nonatomic, copy)NSString *answer_type;
@property(nonatomic, copy)NSString *file_type;
@property(nonatomic, copy)NSString *file_url;

@property(nonatomic, copy)NSString *lesson_id;
@property(nonatomic, copy)NSString *ques_ImgUrl;
@property(nonatomic, copy)NSString *date_of_creation;
@property(nonatomic, copy)NSString *ques_Step;
@property(nonatomic, copy)NSString *resource_url;

@property(nonatomic, retain)NSMutableArray <OptionModel*>*optionArr;
@property(nonatomic, retain)NSMutableArray *API_OptionArr;
@end
