//
//  NewHomeVC.h
//  Docquity
//
//  Created by Docquity-iOS on 21/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentVC.h"
#import "TableSearchView.h"
#import "NewMobileVerifyVC.h"
#import "NewUserMobileVC.h"
@interface NewHomeVC : UIViewController<UIPageViewControllerDataSource>{
    IBOutlet UIView *viewLanguage;
    IBOutlet UIButton *btnLanguage;
    IBOutlet UIButton *btnDoctor;
}


@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (nonatomic,strong) NSArray *arrPageImages;
@property (nonatomic,strong) NSArray *arrPageTitles;

- (PageContentVC *)viewControllerAtIndex:(NSUInteger)index;
-(IBAction)btnLanguageClicked:(id)sender;

-(IBAction)btnDoctorClicked:(id)sender;

@end
