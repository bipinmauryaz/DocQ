/*============================================================================
 PROJECT: Docquity
 FILE:    ImageViewController.m
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/09/15.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "ImageViewController.h"
#import  "NSData+Base64.h"
#import "VIPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum{
    kTAG_Topbar =1,
}ALLTAGS;
@interface ImageViewController ()
@end
@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [self getImage:self.imgBase64];
    // NSLog(@"image size height:%f  width: %f",image.size.height,image.size.width);
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.bounds andImage:image];
    photoView.autoresizingMask = (1 << 6) -1;
    [self.view addSubview:photoView];
    //UIView *tpbar = (UIView*)[self.view viewWithTag:kTAG_Topbar];
    // NSLog(@" top bar heigiht :%f",tpbar.frame.size.height);
    [self topBar];
}

-(void)topBar{
    //NSLog(@"Enter in top bar");
    UIView *statusbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    statusbar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusbar];
    UIView *topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    topbar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    topbar.tag = kTAG_Topbar;
    
    topbar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    UIButton *backBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBarbtn.frame =CGRectMake(8, 28, 28, 28);
    [backBarbtn addTarget:self action:@selector(Back:) forControlEvents:UIControlEventTouchUpInside];
    [backBarbtn setImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal];
    [topbar addSubview:backBarbtn];
    [self.view addSubview:topbar];
    
    UILabel *titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 34)];
    titlelbl.textColor = [UIColor whiteColor];
    titlelbl.font  = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titlelbl.backgroundColor = [UIColor clearColor];
    titlelbl.textAlignment =  NSTextAlignmentCenter;
    
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backbtn.frame =CGRectMake(0,0,backBarbtn.frame.size.width+backBarbtn.frame.origin.x+50,topbar.frame.size.height );
    [backbtn addTarget:self action:@selector(Back:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:backbtn];
    
    titlelbl.numberOfLines =2;
    CGRect myImageRect1 = CGRectMake(topbar.frame.size.width -40, 28.0f, 25.0f, 25.0f);
    UIImageView *myImage1 = [[UIImageView alloc] initWithFrame:myImageRect1];
    [myImage1 setImage:[UIImage imageNamed:@"mors.png"]];
    myImage1.contentMode = UIViewContentModeScaleAspectFit;
    [topbar addSubview:myImage1];
    
    UIButton *saveMorebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveMorebtn.frame =CGRectMake(topbar.frame.size.width -40, 28, 32, 25);
    [saveMorebtn addTarget:self action:@selector(saveMore:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:saveMorebtn];
    
    if (IS_IPHONE_4) {
        if (self.titlebarText.length<25) {
            titlelbl.text= [NSString stringWithFormat:@"%@'s Photo",self.titlebarText];
        }
        else{
            titlelbl.text= [NSString stringWithFormat:@"%@",self.titlebarText];
        }
    }
    else if (IS_IPHONE_5){
    if (self.titlebarText.length<25) {
        titlelbl.text= [NSString stringWithFormat:@"%@'s Photo",self.titlebarText];
    }
        else{
            titlelbl.text= [NSString stringWithFormat:@"%@",self.titlebarText];
        }
    }
    else{
        titlelbl.text= [NSString stringWithFormat:@"%@'s Photo",self.titlebarText];
    }
    [topbar addSubview:titlelbl];
}

-(void)saveMore:(UIButton*)sender{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save photo to gallery",
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self savePhoto];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)savePhoto{
    UIImage *image = [self getImage:self.imgBase64];
    UIImageWriteToSavedPhotosAlbum(image, self,
                                   @selector(image:finishedSavingWithError:contextInfo:),
                                   nil);
}

//***************** fail, while saving image into photo library...
-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    //NSLog(@"error while saving image into iphone library: %@",error);
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //NSLog(@"%@", NSStringFromCGRect([[[self.view subviews] lastObject] frame]));
}

-(void)Back:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage*)getImage: (NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    NSMutableString *dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"Media"];
    NSString *getImagePath = [dataPath stringByAppendingPathComponent:filename];
    // NSLog(@"GEt image path: %@",getImagePath);
    UIImage *imgs = [UIImage imageWithContentsOfFile:getImagePath];
    return imgs;
}

//titlelbl.text= [NSString stringWithFormat:@"%@",self.titlebarText];
//NSUInteger length;
//length = [titlelbl.text length];
//titlelbl.text = [NSString stringWithFormat:@"%u", length];
@end
