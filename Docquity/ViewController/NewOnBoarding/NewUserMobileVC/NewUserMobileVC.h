//
//  NewUserMobileVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NewMobileVerifyVC.h"

@interface NewUserMobileVC : UIViewController<UITextFieldDelegate>{
    IBOutlet UITextField *tfUserMobileNumber;
    IBOutlet UIToolbar *accessoryViewTool;
    NSString*tokenId;
    NSString*trackId;
    NSString*otpTimer;
    IBOutlet UILabel*lbl_countryCode;
    IBOutlet UIView* tfMobileView;
    NSInteger count;
    IBOutlet UILabel*titleLbl;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;
@property (nonatomic,strong) NSArray *assoIdArr;
@property (nonatomic,strong) NSString *assoIdCountNumber;
@property (nonatomic,strong) NSString *countryCode;
@property (nonatomic,strong) NSString *registered_userType;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property(strong,nonatomic)NSString *strCountryCode;
@property(strong,nonatomic)NSDictionary *associationDic;
-(IBAction)btnDoneClicked:(id)sender;

@end
