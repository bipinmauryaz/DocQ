//
//  UpdateExam.h
//  Docquity
//
//  Created by Docquity-iOS on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
@interface UpdateExam : NSObject
{
    NSArray *dbResult;
    NSArray *dbQResult;
    NSArray *dbQAResult;
    NSMutableArray *lArray;
    NSMutableArray *QArray;
    NSMutableArray *QnArray;
    NSMutableArray *AllNonSubmitArray;
}
@property (nonatomic, strong) DBManager *dbManager;
-(void)submitExam;
@end
