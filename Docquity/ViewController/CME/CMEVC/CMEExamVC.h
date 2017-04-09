//
//  CMEExamVC.h
//  Docquity
//
//  Created by Docquity-iOS on 10/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuesModel.h"
#import "CourseModel.h"
#import "DBManager.h"

@interface CMEExamVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
//  NSArray *QuesArray;
    NSArray *dbResult;
    NSArray *dbOptResult;
    BOOL isAnsSelected;
    NSArray *fetchdata;
    NSMutableArray *SelectedAns;
    NSString *ansSelected;
 }

//@property(nonatomic, strong) NSMutableArray <CourseModel *> *courseDataModel;
@property (nonatomic, strong) NSMutableArray <QuesModel *> *quesDataModel;
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSMutableArray *queArr;
@property (nonatomic, strong) NSMutableArray *queSubJsonArr; // Ari
@property (nonatomic, strong) NSString *lessionID;
@property (nonatomic, strong) NSString *resouceFname;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *QA_Arr;
@property (nonatomic, strong) NSString* courseTitle;
@property (nonatomic, strong) NSString *accerediation;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton*btn_endExam;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL isOfflineSolve;

@property (nonatomic) BOOL confirmation;
@end
