//
//  ReviewListCell.h
//  Docquity
//
//  Created by Arimardan Singh on 24/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewListCell : UITableViewCell

@property(nonatomic, weak)IBOutlet UIImageView*editIcon;
@property(nonatomic, weak)IBOutlet UILabel*lbl_queTitle;
@property(nonatomic, weak)IBOutlet UILabel*lbl_Number;

- (void)setInfo:(NSMutableArray*)reviewArr;

@end
