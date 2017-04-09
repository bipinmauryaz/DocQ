//
//  InviteMembers.h
//  Docquity
//
//  Created by Arimardan Singh on 16/07/16.
//  Copyright © 2016 Docquity. All rights reserved.

#import <Foundation/Foundation.h>
@interface InviteMembers : NSObject
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *association;
@property (nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *InviteUserId;

//custom intializer
- (id)initWithData:(NSDictionary *)data;

@end
