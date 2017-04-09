//
//  NewUserGenderVC.h
//  Docquity
//
//  Created by Docquity-iOS on 23/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NewUserGenderVC : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;
    IBOutlet UILabel *lblGender;
    IBOutlet UILabel *lblEmail;
    IBOutlet UITextField *tfEmail;
}

-(IBAction)btnGenderClicked:(id)sender;

@end
