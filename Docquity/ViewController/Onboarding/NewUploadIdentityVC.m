/*============================================================================
 PROJECT: Docquity
 FILE:    NewUploadIdentityVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 8/27/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "NewUploadIdentityVC.h"
#import "Localytics.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"

/*============================================================================
 Interface:   uploadIdentityVC
 =============================================================================*/
@interface NewUploadIdentityVC ()
@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@end

@implementation NewUploadIdentityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[_btn_skip layer] setBorderWidth:1.0f];
    [[_btn_skip layer] setBorderColor:[UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0].CGColor];
    self.btn_skip.layer.cornerRadius = 4.0;
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didPressUploadID:)];
    tap.numberOfTapsRequired = 1.0;
    [self.backImageView addGestureRecognizer:tap];
    isImgUpload = FALSE;
    self.popupParentView.hidden = YES;
    //   documentList = [[NSMutableArray alloc]initWithObjects:@"Passport",@"Voter Identity Card",@"Defence ID",@"Employee ID Card",@"Arms Licence",nil];
    [self submitBtnActivate:FALSE];
    [self getDocumentListServiceCalling];
    [Localytics tagEvent:@"Onboarding Upload Identity Proof"];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Upload Identity Proof";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"help.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
}
-(void)viewDidAppear:(BOOL)animated{
    self.popupParentView.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.85];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.popupView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:86.0/255.0 green:173.0/255.0 blue:183.0/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:32.0/255.0 green:147.0/255.0 blue:197.0/255.0 alpha:1.0] CGColor], nil];
    gradient.startPoint = CGPointZero;
    [self.popupView.layer insertSublayer:gradient atIndex:0];
     UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnGotIt.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.btnGotIt.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.btnGotIt.layer.mask = maskLayer;
    
    self.popupView.layer.cornerRadius = 10.0;
    self.popupView.layer.masksToBounds = YES;
    
    
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
- (IBAction)didPressUploadID:(id)sender {
    
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
           // NSLog(@"AVAuthorizationStatusDenied");
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

-(void)choosePhoto{
    //  [Localytics tagEvent:@"OnBoarding UploadIDProofByGalleryButton Click"];
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
    self.backImageView.hidden = FALSE;
    self.backImageView.image = chosenImage;
    self.backImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backImageView.layer.masksToBounds = YES;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.1);
    u_ImgType = [self contentTypeForImageData:imageData];
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.chooseImgHolder.hidden = YES;
    [self submitBtnActivate:YES];
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

- (IBAction)didPressKnowIDProof:(id)sender {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:1.0 animations:^{
        self.popupParentView.hidden = false;
        
    }];
}
- (IBAction)didPressSubmit:(id)sender {
  //  NSLog(@"submit check img status : %d",isImgUpload);
    [self submitBtnActivate:FALSE];
    isImgUpload?[self claimAccountServiceCalling]:[self UserIDUpload];
    [[AppDelegate appDelegate] showIndicator];
  }
#pragma mark - Tableview Delegate and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return documentList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [documentList objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightLight];
    cell.imageView.image = [UIImage imageNamed:@"valididproofpoptick.png"];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor =  [UIColor clearColor];
    return cell;
}

- (IBAction)didPressGotIT:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        self.popupParentView.hidden = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
}

-(void)submitBtnActivate:(BOOL)flag{
    self.btnSubmit.enabled = flag;
    if(!flag)
        self.btnSubmit.alpha = 0.5;
    else
        self.btnSubmit.alpha = 1.0;
}

#pragma mark - Web service calling
- (void) UserIDUpload
{
  //  NSLog(@"UserIDUpload service calling");
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:base64EncodedString,base64Str1,u_ImgType,Image1,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
 //   NSLog(@"UserIDUpload data dic = %@",dataDic);
    [obj sendRequestToServer:aDic withDataDic:dataDic];
    //NSLog(@"serviceCalling");
}

