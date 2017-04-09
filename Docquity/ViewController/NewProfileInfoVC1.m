//
//  NewProfileInfoVC.m
//  Docquity
//
//  Created by Arimardan Singh on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NewProfileInfoVC.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIImage+fixOrientation.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "DocquityServerEngine.h"
#import "NSString+HTML.h"

@interface NewProfileInfoVC (){
    UITextField *activeField;
    BOOL keyboardHasAppeard;
    NSArray *inputItems;
    NSString *imgUrl;      // for get image_url when we are getting on profile
}

//private method of keyboard Accessory view
- (void) registerForKeyboardNotifications;
- (void) keyboardWasShown:(NSNotification *)notif;
- (void) keyboardWillBeHidden:(NSNotification *)notif;
- (CGRect) getPaddedFrameForView:(UIView *) view;
- (void) endEditing;
@end

@implementation NewProfileInfoVC
@synthesize scroll,scvwContentView,fNameTF,lNameTF,contactNoTF,emailTF,stateTF,cityTF,nationalityTF;
@synthesize nextBarBt,previousBarBt,keybAccessory;
@synthesize imgPicker,pickerView,picker;
@synthesize delegate;
@synthesize dbManager;
@synthesize library;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.library = [[ALAssetsLibrary alloc] init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    // Do any additional setup after loading the view.
    
   NSString* u_fName =  [NSString stringWithFormat:@"%@", [self.data.first_name stringByDecodingHTMLEntities]?[self.data.first_name stringByDecodingHTMLEntities]:@""];
    NSString* u_lName =  [NSString stringWithFormat:@"%@", [self.data.last_name stringByDecodingHTMLEntities]?[self.data.last_name stringByDecodingHTMLEntities]:@""];
    NSString* countrycode = [NSString stringWithFormat:@"%@", self.data.country_code?self.data.country_code:@""];
    [self.CountryCodeBtn setTitle:[NSString stringWithFormat:@"+%@",countrycode] forState:UIControlStateNormal];
    NSString* f_Upper = [u_fName capitalizedString];
    NSString* l_Upper = [u_lName capitalizedString];
    
    if(f_Upper!= (id)[NSNull null])
        self.fNameTF.text= f_Upper;
    else
        self.fNameTF.text=@"";
    if(l_Upper!= (id)[NSNull null])
        self.lNameTF.text=l_Upper;
    else
        self.lNameTF.text=@"";
    
    u_ProfileImg.image = [self getImage:@"MyProfileImage.png"];
    u_ProfileImg.layer.cornerRadius = u_ProfileImg.frame.size.height / 2;
    u_ProfileImg.clipsToBounds= YES;
    
    NSString*  u_country = [NSString stringWithFormat:@"%@", [self.data.country stringByDecodingHTMLEntities]?[self.data.country stringByDecodingHTMLEntities]:@""];
    NSString*  u_city = [NSString stringWithFormat:@"%@", [self.data.city stringByDecodingHTMLEntities]?[self.data.city stringByDecodingHTMLEntities]:@""];
    NSString *city_Upper = [u_city capitalizedString];
    NSString *country_Upper = [u_country capitalizedString];
    if(country_Upper!= (id)[NSNull null])
        self.nationalityTF.text= country_Upper;
        else
        self.nationalityTF.text=@"";
    
    if(city_Upper!= (id)[NSNull null])
        self.cityTF.text= city_Upper;
    else
        self.cityTF.text=@"";
    NSString* u_state = [NSString stringWithFormat:@"%@", [self.data.state stringByDecodingHTMLEntities]?[self.data.state stringByDecodingHTMLEntities]:@""];

    if(u_state!= (id)[NSNull null])
        self.stateTF.text= u_state;
    else
        self.stateTF.text=@"";
    NSString* u_mobileNo = [NSString stringWithFormat:@"%@", self.data.mobile?self.data.mobile:@""];
    self.contactNoTF.enabled = NO;
    if(u_mobileNo!= (id)[NSNull null])
        self.contactNoTF.text= u_mobileNo;
    else
        self.contactNoTF.text=@"";
    NSString* u_email = [NSString stringWithFormat:@"%@", self.data.email?self.data.email:@""];
    if(u_email!= (id)[NSNull null])
        self.emailTF.text=u_email;
    else
        self.emailTF.text=@"";
    
    //Initializing the array for inputItems
    inputItems = [NSArray arrayWithObjects:self.fNameTF,self.lNameTF,self.emailTF,self.nationalityTF,self.cityTF,self.stateTF,nil];
    //Create inputAccessoryView for all inputItems
    for (UITextField *tf in inputItems) {
        tf.inputAccessoryView = self.keybAccessory;
    }
    //Registring for keyboard notifications
    [self registerForKeyboardNotifications];
    keyboardHasAppeard = NO;
    
    //Registering Touch event on scroll
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.scroll addGestureRecognizer:singleTap];
}

