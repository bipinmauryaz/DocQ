//
//  OptionModel.h
//  Docquity
//
//  Created by Docquity-iOS on 17/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionModel : NSObject
@property(nonatomic, copy)NSString *opt_ID;
@property(nonatomic, copy)NSString *option;
@property(nonatomic, copy)NSString *question_ID;
@property(nonatomic)BOOL isSelected;

@end
