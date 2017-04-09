/*============================================================================
 PROJECT: Docquity
 FILE:    ThankYouVC.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 01/09/16.
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
#import "ThankYouVC.h"
#import "MobileVerifyVC.h"
#import "AppDelegate.h"
#import "Localytics.h"

/*============================================================================
 Interface:   ThankYouVC
 =============================================================================*/
@interface ThankYouVC ()

@end

@implementation ThankYouVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblMessage.text = self.welcomeMsg;
    [Localytics tagEvent:@"Onboarding New User Registered"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.title = @"Thank You";
    self.navigationItem.hidesBackButton = true;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"help.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
    if (self.checkforUser) {
        //NSLog(@"checkforUser true");
        [self getUserValidated];
    }
  }

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = true;
}

- (IBAction)didPressGoToHome:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppName message:@"Do you want to login using a different mobile number?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[MobileVerifyVC class]])
            {
                [self.navigationController popToViewController:controller
                                                      animated:YES];
                break;
            }
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
  }

#pragma mark - Mail Service
-(void)openMail{
     if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:AppName message:@"Mail services are not available. Please configure your mail service first." buttonTitle:@"OK"];
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

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark WebService Calls GetCountryList
- (void)getUserValidated
{
    //NSLog(@"getUserValidated thank : ");
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kValidatedUserOnSplash], keyRequestType1, nil];
    Server *server = [[Server alloc] init];
    currentRequestType = kValidatedUserOnSplash;
    server.delegate = self;
    [server sendRequestToServer:aDic withDataDic:nil];
}

- (void) getFriendListServiceCalling //Get friend list Request
{
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetFreiendlist], keyRequestType1,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kGetFreiendlist;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:nil];
    // NSLog(@"serviceCalling1");
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    [[AppDelegate appDelegate] hideIndicator];
    switch (currentRequestType)
    {
        case kValidatedUserOnSplash:
            [self performSelector:@selector(validatedUserResponse:) withObject:responseData afterDelay:0.000];
            break;
  
        case kGetFreiendlist:
            [[AppDelegate appDelegate]showIndicator];
            [self performSelector:@selector(getFriendListResponse:) withObject:responseData afterDelay:0.000];
            break;
            
        default:
            break;
    }
 }

- (void) requestError
{
    [[AppDelegate appDelegate] hideIndicator];
    // NSLog(@"requestError thank : ");
}

-(void)validatedUserResponse:(NSDictionary *)response{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *postDic = [response objectForKey:@"posts"];
    NSString *msg =  [postDic valueForKey:@"msg"];
    // NSLog(@"MobileVerification Response = %@",postDic);
    if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
        
    }else {
        statusResponse = [[postDic valueForKey:@"status"]integerValue ];
        if (statusResponse == 0) {
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
        }else if (statusResponse == 1){
            [self updateUserDefaults:postDic];
        }else if (statusResponse == 3){
            self.lblMessage.text = msg;
        }else if (statusResponse == 6){
            [self didPressGoToHome:nil];
        }else if (statusResponse == 8){
            self.lblMessage.text = msg;
            [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:@"OK"];
        }else if (statusResponse == 9){
            [self didPressGoToHome:nil];
        }
    }
}

- (void) getFriendListResponse:(NSDictionary *)response
{
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]] || (resposeCode == nil))
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
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

#pragma mark - Store values
-(void)updateUserDefaults:(NSDictionary*)postDic{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *resposeCode = [postDic objectForKey:@"data"];
    if ([resposeCode isKindOfClass:[NSNull class]] || resposeCode == nil || (![[postDic objectForKey:@"data"] isKindOfClass:[NSMutableDictionary class]]))
    {
        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
        return;
    }
    else {
        
        NSString*userpermision = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"permission"]?[resposeCode  objectForKey:@"permission"]:@""];
        
        [userpref setObject:userpermision?userpermision:@"" forKey:user_permission];
        
        NSString *userCity = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"city"]?[resposeCode  objectForKey:@"city"]:@""];
        [userpref setObject:userCity?userCity:@"" forKey:user_city];
        
        NSString *userCountry = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country"]?[resposeCode  objectForKey:@"country"]:@""];
        [userpref setObject:userCountry?userCountry:@"" forKey:user_country];
        
        NSString *userCountryCode = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"country_code"]?[resposeCode  objectForKey:@"country_code"]:@""];
        [userpref setObject:userCountryCode?userCountryCode:@"" forKey:user_country_code];
        
        NSString *customId =[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"custom_id"]?[resposeCode  objectForKey:@"custom_id"]:@""];
        [Localytics setCustomerId:customId];
        [userpref setObject:customId?customId:@"" forKey:ownerCustId];
        [userpref setObject:customId?customId:@"" forKey:custId];
        
        NSString *u_email = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"email"]?[resposeCode  objectForKey:@"email"]:@""];
        [Localytics setCustomerEmail:u_email];
        [userpref setObject:u_email?u_email:@"" forKey:emailId1];
        
        NSString *u_fName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"first_name"]?[resposeCode  objectForKey:@"first_name"]:@""];
        [userpref setObject:u_fName?u_fName:@"" forKey:dc_firstName];
        
        NSString *JabberID = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"jabber_id"]?[resposeCode  objectForKey:@"jabber_id"]:@""];
        [userpref setObject:JabberID?JabberID:@"" forKey:jabberId];
        
        NSString *u_lName = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"last_name"]?[resposeCode  objectForKey:@"last_name"]:@""];
        [userpref setObject:u_lName?u_lName:@"" forKey:dc_lastName];
        
        NSString *userMobNo = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"mobile"]?[resposeCode  objectForKey:@"mobile"]:@""];
        [userpref setObject:userMobNo?userMobNo:@"" forKey:user_mobileNo];
        
        userPic = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"profile_pic_path"]?[resposeCode  objectForKey:@"profile_pic_path"]:@""];
        [userpref setObject:userPic?userPic:@"" forKey:profileImage];
        
        NSString *userRegNo = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"registration_no"]?[resposeCode  objectForKey:@"registration_no"]:@""];
        [userpref setObject: userRegNo?userRegNo:@"" forKey:UserRegNo];
        
        NSString *userState = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"state"]?[resposeCode  objectForKey:@"state"]:@""];
        [userpref setObject:userState?userState:@"" forKey:user_state];
        
        NSString *uId=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"user_id"]?[resposeCode  objectForKey:@"user_id"]:@""];
        [userpref setObject:uId?uId:@"" forKey:userId];
        
        NSString *refLink = [NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"referal_link"]?[resposeCode  objectForKey:@"referal_link"]:@""];
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
        //[userpref setBool:YES forKey:signInnormal];
        NSString *u_authkey=[NSString stringWithFormat:@"%@", [usrAuthkey objectForKey:@"auth_key"]?[usrAuthkey objectForKey:@"auth_key"]:@""];
        [userpref setObject:u_authkey?u_authkey:@"" forKey:userAuthKey];
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
     statusResponse = [[postDic valueForKey:@"status"]integerValue];
    if (statusResponse==1) {
        [self downloadWithNsurlconnection];
       // [[AppDelegate appDelegate] connect];
        [self getFriendListServiceCalling];
    }
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

#pragma mark - Pushing to views
-(void)pushToFeedVc{
    [Localytics tagEvent:@"Onboarding New User Validated"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setBool:YES forKey:signInnormal];
    [[AppDelegate appDelegate] navigateToTabBarScren:0];
}

@end
