//
//  ProfessionalCell.h
//  Docquity
//
//  Created by Docquity-iOS on 25/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfessionalCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_companyName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Position;
@property (weak, nonatomic) IBOutlet UILabel *lbl_duration;

@property (weak, nonatomic) IBOutlet UIImageView *img_company;
@end
