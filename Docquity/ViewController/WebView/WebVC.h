/*============================================================================
 PROJECT: Docquity
 FILE:    WebVC.h
 AUTHOR: Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 10/13/16.
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

#import <UIKit/UIKit.h>
@interface UIApplication(Browser)
-(BOOL)openURL:(NSURL *)url forceOpenInSafari:(BOOL)forceOpenInSafari;
@end

@protocol BrowserViewDelegate <NSObject>
- (BOOL)openURL:(NSURL*)url;
@end

/*============================================================================
 Interface: WebVC
 =============================================================================*/
@interface WebVC : UIViewController<UIWebViewDelegate,UIScrollViewDelegate>{
    NSTimer *timer;
    BOOL isVisible;
    NSString *filePathUrl;
    BOOL isFileDownload;
}
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *LblTitle;
@property (strong, nonatomic) NSString *fullURL;
@property (strong, nonatomic) NSString *headerTitleText;
@property (strong, nonatomic) NSString *documentTitle;
@property (strong, nonatomic) NSString *associationid;
@property (strong, nonatomic) NSString *accerediation;
@property (strong, nonatomic) NSString *courseTitle;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic) BOOL isgetResult;
- (id)initWithUrls:(NSURL*)u;
@end
