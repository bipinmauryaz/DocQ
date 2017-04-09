/*============================================================================
 PROJECT: Docquity
 FILE:    ClaimCell.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 01/09/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>

@interface ClaimCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblHint;
@property (weak, nonatomic) IBOutlet UITextField *tfFields;

@end
