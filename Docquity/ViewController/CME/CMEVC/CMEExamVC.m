//
//  CMEExamVC.m
//  Docquity
//
//  Created by Docquity-iOS on 10/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "CMEExamVC.h"
#import "QuesImageCell.h"
#import "QuesTitleCell.h"
#import "QuesAnswerCell.h"
#import "QuesModel.h"
#import "UIImageView+WebCache.h"
#import "DefineAndConstants.h"
#import "ExamReviewVC.h"
#import "OptionModel.h"
#import "CourseDetailVC.h"
#import "CAPSPhotoView.h"
#import "Localytics.h"
#import "NSString+HTML.h"
#import "CMEReviewVC.h"

@interface CMEExamVC (){
    CAPSPhotoView *photoView;
}
//@property(nonatomic, strong)NSMutableArray <QuesModel *> *data;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexDictionary;
@end

@implementation CMEExamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self callingGoogleAnalyticFunction:@"Question Screen" screenAction:@"Visit Question Screen"];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    self.navigationItem.title = @"Question";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self setLeftBarBtn];
    isAnsSelected = NO;
    //SelectedAns = [[NSMutableArray alloc]init];
    _selectedIndexDictionary = [NSMutableDictionary dictionary];
    SelectedAns = [NSMutableArray array];
    //[self loadQuestionData];
    //[self.tableView reloadData];
    if(self.count == [self.queArr count]-1){
     [self.btnNext setTitle:@"FINISH" forState:UIControlStateNormal];
    }
    photoView = [[CAPSPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height) dateTitle:@""
                                               title:[[self.queArr objectAtIndex:self.count]ques_Title]
                                            subtitle:@""];
}

-(void)viewWillAppear:(BOOL)animated{
    if ( [AppDelegate appDelegate].isComeFromReviewListScreen == YES) {
        [self.btn_endExam setTitle:@"END REVIEW" forState:UIControlStateNormal];
    [Localytics tagEvent:@"CME Question Screen"];
    // NSLog(@"viewWillAppear %ld",(long)self.count);
    if(self.count == 0){
        self.confirmation = YES;
    }else{
        self.confirmation = NO;
    }
 }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    self.count --;
    // NSLog(@"viewWillDisappear %ld",(long)self.count);
}

