//
//  AvailableCourseCell.m
//  Docquity
//
//  Created by Docquity-iOS on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "AvailableCourseCell.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
#import "NSString+GetRelativeTime.h"
#import "UIImageView+WebCache.h"
@implementation AvailableCourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lbl_status.layer.cornerRadius = 4.0;
    self.lbl_status.layer.masksToBounds = YES;
}

- (void)setInfo:(CourseModel*)courseModel
{
    [self setupDefaultConstraints];
    if(courseModel.total_user.integerValue>1)
    {
        self.lbl_TotalTaken.text = [NSString stringWithFormat:@"%@ Doctors have taken this course" ,courseModel.total_user];
    }else if (courseModel.total_user.integerValue == 1){
        self.lbl_TotalTaken.text = [NSString stringWithFormat:@"%@ Doctors have taken this course" ,courseModel.total_user];
    }else{
        [self setupremoveConstraints];
    }
    self.lbl_asso.text          =  [NSString stringWithFormat:@"%@ accredited",[courseModel.association_name stringByDecodingHTMLEntities]];
    self.lbl_title.text         =  [courseModel.lesson_name stringByDecodingHTMLEntities];
    self.lbl_Summary.text       =  [courseModel.lesson_summary stringByDecodingHTMLEntities];
    self.lbl_speciality.text    =  [courseModel.speciality_names stringByDecodingHTMLEntities];
    self.lbl_points.text        =  [NSString stringWithFormat:@"Points: %@",courseModel.total_points];
    self.lbl_expire.text        =  [NSString stringWithFormat:@"Expires on : %@",[NSString setUpdateTimewithString:courseModel.expiry_date]];
    
    self.lbl_asso.textColor         = kFontDescColor;
    self.lbl_title.textColor        = kFontTitleColor;
    self.lbl_Summary.textColor      = kFontDescColor;
    self.lbl_speciality.textColor   = kFontDescColor;
    self.lbl_status.textColor       = [UIColor whiteColor];
    
    [self.img_asso sd_setImageWithURL:[NSURL URLWithString:courseModel.association_pic] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
    
    long long int currentTime = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
    [self.lbl_status setHidden:NO];
    if([courseModel.subcription isEqualToString:@"0"]){
        if(courseModel.expiry_date.longLongValue < currentTime){
            self.lbl_status.backgroundColor = kFontDescColor;
            [self.lbl_status setText:@"Expired"];
        }
        else
        {
            [self.lbl_status setHidden:YES];
        }
    }
    else
    {
        if([courseModel.isSubmitted isEqualToString:@"0"])
        {
            if(courseModel.expiry_date.longLongValue < currentTime){
                self.lbl_status.backgroundColor = kFontDescColor;
                [self.lbl_status setText:@"Expired"];
               }
            else
            {
                self.lbl_status.backgroundColor = kYellowColor;
                [self.lbl_status setText:@"Take Course"];
            }
        }
        else if([courseModel.isSubmitted isEqualToString:@"2"]){
            self.lbl_status.backgroundColor = kYellowColor;
            [self.lbl_status setText:@"Submitted"];
        }
        else if([courseModel.remark containsString:@"pass"]){
            self.lbl_status.backgroundColor = kCOAColor;
            [self.lbl_status setText:@"Completed"];
        }
        else if([courseModel.remark containsString:@"fail"]){
            self.lbl_status.backgroundColor = [UIColor redColor];
            [self.lbl_status setText:@"Not Passed"];
        }
        else if([courseModel.remark containsString:@"Submit"]){
            self.lbl_status.backgroundColor = kYellowColor;
            [self.lbl_status setText:@"Submitted"];
        }
    }
}

-(void)setupremoveConstraints{
    self.TopConstraintsSep.constant = 0;
    self.TopConstraintsTotalTaken.constant = 0;
    self.HeightConstraintsTotalTaken.constant = 0;
    self.HeightConstraintsSep.constant = 0;
}

-(void)setupDefaultConstraints{
    self.TopConstraintsSep.constant = 10;
    self.TopConstraintsTotalTaken.constant = 10;
    self.HeightConstraintsTotalTaken.constant = 20;
    self.HeightConstraintsSep.constant = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
