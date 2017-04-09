//
//  CodeClaimVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeClaimVC : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *tfCode;
    IBOutlet UITextField *cardNumber;
    IBOutlet UIImageView *cardImageView;
}
@end
