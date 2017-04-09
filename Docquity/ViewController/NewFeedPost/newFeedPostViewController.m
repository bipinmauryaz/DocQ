/*============================================================================
 PROJECT: Docquity
 FILE:    newFeedPostViewController.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 22/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "newFeedPostViewController.h"
#import "UIViewController+KeyboardAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MobileCoreServices/MobileCoreServices.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AssociationPickerVC.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"
//#import "GMDCircleLoader.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+WebCache.h"
#import "AFURLSessionManager.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "ELCImagePickerController.h"
#import "HWViewPager.h"
#import "PagerCollectionViewCell.h"
#import "iImagePickerController.h"
#import "ImagePreviewViewController.h"
#import "HDMultiPartImageUpload.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "PermissionCheckYourSelfVC.h"
#import "DocquityServerEngine.h"
#import "SpecialityPickerVC.h"

#define  _WEAKREF(obj)         __weak typeof(obj)ref=obj;
#define  _STRONGREF(name)      __strong typeof(ref)name=ref;\
if(!name)return ;\

typedef enum{
    kTAG_imagePicked =9,
}ALLTAGS;

@interface newFeedPostViewController ()
{
    UIToolbar *toolBar;
    float _previousContentHeight;
    UIButton *imageFeed;
    UIButton *videoFeed;
    UIButton *fileFeed;
    BOOL isForcePostClick;
    BOOL setFeedCalled;
    NSString *imgUrls;
    NSInteger ImgUploadCount;
    NSString *feedkind;
    BOOL isNewImageAdd,isIndicatorRemove,isPostPress,isImageUnderProcess;
    NSMutableDictionary *FeedInformationCopy;
    NSString*permstus;
    NSArray* rawdataAr;
 }
@property (strong, nonatomic) IBOutlet UILabel *lblCases;
@property (strong, nonatomic) IBOutlet UIImageView *imgCases;
@property (strong, nonatomic) IBOutlet UILabel *lblTrend;
@property (strong, nonatomic) IBOutlet UIImageView *imgTrend;
@property (nonatomic, strong)NSMutableArray *choosenImagesArr;
@property (strong, nonatomic) IBOutlet UIButton *btnCases;
@property (nonatomic, strong)NSMutableArray *choosenImagesUrlArr;
@property (strong, nonatomic) IBOutlet UIButton *BtnTrend;
@end
@implementation newFeedPostViewController
@synthesize Scrollview,contentView;
@synthesize ContentTextView,postBtn,specialityTagTF;
@synthesize isTrends;
@synthesize metaDataWv;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor greenColor];
    isKeyboardAppear = false;
    isAttachment =false;
    isPDFAttachment = false;
    isVideo = false;
    isImage = false;
    isNewImageAdd = false;
    isUpdateImage = false;
    self.AttachmentView.hidden = YES;
    self.MetaDataView.hidden = YES;
    isForcePostClick = false;
    setFeedCalled = FALSE;
    isIndicatorRemove = false;
    isPostPress = false;
    isImageUnderProcess = false;
    // ContentTextView.backgroundColor = [UIColor lightGrayColor];
    //[self contentViewResize];
    //[self scrollResize];
    [self.Scrollview setBackgroundColor:[UIColor whiteColor]];
    FeedInformationCopy = [[NSMutableDictionary alloc]init];
    self.choosenImagesUrlArr = [[NSMutableArray alloc]init];
    FeedInformationCopy = self.FeedInformation.mutableCopy;
    self.choosenImagesArr = [[NSMutableArray alloc]init];
    specSelectedMainArray = [[NSMutableArray alloc]init];
    assoSelectedMainArray = [[NSMutableArray alloc]init];
    [self PostBtnActivate:NO];
    [self setupTextField:self.TitleTextField];
    [self getSpecialityRequestWithAuthkey];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    //UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
    blockurl =[[NSMutableArray alloc]init];
    
    if([[[AppDelegate appDelegate]myAssociationList]count]==1)
    {
        pickedAssoID = [[[[AppDelegate appDelegate]myAssociationList] objectAtIndex:0]valueForKey:@"association_id"];
        [self.ImgSelectedAsso sd_setImageWithURL:[NSURL URLWithString:[[[AppDelegate appDelegate]myAssociationList] objectAtIndex:0][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
        self.postTypeTF.text = [[[[AppDelegate appDelegate]myAssociationList]objectAtIndex:0]valueForKey:@"association_name"];
        // NSLog(@"Seelcted id: %@",pickedAssoID);
        self.BtnSelection.enabled = false;
    }
    
    else{
        if([[[AppDelegate appDelegate]myAssociationList]count]==0){
            if ([AppDelegate appDelegate].isComeFromTrending ==YES) {
                pickedAssoID = [[self.myNewfeedAssociationList objectAtIndex:0]valueForKey:@"association_id"];
                [self.ImgSelectedAsso sd_setImageWithURL:[NSURL URLWithString:[self.myNewfeedAssociationList objectAtIndex:0][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
                self.postTypeTF.text = [[self.myNewfeedAssociationList objectAtIndex:0]valueForKey:@"association_name"];
                // NSLog(@"Seelcted id: %@",pickedAssoID);
                self.BtnSelection.enabled = false;
 
            }
        }
    }
    
    [self setupToolBar];
    if (self.isEditFeed) {
        [self LoadFeedForEdit];
    }else{
        if (isTrends) {
            [self didPressTrends:self.BtnTrend];
        }
        else{
         [self didPressCases:self.btnCases];
        }
        [self.TitleTextField becomeFirstResponder];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self callingGoogleAnalyticFunction:@"Post Feed Screen" screenAction:@"Post Feed Visit"];
    [self registerNotification];
    [super viewWillAppear:animated];
}

-(void)focusTextview{
    [self.ContentTextView becomeFirstResponder];
}

#pragma mark - Setup TextField
-(void)setupTextField:(UITextField*)textfield{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, textfield.frame.size.height-1, textfield.frame.size.width, 1.0);
    bottomBorder.backgroundColor= [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
    [textfield.layer addSublayer:bottomBorder];
}

-(void)scrollResize{
    Scrollview.contentSize = CGSizeMake(Scrollview.frame.size.width, contentView.frame.size.height);
}

-(void)contentViewResize{
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size.height =ContentTextView.frame.size.height +ContentTextView.frame.origin.y+5;
    contentView.frame = contentViewFrame;
}

-(void)textviewResizer{
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size.height =Scrollview.frame.size.height;
    contentView.frame = contentViewFrame;
    
    CGRect textViewRect = ContentTextView.frame;
    textViewRect.size.height = contentViewFrame.size.height -textViewRect.origin.y;
    ContentTextView.frame = textViewRect;
}

- (void)subscribeToKeyboard {
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            if (!isKeyboardAppear) {
                CGRect toolBarFrame = toolBar.frame;
                toolBarFrame.origin.y = keyboardRect.origin.y - toolBarFrame.size.height;
                toolBar.frame = toolBarFrame;
                if(toolBar.hidden){
                    CGRect ScrollFrame = Scrollview.frame;
                    ScrollFrame.size.height = [UIScreen mainScreen].bounds.size.height- keyboardRect.size.height -ScrollFrame.origin.y;
                    Scrollview.frame = ScrollFrame;
                }else{
                    CGRect ScrollFrame = Scrollview.frame;
                    ScrollFrame.size.height = [UIScreen mainScreen].bounds.size.height- keyboardRect.size.height -toolBarFrame.size.height-ScrollFrame.origin.y;
                    Scrollview.frame = ScrollFrame;
                }
                isKeyboardAppear = YES;
            }
         }
        else {
            CGRect toolBarFrame = toolBar.frame;
            toolBarFrame.origin.y = keyboardRect.origin.y - toolBarFrame.size.height;
            toolBar.frame = toolBarFrame;
            
            CGRect ScrollFrame = Scrollview.frame;
            ScrollFrame.size.height =  [UIScreen mainScreen].bounds.size.height - toolBarFrame.size.height-64;
            Scrollview.frame = ScrollFrame;
            [self scrollResize];
            isKeyboardAppear = false;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - textfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = textField.text.length - range.length + string.length;
    if (length > 0){
        [self PostBtnActivate:YES];
    } else if(ContentTextView.text.length<=0){
        [self PostBtnActivate:NO];
    }
    return YES;
}

#pragma mark - textView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if(![textView hasText]){
        textView.text = @"";
        self.PlaceHolder.hidden= true;
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.PlaceHolder.hidden= true;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect newFrame = textView.frame;
    _previousContentHeight = textView.frame.size.height;
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), (newSize.height));
    textView.frame = newFrame;
    textView.scrollEnabled = false;
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size.height = textView.frame.origin.y + textView.frame.size.height+5;
    if(newFrame.size.height > contentView.frame.size.height - newFrame.origin.y){
        if (isAttachment) {
            contentViewFrame.size.height = contentViewFrame.size.height + newSize.height - _previousContentHeight;
        }else if(!self.MetaDataView.hidden){
            contentViewFrame.size.height = contentViewFrame.size.height + newSize.height - _previousContentHeight;
        }else if (isPDFAttachment){
            contentViewFrame.size.height = contentViewFrame.size.height + newSize.height - _previousContentHeight;
        }
        else{
            contentViewFrame.size.height = textView.frame.size.height + textView.frame.origin.y ;
        }
    }
    contentView.frame = contentViewFrame;
    //NSLog(@"content view size in text view change : %f",contentViewFrame.size.height);
    isAttachment?[self updateAttachmentView]:nil;
    isPDFAttachment?[self updatePDFView]:nil;
    metaViewAppeared?[self updateMetaView]:nil;
    [self scrollResize];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    ContentTextView.font = [UIFont systemFontOfSize:16.0];
    NSUInteger length = self.ContentTextView.text.length - range.length + text.length;
    if (length > 0) {
        [self PostBtnActivate:YES];
    } else if(self.TitleTextField.text.length <=0){
        [self PostBtnActivate:NO];
    }
    if (range.length == 0) {
    }
    //Meta view test by string
    NSArray *items = nil;
    //[[NSArray alloc]init];
    if([text isEqualToString:@" "])
    {
        // NSLog(@"value before space= %@",textView.text);
        items = nil;
        items = [textView.text componentsSeparatedByString:@" "];
        for (NSString *str in items) {
            // NSLog(@"str = %@",str);
            if ([self urlCheckingForAll:str]) {
                NSString*myurlStr;
                if (str && (str.length != 0)) {
                    NSRange rng = [str rangeOfString:@"http://"options:NSCaseInsensitiveSearch];
                    NSRange rng1 = [str rangeOfString:@"https://"options:NSCaseInsensitiveSearch];
                    myurlStr = str;
                    if (rng.location == NSNotFound && rng1.location == NSNotFound) {
                        myurlStr = [NSString stringWithFormat:@"http://%@" ,str];
                    }
                }
                if ([blockurl containsObject:[myurlStr lowercaseString]]) // YES
                {
                    // Do something
                }
                else{
                    if (!metaViewAppeared) {
                        // isAttachment?nil:[self setOGView];
                        //isAttachment?nil:[self serviceCalling2:ogUrl];
                        if(!isAttachment && !isPDFAttachment){
                            [self setOGView];
                            [self serviceCalling2:ogUrl];
                        }
                    }
                }
            }
        }
    }

    //Here we check if the replacement text is equal to the string we are currently holding in the paste board
    else if ([text isEqualToString:[UIPasteboard generalPasteboard].string]) {
        //// Set this class to be the delegate of the UITextView. Now when a user will paste a text in that textview, this delegate will be called.
        if (text && (text.length != 0)) {
            NSRange rng = [text rangeOfString:@"http://"options:NSCaseInsensitiveSearch];
            NSRange rng1 = [text rangeOfString:@"https://"options:NSCaseInsensitiveSearch];
            if (rng.location != NSNotFound || rng1.location != NSNotFound) {
                items = nil;
                items = [text componentsSeparatedByString:@""];
                for (NSString *str in items) {
                    // NSLog(@"str = %@",str);
                    if ([self urlCheckingForAll:str]) {
                        NSString*myurlStr;
                        if (str && (str.length != 0)) {
                            NSRange rng = [str rangeOfString:@"http://"options:NSCaseInsensitiveSearch];
                            NSRange rng1 = [str rangeOfString:@"https://"options:NSCaseInsensitiveSearch];
                            myurlStr = str;
                            if (rng.location == NSNotFound && rng1.location == NSNotFound) {
                                myurlStr = [NSString stringWithFormat:@"http://%@" ,str];
                            }
                        }
                        if ([blockurl containsObject:[myurlStr lowercaseString]]) // YES
                        {
                            // Do something
                        }
                        else{
                            if (!metaViewAppeared) {
                                // isAttachment?nil:[self setOGView];
                                // isAttachment?nil:[self serviceCalling2:ogUrl];
                                if(!isAttachment && !isPDFAttachment){
                                    [self setOGView];
                                    [self serviceCalling2:ogUrl];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    else if([text isEqualToString:@"\n"])
    {
        items = nil;
        items = [textView.text componentsSeparatedByString:@" "];
        for (NSString *str in items) {
            // NSLog(@"str = %@",str);
            if ([self urlCheckingForAll:str]) {
                if (!metaViewAppeared) {
                    // isAttachment?nil:[self setOGView];
                    // isAttachment?nil:[self serviceCalling2:ogUrl];
                    if(!isAttachment && !isPDFAttachment){
                        [self setOGView];
                        [self serviceCalling2:ogUrl];
                    }
                }
            }
        }
    }
    return YES;
}

#pragma mark - Validating URL
- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    candidate = [NSString stringWithFormat:@"http://%@" ,candidate];
    return [urlTest evaluateWithObject:candidate];
}

-(BOOL)urlCheckingForAll:(NSString*)text{
    BOOL Valid = false;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            //NSLog(@"found URL: %@", url);
            text = [url absoluteString];
        }
    }
    url = [NSURL URLWithString:text];
    if (url && url.scheme && url.host)
    {
        text = [url absoluteString];
        Valid = true;
        //the url looks ok, do something with it
        // NSLog(@"%@ is a valid URL", text);
        ogUrl = text;
    }
    return Valid;
}

#pragma mark - Setup Toolbar
-(void)setupToolBar{
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                          self.view.bounds.size.height - 40.0f,
                                                          self.view.bounds.size.width,
                                                          40.0f)];
    // toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolBar];
    UILabel *topBorder= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, toolBar.frame.size.width,0.5f)];
    topBorder.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:192.0/255.0 blue:199.0/255.0 alpha:1.0];
    [toolBar addSubview:topBorder];
    
    imageFeed = [UIButton buttonWithType:UIButtonTypeCustom];
    //  imageFeed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    imageFeed.frame = CGRectMake(20,
                                 0.0f,
                                 40.0f,
                                 40.0f);
    [imageFeed setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    imageFeed.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 16);
    [imageFeed addTarget:self action:@selector(didPressImagePick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:imageFeed];
    videoFeed= [UIButton buttonWithType:UIButtonTypeCustom];
    //  imageFeed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    videoFeed.frame = CGRectMake(imageFeed.frame.origin.x +imageFeed.frame.size.width + imageFeed.frame.origin.x,
                                 0.0f,
                                 40.0f,
                                 40.0f);
    [videoFeed setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
    videoFeed.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 16);
    [videoFeed addTarget:self action:@selector(didPressVideoPick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:videoFeed];

    fileFeed= [UIButton buttonWithType:UIButtonTypeCustom];
    //  imageFeed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    fileFeed.frame = CGRectMake(videoFeed.frame.origin.x + videoFeed.frame.size.width + imageFeed.frame.origin.x,
                                0.0f,
                                40.0f,
                                40.0f);
    [fileFeed setImage:[UIImage imageNamed:@"file-upload.png"] forState:UIControlStateNormal];
    fileFeed.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 16);
    [fileFeed addTarget:self action:@selector(didUploadDocument) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:fileFeed];
    [self subscribeToKeyboard];
}

#pragma mark - ToolBar Hide
-(void)hideToolbar:(BOOL)hide{
    //NSLog(@"hide toolbar %d",hide);
    toolBar.hidden = hide;
    CGRect ScrollFrame = Scrollview.frame;
    //                ScrollFrame.size.height = ScrollFrame.size.height - toolBarFrame.origin.y+64;
    //                ScrollFrame.size.height = [UIScreen mainScreen].bounds.size.height- toolBarFrame.origin.y - Scrollview.frame.origin.y;
    ScrollFrame.size.height = ScrollFrame.size.height + toolBar.frame.size.height;
    Scrollview.frame = ScrollFrame;
}

#pragma mark - Press Image Pick
-(void)didPressImagePick{
     [self callingGoogleAnalyticFunction:@"Post Feed Screen" screenAction:@"Click on pick image"];
    [Localytics tagEvent:@"Post Camera Icon Click"];
    [self.view endEditing:YES];
    // [self getPictureOrVideoFromLibrary];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera"otherButtonTitles:@"Photo gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

-(void)didPressVideoPick{
    [self callingGoogleAnalyticFunction:@"Post Feed Screen" screenAction:@"Click on pick Video"];
    [Localytics tagEvent:@"Post Video Icon Click"];
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera"otherButtonTitles:@"Video gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==1100) {
        switch (buttonIndex) {
            case 0:
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }
    else{
        switch (actionSheet.tag)
        {
            case 1:
                //NSLog(@"image pickrr");
                switch (buttonIndex)
            {
                case 0:
                {
#if TARGET_IPHONE_SIMULATOR
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Camera not available." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                    [alert show];
#elif TARGET_OS_IPHONE
                    
                    if (_isEditFeed) {
                        if (4 - (self.choosenImagesUrlArr.count+self.choosenImagesArr.count) >0)
                        {
                            [self getPictureFromCamera:4 - (self.choosenImagesUrlArr.count+self.choosenImagesArr.count)];
                        }else{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:@"Maximum 4 images can be attached to a post." preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }else{
                        if (4 - self.choosenImagesArr.count >0)
                        {
                            [self getPictureFromCamera:4 - self.choosenImagesArr.count];
                            //[self openCustomCamera:4 - self.choosenImagesArr.count];
                        }else{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:@"Maximum 4 images can be attached to a post." preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }
#endif
                }
                    break;
                case 1:
                {
                    // [self getPictureFromLibrary];
                    [self getELCPictureFromLibrary];
                }
                    break;
            }
                break;
                
            case 2:
                // NSLog(@"Video picker");
                switch (buttonIndex)
            {
                case 0:
                {
#if TARGET_IPHONE_SIMULATOR
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Camera not available." delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                    [alert show];
#elif TARGET_OS_IPHONE
                    [self RecordVideoButton];
#endif
                }
                    break;
                case 1:
                {
                    [self getVideoFromLibrary];
                }
                    break;
            }
                break;
            default:
                break;
        }
    }
}

- (void)getPictureFromLibrary {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.imagePickerController.delegate = self;
    self.imagePickerController.navigationBar.translucent = NO;
    self.imagePickerController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    self.imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
    self.imagePickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)getVideoFromLibrary {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    self.imagePickerController.delegate = self;
    self.imagePickerController.videoMaximumDuration = 3600.0f;//sec for sending video duration
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)getPictureFromCamera:(NSInteger )maximg {
    dispatch_async(dispatch_get_main_queue(), ^{
        maximumImageClick = maximg;
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.showsCameraControls = NO;
        
        UIView *vwOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 90, self.view.bounds.size.width, 90)];
        // [vwOverlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [vwOverlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
        // [self.view addSubview:vwOverlay];
        imagePickerController.cameraOverlayView = vwOverlay;
        
        UIView *vwCapture = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-30, 10, 65, 65)];
        [vwCapture setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [vwCapture.layer setBorderColor:[UIColor whiteColor].CGColor];
        [vwCapture.layer setBorderWidth:3.];
        [vwCapture.layer setCornerRadius:vwCapture.bounds.size.width/2];
        [vwOverlay addSubview:vwCapture];
        
        btnCapture = [[UIButton alloc] initWithFrame:CGRectInset(vwCapture.bounds, 5, 5)];
        [btnCapture setBackgroundColor:[UIColor whiteColor]];
        [btnCapture setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnCapture.layer setCornerRadius:btnCapture.bounds.size.width/2];
        [btnCapture addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [vwCapture addSubview:btnCapture];
        
        btnDone = [[UIButton alloc] initWithFrame:CGRectMake(vwOverlay.bounds.size.width - 60, (vwOverlay.bounds.size.height - 30)/2, 60, 30)];
        [btnDone setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [btnDone setTitle:@"Done" forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [vwOverlay addSubview:btnDone];
        self.imagePickerController = imagePickerController;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    });
}

- (void)takePhoto:(UIButton*)sender
{
    if (sender.titleLabel.text.integerValue==maximumImageClick) {
        NSString *title;
        if (maximumImageClick==1) {
            title = [NSString stringWithFormat:NSLocalizedString(@"Only %d photo", nil), maximumImageClick];
        }
        else{
            title = [NSString stringWithFormat:NSLocalizedString(@"Only %d photos", nil), maximumImageClick];
        }
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Maximum 4 images can be attached to a post.", nil), maximumImageClick];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }else{
        [self.imagePickerController takePicture];
    }
}

-(void)changeNumber:(UIButton*)sender{
    [sender setTitle:[NSString stringWithFormat:@"%d",[sender.titleLabel.text intValue] + 1] forState:UIControlStateNormal];
}

-(void)done:(id)sender{
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    // NSLog(@"choose arr img counr  = %lu, %@",(unsigned long)self.choosenImagesArr.count,self.choosenImagesArr);
    [self imagesPickingFinish:self.choosenImagesArr];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //  NSLog(@"didFinishPickingMediaWithInfo");
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeVideo] || [type isEqualToString:(NSString *)kUTTypeMovie])
    {
        //  NSLog(@"video chhosen");
        urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
        isVideo = YES;
        isImage = FALSE;
        //  NSLog(@"video url: %@",urlvideo);
        vidData = [NSData dataWithContentsOfURL:urlvideo];
        u_ImgType = @"video/mp4";
        //        chosenImage = [self thumbnailImageFromURL:urlvideo];
        chosenImage  = [self generateThumbImage:[NSString stringWithFormat:@"%@",urlvideo]];
        CGFloat  ratio =self.AttachmentView.frame.size.width/ chosenImage.size.width;
        
        UIImage *newImage = [UIImage imageWithCGImage:chosenImage.CGImage
                                                scale:1/ratio
                                          orientation:chosenImage.imageOrientation];
        chosenImage = [self drawImage:newImage withPlayImage:[UIImage imageNamed:@"play-icon.png"]];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        [arr addObject:chosenImage];
        [self addAttachmentInAttachmentview:arr];
        //   NSLog(@"Video recorded: %@", info);
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    }else{
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self.choosenImagesArr addObject:[image fixOrientation]];
        [self changeNumber:btnCapture];
    }
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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

-(NSString *)encodeImagetoBase64:(UIImage *)Image{
    NSData *imageData = UIImageJPEGRepresentation(Image, 0.01);
    u_ImgType = [self contentTypeForImageData:imageData];
    //NSLog(@"imageType= %@", u_ImgType);
    UIImage *image = [UIImage imageWithData:imageData];
    base64EncodedString = [imageData base64EncodedStringWithOptions:0];
    encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)base64EncodedString,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 ));
    NSLog(@"image= %@", image);
    return base64EncodedString;
}

#pragma mark - Attachment View Setup
-(void)addAttachmentInAttachmentview:(NSMutableArray*)pickedImage{
    self.pdfAttachmentView.hidden = true;
    int viewHeight = 0;
    for(UIImageView *imgV in  self.AttachmentView.subviews){
        if (imgV.tag == kTAG_imagePicked) {
            [imgV removeFromSuperview];
        }
    }
    for (int i=0; i<pickedImage.count; i++) {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, viewHeight, self.AttachmentView.frame.size.width, self.AttachmentView.frame.size.height)];
        UIImage *pickedImg = [pickedImage objectAtIndex:i];
        imageview.image = pickedImg;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.tag = kTAG_imagePicked;
        float  ratio =imageview.frame.size.width/ pickedImg.size.width;
        [self.AttachmentView addSubview: imageview];
        self.AttachmentView.hidden = false;
        imageview.userInteractionEnabled = YES;
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame = CGRectMake(imageview.frame.size.width-40, 5, 30, 30);
        cancel.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 16, 8);
        [cancel setImage:[UIImage imageNamed:@"cross_white.png"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(removeAttachedObject:) forControlEvents:UIControlEventTouchUpInside];
        cancel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        cancel.layer.shadowOpacity = 1.0;
        cancel.layer.shadowRadius = 4;
        cancel.layer.shadowOffset = CGSizeMake(1.0f, 3.0f);
        [imageview addSubview:cancel];
        isAttachment = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapRecognizer addTarget:self action:@selector(videoButtonClicked)];
        [imageview addGestureRecognizer:tapRecognizer];
        
        CGRect frame = imageview.frame;
        // frame.origin.y = 0;
        frame.origin.y = viewHeight;
        frame.size.height =pickedImg.size.height*ratio;
        imageview.frame= frame;
        viewHeight = frame.size.height +10;
        frame = self.AttachmentView.frame;
        frame.size.height = imageview.frame.origin.y + imageview.frame.size.height;
        self.AttachmentView.frame = frame;
        [self updateAttachmentView];
    }
}

-(void)addAttachmentInAttachment{
    //CGRect frame = self.AttachmentView.frame;
    self.pdfAttachmentView.hidden = true;
    self.AttachmentView.hidden = false;
    self.AttachmentView.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    self.AttachmentView.layer.borderWidth = 1.0f;
    // self.AttachmentView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    self.viewPager.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:247.0/255.0 blue:249.0/255.0 alpha:1.0];
    if (self.choosenImagesArr.count==1) {
        //  NSLog(@"cellForItemAtIndexPath  arr =1");
        UICollectionViewFlowLayout *flow =(UICollectionViewFlowLayout*) self.viewPager.collectionViewLayout;
        flow.sectionInset = UIEdgeInsetsMake(0 ,10, 0, 10);
    }
    else {
        //  NSLog(@"cellForItemAtIndexPath  arr >=1");
        UICollectionViewFlowLayout *flow =(UICollectionViewFlowLayout*) self.viewPager.collectionViewLayout;
        flow.sectionInset = UIEdgeInsetsMake(0 ,20, 0, 20);
    }
    [self.viewPager reloadData];
    [self updateAttachmentView];
}

#pragma mark - Document Attachment View Setup
-(void)addDocumentInAttachmentview:(UIImage*)pickedImage PdfName:(NSString *)name documentType:(NSString *)type{
    self.pdfAttachmentView.hidden = false;
    self.AttachmentView.hidden = true;
    self.imgThumbnailpdf.image = pickedImage;
    self.imgThumbnailpdf.contentMode = UIViewContentModeScaleAspectFill;
    self.imgThumbnailpdf.clipsToBounds = YES;
    self.imgThumbnailpdf.tag = kTAG_imagePicked;
    self.pdf_nameViewholder.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
    self.btn_cancel_pdf.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.btn_cancel_pdf.layer.shadowOpacity = 1.0;
    self.btn_cancel_pdf.layer.shadowRadius = 4;
    self.btn_cancel_pdf.layer.shadowOffset = CGSizeMake(1.0f, 3.0f);
    if(self.isEditFeed && [[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"document"]){
        self.btn_cancel_pdf.enabled = false;
        self.btn_cancel_pdf.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.2];
    }
    isPDFAttachment = YES;
    isAttachment = NO;
    name = [name stringByReplacingOccurrencesOfString:type withString:@""];
    name = [name substringToIndex:name.length-(name.length>0)];
    self.lbl_File_name.text = name;
    if([type isEqualToString:@"pdf"]){
        self.img_document_type.image = [UIImage imageNamed:@"pdf.png"];
    }else if([type containsString:@"xls"]){
        self.img_document_type.image = [UIImage imageNamed:@"xls.png"];
    }else if([type containsString:@"ppt"]){
        self.img_document_type.image = [UIImage imageNamed:@"ppt.png"];
    }else if([type containsString:@"doc"]){
        self.img_document_type.image = [UIImage imageNamed:@"doc.png"];
    }else if ([type isEqualToString:@"rtf"]){
        self.img_document_type.image = [UIImage imageNamed:@"rtf.png"];
    }else if ([type isEqualToString:@"txt"]){
        self.img_document_type.image = [UIImage imageNamed:@"txt.png"];
    }
    self.pdfAttachmentView.layer.cornerRadius = 8.0;
    self.pdf_nameViewholder.layer.cornerRadius = 8.0;
    self.btn_cancel_pdf.layer.cornerRadius = 8.0;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imgThumbnailpdf.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.imgThumbnailpdf.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shapelayer as the mask for the image view's layer
    self.imgThumbnailpdf.layer.mask = maskLayer;
    [self hideToolbar:YES];
    [self updatePDFView];
}

#pragma mark - ColelctionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Collection view cell for row at index path item = %ld",(long)indexPath.item);
    PagerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FullCollectionCell" forIndexPath:indexPath];
    if (self.isEditFeed) {
        if (indexPath.item >= self.choosenImagesUrlArr.count) {
            cell.ImageShow.image =[self.choosenImagesArr objectAtIndex:indexPath.item - self.choosenImagesUrlArr.count];
        }else{
            //   NSString *imgURl = [NSString stringWithFormat:ImageUrl@"%@",[[self.choosenImagesUrlArr objectAtIndex:indexPath.item]valueForKey:@"multiple_file_url"]];
            NSString *imgURl = [NSString stringWithFormat:@"%@",[self.choosenImagesUrlArr objectAtIndex:indexPath.item]];
            //       NSLog(@"imgURl is %@",imgURl);
            //            [cell.ImageShow sd_setImageWithURL:[NSURL URLWithString:imgURl] placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            [cell.ImageShow  sd_setImageWithURL:[NSURL URLWithString:imgURl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]
                                        options:SDWebImageRefreshCached];
        }
    }else
        cell.ImageShow.image =[self.choosenImagesArr objectAtIndex:indexPath.item];
    // cell.ImageShow.image =[self.choosenImagesArr objectAtIndex:indexPath.item - self.choosenImagesUrlArr.count];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    cell.ImageShow.contentMode = UIViewContentModeScaleAspectFill;
    // cell.ImageShow.clipsToBounds = YES;
    cell.ImageShow.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(PickedImageTap:)];
    [cell addGestureRecognizer:tapRecognizer];
     if (_isEditFeed) {
        cell.photoCount.text = [NSString stringWithFormat:@"%ld of %lu",(unsigned long)indexPath.item+1,(unsigned long)self.choosenImagesUrlArr.count+self.choosenImagesArr.count];
    }else{
        cell.photoCount.text = [NSString stringWithFormat:@"%ld of %lu",(unsigned long)indexPath.item+1,(unsigned long)self.choosenImagesArr.count];
    }
    cell.photoCount.layer.cornerRadius = 9.0;
    cell.photoCount.layer.masksToBounds = YES;
    cell.photoCount.numberOfLines = 1;
    cell.photoCount.adjustsFontSizeToFitWidth = YES;
    cell.photoCount.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    cell.BtnCancel.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 8, 5);
    [cell.BtnCancel setImage:[UIImage imageNamed:@"cross_white.png"] forState:UIControlStateNormal];
    [cell.BtnCancel addTarget:self action:@selector(removeItems:) forControlEvents:UIControlEventTouchUpInside];
    cell.BtnCancel.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.BtnCancel.layer.shadowOpacity = 1.0;
    cell.BtnCancel.layer.shadowRadius = 5;
    cell.BtnCancel.layer.shadowOffset = CGSizeMake(2.0f, 3.0f);
    //    if(!isIndicatorRemove){
    //        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
    //                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //        activityView.center=cell.center;
    //        activityView.tag = indexPath.item+1;
    //        [activityView startAnimating];
    //        [cell addSubview:activityView];
    //    }
     return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //NSLog(@"Collection view numberOfItemsInSection");
    if (_isEditFeed) {
        if(isImageUnderProcess){
            [[AppDelegate appDelegate]alerMassegeWithError:@"Image is being processed, Please wait" withButtonTitle:OK_STRING autoDismissFlag:YES];
            return 0;
        }
        return self.choosenImagesUrlArr.count + self.choosenImagesArr.count;
    }else{
        return self.choosenImagesArr.count;
    }
}

-(void)removeItems:(UIButton*)sender{
    if(isImageUnderProcess){
        [[AppDelegate appDelegate]alerMassegeWithError:@"Image is being processed, Please wait" withButtonTitle:OK_STRING autoDismissFlag:YES];
        return;
    }
    //    }else if(self.choosenImagesUrlArr.count < self.choosenImagesArr.count){
    //        [[AppDelegate appDelegate]alerMassegeWithError:@"Image is being process Please wait" withButtonTitle:@"Please Wait" autoDismissFlag:YES];
    //        return;
    //    }
    NSIndexPath *indexPath = nil;
    indexPath = [self.viewPager indexPathForItemAtPoint:[self.viewPager convertPoint:sender.center fromView:sender.superview]];
    if (_isEditFeed) {
        
        //        if (indexPath.item>=self.choosenImagesUrlArr.count) {
        //            [self.choosenImagesArr removeObjectAtIndex:indexPath.item-self.choosenImagesUrlArr.count];
        //            [self.viewPager reloadData];
        //        }else{
        //            [self.choosenImagesUrlArr removeObjectAtIndex:indexPath.item];
        //            [self.viewPager reloadData];
        //        }
        
        [self.choosenImagesUrlArr removeObjectAtIndex:indexPath.item];
        [self.choosenImagesArr removeAllObjects];
        [self.viewPager reloadData];
         if (self.choosenImagesUrlArr.count==0 && self.choosenImagesArr.count==0) {
            self.AttachmentView.hidden = true;
            isImage = FALSE;
            isAttachment = FALSE;
            CGRect frame = self.ContentTextView.frame;
            frame.size.height = self.ContentTextView.contentSize.height;
            self.ContentTextView.frame = frame;
            // CGRect frame = self.ContentTextView.frame;
            [self updateContentView:frame];
        }
    }else
    {
        [self.choosenImagesArr removeObjectAtIndex:indexPath.item];
        [self.choosenImagesUrlArr removeObjectAtIndex:indexPath.item];
        [self.viewPager reloadData];
        if (self.choosenImagesArr.count==0) {
            self.AttachmentView.hidden = true;
            isImage = FALSE;
            isAttachment = FALSE;
            [self updateAttachmentView];
        }
    }
}

-(void)addMetaInAttachmentview{
    CGRect frame = self.metaDataWv.frame;
    CGRect attframe = self.AttachmentView.frame;
    attframe.size.height = frame.size.height + frame.origin.y*2;
    self.AttachmentView.frame = attframe;
    self.AttachmentView.hidden = false;
    [self updateAttachmentView];
}

-(void)removeAttachedObject:(UIButton*)sender{
    //  NSLog(@"Remove attachment calling");
    isUpdateImage =YES;
    UIImageView *imgView = (UIImageView*)[sender superview];
    [imgView removeFromSuperview];
    self.AttachmentView.hidden = YES;
    self.AttachmentView.backgroundColor = [UIColor whiteColor];
    [self updateAttachmentView];
    isAttachment = false;
    isVideo = false;
}

-(void)removeAttachedMetaObject{
    //NSLog(@"Remove attachment Meta calling");
    // self.imgMeta.image = nil;
    self.LblMetaDesc.text = @"";
    self.LblMetaTitle.text = @"";
    self.LblMetaUrl.text = @"";
    self.imgMeta.image = nil;
    self.MetaDataView.frame = CGRectMake(8.0, 172.0, [UIScreen mainScreen].bounds.size.width-16, 70);
    self.imgMeta.frame =CGRectMake(6.0, 6, 58, 58);
    self.LblMetaTitle.frame =CGRectMake(70.0, 6.0, self.MetaDataView.frame.size.width-74.0, 16);
    self.LblMetaDesc.frame =CGRectMake(70.0, 24.0, self.MetaDataView.frame.size.width-74, 16);
    self.LblMetaUrl.frame =CGRectMake(70.0, 42.0, self.MetaDataView.frame.size.width-74, 16);
    CGRect frame = self.ContentTextView.frame;
    metaViewAppeared = false;
    [self hideToolbar:NO];
    [self updateContentView:frame];
}

- (IBAction)removePDFView:(id)sender {
    [self showDeletePDFViewWithActionTitle:@"Remove Document"];
}

-(void)showDeletePDFViewWithActionTitle:(NSString *)aTitle{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:aTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.pdfAttachmentView.hidden = YES;
        self.imgThumbnailpdf.image = nil;
        self.img_document_type.image = nil;
        self.lbl_File_name.text = @"";
        [self hideToolbar:NO];
        isPDFAttachment = NO;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)updateAttachmentView{
    CGRect frame = self.AttachmentView.frame;
    frame.origin.y = ContentTextView.frame.size.height + ContentTextView.frame.origin.y+5;
    self.AttachmentView.frame = frame;
    if (self.AttachmentView.hidden) {
        frame.size.height = 0;
    }
    [self updateContentView:frame];
}

-(void)updateMetaView{
    CGRect frame = self.MetaDataView.frame;
    frame.origin.y = ContentTextView.frame.size.height + ContentTextView.frame.origin.y+5;
    self.MetaDataView.frame = frame;
    [self updateContentView:frame];
}

-(void)updatePDFView{
    CGRect frame = self.pdfAttachmentView.frame;
    frame.origin.y = ContentTextView.frame.size.height + ContentTextView.frame.origin.y+5;
    self.pdfAttachmentView.frame = frame;
    [self updateContentView:frame];
}

-(void)updateContentView:(CGRect)frame{
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = frame.size.height + frame.origin.y+5;
    self.contentView.frame = contentFrame;
    [self scrollResize];
}

#pragma mark - Go To Back View
- (IBAction)didPressCancel:(id)sender {
    [Localytics tagEvent:@"Post Cancel Click"];
    //[self doneEditing:nil];
    [self.view endEditing:YES];
    if (isAttachment ==YES) {
        [self endEditing];
        [self.Scrollview endEditing:YES];
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Do you want to discard changes? If you go back now, your draft will be discarded."
                                      delegate:self
                                      cancelButtonTitle:@"KEEP"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"DISCARD",
                                      nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        actionSheet.tag = 1100;
        [actionSheet showInView:self.view];
        return;
    }
    
    if (([self.ContentTextView.text length]!= 0) || ([self.TitleTextField.text length] != 0)) {
        [self endEditing];
        [self.Scrollview endEditing:YES];
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Do you want to discard changes? If you go back now, your draft will be discarded."
                                        delegate:self
                                      cancelButtonTitle:@"KEEP"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"DISCARD",
                                      nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        actionSheet.tag = 1100;
        [actionSheet showInView:self.view];
        return;
    }
    else {
        [self endEditing];
        [self.Scrollview endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - End Editing
- (void)endEditing
{
    if (([self.ContentTextView.text length]!= 0) || ([self.TitleTextField.text length] != 0)) {
        [self PostBtnActivate:YES];
    }
    else
    {
        if (([self.postTypeTF.text length]!= 0))
        {
            [self PostBtnActivate:YES];
        }
    }
    [self.view endEditing:YES];
}

#pragma mark - Post Btn Activate
-(void)PostBtnActivate:(BOOL)Active{
    if (Active) {
        postBtn.enabled = true;
        [postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        postBtn.enabled = false;
        [postBtn setTitleColor:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    }
}

#pragma  mark - Association Picking
- (IBAction)didPressPickAssociationBtn:(id)sender {
    [Localytics tagEvent:@"Select Association Click"];
    //NSLog(@"didPressPickAssociationBtn");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AssociationPickerVC *assoPVC = [storyboard instantiateViewControllerWithIdentifier:@"AssociationPickerVC"];
    assoPVC.delegate = self;
    assoPVC.associationListArr  = assoSelectedMainArray;
    assoPVC.array = associationArr.mutableCopy;
    [self presentViewController:assoPVC animated:NO completion:nil];
}

#pragma  mark - SpecialityTag Picking
- (IBAction)didPressPickSpecialityBtn:(id)sender {
    [self callingGoogleAnalyticFunction:@"Post Feed Screen" screenAction:@"Click to Select TAG"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SpecialityPickerVC *specVC = [storyboard instantiateViewControllerWithIdentifier:@"SpecialityPickerVC"];
    specVC.delegate = self;
    specVC.specialityListArr  = specSelectedMainArray;
    specVC.array = specialityArr.mutableCopy;
    [self presentViewController:specVC animated:NO completion:nil];
}

//-(void)selectedAssociationName:(NSString*)Name AssoID:(NSString*)assoid assoimage:(UIImage *)assoImage{
//    //NSLog(@"selectedAssociation Name: %@",Name);
//    // NSLog(@"selectedAssociation ID: %@",assoid);
//    self.ImgSelectedAsso.image = assoImage;
//    self.postTypeTF.text = Name;
//    pickedAssoID = [NSString stringWithFormat:@"%@",assoid];
//    [self.TitleTextField becomeFirstResponder];
//}

-(void)selectedAssociationName:(NSMutableArray*)Name AssoID:(NSMutableArray*)associationId associationArray:(NSMutableArray*)associationMainArr{
    // NSLog(@"selectedSpeciality Name: %@",Name);
    //  NSLog(@"selectedSpeciality ID: %@",specialityId);
    NSString * myassociation = [[Name valueForKey:@"description"] componentsJoinedByString:@", "];
    // NSLog(@"Speciality Name: %@",myspeciality);
    
    NSString * myassociationId = [[associationId valueForKey:@"description"] componentsJoinedByString:@"|"];
    //pickedAssoID =  associationId.mutableCopy;
    
    pickedAssoID =[NSString stringWithFormat:@"%@",myassociationId];

    // NSLog(@"Speciality ID: %@",Arr_specialityId);
    
    //  self.ImgSelectedAsso.image = assoImage;
    self.postTypeTF.text  =  [myassociation stringByDecodingHTMLEntities];
    // pickedSpecialityID = [NSString stringWithFormat:@"%@",specialityId];
    // [self.TitleTextField becomeFirstResponder];
    
    assoSelectedMainArray = associationMainArr;
}

-(void)selectedSpecialityName:(NSMutableArray*)Name specialityID:(NSMutableArray*)specialityId spacialityArray:(NSMutableArray*)specMainArr{
   // NSLog(@"selectedSpeciality Name: %@",Name);
   //  NSLog(@"selectedSpeciality ID: %@",specialityId);
    NSString * myspeciality = [[Name valueForKey:@"description"] componentsJoinedByString:@", "];
   // NSLog(@"Speciality Name: %@",myspeciality);
    Arr_specialityId =  specialityId.mutableCopy;
     // NSLog(@"Speciality ID: %@",Arr_specialityId);
    
  //  self.ImgSelectedAsso.image = assoImage;
    self.specialityTagTF.text =  [myspeciality stringByDecodingHTMLEntities];
   // pickedSpecialityID = [NSString stringWithFormat:@"%@",specialityId];
   // [self.TitleTextField becomeFirstResponder];
    specSelectedMainArray = specMainArr;
}

-(IBAction)metaCancelBtnAction:(id)sender
{
    //NSLog(@"metaCancelBtnAction");
    [self.AttachmentView removeFromSuperview];
    [self hideToolbar:NO];
    metaViewAppeared = NO;
}

- (void)PickedImageTap:(UITapGestureRecognizer*)sender {
    PagerCollectionViewCell *cell = (PagerCollectionViewCell *)sender.view;
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    UIImageView *imgv =cell.ImageShow;
    imageInfo.image = imgv.image;
    imageInfo.referenceRect = imgv.frame;
    imageInfo.referenceView = imgv.superview;
    imageInfo.referenceContentMode = imgv.contentMode;
    imageInfo.referenceCornerRadius = imgv.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIImageView class]]) {
        return NO;
    }else if(touch.view == self.contentView){
        [self focusTextview];
        return YES;
    }else{
        return ! ([touch.view isKindOfClass:[UIControl class]]);
    }
    //    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark - Generate Video Thumbnail
-(UIImage *)generateThumbImage : (NSString *)filepath
{
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:filepath]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    //thumbnail = [self drawImage:thumbnail withPlayImage:[UIImage imageNamed:@"play-icon.png"]];
    isVideo = YES;
    return thumbnail;
}

-(UIImage *)drawImage:(UIImage*)thumbnail withPlayImage:(UIImage *)playerImage
{
    UIGraphicsBeginImageContextWithOptions(thumbnail.size, NO, 0.0f);
    [thumbnail drawInRect:CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height)];
    [playerImage drawInRect:CGRectMake((thumbnail.size.width-50)/2, (thumbnail.size.height-50)/2, 50, 50)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

#pragma mark - Upload Video
-(void)uploadVideoOnServer{
    isImageUnderProcess = YES;
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSMutableDictionary *dataDic;
    base64EncodedString = [vidData base64EncodedStringWithOptions:0];
    [userpref setObject:base64EncodedString forKey:base64Str1];
    //set user profile Updation
    dataDic =[[NSMutableDictionary alloc]initWithObjectsAndKeys:u_ImgType?u_ImgType:@"",Image1,base64EncodedString?base64EncodedString:@"",base64Str1, nil];
    
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

#pragma mark - Post Button Clicked
-(IBAction)didPressPostBtn:(id)sender{
    [self callingGoogleAnalyticFunction:@"Post Feed Screen" screenAction:@"Post Feed Click"];
    [self.view endEditing:YES];
    isPostPress = YES;
    [Localytics tagEvent:@"Post Feed To Click"];
    [[AppDelegate appDelegate] getPlaySound];
    if (!self.isEditFeed)
    {
        [Localytics tagEvent:@"Feed submit."];
        NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
        [userpref setObject:self.TitleTextField.text forKey:feedPostTitle];
        [userpref setObject:self.ContentTextView.text forKey:feedPostContent];
        if ([self.postTypeTF.text length] == 0){
            [UIAppDelegate alerMassegeWithError:@"Please select association." withButtonTitle:OK_STRING autoDismissFlag:NO];
            [self PostBtnActivate:YES];
            return;
        }
         else if ([self.TitleTextField.text length] == 0){
            [UIAppDelegate alerMassegeWithError:@"Please fill out post title." withButtonTitle:OK_STRING autoDismissFlag:NO];
             [self PostBtnActivate:YES];
            return;
         }
        else if([NSString trim:self.TitleTextField.text].length == 0) {
                [UIAppDelegate alerMassegeWithError:@"Please fill out post title." withButtonTitle:OK_STRING autoDismissFlag:NO];
                [self PostBtnActivate:YES];
                return;
        }
       else if ([AppDelegate appDelegate].isCases_Feed == YES){
           if ([self.specialityTagTF.text length] == 0 || [NSString trim:self.specialityTagTF.text].length == 0){
            [UIAppDelegate alerMassegeWithError:@"Please tag your cases." withButtonTitle:OK_STRING autoDismissFlag:NO];
            [self PostBtnActivate:YES];
            return;
        }
        }
        [[AppDelegate appDelegate] showIndicator];
        [self PostBtnActivate:NO];
        if ([AppDelegate appDelegate].isMetaData ==YES) {
            if ([metaContent isEqualToString:@""]) {
                 UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:@"" message:@"We are generating URL Preview.\nWould you like to:" delegate:self cancelButtonTitle:@"WAIT" otherButtonTitles:@"POST", nil];
                confAl.tag = 888;
                [confAl show];
            }
            else {
            [self serviceCalling];
            }
        }
        else{
        [self serviceCalling];
        }
    }
    else
    {
        [self SetEditFeed];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==888) {
        if(buttonIndex==1)
        {
            [Localytics tagEvent:@"PostMeta Post Click"];
            isForcePostClick = YES;
            fileType = @"link";
            [self serviceCalling];
        }
        else{
            [Localytics tagEvent:@"PostMeta Wait Click"];
            [self PostBtnActivate:YES];
        }
    }
}

#pragma webservices methods
- (void) serviceCalling
{
    [self PostBtnActivate:NO];
    // NSLog(@"serviceCalling");
    if (!self.isEditFeed) {
        if (isAttachment)
        {
            if (isVideo)
            {
                [self uploadThumbnail];
                // [self uploadVideoToServer];
            }
            else if(isImage)
            {
                // [self uploadImagesToServer];
                if(self.choosenImagesUrlArr.count == self.choosenImagesArr.count){
                    NSString *content = [self.ContentTextView.attributedText string];
                    [self setFeedToServerWithContent:content];
                }
            }
        }else if(isPDFAttachment){
            [self uploadThumbnail];
        }
        else if ([self.ContentTextView.text length] == 0 || [NSString trim:self.ContentTextView.text].length == 0)
        {
            [UIAppDelegate alerMassegeWithError:@"Please fill out post content." withButtonTitle:OK_STRING autoDismissFlag:NO];
            [self PostBtnActivate:YES];
            [[AppDelegate appDelegate]hideIndicator];
            return;
        }
        else{
            // NSLog(@"image not available, content is %@",self.ContentTextView.text);
            [self setFeedToServerWithContent:self.ContentTextView.text];
            //[[AppDelegate appDelegate] showIndicator];
        }
    }
}

//IF post button click in edit mode
/*
 check here for title or content if title null the popup message, if content null but image is attached, then go otherwise content null
  */