- (void) claimAccountServiceCalling
{
  //  NSLog(@"claimAccountServiceCalling");
     NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetClaimAccount], keyRequestType1, nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetClaimAccount;
    obj.delegate = self;
    NSDictionary *dataDic =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[self.userData valueForKey:dc_firstName]],dc_firstName,[NSString stringWithFormat:@"%@",[self.userData valueForKey:dc_lastName]],dc_lastName,[NSString stringWithFormat:@"%@",[self.userData valueForKey:UserRegNo]?[self.userData valueForKey:UserRegNo]:@""],UserRegNo, [NSString stringWithFormat:@"%@",[self.userData valueForKey:emailId1]],emailId1,[NSString stringWithFormat:@"%@",self.selectedCountry],user_country,[NSString stringWithFormat:@"%@",[self.userData valueForKey:Image1]?[self.userData valueForKey:Image1]:@""] ,Image1,nil];
   // NSLog(@"claimAccountServiceCalling on new upload identity data dic = %@",dataDic);
     [obj sendRequestToServer:aDic withDataDic:dataDic];
    // NSLog(@"serviceCalling");
}

- (void) getDocumentListServiceCalling
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setObject:self.selectedAssoID?self.selectedAssoID:@"" forKey:documentbasedAssoId];
    [[DocquityServerEngine sharedInstance]GetDocqumentListRequestWithAccessKey:@"d3aeebaa5a03986262f51ced95b4ccac" association_id:self.selectedAssoID format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
         [[AppDelegate appDelegate] hideIndicator];
        NSMutableDictionary *postDic = [[responceObject objectForKey:@"posts"] mutableCopy];
        // NSLog(@"%@",postDic);
        if ([postDic isKindOfClass:[NSNull class]] || (postDic == nil))
          {
            //NSLog(@"Document data is Null");
          }else if(![[postDic valueForKey:@"data"] isKindOfClass:[NSArray class]]){
            // NSLog(@"Document data is not array type");
        }
         else {
            NSString *stus=[NSString stringWithFormat:@"%@", [postDic objectForKey:@"status"]?[postDic  objectForKey:@"status"]:@""];
               int respSts = [stus intValue];
              if (respSts == 1) {
                   documentList = [[NSMutableArray alloc]init];
                     documentList = [postDic valueForKey:@"data"];
                 [self.tableView reloadData];
            }
             else if(respSts==9){
                  [[AppDelegate appDelegate] logOut];
             }
         }
     }];
 }

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    [[AppDelegate appDelegate] hideIndicator];
    if(currentRequestType == kSetUploadFileRequest)
        [self performSelector:@selector(UserIDUploadResponse:) withObject:responseData afterDelay:0.000];
    else if(currentRequestType == kSetClaimAccount)
        [self performSelector:@selector(claimAccountResponse:) withObject:responseData afterDelay:0.000];
    else if(currentRequestType == kGetDocumentList)
        [self performSelector:@selector(getDocumentListResponse:) withObject:responseData afterDelay:0.000];
    else if (currentRequestType ==  kGetFreiendlist)
        [self performSelector:@selector(getFriendListResponse:) withObject:responseData afterDelay:0.000];
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
 //   NSLog(@"Req error for %d",currentRequestType);
  //  NSLog(@"%d",isImgUpload);
    if(currentRequestType == kSetUploadFileRequest){
        isImgUpload = false;
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
    }
    [self submitBtnActivate:YES];
}

-(void)UserIDUploadResponse:(NSDictionary *)response{
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    //NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        [self submitBtnActivate:YES];
    }
    else {
         if ([[postDic valueForKey:@"status"]integerValue] == 0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            [self submitBtnActivate:YES];
            
        }
         else if ([[postDic valueForKey:@"status"]integerValue] == 1) {
            isImgUpload = YES;
              NSString* fileUrl= [NSString stringWithFormat:@"%@",[postDic objectForKey:@"file_url"]?[postDic objectForKey:@"file_url"]:@""];
            [self.userData setObject:fileUrl forKey:Image1];
            [self claimAccountServiceCalling];
        }
    }
}

- (void) claimAccountResponse:(NSDictionary *)response
{
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
   // NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        [self submitBtnActivate:YES];
    }
    else {
        responseStatus = [[postDic valueForKey:@"status"]integerValue];
        if (responseStatus==0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
            [self submitBtnActivate:YES];
        }
        else if(responseStatus == 1){
            [self updateUserDefaults:postDic];
        }
            else if(responseStatus == 3){
            [self updateUserDefaults:postDic];
            
        }else if(responseStatus == 4){
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
            isImgUpload = false;
            [self submitBtnActivate:YES];
        }
    }
}