/*
 #pragma mark - Load Data
 -(void)loadQuestionData{
 NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid,question_id,question,question_type,answer_type,file_type,file_url FROM cme_questions WHERE lesson_id = '%@'",self.lessionID];
 if (dbResult != nil) {
 dbResult = nil;
 }
 dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
 NSLog(@"dbresult = %@",dbResult);
 
 
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
 for(NSArray *arr in dbResult){
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
 [self loadQuestionOptionData:qm.ques_ID];
 }
  [self.tableView reloadData];
 }
 
 #pragma mark - Load Data
 -(void)loadQuestionOptionData:(NSString *)qid{
 
 
 //  NSString *qid = [[queArr objectAtIndex:_count]ques_ID];
 
 NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid, option, option_id, isSelected FROM cme_questions_answer WHERE question_id = '%@'",qid];
 if (dbOptResult != nil) {
 dbOptResult = nil;
 }
 dbOptResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
 NSLog(@"dbOptResult = %@",dbOptResult);
 
 NSInteger  indexOfOPT           = [self.dbManager.arrColumnNames indexOfObject:@"option"];
 NSInteger  indexOfOPTID         = [self.dbManager.arrColumnNames indexOfObject:@"option_id"];
 NSInteger  indexOfSelected      = [self.dbManager.arrColumnNames indexOfObject:@"isSelected"];
 
 for(NSArray *arr in dbOptResult){
 
 OptionModel *optModel   =   [OptionModel new];
 optModel.option         =   [arr objectAtIndex:indexOfOPT];
 optModel.opt_ID         =   [arr objectAtIndex:indexOfOPTID];
 optModel.isSelected     =   [arr objectAtIndex:indexOfSelected];
 
 [[[queArr objectAtIndex:_count]optionArr] addObject:optModel];
 
 }
 
 [self.tableView reloadData];
 
 }
 */

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowcount = 0 ;
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if(![[[self.queArr objectAtIndex:_count]question_type]isEqualToString:@"text"]){
                rowcount = 1;
            }
            return rowcount;
            break;
            
        default:
            return [[[self.queArr objectAtIndex:_count]optionArr] count];
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *QuestitleCell  = @"QuesTitleCell";
    static NSString *quesImageCell  = @"QuesImageCell";
    static NSString *quesAnswerCell = @"QuesAnswerCell";
  
    QuesTitleCell *QTitleCell = [tableView dequeueReusableCellWithIdentifier:QuestitleCell];
    QuesImageCell *QIcell = [tableView dequeueReusableCellWithIdentifier:quesImageCell];
    QuesAnswerCell *QACell = [tableView dequeueReusableCellWithIdentifier:quesAnswerCell];
    
    QuesModel *queModel = [self.queArr objectAtIndex:self.count];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapped:)];
    switch (indexPath.section) {
        case 0:
            if (QTitleCell==nil) {
                QTitleCell = [[QuesTitleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QuestitleCell];
            }
            QTitleCell.lbl_Ques_Step.text = [NSString stringWithFormat:@"%ld of %lu",(long)_count+1,(unsigned long)[self.queArr count]];
            QTitleCell.lbl_Ques_Title.text = [self parsingHTMLText:queModel.ques_Title];
            [QTitleCell.btn_View_Case addTarget:self action:@selector(viewCourse) forControlEvents:UIControlEventTouchUpInside];
            return QTitleCell;
            break;
            
        case 1:
            if (QIcell==nil) {
                QIcell = [[QuesImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:quesImageCell];
            }
            if(self.isOfflineSolve){
                QIcell.Img_Question.image = [self getImageFor:@"image" imageFilePath:[[self cmeLessonLocalPathForFile:self.resouceFname] stringByAppendingPathComponent:[self getFileNameFromURL:queModel.file_url]]];
            }else{
                [QIcell.Img_Question sd_setImageWithURL:[NSURL URLWithString:queModel.file_url] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
            }
            QIcell.Img_Question.contentMode = UIViewContentModeScaleAspectFill;
            QIcell.Img_Question.layer.masksToBounds = YES;
            gesture.numberOfTapsRequired = 1.0;
            [QIcell.Img_Question addGestureRecognizer:gesture];
            return QIcell;
            break;
         default:
            if (QACell==nil) {
                QACell = [[QuesAnswerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:quesAnswerCell];
            }
            QACell.lbl_sep.backgroundColor = kBorderBGColor;
            
            if(indexPath.row == 0){
                [self prefix_addUpperBorder:QACell];
                
                if (indexPath.row == [[[self.queArr objectAtIndex:_count]optionArr] count]-1){
                    QACell.LeadingConstraintsLblSep.constant    =   15.0;
                    QACell.TrailingConstraintsLblSep.constant   =   15.0;
                }
                
            }else if (indexPath.row == [[[self.queArr objectAtIndex:_count]optionArr] count]-1){
                
                QACell.LeadingConstraintsLblSep.constant    =   15.0;
                QACell.TrailingConstraintsLblSep.constant   =   15.0;
            }else{
                QACell.LeadingConstraintsLblSep.constant    =   30.0;
                QACell.TrailingConstraintsLblSep.constant   =   30.0;
                
            }
            NSString *opt = [[[[self.queArr objectAtIndex:self.count]optionArr] objectAtIndex:indexPath.row].option stringByDecodingHTMLEntities];
            QACell.lbl_Answer_Option.text = [self parsingHTMLText:opt];
            
            //            QACell.lbl_Answer_Option.text = [[[self.queArr objectAtIndex:self.count]optionArr] objectAtIndex:indexPath.row].option;
            
            
            //            QACell.lbl_Answer_Option.text = [[[self.queArr objectAtIndex:self.count]optionArr] objectAtIndex:indexPath.row][@"option"];
            
            
            
            //            if([[[self.queArr objectAtIndex:self.count]answer_type]isEqualToString:@"single"]){
            //                self.tableView.allowsMultipleSelection = NO;
            //                if(self.selectedIndexPath == indexPath){
            //
            //                    QACell.Img_Status.image = [UIImage imageNamed:@"radiobuttonselected.png"];
            //                }else{
            //                    QACell.Img_Status.image = [UIImage imageNamed:@"radiobuttonunselected.png"];
            //                }
            //            }else {
            //                self.tableView.allowsMultipleSelection = YES;
            //                if ([SelectedAns containsObject:indexPath]){
            //                    QACell.Img_Status.image  = [UIImage imageNamed:@"tick-box.png"];
            //                }else{
            //                    QACell.Img_Status.image  = [UIImage imageNamed:@"untick-box.png"];
            //                }
            //            }
            //
            
            if([[[self.queArr objectAtIndex:self.count]answer_type]isEqualToString:@"single"]){
                self.tableView.allowsMultipleSelection = NO;
                if([[[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:indexPath.row]isSelected]){
                    
//                    if (QACell.isSelected == false) {
//                        QACell.selected  = true;
//                        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
//                    }
                    self.selectedIndexPath=indexPath;
                    QACell.Img_Status.image = [UIImage imageNamed:@"radiobuttonselected.png"];
                }else{
                    QACell.Img_Status.image = [UIImage imageNamed:@"radiobuttonunselected.png"];
                    
//                    if (QACell.isSelected != false) {
//                        QACell.selected  = true;
//                        [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
//                    }
                    
                }
            }else {
                self.tableView.allowsMultipleSelection = YES;
                if([[[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:indexPath.row]isSelected]){
                    QACell.Img_Status.image  = [UIImage imageNamed:@"tick-box.png"];
                }else{
                    QACell.Img_Status.image  = [UIImage imageNamed:@"untick-box.png"];
                }
            }
            
            
            
            return QACell;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView reloadData];
    
    if(indexPath.section == 2){
        
        // NSLog(@"Selected index = %ld",(long)indexPath.row);
        //        if([[[self.queArr objectAtIndex:self.count]answer_type]isEqualToString:@"single"]){
        //            self.selectedIndexPath = indexPath;
        //            ansSelected = [[[self.queArr objectAtIndex:self.count]optionArr] objectAtIndex:indexPath.row].opt_ID;
        //       }else{
        //
        //           if ([SelectedAns containsObject:indexPath])
        //           {
        //               [SelectedAns removeObject:indexPath];
        //               QACell.Img_Status.image = [UIImage imageNamed:@"untick-box.png"];
        //           }
        //           else
        //           {
        //               [SelectedAns addObject:indexPath];
        //                QACell.Img_Status.image = [UIImage imageNamed:@"tick-box.png"];
        //
        //           }
        //       }
        
        
        if([[[self.queArr objectAtIndex:self.count]answer_type]isEqualToString:@"single"]){
            //[self.queArr removeAllObjects];
            
            [[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:self.selectedIndexPath.row].isSelected = false;
            self.selectedIndexPath = indexPath;
            [[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:indexPath.row].isSelected = true;
        }else{
            [[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:indexPath.row].isSelected = ![[[self.queArr objectAtIndex:self.count]optionArr]objectAtIndex:indexPath.row].isSelected;
        }
        [tableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prefix_addUpperBorder:(UIView*)view
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = kBorderLayerColor;
    upperBorder.frame = CGRectMake(15, 0, width - 30, 1.0f);
    [view.layer addSublayer:upperBorder];
}

- (IBAction)didPressEndExam:(id)sender
{
    if ( [AppDelegate appDelegate].isComeFromReviewListScreen == YES) {
        UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CMEReviewVC *reviewList  = [mstoryboard instantiateViewControllerWithIdentifier:@"CMEReviewVC"];
        reviewList.Arr_reviewlist  =  self.queArr;
        reviewList.subqueArr       =  self.queSubJsonArr;
        reviewList.lessionID       =  self.lessionID;
        [self.navigationController pushViewController:reviewList animated:YES];
    }
    else{
     /*
    if(self.confirmation)
    {
     */
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you really want to exit?" message:backConfirmationMsg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIStoryboard *Storyboard   =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
            CourseDetailVC *cDetail    =   [Storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
            cDetail.lessionID          =   self.lessionID;
            cDetail.btnShow            =   YES;
         //   UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cDetail];
            cDetail.isShowdownloadedData = @"1";
            /*
            nav.navigationBar.tintColor = [UIColor whiteColor];
            nav.navigationBar.translucent = NO;
            nav.navigationBar.barTintColor = kThemeColor;
            
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
            barButton.imageInsets = UIEdgeInsetsMake(4, 0, 4, 8);
            nav.navigationBar.topItem.leftBarButtonItem = barButton;
            [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
             */
             [self.navigationController pushViewController:cDetail animated:YES];
           // [self presentViewController:nav animated:YES completion:nil];
           // self.count++ ; //Trick

          //  [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
/*
else{
        [self.navigationController popViewControllerAnimated:YES];
    }
 */
//}

- (IBAction)didPressNext:(id)sender {
    [self callingGoogleAnalyticFunction:@"Question Screen" screenAction:@"Next Click"];
    QuesModel *qm = [self.queArr objectAtIndex:self.count];
    for (OptionModel *optM in qm.optionArr)
    {
        if(optM.isSelected)
        {
            isAnsSelected = YES;
            break;
        }else
        {
            isAnsSelected = NO;
        }
    }
    if(!isAnsSelected){
        [self singleButtonAlertViewWithAlertTitle:@"CME" message:kquestionValidationMsg buttonTitle:OK_STRING];
        return;
    }
    if(self.count == self.queArr.count-1)
    {
        self.count ++ ;
        self.QA_Arr  = [[NSMutableArray alloc]init];
        for(QuesModel *qm in _queArr){
            NSMutableDictionary *qadic = [[NSMutableDictionary alloc]init];
            NSString *ansCollection;
            for (OptionModel *optM in qm.optionArr) {
                if(optM.isSelected){
                    if(ansCollection.length>0){
                        ansCollection = [NSString stringWithFormat:@"%@|%@",ansCollection,optM.opt_ID];
                    }else{
                        ansCollection = optM.opt_ID;
                    }
                }
            }
            [qadic setObject:ansCollection forKey:@"answer_id"];
            [qadic setObject:qm.ques_ID forKey:@"question_id"];
            [self.QA_Arr addObject:qadic];
        }
        [self openReviewScreen];
    }
    else {
        self.count ++ ;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        CMEExamVC *startExam = [storyboard instantiateViewControllerWithIdentifier:@"CMEExamVC"];
        startExam.count = self.count;
        startExam.lessionID = self.lessionID;
        startExam.resouceFname = self.resouceFname;
        startExam.queArr = self.queArr;
        startExam.courseTitle = self.courseTitle;
        startExam.accerediation = self.accerediation;
        startExam.isOfflineSolve = self.isOfflineSolve;
        // startExam.QA_Arr = self.QA_Arr;
        [self.navigationController pushViewController:startExam animated:YES];
    }
  }

-(void)openReviewScreen{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    ExamReviewVC *reviewScreen = [storyboard instantiateViewControllerWithIdentifier:@"ExamReviewVC"];
    reviewScreen.Arr_reviewlist = self.queArr;
    reviewScreen.QuesSubArr = self.QA_Arr;
    reviewScreen.lessionID = self.lessionID;
    reviewScreen.msg = examReviewMsg;
    reviewScreen.courseTitle = self.courseTitle;
    reviewScreen.accerediation = self.accerediation;
    [AppDelegate appDelegate].isSubmitBtnCallingFromScreen =NO;
    [self.navigationController pushViewController:reviewScreen animated:YES];
}

-(NSString*)cmeLessonLocalPathForFile:(NSString*)filename{
    NSString *lDirURL = [NSString stringWithFormat:@"CME/%@",self.lessionID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lessonPath = [documentsDirectory stringByAppendingPathComponent:lDirURL];
    NSString *fullPath = [lessonPath stringByAppendingPathComponent:filename];
    return fullPath;
}

-(NSString*)getFileNameFromURL:(NSString*)url{
    NSArray *parts      = [url componentsSeparatedByString:@"/"];
    NSString *filename  = [parts lastObject];
    return filename;
}

- (UIImage*)getImageFor:(NSString *)source imageFilePath:(NSString *)imageFilePath {
    UIImage *img = [UIImage imageWithContentsOfFile:imageFilePath];
    if([source isEqualToString:@"video"])
    {
        CGFloat  ratio = ([UIScreen mainScreen].bounds.size.width - 30) / img.size.width;
        // NSLog(@"Ratio = %f",ratio);
        // NSLog(@"img size = %f",img.size.width);
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

-(void)viewCourse{
    [self callingGoogleAnalyticFunction:@"Question Screen" screenAction:@"View Course Detail Click"];
    UIStoryboard *Storyboard   =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CourseDetailVC *cDetail    =   [Storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
    cDetail.lessionID          =   self.lessionID;
    cDetail.btnShow            =   NO;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cDetail];
    cDetail.isShowdownloadedData = @"1";
    
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
   // barButton.imageInsets = UIEdgeInsetsMake(4, 0, 4, 8);
    nav.navigationBar.topItem.leftBarButtonItem = barButton;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self presentViewController:nav animated:YES completion:nil];
    self.count++ ; //Trick
}

-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setLeftBarBtn{
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -8; // it was -6 in iOS 6
    
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  }

-(void)backView{
    [self callingGoogleAnalyticFunction:@"Question Screen" screenAction:@"Back Click"];
    if(self.confirmation)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:backConfirmationTitle message:backConfirmationMsg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
         [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        
        if (self.confirmation) {
            [self backView];
            return NO;
        } else
            return YES;
    } else
        return YES;
}

-(void)imgTapped:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView *)tap.view;
    [photoView fadeInPhotoViewFromImageView:imageView];
}

-(NSString*)parsingHTMLText:(NSString*)text{
    text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}


@end