#pragma mark- webservices methods
-(void)SetEditFeed{
    imgUrls = @"";
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [userpref setObject:self.TitleTextField.text forKey:feedPostTitle];
    [userpref setObject:self.ContentTextView.text forKey:feedPostContent];
    // [userpref setObject:metaContent?metaContent:@"" forKey:feedFileURL];
    // metaContent = [userpref objectForKey:feedFileURL];
    [userpref setObject:[self.FeedInformation valueForKey:@"feed_id"] forKey:feedID];
    [userpref setObject:[self.FeedInformation valueForKey:@"posted_by"] forKey:userId];
    if ([self.postTypeTF.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please select association." withButtonTitle:OK_STRING autoDismissFlag:NO];
        [self PostBtnActivate:YES];
        return;
    }
    else if ([self.TitleTextField.text length] == 0 || [NSString trim:self.TitleTextField.text].length == 0){
        [UIAppDelegate alerMassegeWithError:@"Please fill out post title." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    else if ([AppDelegate appDelegate].isCases_Feed == YES){
        if ([self.specialityTagTF.text length] == 0 || [NSString trim:self.specialityTagTF.text].length == 0){
            [UIAppDelegate alerMassegeWithError:@"Please tag your cases." withButtonTitle:OK_STRING autoDismissFlag:NO];
            [self PostBtnActivate:YES];
            return;
        }
    }
    if (isAttachment)
    {
        [[AppDelegate appDelegate] showIndicator];
        if (isVideo)
        {
            [self uploadThumbnail];
        }
        else if(isImage)
        {
            if(isImageUnderProcess){
                return;
            }
            isVideo = false;
            fileType = @"image";
            for (int i=0; i<self.choosenImagesUrlArr.count; i++) {
                if (![imgUrls isEqualToString:@""]) {
                    imgUrls = [NSString stringWithFormat:@"%@|%@",imgUrls,[self.choosenImagesUrlArr objectAtIndex:i]];
                }else{
                    imgUrls = [self.choosenImagesUrlArr objectAtIndex:i];
                }
            }
            [self setFeedToServerWithContent:self.ContentTextView.text];
        }
    }else if(isPDFAttachment && [[self.FeedInformation valueForKey:@"file_type"] isEqualToString:@"document"]){
        [[AppDelegate appDelegate] showIndicator];
        [self setFeedToServerWithContent:self.ContentTextView.text];
    }
    else if(isPDFAttachment){
        [self uploadThumbnail];
    }
    else if (metaViewAppeared){
        [[AppDelegate appDelegate] showIndicator];
        [self setFeedToServerWithContent:self.ContentTextView.text];
    }
    else if ([self.ContentTextView.text length] == 0 || [NSString trim:self.ContentTextView.text].length == 0)
    {
        if (isVideo) {
            [[AppDelegate appDelegate] showIndicator];
            // NSLog(@"image not available, content is %@",self.ContentTextView.text);
            [self setFeedToServerWithContent:self.ContentTextView.text];
        }
        else{
            [UIAppDelegate alerMassegeWithError:@"Please fill out post content." withButtonTitle:OK_STRING autoDismissFlag:NO];
            [self PostBtnActivate:YES];
            return;
        }
    }
    else
    {
        [[AppDelegate appDelegate] showIndicator];
        // NSLog(@"image not available, content is %@",self.ContentTextView.text);
        [self setFeedToServerWithContent:self.ContentTextView.text];
        //[[AppDelegate appDelegate] showIndicator];
    }
}

#pragma mark - Feed API Calling
-(void)setFeedToServerWithContent:(NSString*)feedContent{
    //NSLog(@"setFeedToServerWithContent");
    //    [[AppDelegate appDelegate]showIndicator];
    [self PostBtnActivate:NO];
    feedContent = [feedContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *feedTitle = [NSString trim:self.TitleTextField.text];
   // NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
   // NSDictionary *aDic = [[NSDictionary alloc]init];
    if (self.isEditFeed) {
        /*
        NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
        [self setEditFeedPostRequestWithAuthkey: [userPref valueForKey:feedID] post_type:self.postTypeTF.text feed_title:feedTitle feed_content:feedContent file_type:fileType file_url:fileUrl association_id:pickedAssoID feed_kind:feedkind meta_url:ogUrl video_image_url:imgUrls];
         */
       // aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetEditPostFeedRequest], keyRequestType1, nil];
        
        if(![[self.FeedInformation valueForKey:@"meta_url"]isEqualToString:@""])
            ogUrl =[self.FeedInformation valueForKey:@"meta_url"];

        if([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"video"]){
            imgUrls = [self.FeedInformation valueForKey:@"video_image_url"];
            fileUrl = [self.FeedInformation valueForKey:@"file_url"];
        }
        if([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"document"]){
            imgUrls = [self.FeedInformation valueForKey:@"video_image_url"];
            fileUrl = [self.FeedInformation valueForKey:@"file_url"];
        }
    }
    else{
      }
    if ([AppDelegate appDelegate].isMetaData ==YES) {
        fileType = @"link";
       // [userpref setObject:fileType?fileType:@"" forKey:feedFileTyp];
        metaContent = [metaContent stringByDecodingHTMLEntities];
       // [userpref setObject:metaContent?metaContent:@"" forKey:feedFileURL];
        //   [userpref setObject:ogUrl?ogUrl:@"" forKey:metaDataURL];
        if ([feedContent.lowercaseString containsString:[NSString stringWithFormat:@"%@",ogUrl]]) {
           // NSLog(@"mesg: %@",feedContent);
            
            feedContent =  [feedContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",ogUrl] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [feedContent length])];
        }
        else if ([feedContent.lowercaseString containsString:[[NSString stringWithFormat:@"%@",ogUrl]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
            NSString *serachurl = [[NSString stringWithFormat:@"%@",ogUrl]stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            NSRange range = [feedContent rangeOfString:serachurl];
            if (range.location == NSNotFound) {
                //  NSLog(@"string was not found");
            } else {
              //  NSLog(@"position %lu , length = %lu", (unsigned long)range.location, (unsigned long)range.length);
               // NSLog(@"total length of text = %lu", (unsigned long)feedContent.length);
            }
            if (feedContent.length <= range.length + range.location) {
                feedContent =  [feedContent stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",ogUrl]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [feedContent length])];
            }
        }
        else if ([feedContent.lowercaseString containsString:[[NSString stringWithFormat:@"%@",ogUrl]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
            feedContent =  [feedContent stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",ogUrl]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [feedContent length])];
        }
        
        NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
        self.isEditFeed?[self setEditFeedPostRequestWithAuthkey:[userPref valueForKey:feedID] post_type:self.postTypeTF.text feed_title:feedTitle feed_content:feedContent file_type:fileType file_url:fileUrl association_id:pickedAssoID feed_kind:feedkind meta_url:ogUrl video_image_url:imgUrls]:[self setFeedPostRequestWithAuthkey: self.postTypeTF.text feed_title:feedTitle feed_content:feedContent file_type:fileType file_url:fileUrl association_id:pickedAssoID feed_kind:feedkind meta_url:ogUrl video_image_url:imgUrls];
     }
    else{
        // NSLog(@"Image urls = %@",imgUrls);
        if (!_isEditFeed && isImage) {
            for (int i=0; i<self.choosenImagesUrlArr.count; i++) {
                if (![imgUrls isEqualToString:@""]) {
                    imgUrls = [NSString stringWithFormat:@"%@|%@",imgUrls,[self.choosenImagesUrlArr objectAtIndex:i]];
                }else{
                    imgUrls = [self.choosenImagesUrlArr objectAtIndex:i];
                }
            }
            fileUrl =imgUrls;
        }
        if(isVideo){
            fileType = @"video";
        }else if(isPDFAttachment){
            fileType = @"document";
        }
        if(isImage){
            fileUrl =imgUrls.copy;
            imgUrls = @"";
        }
         NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
        self.isEditFeed?[self setEditFeedPostRequestWithAuthkey: [userPref valueForKey:feedID] post_type:self.postTypeTF.text feed_title:feedTitle feed_content:feedContent file_type:fileType file_url:fileUrl association_id:pickedAssoID feed_kind:feedkind meta_url:ogUrl video_image_url:imgUrls]:[self setFeedPostRequestWithAuthkey: self.postTypeTF.text feed_title:feedTitle feed_content:feedContent file_type:fileType file_url:fileUrl association_id:pickedAssoID feed_kind:feedkind meta_url:ogUrl video_image_url:imgUrls];
    }
}

-(void) uploadImagesToServer
{
    isImageUnderProcess = YES;
    if (_isEditFeed) {
        if(!imgUrls){
            imgUrls = @"";
        }
        for (NSString *str in self.choosenImagesUrlArr) {
            if ([imgUrls isEqualToString:@""]) {
                imgUrls = str;
            }else{
                imgUrls = [NSString stringWithFormat:@"%@|%@",imgUrls,str];
            }
        }
    }else{
        [self.choosenImagesUrlArr removeAllObjects];
    }
    imgUrls = _isEditFeed?imgUrls:@"";
    // NSLog(@"Enter in upload image to server, img url = %@",imgUrls);
    ImgUploadCount =0;
    [self multipleImageUpload:[self.choosenImagesArr objectAtIndex:ImgUploadCount]];
}

-(void)asyncAPICallingForUploadImage:(NSMutableDictionary*)userInfo{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *file=    [userInfo valueForKey:base64Str1];
    NSString *fType=    [userInfo objectForKey:feedFileTyp];
    [userpref synchronize];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:WebUrl@"setApi.php?rquest=UploadFile"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:500.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString =  [NSString stringWithFormat:@"file=%@&type=%@&format=%@",file?file:@"",fType?fType:@"",jsonformat];
    //NSLog(@"post string for SetUploadFileRequest %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    //  NSLog(@"string: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    __block NSError *e;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    // Code to run when the response completes...
                    //    NSLog(@"Async UploadMedicalReport Response= %@",response);
                    
                    if (!error) {
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
                        // NSLog(@"Async UploadPicture Response json data= %@",json);
                        NSDictionary *postdic = [json objectForKey:@"posts"];
                        // NSLog(@"post data =%@",postdic);
                        NSInteger status = [[postdic valueForKey:@"status"]integerValue];
                        if (status==1) {
                            fileType = [NSString stringWithFormat:@"%@",[postdic objectForKey:@"file_type"]?[postdic objectForKey:@"file_type"]:@""];
                            if ([imgUrls isEqualToString:@""]) {
                                // NSLog(@"img url is if blanck = %@",imgUrls);
                                imgUrls = [postdic objectForKey:@"file_url"];
                               // NSLog(@"img url is if is = %@",imgUrls);
                                ImgUploadCount ++;
                            }else{
                                // NSLog(@"img url is if not = %@",imgUrls);
                                imgUrls = [NSString stringWithFormat:@"%@|%@",imgUrls,[postdic objectForKey:@"file_url"]];
                                ImgUploadCount++;
                                // NSLog(@"img url is if not = %@",imgUrls);
                            }
                            if (ImgUploadCount==self.choosenImagesArr.count) {
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"docquityAllImgUploaded" object:self];
                            }
                        }
                    } else {
                        // update the UI to indicate error
                    }
                }] resume];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"docquityAllImgUploaded" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    // NSLog (@"Enter in receiveNotification!");
    if (!setFeedCalled) {
        if ([[notification name] isEqualToString:@"docquityAllImgUploaded"])
            setFeedCalled = YES;
        //   NSLog (@"Successfully received the test notification!");
        NSString *content = [self.ContentTextView.attributedText string];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFeedToServerWithContent:content];
        });
    }
}

#pragma webservices methods for Set file uploading
- (void) uploadImageToServer:(UIImage *)image
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSMutableDictionary *dataDic;
    base64EncodedString = [self encodeImagetoBase64:image];
    [userpref setObject:base64EncodedString forKey:base64Str1];
    //set user profile Updation
    dataDic =[[NSMutableDictionary alloc]initWithObjectsAndKeys:u_ImgType?u_ImgType:@"",Image1,base64EncodedString?base64EncodedString:@"",base64Str1, nil];
    
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

-(void)multipleImageUpload:(UIImage *)image{
    isImageUnderProcess = YES;
    image = [image fixOrientation];
    // NSLog(@"Mulit image post ,%ld",(long)ImgUploadCount);
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSMutableDictionary *dataDic;
    base64EncodedString = [self encodeImagetoBase64:image];
    [userpref setObject:base64EncodedString forKey:base64Str1];
    //set user profile Updation
    dataDic =[[NSMutableDictionary alloc]initWithObjectsAndKeys:u_ImgType?u_ImgType:@"",Image1,base64EncodedString?base64EncodedString:@"",base64Str1, nil];
    
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

- (void) serviceCalling1
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    [[AppDelegate appDelegate] showIndicator];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kSetUploadFileRequest], keyRequestType1, nil];
    NSMutableDictionary *dataDic;
    
    [userpref setObject:u_ImgType forKey:Image1];
    [userpref setObject:base64EncodedString forKey:base64Str1];
    //set user profile Updation
    dataDic =[[NSMutableDictionary alloc]initWithObjectsAndKeys:u_ImgType?u_ImgType:@"",Image1,base64EncodedString?base64EncodedString:@"",base64Str1, nil];
    
    Server *obj = [[Server alloc] init];
    currentRequestType = kSetUploadFileRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

#pragma webservices methods for metadata request
- (void)serviceCalling2:(NSString*)urlAddress
{
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    //[userpref setObject:u_ImgType forKey:Image1];
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:urlAddress options:0 range:NSMakeRange(0, [urlAddress length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            NSLog(@"found URL: %@", url);
            //break;
        }
    }
    NSString *myString = [url absoluteString];
    [userpref setObject:myString forKey:metaURLs];
    [userpref synchronize];
    [blockurl addObject:myString];
    // [GMDCircleLoader setOnView:self.view withTitle:@"Please wait...\nWe are generating preview." animated:YES];
    [AppDelegate appDelegate].isMetaData =YES;
    metaContent = @"";
    // [[AppDelegate appDelegate] showIndicator];
    [self getMetaViewRequestWithAuthkey:urlAddress];
}

#pragma webservices methods for Get AssociationListRequest
- (void) serviceCalling3
{
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGetAssociationListRequest], keyRequestType1, nil];
    Server *obj = [[Server alloc] init];
    currentRequestType = kGetAssociationListRequest;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:nil];
}

//- (void)stopCircleLoader {
//    [GMDCircleLoader hideFromView:self.view animated:YES];
//}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // Start the throbber to check if the user exists
    metaDataWv.backgroundColor = [UIColor whiteColor];
    metaDataWv.contentMode = UIViewContentModeScaleToFill;
    metaDataWv.clipsToBounds = YES;
    [metaDataWv.scrollView setScrollEnabled:NO];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //[self.activityIndicator stopAnimating];
   // [self performSelector:@selector(stopCircleLoader) withObject:nil afterDelay:0.0];
     //Resize the webView to its Contentsize
    CGFloat height = webView.scrollView.contentSize.height;
    CGRect rect = webView.frame;
    rect.size.height = height;
    webView.frame = rect;
    [webView.superview sizeToFit];
    [self updateAttachmentView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
   // [self performSelector:@selector(stopCircleLoader) withObject:nil afterDelay:0.0];
    // NSLog(@"%@",error);
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    // NSLog(@"Req finish");
    switch (currentRequestType)
    {
        
        case kSetUploadFileRequest:
            [self setuploadFileRequest:responseData];
            break;
        case kGetMetaDataRequest:
            [self getMetaDataRequest:responseData];
            break;
      
        default:
            break;
    }
}

#pragma result for Set Upload file
- (void) setuploadFileRequest:(NSDictionary *)response
{
    isImageUnderProcess = YES;
    // NSLog(@"resp setuploadFileRequest= %@ , %ld",response,(long)ImgUploadCount);
    NSIndexPath *path =  [NSIndexPath indexPathForRow:ImgUploadCount inSection:0];
    PagerCollectionViewCell *cell = (PagerCollectionViewCell*) [self.viewPager cellForItemAtIndexPath:path];
    UIActivityIndicatorView *activityView = [cell viewWithTag:ImgUploadCount+1];
    [activityView removeFromSuperview];
    if(isVideo){
        [[AppDelegate appDelegate] hideIndicator];
        imgUrls = @"";
    }
    else if(isPDFAttachment){
        [[AppDelegate appDelegate] hideIndicator];
        imgUrls = @"";
    }
    else if (ImgUploadCount==self.choosenImagesArr.count-1) {
    // NSLog(@"resp setuploadFileRequest= %d vs %d",ImgUploadCount,self.choosenImagesArr.count);
     [[AppDelegate appDelegate] hideIndicator];
    }
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
    {
        // tel is null
    }
    else {
        NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
        fileType = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"file_type"]?[resposeCode objectForKey:@"file_type"]:@""];
        fileUrl= [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"file_url"]?[resposeCode objectForKey:@"file_url"]:@""];
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            ImgUploadCount++;
            if (_isEditFeed) {
                [self.choosenImagesUrlArr addObject:fileUrl];
                imgUrls = isPDFAttachment?fileUrl:@"";
            }else{
                if (isVideo) {
                    imgUrls = fileUrl;
                }else if (isPDFAttachment) {
                    imgUrls = fileUrl;
                }else if(isImage){
                    [self.choosenImagesUrlArr addObject:fileUrl];
                }
            }
            imgRetryCount = 0;
            if (isImage) {
                if (ImgUploadCount<self.choosenImagesArr.count) {
                    
                    [self multipleImageUpload:[self.choosenImagesArr objectAtIndex:ImgUploadCount]];
                }else{
                    isIndicatorRemove = YES;
                    isImageUnderProcess = NO;
                    _isEditFeed?[self.choosenImagesArr removeAllObjects]:nil;
                    //   If all images are upload, then send to feed post
                    imgRetryCount = 0;
                    if(isPostPress && _isEditFeed){
                        [self SetEditFeed];
                    }else if(isPostPress){
                         if ([AppDelegate appDelegate].isCases_Feed == YES){
                             if ([self.specialityTagTF.text length] == 0 || [NSString trim:self.specialityTagTF.text].length == 0){
                                    }
                             else{
                        NSString *content = [self.ContentTextView.attributedText string];
                        [self setFeedToServerWithContent:content];
                             }
                         }
                    }else{
                        [self.viewPager reloadData];
                    }
                }
            }else if (isVideo){
                [self uploadVideoToServer];
            }else if (isPDFAttachment){
                [self uploadFileToServer];
            }
        }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 0) {
            if (imgRetryCount<3) {
                [self multipleImageUpload:[self.choosenImagesArr objectAtIndex:ImgUploadCount]];
                imgRetryCount ++;
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:AppName message:message delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                [alert show];
            }
         }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
        else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
        {
            NSString*userValidateCheck = @"readonly";
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
            [userpref synchronize];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Set upload File Request" message:message delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma result for Set Upload file
- (void) getMetaDataRequest:(NSDictionary *)response
{
    //NSLog(@"getMetaDataRequest");
    // NSLog(@"resp from meta =%@",response);
    [[AppDelegate appDelegate] hideIndicator];
    NSDictionary *resposeCode=[response objectForKey:@"posts"];
    if ([response isKindOfClass:[NSNull class]] || !(response.count))
    {
        // tel is null
        // NSLog(@"Null Response here");
        self.MetaDataView.hidden = YES;
        [self removeAttachedMetaObject];
     }
    else if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
    {
        // tel is null
        //  NSLog(@"Null resposeCode here");
    }
    else {
        if([[resposeCode  valueForKey:@"status"]integerValue] == 1){
            //[AppDelegate appDelegate].isMetaData =YES;
            metaContent =  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"meta"]?[resposeCode objectForKey:@"meta"]:@""];
            metaContent = [metaContent stringByDecodingHTMLEntities];
            metaDataWv.opaque = NO;
            [metaDataWv.scrollView setScrollEnabled:NO];
            CGRect rect;
            
            metaDataWv.backgroundColor = [UIColor whiteColor];
            rect = metaDataWv.frame;
            rect.size.height = 2;
            metaDataWv.frame = rect;
            [metaDataWv loadHTMLString:metaContent baseURL:nil];
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            [userpref setObject:metaContent?metaContent:@"" forKey:feedFileURL];
            [userpref synchronize];
            [self hideToolbar:YES];
            NSMutableDictionary *rawdata = [resposeCode valueForKey:@"rawmeta"];
            self.LblMetaTitle.text = [[rawdata valueForKey:@"title"]isEqualToString:@""]?ogUrl:[[rawdata valueForKey:@"title"]stringByDecodingHTMLEntities];
            self.LblMetaDesc.text = [[rawdata valueForKey:@"description"] stringByDecodingHTMLEntities];
            self.LblMetaUrl.text = [rawdata valueForKey:@"pageUrl"];
            BOOL img = TRUE;
            if ([[rawdata objectForKey:@"images"] isKindOfClass:[NSNumber class]])
            {
                if([[rawdata objectForKey:@"images"] isEqual:[NSNumber numberWithBool:NO]])
                {
                    img = NO;
                }
            }
             if (!img && [[rawdata valueForKey:@"description"]isEqualToString:@""])
             {
                [self completedMetaShowByConditionWithImage:false Description:false];
            }
             else if (!img && ![[rawdata valueForKey:@"description"]isEqualToString:@""])
            {
                [self completedMetaShowByConditionWithImage:false Description:true];
            }else if (img && ![[rawdata valueForKey:@"description"]isEqualToString:@""])
            {
                [self completedMetaShowByConditionWithImage:true Description:true];
                [self.imgMeta sd_setImageWithURL:[NSURL URLWithString:[rawdata valueForKey:@"images"]] placeholderImage:[UIImage imageNamed:@"img-not.png"]options:SDWebImageRefreshCached];
            }else if (img && [[rawdata valueForKey:@"description"]isEqualToString:@""])
            {
                [self completedMetaShowByConditionWithImage:true Description:false];
                [self.imgMeta sd_setImageWithURL:[NSURL URLWithString:[rawdata valueForKey:@"images"]] placeholderImage:[UIImage imageNamed:@"img-not.png"]options:SDWebImageRefreshCached];
            }
        }
        else if([[resposeCode  valueForKey:@"status"]integerValue] == 9){
            [[AppDelegate appDelegate] logOut];
        }
        else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
        {
            NSString*userValidateCheck = @"readonly";
            NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
            [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
            [userpref synchronize];
            NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
            if ([u_permissionstus isEqualToString:@"readonly"]) {
                [self getcheckedUserPermissionData];
            }
        }
        else{
            [AppDelegate appDelegate].isMetaData =NO;
        }
    }
}