- (void) getDocumentListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *postDic = [response objectForKey:@"posts"];
 //   NSLog(@"%@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || (postDic == nil))
    {
        //NSLog(@"Document data is Null");
    }
    else if(![[postDic valueForKey:@"data"] isKindOfClass:[NSMutableArray class]])
    {
        // NSLog(@"Document data is not array type");
    }
    else {
        NSString *stus=[NSString stringWithFormat:@"%@", [postDic objectForKey:@"status"]?[postDic  objectForKey:@"status"]:@""];
        int respSts = [stus intValue];
        if (respSts == 1) {
            documentList = [[NSMutableArray alloc]init];
            documentList = [postDic valueForKey:@"data"];
            [self.tableView reloadData];
        }
        else if(respSts==9){
            [[AppDelegate appDelegate] logOut];
        }
        else{
        }
    }
}

#pragma mark - Mail Service
-(void)openMail{
    if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:AppName message:@"Mail services are not available. Please configure your mail service first." buttonTitle:OK_STRING];
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

#pragma mark - Store values
-(void)updateUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil)
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        
        return;
    }
    
    else {
         NSString*userpermision = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"permission"]?[resposeCode  objectForKey:@"permission"]:@""];
        [userpref setObject:userpermision?userpermision:@"" forKey:user_permission];
         NSString* userCity = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        [userpref setObject:userCity?userCity:@"" forKey:user_city];
          NSString*userCountry = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
           NSString*userCountryCode = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
          NSString*customId =[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"custom_id"]?[resposeCode  objectForKey:@"custom_id"]:@""];
        [Localytics setCustomerId:customId];
        [userpref setObject:customId?customId:@"" forKey:ownerCustId];
        [userpref setObject:customId?customId:@"" forKey:custId];
        
        NSString*u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        [Localytics setCustomerEmail:u_email];
        [userpref setObject:u_email?u_email:@"" forKey:emailId1];
        
        NSString*u_fName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"first_name"]?[resposeCode  objectForKey:@"first_name"]:@""];
        [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
        
        NSString*JabberID = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_id"]?[resposeCode  objectForKey:@"jabber_id"]:@""];
        [userpref setObject:JabberID?JabberID:@"" forKey:jabberId];
        
        NSString*u_lName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"last_name"]?[resposeCode  objectForKey:@"last_name"]:@""];
        [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
        
        NSString*userMobNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
        
        NSString*usersPic = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"profile_pic_path"]?[resposeCode  objectForKey:@"profile_pic_path"]:@""];
        [userpref setObject:usersPic?usersPic:@"" forKey:profileImage];
        
        NSString *userRegNo = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"registration_no"]?[resposeCode  objectForKey:@"registration_no"]:@""];
        [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        
        NSString *userState = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        [userpref setObject:userState?userState:@"" forKey:user_state];
        
        NSString *uId=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"user_id"]?[resposeCode  objectForKey:@"user_id"]:@""];
        [userpref setObject:uId?uId:@"" forKey:userId];
        
        NSString *refLink = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"referal_id"]?[resposeCode  objectForKey:@"referal_id"]:@""];
        [userpref setObject:refLink?refLink:@"" forKey:shareRefLink];
        [userpref synchronize];
     }
    NSMutableDictionary*usrAuthkey  = [postDic objectForKey:@"user_auth_key"];
    if ([usrAuthkey  isKindOfClass:[NSNull class]] || usrAuthkey == nil)
    {
        // usrAuthkey is null
    }
    else
    {
        NSString *u_authkey=[NSString stringWithFormat:@"%@", [usrAuthkey objectForKey:@"auth_key"]?[usrAuthkey objectForKey:@"auth_key"]:@""];
        [userpref setObject:u_authkey?u_authkey:@"" forKey:userAuthKey];
  //      NSLog(@"User authkey set at upload idenetiy");
        [userpref synchronize];
    }
     NSMutableDictionary*usrjabber  = [postDic objectForKey:@"jabber"];
    if ([usrjabber  isKindOfClass:[NSNull class]] || usrjabber == nil)
    {
        // usrjabber is null
    }
    else {
        NSString *jabberPassword=[NSString stringWithFormat:@"%@", [usrjabber objectForKey:@"password"]?[usrjabber objectForKey:@"password"]:@""];
        [userpref setObject:jabberPassword?jabberPassword:@"" forKey:password1];
        [userpref synchronize];
    }
    NSMutableDictionary *spclDic = [postDic objectForKey:@"speciality_list"];
    if([[spclDic  valueForKey:@"status"]integerValue] == 1){
     NSString *DocSpecility;
        if ([spclDic  isKindOfClass:[NSNull class]] || spclDic==nil)
        {
            // usrAuthkey is null
        }
        else {
            NSMutableArray *mainSpeciality =[[NSMutableArray alloc]init];
            mainSpeciality  = [spclDic objectForKey:@"speciality"];
            if([mainSpeciality count] && [mainSpeciality isKindOfClass:[NSMutableArray class]]){
                DocSpecility = [[mainSpeciality  objectAtIndex:0] valueForKey:@"speciality_name"];
                [userpref setObject:DocSpecility?DocSpecility:@"" forKey:docSpecility];
                [userpref synchronize];
            }
        }
    }
    [userpref synchronize];
    [self downloadWithNsurlconnection];
   // [[AppDelegate appDelegate] connect];
    [self getFriendListServiceCalling];

}

