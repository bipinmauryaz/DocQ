//
//  SDCollectionViewController.h
//  SDPhotoBrowser
//
//  Created by gsd on 16/1/21.
//  Copyright © 2016年 GSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefineAndConstants.h"
@interface SDCollectionViewController : UICollectionViewController

+ (instancetype)demoCollectionViewController;
@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSMutableArray *userTimelinePic;
@end
