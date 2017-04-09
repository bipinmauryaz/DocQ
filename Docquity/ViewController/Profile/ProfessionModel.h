//
//  ProfessionModel.h
//  Docquity
//
//  Created by Docquity-iOS on 25/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfessionModel : NSObject
@property(nonatomic, copy)NSString *profession_id;
@property(nonatomic, copy)NSString *profession_name;
@property(nonatomic, copy)NSString *position;
@property(nonatomic, copy)NSString *location;
@property(nonatomic, copy)NSString *start_date;
@property(nonatomic, copy)NSString *end_date;
@property(nonatomic, copy)NSString *start_month;
@property(nonatomic, copy)NSString *end_month;
@property(nonatomic, copy)NSString *prof_description;
@property(nonatomic, copy)NSString *current_prof;

@end
