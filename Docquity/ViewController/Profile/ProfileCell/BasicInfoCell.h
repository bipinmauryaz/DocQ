//
//  BasicInfoCell.h
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Interest;
@property (weak, nonatomic) IBOutlet UILabel *lbl_basicInfoStatic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_specializationStatic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_interestStatic;

@end
