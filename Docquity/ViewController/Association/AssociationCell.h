/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationCell.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/12/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/


#import <UIKit/UIKit.h>

@interface AssociationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *LblAssoName;
@property (strong, nonatomic) IBOutlet UILabel *LblAssoDescription;
@property (strong, nonatomic) IBOutlet UIImageView *ImgAssoImage;
@property (strong, nonatomic) IBOutlet UIImageView *ImgCheckUncheck;
@property (nonatomic)BOOL cellSelected;
@end
