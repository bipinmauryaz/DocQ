//
//  TLSummaryCell.m
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "TLSummaryCell.h"
#import "WebVC.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
@implementation TLSummaryCell
@synthesize lbl_SummaryText,lbl_SummaryDetails,lbl_TotalCME,lbl_Speciality,lbl_hobby,lbl_experience;
@synthesize img_cme,img_speciality,img_hobby,img_experience;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)configureUserInfoWithData:(ProfileData*)dic {
    self.profileData = dic;
    
    if([[dic valueForKey:@"custom_id"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]]  ){
        self.btn_editProfile.hidden = NO;
    }else{
        self.btn_editProfile.hidden = YES;
    }

    lbl_SummaryText.text = @"Personal Info";
    lbl_SummaryText.backgroundColor = [UIColor clearColor];
    [self setupSummaryDetails];
    [self setupExpertiseInfo];
    [self setupCMEInfo];
    [self setupSpecilityInfo];
    [self setupHobbiesInfo];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupSummaryDetails{
    lbl_SummaryDetails.backgroundColor = [UIColor clearColor];
    NSString *summary = self.profileData.bio;
    summary = [summary stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];
    summary = [summary stringByReplacingOccurrencesOfString:@"<br/>" withString: @"\n"];
    summary = [summary stringByReplacingOccurrencesOfString:@"<br />" withString: @"\n"];
    summary = [[summary stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    lbl_SummaryDetails.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    lbl_SummaryDetails.userInteractionEnabled = YES;
    lbl_SummaryDetails.delegate = self;
    
    if(summary != nil && summary.length>0){
        self.lblSummaryHeightConstraints.constant = 20;
        self.summaryDetailsBottomConstraints.constant = 12;
        lbl_SummaryDetails.text = summary;
    }else{
        self.lblSummaryHeightConstraints.constant = 0;
        self.summaryDetailsBottomConstraints.constant = 0;
    }
}

-(void)setupSpecilityInfo{
    NSString *speclity = @"";
    for(NSMutableDictionary *specdic in self.profileData.SpecArr){
        if([speclity isEqualToString:@""]){
            speclity = [specdic valueForKey:@"speciality_name"];
        }else{
            speclity = [NSString stringWithFormat:@"%@, %@",speclity,[specdic valueForKey:@"speciality_name"]];
        }
    }
    speclity = [[speclity stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    lbl_Speciality.text = speclity;
    lbl_Speciality.backgroundColor = [UIColor clearColor];
    img_speciality.image = [UIImage imageNamed:@"specialization.png"];
    img_speciality.backgroundColor = [UIColor clearColor];
  
    if([speclity isEqualToString:@""]){
        self.lblSpecBottomConstraints.constant = 0;
        self.lblSpecHeightConstraints.constant = 0;
        self.imgSpecHeightConstraints.constant = 0;
    }else if(self.lblSpecHeightConstraints.constant ==0){
        self.lblSpecBottomConstraints.constant = 10;
        self.lblSpecHeightConstraints.constant = 20;
        self.imgSpecHeightConstraints.constant = 12;
    }
 }

-(void)setupCMEInfo{
    NSString *totalcmePoints = self.profileData.total_cme_points?self.profileData.total_cme_points:@"0";
    NSString *referpoints = self.profileData.total_refer_points?self.profileData.total_refer_points:@"0";
    NSString* totalreferPoints   =  [NSString stringWithFormat:@"%.0f",[referpoints floatValue]];
    if(totalcmePoints.integerValue >1){
        lbl_TotalCME.text = [NSString stringWithFormat:@"%@ CME Points    %@ Referral Points",totalcmePoints,totalreferPoints];
    }else{
        lbl_TotalCME.text = [NSString stringWithFormat:@"%@ CME Point     %@ Referral Point",totalcmePoints,totalreferPoints];
    }

    lbl_TotalCME.backgroundColor = [UIColor clearColor];
    img_cme.image = [UIImage imageNamed:@"courses.png"];
    img_cme.backgroundColor = [UIColor clearColor];
}

-(void)setupExpertiseInfo{
    NSString *expertise = @"";
    NSString *position = @"";
    NSArray *sortedArray;
    [self resetExpLabelConstraits];
    if(self.profileData.ProfessionArr.count > 0) {
        for(NSMutableDictionary *profDic in self.profileData.ProfessionArr){
            if([[profDic valueForKey:@"current_prof"]isEqualToString:@"1"]){
                expertise = [NSString stringWithFormat:@"%@ at %@",[profDic valueForKey:@"position"],[profDic valueForKey:@"profession_name"]];
                position = [profDic valueForKey:@"profession_name"];
                break;
            }
        }
        if([expertise isEqualToString:@""]){
            NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
            sortedArray = [self.profileData.ProfessionArr sortedArrayUsingDescriptors:sortDescriptors];
            expertise = [NSString stringWithFormat:@"%@ at %@",[[sortedArray objectAtIndex:0] valueForKey:@"position"],[[sortedArray objectAtIndex:0] valueForKey:@"profession_name"]];
            position = [[sortedArray objectAtIndex:0] valueForKey:@"profession_name"];
        }
    }else if(self.profileData.eduArr.count > 0){
    
        for(NSMutableDictionary *profDic in self.profileData.eduArr){
            if([[profDic valueForKey:@"current_pursuing"]isEqualToString:@"1"]){
                expertise = [NSString stringWithFormat:@"%@ from %@",[profDic valueForKey:@"degree"],[profDic valueForKey:@"school"]];
                position = [profDic valueForKey:@"school"];
                break;
            }
        }
        if([expertise isEqualToString:@""]){
            
            NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"end_date"
                                                                         ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
            sortedArray = [self.profileData.eduArr sortedArrayUsingDescriptors:sortDescriptors];
            expertise = [NSString stringWithFormat:@"%@ from %@",[[sortedArray objectAtIndex:0] valueForKey:@"degree"],[[sortedArray objectAtIndex:0] valueForKey:@"school"]];
            position = [[sortedArray objectAtIndex:0] valueForKey:@"school"];
            
        }
    
    }else {
        self.lblExperienceHeightConstraints.constant = 0;
        self.lblExperienceBottomConstraints.constant = 0;
        self.btnSeeAllHeightConstraints.constant = 0;
        self.imgExpHeightConstraints.constant = 0;
        self.btnSeeAllBottomConstraints.constant = 0;
        self.lblSeeAllSeperatorBottmConstraints.constant = 0;
        self.lblSepbtnHeightConstraints.constant = 0;
        self.btn_see_all_info.hidden = true;
        self.lbl_sep_btn.hidden = true;
        self.img_experience.hidden = true;
    }
    expertise = [[expertise stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    lbl_experience.text = expertise;
    lbl_experience.backgroundColor = [UIColor clearColor];
    img_experience.image = [UIImage imageNamed:@"expertise.png"];
    img_experience.backgroundColor = [UIColor clearColor];
    
    [lbl_experience setText:expertise afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:position options:NSCaseInsensitiveSearch];
    
        UIFont *boldSystemFont = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];

            CFRelease(font);
        }
        return mutableAttributedString;
    }];
}

-(void)setupHobbiesInfo{
    NSString *hobby = @"";
    for(NSMutableDictionary *hobDic in self.profileData.interestArr){
        if([hobby isEqualToString:@""]){
            hobby = [hobDic valueForKey:@"interest_name"];
        }else{
            hobby = [NSString stringWithFormat:@"%@, %@",hobby,[hobDic valueForKey:@"interest_name"]];
        }
    }
    hobby = [[hobby stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    lbl_hobby.text = hobby;
    lbl_hobby.backgroundColor = [UIColor clearColor];
    img_hobby.image = [UIImage imageNamed:@"hobbies.png"];
    img_hobby.backgroundColor = [UIColor clearColor];
    if([hobby isEqualToString:@""]){
        self.lblSpecBottomConstraints.constant = 0;
        self.lblHobbyBottomConstraints.constant = 0;
        self.lblHobbyHeightConstraints.constant = 0;
        self.imgHobbyHeightConstraints.constant = 0;
    }else if(self.lblHobbyHeightConstraints.constant ==0){
         self.lblSpecBottomConstraints.constant = 10;
        self.lblHobbyBottomConstraints.constant = 9;
        self.lblHobbyHeightConstraints.constant = 20;
        self.imgHobbyHeightConstraints.constant = 12;
    }
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self.delegate clickedUrl:[NSString stringWithFormat:@"%@",url]];

}


-(void)resetExpLabelConstraits{

    self.lblExperienceHeightConstraints.constant = 20;
    self.lblExperienceBottomConstraints.constant = 10;
    self.btnSeeAllHeightConstraints.constant = 30;
    self.btnSeeAllBottomConstraints.constant = 10;
    self.lblSeeAllSeperatorBottmConstraints.constant = 0.5;
    self.lblSepbtnHeightConstraints.constant = 0.5;
    self.imgExpHeightConstraints.constant = 20;
    self.btn_see_all_info.hidden = false;
    self.lbl_sep_btn.hidden = false;
    self.img_experience.hidden = false;

}


- (IBAction)didPressEditProfile:(id)sender {
    [self openProfileDetails];
}

- (IBAction)didPressSeeAllInfo:(id)sender {
    [self openProfileDetails];

}

-(void)openProfileDetails{
    [self.delegate openProfile];
}


@end
