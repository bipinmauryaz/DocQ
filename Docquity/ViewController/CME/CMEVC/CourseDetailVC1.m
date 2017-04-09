//
//  CourseDetailVC.m
//  Docquity
//
//  Created by Docquity-iOS on 07/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "CourseDetailVC.h"
#import "DefineAndConstants.h"
#import "NSString+GetRelativeTime.h"
#import "CMEExamVC.h"
#import "NSString+HTML.h"
#import "UIImageView+WebCache.h"
#import "DocquityServerEngine.h"
#import "ZipArchive.h"
#import <AVFoundation/AVFoundation.h>
#import "CAPSPhotoView.h"
#import "Localytics.h"
#import "WebVC.h"
#import "AppDelegate.h"
#import "AvailableCourseVC.h"
@interface CourseDetailVC ()<BSProgressButtonViewDelegate>
{
    CAPSPhotoView *photoView;
}

@end

@implementation CourseDetailVC
@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    isOfflineSolve = FALSE;
    imgArrForWebview = [[NSMutableArray alloc]init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    [self createDirectory:[NSString stringWithFormat:@"CME/%@",self.model.lesson_id]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.title = @"Course Details";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.lbl_status.layer.cornerRadius = 4.0;
    self.lbl_status.layer.masksToBounds = YES;
    self.ProgressButton.hidden = false;
    self.ProgressButton.delegate = self;
    self.ProgressButton.bgViewColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height) dateTitle:@""
                                               title:self.model.lesson_name
                                            subtitle:self.model.lesson_summary];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapped)];
    gesture.numberOfTapsRequired = 1.0;
    [_img_Course addGestureRecognizer:gesture];
    if(!_btnShow){
        self.HeightConstraintsForBottomButton.constant  = 0;
        self.BottomMarginConstraintsForScrollview.constant = 0;
    }else{
        [self setLeftBarBtn];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [Localytics tagEvent:@"CME Course Details"];
    if([_isShowdownloadedData isEqualToString:@"1"]){
        [self loadData];
    }else{
        if (![self.lbl_status.text containsString:@"Complete"]) {
            [self setSuscribeCourseRequest:self.model WithType:@"preview"];
        }
        
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [delegate updateCMEListing:self.model];
    if (![self.lbl_status.text containsString:@"Complete"]) {
        _isShowdownloadedData = @"1";
    }
    
}

#pragma mark - Load Data
-(void)loadData{
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT _id,association_name,course_code,expiry_date,lesson_id,lesson_name,lesson_summary,lesson_description,date_of_creation,total_points,specialities_Ids,isDownload,subcription,file_type,file_url,resouce_file_name,document_name,remarks,pdf_result_url,exam_association,association FROM cme_lesson WHERE lesson_id = %@",self.lessionID];
    if (dbResult != nil) {
        dbResult = nil;
    }
    dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    NSLog(@"dbresult = %@",dbResult);
    
    
    NSInteger  indexOfAssoName = [self.dbManager.arrColumnNames indexOfObject:@"association_name"];
    NSInteger  indexOfCCode = [self.dbManager.arrColumnNames indexOfObject:@"course_code"];
    NSInteger  indexOfExpiryDate = [self.dbManager.arrColumnNames indexOfObject:@"expiry_date"];
    NSInteger  indexOfLID = [self.dbManager.arrColumnNames indexOfObject:@"lesson_id"];
    NSInteger  indexOfLname = [self.dbManager.arrColumnNames indexOfObject:@"lesson_name"];
    NSInteger  indexOfLSummary = [self.dbManager.arrColumnNames indexOfObject:@"lesson_summary"];
    NSInteger  indexOfDOC = [self.dbManager.arrColumnNames indexOfObject:@"date_of_creation"];
    NSInteger  indexOfPoints= [self.dbManager.arrColumnNames indexOfObject:@"total_points"];
    NSInteger  indexOfSpIDs = [self.dbManager.arrColumnNames indexOfObject:@"specialities_Ids"];
    NSInteger  indexOfDownload = [self.dbManager.arrColumnNames indexOfObject:@"isDownload"];
    NSInteger  indexOfSubcription = [self.dbManager.arrColumnNames indexOfObject:@"subcription"];
    NSInteger  indexOfLessonDesc = [self.dbManager.arrColumnNames indexOfObject:@"lesson_description"];
    NSInteger  indexOfFileType = [self.dbManager.arrColumnNames indexOfObject:@"file_type"];
    NSInteger  indexOfFileUrl = [self.dbManager.arrColumnNames indexOfObject:@"file_url"];
    NSInteger  indexOfResouceFname = [self.dbManager.arrColumnNames indexOfObject:@"resouce_file_name"];
    NSInteger  indexOfDocName = [self.dbManager.arrColumnNames indexOfObject:@"document_name"];
    NSInteger  indexOfRemark = [self.dbManager.arrColumnNames indexOfObject:@"remarks"];
    NSInteger  indexOfPdfurl = [self.dbManager.arrColumnNames indexOfObject:@"pdf_result_url"];
    NSInteger  indexOfExAsso = [self.dbManager.arrColumnNames indexOfObject:@"exam_association"];
    NSInteger  indexOfAssoid = [self.dbManager.arrColumnNames indexOfObject:@"association"];
    if(_fetchdata == nil) {
        _fetchdata = [NSMutableArray array];
    }
    
    if(self.model == nil){
        self.model = [CourseModel new];
    }
    
    
    for(NSArray *arr in dbResult){
        CourseModel *courseModel        =   [CourseModel new];
        courseModel.association_name    =   [arr objectAtIndex:indexOfAssoName];
        courseModel.course_code         =   [arr objectAtIndex:indexOfCCode];
        courseModel.expiry_date         =   [arr objectAtIndex:indexOfExpiryDate];
        courseModel.lesson_id           =   [arr objectAtIndex:indexOfLID];
        courseModel.lesson_name         =   [arr objectAtIndex:indexOfLname];
        courseModel.lesson_summary      =   [arr objectAtIndex:indexOfLSummary];
        courseModel.lesson_description  =   [arr objectAtIndex:indexOfLessonDesc];
        courseModel.date_of_creation 	=   [arr objectAtIndex:indexOfDOC];
        courseModel.total_points        =   [arr objectAtIndex:indexOfPoints];
        courseModel.subcription         =   [arr objectAtIndex:indexOfSubcription];
        courseModel.isDownload          =   [arr objectAtIndex:indexOfDownload];
        courseModel.file_url            =   [arr objectAtIndex:indexOfFileUrl];
        courseModel.file_type           =   [arr objectAtIndex:indexOfFileType];
        courseModel.resouceFname        =   [arr objectAtIndex:indexOfResouceFname];
        courseModel.documentName        =   [arr objectAtIndex:indexOfDocName];
        courseModel.remark              =   [arr objectAtIndex:indexOfRemark];
        courseModel.pdf_result_url      =   [arr objectAtIndex:indexOfPdfurl];
        self.model.lesson_id            =   [arr objectAtIndex:indexOfLID];
        self.model.lesson_name          =   [arr objectAtIndex:indexOfLname];
        self.model.file_url             =   [arr objectAtIndex:indexOfFileUrl];
        self.model.documentName         =   [arr objectAtIndex:indexOfDocName];
        self.model.resouceFname         =   [arr objectAtIndex:indexOfResouceFname];
        self.model.remark               =   [arr objectAtIndex:indexOfRemark];
        self.model.examAssoid           =   [arr objectAtIndex:indexOfExAsso];
        self.model.pdf_result_url       =   [arr objectAtIndex:indexOfPdfurl];
        self.model.association_ids      =   [arr objectAtIndex:indexOfAssoid];
        NSString *spid                  =   [arr objectAtIndex:indexOfSpIDs];
        NSArray *spArray = [[NSArray alloc]init];
        spArray = [spid componentsSeparatedByString:@","];
        for (NSString *str in spArray){
            if(courseModel.speciality_names == nil){
                courseModel.speciality_names = [NSString stringWithFormat:@"%@",[self specialityNameBasedOnSpecialityID:str]];
            }else{
                courseModel.speciality_names = [NSString stringWithFormat:@"%@, %@",courseModel.speciality_names,[self specialityNameBasedOnSpecialityID:str]];
            }
        }
//        if([courseModel.isDownload isEqualToString:@"0"]){
//            [self setSuscribeCourseRequest:self.model WithType:@"preview"];
//            return;
//            
//        }
    
        [self reloadView:courseModel];
    }
    
}



-(NSString *)specialityNameBasedOnSpecialityID:(NSString*)spid{
    NSString *selectSpecialityQuery = [NSString stringWithFormat:@"SELECT _id,speciality_id,speciality_name FROM speciality WHERE speciality_id = '%@'",spid];
    if (dbSpecResult != nil) {
        dbSpecResult = nil;
    }
    dbSpecResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectSpecialityQuery]];
    NSInteger  indexOfSpecName = [self.dbManager.arrColumnNames indexOfObject:@"speciality_name"];
    return [[dbSpecResult objectAtIndex:0]objectAtIndex:indexOfSpecName];
}

