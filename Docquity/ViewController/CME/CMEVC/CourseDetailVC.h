//
//  CourseDetailVC.h
//  Docquity
//
//  Created by Docquity-iOS on 07/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "BSProgressButtonView.h"
#import "CourseModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
@interface CourseDetailVC : UIViewController<UIWebViewDelegate,MFMailComposeViewControllerDelegate>{
    NSArray *dbResult;
    NSArray *dbSpecResult;
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray *imgArrForWebview;
    NSMutableArray *queArr;
    NSArray *dbOptResult;
    NSArray *dbQueResult;
    BOOL isOfflineSolve;
    NSString *permstus;
    BOOL checkVerify;
}
@property(nonatomic, assign)id delegate;
@property (weak, nonatomic) IBOutlet UIImageView *img_asso;
@property (weak, nonatomic) IBOutlet UIButton *btn_Transcript;
@property (weak, nonatomic) IBOutlet BSProgressButtonView *ProgressButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintsForImageViewDetails;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintsForBottomButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomMarginConstraintsForScrollview;
@property (weak, nonatomic) IBOutlet UILabel *lbl_status;
@property (weak, nonatomic) IBOutlet UILabel *course_association;
@property (weak, nonatomic) IBOutlet UILabel *lbl_course_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_course_summary;
@property (weak, nonatomic) IBOutlet UIImageView *img_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Course_Point;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Seperator;
@property (weak, nonatomic) IBOutlet UILabel *lbl_course_expiry;
@property (weak, nonatomic) IBOutlet UIImageView *img_Course;
@property (weak, nonatomic) IBOutlet UIWebView *course_detail_webview;
@property (weak, nonatomic) IBOutlet UIButton *btnSolve;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstant;
@property (weak, nonatomic) IBOutlet UIImageView *img_pdf_thumnail;
@property (weak, nonatomic) IBOutlet UIView *pdfViewholder;
@property (weak, nonatomic) IBOutlet UILabel *pfd_name;
@property (weak, nonatomic) IBOutlet UIView *pdf_main_view;
@property (weak, nonatomic) IBOutlet UIButton *btn_pdfopen;
@property (weak, nonatomic) IBOutlet UILabel *lbl_totalPage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintsPDFView;
@property (nonatomic, strong) NSMutableString *dataPath;
@property (nonatomic, strong) NSString *coursePoint;
@property (nonatomic, strong) NSString *courseExpire;
@property (nonatomic, strong) NSString *lessionID;
@property (nonatomic, strong) NSString *isSample;
@property (nonatomic, strong) CourseModel *model;
@property (nonatomic, strong) NSString *isShowdownloadedData;
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSMutableArray <CourseModel *> *fetchdata;
@property (nonatomic, strong) NSMutableArray <QuesModel *> *quesDataModel;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic) BOOL btnShow;
@property (nonatomic) BOOL isNoifPView;
@end
@protocol senddata <NSObject>
-(void) updateCMEListing:(CourseModel*)model;
@end
@protocol CourseDetail
-(void)DidGoToBack;
@end
