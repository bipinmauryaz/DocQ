//
//  MedicalSpecialityCell.h
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicalSpecialityCell : UITableViewCell
@property(weak,nonatomic) IBOutlet UILabel *lblSpeciality;
@property(weak,nonatomic) IBOutlet UILabel *lblSpecialityBrief;
@property(weak,nonatomic) IBOutlet UIImageView *imageView_Specialty;
@property(weak,nonatomic) IBOutlet UIImageView *checkUncheck;

@end