-(void)reloadView:(CourseModel*)courseModel{
    [self backGroundClear];
    self.lessionID = courseModel.lesson_id;
    self.coursePoint = courseModel.total_points;
    self.courseExpire = courseModel.expiry_date;
    self.course_association.text = [NSString stringWithFormat:@"%@ accredited",courseModel.association_name];
    self.lbl_course_summary.text = courseModel.lesson_summary;
    self.lbl_course_title.text = courseModel.lesson_name;
    self.lbl_Course_Point.text = [NSString stringWithFormat:@"Points: %@",self.coursePoint];
    self.lbl_course_expiry.text = [NSString stringWithFormat:@"Expires on : %@",[NSString setUpdateTimewithString:self.courseExpire]];
    self.lbl_course_expiry.textColor = kFontDeactivateColor;
    self.lbl_Seperator.backgroundColor = kFontDeactivateColor;
    self.lbl_speciality.textColor = kFontDescColor;
    self.lbl_course_title.textColor = kFontTitleColor;
    self.lbl_course_summary.textColor = kFontDescColor;
    self.lbl_Course_Point.textColor = kThemeColor;
    self.course_association.textColor = kFontDescColor;
    self.lbl_speciality.text = [courseModel.speciality_names stringByDecodingHTMLEntities];
    self.course_detail_webview.backgroundColor = [UIColor clearColor];
    self.img_speciality.image = [UIImage imageNamed:@"plus_default.png"];
    [self.img_asso sd_setImageWithURL:[NSURL URLWithString:courseModel.association_pic] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
   // self.img_Course.image = [UIImage imageNamed: @"img-not.png"];
    if ([courseModel.lesson_description isEqualToString:@""]) {
        self.course_detail_webview.hidden = YES;
    }else{
        self.course_detail_webview.hidden = NO;
        if([self.isShowdownloadedData isEqualToString:@"1"] && [courseModel.isDownload isEqualToString: @"1"]){
          __block  NSString *htmlString = [NSString stringWithFormat:@"<font face='Helvetica'>%@</font>", courseModel.lesson_description];
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            
            [regex enumerateMatchesInString:htmlString
                                    options:0
                                      range:NSMakeRange(0, [htmlString length])
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     NSString *imgUrl = [htmlString substringWithRange:[result rangeAtIndex:2]];
                                     
                                     [imgArrForWebview addObject:imgUrl];
                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                         NSArray *parts = [imgUrl componentsSeparatedByString:@"/"];
                                         NSString *filename = [self getFileNameFromURL:imgUrl];
                                         
                                         NSURL *filepathurl = [NSURL fileURLWithPath:[[self cmeLessonLocalPathForFile:courseModel.resouceFname] stringByAppendingPathComponent:filename]];
                                         
                                         NSLog(@"filepathurl = %@",filepathurl);
                                         htmlString = [htmlString stringByReplacingOccurrencesOfString:imgUrl withString:[NSString stringWithFormat:@"%@",filepathurl]];
                                        
//                                        [self.course_detail_webview loadHTMLString:htmlString baseURL: nil];
                                     });
                                    
                                     
                                 }];
           [self.course_detail_webview loadHTMLString:htmlString baseURL: nil];
            
        }else{
            NSString *htmlString = [NSString stringWithFormat:@"<font face='Helvetica'>%@</font>", courseModel.lesson_description];
             [self.course_detail_webview loadHTMLString:htmlString baseURL: nil];
        }
    }
   
    if([courseModel.file_type isEqualToString:@"video"]){
        [self hidePdfView:true];
        if([self.isShowdownloadedData isEqualToString:@"1"]){
            self.img_Course.image = [self getImageFor:@"video"];
        }else{
            [self saveImage:[self loadThumbNail:courseModel.file_url]];
            self.img_Course.image = [self getImageFor:@"video"];
        }
        self.img_Course.contentMode = UIViewContentModeScaleAspectFill;
        self.img_Course.layer.masksToBounds = YES;
    } else if([courseModel.file_type isEqualToString:@"image"]){
        [self hidePdfView:YES];
        if([self.isShowdownloadedData isEqualToString:@"1"] && [courseModel.isDownload isEqualToString:@"1"]){
            [self downloadImageFile:courseModel.file_url documentDirURL:[NSString stringWithFormat:@"CME/%@",courseModel.lesson_id]];
            self.img_Course.image = [UIImage imageNamed:@"img-not.png"];
        }else{
            
            [self.img_Course sd_setImageWithURL:[NSURL URLWithString:courseModel.file_url] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
        }
        self.img_Course.contentMode = UIViewContentModeScaleAspectFill;
        self.img_Course.layer.masksToBounds = YES;
    }
    else if([courseModel.file_type isEqualToString:@"document"]){
        [self hidePdfView:NO];
        self.pdf_main_view.backgroundColor = kThemeColor;
        self.pdfViewholder.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        self.pfd_name.text = courseModel.documentName;
        NSString *type = [courseModel.documentName pathExtension];
        NSString* name = [courseModel.documentName stringByReplacingOccurrencesOfString:type withString:@""];
        name = [courseModel.documentName substringToIndex:name.length-(name.length>0)];
        self.pfd_name.text = name;
        
        if([self.isShowdownloadedData isEqualToString:@"1"])
        {
            NSString *filepath = [self cmeLessonLocalPathForFile:courseModel.resouceFname];
            [self saveImage:[self pdfThumbnail:[filepath stringByAppendingPathComponent:[self getFileNameFromURL:courseModel.file_url]]]];
            self.img_pdf_thumnail.image = [self getImageFor:@"pdf"];
            self.img_pdf_thumnail.contentMode = UIViewContentModeScaleAspectFill;
            self.img_pdf_thumnail.layer.masksToBounds = YES;
            self.pfd_name.text = courseModel.documentName;
            self.lbl_totalPage.hidden = ![courseModel.isDownload isEqualToString:@"1"];
            if(self.model.documentTPage.integerValue > 1){
            self.lbl_totalPage.text = [NSString stringWithFormat:@"%@ pages",self.model.documentTPage];
            }else{
                self.lbl_totalPage.text = [NSString stringWithFormat:@"%@ page",self.model.documentTPage];
            }
            
        }else
        {
            [self saveImage:[self pdfThumbnail:courseModel.file_url]];
            self.img_Course.image = [self getImageFor:@"pdf"];
            self.lbl_totalPage.hidden = YES;
        }

    }else{
        self.HeightConstraintsForImageViewDetails.constant = 0;
        self.HeightConstraintsPDFView.constant = 0;
    }
    
    //Remarks
     [self.btnSolve setTitle:@"Solve Online" forState:UIControlStateNormal];
    self.lbl_status.hidden = NO;
    [self showTranscriptBtn:NO];
    [self.lbl_status setHidden:NO];
    if([self isCourseExpire:courseModel.expiry_date]){
        self.lbl_status.backgroundColor = kFontDescColor;
        [self.lbl_status setText:@"Expired"];
    }else if([courseModel.remark containsString:@"pass"]){
        self.lbl_status.backgroundColor = kCOAColor;
        self.lbl_status.text = @"Completed";
        [self showTranscriptBtn:YES];
        self.model.isSubmitted = @"1";
        self.model.remark = @"passed";
    }else if([courseModel.remark containsString:@"fail"]){
        self.lbl_status.backgroundColor = [UIColor redColor];
        self.lbl_status.text = @"Not Passed";
        self.model.isSubmitted = @"1";
        self.model.remark = @"failed";
         [self.btnSolve setTitle:@"Retake Online" forState:UIControlStateNormal];
    }else if([courseModel.remark containsString:@"Submit"]){
        self.lbl_status.backgroundColor = kYellowColor;
        self.lbl_status.text = @"Submitted";
        [self showTranscriptBtn:YES];
        self.btnSolve.hidden = YES;
        self.HeightConstraintsForBottomButton.constant  = 0;
        self.BottomMarginConstraintsForScrollview.constant = 0;
        self.model.isSubmitted = @"2";
    }else{
        self.lbl_status.hidden = YES;
    }
    
    if([courseModel.isDownload isEqualToString:@"0"] || [courseModel.isDownload isEqualToString:@""] || courseModel.isDownload == nil){
        self.ProgressButton.bgViewColor = korangeColor;
        _ProgressButton.text = @"Save & Solve later";
        UITapGestureRecognizer *downloadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downloadStart)];
        downloadTap.numberOfTapsRequired = 1.0;
        [_ProgressButton addGestureRecognizer:downloadTap];
    }else{
        self.ProgressButton.bgViewColor = kCOAColor;
        UITapGestureRecognizer *solveTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(StartTest)];
        solveTap.numberOfTapsRequired = 1.0;
        [_ProgressButton addGestureRecognizer:solveTap];
        if([self.lbl_status.text isEqualToString:@"Not Passed"]){
            _ProgressButton.text = @"Retake Offline";
        }else {
            _ProgressButton.text = @"Solve Offline";
        }
    }
}

