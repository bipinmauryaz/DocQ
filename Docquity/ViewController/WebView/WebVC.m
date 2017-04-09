/*============================================================================
 PROJECT: Docquity
 FILE:    WebVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity on 10/13/16.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "WebVC.h"
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "Localytics.h"
#import "MailActivity.h"
#import "AppDelegate.h"
#import "SSCWhatsAppActivity.h"
#import "NSString+HTML.h"

/*============================================================================
 Interface: WebVC
 =============================================================================*/
@interface WebVC (){
    NSString *theTitle;
}
@end

@implementation UIApplication(Browser)

-(BOOL)openURL:(NSURL *)url forceOpenInSafari:(BOOL)forceOpenInSafari
{
    if(forceOpenInSafari)
    {
        // We're overriding our app trying to open this URL, so we'll let UIApplication federate this request back out
        //  through the normal channels. The return value states whether or not they were able to open the URL.
        return [self openURL:url];
    }
    
    // Otherwise, we'll see if it is a request that we should let our app open.
    
    BOOL couldWeOpenUrl = NO;
    NSString* scheme = [url.scheme lowercaseString];
    if([scheme compare:@"http"] == NSOrderedSame
       || [scheme compare:@"https"] == NSOrderedSame)
    {
        // TODO - Here you might also want to check for other conditions where you do not want your app opening URLs (e.g.
        //  Facebook authentication requests, OAUTH requests, etc)
        
        // TODO - Update the cast below with the name of your AppDelegate
        // Let's call the method you wrote on your AppDelegate to actually open the BrowserViewController
        couldWeOpenUrl = [(id<BrowserViewDelegate>)self.delegate openURL:url];
    }
    
    if(!couldWeOpenUrl)
    {
        return [self openURL:url];
    }
    else
    {
        return YES;
    }
}
@end

@implementation WebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    isFileDownload = false;
    //self.LblTitle.textColor = [UIColor whiteColor];
    self.LblTitle.font  = [UIFont systemFontOfSize:17];
    self.LblTitle.textAlignment = NSTextAlignmentCenter;
    [self.indicator startAnimating];
    [self.indicator setHidesWhenStopped:YES];
    NSString *theFileName = [[_documentTitle lastPathComponent] stringByDeletingPathExtension];
     if([theFileName isEqualToString:@""] || theFileName == nil){
        theFileName = self.fullURL;
    }
    
    self.LblTitle.text = theFileName;
    NSURL *url = [NSURL URLWithString:self.fullURL];
    if([AppDelegate appDelegate].isInternet){
        if (url && [url scheme] && [url host])
        {
            // NSLog(@"valid URL");
        }else {
            self.fullURL = [NSString stringWithFormat:ImageUrl@"%@",self.fullURL];
            url = [NSURL URLWithString:self.fullURL];
            // NSLog(@"not valid");
        }
    }
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    if(self.isgetResult)
    {
        self.shareBtn.hidden = false;
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
        [self downloadFile:[NSString stringWithFormat:@"%@",url]];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)GoToBack:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.progressView.progress = 0;
    isVisible = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    //theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //self.LblTitle.text = theTitle;
    isVisible = true;
    NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *name = [_documentTitle stringByDecodingHTMLEntities];
    NSString *type = [name pathExtension];
    name = [[_documentTitle lastPathComponent] stringByDeletingPathExtension];
    if([type isEqualToString:@"pdf"]){
        self.LblTitle.text = name;
        [self webzoom];
    }else if([type containsString:@"xls"]){
        self.LblTitle.text = name;
        [self webzoom];
        
    }else if([type containsString:@"ppt"]){
        self.LblTitle.text = name;
        [self webzoom];
        
    }else if([type containsString:@"doc"]){
        self.LblTitle.text = name;
        [self webzoom];
        
    }else if ([type isEqualToString:@"rtf"]){
        self.LblTitle.text = name;
        [self webzoom];
    }else if ([type isEqualToString:@"txt"]){
        self.LblTitle.text = name;
        [self webzoom];
    }
    else{
        self.LblTitle.text = pageTitle;
    }
    self.progressView.progress = 1.0;
}

