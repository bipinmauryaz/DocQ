//
//  MobileVerifyVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMobileVerifyVC : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *btnNeedHelp;
    IBOutlet UIButton *btnResendOTP;
    IBOutlet UILabel *lblCountryCode;
    IBOutlet UILabel *lblTimer;
    IBOutlet UIView *viewSuper;
}
@property(weak,nonatomic)IBOutlet UITextField *tfContactNumber;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP1;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP2;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP3;
@property(weak,nonatomic) IBOutlet UITextField *tfOTP4;

-(IBAction)btnNeedHelpClicked:(id)sender;
-(IBAction)btnResendOTP:(id)sender;




@end
