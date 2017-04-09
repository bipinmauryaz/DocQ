//
//  AvailableCourseVC.h
//  Docquity
//
//  Created by Docquity Services on 04/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "CourseModel.h"
#import "UILoadingView.h"
@interface AvailableCourseVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIScrollViewDelegate>{
    NSMutableArray *newcoursesArr;
    NSMutableArray *alreadytakencoursesArr;
    int coursepagecount;
    int Completepagecount;
    NSArray *dbResult;
    NSArray *dbSpecResult;
    NSMutableArray *DataSource;
    UIRefreshControl *refreshControl;
    float verticalContentOffset;
    NSInteger selectedIndex;
    NSIndexPath *selectedIndexPath;
    BOOL isNewCourse;
    float newcourseContentOffset;
    float compCourseContentOffset;
    BOOL isSetPullOnAvC;
    BOOL isSetPullOnComC;
    BOOL isShowSampleCourse;
    NSString *SampleMsg;
    NSString *learnMorelink;
    NSString *availCourseStatus;
    BOOL is_topRefreshing;
    NSString*permstus;
    UILoadingView *loader;
    UIView *blankloaderview;
}
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_emptyview;
@property(nonatomic,strong) NSMutableString *dataPath;
@property (strong, nonatomic) IBOutlet UIView *nilView;
@property(nonatomic,strong) NSMutableArray *newcoursesArr;
@property(nonatomic,strong) NSMutableArray *completeCoursesArr;
@property(nonatomic,strong) IBOutlet UITableView *courseTV;
@property(nonatomic,strong)  NSMutableArray *alreadytakencoursesArr;
@property(nonatomic, strong)NSMutableArray <CourseModel *> *data;
@property(nonatomic, strong)NSMutableArray <CourseModel *> *fetchdata;
//button action
@property (nonatomic, strong)  IBOutlet UIButton* courses_button;
@property (nonatomic, strong)  IBOutlet UIButton* alreadytaken_button;


-(IBAction)buttonChangedonClick:(UIButton *)sender;
@property (nonatomic,strong) DBManager *dbManager;


@end