- (void) requestError
{
    [self PostBtnActivate:YES];
    [[AppDelegate appDelegate] hideIndicator];
     metaViewAppeared = false;
   // [self performSelector:@selector(stopCircleLoader) withObject:nil afterDelay:0.0];
}

-(void)LoadFeedForEdit{
    pickedAssoID = @"";
    [self.SegmentFeedOption setSelectedSegmentIndex:1];
   //NSLog(@"feed information: %@",self.FeedInformation);
    [[self.FeedInformation valueForKey:@"feed_kind"]isEqualToString:@"cases"]?[self didPressCases:self.btnCases]:[self didPressTrends:self.BtnTrend];
    self.TitleTextField.text = [self.FeedInformation valueForKey:@"title"];
    self.ContentTextView.text = [self.FeedInformation valueForKey:@"content"];
    self.PlaceHolder.hidden = self.ContentTextView.text?YES:NO;
    [self PostBtnActivate:self.PlaceHolder.hidden];
    NSMutableArray *assoListArray = [[NSMutableArray alloc]init];
    assoListArray = [self.FeedInformation valueForKey:@"association_list"];
    NSString *associationList = @"";
    NSString *assoImage=@"";
    SpecialityArrList = [[NSMutableArray alloc]init];
    NSMutableArray* specialityNameArrData=[[NSMutableArray alloc]init];
    Arr_specialityId = [[NSMutableArray alloc]init];
    rawdataAr = [[NSArray alloc]init];
    NSString*specialityId;
    NSString*specialityName;
    SpecialityArrList = [self.FeedInformation valueForKey:@"speciality"];
    specSelectedMainArray = SpecialityArrList;
    assoSelectedMainArray = assoListArray;
    for(int i=0; i<[SpecialityArrList count]; i++)
    {
        NSDictionary *speclityInfo =  SpecialityArrList[i];
        if (speclityInfo != nil && [speclityInfo isKindOfClass:[NSDictionary class]])
        {
            specialityId = speclityInfo[@"speciality_id"];
            specialityName = speclityInfo[@"speciality_name"];
        }
        [specialityNameArrData addObject:specialityName];
        [Arr_specialityId addObject:specialityId];
    }
    NSString * myspeciality = [[specialityNameArrData valueForKey:@"description"] componentsJoinedByString:@", "];
   // NSLog(@"Speciality Name: %@",myspeciality);
  //   NSLog(@"Speciality Arr_specialityId: %@",Arr_specialityId);
    self.specialityTagTF.text = [myspeciality stringByDecodingHTMLEntities];
    for(int i=0; i<[assoListArray count]; i++)
    {
        NSDictionary *assoInfo = assoListArray[i];
        if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
        {
            NSString* asId = assoInfo[@"association_id"];
            for (int j=0; j<[AppDelegate appDelegate].myAssociationList.count; j++)
            {
                NSDictionary *dic= [AppDelegate appDelegate].myAssociationList[j];
                if ([[dic valueForKey:@"association_id"]isEqualToString:asId]) {
                    if (i==0) {
                        pickedAssoID =[NSString stringWithFormat:@"%@",asId];
                        associationList = [NSString stringWithFormat:@"%@",[dic valueForKey:@"association_name"]];
                        assoImage =[NSString stringWithFormat:@"%@",[dic valueForKey:@"profile_pic_path"]];
                    }else{
                        associationList = [NSString stringWithFormat:@"%@, %@",associationList,[dic valueForKey:@"association_name"]];
                        pickedAssoID =[NSString stringWithFormat:@"%@|%@",pickedAssoID,asId];
                    }
                    break;
                }
            }
        }
    }
     if (assoListArray.count+1 == [AppDelegate appDelegate].myAssociationList.count) {
       // associationList = @"Everyone";
       // self.ImgSelectedAsso.image = [UIImage imageNamed:@"globe.png"];
    }else if (assoListArray.count==1){
        // [self.ImgSelectedAsso sd_setImageWithURL:[NSURL URLWithString:assoImage] placeholderImage:nil options:SDWebImageRefreshCached];
        [self.ImgSelectedAsso  sd_setImageWithURL:[NSURL URLWithString:assoImage]
                                 placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                          options:SDWebImageRefreshCached];
    }
    [self textViewDidChange:self.ContentTextView];
     [self contentViewResize];
     [self scrollResize];
    //NSLog(@"Asso list: %@",associationList);
    
    if([[[AppDelegate appDelegate]myAssociationList]count]==0){
        if ([AppDelegate appDelegate].isComeFromTrending ==YES) {
            pickedAssoID = [[self.myNewfeedAssociationList objectAtIndex:0]valueForKey:@"association_id"];
            [self.ImgSelectedAsso sd_setImageWithURL:[NSURL URLWithString:[self.myNewfeedAssociationList objectAtIndex:0][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
            self.postTypeTF.text = [[self.myNewfeedAssociationList objectAtIndex:0]valueForKey:@"association_name"];
            // NSLog(@"Seelcted id: %@",pickedAssoID);
            self.BtnSelection.enabled = false;
             }
    }
        else{
    self.postTypeTF.text = associationList;
        }
    if ([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"image"]) {
        isImage = YES;
        isVideo = false;
        isAttachment = YES;
        //chosenImage = [self.FeedInformation valueForKey:@"FeedImg"];
        self.choosenImagesUrlArr = [[NSMutableArray alloc]init];
        //New changes
         for(NSMutableDictionary *tempdic in [self.FeedInformation valueForKey:@"image_list"]){
            [self.choosenImagesUrlArr addObject:[tempdic valueForKey:@"multiple_file_url"]];
        }
        //  self.choosenImagesUrlArr = [self.FeedInformation valueForKey:@"image_list"];
        [self addAttachmentInAttachment];
    }
    else if ([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"link"]) {
        isImage = NO;
        isVideo = NO;
        [self setOGView];
        [self updateMetaView];
        [self serviceCalling2:[self.FeedInformation valueForKey:@"meta_url"]];
    }else if ([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"video"]) {
        isImage = NO;
        isVideo = YES;
        [self hideToolbar:YES];
        
    }else if ([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"document"]) {
        isImage = NO;
        isVideo = NO;
        isPDFAttachment = YES;
        [self hideToolbar:YES];
        originalFileName = [self.FeedInformation valueForKey:@"file_name"];
        NSString *ext = [[self.FeedInformation valueForKey:@"file_name"] pathExtension];
        [self addDocumentInAttachmentview:[self.FeedInformation valueForKey:@"FeedImg"] PdfName:[self.FeedInformation valueForKey:@"file_name"] documentType:ext];
        [self updatePDFView];
    }
    [self focusTextview];
}

-(void)setOGView{
    //  NSLog(@"setOGView");
    self.MetaDataView.hidden = false;
    [self hideToolbar:YES];
    metaViewAppeared = YES;
    self.MetaDataView.layer.borderWidth = 1.0f;
    self.MetaDataView.layer.cornerRadius = 1.0f;
    self.MetaDataView.layer.masksToBounds = YES;
    self.MetaDataView.layer.borderColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0].CGColor;
    
    self.MetaDataView.layer.shadowColor =[UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0].CGColor;
    self.MetaDataView.layer.shadowOpacity = 1.0;
    self.MetaDataView.layer.shadowRadius = 10;
    self.MetaDataView.layer.shadowOffset = CGSizeMake(1.0, 5.0);
    
    CGRect frame = self.MetaDataView.frame;
    frame.origin.y = self.ContentTextView.frame.origin.y + self.ContentTextView.frame.size.height+4;
    self.MetaDataView.frame = frame;
    self.imgMeta.hidden = TRUE;
    self.LblMetaUrl.hidden = TRUE;
    self.LblMetaDesc.hidden = TRUE;
    self.LblMetaTitle.hidden = TRUE;
    self.MetaLoader.hidden = FALSE;
    [self.MetaLoader startAnimating];
    self.imgMeta.contentMode = UIViewContentModeScaleAspectFill;
    self.imgMeta.layer.masksToBounds = YES;
}

-(void)completedMetaShowByConditionWithImage:(BOOL)image Description:(BOOL)description{
    // NSLog(@"Enter in completedMeta");
    self.imgMeta.hidden = FALSE;
    self.LblMetaUrl.hidden = FALSE;
    self.LblMetaDesc.hidden = FALSE;
    self.LblMetaTitle.hidden = FALSE;
    [self.MetaLoader stopAnimating];
    self.MetaLoader.hidden = TRUE;
    if (!image)
    {
        CGRect reframe = self.LblMetaTitle.frame;
        reframe.origin.x = self.imgMeta.frame.origin.x;
        reframe.size.width = self.MetaDataView.frame.size.width - (reframe.origin.x*2);
        self.LblMetaTitle.frame = reframe;
        if (!description) {
            reframe = self.LblMetaUrl.frame;
            reframe.origin.y = self.LblMetaTitle.frame.origin.y + self.LblMetaTitle.frame.size.height +1;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaUrl.frame = reframe;
            self.LblMetaDesc.hidden = true;
            reframe = self.MetaDataView.frame;
            reframe.size.height = self.LblMetaUrl.frame.size.height + self.LblMetaUrl.frame.origin.y +4;
            self.MetaDataView.frame = reframe;
        }else if (description){
            reframe = self.LblMetaDesc.frame;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaDesc.frame = reframe;
            
            reframe = self.LblMetaUrl.frame;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaUrl.frame = reframe;
        }
    }else{
        CGRect reframe ;
        if (!description) {
            reframe = self.LblMetaUrl.frame;
            reframe.origin.y = self.LblMetaTitle.frame.origin.y + self.LblMetaTitle.frame.size.height +1;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaUrl.frame = reframe;
            
            reframe = self.MetaDataView.frame;
            reframe.size.height = self.imgMeta.frame.size.height + self.imgMeta.frame.origin.y +4;
            self.MetaDataView.frame = reframe;
            self.LblMetaDesc.hidden = true;
            
        }else if (description){
            reframe = self.LblMetaDesc.frame;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaDesc.frame = reframe;
            self.LblMetaDesc.hidden = false;
            reframe = self.LblMetaUrl.frame;
            reframe.origin.x = self.LblMetaTitle.frame.origin.x;
            self.LblMetaUrl.frame = reframe;
        }
    }
    if (self.isEditFeed && [[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"link"]) {
        UIButton *fadeViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fadeViewBtn.frame = CGRectMake(0, 0, self.MetaDataView.frame.size.width, self.MetaDataView.frame.size.height);
        [self.MetaDataView addSubview:fadeViewBtn];
        [fadeViewBtn setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
        
    }else{
        UITapGestureRecognizer *removeLink = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDeleteLinkAlert)];
        [self.MetaDataView addGestureRecognizer:removeLink];
        removeLink.numberOfTapsRequired =1.0;
    }
}

-(void)showDeleteLinkAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Remove Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // [self.MetaDataView removeFromSuperview];
        self.MetaDataView.hidden = YES;
        [self removeAttachedMetaObject];
        // [self];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
     [self presentViewController:alert animated:YES completion:nil];
  }

//*****************************************
//*****************************************
//********** RECORD VIDEO BUTTON **********
//*****************************************
//*****************************************

- (IBAction)RecordVideoButton
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = self;
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
        
        if ([videoMediaTypesOnly count] == 0)		//Is movie output possible?
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sorry but your device does not support video recording"
                                                                     delegate:nil
                                                            cancelButtonTitle:OK_STRING
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            [actionSheet showInView:[[self view] window]];
         }
        else
        {
            //Select front facing camera if possible
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
                self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            self.imagePickerController.mediaTypes = videoMediaTypesOnly;
            self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
            self.imagePickerController.videoMaximumDuration = 3600;			//Specify in seconds (600 is default)
            self.imagePickerController.allowsEditing = YES;
            //   [self presentModalViewController:videoRecorder animated:YES];
            [self presentViewController: self.imagePickerController animated:YES completion:nil];
        }
    }
    else
    {
        //No camera is availble
    }
}

