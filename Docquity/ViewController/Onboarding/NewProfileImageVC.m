/*============================================================================
 PROJECT: Docquity
 FILE:    NewProfileImageVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 8/27/16.
 =============================================================================*/


/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define MOBILE_NO_FIELD_MAX_CHAR_LENGTH 11
#define PASSWORD_MAX_CHAR_LENGTH 20

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "NewProfileImageVC.h"
#import "NewUploadIdentityVC.h"
#import "AppDelegate.h"
#import "Localytics.h"
#import "DocquityServerEngine.h"

/*============================================================================
 Interface:   NewProfileImageVC
 =============================================================================*/
@interface NewProfileImageVC ()

@end

@implementation NewProfileImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didPressUploadImage:)];
    tap.numberOfTapsRequired = 1.0;
    [self.backviewImage addGestureRecognizer:tap];
    userdef = [NSUserDefaults standardUserDefaults];
 //   NSLog(@"%@",[userdef valueForKey:password1]);
 //   NSLog(@"%@",[userdef valueForKey:userAuthKey]);
    [self submitBtnActivate:FALSE];
    [Localytics tagEvent:@"Onboarding Upload Profile Screen"];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Upload Profile Image";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.hidesBackButton = self.isAccountClaimed;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"help.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressUploadImage:(id)sender {
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

#pragma mark - Image picker delegates
-(void)takePhoto{
    // [Localytics tagEvent:@"OnBoarding UploadIDProofByCameraButton Click"];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)choosePhoto{
    // [Localytics tagEvent:@"OnBoarding UploadIDProofByGalleryButton Click"];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.translucent = NO;
    picker.navigationBar.barTintColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
     UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.backviewImage.hidden = FALSE;
    self.backviewImage.image = chosenImage;
    self.backviewImage.contentMode = UIViewContentModeScaleAspectFit;
    self.backviewImage.layer.masksToBounds = YES;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.1);
    u_ImgType = [self contentTypeForImageData:imageData];
    //NSLog(@"imageType= %@", u_ImgType);
    
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.chooseImageViewHolder.hidden = YES;
    [self submitBtnActivate:YES];
    [self saveImage:chosenImage];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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

#pragma mark - locally save Image
- (void)saveImage:(UIImage*)SaveImage {
    NSString *savedImagePath = [[[AppDelegate appDelegate]dataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"MyProfileImage.png"]];
    mediaPath = [NSString stringWithFormat:@"MyProfileImage.png"];
    
    // NSLog(@"Media Path : %@",mediaPath);
    //  UIImage *image = SaveImage; // imageView is my image from camera
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(SaveImage, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(SaveImage, compression);
    }
    [imageData writeToFile:savedImagePath atomically:NO];
}

- (IBAction)didPressSubmit:(id)sender {
   // [self uploadProfileImage];
    [self setProfileImgUpdateRequest:base64EncodedString profileTypeImg:u_ImgType selectImg:nil];
     }

- (IBAction)didPressSkip:(id)sender {
    [self pushToFeedVc];
    [Localytics tagEvent:@"Onboarding Skip Upload Profile Image"];
}

-(void)pushToUploadIdentity{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewUploadIdentityVC *NewUploadIdentity = [storyboard instantiateViewControllerWithIdentifier:@"NewUploadIdentityVC"];
    [self.navigationController pushViewController:NewUploadIdentity animated:YES];
}


#pragma mark - set user profile Img api calling
-(void)setProfileImgUpdateRequest:(NSString*)UserprofileImg profileTypeImg:(NSString*)profileImgType selectImg:(UIImage*)chosesImage{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetUserImgRequest:[userDef objectForKey:userAuthKey] userpic:UserprofileImg userpictype:profileImgType  app_version:[userDef objectForKey:kAppVersion] device_type:kDeviceType lang:kLanguage callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                imgUrl=[resposePost objectForKey:@"user_pic_url"];
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:imgUrl?imgUrl:@"" forKey:profileImage];
                [userpref synchronize];
               [self pushToFeedVc];
              }
            
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
}
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}


-(void)submitBtnActivate:(BOOL)flag{
    self.btnSubmit.enabled = flag;
    if(!flag)
        self.btnSubmit.alpha = 0.5;
    else
        self.btnSubmit.alpha = 1.0;
}

#pragma mark - Pushing to views
-(void)pushToFeedVc{
    [Localytics tagEvent:@"Onboarding New User Validated"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setBool:YES forKey:signInnormal];
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
}

#pragma mark - Mail Service
-(void)openMail{
     if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email." buttonTitle:OK_STRING];
        return;
    }else{
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[SupportEmail]];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
