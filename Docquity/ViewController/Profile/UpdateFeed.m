//
//  UpdateFeed.m
//  Docquity
//
//  Created by Docquity-iOS on 13/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "UpdateFeed.h"

@implementation UpdateFeed

//- (id)init {
//    if (self = [super init]) {
//       self.ActivityArray = [[NSMutableArray alloc] init];
//    }
//    return self;
//}
//
+(UpdateFeed*) sharedInstance{
    static UpdateFeed* _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
        _shared.activityArray = [[NSMutableArray alloc] init];
        _shared.deleteFeedArray = [[NSMutableArray alloc] init];
    });
    return _shared;
}

@end