-(void)viewWillAppear:(BOOL)animated{
    camImg.hidden = NO;
    self.scroll.contentSize=self.scvwContentView.frame.size;
    [self registerNotification];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationItem.title = @"Edit Personal Information";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = NO;
    if (isback==YES) {
        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
        [self.delegate EditProfileViewCallWithCustomid:[userdef objectForKey:custId] update_firstName:self.fNameTF.text update_lastName:self.lNameTF.text update_email:self.emailTF.text update_city:self.cityTF.text update_country:self.nationalityTF.text update_state:self.stateTF.text];
    }
    //[delegate imgupdates:imgUrl];
}
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"gotCountryList" object:nil];
}

#pragma mark - country list get Notification
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"gotCountryList"])
    {
        NSString *mobileCountryCode;
        NSString *mobileCountryISO;
        // NSLog (@"Successfully received MyAssociation");
        for (int i=0; i<[AppDelegate appDelegate].countryListArray.count; i++) {
            NSMutableDictionary *tempdic =[[AppDelegate appDelegate].countryListArray objectAtIndex:i];
            if ([[tempdic valueForKey:@"country_code"]caseInsensitiveCompare:[NSString stringWithFormat:@"%@", self.data.country_code?self.data.country_code:@""]]== NSOrderedSame) {
                mobileCountryCode = [tempdic valueForKey:@"country_code"];
                mobileCountryISO = [tempdic valueForKey:@"iso_code"];
                [self.CountryCodeBtn setTitle:[NSString stringWithFormat:@"%@ (+%@)",mobileCountryISO,mobileCountryCode] forState:UIControlStateNormal];
                break;
            }
        }
    }
}