-(void)uploadVideoWithChunk{
    NSString *uploadurl = [NSString stringWithFormat:WebUrl@"setApi.php?rquest=pupload"];
    //NSLog(@"upload url = %@",uploadurl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:uploadurl]];
    //   NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"Some Caption"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    if (vidData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=ios.mp4\r\n", @"videoFormKey"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: video/mp4\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:vidData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(data.length > 0)
        {
            NSLog(@"Error: %@", error);
            //NSLog(@"response: %@", response);
        }
    }];
}

-(void)uploadFileToServers
{
    NSString *uploadurl = [NSString stringWithFormat:WebUrl@"setApi.php?rquest=pupload"];
    // NSLog(@"upload url = %@",uploadurl);
      NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadurl]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"ashutosh.mp4" forHTTPHeaderField:@"name"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    NSURLSessionUploadTask* uploadTask = [defaultSession uploadTaskWithRequest:request fromFile:urlvideo completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              if (error || [httpResponse statusCode]!=202)
                                              {
                                                  
                                                  NSLog(@" Error");//Error
                                              }
                                              else
                                              {
                                                  // NSLog(@"Success block");//Success
                                              }
                                              [defaultSession invalidateAndCancel];
                                          }];
    [uploadTask resume];
}

-(void)getELCPictureFromLibrary
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    if (_isEditFeed) {
        if (4 - (self.choosenImagesUrlArr.count+self.choosenImagesArr.count) >0)
        {
            elcPicker.maximumImagesCount = 4 - (self.choosenImagesUrlArr.count+self.choosenImagesArr.count);
            //    elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select to 100
            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
            
            elcPicker.imagePickerDelegate = self;
            elcPicker.navigationBar.translucent = NO;
            elcPicker.navigationBar.barTintColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
            elcPicker.navigationBar.tintColor = [UIColor whiteColor];
            elcPicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
            
            [self presentViewController:elcPicker animated:YES completion:nil];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:@"Maximum 4 images can be attached to a post." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else{
        if (4 - self.choosenImagesArr.count >0)
        {
            elcPicker.maximumImagesCount = 4 - self.choosenImagesArr.count;
            //    elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select to 100
            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
            elcPicker.imagePickerDelegate = self;
            elcPicker.navigationBar.translucent = NO;
            elcPicker.navigationBar.barTintColor = [UIColor colorWithRed:0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
            elcPicker.navigationBar.tintColor = [UIColor whiteColor];
            elcPicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
            [self presentViewController:elcPicker animated:YES completion:nil];
          }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:@"Maximum 4 images can be attached to a post." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark ELCImagePickerControllerDelegate Methods
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.viewPager.hidden = NO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ;
    //workingFrame.origin.x = 0;
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:[image fixOrientation]];
             }
            else {
                
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:AppName message:@"Please select only image" delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    for (UIImage *img in images){
        [self.choosenImagesArr addObject:img];
    }
    //NSLog(@"total image selected = %lu",(unsigned long)self.choosenImagesArr.count);
    // [self addAttachmentInAttachmentview:self.choosenImagesArr];
    isVideo = false;
    isImage = YES;
    isAttachment = YES;
    if (_isEditFeed) {
        isUpdateImage = YES;
        if (self.AttachmentView.hidden) {
            [self addAttachmentInAttachment];
            [self uploadImagesToServer];
        }
        else{
            [self.viewPager reloadData];
            [self uploadImagesToServer];
        }
    }else{
        [self addAttachmentInAttachment];
        //upload image
        [self uploadImagesToServer];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HWViewPagerDelegate
-(void)pagerDidSelectedPage:(NSInteger)selectedPage{
    // NSLog(@"FistViewController, SelectedPage : %d",(int)selectedPage);
    NSString * string = [NSString stringWithFormat:@"SectionInset left,right = 30\nminLinespacing =20\nSelectedPage : %d",(int)selectedPage];
  //  NSLog(@"FistViewController, SelectedPage : %@",string);
    NSIndexPath *path =  [NSIndexPath indexPathForRow:selectedPage inSection:0];
    PagerCollectionViewCell *cell = (PagerCollectionViewCell*) [self.viewPager cellForItemAtIndexPath:path];
   // NSLog(@"photo count in view pager delegate = %@", cell.photoCount.text);
}

#pragma mark - did click on Trends
-(IBAction)didPressTrends:(UIButton*)sender{
    [Localytics tagEvent:@"Post Feed Trends"];
    [AppDelegate appDelegate].isCases_Feed = NO;
    self.specialityTagTF.placeholder = @"Tags (optional)";
    lbl_navheaderTitle.text = @"New Trend";
    feedkind = @"post";
    [self removeBottom:sender];
    [self addBottom:sender];
    self.lblTrend.textColor =[UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:220.0/255.0 alpha:1.0];
    self.lblCases.textColor =[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0];
    [self deselectModeSender:self.btnCases];
}

#pragma mark - did click on Cases
- (IBAction)didPressCases:(UIButton*)sender {
    [Localytics tagEvent:@"Post Feed Cases"];
    [AppDelegate appDelegate].isCases_Feed = YES;
    self.specialityTagTF.placeholder = @"Tags";
    lbl_navheaderTitle.text = @"New Case";
    feedkind = @"cases";
    [self removeBottom:sender];
    [self addBottom:sender];
    self.lblCases.textColor =[UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:220.0/255.0 alpha:1.0];
    self.lblTrend.textColor =[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0];
    [self deselectModeSender:self.BtnTrend];
}

#pragma mark - remove from Bottom
-(void)removeBottom:(UIButton*)btn{
    for (UIView *view in btn.subviews) {
        if (view.tag==1111) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - add on Bottom
-(void)addBottom:(UIButton *)sender{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height-3, sender.frame.size.width, 3)];
    lineView.backgroundColor = [UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    lineView.tag = 1111;
    [sender addSubview:lineView];
    if (sender.tag==999) {
        self.imgCases.image = [UIImage imageNamed:@"cases_grey.png"];
    }else if(sender.tag==888){
        self.imgTrend.image = [UIImage imageNamed:@"trends_grey.png"];
    }
}


#pragma mark - deseclect Mode Sender
-(void)deselectModeSender:(UIButton*)sender{
    [sender setTitleColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    UIView *border = (UIView*)[sender viewWithTag:1111];
    [border removeFromSuperview];
    if (sender.tag==999) {
        self.imgCases.image = [UIImage imageNamed:@"cases-hover.png"];
    }else if(sender.tag==888){
        self.imgTrend.image = [UIImage imageNamed:@"trends_hover.png"];
    }
}


#pragma mark - open Custom Camera
-(void)openCustomCamera:(NSInteger)max{
    iImagePickerController *imgpick = [[iImagePickerController alloc]init];
    //imgpick.maximumImageClick = 4 - self.choosenImagesArr.count;
    imgpick.maximumImageClick = max;
    imgpick.delegate = self;
    [self presentViewController:imgpick animated:NO completion:nil];
}

#pragma mark - imagesPickingFinish
- (void)imagesPickingFinish:(NSMutableArray*)arrImages
{
    isImage = YES;
    isVideo = false;
    isAttachment = YES;
    if(!arrImages || [arrImages isKindOfClass:[NSNull class]] || [arrImages count]==0){
        return;
    }
    //    for (UIImage *img in arrImages){
    //        [self.choosenImagesArr addObject:img];
    //    }
    if (self.AttachmentView.hidden) {
        [self addAttachmentInAttachment];
        [self uploadImagesToServer];
    }else{
        [self.viewPager reloadData];
        [self uploadImagesToServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - open Video Button Clicked
-(void)videoButtonClicked
{
    NSString*fileUrlLink = [NSString stringWithFormat:@"%@",urlvideo];
    
    // Make a URL
    NSURL *url = [NSURL URLWithString:
                  fileUrlLink];
    // Initialize the MPMoviePlayerController object using url
    _videoPlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    // Add a notification. (It will call a "moviePlayBackDidFinish" method when _videoPlayer finish or stops the plying video)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_videoPlayer];
    // Set control style tp default
    _videoPlayer.controlStyle = MPMovieControlStyleDefault;
    
    //_videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    // Set shouldAutoplay to YES
    _videoPlayer.shouldAutoplay = YES;
    
    // Add _videoPlayer's view as subview to current view.
    [[_videoPlayer view] setFrame: [self.view bounds]];  // frame must match parent view
    [self.view addSubview: [_videoPlayer view]];
    
    // Set the screen to full.
    [_videoPlayer setFullscreen:YES animated:NO];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [_videoPlayer stop];
    MPMoviePlayerController *videoplayer = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:videoplayer];
    if ([videoplayer
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [videoplayer.view removeFromSuperview];
        // remove the video player from superview.
    }
}

-(void)uploadThumbnail{
    [self uploadImageToServer:chosenImage];
    [[AppDelegate appDelegate]showIndicator];
}

-(void)uploadVideoToServer{
    isVideo = YES;
    isImage = false;
    if([AppDelegate appDelegate].is2GData){
        self.oneChunkSize = defaultChunkSize/6;
    }else if([AppDelegate appDelegate].is3GData){
        self.oneChunkSize = defaultChunkSize/4;
    }else if([AppDelegate appDelegate].is4GData){
        self.oneChunkSize = defaultChunkSize/2;
    }else if([AppDelegate appDelegate].isWifiData){
        self.oneChunkSize = defaultChunkSize;
    }
    NSMutableDictionary *postParam = [[NSMutableDictionary alloc]init];
    [postParam addEntriesFromDictionary:[self demoPostDict]];
    HDMultiPartImageUpload *obj = [[HDMultiPartImageUpload alloc]init]; //intilaize the object and set all the required parameters.
    
    obj.oneChunkSize = self.oneChunkSize;
    obj.uploadURLString = WebUrl@"setApi.php?rquest=ChunkMerger";
    obj.postParametersDict = postParam;
    obj.videoData = vidData;
    // NSLog(@"Post Param = %@",postParam);
    obj.delegate = self;
    [obj startUploadImagesToServer];
}

-(NSMutableDictionary*)demoPostDict // Create a dictionary of the parameters needed to be passed at server
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    //#warning - These key values in post dictionary varies according to the server implementation----
    
    NSUInteger totalFileSize = [vidData length];
    
    //int totalChunks = ceil(totalFileSize/oneChunkSize);
    
    int totalChunks = round((totalFileSize/self.oneChunkSize)+0.5);//round-off to nearest  largest valua 1.01 is considered as 2
    
    // Create your Post parameter dict according to server
    NSString* originalFilename = @"tmpVideoToUpload.mp4";//uniqueFileName;
    
    //Creating a unique file to upload to server
    //    NSString *prefixString = @"Album";
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    NSString *prefixString = [NSString stringWithFormat:@"%@_%@",[userdef objectForKey:userId1],[userdef objectForKey:ownerCustId]];
    
    NSString *videoType = @"video/mp4";
    
    // This method generates a new string each time it is invoked, so it also uses a counter to guarantee that strings created from the same process are unique.
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;//
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    //Add key values your post param Dict
    [param setObject:uniqueFileName forKey:@"uniqueFilename"];
    [param setObject:[NSString stringWithFormat:@"%lu",(unsigned long)totalFileSize] forKey:@"totalFileSize"];
    [param setObject:@"1" forKey:@"num"];
    [param setObject:[NSString stringWithFormat:@"%d",totalChunks] forKey:@"num_chunks"];
    [param setObject:videoType forKey:@"fileType"];
    [param setObject:originalFilename forKey:@"originalFilename"];
    if(totalChunks==1){
        [param setObject:@"1" forKey:@"status"];
    }else{
        [param setObject:@"0" forKey:@"status"];
    }
    //- #warning - These key values in post dictionary varies according to the server implementation----
    return param;
}

- (void) videoRequestFinished:(NSMutableDictionary * )serverResponseData
{
    // NSLog(@"videoRequestFinished, = %@",serverResponseData);
    fileUrl = [serverResponseData valueForKey:@"fileurl"];
    NSString *content = [self.ContentTextView.attributedText string];
    [self setFeedToServerWithContent:content];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.navigationItem setTitle:@"Pick Videos"];
}

#pragma mark - upload document
-(void)didUploadDocument{
    UIDocumentMenuViewController *documentPickerMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(__bridge NSString*)kUTTypePDF] inMode:UIDocumentPickerModeImport];
    documentPickerMenu.delegate = self;
    [self presentViewController:documentPickerMenu animated:YES completion:nil];
}

-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    self.restorationIdentifier = [NSUUID UUID].UUIDString;
    if (controller.documentPickerMode == UIDocumentPickerModeImport)
    {
        //  NSLog(@"Opened %@", url.path);
        //  fileData = [NSData dataWithContentsOfURL:url];
        
        NSString *fileTmpPath = [url path];
        // if ( [[NSFileManager defaultManager] fileExistsAtPath:fileTmpPath] ) {
        self.file_Name = [fileTmpPath lastPathComponent];
        originalFileName =  [fileTmpPath lastPathComponent];
        NSString *cacheFolderPath = [self cacheFolderPath];
        NSError *error;
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:cacheFolderPath] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
        self.file_Name = [NSString stringWithFormat:@"%@_%@",[userdef objectForKey:userId1],self.file_Name];
        
        self.originalFilePath = [cacheFolderPath stringByAppendingPathComponent:self.file_Name];
        [[NSFileManager defaultManager] copyItemAtPath:fileTmpPath toPath:self.originalFilePath error:&error];
        //  }
        NSString *pdfPath = [cacheFolderPath stringByAppendingPathComponent:self.file_Name];
        fileData = [NSData dataWithContentsOfFile:pdfPath];
        NSString *ext = [originalFileName pathExtension];
        UIImage* thumbnailImage = [self getThumnailFromPDF];
        chosenImage = thumbnailImage;
        [self addDocumentInAttachmentview:thumbnailImage PdfName:originalFileName documentType:ext];
    }
 }

-(UIImage*)getThumnailFromPDF{
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:self.originalFilePath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    CGPDFPageRef page;
    CGRect aRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(pdf);
    for(int i = 0; i < totalNum; i++ ) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, aRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetGrayFillColor(context, 1.0, 1.0);
        CGContextFillRect(context, aRect);
        
        // Grab the first PDF page
        page = CGPDFDocumentGetPage(pdf, i + 1);
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
        // And apply the transform.
        CGContextConcatCTM(context, pdfTransform);
        
        CGContextDrawPDFPage(context, page);
        
        // Create the new UIImage from the context
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
        CGContextRestoreGState(context);
    }
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    return thumbnailImage;
}

- (NSString *)cacheFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    NSMutableString *dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"DocquityCache"];
    return dataPath;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)uploadFileToServer{
    //    isVideo = YES;
    //    isImage = false;
    if([AppDelegate appDelegate].is2GData){
        self.oneChunkSize = defaultChunkSize/6;
    }else if([AppDelegate appDelegate].is3GData){
        self.oneChunkSize = defaultChunkSize/4;
    }else if([AppDelegate appDelegate].is4GData){
        self.oneChunkSize = defaultChunkSize/2;
    }else if([AppDelegate appDelegate].isWifiData){
        self.oneChunkSize = defaultChunkSize;
    }
    NSMutableDictionary *postParam = [[NSMutableDictionary alloc]init];
    [postParam addEntriesFromDictionary:[self filePostDict]];
    HDMultiPartImageUpload *obj = [[HDMultiPartImageUpload alloc]init]; //intilaize the object and set all the required parameters.
    
    obj.oneChunkSize = self.oneChunkSize;
    obj.uploadURLString = WebUrl@"setApi.php?rquest=ChunkMerger";
    obj.postParametersDict = postParam;
    obj.fileData = fileData;
    // NSLog(@"Post Param = %@",postParam);
    obj.delegate = self;
    [obj startUploadFilesToServer];
}

