//
//  SectionCell.h
//  Docquity
//
//  Created by Docquity-iOS on 23/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UITextView *txt_userComment;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btn_Reply;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintsForImguser;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintsForLblTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintsForBtnLike;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTopConstraintsFromUsername;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTopConstraintsFromComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LikeTopConstraintsFromComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeBottomConstraintsFromComment;

@end
