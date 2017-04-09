//
//  InviteMembers.m
//  Docquity
//
//  Created by Arimardan Singh on 16/07/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "InviteMembers.h"

@implementation InviteMembers

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.firstname = data[@"first_name"];
        self.lastname =  data[@"last_name"];
        self.association =  data[@"institution_name"];
        self.InviteUserId =  data[@"id"];
    }
    return self;
}

@end
