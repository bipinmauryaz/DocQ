//
//  NewHomeVC.m
//  Docquity
//
//  Created by Docquity-iOS on 21/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewHomeVC.h"
#import "NewCountryVC.h"
#import "DefineAndConstants.h"
#import "AssociationPickerVC.h"

#import "CNPPopupController.h"



@interface NewHomeVC ()<CNPPopupControllerDelegate>
{
    NSTimer *aTimer;
}

@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation NewHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:10.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
    pageControl.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    languageList = [[NSMutableArray alloc]initWithObjects:@"English",@"Indonasia(Bhasha)",nil];

    _arrPageImages = [[NSMutableArray alloc]init];
    _arrPageTitles = [[NSMutableArray alloc]init];
 
 _arrPageTitles = [[NSMutableArray alloc]initWithObjects:@"Welcome to Asia's largest network for medical professionals.",@"Peer to Peer consultation on medical cases in a private & secure environment.",@"Earn instant credit points through our accredited CME courses.",@"Medico legal advice for medical professionals.",@"Keep yourself updated with the latest medical trends.",nil];
    
_arrPageImages =[[NSMutableArray alloc]initWithObjects:@"Networks.png",@"PeerToPeer.png",@"CMEPoints.png",@"Discussions.png",@"NewNotification.png",nil];
    
//    for (NSDictionary *dict in arrPageViewData) {
//        //[_arrPageTitles addObject:[dict objectForKey:@"content"]];
//        [_arrPageTitles addObject:@"Need answer? Ask free questions and get answer from professionals"];
//        
//        [_arrPageImages addObject:[dict objectForKey:@"slide_url"]];
//    }
//
    // Create page view controller
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.PageViewController.dataSource = self;
    PageContentVC *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.PageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMinY(viewLanguage.frame)-20);
    [self addChildViewController:_PageViewController];
    [self.view addSubview:_PageViewController.view];
    [self.PageViewController didMoveToParentViewController:self];
    
    //for popup
    self.popupView.hidden=YES;
    
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor= [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor whiteColor];

  }

-(void)viewWillAppear:(BOOL)animated {
     [Localytics tagEvent:@"OnboardingHomeScreen Visit"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnBoarding_Home_Screen" screenAction:@"OnBoardingHomeScreen Visit"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    // /*! setup an interval */
   // aTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animation) userInfo:nil repeats:YES];
 }

-(void)animation{
    for (int i=0; i<5; i++)
    {
        self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.PageViewController.dataSource = self;
        PageContentVC *startingViewController = [self viewControllerAtIndex:i];
        NSArray *viewControllers = @[startingViewController];
        [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Calls
-(void)ServiceHitForData{
[WebServiceCall callServiceGETWithName:@"http://dev.docquity.com/connect/services/association/get?rquest=app_slide_list&version=2.0&lang=en" withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error){
        if (response) {
            NSError *errorJson=nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
            
            NSArray *arrPageViewData = [NSArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.slide_list"]];
            _arrPageImages = [[NSMutableArray alloc]init];
            _arrPageTitles = [[NSMutableArray alloc]init];

            for (NSDictionary *dict in arrPageViewData) {
                //[_arrPageTitles addObject:[dict objectForKey:@"content"]];
                 [_arrPageTitles addObject:@"Need answer? Ask free questions and get answer from professionals"];
               
                [_arrPageImages addObject:[dict objectForKey:@"slide_url"]];
            }
            // Create page view controller
            self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
            self.PageViewController.dataSource = self;            
            PageContentVC *startingViewController = [self viewControllerAtIndex:0];
            NSArray *viewControllers = @[startingViewController];
            [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            
            // Change the size of page view controller
            self.PageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMinY(viewLanguage.frame)-20);
            [self addChildViewController:_PageViewController];
            [self.view addSubview:_PageViewController.view];
            [self.PageViewController didMoveToParentViewController:self];
        }
        else if (error)
        {
         [SVProgressHUD dismiss];
         NSLog(@"%@",error);
        }
    }];
}

#pragma mark - Uibutton Method
-(IBAction)btnLanguageClicked:(id)sender{
   // self.popupView.hidden=NO;
   // [Localytics tagEvent:@"OnboardingHomeScreen Change language Click"];
    // [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnBoarding_Home_Screen" screenAction:@"Screen Change language click"];
    //  [self showPopupWithStyle:CNPPopupStyleCentered];
   // TableSearchView *tableSearch = [[TableSearchView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.navigationController.navigationBar addSubview:tableSearch];
  
      //  [Localytics tagEvent:@"Select Association Click"];
        //NSLog(@"didPressPickAssociationBtn");
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [UIView animateWithDuration:1.0 animations:^{
//        self.popupParentView.hidden = false;
//    }];
 }


-(IBAction)btnDoctorClicked:(id)sender{

     [Localytics tagEvent:@"OnboardingHomeScreen Doctor Click"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnBoarding_Home_Screen" screenAction:@"Doctor Click"];
     self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewCountryVC *newCountry = [storyboard instantiateViewControllerWithIdentifier:@"NewCountryVC"];
    newCountry.userType = @"doctor";
    [self.navigationController pushViewController:newCountry animated:YES];
}

-(IBAction)btnLogInClicked:(id)sender{
    [Localytics tagEvent:@"OnboardingHomeScreen Login Click"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnBoarding_Home_Screen" screenAction:@"OnBoardingHomeScreen Login Click"];
    self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewCountryVC *newCountry = [storyboard instantiateViewControllerWithIdentifier:@"NewCountryVC"];
    newCountry.userType = @"";
    [self.navigationController pushViewController:newCountry animated:YES];
}

-(IBAction)btnStudentClicked:(id)sender{
    [Localytics tagEvent:@"OnboardingHomeScreen Student Click"];
   [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnBoarding_Home_Screen" screenAction:@"OnBoardingHomeScreen Student Click"];
    self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewCountryVC *newCountry = [storyboard instantiateViewControllerWithIdentifier:@"NewCountryVC"];
    newCountry.userType = @"student";
    [self.navigationController pushViewController:newCountry animated:YES];
}

#pragma mark - Page View Datasource Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentVC*) viewController).pageIndex;
     if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentVC*) viewController).pageIndex;
     if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.arrPageImages count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - Other Methods
- (PageContentVC *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.arrPageImages count] == 0) || (index >= [self.arrPageImages count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    PageContentVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentVC"];
    pageContentViewController.imgFile = self.arrPageImages[index];
    pageContentViewController.txtTitle = self.arrPageTitles[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

#pragma mark - No of Pages Methods
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.arrPageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


//for popup
- (IBAction)englishbtnAction:(id)sender {
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor whiteColor];
}

- (IBAction)indonesiaBtnAction:(id)sender {
    _englishBtn.layer.borderWidth=2.0;
    _englishBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _englishBtn.backgroundColor=[UIColor whiteColor];
    
    _indonesiaBtn.layer.borderWidth=2.0;
    _indonesiaBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _indonesiaBtn.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
}

- (IBAction)cancelAtion:(id)sender {
      self.popupView.hidden=YES;
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
