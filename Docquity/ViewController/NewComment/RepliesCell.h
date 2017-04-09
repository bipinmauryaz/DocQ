//
//  RepliesCell.h
//  Docquity
//
//  Created by Docquity-iOS on 28/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepliesModel.h"
@interface RepliesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UITextView *txt_userComment;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;






@end
