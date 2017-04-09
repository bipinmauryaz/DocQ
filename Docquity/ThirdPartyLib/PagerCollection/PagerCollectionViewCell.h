/*============================================================================
 PROJECT: Docquity
 FILE:    PagerCollectionViewCell.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 17/05/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
@interface PagerCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *ImageShow;
@property (strong, nonatomic) IBOutlet UILabel *photoCount;
@property (strong, nonatomic) IBOutlet UIButton *BtnCancel;

@end