-(void)webzoom{
    self.webView.scrollView.delegate = self; // set delegate method of UISrollView
    self.webView.scrollView.maximumZoomScale = 20; // set as you want.
    self.webView.scrollView.minimumZoomScale = 1; // set as you want.
    
    //// Below two line is for iOS 6, If your app only supported iOS 7 then no need to write this.
    self. webView.scrollView.zoomScale = 2;
    self.webView.scrollView.zoomScale = 1;
}

//#pragma mark - UIScrollView Delegate Methods
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    self.webView.scrollView.maximumZoomScale = 20; // set similar to previous.
//}

-(void)timerCallback {
    if (isVisible) {
        if (self.progressView.progress >= 1) {
            self.progressView.hidden = true;
            [timer invalidate];
        }
        else {
            self.progressView.progress += 0.1;
        }
    }
    else {
        self.progressView.progress += 0.02;
        if (self.progressView.progress >= 0.8)
        {
            if (self.progressView.progress >= 0.97)
            {
                self.progressView.progress = 0.97;
            }
            else
            {
                self.progressView.progress += 0.01;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Object lifecycle
- (id)initWithUrls:(NSURL*)u
{
    // self = [self initWithNibName:@"BrowserViewController" bundle:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    if(self)
    {
        self.webView.delegate = self;
        [self disablesAutomaticKeyboardDismissal];
        // [self.webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.tagName"];
        _fullURL = [NSString stringWithFormat:@"%@",u];
        
        // Hide tab bars / toolbars etc
        // self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.webView endEditing:YES];
}

//-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
//{
//    if ( self.presentedViewController)
//    {
//        [super dismissViewControllerAnimated:flag completion:completion];
//    }
//}

- (IBAction)didPressShare:(id)sender {
    if(isFileDownload){
        [self shareBtnclicked];
    }
}

-(void)sharePDF{
     [self callingGoogleAnalyticFunction:@"CME Certificate Screen" screenAction:@"Share Click"];
    [Localytics tagEvent:@"PDF result Share"];
    SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
    NSURL *urlToShare = [NSURL URLWithString:filePathUrl];
    NSString*sharecontent =  @"Attached is my CME certificate for the Course";
    NSString* bottomcontent = @"--Earn my cme point on Docquity.";
    NSString*finalsharecontent = [NSString stringWithFormat:@"%@ %@\n\n%@",sharecontent, self.courseTitle,bottomcontent];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[finalsharecontent,urlToShare] applicationActivities:@[whatsAppActivity]];
    
    [activityViewController setValue:@"CME Certificate Docquity" forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePostToVimeo,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToFacebook];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

-(void)downloadFile:(NSString *)fileURL {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:[fileURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                  NSString *documentsDirectory = [paths objectAtIndex:0];
                                                  
                                                  return [[NSURL fileURLWithPath:documentsDirectory] URLByAppendingPathComponent:[response suggestedFilename]];
                                                  
                                              } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                  //NSLog(@"File downloaded to: %@", filePath);
                                                  filePathUrl = [NSString stringWithFormat:@"%@",filePath];
                                                  isFileDownload = YES;
                                                  //  [self.btnSolve setTitle:@"SOLVE" forState:UIControlStateNormal];
                                                  //  self.btnSolve.backgroundColor = kCOAColor;
                                              }];
    [downloadTask resume];
}

-(void)shareBtnclicked{
    [self sharePDF];
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sharePDF];
     }]];
    if(![self.accerediation isEqualToString:@"Sample"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Post on Docquity" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setFeedToServerWithTitle:self.courseTitle content:postCertDocqMsg];
          }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];*/
}

#pragma mark - Feed API Calling
-(void)setFeedToServerWithTitle:(NSString*)feedTitle content:(NSString *)desc{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]setFeedPostWithTitle:feedTitle content:desc posted_by:[[NSUserDefaults standardUserDefaults]valueForKey:userId] user_type:@"user" feed_type:@"association" file_type:@"" file_url:@"" meta_url:@"" feed_type_id:self.associationid auth_key:[userpref valueForKey:userAuthKey] format:jsonformat feed_kind:@"post" video_image_url:@"" file_name:@"" file_description:@"" callback:^(NSMutableDictionary *responseObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        //NSLog(@"responseObject Feed set- %@",responseObject);
        if([responseObject isKindOfClass:[NSNull class]]){
            //Something went wrong alert
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
        }else{
            //successfull alert
            [self singleButtonAlertViewWithAlertTitle:@"CME" message:cmePostMsg buttonTitle:OK_STRING];
        }
    }];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
