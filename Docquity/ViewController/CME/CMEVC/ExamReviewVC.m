//
//  ExamReviewVC.m
//  Docquity
//
//  Created by Docquity-iOS on 18/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "ExamReviewVC.h"
#import "CMEExamVC.h"
#import "AKTableAlert.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
#import "CMEResultVC.h"
#import "AppDelegate.h"
#import "Localytics.h"
#import "NSString+HTML.h"
#import "CMEReviewVC.h"
@interface ExamReviewVC ()

@end

@implementation ExamReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmation = YES;
    assoArr = [[NSMutableArray alloc]init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    [self getDataFromDB];
    NSError * error;
    
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:self.QuesSubArr options:NSJSONWritingPrettyPrinted error:&error];
    QAjson = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    self.lblMessage.text = [[self.msg stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
}

-(void)viewWillAppear:(BOOL)animated{
    [self callingGoogleAnalyticFunction:@"CME Submit Screen" screenAction:@"Visit CME Submit Screen"];
    [Localytics tagEvent:@"CME Review Screen"];
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationItem.title = @"Complete Question";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    [self setLeftBarBtn];
  
    if([AppDelegate appDelegate].isSubmitBtnCallingFromScreen ==YES)
    {
        [self didPressSubmit:nil];
    }
}
-(void)getDataFromDB{
    
    NSString *selectAssoQuery = [NSString stringWithFormat:@"SELECT _id,association FROM cme_lesson WHERE lesson_id = '%@'",self.lessionID];
    if (dbResult != nil) {
        dbResult = nil;
    }
    dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectAssoQuery]];
    NSInteger  indexOfAssociation = [self.dbManager.arrColumnNames indexOfObject:@"association"];
    for(NSArray *arr in dbResult)
    {
        NSString *association    =   [arr objectAtIndex:indexOfAssociation];
        NSArray *items           = [association componentsSeparatedByString:@","];
        if(items.count>1){
            isMultiAsso = YES;
            for(NSString *str in items){
                NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
                [tmpDic setObject:str forKey:@"assoID"];
                [tmpDic setObject:[self associationNameBasedOnAssoID:str] forKey:@"assoName"];
                [assoArr addObject:tmpDic];
            }
        }else{
            isMultiAsso = NO;
            assoID = association;
        }
    }
}

- (IBAction)didPressSubmit:(id)sender {
   [self callingGoogleAnalyticFunction:@"CME Submit Screen" screenAction:@"Submit Course Click"];
    if(isMultiAsso){
        [self showTableAlert];
    }else{
        [self SubmitAnswer];
    }
}

- (IBAction)didPressReview:(id)sender {
    UIStoryboard *mstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CMEReviewVC *VC5    = [mstoryboard instantiateViewControllerWithIdentifier:@"CMEReviewVC"];
    VC5.Arr_reviewlist  =  self.Arr_reviewlist;
    VC5.lessionID     =   self.lessionID;
    VC5.subqueArr         = self.QuesSubArr;
    [self.navigationController pushViewController:VC5 animated:YES];
}

- (void) ReviewViewController{
     for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[CMEExamVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

-(NSString *)associationNameBasedOnAssoID:(NSString*)asID{
    NSString *selectAssocitationQuery = [NSString stringWithFormat:@"SELECT _id,association_id,association_name FROM association WHERE association_id = '%@'",asID];
    if (dbAssoResult != nil) {
        dbAssoResult = nil;
    }
    dbAssoResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectAssocitationQuery]];
    NSInteger  indexOfAssName = [self.dbManager.arrColumnNames indexOfObject:@"association_name"];
    return [[dbAssoResult objectAtIndex:0]objectAtIndex:indexOfAssName];
}

-(void)showTableAlert
{
    // create the alert
    self.alert = [AKTableAlert tableAlertWithTitle:@"Choose an association" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                  {
                      return assoArr.count;
                  }
                                          andCells:^UITableViewCell* (AKTableAlert *anAlert, NSIndexPath *indexPath)
                  {
                      static NSString *CellIdentifier = @"CellIdentifier";
                      UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                      if (cell == nil)
                          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                      cell.backgroundColor = [UIColor clearColor];
                      cell.textLabel.text = [[[NSString stringWithFormat:@"%@", [[assoArr objectAtIndex:indexPath.row]valueForKey:@"assoName"]]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
                      cell.textLabel.textColor = [UIColor whiteColor];
                      return cell;
                  }];
    
    // Setting custom alert height
    self.alert.height = 350;
    // configure actions to perform
    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        // NSLog(@"selectedIndex =  %ld",(long)selectedIndex.row);
        assoID = [[assoArr objectAtIndex:selectedIndex.row]valueForKey:@"assoID"];
        [self SubmitAnswer];
    } andCompletionBlock:^{
        // NSLog(@"Cancel Button Pressed\nNo Cell select");
    }];
    // show the alert
    [self.alert show];
}

