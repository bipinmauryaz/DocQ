//
//  CMEResultVC.m
//  Docquity
//
//  Created by Docquity-iOS on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "CMEResultVC.h"
#import "AppDelegate.h"
#import "CourseDetailVC.h"
#import "Localytics.h"
#import "WebVC.h"
@interface CMEResultVC ()

@end

@implementation CMEResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmation = YES;
    [Localytics tagEvent:@"CME Result Screen"];
    // Do any additional setup after loading the view.
    self.btn_transcript.hidden = ![AppDelegate appDelegate].isInternet;
    self.lblMessage.text = self.Msg;
    if([self.remarks containsString:@"pass"]){
        self.lblMessage.text = @"Congratulations! You have successfully passed the course.";
        self.img_status.image = [UIImage imageNamed:@"passed.png"];
    
    }else if([self.remarks containsString:@"fail"]){
        self.lblMessage.text = @"Whoops! \n You have not met the minimum passing criteria. \n Retake the course";
        self.img_status.image = [UIImage imageNamed:@"fail.png"];
    }else{
        self.lblMessage.text = @"Submitted";
        self.img_status.image = [UIImage imageNamed:@"completequestion.png"];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationItem.title = @"Result";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    [self setLeftBarBtn];
}


- (IBAction)didPressSendResult:(id)sender {
    [Localytics tagEvent:@"CME View Certificate"];
    NSString* documentfeedTitle = @"Certificate.pdf";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = self.pdfURL;
    webvw.isgetResult = YES;
    webvw.documentTitle = documentfeedTitle;
    webvw.courseTitle = self.courseTitle;
    webvw.associationid = self.associationid;
    [self presentViewController:webvw animated:YES completion:nil];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLeftBarBtn{
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -8; // it was -6 in iOS 6
    
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
}

-(void)backView{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[CourseDetailVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        
        if (self.confirmation) {
            [self backView];
            return NO;
        } else
            return YES;
    } else
        return YES;
}

@end
