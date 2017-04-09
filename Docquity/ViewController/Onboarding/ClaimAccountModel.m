/*============================================================================
 PROJECT: Docquity
 FILE:    ClaimAccountModel.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 01/09/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "ClaimAccountModel.h"
#import "DefineAndConstants.h"
@implementation ClaimAccountModel
- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.firstName  = data[dc_firstName];
        self.lastName   = data[dc_lastName];
        self.medicalReg = data[UserRegNo];
        self.emailID    = data[emailId1];
        self.claimcode  = data[kinvitecode];
        self.associationName = data[kassociationName];
        self.universityId =   data[kuniversity_id];
        self.specializationName = data[kspeciality_name];
        self.specializationId =   data[kspeciality_id];
      }
    return self;
}
@end
