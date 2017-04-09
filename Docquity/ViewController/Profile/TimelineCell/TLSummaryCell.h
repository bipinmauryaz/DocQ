//
//  TLSummaryCell.h
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ProfileData.h"
@interface TLSummaryCell : UITableViewCell

<
TTTAttributedLabelDelegate
>
{
    NSMutableDictionary *profileinfo;
}
@property (weak, nonatomic) IBOutlet UIImageView *img_summary;
@property(nonatomic, strong) ProfileData *profileData;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_SummaryDetails;
@property (weak, nonatomic) IBOutlet UIButton *btn_editProfile;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_experience;
@property (weak, nonatomic) IBOutlet UIImageView *img_experience;

@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalCME;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SummaryText;

@property (weak, nonatomic) IBOutlet UIImageView *img_cme;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Speciality;
@property (weak, nonatomic) IBOutlet UIImageView *img_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_hobby;
@property (weak, nonatomic) IBOutlet UIImageView *img_hobby;
@property (assign, nonatomic)id delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblExperienceBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSummaryHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblExperienceHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSeeAllHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgExpHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSeeAllBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSeeAllSeperatorBottmConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgSpecHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHobbyHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSpecTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSpecBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSpecHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSepbtnHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHobbyBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHobbyHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summaryDetailsBottomConstraints;
-(void)configureUserInfoWithData:(ProfileData*)profileData;
@property (weak, nonatomic) IBOutlet UILabel *lbl_sep_btn;

@property (weak, nonatomic) IBOutlet UIButton *btn_see_all_info;
- (IBAction)didPressEditProfile:(id)sender;

- (IBAction)didPressSeeAllInfo:(id)sender;

@end


@protocol timelineCellDelegate <NSObject>

-(void)clickedUrl:(NSString *)url;
-(void)openProfile;

@end
