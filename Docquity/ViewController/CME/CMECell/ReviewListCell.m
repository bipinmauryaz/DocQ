//
//  ReviewListCell.m
//  Docquity
//
//  Created by Arimardan Singh on 24/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "ReviewListCell.h"

@implementation ReviewListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(NSMutableArray*)reviewArr
{
    _lbl_Number.text = @"1";
    
    _editIcon.image = [UIImage imageNamed:@"edit-profile.png"];
    _lbl_queTitle.text =  [NSString stringWithFormat:@"%@",@"Anitbodies to which of the following antigens of Bacillus anthracis are"];
    // _lbl_Number.backgroundColor = [UIColor yellowColor];
    //_lbl_queTitle.backgroundColor = [UIColor yellowColor];
}

@end
