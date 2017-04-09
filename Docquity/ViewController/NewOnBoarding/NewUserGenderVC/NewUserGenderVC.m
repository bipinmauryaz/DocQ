//
//  NewUserGenderVC.m
//  Docquity
//
//  Created by Docquity-iOS on 23/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewUserGenderVC.h"

@interface NewUserGenderVC ()

@end

@implementation NewUserGenderVC
- (void)viewDidLoad {
    [super viewDidLoad];
    btnMale.selected = YES;
    btnMale.layer.borderWidth = 1.0f;
    btnMale.layer.borderColor = [UIColor clearColor].CGColor;
    btnMale.backgroundColor = [UIColor colorWithRed:8.0f/255.0f green:152.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    btnFemale.selected = NO;
    btnFemale.layer.borderWidth = 1.0f;
    btnFemale.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Uitextfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton Actions
-(IBAction)btnGenderClicked:(id)sender{
    if (sender == btnMale) {
        btnMale.selected = YES;
        btnMale.backgroundColor = [UIColor colorWithRed:8.0f/255.0f green:152.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
        btnMale.layer.borderColor = [UIColor clearColor].CGColor;
        btnFemale.selected = NO;
        btnFemale.backgroundColor = [UIColor whiteColor];
        btnFemale.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else
    {
        btnFemale.selected = YES;
        btnFemale.layer.borderColor = [UIColor clearColor].CGColor;
        btnFemale.backgroundColor = [UIColor colorWithRed:8.0f/255.0f green:152.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
        btnMale.selected = NO;
        btnMale.backgroundColor = [UIColor whiteColor];
        btnMale.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
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
