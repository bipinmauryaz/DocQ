//
//  CMEReviewVC.h
//  Docquity
//
//  Created by Arimardan Singh on 24/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewListCell.h"
#import "DBManager.h"
#import "QuesModel.h"
#import "CourseModel.h"

@interface CMEReviewVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *reviewlistTblVw;
    NSArray *dbResult;
    NSArray *dbOptResult;
    BOOL isAnsSelected;
    NSArray *fetchdata;
    NSMutableArray *SelectedAns;
    NSString *ansSelected;
}

@property (nonatomic, strong) DBManager *dbManager;
@property(nonatomic,strong)NSMutableArray*Arr_reviewlist;
@property(nonatomic,strong)IBOutlet UITableView *reviewlistTblVw;
@property (nonatomic, strong) NSString *lessionID;
@property (nonatomic) NSInteger count;
@property (nonatomic, strong) CourseModel *model;
@property (nonatomic) BOOL isOfflineSolve;
@property (nonatomic, strong) NSMutableArray <QuesModel *> *quesDataModel;
@property (nonatomic, strong) NSMutableArray *subqueArr;
@property (nonatomic, strong) NSMutableArray *queArr;
@property (nonatomic, strong) NSString *resouceFname;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *QA_Arr;
@property (nonatomic, strong) NSString* courseTitle;
@property (nonatomic, strong) NSString *accerediation;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton*btn_endExam;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL  confirmation;
@property (nonatomic) BOOL  isComefromReviewScreen;

@end

