//
//  UpdateFeed.h
//  Docquity
//
//  Created by Docquity-iOS on 13/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateFeed : NSObject
@property (nonatomic,retain) NSMutableArray *activityArray;
@property (nonatomic,retain) NSMutableArray *deleteFeedArray;
+(UpdateFeed*) sharedInstance;
@end