-(NSMutableDictionary*)filePostDict // Create a dictionary of the parameters needed to be passed at server
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    //#warning - These key values in post dictionary varies according to the server implementation----
    
    NSUInteger totalFileSize = [fileData length];
    
    //int totalChunks = ceil(totalFileSize/oneChunkSize);
    
    int totalChunks = round((totalFileSize/self.oneChunkSize)+0.5);//round-off to nearest  largest valua 1.01 is considered as 2
    
    // Create your Post parameter dict according to server
    NSString* originalFilename = @"tmpFileToUpload.pdf";//uniqueFileName;
    
    //Creating a unique file to upload to server
    //    NSString *prefixString = @"Album";
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    NSString *prefixString = [NSString stringWithFormat:@"%@_%@",[userdef objectForKey:userId1],[userdef objectForKey:ownerCustId]];
    
    NSString *file_Type = @"application/pdf";
    
    //    This method generates a new string each time it is invoked, so it also uses a counter to guarantee that strings created from the same process are unique.
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;//
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    //Add key values your post param Dict
    [param setObject:uniqueFileName forKey:@"uniqueFilename"];
    [param setObject:[NSString stringWithFormat:@"%lu",(unsigned long)totalFileSize] forKey:@"totalFileSize"];
    [param setObject:@"1" forKey:@"num"];
    [param setObject:[NSString stringWithFormat:@"%d",totalChunks] forKey:@"num_chunks"];
    [param setObject:file_Type forKey:@"fileType"];
    [param setObject:originalFilename forKey:@"originalFilename"];
    if(totalChunks==1){
        [param setObject:@"1" forKey:@"status"];
    }else{
        [param setObject:@"0" forKey:@"status"];
    }
    //- #warning - These key values in post dictionary varies according to the server implementation----
    return param;
}

