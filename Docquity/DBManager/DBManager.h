/*============================================================================
 PROJECT: Docquity
 FILE:    DBManager.h
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 13/08/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <Foundation/Foundation.h>

/*============================================================================
 Interface:  DBManager
 =============================================================================*/
@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;


-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

//for loaddataFromDB 
-(NSArray *)loadDataFromDB:(NSString *)query;

//for excute query
-(void)executeQuery:(NSString *)query;


///To check for presencStatus Column
-(BOOL)checkColumnExists;

//Add presencStatus column in Contact Table
- (void)addPresenceColumnInContactsTable;
@end
