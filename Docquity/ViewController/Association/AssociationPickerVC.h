/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationPickerVC.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/12/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>

/*============================================================================
 Interface: AssociationPickerVC
 =============================================================================*/
@interface AssociationPickerVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
     NSMutableArray *selectedIndexes;
     NSMutableArray *selectedAssociationList;
}

@property (nonatomic,assign)id delegate;
@property (nonatomic,strong)NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *associationListArr;
@end

@protocol selectAsso <NSObject>

-(void)selectedAssociationName:(NSMutableArray*)Name AssoID:(NSMutableArray*)associationId associationArray:(NSMutableArray*)associationMainArr;



@end
