//
//  AvailableCourseCell.h
//  Docquity
//
//  Created by Docquity-iOS on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"

@interface AvailableCourseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalTaken;
@property (weak, nonatomic) IBOutlet UIImageView *img_asso;
@property (weak, nonatomic) IBOutlet UILabel *lbl_asso;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Summary;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_points;
@property (weak, nonatomic) IBOutlet UILabel *lbl_expire;
@property (weak, nonatomic) IBOutlet UIImageView *img_accreditation;
@property (weak, nonatomic) IBOutlet UILabel *lbl_status;
@property (weak, nonatomic) IBOutlet UILabel *lbl_assured;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintsSep;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintsTotalTaken;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TopConstraintsSep;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TopConstraintsTotalTaken;

- (void)setInfo:(CourseModel*)courseInfo;
@end