- (void) fileRequestFinished:(NSMutableDictionary * )serverResponseData
{
    //NSLog(@"fileRequestFinished, = %@",serverResponseData);
    fileUrl = [serverResponseData valueForKey:@"fileurl"];
    NSString *content = [self.ContentTextView.attributedText string];
    [self setFeedToServerWithContent:content];
}

- (IBAction)didPressPdfCancel:(id)sender {
    
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic==nil)
        {
            //tel is null
        }
        else {
            NSString * stusmsg =[NSString stringWithFormat:@"%@",[postDic objectForKey:@"msg"]?[postDic objectForKey:@"msg"]:@""];
            NSString * ICNumber;
            NSString * Identity;
            NSString *InviteCodeExample;
            NSString * InviteCodeTyp;
            NSString * IdentityMsg;
            NSDictionary *dataDic=[postDic objectForKey:@"data"];
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic== nil)
            {
                // tel is null
            }
            else {
                permstus = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"permission"]?[dataDic objectForKey:@"permission"]:@""];
                NSDictionary *reqDic=[dataDic objectForKey:@"requirement"];
                if ([reqDic isKindOfClass:[NSNull class]]|| reqDic ==nil)
                {
                    // tel is null
                }
                else {
                    ICNumber =[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"ic_number"]?[reqDic objectForKey:@"ic_number"]:@""];
                    Identity=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity"]?[reqDic objectForKey:@"identity"]:@""];
                    IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    if ([IdentityMsg  isEqualToString:@""] || [IdentityMsg isEqualToString:@"<null>"]) {
                    }
                    else {
                        IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    }
                    NSDictionary *IC_reqDic=[reqDic objectForKey:@"ic_requirement"];
                    if ([IC_reqDic isKindOfClass:[NSNull class]]||IC_reqDic ==nil)
                    {
                        // tel is null
                    }
                    else {
                        InviteCodeExample =[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_example"]?[IC_reqDic objectForKey:@"invite_code_example"]:@""];
                        InviteCodeTyp=[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_type"]?[IC_reqDic objectForKey:@"invite_code_type"]:@""];
                    }
                }
            }
            if([[postDic valueForKey:@"status"]integerValue] == 1){
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:permstus?permstus:@"" forKey:user_permission];//mandatory
                [userpref synchronize];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 11){
                [self pushToVerifyAccount:stusmsg invite_codeType:InviteCodeTyp invite_code_example:InviteCodeExample ic_number:ICNumber identity:Identity identity_message:IdentityMsg];
            }
            else{
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
        }
    }];
}

