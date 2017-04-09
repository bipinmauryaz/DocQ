//
//  NewUserDetailsVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewUserDetailsVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblLastName;
    IBOutlet UILabel *lblEmail;
    IBOutlet UITextField *tfFirstName;
    IBOutlet UITextField *tfLastName;
    IBOutlet UITextField *tfEmail;
    IBOutlet UIView *medicalView;
    IBOutlet UITextField *tfMedicalRegNo;
    IBOutlet UILabel *lbl_MedicalRegNo;
}
@property(nonatomic,strong)   IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (nonatomic,strong) NSDictionary *claimDataDict;
@property (nonatomic,strong) NSString *countryName;
@property(strong,nonatomic)NSMutableArray *associationIdArr;
@property (nonatomic,strong) NSString *registered_userType;

@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousBarBt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;

@end
