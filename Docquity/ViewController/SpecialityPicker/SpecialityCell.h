/*============================================================================
 PROJECT: Docquity
 FILE:    SpecialityCell.h
 AUTHOR:  Copyright © 2017 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 02/02/17.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>

@interface SpecialityCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *LblSpecialityName;
@property (strong, nonatomic) IBOutlet UILabel *LblspecialityDescription;
@property (strong, nonatomic) IBOutlet UIImageView *ImgSpecialityImage;
@property (strong, nonatomic) IBOutlet UIImageView *ImgCheckUncheck;
@property (nonatomic)BOOL cellSelected;
@end