-(void)showTranscriptBtn:(BOOL)show{
    self.btnSolve.hidden = show;
    self.ProgressButton.hidden = show;
    self.btn_Transcript.hidden = !show;
}

-(void)backGroundClear{
    self.lbl_Seperator.hidden                   =   false;
    self.course_association.backgroundColor     =   [UIColor whiteColor];
    self.lbl_course_title.backgroundColor       =   [UIColor whiteColor];
    self.lbl_course_summary.backgroundColor     =   [UIColor whiteColor];
    self.lbl_speciality.backgroundColor         =   [UIColor whiteColor];
    self.lbl_Course_Point.backgroundColor       =   [UIColor whiteColor];
    self.lbl_course_expiry.backgroundColor      =   [UIColor whiteColor];
    self.ProgressButton.hidden                  =   false;
    self.btnSolve.hidden                        =   false;
    self.btnSolve.enabled                       =   true;
    self.ProgressButton.bgViewColor             =   korangeColor;
    self.btnSolve.backgroundColor               =   kThemeColor;
    [self.ProgressButton setCompletionButtonDidNonActiveBlock:^{
        self.ProgressButton.bgViewColor = korangeColor;
        _ProgressButton.text = @"Save & Solve later";
    }];
    
    [self.ProgressButton setCompletionButtonDidActiveBlock:^{
        self.ProgressButton.bgViewColor = kCOAColor;
        _ProgressButton.text = @"Solve Offline";
        
  
    }];
}

