//
//  statusCell.h
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface statusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_Status;
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (weak, nonatomic) IBOutlet UIView *view_status_holder;

@end
