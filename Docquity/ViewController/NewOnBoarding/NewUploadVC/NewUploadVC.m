//
//  NewUploadVC.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewUploadVC.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"

@interface NewUploadVC ()

@end

@implementation NewUploadVC
@synthesize btn_skip,btnGotIt;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithHeaderLogoWithOutHelpImageAndBarButtonItems:@"Proof of Identity"];
//     UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userClicked:)];
//    gesture.numberOfTapsRequired = 1;
//    [_imageViewUserIdentityImage addGestureRecognizer:gesture];
  
    //    if(array.count==1)
    //    {
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    //       // NSLog(@"Seelcted id: %@",selectedAssoId);
    //    }
    NSString*selected_AssociationId;
    if ([_registeredUserType isEqualToString:@"doctor"]) {
       
      NSMutableArray *AssoIdArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"AssociationIdArray"] mutableCopy];
        if ([AssoIdArray count] == 0)
        {
            selected_AssociationId = @"34";
        }
        else
        {
        selected_AssociationId  = [[AssoIdArray valueForKey:@"description"] componentsJoinedByString:@","];
            if ([AssoIdArray count] == 1)
            {
            }
            else {
             NSRange FromRange = [selected_AssociationId rangeOfString:@","];
            if (FromRange.location==0) {
                selected_AssociationId=nil;
            }
            else{
               selected_AssociationId = [selected_AssociationId substringWithRange:NSMakeRange(0,FromRange.location)];
                //NSLog(@"Message from: %@",from);
            }
         }
    }
      }
    if ([_registeredUserType isEqualToString:@"student"]) {
        selected_AssociationId = @"30";
    }
    
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setObject:selected_AssociationId?selected_AssociationId:@"" forKey:documentbasedAssoId];
    [userpref synchronize];
    
    [self getDocumentListServiceCalling:selected_AssociationId];
    _uploadBtn.hidden = YES;
     btn_skip.hidden = NO;
     self.popupParentView.hidden = YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [Localytics tagEvent:@"OnboardingUploadIdsScreen Visit"];
    [self callingGoogleAnalyticFunction:@"OnboardingUploadIdsScreen" screenAction:@"OnboardingUploadIdsScreen Visit"];
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
   _imageViewUserIdentityImage.hidden = FALSE;
   _imageViewUserIdentityImage.image = chosenImage;
    _imageViewUserIdentityImage.contentMode = UIViewContentModeScaleAspectFit;
    _imageViewUserIdentityImage.layer.masksToBounds = YES;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.1);
    u_ImgType = [self contentTypeForImageData:imageData];
    //NSLog(@"imageType= %@", u_ImgType);
    
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //self.chooseImageViewHolder.hidden = YES;
    //[self uploadBtnActivate:YES];
   // [self saveImage:chosenImage];
    [self  UserIDUpload];
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

#pragma mark - know your valid Identity Proof Check
-(IBAction)btnKnowValidClicked:(id)sender{
//[self.navigationController setNavigationBarHidden:YES animated:YES];
[UIView animateWithDuration:1.0 animations:^{
    self.popupParentView.hidden = false;
}];
}

#pragma mark - Got It
- (IBAction)didPressGotIT:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
    self.popupParentView.hidden = YES;
   // [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightLight];
    cell.textLabel.numberOfLines = 2;
    cell.imageView.image = [UIImage imageNamed:@"BlueTickImage.png"];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor =  [UIColor clearColor];
    return cell;
}

#pragma mark - skipBtnAction
- (IBAction)didPressSkip:(id)sender
{
    [Localytics tagEvent:@"OnboardingUploadIdsScreen Skip Click"];
    [self callingGoogleAnalyticFunction:@"OnboardingUploadIdsScreen" screenAction:@"OnboardingUploadIdsScreen Skip"];
    [self pushToFeedVc];
}