-(void)pushToVerifyAccount:(NSString*)stusmsg invite_codeType:(NSString*)InviteCodeTyp invite_code_example:(NSString*)InviteCodeExample ic_number:(NSString*)ICNumber identity:(NSString*)Identity identity_message:(NSString*)IdentityMsg{
    UIViewController *cuurent_view = self.presentingViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    PermissionCheckYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"PermissionCheckYourSelfVC"];
    selfVerify.titleMsg = stusmsg;
    selfVerify.titledesc = InviteCodeTyp;
    selfVerify.tf_placeholder = InviteCodeExample;
    selfVerify.IcnumberValue = ICNumber;
    selfVerify.idetityValue = Identity;
    selfVerify.identityTypMsg = IdentityMsg;
    [self dismissViewControllerAnimated:NO completion:^{
        [cuurent_view presentViewController:selfVerify animated:YES completion:nil];
    }];
    // [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

#pragma mark - getSpecialityRequest
-(void)getSpecialityRequestWithAuthkey{
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getSpecialityRequestWithAuthKey:[userPref valueForKey:userAuthKey] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
        // NSLog(@"responseObject get metaView:%@",responseObject);
         if(error){
             if (error.code == NSURLErrorTimedOut) {
                 //time out error here
             }
             else{
                 // [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }
         }else
         {
             // NSLog(@"responseObject get profile:%@",responseObject);
             NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
             if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil)
             {
                 // tel is null
             }
             else
             {
                 if([[resposeDic valueForKey:@"status"]integerValue] == 1)
                 {
                     NSMutableDictionary *dataDic=[resposeDic objectForKey:@"data"];
                     if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                     {
                         // tel is null
                     }
                     else{
                       specialityArr = [[NSMutableArray alloc]init];
                       specialityArr =[dataDic objectForKey:@"specility"];
                         for(int i=0; i<[specialityArr count]; i++)
                         {
                             NSDictionary *dataDic  = specialityArr[i];
                             if (dataDic  != nil && [dataDic  isKindOfClass:[NSDictionary class]])
                             {
                                 NSString*specialityId = dataDic[@"speciality_id"];
                                 NSString*specialityName = dataDic[@"speciality_name"];
                                // NSLog(@"feed Id timeline photo:%@",specialityId);
                                // NSLog(@"feed Url timeline:%@",specialityName);
                                // NSLog(@"data get for feed timeline:%@",dataDic);
                             }
                         }
                        // NSLog(@"data get for feed timeline:%@",dataDic);
                     }
                     // NSLog(@"data get for feed timeline:%@",dataDic);
                 }
                 //timeline Data Entry End
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 9)
                 {
                     [[AppDelegate appDelegate] logOut];
                 }
                 else  if([[resposeDic valueForKey:@"status"]integerValue] == 11)
                 {
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 5)
                 {
                     [[AppDelegate appDelegate]ShowPopupScreen];
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 0)
                 {
               }
             }
         }
     }];
}