-(void)completionButtonAction{
    NSLog(@"completionButtonAction");
    [self StartTest];
}


-(void)hidePdfView:(BOOL)hidden{
    self.pdf_main_view.hidden = hidden;
    self.img_pdf_thumnail.hidden = hidden;
    self.pdfViewholder.hidden = hidden;
    self.btn_pdfopen.hidden = hidden;
    self.lbl_totalPage.hidden = hidden;
    self.img_Course.hidden = !hidden;
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *SourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSString *padding = @"document.body.style.margin='0';document.body.style.padding = '0'";
    [webView stringByEvaluatingJavaScriptFromString:padding];
    self.course_detail_webview.scrollView.scrollEnabled = NO;
    self.webViewHeightConstant.constant = webView.scrollView.contentSize.height;
   // NSLog(@"new html : %@",SourceCodeString);
}

-(NSString*)cmeLessonLocalPathForFile:(NSString*)filename{
    NSString *lDirURL = [NSString stringWithFormat:@"CME/%@",self.lessionID];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
    
    NSString *fullPath = [lessonPath stringByAppendingPathComponent:filename];
    
    return fullPath;

}

-(BOOL)isCourseExpire:(NSString *)expireDate
{
    BOOL expire = false;
    long long int currentTime = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
    if(expireDate.longLongValue < currentTime)
    {
        expire = YES;
     
    }else{
        expire = NO;
    }
    return expire;
}

//////CME Restriction
- (IBAction)solveBtnAction:(id)sender {
    isOfflineSolve = NO;
    [self setSuscribeCourseRequest:self.model WithType:@"download"];
}

//////CME Restriction
-(void)downloadStart{
    
    if([self isCourseExpire:self.model.expiry_date])
    {
        [self singleButtonAlertViewWithAlertTitle:@"CME" message:cmeExpireMsg buttonTitle:@"OK"];
    }
    else
    {
        isOfflineSolve = YES;
        _ProgressButton.text = @"Downloading...";
        [self setSuscribeCourseRequest:self.model WithType:@"download"];
    }
}

//////CME Restriction
-(void)StartTest{
    if([self isCourseExpire:self.model.expiry_date]){
        [self singleButtonAlertViewWithAlertTitle:@"CME" message:cmeExpireMsg buttonTitle:@"OK"];
    }else
    {
        [self loadQuestionData];
    }
}

-(void)pushToExam{
 
    UIStoryboard *NewStoryboard =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CMEExamVC *ExamStart        =   [NewStoryboard instantiateViewControllerWithIdentifier:@"CMEExamVC"];
    ExamStart.count             =   0;
    ExamStart.lessionID         =   self.lessionID;
    ExamStart.resouceFname      =   self.model.resouceFname;
    ExamStart.queArr            =   queArr;
    ExamStart.isOfflineSolve    =   isOfflineSolve;
    ExamStart.courseTitle       =   self.model.lesson_name;
    [self.navigationController pushViewController:ExamStart animated:YES];
}


