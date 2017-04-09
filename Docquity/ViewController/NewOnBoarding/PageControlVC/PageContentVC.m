//
//  PageContentVC.m
//  Docquity
//
//  Created by Docquity-iOS on 21/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "PageContentVC.h"

@interface PageContentVC ()

@end

@implementation PageContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  //  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imgFile]];
    self.ivScreenImage.image = [UIImage imageNamed:self.imgFile];
    self.lblScreenLabel.text = self.txtTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
