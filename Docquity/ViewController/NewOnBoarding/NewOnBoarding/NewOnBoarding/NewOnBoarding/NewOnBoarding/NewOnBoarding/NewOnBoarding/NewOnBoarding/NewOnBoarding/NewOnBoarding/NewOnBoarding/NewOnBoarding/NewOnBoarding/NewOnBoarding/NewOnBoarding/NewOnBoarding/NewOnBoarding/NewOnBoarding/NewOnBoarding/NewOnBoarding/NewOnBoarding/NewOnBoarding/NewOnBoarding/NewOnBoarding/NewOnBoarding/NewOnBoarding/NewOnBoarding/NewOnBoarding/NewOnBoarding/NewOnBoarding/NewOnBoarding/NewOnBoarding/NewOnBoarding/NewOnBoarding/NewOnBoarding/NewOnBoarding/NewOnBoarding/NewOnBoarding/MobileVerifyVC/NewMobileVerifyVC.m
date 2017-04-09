//
//  MobileVerifyVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewMobileVerifyVC.h"

@interface NewMobileVerifyVC ()

@end

@implementation NewMobileVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    viewSuper.layer.borderWidth = 1.0f;
    viewSuper.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _tfContactNumber.rightViewMode = UITextFieldViewModeAlways;
    _tfContactNumber.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit-profile.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Actions

-(IBAction)btnNeedHelpClicked:(id)sender{
    
}


-(IBAction)btnResendOTP:(id)sender{
    
}



#pragma mark - UItextfield Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