#pragma mark - Data insert in Model
-(void)CourseModelUpdate:(CourseModel*)courseModel withValue:(NSDictionary*)dic{
    
//  courseModel.association_name    =   [dic valueForKey:@"association_name"];
    courseModel.course_code         =   [dic valueForKey:@"course_code"];
    courseModel.date_of_submission  =   [dic valueForKey:@"date_of_submission"];
    courseModel.expiry_date         =   [dic valueForKey:@"expiry_date"];
    courseModel.file_type           =   [dic valueForKey:@"file_type"];
    courseModel.file_url            =   [dic valueForKey:@"file_url"];
    courseModel.lesson_description  =   [dic valueForKey:@"lesson_description"];
    courseModel.lesson_id           =   [dic valueForKey:@"lesson_id"];
    courseModel.lesson_name         =   [dic valueForKey:@"lesson_name"];
    courseModel.lesson_summary      =   [dic valueForKey:@"lesson_summary"];
    courseModel.date_of_creation 	=   [dic valueForKey:@"start_date"];
    courseModel.total_points        =   [dic valueForKey:@"total_points"];
    courseModel.score               =   [dic valueForKey:@"score"];
    courseModel.remark              =   [dic valueForKey:@"remark"];
    courseModel.resource_url        =   [dic valueForKey:@"resource_url"];
    courseModel.documentName        =   [dic valueForKey:@"document_name"];
    courseModel.accreditation_url   =   [dic valueForKey:@"accreditation_url"];
    
    courseModel.total_user          =   [dic valueForKey:@"number_of_user"];

    
    courseModel.speciality_ids      =   @"";
    courseModel.association_ids     =   @"";
//  _model.documentName             =   [dic valueForKey:@"document_name"];
    NSMutableArray *spAr            =   [dic valueForKey:@"speciality"];
    NSMutableArray *asAr            =   [dic valueForKey:@"association"];

    if([[dic valueForKey:@"thumbnail"]isEqualToString:@""]){
        courseModel.thumbnail           =   @"NA";
    }else{
        courseModel.thumbnail           =   [dic valueForKey:@"thumbnail"];
    }
    
    for (NSDictionary *spclDic in spAr){
        if(courseModel.speciality_ids == nil || [courseModel.speciality_ids isEqualToString:@""]){
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@",[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }else{
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@, %@",courseModel.speciality_ids,[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }
    }
    
    for (NSDictionary *asDic in asAr){
        if(courseModel.association_ids == nil || [courseModel.association_ids isEqualToString:@""]){
            courseModel.association_ids = [NSString stringWithFormat:@"%@",[asDic valueForKey:@"association_id"]];
            [self InsertAssociationDataWithID:[asDic valueForKey:@"association_id"] AssociationName:[asDic valueForKey:@"association_name"] association_pic:[asDic valueForKey:@"association_pic"]];
            courseModel.association_pic     =   [asDic valueForKey:@"association_pic"];
        }else{
            courseModel.association_ids = [NSString stringWithFormat:@"%@,%@",courseModel.association_ids,[asDic valueForKey:@"association_id"]];
            [self InsertAssociationDataWithID:[asDic valueForKey:@"association_id"] AssociationName:[asDic valueForKey:@"association_name"] association_pic:[asDic valueForKey:@"association_pic"]];
        }
    }
     [self reloadView:courseModel];
   // [self updateLessionData:courseModel];  //Update Lesson Items
}

-(void)updateModelWithDownloadedQuestion:(CourseModel*)courseModel withValue:(NSDictionary*)dic{
   // courseModel.association_name    =   [dic valueForKey:@"association_name"];
    courseModel.course_code         =   [dic valueForKey:@"course_code"];
    courseModel.date_of_submission  =   [dic valueForKey:@"date_of_submission"];
    courseModel.expiry_date         =   [dic valueForKey:@"expiry_date"];
    courseModel.file_type           =   [dic valueForKey:@"file_type"];
    courseModel.file_url            =   [dic valueForKey:@"file_url"];
    courseModel.lesson_description  =   [dic valueForKey:@"lesson_description"];
    courseModel.lesson_id           =   [dic valueForKey:@"lesson_id"];
    courseModel.lesson_name         =   [dic valueForKey:@"lesson_name"];
    courseModel.lesson_summary      =   [dic valueForKey:@"lesson_summary"];
    courseModel.date_of_creation 	=   [dic valueForKey:@"start_date"];
    courseModel.total_points        =   [dic valueForKey:@"total_points"];
    courseModel.score               =   [dic valueForKey:@"score"];
    courseModel.remark              =   [dic valueForKey:@"remark"];
    courseModel.resource_url        =   [dic valueForKey:@"resource_url"];
    courseModel.accreditation_url   =   [dic valueForKey:@"accreditation_url"];
    
    courseModel.total_user          =   [dic valueForKey:@"number_of_user"];
    courseModel.documentName        =   [dic valueForKey:@"document_name"];
    courseModel.subcription         =   @"1";
    NSMutableArray *spAr            =   [dic valueForKey:@"speciality"];
    NSMutableArray *asAr            =   [dic valueForKey:@"association"];
    courseModel.speciality_ids      =   @"";
    courseModel.association_ids     =   @"";
    if([[dic valueForKey:@"thumbnail"]isEqualToString:@""]){
        courseModel.thumbnail           =   @"NA";
    }else{
        courseModel.thumbnail           =   [dic valueForKey:@"thumbnail"];
    }
    
    for (NSDictionary *spclDic in spAr){
        if(courseModel.speciality_ids == nil || [courseModel.speciality_ids isEqualToString:@""]){
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@",[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }else{
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@,%@",courseModel.speciality_ids,[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }
    }
    
    for (NSDictionary *asDic in asAr){
        if(courseModel.association_ids == nil || [courseModel.association_ids isEqualToString:@""]){
            courseModel.association_ids = [NSString stringWithFormat:@"%@",[asDic valueForKey:@"association_id"]];
            courseModel.association_pic     =   [asDic valueForKey:@"association_pic"];
            [self InsertAssociationDataWithID:[asDic valueForKey:@"association_id"] AssociationName:[asDic valueForKey:@"association_name"] association_pic:[asDic valueForKey:@"association_pic"]];
        }else{
            courseModel.association_ids = [NSString stringWithFormat:@"%@,%@",courseModel.association_ids,[asDic valueForKey:@"association_id"]];
           [self InsertAssociationDataWithID:[asDic valueForKey:@"association_id"] AssociationName:[asDic valueForKey:@"association_name"] association_pic:[asDic valueForKey:@"association_pic"]];
        }
    }

    [self InsertLessonData:courseModel];
    
    NSMutableArray *queArray          =   [dic valueForKey:@"question_option"];
    for (NSDictionary *queDic in queArray){
        QuesModel *queModel         =   [QuesModel new];
        queModel.ques_ID            =   [queDic valueForKey:@"question_id"];
        queModel.ques_Title         =   [queDic valueForKey:@"question"];
        queModel.question_type      =   [queDic valueForKey:@"question_type"];
        queModel.answer_type        =   [queDic valueForKey:@"answer_type"];
        queModel.file_type          =   [queDic valueForKey:@"file_type"];
        queModel.file_url           =   [queDic valueForKey:@"file_url"];
        queModel.lesson_id          =   [dic valueForKey:@"lesson_id"];
        queModel.date_of_creation   =   [dic valueForKey:@"start_date"];
        queModel.API_OptionArr      =   [[NSMutableArray alloc]init];
        // NSArray *optArr         =   [[NSArray alloc]init];
        for (NSDictionary *optDic in [queDic valueForKey:@"options"]){
            [queModel.API_OptionArr addObject:optDic];
        }
        [self InsertQuestionData:queModel];
    }
    isOfflineSolve?[self downloadResourceFolder]:nil;
    isOfflineSolve?nil:[self StartTest];
}


-(void)InsertAssociationDataWithID: (NSString* )asID AssociationName:(NSString*)name association_pic:(NSString*)pic_url {
    
    NSString *query= [NSString stringWithFormat:@"INSERT INTO association (association_id,association_name,association_pic) VALUES ('%@','%@','%@');",asID,name,pic_url];
    [self.dbManager executeQuery:query];
}


-(void)InsertSpecialityDataWithID: (NSString* )spID SpecialityName:(NSString*)name {
    
    NSString *query= [NSString stringWithFormat:@"INSERT INTO speciality (speciality_id,speciality_name) VALUES ('%@','%@');",spID,name];
    [self.dbManager executeQuery:query];
}



#pragma mark - Lesson insert
-(void)InsertLessonData: (CourseModel *)model{
    NSString *isDownloadStat = isOfflineSolve?@"1":@"0";
    NSString *assoName = [model.association_name stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *lessonName = [model.lesson_name stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *lessonSummary = [model.lesson_summary stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *lesDesc = [model.lesson_description stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
 
    NSString *query= [NSString stringWithFormat:@"INSERT INTO  cme_lesson (association_name,course_code,expiry_date,lesson_id,lesson_name,lesson_summary,lesson_description,date_of_creation,total_points,specialities_Ids,isDownload,subcription,remarks,isSubmit,isApiSync,file_type,file_url,document_name,accreditation,association,resouce_file_name,association_pic,accreditation_url,pdf_result_url,exam_association) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@', '%@' ,'%@' , '%@', '%@', '%@', '%@', '%@', '%@','%@','%@','%@','%@','%@','%@');",assoName,model.course_code,model.expiry_date,model.lesson_id,lessonName,lessonSummary,lesDesc,model.date_of_creation,model.total_points,model.speciality_ids,isDownloadStat,model.subcription,model.remark, model.isSubmitted, model.isApiSync,model.file_type,model.file_url,model.documentName,model.accreditation,model.association_ids,@"",model.association_pic,model.accreditation_url,@"",@""];
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        [self updateLessionData:model];
    }
    
}

  

-(void)InsertQuestionData: (QuesModel *)model{
    
    NSString *qtitle = [model.ques_Title stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    NSString *query= [NSString stringWithFormat:@"INSERT INTO cme_questions (question_id,lesson_id,question,question_type,answer_type,file_type,file_url,isDownload,date_of_creation,resource_url) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",model.ques_ID,model.lesson_id,qtitle,model.question_type,model.answer_type,model.file_type,model.file_url,@"0",model.date_of_creation,model.resource_url];
    [self.dbManager executeQuery:query];
    
    for (NSDictionary *optDic in model.API_OptionArr){
        
        NSString *ques_answer_query= [NSString stringWithFormat:@"INSERT INTO  cme_questions_answer (question_id,option,isDownload,option_id,isSelected) VALUES ('%@','%@','%@','%@','%@');",model.ques_ID,[optDic valueForKey:@"options"],@"0",[optDic valueForKey:@"answer_id"],@"0"];
        [self.dbManager executeQuery:ques_answer_query];
    }
}

-(void)downloadResourceFolder{
    NSLog(@"downloadResourceFolder");
    if([self.model.resource_url isEqualToString:@""] || self.model.resource_url == nil){
        [self updateLessionDownload:self.lessionID ResouceFolder:@""];
        [self.ProgressButton updateProgress:1];
    }else{
        [self downloadFile:self.model.resource_url documentDirURL:[NSString stringWithFormat:@"CME/%@",self.model.lesson_id] lessionID:self.model.lesson_id];
    }
}

-(void)updateLessionDownload:(NSString*)lessonID ResouceFolder:(NSString *)resourceName {
    
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET isDownload = '1', subcription = '1', resouce_file_name = '%@', document_name = '%@' WHERE lesson_id = '%@'",resourceName,resourceName,lessonID];
    [self.dbManager executeQuery:query];
    
    self.model.isDownload = @"1";
    self.model.subcription = @"1";

}


-(void)updateLessionData:(CourseModel*)model{
    
    NSString *lessonDesc = [model.lesson_description stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *resUrl = [model.resource_url stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET file_type = '%@', file_url = '%@', lesson_description = '%@' ,resource_url = '%@' ,date_of_submission = '%@',resouce_file_name ='',document_name ='%@',thumbnail = '%@',association = '%@',accreditation = '%@' WHERE lesson_id = '%@'",model.file_type,model.file_url,lessonDesc,resUrl,model.date_of_submission,model.documentName,model.thumbnail, model.association_ids,model.accreditation,model.lesson_id];
    [self.dbManager executeQuery:query];
    
//    [self createDirectory:[NSString stringWithFormat:@"CME/%@",model.lesson_id]];
//    [self loadData];
    
//    if(resUrl.length>0)
//    {
//        [self downloadFile:resUrl documentDirURL:[NSString stringWithFormat:@"CME/%@",model.lesson_id] lessionID:model.lesson_id];
//        
//    }else{
//          [self loadData];
//    }
}



-(void)downloadFile:(NSString *)fileURL documentDirURL:(NSString*)lDirURL lessionID:(NSString*)lID{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:[fileURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //Convert totalBytesWritten and totalBytesExpectedToWrite into floats so that percentageCompleted doesn't get rounded to the nearest integer
        CGFloat written = totalBytesWritten;
        CGFloat total = totalBytesExpectedToWrite;
        CGFloat percentageCompleted = written/total;
        
        CGFloat downloadPer = percentageCompleted*100;
        NSLog(@"percentageCompleted = %f", downloadPer);
        
//        [self.ProgressButton setCompletionBlock:^{
//            
//        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.ProgressButton updateProgress:percentageCompleted];
        });

    }];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                  NSString *documentsDirectory = [paths objectAtIndex:0];
                                                  NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
                                                  NSURL *lessionurl = [NSURL fileURLWithPath:lessonPath];
                                                  return [lessionurl URLByAppendingPathComponent:[response suggestedFilename]];
                                                  
                                              } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                  NSLog(@"File downloaded to: %@", filePath);
                                                  [self unzipFile:filePath];
                                                  
                                                //  [self.btnSolve setTitle:@"SOLVE" forState:UIControlStateNormal];
                                                //  self.btnSolve.backgroundColor = kCOAColor;
                                              }];
    [downloadTask resume];
    
    
}

-(void)unzipFile:(NSURL*)pathName{
    NSString *zipFilePath = [pathName path];
    NSString *output = [zipFilePath stringByDeletingPathExtension];
    ZipArchive* za = [[ZipArchive alloc] init];
    
    if( [za UnzipOpenFile:zipFilePath] ) {
        if( [za UnzipFileTo:output overWrite:YES] != NO ) {
            //unzip data success
            //do something
        }
        [za UnzipCloseFile];
    }
    NSString *filename = [self getFileNameFromURL:output];
    self.model.resouceFname = filename;
    [self updateLessionDownload:self.lessionID ResouceFolder:filename];
}

#pragma mark - Create Directory
-(void) createDirectory : (NSString *) dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    self.dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:dirName];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:self.dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"Couldn't create directory error: %@", error);
    }
    else {
        NSLog(@"directory created!");
    }
    NSLog(@"dataPath : %@ ",self.dataPath); // Path of folder created
}


