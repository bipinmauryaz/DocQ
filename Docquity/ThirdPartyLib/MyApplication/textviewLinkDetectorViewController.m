/*============================================================================
 PROJECT: Docquity
 FILE:    textviewLinkDetectorViewController.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 07/03/16.
 =============================================================================*/

#import "textviewLinkDetectorViewController.h"

@interface textviewLinkDetectorViewController ()

@end

@implementation textviewLinkDetectorViewController
@synthesize textView;
@synthesize button;
@synthesize webView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* theHtml = [NSString stringWithFormat:@"<html><body><a href=\"%@\">%@</a></body></html>", DQTY_URL, DQTY_URL];
    [webView loadHTMLString:theHtml baseURL:nil];
    
    [button setTitle:DQTY_URL forState:UIControlStateNormal];
    
    [textView setText:DQTY_URL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openLinkInBrowser:(id)sender
{
    NSURL *url = [NSURL URLWithString:DQTY_URL];
    BrowserViewController *bvc = [[BrowserViewController alloc] initWithUrls:url];
    [self.navigationController pushViewController:bvc animated:YES];
 }

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


@end
