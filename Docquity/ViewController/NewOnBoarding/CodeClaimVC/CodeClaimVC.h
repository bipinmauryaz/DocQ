//
//  CodeClaimVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewUserDetailsVC.h"
#import "CAPSPhotoView.h"

@interface CodeClaimVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UITextField *tfCode;
    IBOutlet UILabel *lbl_inviteCodeType;
    IBOutlet UIImageView *cardImageView;
    NSInteger count;
    IBOutlet UIButton*btnNext;
    CAPSPhotoView *photoView;
}

@property (nonatomic,strong) NSString *Strcode_invteType;
@property (nonatomic,strong) NSString *StrCardFileUrl;
@property (nonatomic,strong) NSString *strTfplaceholder;
@property(strong,nonatomic)NSString *Claim_MobileNumber;
@property (nonatomic,strong) NSString *Calim_countryCode;
@property (nonatomic,strong) NSString *registered_userType;

@end
