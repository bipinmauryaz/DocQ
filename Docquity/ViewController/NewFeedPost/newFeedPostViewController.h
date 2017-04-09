/*============================================================================
 PROJECT: Docquity
 FILE:    newFeedPostViewController.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 22/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "Server.h"
#import "Localytics.h"
#import "ELCImagePickerController.h"
#import "ELCImagePickerHeader.h"
#import "HWViewPager.h"
#import "HDMultiPartImageUpload.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UserTimelineVC.h"

static const int defaultChunkSize = 2097152;
@interface newFeedPostViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,ServerRequestFinishedProtocol,UIPopoverControllerDelegate,UIAlertViewDelegate,ELCImagePickerControllerDelegate,UICollectionViewDataSource,HWViewPagerDelegate,AKVideoUploadFinishProtocol,UIDocumentPickerDelegate,UIDocumentMenuDelegate>{
    BOOL isKeyboardAppear,isVideo,isAttachment,metaViewAppeared,isImage,isUpdateImage,isPDFAttachment;
    UIImage *chosenImage;
    NSString *u_ImgType,*base64EncodedString;
    NSMutableArray *blockurl;
    NSString *ogUrl,*pickedAssoID,*encodedString;
    NSInteger count;
    NSString*pickedSpecialityID;
    NSTimer *timer;
    NSData *vidData;
    NSData *fileData;
    ServerRequestType1 currentRequestType;
    NSString *fileType, *metaContent,*fileUrl;
    UIProgressView * progressView;
    NSURL *urlvideo;
    NSInteger imgRetryCount;
    UIButton *btnCapture ,*btnDone;
    NSInteger maximumImageClick;
    NSString *originalFileName;
    NSMutableArray *Arr_specialityId;
    NSMutableArray *SpecialityArrList;
    NSMutableArray *specialityArr;
    NSMutableArray *specSelectedMainArray;
    
    NSMutableArray *Arr_associationId;
    NSMutableArray *AssociationArrList;
    NSMutableArray *associationArr;
    NSMutableArray *assoSelectedMainArray;
    IBOutlet UILabel*lbl_navheaderTitle;
    NSMutableArray *myNewfeedAssociationList;
}

@property(nonatomic,strong)NSMutableArray *myNewfeedAssociationList;
@property (strong, nonatomic) NSString *file_Name;
@property (strong, nonatomic) NSString *restorationIdentifier;
@property (strong, nonatomic) NSString *originalFilePath;
@property (strong, nonatomic) IBOutlet UISegmentedControl *SegmentFeedOption;
@property (strong, nonatomic) IBOutlet UIView *MetaDataView;
@property (strong, nonatomic) IBOutlet UIImageView *imgMeta;
@property (strong, nonatomic) IBOutlet UILabel *LblMetaTitle;
@property (strong, nonatomic) IBOutlet UILabel *LblMetaDesc;
@property (strong, nonatomic) IBOutlet UILabel *LblMetaUrl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *MetaLoader;
@property (strong, nonatomic) IBOutlet UIButton *BtnSelection;
@property (strong, nonatomic) IBOutlet HWViewPager *viewPager;
@property (strong, nonatomic) IBOutlet UIImageView *ImgSelectedAsso;
@property (strong, nonatomic) IBOutlet UIWebView *metaDataWv;
@property (strong, nonatomic) IBOutlet UITextField *specialityTagTF;
@property (strong, nonatomic) IBOutlet UITextField *postTypeTF;
@property (strong, nonatomic) IBOutlet UIButton *postBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *Scrollview;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *AssociationView;
@property (strong, nonatomic) IBOutlet UILabel *PlaceHolder;
@property (strong, nonatomic) IBOutlet UIView *AttachmentView;
@property (strong, nonatomic) IBOutlet UITextView *ContentTextView;
@property (strong, nonatomic) IBOutlet UITextField *TitleTextField;
@property (strong, nonatomic) NSMutableDictionary *FeedInformation;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic,assign) int oneChunkSize;
@property (weak, nonatomic) IBOutlet UIView *pdfAttachmentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnailpdf;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel_pdf;
@property (weak, nonatomic) IBOutlet UIImageView *img_document_type;
@property (weak, nonatomic) IBOutlet UILabel *lbl_File_name;
@property (weak, nonatomic) IBOutlet UIView *pdf_nameViewholder;

@property(nonatomic) BOOL isEditFeed;
@property(nonatomic) BOOL isTrends;
@property(nonatomic, assign) UserTimelineVC *userTimeline;
- (void)imagesPickingFinish:(NSMutableArray*)arrImages;

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressPdfCancel:(id)sender;

@end
