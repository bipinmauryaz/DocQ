/*============================================================================
 PROJECT: Docquity
 FILE:    ReportIssueVC.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 18/8/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "ReportIssueVC.h"
#import "AppDelegate.h"
#import "Localytics.h"
#import "DeviceUtil.h"

/*============================================================================
 Interface: ReportIssueVC
 =============================================================================*/
@interface ReportIssueVC ()
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation ReportIssueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self borderButton:self.btnAddAttachment];
    UITapGestureRecognizer *tapForKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tapForKeyboard.numberOfTapsRequired = 1.0;
    
    [self.scrollView addGestureRecognizer:tapForKeyboard];
    UITapGestureRecognizer *tapForImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageChangeRequest)];
    tapForImage.numberOfTapsRequired = 1.0;
    [self.screenShot addGestureRecognizer:tapForImage];
    isScreenshot = FALSE;
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden=NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"Report Issue TAB click"];
    // self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.sendBtn.userInteractionEnabled=NO;

//    dispatch_async(dispatch_get_main_queue(), ^{
//  //  [self.navigationController setNavigationBarHidden:NO animated:NO];
//  
//    self.navigationItem.title = @"Report Issue";
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
//   
////    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"button.png"] forBarMetrics:UIBarMetricsDefault];
//    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//        send=[[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendReport:)];
//    //    [send setEnabled:false];
//    self.navigationItem.rightBarButtonItem = send;
//    [self textViewDidChange:self.tvReportText];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
//                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
//        
//    });
    self.navigationController.navigationBarHidden=YES;

 
}


-(void)viewWillDisappear:(BOOL)animated{

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

//-(void)viewDidDisappear:(BOOL)animated{
//    
//
//
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//-(void)viewDidDisappear:(BOOL)animated{
//    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)imageChangeRequest{
    [self hideKeyboard];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // choose photo button tapped.
        [self didPressRemovePhoto];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // take photo button tapped.
        [self takePhoto];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // choose photo button tapped.
        [self choosePhoto];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)borderButton:(UIButton*)sender{
    sender.layer.borderWidth = 1.0;
    sender.layer.borderColor = [UIColor colorWithRed:5.0/255.0 green:148.0/255.0 blue:248.0/255.0 alpha:1.0].CGColor;
}

-(IBAction)sendReport:(id)sender{
   // NSLog(@"Send report");
    [self hideKeyboard];
    isScreenshot?[self screenshotUpload]:[self ReportIssueServiceCalling];
}

- (IBAction)didPressAttachImg:(id)sender {
    [self.view endEditing:YES];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // take photo button tapped.
        [self takePhoto];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // choose photo button tapped.
        [self choosePhoto];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void)takePhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:Nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
        
    }else{
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied)
        {
            NSLog(@"AVAuthorizationStatusDenied");
            [self showPopupForImageController:@"Camera"];
        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

- (void)choosePhoto {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
              //  NSLog(@"PHAuthorizationStatusAuthorized");
                [self openPhotoGallery];
                break;
            case PHAuthorizationStatusRestricted:
                ///NSLog(@"PHAuthorizationStatusRestricted");
                [self showPopupForImageController:@"Photos"];
                break;
            case PHAuthorizationStatusDenied:
                //NSLog(@"PHAuthorizationStatusDenied");
                [self showPopupForImageController:@"Photos"];
                break;
            default:
                break;
        }
    }];
}

-(void)showPopupForImageController:(NSString*)source{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:[NSString stringWithFormat:AppName@" does not have access to your %@. To enable access, tap Settings and turn on %@.",source,source] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:settingsAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    });
}

-(void)openPhotoGallery{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.translucent = NO;
    picker.navigationBar.barTintColor = [UIColor whiteColor];
    //[UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.screenShot.image = chosenImage;
    self.screenShot.hidden = false;
    self.btnAddAttachment.hidden = TRUE;
    self.screenShot.contentMode = UIViewContentModeScaleAspectFill;
    isScreenshot = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.1);
    u_ImgType = [self contentTypeForImageData:imageData];
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didPressRemovePhoto {
    self.screenShot.image = nil;
    self.screenShot.hidden = YES;
    self.btnAddAttachment.hidden = false;
    isScreenshot = NO;
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView hasText]){
        send.enabled = YES;
        self.sendBtn.userInteractionEnabled=YES;
        self.sendBtn.titleLabel.tintColor=[UIColor colorWithRed:0.0/255.0f green:137.0/255.0f blue:202.0/255.0f alpha:1.0f];

    }else
    {
        send.enabled = NO;
        self.sendBtn.titleLabel.tintColor=[UIColor colorWithRed:5.0/255.0 green:148.0/255.0 blue:248.0/255.0 alpha:0.5];

        self.sendBtn.userInteractionEnabled=NO;
    }
}

#pragma mark - get content type of image
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (void)screenshotUpload
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:base64EncodedString,base64Str1,u_ImgType,Image1,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
    //NSLog(@"serviceCalling");
}


#pragma webservices methods
- (void) ReportIssueServiceCalling
{
    isScreenshot?nil:[[AppDelegate appDelegate] showIndicator];
    NSString *iphonemodel = [DeviceUtil hardwareDescription];
    // [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kReportBug], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.tvReportText.text],@"msg",[NSString stringWithFormat:@"%@",fileUrl?fileUrl:@""],profileImage,[NSString stringWithFormat:@"%@",iphonemodel],@"iPhoneModel",nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kReportBug;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
    // NSLog(@"serviceCalling");
}



#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    if(currentRequestType == kSetUploadFileRequest)
        [self performSelector:@selector(screenshotUploadResponse:) withObject:responseData afterDelay:0.000];
    else
        [self performSelector:@selector(ReportBugResponse:) withObject:responseData afterDelay:0.000];
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
}


-(void)screenshotUploadResponse:(NSDictionary *)response{
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    // NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic==nil)
    {
    }
    else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue ];
        if (statusResponse==0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            
        }else if (statusResponse==1){
            fileUrl= [NSString stringWithFormat:@"%@",[postDic objectForKey:@"file_url"]?[postDic objectForKey:@"file_url"]:@""];
            
            [self ReportIssueServiceCalling];
        }
    }
}

-(void)ReportBugResponse:(NSDictionary *)response{
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    [[AppDelegate appDelegate] hideIndicator];
    // NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic==nil)
    {
    }
    else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue ];
        if (statusResponse==0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            
        }else if (statusResponse==1){
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            
            self.tvReportText.text = @"";
            [send setEnabled:false];
            self.sendBtn.userInteractionEnabled=NO;
            self.sendBtn.titleLabel.tintColor=[UIColor colorWithRed:5.0/255.0 green:148.0/255.0 blue:248.0/255.0 alpha:0.5];


            self.screenShot.image = nil;
            self.screenShot.hidden = YES;
            self.btnAddAttachment.hidden = false;
            isScreenshot = false;
        }
    }
}


-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
