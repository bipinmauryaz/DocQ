//
//  CMEReviewVC.m
//  Docquity
//
//  Created by Arimardan Singh on 24/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "CMEReviewVC.h"
#import "QuesModel.h"
#import "NSString+HTML.h"
#import "CMEExamVC.h"
#import "ExamReviewVC.h"

@interface CMEReviewVC ()

@end

@implementation CMEReviewVC
@synthesize reviewlistTblVw,Arr_reviewlist;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
   // QuesModel *queModel = [self.Arr_reviewlist objectAtIndex:self.count];
  //  QTitleCell.lbl_Ques_Step.text = [NSString stringWithFormat:@"%ld of %lu",(long)_count+1,(unsigned long)[self.queArr count]];
  
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationItem.title = @"Review";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
   // self.Arr_reviewlist = [[NSMutableArray alloc]initWithObjects:@"Anitbodies to which of the following antigens of Bacillus anthracis are",nil];
    
    // [self loadQuestionData];
    //  [self.reviewlistTblVw reloadData];
    // Do any additional setup after loading the view.
}
#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Arr_reviewlist count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ReviewListCell";
    ReviewListCell *reviewcell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (reviewcell == nil) {
        reviewcell = [[ReviewListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        //notifycell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger row = indexPath.row;
    reviewcell.lbl_Number.text = [NSString stringWithFormat:@"%ld",(long)row+1];
     NSLog(@"row%ld",(long)indexPath.row);
    reviewcell.editIcon.image = [UIImage imageNamed:@"EditableIcon.png"];
    // QTitleCell.lbl_Ques_Title.text =
    QuesModel *queModel = [self.Arr_reviewlist objectAtIndex:row];
    reviewcell.lbl_queTitle.text = [self parsingHTMLText:queModel.ques_Title];
   // @"Anitbodies to which of the following antigens of Bacillus anthracis are";
   // NSDictionary *Dic;
   // notificationTblVw.hidden=NO;
   // notifyDic= self.Arr_reviewlist [indexPath.row];
   // [reviewcell setInfo:self.Arr_reviewlist];
    return reviewcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [self pushToExam:indexPath.row];
    return;
}

-(void)pushToExam:(NSInteger)rowCount{
    UIStoryboard *NewStoryboard =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CMEExamVC *ExamStart        =   [NewStoryboard instantiateViewControllerWithIdentifier:@"CMEExamVC"];
    ExamStart.count             =   rowCount;
    ExamStart.lessionID         =   self.lessionID;
    ExamStart.resouceFname      =   self.model.resouceFname;
    ExamStart.queArr            =   self.Arr_reviewlist;
    ExamStart.isOfflineSolve    =   _isOfflineSolve;
    ExamStart.courseTitle       =   self.model.lesson_name;
    ExamStart.accerediation     =   self.model.accreditation;
    ExamStart.queSubJsonArr     =   self.subqueArr;
    [AppDelegate appDelegate].isComeFromReviewListScreen = YES;
    [self.navigationController pushViewController:ExamStart animated:YES];
}

- (void) ReviewViewController{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[CMEExamVC class]])
        {
            /*
            UIStoryboard *NewStoryboard =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
            CMEExamVC *ExamStart        =   [NewStoryboard instantiateViewControllerWithIdentifier:@"CMEExamVC"];
            ExamStart.count             =  1;
            ExamStart.lessionID         =   self.lessionID;
            ExamStart.resouceFname      =   self.model.resouceFname;
            ExamStart.queArr            =   self.Arr_reviewlist;
            ExamStart.isOfflineSolve    =   _isOfflineSolve;
            ExamStart.courseTitle       =   self.model.lesson_name;
            ExamStart.accerediation     = self.model.accreditation;
            [self.navigationController pushViewController:ExamStart animated:YES];
             */
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (IBAction)didPressEndReview:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressSubmit:(id)sender {
    [self openReviewScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(NSString*)parsingHTMLText:(NSString*)text{
    text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}

 #pragma mark - Load question Data
 -(void)loadQuestionData{
 NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid,question_id,question,question_type,answer_type,file_type,file_url FROM cme_questions WHERE lesson_id = '%@'",self.lessionID];
 if (dbResult != nil) {
 dbResult = nil;
 }
 dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
 //NSLog(@"dbresult = %@",dbResult);
 
 NSInteger  indexOfQID       = [self.dbManager.arrColumnNames indexOfObject:@"question_id"];
 NSInteger  indexOfQues      = [self.dbManager.arrColumnNames indexOfObject:@"question"];
 NSInteger  indexOfQType     = [self.dbManager.arrColumnNames indexOfObject:@"question_type"];
 NSInteger  indexOfAnsType   = [self.dbManager.arrColumnNames indexOfObject:@"answer_type"];
 NSInteger  indexOfQFType    = [self.dbManager.arrColumnNames indexOfObject:@"file_type"];
 NSInteger  indexOfQFUrl     = [self.dbManager.arrColumnNames indexOfObject:@"file_url"];
 
if(self.Arr_reviewlist == nil){
self.Arr_reviewlist = [[NSMutableArray alloc]init];
 }else{
 [self.Arr_reviewlist removeAllObjects];
 }
 
 /*
 if(_quesDataModel == nil) {
 _quesDataModel = [NSMutableArray array];
 }
  */
 for(NSArray *arr in dbResult){
 QuesModel *quesModel            =   [QuesModel new];
 quesModel.ques_ID               =   [arr objectAtIndex:indexOfQID];
 quesModel.ques_Title            =   [arr objectAtIndex:indexOfQues];
 quesModel.question_type         =   [arr objectAtIndex:indexOfQType];
 quesModel.answer_type           =   [arr objectAtIndex:indexOfAnsType];
 quesModel.file_type             =   [arr objectAtIndex:indexOfQFType];
 quesModel.file_url              =   [arr objectAtIndex:indexOfQFUrl];
 quesModel.optionArr             =   [[NSMutableArray alloc]init];
 [self.reviewlistTblVw reloadData];
 [self.Arr_reviewlist addObject:quesModel];
 /*
 }
  for(QuesModel *qm in queArr){
  [self loadQuestionOptionData:qm];
  }
 [self.tableView reloadData];
 */
 }
}

#pragma mark - Load Data
-(void)loadQuestionOptionData:(QuesModel *)qm{
    NSString *qid = qm.ques_ID;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid, option, option_id FROM cme_questions_answer WHERE question_id = '%@'",qid];
    if (dbOptResult != nil) {
        dbOptResult = nil;
    }
    dbOptResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    //NSLog(@"dbOptResult = %@",dbOptResult);
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

-(void)openReviewScreen{
    if ([AppDelegate appDelegate].isComeFromReviewListScreen ==YES)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        ExamReviewVC *reviewScreen = [storyboard instantiateViewControllerWithIdentifier:@"ExamReviewVC"];
       // reviewScreen.Arr_reviewlist = self.queArr;
        reviewScreen.QuesSubArr = self.subqueArr;
        reviewScreen.lessionID = self.lessionID;
        reviewScreen.msg = examReviewMsg;
        reviewScreen.courseTitle = self.courseTitle;
        reviewScreen.accerediation = self.accerediation;
        [AppDelegate appDelegate].isSubmitBtnCallingFromScreen = YES;
        [self.navigationController pushViewController:reviewScreen animated:YES];
    }
    else{
    [self.navigationController popViewControllerAnimated:YES];
    [AppDelegate appDelegate].isSubmitBtnCallingFromScreen = YES;
    }
}

-(void)didPressReviewQuestion {
    QuesModel *qm = [self.Arr_reviewlist objectAtIndex:1];
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
      //  [self singleButtonAlertViewWithAlertTitle:@"CME" message:kquestionValidationMsg buttonTitle:OK_STRING];
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
       // [self openReviewScreen];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
