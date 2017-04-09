//
//  NewHomeVC.h
//  Docquity
//
//  Created by Docquity-iOS on 21/02/17.
//  Copyright © 2017 Docquity. All rights reserved.

#import <UIKit/UIKit.h>
#import "PageContentVC.h"
#import "TableSearchView.h"
#import "NewMobileVerifyVC.h"
#import "NewUserMobileVC.h"
#import "SpecialityVC.h"
#import "UIImageView+WebCache.h"
#import "NewUniversitySearchVC.h"
#import "NewUploadVC.h"
#import "UserImageUploadVC.h"
#import "NewAssoicationVC.h"

@interface NewHomeVC : UIViewController<UIPageViewControllerDataSource>
{
    IBOutlet UIView *viewLanguage;
    IBOutlet UIButton *btnLanguage;
    IBOutlet UIButton *btnDoctor;
    IBOutlet UIButton *btnLogIn;
    NSMutableArray *languageList;
}

//for popup
@property (weak, nonatomic) IBOutlet UIButton *englishBtn;
@property (weak, nonatomic) IBOutlet UIButton *indonesiaBtn;
@property (weak, nonatomic) IBOutlet UIView *popupView;

@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (nonatomic,strong) NSMutableArray *arrPageImages;
@property (nonatomic,strong) NSMutableArray *arrPageTitles;

- (PageContentVC *)viewControllerAtIndex:(NSUInteger)index;
-(IBAction)btnLanguageClicked:(id)sender;

- (IBAction)didPressCancel:(id)sender;
-(IBAction)btnDoctorClicked:(id)sender;
-(IBAction)btnLogInClicked:(id)sender;
-(IBAction)btnStudentClicked:(id)sender;

@end