-(UIImage *)loadThumbNail:(NSString *)urlVideo
{
    NSURL *url = [NSURL URLWithString:urlVideo];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = TRUE;
    NSError *err = NULL;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    return [[UIImage alloc] initWithCGImage:imgRef];
    
}

//-(void)getthumbnailfromurl{
//    MPMoviePlayerController *player = [[[MPMoviePlayerController alloc] initWithContentURL:videoURL]autorelease];
//    UIImage  *thumbnail = [player thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//}


- (void)saveImage:(UIImage*)SaveImage {
   
    NSString *lDirURL = [NSString stringWithFormat:@"CME/%@",self.lessionID];
    NSString *imageRename = [NSString stringWithFormat:@"thumb-L%@.png",self.lessionID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
    
    
    NSString *savedImagePath = [lessonPath stringByAppendingPathComponent:imageRename];

    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(SaveImage, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(SaveImage, compression);
    }
    [imageData writeToFile:savedImagePath atomically:NO];
}

- (UIImage*)getImageFor:(NSString *)source {
    NSString *lDirURL = [NSString stringWithFormat:@"CME/%@",self.lessionID];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
    
    NSString *getImagePath = [lessonPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb-L%@.png",self.lessionID]];
    //NSLog(@"GEt image path: %@",getImagePath);
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    
    if([source isEqualToString:@"video"])
    {
        CGFloat  ratio = ([UIScreen mainScreen].bounds.size.width - 30) / img.size.width;
        NSLog(@"Ratio = %f",ratio);
        NSLog(@"img size = %f",img.size.width);
        UIImage *newImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1/ratio
                                          orientation:img.imageOrientation];
        img = [self drawImage:newImage withPlayImage:[UIImage imageNamed:@"play-icon.png"]];
    }
    
    return img;
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

-(void)downloadImageFile:(NSString *)fileURL documentDirURL:(NSString*)lDirURL {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    

    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                  NSString *documentsDirectory = [paths objectAtIndex:0];
                                                  NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
                                                  NSURL *lessionurl = [NSURL fileURLWithPath:lessonPath];
                                                  return [lessionurl URLByAppendingPathComponent:[NSString stringWithFormat:@"thumb-L%@.png",self.lessionID]];
                                                  return [lessionurl URLByAppendingPathComponent:[response suggestedFilename]];
                                                  
                                              } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                  NSLog(@"File downloaded to: %@", filePath);
                                                  self.img_Course.image = [self getImageFor:@"image"];
                                              }];
    [downloadTask resume];
    
    
}