-(void)SubmitAnswer{
    for(NSMutableDictionary *dic in self.QuesSubArr){
        NSString *optid = [dic valueForKey:@"answer_id"];
        NSString *queid = [dic valueForKey:@"question_id"];
        [self updateSetDefaultQATableForQuesID:queid];
        NSArray *optArray = [optid componentsSeparatedByString:@"|"];
        for (NSString *str in optArray) {
            [self updateQATableWithSelectedStatus:@"1" quesID:queid optionID:str];
        }
    }
    [self updateExamAssociationForLessionID:self.lessionID];
    if([AppDelegate appDelegate].isInternet){
        [self setSubmitAnswerRequest];
        // [self PDFGenereate];
    }else{
    [self UpdateLessonDatawithRemarks:@"Submitted" submitStatus:@"2" APIStatus:@"0" submitDate:@"0"];
    }
}

#pragma mark - set subscribe course  Request
-(void)setSubmitAnswerRequest{
    [[AppDelegate appDelegate] showIndicator];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *appVer = [userpref objectForKey:kAppVersion];
    [[DocquityServerEngine sharedInstance]SubmitAnswerRequestWithAuthKey:[userpref objectForKey:userAuthKey] lesson_id:self.lessionID association_id:assoID qa_json:QAjson device_type:kDeviceType app_version:appVer lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
        // NSLog(@"Response : %@",responseObject);
        [[AppDelegate appDelegate] hideIndicator];
        if(error){
        }else{
            NSDictionary *postResponse=[responseObject objectForKey:@"posts"];
            if ([postResponse isKindOfClass:[NSNull class]]||postResponse ==nil)
            {
                [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
            }else{
                if([[postResponse valueForKey:@"status"]integerValue]==1 || [[postResponse valueForKey:@"status"]integerValue]==2){
                    NSString *remarks = [[postResponse valueForKey:@"data"]valueForKey:@"remark"];
                    pdfurl = [[postResponse valueForKey:@"data"]valueForKey:@"pdf_url"];
                    NSString *dos = [[postResponse valueForKey:@"data"]valueForKey:@"date_of_submission"];
                    [self UpdateLessonDatawithRemarks:remarks submitStatus:@"1" APIStatus:@"1" submitDate:dos];
                    
                }else if([[postResponse valueForKey:@"status"]integerValue]==0){
                    NSString *msg = [[postResponse valueForKey:@"data"]valueForKey:@"msg"];
                    [self singleButtonAlertViewWithAlertTitle:AppName message:msg buttonTitle:OK_STRING];
                }
                else{
                    [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                }
            }
        }
    }];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)updateExamAssociationForLessionID:(NSString*)lid{
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET exam_association = '%@' WHERE lesson_id = '%@'",assoID, self.lessionID];
    [self.dbManager executeQuery:query];
}

#pragma mark - Lesson insert
-(void)UpdateLessonDatawithRemarks:(NSString *)remarks submitStatus:(NSString*)stat APIStatus:(NSString *)apiSync submitDate:(NSString*)dos{
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET remarks = '%@', isSubmit = '%@', isApiSync = '%@' ,date_of_submission = '%@', pdf_result_url = '%@' WHERE lesson_id = '%@'",remarks,stat,apiSync, dos, pdfurl,self.lessionID];
    [self.dbManager executeQuery:query];
    if(![AppDelegate appDelegate].isInternet){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NotSubmitted message:submitOfflineMsg preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushTOResultScreenWithMsg:@"Submitted" remarks:@""];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else{ [self pushTOResultScreenWithMsg:remarks remarks:remarks];}
}

-(void)pushTOResultScreenWithMsg:(NSString*)msg remarks:(NSString*)remarks{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CMEResultVC *resultScreen = [storyboard instantiateViewControllerWithIdentifier:@"CMEResultVC"];
    resultScreen.Msg = msg;
    resultScreen.remarks = remarks;
    resultScreen.pdfURL = pdfurl;
    resultScreen.associationid = assoID;
    resultScreen.courseTitle = self.courseTitle;
    resultScreen.accerediation = self.accerediation;
    [self.navigationController pushViewController:resultScreen animated:YES];
}

-(void)setLeftBarBtn{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

-(void)backView{
    if(self.confirmation)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:backConfirmationTitle message:backConfirmationMsg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIStoryboard *Storyboard   =   [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
            CourseDetailVC *cDetail    =   [Storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
            cDetail.lessionID          =   self.lessionID;
            cDetail.btnShow            =   YES;
            cDetail.isShowdownloadedData = @"1";
            [self.navigationController pushViewController:cDetail animated:YES];
           // [self.navigationController popViewControllerAnimated:YES];
        }]];
         [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           }]];
          [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
    {
         if (self.confirmation) {
            [self backView];
            return NO;
        } else
            return YES;
    } else
        return YES;
}

-(void)updateQATableWithSelectedStatus:(NSString*)status quesID:(NSString*)qid optionID:(NSString*)optID {
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_questions_answer SET isSelected = '%@' WHERE question_id = '%@' AND option_id = '%@'",status,qid,optID];
    [self.dbManager executeQuery:query];
}

-(void)updateSetDefaultQATableForQuesID:(NSString*)qid {
    NSString *query= [NSString stringWithFormat:@"UPDATE cme_questions_answer SET isSelected = '0' WHERE question_id = '%@'",qid];
    [self.dbManager executeQuery:query];
}

@end
