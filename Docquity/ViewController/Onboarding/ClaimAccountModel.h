/*============================================================================
 PROJECT: Docquity
 FILE:    ClaimAccountModel.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 01/09/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <Foundation/Foundation.h>

@interface ClaimAccountModel : NSObject
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *medicalReg;
@property (nonatomic, strong) NSString *emailID;
@property (nonatomic, strong) NSString *associationName;
@property (nonatomic, strong) NSString *universityName;
@property (nonatomic, strong) NSString *universityId;
@property (nonatomic, strong) NSString *specializationName;
@property (nonatomic, strong) NSMutableArray *specializationId;
@property (nonatomic, strong) NSString *claimcode;

//custom intializer
- (instancetype)initWithData:(NSDictionary *)data;

@end
