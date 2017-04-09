/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationModel.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 29/08/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "AssociationModel.h"
@implementation AssociationModel

//- (instancetype)initWithArray:(NSDictionary *)dict{
//    if (self = [super init]) {
//        [self setValuesForKeysWithDictionary:dict];
//    }return self;
//}

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.country = data[@"association_country"];
        self.countryCode = data[@"country_code"];
        self.fullname = data[@"association_full_name"];
        self.idx = data[@"association_id"];
        self.flagUrl = data[@"profile_pic_path"];
        self.icExample = data[@"invite_code_example"];
        self.icType = data[@"invite_code_type"];
    }
    return self;
}

@end