#pragma mark - setFeedPostRequestWithAuthKey
-(void)setFeedPostRequestWithAuthkey:(NSString*)post_type feed_title:(NSString*)feed_title feed_content:(NSString*)feed_content file_type:(NSString*)file_type file_url:(NSString*)file_url association_id:(NSString*)association_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url video_image_url:(NSString*)videoImgUrl {
     NSString* josn_specialityId;
      if (self.specialityTagTF.text.length!=0) {
           NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Arr_specialityId options:NSJSONWritingPrettyPrinted error:&error];
        josn_specialityId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        josn_specialityId = [[josn_specialityId componentsSeparatedByCharactersInSet:unwantedChars]componentsJoinedByString: @""];
      }
    NSString *metaArr = [rawdataAr description];
    if ([metaArr isEqualToString:@"(\n)"]) {
        metaArr = @"";
    }
     if((isAttachment = YES)){
        originalFileName = originalFileName.mutableCopy;
    }
    else
    {
        originalFileName = @"";
    }
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetPostFeedWithAuthKey:[userPref valueForKey:userAuthKey] title:feed_title content:feed_content feed_type:@"association" file_type:file_type?file_type:@"" file_url:file_url?file_url:@""  feed_type_id:association_id feed_kind:feed_kind meta_url:meta_url?meta_url:@"" video_image_url:videoImgUrl?videoImgUrl:@"" file_name:originalFileName?originalFileName:@"" file_description:@"" classification:@"" meta_array:metaArr?metaArr:@"" speciality_json_array:josn_specialityId?josn_specialityId:@"" device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
      {
          [[AppDelegate appDelegate] hideIndicator];
          NSDictionary *resposeCode=[responseObject objectForKey:@"posts"];
          if ([responseObject isKindOfClass:[NSNull class]] || !(responseObject.count))
          {
              self.MetaDataView.hidden = YES;
              [self removeAttachedMetaObject];
          }
          else if([[resposeCode allKeys]containsObject:@"meta"])
          {
          }
          else if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
          {
              //resposeCode is null
              [[NSNotificationCenter defaultCenter]postNotificationName:@"docquitySetFeedUploaded" object:self];
              [AppDelegate appDelegate].isMetaData = NO;
              [self dismissViewControllerAnimated:YES completion:nil];
          }
          else {
              NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
              if([[resposeCode valueForKey:@"status"]integerValue] == 1)
              {
                  [AppDelegate appDelegate].isbackFromPostFeed = YES;
                  [AppDelegate appDelegate].isMetaData = NO;
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"docquitySetFeedUploaded" object:self];
                  [self dismissViewControllerAnimated:YES completion:nil];
              }
              else  if([[resposeCode valueForKey:@"status"]integerValue] == 9)
              {
                  [[AppDelegate appDelegate] logOut];
              }
              else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
              {
                  NSString*userValidateCheck = @"readonly";
                  NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                  [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                  NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                  [userpref synchronize];
                  if ([u_permissionstus isEqualToString:@"readonly"]) {
                      [self getcheckedUserPermissionData];
                  }
              }
              else{
                  [UIAppDelegate alerMassegeWithError:[NSString stringWithFormat:@"%@ for post feed.",message] withButtonTitle:OK_STRING autoDismissFlag:NO];
              }
          }
     }];
}

#pragma mark - setEditFeedPostRequestWithAuthKey
-(void)setEditFeedPostRequestWithAuthkey:(NSString*)feedId post_type:(NSString*)post_type feed_title:(NSString*)feed_title feed_content:(NSString*)feed_content file_type:(NSString*)file_type  file_url:(NSString*)file_url association_id:(NSString*)association_id feed_kind:(NSString*)feed_kind meta_url:(NSString*)meta_url video_image_url:(NSString*)videoImgUrl
{
    NSString* josn_specialityId;
    if (self.specialityTagTF.text.length!=0) {
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Arr_specialityId options:NSJSONWritingPrettyPrinted error:&error];
        josn_specialityId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        josn_specialityId = [[josn_specialityId componentsSeparatedByCharactersInSet:unwantedChars]componentsJoinedByString: @""];
    }
    NSString *metaArr = [rawdataAr description];
    if ([metaArr isEqualToString:@"(\n)"]) {
        metaArr = @"";
    }

    if([[self.FeedInformation valueForKey:@"file_type"]isEqualToString:@"document"]){
        originalFileName = originalFileName.mutableCopy;
    }
    else
    {
        originalFileName = @"";
    }
    
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetEditFeedWithAuthKey:[userPref valueForKey:userAuthKey] feed_id:feedId title:feed_title content:feed_content feed_type:@"association" file_type:file_type?file_type:@"" file_url:file_url?file_url:@""  feed_type_id:association_id feed_kind:feed_kind meta_url:meta_url?meta_url:@"" video_image_url:videoImgUrl?videoImgUrl:@"" file_name:originalFileName?originalFileName:@"" file_description:@"" classification:@"" meta_array:metaArr?metaArr:@"" speciality_json_array:josn_specialityId?josn_specialityId:@"" device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
       {
         [[AppDelegate appDelegate] hideIndicator];
         NSDictionary *resposeCode=[responseObject objectForKey:@"posts"];
         if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
         {
             //resposeCode is null
         }
         else {
             NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
             
             if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                 
                 [AppDelegate appDelegate].isbackFromPostFeed = YES;
                 [AppDelegate appDelegate].isMetaData = NO;
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"docquitySetFeedUploaded" object:self];
                 [self dismissViewControllerAnimated:YES completion:nil];
             }
             else  if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                 
                 [[AppDelegate appDelegate] logOut];
             }
             else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
             {
                 NSString*userValidateCheck = @"readonly";
                 NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                 [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                 [userpref synchronize];
                 NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                 if ([u_permissionstus isEqualToString:@"readonly"]) {
                     [self getcheckedUserPermissionData];
                 }
             }
             else{
                 [UIAppDelegate alerMassegeWithError:message withButtonTitle:OK_STRING autoDismissFlag:NO];
                 [self PostBtnActivate:YES];
             }
         }
     }];
}

#pragma mark - getMetaViewRequest
-(void)getMetaViewRequestWithAuthkey:(NSString*)meta_urlAddress {
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]GetMetaPreviewWithAuthKey:[userPref valueForKey:userAuthKey] meta_url:meta_urlAddress type_for:@"feed" device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
        // NSLog(@"responseObject get metaView:%@",responseObject);
         [[AppDelegate appDelegate] hideIndicator];
         
         if ([responseObject isKindOfClass:[NSNull class]] || !(responseObject.count))
         {
             // tel is null
             // NSLog(@"Null Response here");
             self.MetaDataView.hidden = YES;
             [self removeAttachedMetaObject];
          }
         else{
         NSDictionary *postdic =[responseObject objectForKey:@"posts"];
         if ([postdic isKindOfClass:[NSNull class]]|| postdic == nil)
         {
             // tel is null
             //  NSLog(@"Null resposeCode here");
         }
         else {
             
             NSDictionary *datadic =[postdic objectForKey:@"data"];
             if ([datadic isKindOfClass:[NSNull class]]|| datadic == nil)
             {
                 // tel is null
                 //  NSLog(@"Null resposeCode here");
             }
             else {
                if([[postdic  valueForKey:@"status"]integerValue] == 1){
                 //[AppDelegate appDelegate].isMetaData =YES;
                 metaContent =  [NSString stringWithFormat:@"%@",[datadic objectForKey:@"meta"]?[datadic objectForKey:@"meta"]:@""];
                 metaContent = [metaContent stringByDecodingHTMLEntities];
                 metaDataWv.opaque = NO;
                 [metaDataWv.scrollView setScrollEnabled:NO];
                 CGRect rect;
                 
                 metaDataWv.backgroundColor = [UIColor whiteColor];
                 rect = metaDataWv.frame;
                 rect.size.height = 2;
                 metaDataWv.frame = rect;
                 [metaDataWv loadHTMLString:metaContent baseURL:nil];
                 NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                 [userpref setObject:metaContent?metaContent:@"" forKey:feedFileURL];
                 [userpref synchronize];
                 [self hideToolbar:YES];
                 rawdataAr = [[NSArray alloc]init];
                 rawdataAr  = [datadic valueForKey:@"rawmeta"];
                // [userpref setObject:rawdataArr?rawdataArr:@"" forKey:@"metaArr"];
                // [userpref synchronize];
                 NSMutableDictionary *rawdata = [datadic valueForKey:@"rawmeta"];
                 self.LblMetaTitle.text = [[rawdata valueForKey:@"title"]isEqualToString:@""]?ogUrl:[[rawdata valueForKey:@"title"]stringByDecodingHTMLEntities];
                 self.LblMetaDesc.text = [[rawdata valueForKey:@"description"] stringByDecodingHTMLEntities];
                 self.LblMetaUrl.text = [rawdata valueForKey:@"pageUrl"];
                 BOOL img = TRUE;
                 if ([[rawdata objectForKey:@"images"] isKindOfClass:[NSNumber class]])
                 {
                     if([[rawdata objectForKey:@"images"] isEqual:[NSNumber numberWithBool:NO]])
                     {
                         img = NO;
                     }
                 }
                 if (!img && [[rawdata valueForKey:@"description"]isEqualToString:@""]) {
                     [self completedMetaShowByConditionWithImage:false Description:false];
                 }else if (!img && ![[rawdata valueForKey:@"description"]isEqualToString:@""]){
                     [self completedMetaShowByConditionWithImage:false Description:true];
                 }else if (img && ![[rawdata valueForKey:@"description"]isEqualToString:@""]){
                     [self completedMetaShowByConditionWithImage:true Description:true];
                     [self.imgMeta sd_setImageWithURL:[NSURL URLWithString:[rawdata valueForKey:@"images"]] placeholderImage:[UIImage imageNamed:@"img-not.png"]options:SDWebImageRefreshCached];
                 }else if (img && [[rawdata valueForKey:@"description"]isEqualToString:@""]){
                     [self completedMetaShowByConditionWithImage:true Description:false];
                     [self.imgMeta sd_setImageWithURL:[NSURL URLWithString:[rawdata valueForKey:@"images"]] placeholderImage:[UIImage imageNamed:@"img-not.png"]options:SDWebImageRefreshCached];
                 }
             }
             else if([[postdic  valueForKey:@"status"]integerValue] == 9){
                 [[AppDelegate appDelegate] logOut];
             }
             else  if([[postdic valueForKey:@"status"]integerValue] == 11)
             {
                 NSString*userValidateCheck = @"readonly";
                 NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                 [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                 [userpref synchronize];
                 NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                 if ([u_permissionstus isEqualToString:@"readonly"]) {
                     [self getcheckedUserPermissionData];
                 }
             }
             else{
                 [AppDelegate appDelegate].isMetaData =NO;
             }
           }
         }
         }
     }];
}


@end
