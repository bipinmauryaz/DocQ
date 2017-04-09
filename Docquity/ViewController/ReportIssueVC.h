/*============================================================================
 PROJECT: Docquity
 FILE:    ReportIssueVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 18/8/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "Server.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

/*============================================================================
 Interface: ReportIssueVC
 =============================================================================*/
@interface ReportIssueVC : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ServerRequestFinishedProtocol>{
    UIBarButtonItem *send;
    BOOL isScreenshot;
    ServerRequestType1 currentRequestType;
    NSInteger statusResponse;
    NSString *fileUrl;
    NSString *u_ImgType;
    NSString *base64EncodedString;
}

@property (weak, nonatomic) IBOutlet UIButton *btnAddAttachment;
@property (weak, nonatomic) IBOutlet UITextView *tvReportText;
@property (weak, nonatomic) IBOutlet UIImageView *screenShot;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)didPressAttachImg:(id)sender;

@end
