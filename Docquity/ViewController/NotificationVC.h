//
//  NotificationVC.h
//  Docquity
//
//  Created by Arimardan Singh on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//
@class NewCommentVC;
@class CourseDetailVC;
#import <UIKit/UIKit.h>
@interface NotificationVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *notificationTblVw;
    IBOutlet UILabel*lbl_notifyStatus;
    IBOutlet UILabel *nilLbl;
    BOOL is_topRefreshing;
}

@property (strong, nonatomic) IBOutlet UIView *nilView;
@property(nonatomic,strong)NSMutableArray*notify_detailsArr;
@property(nonatomic,strong)IBOutlet UITableView *notificationTblVw;
@property (weak) NewCommentVC *NewCommentRefrence;
@property (weak)CourseDetailVC *courseDetailControllerRefrence;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