#pragma mark - Save Button Action
-(IBAction)saveBtnClick:(id)sender{
    if (([self.fNameTF.text length] == 0)||([self.emailTF.text length] == 0)){
        [UIAppDelegate alerMassegeWithError:@"Please fill out all the fields." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    else if (![self.emailTF.text isEqualToString:@""])
    {
        NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        ////for Email
        if ([regextest evaluateWithObject:[emailTF.text lowercaseString]] == YES)
        {
        }
        else
        {
            [UIAppDelegate alerMassegeWithError:@"Please enter valid email Id." withButtonTitle:OK_STRING autoDismissFlag:NO];
            return;
        }
    }
    if (([self.fNameTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.first_name?self.data.first_name:@""]])&& ([self.lNameTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.last_name?self.data.last_name:@""]])&&([self.emailTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.email?self.data.email:@""]])&&([self.contactNoTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.mobile?self.data.mobile:@""]])&&([self.nationalityTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.country?self.data.country:@""]])&&([self.cityTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.city?self.data.city:@""]])&&([self.stateTF.text isEqualToString:[NSString stringWithFormat:@"%@", self.data.state?self.data.state:@""]])){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else{
    self.fNameTF.text =  [self.fNameTF.text stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    self.lNameTF.text =  [self.lNameTF.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    self.nationalityTF.text =  [self.nationalityTF.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    self.cityTF.text  =  [self.cityTF.text  stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.stateTF.text  =  [self.stateTF.text  stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
       

        //calling webservice for profile updates
        [self setProfileUpdateRequest:self.fNameTF.text  lastname:self.lNameTF.text email:self.emailTF.text country:self.nationalityTF.text city:self.cityTF.text state:self.stateTF.text];
    }
}

#pragma mark - profile Button Action
-(IBAction)profileBtnClick:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select profile photo from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera"otherButtonTitles:@"Photo gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1:
            switch (buttonIndex)
        {
            case 0:
            {
#if TARGET_IPHONE_SIMULATOR
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Camera not available." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
#elif TARGET_OS_IPHONE
                picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.editing = YES;
                picker.showsCameraControls = YES;
                picker.delegate = (id)self;
                [self presentViewController:picker animated:YES completion:nil];
#endif
            }
                break;
            case 1:
            {
                picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.delegate = self;
                picker.navigationBar.translucent = NO;
                picker.navigationBar.barTintColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
                picker.navigationBar.tintColor = [UIColor whiteColor];
                picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                [self presentViewController:picker animated:YES completion:nil];
            }
                break;
        }
            break;
        default:
            break;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* chosenImage = info[UIImagePickerControllerOriginalImage];
    chosenImage = chosenImage.fixOrientation;
    [self saveImage:chosenImage];
    [self.library saveImage:chosenImage toAlbum:@"Docquity Profile Photos" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            // NSLog(@"Big error: %@", [error description]);
        }
    }];
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.01);
    // NSLog(@"0.1 size: %d", imageData.length);
    
    NSString* u_ImgType = [self contentTypeForImageData:imageData];
    NSString* base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    [self setProfileImgUpdateRequest:base64EncodedString profileTypeImg:u_ImgType selectImg:chosenImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    if (!error)
    {
        //it worked do the thing
    }
}

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

#pragma mark - set user profile update api calling
-(void)setProfileUpdateRequest:(NSString*)first_name lastname:(NSString*)last_name email:(NSString*)email country:(NSString*)country city:(NSString*)city state:(NSString*)state{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetProfileRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] firstname:first_name lastname:last_name email:email mobile:@"" country:country city:city state:state format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        
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
                isback = YES;
                [self.navigationController popViewControllerAnimated:YES];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                [alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
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
                u_ProfileImg.image = chosesImage;
                camImg.hidden = YES;
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                [alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - next Button Action
- (IBAction)nextInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *nextInputField = [inputItems objectAtIndex:(idx + 1)];
    [nextInputField becomeFirstResponder];
}

#pragma mark - previous Button Action
- (IBAction)previousInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *prevInputField = [inputItems objectAtIndex:(idx - 1)];
    [prevInputField becomeFirstResponder];
}

#pragma mark - done Button Action
- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    //Adjust he inputAccessory according to the position of textField in inputItems
    NSUInteger idx = [inputItems indexOfObject:textField];
    self.previousBarBt.enabled = YES;
    self.nextBarBt.enabled = YES;
    if (idx == 0) {
        self.previousBarBt.enabled = NO;
    }else if(idx == (inputItems.count - 1)){
        self.nextBarBt.enabled = NO;
    }
    //scrolling the textField to visible area
    if (keyboardHasAppeard)
        [self.scroll scrollRectToVisible:[self getPaddedFrameForView:textField] animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    // NSLog(@"textFieldDidEndEditingcalled");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    // NSLog(@"textFieldShouldReturn called");
}

#pragma mark private methods
- (CGRect) getPaddedFrameForView:(UIView *) view
{
    CGFloat padding = 5;
    CGRect frame = view.frame;
    frame.size.height += 2 * padding;
    frame.origin.y -= padding;
    return frame;
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark Notification handlers
- (void)keyboardWasShown:(NSNotification*)notif
{
    NSDictionary* info = [notif userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scroll.contentInset = contentInsets;
    self.scroll.scrollIndicatorInsets = contentInsets;
    //scrolling the active field to visible area
    if ((nil != activeField) && (keyboardHasAppeard == NO))
        [self.scroll scrollRectToVisible:[self getPaddedFrameForView:activeField] animated:YES];
    keyboardHasAppeard = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)notif
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.scroll.contentInset = UIEdgeInsetsZero;
    self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
    keyboardHasAppeard = NO;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setFNameTF:nil];
    [self setLNameTF:nil];
    [self setContactNoTF:nil];
    [self setNationalityTF:nil];
    [self setCityTF:nil];
    [self setEmailTF:nil];
    [self setStateTF:nil];
    inputItems = nil;
    [self setScvwContentView:nil];
    [super viewDidUnload];
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

#pragma mark - getImage
- (UIImage*)getImage: (NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"Media"];
    NSString *getImagePath = [dataPath stringByAppendingPathComponent:filename];
    // NSLog(@"Get image path: %@",getImagePath);
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    if (img == nil && img == NULL)
    {
        img = [UIImage imageNamed:@"avatar.png"];
        // NSLog(@"no underlying data");
    }
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