#pragma mark - uplaodBtnAction
- (IBAction)didPressUpload:(id)sender
{
 [self SetUpdateIdentificationRequestData];
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
        //NSLog(@"UserIDUpload service calling");
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
        NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:base64EncodedString,base64Str1,u_ImgType,Image1,nil];
        Server *obj = [[Server alloc] init];
        currentRequestType = kSetUploadFileRequest;
        obj.delegate = self;
        //NSLog(@"UserIDUpload data dic = %@",dataDic);
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

- (IBAction)didPressIdentityProof:(id)sender{
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

#pragma mark - userId Upload response
-(void)UserIDUploadResponse:(NSDictionary *)response{
    NSDictionary *postDic = [response objectForKey:@"posts"];
   // NSString *msg =  [postDic valueForKey:@"msg"];
    //NSLog(@"postDic response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
   {
       // [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
       // [self submitBtnActivate:YES];
   }
 else {
    if ([[postDic valueForKey:@"status"]integerValue] == 0)
    {
           // [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
           // [self submitBtnActivate:YES];
    }
else if ([[postDic valueForKey:@"status"]integerValue] == 1)
    {
           // isImgUpload = YES;
        fileUrl= [NSString stringWithFormat:@"%@",[postDic objectForKey:@"file_url"]?[postDic objectForKey:@"file_url"]:@""];
        
        btn_skip.hidden = YES;
       _uploadBtn.hidden = NO;
    }
 }
}

#pragma mark - documentList Api calling
- (void) getDocumentListServiceCalling:(NSString*)AssociationID
{
    // NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    //[userpref setObject:self.selectedAssoID?self.selectedAssoID:@"" forKey:documentbasedAssoId];
    [[DocquityServerEngine sharedInstance]GetDocqumentListRequestWithAccessKey:@"d3aeebaa5a03986262f51ced95b4ccac" association_id:AssociationID format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
       // [[AppDelegate appDelegate] hideIndicator];
        NSMutableDictionary *postDic = [[responceObject objectForKey:@"posts"] mutableCopy];
        // NSLog(@"%@",postDic);
        if ([postDic isKindOfClass:[NSNull class]] || (postDic == nil))
        {
            //NSLog(@"Document data is Null");
        }else if(![[postDic valueForKey:@"data"] isKindOfClass:[NSArray class]]){
            // NSLog(@"Document data is not array type");
        }
        else {
            if ([[postDic valueForKey:@"status"]integerValue] == 1)
            {
                documentList = [[NSMutableArray alloc]init];
                documentList = [postDic valueForKey:@"data"];
                [self.tableView reloadData];
            }
            else if ([[postDic valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate] logOut];
            }
        }
    }];
}

#pragma mark - Pushing to views
-(void)pushToFeedVc
{
     [[AppDelegate appDelegate] navigateToTabBarScren:0];
    // [[AppDelegate appDelegate] cancelLoginN];
}

#pragma mark - check Update Identification Request calling
-(void)SetUpdateIdentificationRequestData{
    [WebServiceCall showHUD];
   // [[AppDelegate appDelegate] showIndicator];
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *idproof = fileUrl;
    [[DocquityServerEngine sharedInstance]update_identificationRequest:[userpref objectForKey:userAuthKey] invite_code:@"" identity_proof:idproof device_type:kDeviceType app_version:[userpref valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary* responceObject, NSError* error)
    {
        //NSLog(@"responceObject = %@",responceObject);
        //[[AppDelegate appDelegate] hideIndicator];
        [SVProgressHUD dismiss];
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            //tel is null
        }
        else {
            NSString*stusmsg=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                [self pushToFeedVc];
                /*
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
                 */
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                //[[AppDelegate appDelegate] hideIndicator];
                [[AppDelegate appDelegate] logOut];
            }
            else{
               // [[AppDelegate appDelegate] hideIndicator];
                [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
        }
    }];
}

#pragma mark - view Did Appear
-(void)viewDidAppear:(BOOL)animated{
    // [self.tf_RegNo becomeFirstResponder];
    self.popupParentView.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.85];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.popupView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
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
    //Dispose of any resources that can be recreated.
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
