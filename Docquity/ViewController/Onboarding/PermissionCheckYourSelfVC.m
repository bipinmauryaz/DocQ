//
//  PermissionCheckYourSelfVC.m
//  Docquity
//
//  Created by Arimardan Singh on 26/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "PermissionCheckYourSelfVC.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "AppDelegate.h"

@interface PermissionCheckYourSelfVC (){
    NSString*ImgUrl;
}
@end

@implementation PermissionCheckYourSelfVC
@synthesize titleMsg,titledesc,tf_placeholder,idetityValue,IcnumberValue;
@synthesize identityTypMsg;

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    _lbl_TitleMsg.text = titleMsg;
    if ([IcnumberValue integerValue] == 1 && [idetityValue integerValue] == 1)
    {
        NSRange range = [titledesc rangeOfString:@"-"];
        if (range.location != NSNotFound) {
            _lbl_TitleMsg.text = titleMsg;
             NSString *newString = [titledesc substringToIndex:range.location];
            _lbl_title_desc.text =  [NSString stringWithFormat:@"Please enter %@",newString?newString:@""];
            // NSLog(@"New string = %@",newString);
        }
        else{
            _lbl_TitleMsg.text = titleMsg;
            _lbl_title_desc.text =  [NSString stringWithFormat:@"Please enter %@",titledesc?titledesc:@""];
        }
        _tf_RegNo.placeholder = tf_placeholder;
        _lbl_documentUpload.text = identityTypMsg;
        [self submitBtnActivate:YES];
    }
    else if ([IcnumberValue integerValue] == 0 && [idetityValue integerValue] == 0)
    {
        _lbl_welcomemsg.hidden = NO;
        _lbl_welcomemsg.text = titleMsg;
        _lbl_TitleMsg.hidden =YES;
        _lbl_title_desc.hidden =YES;
        _tf_RegNo.hidden =YES;
        _backImageView.hidden =YES;
        _chooseImgHolder.hidden =YES;
        _tableView.hidden =YES;
        _popupParentView.hidden =YES;
        _popupView.hidden =YES;
        _btnknowYourIdProof.hidden = YES;
        _lbl_documentUpload.hidden =YES;
        _btnSubmit.hidden =YES;
    }
    else if ([IcnumberValue integerValue] == 0 && [idetityValue integerValue] == 1)
    {
        _lbl_title_desc.hidden =YES;
        _lbl_TitleMsg.text = titleMsg;
        _tf_RegNo.hidden =YES;
        [self submitBtnActivate:NO];
    }
    else if ([IcnumberValue integerValue] == 1 && [idetityValue integerValue] == 0)
    {
        _lbl_TitleMsg.text = titleMsg;
        [self.tf_RegNo becomeFirstResponder];
        _backImageView.hidden =YES;
        _chooseImgHolder.hidden =YES;
        _tableView.hidden =YES;
        _popupParentView.hidden =YES;
        _popupView.hidden =YES;
        _btnknowYourIdProof.hidden =YES;
        _lbl_documentUpload.hidden =YES;
        _lbl_welcomemsg.hidden =YES;
        NSRange range = [titledesc rangeOfString:@"-"];
        if (range.location != NSNotFound) {
            NSString *newString = [titledesc substringToIndex:range.location];
            _lbl_title_desc.text =  [NSString stringWithFormat:@"Please enter %@",newString?newString:@""];
            // NSLog(@"New string = %@",newString);
        }
        else{
            _lbl_title_desc.text =  [NSString stringWithFormat:@"Please enter %@",titledesc?titledesc:@""];
        }
        _tf_RegNo.placeholder = tf_placeholder;
        [self submitBtnActivate:YES];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didPressUploadID:)];
    tap.numberOfTapsRequired = 1.0;
    [self.backImageView addGestureRecognizer:tap];
    self.popupParentView.hidden = YES;
    
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    self.selectedAssoID = [userpref objectForKey:documentbasedAssoId];
    [self getDocumentListServiceCalling:self.selectedAssoID];
    
    self.tf_RegNo.layer.cornerRadius = 25;
    self.tf_RegNo.layer.masksToBounds = YES;
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
}

-(void)submitBtnActivate:(BOOL)flag{
    self.btnSubmit.enabled = flag;
    if(!flag)
        self.btnSubmit.alpha = 0.5;
    else
        self.btnSubmit.alpha = 1.0;
}

