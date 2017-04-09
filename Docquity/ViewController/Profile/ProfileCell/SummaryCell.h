//
//  SummaryCell.h
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *tv_bio;
@property (weak, nonatomic) IBOutlet UILabel *lbl_summaryStatic;

@end
