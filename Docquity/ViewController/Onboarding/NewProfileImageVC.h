/*============================================================================
 PROJECT: Docquity
 FILE:    NewProfileImageVC.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 27/08/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
//#import "Server.h"
@import MessageUI;

@interface NewProfileImageVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>{
    NSString *u_ImgType;
    NSString *base64EncodedString;
    NSString *mediaPath;
    NSMutableString *dataPath;
//    ServerRequestType1 currentRequestType;
    NSInteger statusResponse;
    NSString *imgUrl;
    NSUserDefaults *userdef;
}

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIImageView *backviewImage;
@property (weak, nonatomic) IBOutlet UIView *chooseImageViewHolder;
@property (nonatomic)BOOL isAccountClaimed;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end