-(void)viewDidAppear:(BOOL)animated{
    // [self.tf_RegNo becomeFirstResponder];
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

#pragma mark - uploadId Action
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

#pragma mark - take Photo Action
- (void)takePhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:Nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied)
        {
            //NSLog(@"AVAuthorizationStatusDenied");
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

#pragma mark - choose Photo Action
-(void)choosePhoto{
    //[Localytics tagEvent:@"OnBoarding UploadIDProofByGalleryButton Click"];
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

#pragma mark - Know Id Proof Action
- (IBAction)didPressKnowIDProof:(id)sender {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:1.0 animations:^{
        self.popupParentView.hidden = false;
    }];
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

#pragma mark - Got it Button Action
- (IBAction)didPressGotIT:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
    self.popupParentView.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
}

#pragma mark -  submit Button Action
- (IBAction)didPressSubmit:(id)sender {
    //  NSLog(@"submit check img status : %d",isImgUpload);
    if ([IcnumberValue integerValue] == 1 && [idetityValue integerValue] == 1)
    {
        if(base64EncodedString.length >0){
            isImgUpload?[self SetUpdateIdentificationRequestData]:[self UserIDUpload];
        }
        else{
            if ([_tf_RegNo.text length] == 0){
                [UIAppDelegate alerMassegeWithError:[NSString stringWithFormat:@"%@ or upload a document.",_lbl_title_desc.text?_lbl_title_desc.text:@""] withButtonTitle:OK_STRING autoDismissFlag:NO];
                return;
            }
            else{
                [self SetUpdateIdentificationRequestData];
            }
        }
    }
    else if ([IcnumberValue integerValue] == 0 && [idetityValue integerValue] == 1)
    {
        if(base64EncodedString.length >0){
            isImgUpload?[self SetUpdateIdentificationRequestData]:[self UserIDUpload];
        }
        else {
            [UIAppDelegate alerMassegeWithError:[NSString stringWithFormat:@"Please %@",identityTypMsg?identityTypMsg:@""] withButtonTitle:@"OK" autoDismissFlag:NO];
            return;
        }
    }
    else if ([IcnumberValue integerValue] == 1 && [idetityValue integerValue] == 0)
    {
        if ([_tf_RegNo.text length] == 0){
            [UIAppDelegate alerMassegeWithError:[NSString stringWithFormat:@"%@",_lbl_title_desc.text?_lbl_title_desc.text:@""] withButtonTitle:OK_STRING autoDismissFlag:NO];
            return;
        }
        else{
            [self SetUpdateIdentificationRequestData] ;
        }
    }
}

#pragma mark - check Update Identification Request calling
-(void)SetUpdateIdentificationRequestData{
    [[AppDelegate appDelegate] showIndicator];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *idproof = fileUrl;
    [[DocquityServerEngine sharedInstance]update_identificationRequest:[userpref objectForKey:userAuthKey] invite_code:_tf_RegNo.text identity_proof:idproof device_type:kDeviceType app_version:[userpref valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        [[AppDelegate appDelegate] hideIndicator];
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            //tel is null
        }
        else {
            NSString*stusmsg=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                _lbl_title_desc.hidden =YES;
                _tf_RegNo.hidden =YES;
                _backImageView.hidden =YES;
                _chooseImgHolder.hidden =YES;
                _tableView.hidden =YES;
                _popupParentView.hidden =YES;
                _popupView.hidden =YES;
                _btnknowYourIdProof.hidden =YES;
                _lbl_documentUpload.hidden =YES;
                _btnSubmit.hidden =YES;
                _lbl_TitleMsg.hidden =YES;
                _lbl_welcomemsg.hidden =NO;
                _lbl_welcomemsg.text = stusmsg;
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] hideIndicator];
                [[AppDelegate appDelegate] logOut];
            }
            else{
                [[AppDelegate appDelegate] hideIndicator];
                [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
        }
    }];
}

#pragma mark - Web service calling
- (void) UserIDUpload
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else{
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
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    [[AppDelegate appDelegate] hideIndicator];
    if(currentRequestType == kSetUploadFileRequest)
        [self performSelector:@selector(UserIDUploadResponse:) withObject:responseData afterDelay:0.000];
    else if(currentRequestType == kGetDocumentList)
    [self performSelector:@selector(getDocumentListResponse:) withObject:responseData afterDelay:0.000];
}

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
}

#pragma mark - get document list api response
- (void) getDocumentListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *postDic = [response objectForKey:@"posts"];
    //   NSLog(@"%@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || (postDic == nil))
    {
        //NSLog(@"Document data is Null");
    }
    else if(![[postDic valueForKey:@"data"] isKindOfClass:[NSMutableArray class]]){
        // NSLog(@"Document data is not array type");
    }
    else {
        if([[postDic valueForKey:@"status"]integerValue] == 1){
            documentList = [[NSMutableArray alloc]init];
            documentList = [postDic valueForKey:@"data"];
            [self.tableView reloadData];
        }
        else  if ([[postDic valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
        else  if ([[postDic valueForKey:@"status"]integerValue] == 0)
        {
        }
    }
}

#pragma mark - Pushing to skipBtnAction
- (IBAction)didPressSkipBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - userId Upload response
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
        else if ([[postDic valueForKey:@"status"]integerValue] == 1){
            isImgUpload = YES;
            fileUrl= [NSString stringWithFormat:@"%@",[postDic objectForKey:@"file_url"]?[postDic objectForKey:@"file_url"]:@""];
            [self SetUpdateIdentificationRequestData];
        }
    }
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // [self submitBtnActivate:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) getDocumentListServiceCalling:(NSString*)AssociationID
{
   // NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    //[userpref setObject:self.selectedAssoID?self.selectedAssoID:@"" forKey:documentbasedAssoId];
    [[DocquityServerEngine sharedInstance]GetDocqumentListRequestWithAccessKey:@"d3aeebaa5a03986262f51ced95b4ccac" association_id:AssociationID format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
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
            if ([[postDic valueForKey:@"status"]integerValue] == 1) {
                documentList = [[NSMutableArray alloc]init];
                documentList = [postDic valueForKey:@"data"];
                [self.tableView reloadData];
            }
            else  if ([[postDic valueForKey:@"status"]integerValue] == 9) {
                [[AppDelegate appDelegate] logOut];
            }
        }
    }];
}

@end
