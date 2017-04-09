//
//  SpecilityFeedVC.h
//  Docquity
//
//  Created by Docquity-iOS on 13/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefineAndConstants.h"
#import "UINavigationBar+ZZHelper.h"
@interface SpecilityFeedVC : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableArray *specFeedArr;
    NSInteger offset;
    NSIndexPath *clickedIndexPath;
    NSString*feedShareUrl;
    NSString * permstus; //check readonly permission
    NSMutableArray *deleteFeedid;
    BOOL isDeleteFeed;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSString *specId;
@property (strong, nonatomic) NSString *specName;
@property (nonatomic,assign)id delegate;
@end


@protocol SpecilityViewDelegate <NSObject>
-(void)specilityViewFindDelete:(BOOL)isDelete deleteFeedID:(NSMutableArray*)deleteFeedID;


@end