- (void) getFriendListServiceCalling //Get friend list Request
{
    //[[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetFreiendlist], keyRequestType1,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kGetFreiendlist;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:nil];
    // NSLog(@"serviceCalling1");
}

- (void) getFriendListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]] || (resposeCode == nil))
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            self.frndListArr = [resposeCode objectForKey:@"friendlist"];
            if([self.frndListArr count] && [self.frndListArr isKindOfClass:[NSMutableArray class]])
                for(int i =0; i<[self.frndListArr count];i++)
                {
                    NSDictionary*frndDic =[self.frndListArr objectAtIndex:i];
                    if(frndDic && [frndDic isKindOfClass:[NSDictionary class]])
                    {
                        NSString *usernName = [NSString stringWithFormat:@"%@", [frndDic objectForKey:@"first_name"]?[frndDic  objectForKey:@"first_name"]:@""];
                        NSString *jid = [NSString stringWithFormat:@"%@", [frndDic objectForKey:@"jabber_id"]?[frndDic  objectForKey:@"jabber_id"]:@""];
                        [self insertContactWithUserName:usernName andJid:jid];
                    }
                }
        }
    }
    [self pushToFeedVc];
}


#pragma mark - download profile
-(void)downloadWithNsurlconnection
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ImageUrl@"%@",userPic]];
    // NSLog(@"Login IMG URL : %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
  //  NSLog(@"connection : %@",connection);
}

#pragma mark - NSURL Connection Delegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    self.RecvimageData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.RecvimageData appendData:data];
    self.receivedBytes += data.length;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *savedImagePath = [[[AppDelegate appDelegate]dataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"MyProfileImage.png"]];
    mediaPath = [NSString stringWithFormat:@"MyProfileImage.png"];
    // NSLog(@"Media Path : %@",mediaPath);
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    UIImage *SaveImage = [UIImage imageWithData:self.RecvimageData];
    NSData *imageData = UIImageJPEGRepresentation(SaveImage, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(SaveImage, compression);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [imageData writeToFile:savedImagePath atomically:NO];
}

#pragma mark - Database handling
-(void)insertContactWithUserName:(NSString*)usernName andJid:(NSString*)jid
{
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    NSString *insertQuery= [NSString stringWithFormat:@"INSERT INTO  contacts (username,nickname) VALUES ('%@','%@')",jid,usernName];
    [self.dbManager executeQuery:insertQuery];
}

#pragma mark - Pushing to skipBtnAction
- (IBAction)didPressSkipBtn:(id)sender {
   [self claimAccountServiceCalling];
   [[AppDelegate appDelegate] showIndicator];
}

#pragma mark - Pushing to views
-(void)pushToFeedVc{
    [Localytics tagEvent:@"Onboarding New User Validated"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setBool:YES forKey:signInnormal];
     [[AppDelegate appDelegate] navigateToTabBarScren:0];
    //[self navigateToTabBarScren];
}


@end
