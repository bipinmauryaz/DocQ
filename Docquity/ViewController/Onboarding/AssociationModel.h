/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationModel.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 29/08/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <Foundation/Foundation.h>

@interface AssociationModel : NSObject
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *idx;
@property (nonatomic, strong) NSString *flagUrl;
@property (nonatomic, strong) NSString *icExample;
@property (nonatomic, strong) NSString *icType;

//custom intializer
- (instancetype)initWithData:(NSDictionary *)data;


@end