#pragma mark - set subscribe course  Request
-(void)setSuscribeCourseRequest:(CourseModel*)CModel WithType:(NSString*)type{
    if(!isOfflineSolve && [type isEqualToString:@"download"]){
        [self.btnSolve setTitle:@"Processing..." forState:UIControlStateNormal];
        self.btnSolve.enabled = NO;
    }
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
    NSLog(@"user authkey = %@",u_authkey);
    [userpref synchronize];
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[DocquityServerEngine sharedInstance]SubcribeCourseRequest:u_authkey lesson_id:CModel.lesson_id device_type:@"ios" app_version:version lang:@"en" type:type callback:^(NSDictionary* responseObject, NSError* error) {
        NSLog(@"%@",responseObject);
        if(!isOfflineSolve){
            [self.btnSolve setTitle:@"Solve Online" forState:UIControlStateNormal];
            self.btnSolve.enabled = YES;
        }
        if(![AppDelegate appDelegate].isInternet){
            [self singleButtonAlertViewWithAlertTitle:NoInternetTitle message:NoInternetMessage buttonTitle:@"OK"];
            return;
            
        }
        
        NSDictionary *resposeCode=[responseObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
        }
        else {
            NSString *status=[NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"status"]?[resposeCode objectForKey:@"status"]:@""];
            int value = [status intValue];
            if(value == 1){
                NSDictionary *courseData=[resposeCode objectForKey:@"data"];
                if ([courseData isKindOfClass:[NSNull class]]||courseData == nil)
                {
                    [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
                }
                else {
                    NSDictionary *courseDic = [[NSDictionary alloc]init];
                    courseDic= [courseData objectForKey:@"course"];
                    if ([courseDic count] == 0) {
                        [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:@"OK"];
                    }
                    else {
                        if([type isEqualToString:@"preview"]){
                            [self CourseModelUpdate:CModel withValue:courseDic];
                        }else{
                            [self updateModelWithDownloadedQuestion:CModel withValue:courseDic];
                        }
                        
                    }
                }
            }
        }
        
    }];
}



-(UIImage*)pdfThumbnail:(NSString*)Path{
    NSURL *url = [NSURL fileURLWithPath: Path];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    size_t  totalPages= CGPDFDocumentGetNumberOfPages(pdf);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, rect);

    CGAffineTransform transform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, rect, 0, true);
    CGContextConcatCTM(context, transform);
    CGContextDrawPDFPage(context, page);

    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);

    self.model.documentTPage = [NSString stringWithFormat:@"%zu",totalPages];
    
    return image;
}



- (IBAction)didPressPdfOpen:(id)sender {
    [Localytics tagEvent:@"CME DeailScreen DocumentOpen Click"];
    NSString* documentfeedTitle = self.model.documentName;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = self.model.file_url;
    webvw.documentTitle = documentfeedTitle;
    [self presentViewController:webvw animated:YES completion:nil];
}

