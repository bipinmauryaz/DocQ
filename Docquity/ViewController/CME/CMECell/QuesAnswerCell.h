//
//  QuesAnswerCell.h
//  Docquity
//
//  Created by Docquity-iOS on 10/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuesAnswerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *Img_Status;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Answer_Option;

@property (weak, nonatomic) IBOutlet UILabel *lbl_sep;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LeadingConstraintsLblSep;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TrailingConstraintsLblSep;
@end
