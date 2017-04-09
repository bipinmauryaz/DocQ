//
//  UserImageUploadVC.m
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "UserImageUploadVC.h"
#import "FeedVC.h"
#import "DocquityServerEngine.h"
#import "NewUploadVC.h"
#import "DefineAndConstants.h"

@interface UserImageUploadVC ()
@end
@implementation UserImageUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
     [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Profile Picture"];
     UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userClicked:)];
    gesture.numberOfTapsRequired = 1;
    [_imageViewUserImage addGestureRecognizer:gesture];
    userdef = [NSUserDefaults standardUserDefaults];
    [self uploadBtnActivate:FALSE];
    [Localytics tagEvent:@"Onboarding Upload Profile Screen"];
    //Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
     [Localytics tagEvent:@"OnboardingUploadProfile Visit"];
    [self callingGoogleAnalyticFunction:@"OnboardingUploadProfileScreen Visit" screenAction:@"OnboardingUploadProfileScreen Visit"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma martk - UITapgesture recogniser
-(void)userClicked:(UITapGestureRecognizer *)recogniser
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // take photo button tapped.
        [self takePhoto];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // choose photo button tapped.
        [self choosePhoto];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    self.imageViewUserImage.image = image;
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image picker delegates
-(void)takePhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)choosePhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.translucent = NO;
    picker.navigationBar.barTintColor = [UIColor whiteColor];
    picker.navigationBar.tintColor = [UIColor blackColor];
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageViewUserImage.hidden = FALSE;
    self.imageViewUserImage.image = chosenImage;
    self.imageViewUserImage.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewUserImage.layer.masksToBounds = YES;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.1);
    u_ImgType = [self contentTypeForImageData:imageData];
    //NSLog(@"imageType= %@", u_ImgType);
    
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //self.chooseImageViewHolder.hidden = YES;
    [self uploadBtnActivate:YES];
    [self saveImage:chosenImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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

- (IBAction)didPressUpload:(id)sender {
    /*
    NSString*checkPermission = [userdef valueForKey:user_permission];
    if ([checkPermission isEqualToString:@"readonly"])
    {
        self.navigationController.navigationBar.hidden = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
        NewUploadVC *newuploadIdentity = [storyboard instantiateViewControllerWithIdentifier:@"NewUploadVC"];
        newuploadIdentity.registeredUserType = _registeredUserType;
        [self.navigationController pushViewController:newuploadIdentity animated:YES];
    }
    else
    {
        [self pushToFeedVc];
    }
     */
    [self setProfileImgUpdateRequest:base64EncodedString profileTypeImg:u_ImgType selectImg:nil];
}

#pragma mark - skipBtnAction
- (IBAction)didPressSkip:(id)sender {
     [Localytics tagEvent:@"OnboardingUploadProfile Skip Click"];
     [self callingGoogleAnalyticFunction:@"OnboardingUploadProfileScreen Visit" screenAction:@"OnboardingUploadProfileScreen Skip"];
    [self pushUploadIdentityVc];
    // [self pushToFeedVc];
    //[Localytics tagEvent:@"Onboarding Skip Upload Profile Image"];
    /*
    NSString*checkPermission = [userdef valueForKey:user_permission];
    if ([checkPermission isEqualToString:@"readonly"]) {
    self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewUploadVC *newuploadIdentity = [storyboard instantiateViewControllerWithIdentifier:@"NewUploadVC"];
     newuploadIdentity.registeredUserType = _registeredUserType;
    [self.navigationController pushViewController:newuploadIdentity animated:YES];
    }
    else
    {
        [self pushToFeedVc];
    }
    */
}

#pragma mark - set user profile Img api calling
-(void)setProfileImgUpdateRequest:(NSString*)UserprofileImg profileTypeImg:(NSString*)profileImgType selectImg:(UIImage*)chosesImage{
    [WebServiceCall showHUD];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* uAtuhKey = [userDef objectForKey:userAuthKey];
    [[DocquityServerEngine sharedInstance]SetUserImgRequest:uAtuhKey userpic:UserprofileImg userpictype:profileImgType app_version:[userDef objectForKey:kAppVersion] device_type:kDeviceType lang:kLanguage callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [SVProgressHUD dismiss];
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
                [self pushUploadIdentityVc];
                //[self pushToFeedVc];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                [SVProgressHUD dismiss];
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

#pragma mark - UploadBtnActive
-(void)uploadBtnActivate:(BOOL)flag{
    self.btnUpload.enabled = flag;
    if(!flag)
    self.btnUpload.alpha = 0.5;
    else
    self.btnUpload.alpha = 1.0;
}

#pragma mark - Pushing to views
-(void)pushToFeedVc
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setBool:YES forKey:signInnormal];
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
}

-(void)pushUploadIdentityVc{
    self.navigationController.navigationBar.hidden = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    NewUploadVC *newuploadIdentity = [storyboard instantiateViewControllerWithIdentifier:@"NewUploadVC"];
    newuploadIdentity.registeredUserType = _registeredUserType;
    [self.navigationController pushViewController:newuploadIdentity animated:YES];
}

@end