-(NSString*)getFileNameFromURL:(NSString*)url{
    NSArray *parts = [url componentsSeparatedByString:@"/"];
    NSString *filename = [parts lastObject];
    return filename;
}

-(void)imgTapped{
    if([self.model.file_type isEqualToString:@"video"]){
        [self openVideo];
    }
    else{
        [photoView fadeInPhotoViewFromImageView:self.img_Course];
    }
}

- (void)openVideo{
    [Localytics tagEvent:@"CourseDetails VideoPlay Click"];
    
    NSURL *url = [NSURL URLWithString:self.model.file_url];
    
    self.videoPlayer =  [[MPMoviePlayerController alloc]initWithContentURL:url];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_videoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
    
    _videoPlayer.controlStyle = MPMovieControlStyleDefault;  // Set control style tp default
    
    
    _videoPlayer.shouldAutoplay = YES;  // Set shouldAutoplay to YES
    
    
    [[_videoPlayer view] setFrame: [self.view bounds]];
    [self.view addSubview: [_videoPlayer view]];
    
    
    [_videoPlayer setFullscreen:YES animated:NO];  // Set the screen to full.
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [_videoPlayer stop];
   
    MPMoviePlayerController *videoPlayer = [notification object];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                    object:videoPlayer];
    
    if ([videoPlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [videoPlayer.view removeFromSuperview];
    }
}
- (void)moviePlayerPlaybackDidFinishNotification:(NSNotification*)notification
{
   [_videoPlayer.view removeFromSuperview];
}


#pragma mark - Load Data
-(void)loadQuestionData{
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid,question_id,question,question_type,answer_type,file_type,file_url FROM cme_questions WHERE lesson_id = '%@'",self.lessionID];
    if (dbQueResult != nil) {
        dbQueResult = nil;
    }
    dbQueResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    NSLog(@"dbQueResult = %@",dbQueResult);
    
    
    NSInteger  indexOfQID       = [self.dbManager.arrColumnNames indexOfObject:@"question_id"];
    NSInteger  indexOfQues      = [self.dbManager.arrColumnNames indexOfObject:@"question"];
    NSInteger  indexOfQType     = [self.dbManager.arrColumnNames indexOfObject:@"question_type"];
    NSInteger  indexOfAnsType   = [self.dbManager.arrColumnNames indexOfObject:@"answer_type"];
    NSInteger  indexOfQFType    = [self.dbManager.arrColumnNames indexOfObject:@"file_type"];
    NSInteger  indexOfQFUrl     = [self.dbManager.arrColumnNames indexOfObject:@"file_url"];
    
    
    if(queArr == nil){
        queArr = [[NSMutableArray alloc]init];
    }else{
        [queArr removeAllObjects];
    }
    
    
    if(_quesDataModel == nil) {
        _quesDataModel = [NSMutableArray array];
    }
    for(NSArray *arr in dbQueResult){
        QuesModel *quesModel            =   [QuesModel new];
        quesModel.ques_ID               =   [arr objectAtIndex:indexOfQID];
        quesModel.ques_Title            =   [arr objectAtIndex:indexOfQues];
        quesModel.question_type         =   [arr objectAtIndex:indexOfQType];
        quesModel.answer_type           =   [arr objectAtIndex:indexOfAnsType];
        quesModel.file_type             =   [arr objectAtIndex:indexOfQFType];
        quesModel.file_url              =   [arr objectAtIndex:indexOfQFUrl];
        quesModel.optionArr             =   [[NSMutableArray alloc]init];
        [queArr addObject:quesModel];
    }
    for(QuesModel *qm in queArr){
        [self loadQuestionOptionData:qm];
    }
    
     [self pushToExam];
}


#pragma mark - Load Data
-(void)loadQuestionOptionData:(QuesModel *)qm{
    
    
    NSString *qid = qm.ques_ID;
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid, option, option_id FROM cme_questions_answer WHERE question_id = '%@'",qid];
    if (dbOptResult != nil) {
        dbOptResult = nil;
    }
    dbOptResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    NSLog(@"dbOptResult = %@",dbOptResult);
    
    
    NSInteger  indexOfOPT           = [self.dbManager.arrColumnNames indexOfObject:@"option"];
    NSInteger  indexOfOPTID         = [self.dbManager.arrColumnNames indexOfObject:@"option_id"];
//    NSInteger  indexOfSelected      = [self.dbManager.arrColumnNames indexOfObject:@"isSelected"];
    
    for(NSArray *arr in dbOptResult){
        
        OptionModel *optModel   =   [OptionModel new];
        optModel.option         =   [arr objectAtIndex:indexOfOPT];
        optModel.opt_ID         =   [arr objectAtIndex:indexOfOPTID];
        optModel.question_ID    =   qid;
        optModel.isSelected     =   false;
        
        [qm.optionArr addObject:optModel];
        
    }
}



-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)setLeftBarBtn{
    UIBarButtonItem *backButton;
    
    if(self.isNoifPView){
        backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setroot)];
    }else{
        backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -8; // it was -6 in iOS 6
    
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
   
}

-(void)setroot{
    [[AppDelegate appDelegate] navigateToTabBarScren:1];
}

-(void)backView{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[AvailableCourseVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }

}

- (IBAction)didPressTranscript:(id)sender {
    [Localytics tagEvent:@"CME Course Detail View Certificate"];
    if(self.model.pdf_result_url == nil || [self.model.pdf_result_url isEqualToString:@""] || [self.model.pdf_result_url isEqualToString:@"NA"] ){
        [self singleButtonAlertViewWithAlertTitle:@"OOPS!" message:@"There is some technical issue to generate your certificate. Please try again later or contact our support team." buttonTitle:@"OK"];
        return;
        
    }
    NSString* documentfeedTitle = @"Certificate.pdf";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = self.model.pdf_result_url;
    webvw.courseTitle = self.model.lesson_name;
    webvw.associationid= [self.model.association_ids stringByReplacingOccurrencesOfString:@"," withString:@"|"];
    webvw.documentTitle = documentfeedTitle;
//    [self updateLessionData:self.model];
    webvw.isgetResult = YES;
    [self presentViewController:webvw animated:YES completion:nil];
}

@end
