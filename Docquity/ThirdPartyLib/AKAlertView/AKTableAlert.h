//
//  AKTableAlert.h
//
//  Version 1.3
//
//  Created by Matteo Del Vecchio on 11/12/12.
//  Updated on 03/07/2013.
//
//  Copyright (c) 2012 Matthew Labs. All rights reserved.
//  For the complete copyright notice, read Source Code License.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class AKTableAlert;


// Blocks definition for table view management
typedef NSInteger (^AKTableAlertNumberOfRowsBlock)(NSInteger section);
typedef UITableViewCell* (^AKTableAlertTableCellsBlock)(AKTableAlert *alert, NSIndexPath *indexPath);
typedef void (^AKTableAlertRowSelectionBlock)(NSIndexPath *selectedIndex);
typedef void (^AKTableAlertCompletionBlock)(void);


@interface AKTableAlert : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) AKTableAlertCompletionBlock completionBlock;	// Called when Cancel button pressed
@property (nonatomic, strong) AKTableAlertRowSelectionBlock selectionBlock;	// Called when a row in table view is pressed


// Classe method; rowsBlock and cellsBlock MUST NOT be nil
// Pass NIL to cancelButtonTitle to show an alert without cancel button
+(AKTableAlert *)tableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelBtnTitle numberOfRows:(AKTableAlertNumberOfRowsBlock)rowsBlock andCells:(AKTableAlertTableCellsBlock)cellsBlock;

// Initialization method; rowsBlock and cellsBlock MUST NOT be nil
// Pass NIL to cancelButtonTitle to show an alert without cancel button
-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelBtnTitle numberOfRows:(AKTableAlertNumberOfRowsBlock)rowsBlock andCells:(AKTableAlertTableCellsBlock)cellsBlock;

// Allows you to perform custom actions when a row is selected or the cancel button is pressed
-(void)configureSelectionBlock:(AKTableAlertRowSelectionBlock)selBlock andCompletionBlock:(AKTableAlertCompletionBlock)comBlock;

// Show the alert
-(void)show;

@end

