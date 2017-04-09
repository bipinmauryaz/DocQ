//
//  CodeClaimVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "CodeClaimVC.h"

@interface CodeClaimVC ()

@end

@implementation CodeClaimVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tfCode.layer.borderWidth = 1.0f;
    tfCode.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextfield Delegate

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
