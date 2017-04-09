//
//  ExamReviewVC.h
//  Docquity
//
//  Created by Docquity-iOS on 18/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
@class AKTableAlert;

@interface ExamReviewVC : UIViewController{
    NSArray *dbResult;
    BOOL isMultiAsso;
    NSString *assoID;
    NSArray *dbAssoResult;
    NSMutableArray *assoArr;
    NSString *QAjson;
    NSString *pdfurl;
 }
@property(nonatomic,strong)NSMutableArray*Arr_reviewlist;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *courseTitle;
@property (nonatomic,strong) NSMutableArray *QuesSubArr;
@property (nonatomic, strong) NSString *lessionID;
@property (nonatomic,strong) DBManager *dbManager;
@property (strong, nonatomic) AKTableAlert *alert;
@property (nonatomic) BOOL confirmation;
@property (strong, nonatomic) NSString *accerediation;
@property (weak, nonatomic) IBOutlet UIButton *btn_submit;
@property (weak, nonatomic) IBOutlet UIButton *btn_review;
@end
