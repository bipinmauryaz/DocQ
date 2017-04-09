/*============================================================================
 PROJECT: Docquity
 FILE:    textviewLinkDetectorViewController.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 07/03/16.
 =============================================================================*/


/*============================================================================
 IMPORT Framework
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

/*============================================================================
 MACRO
 =============================================================================*/
#define DQTY_URL    @"https://docquity.com"

/*============================================================================
 Interface:  textviewLinkDetectorViewController
 =============================================================================*/
@interface textviewLinkDetectorViewController : UIViewController
<UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *button;
    IBOutlet UITextView *textView;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UITextView *textView;

- (IBAction)openLinkInBrowser:(id)sender;

@end
