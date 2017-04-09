    //
//  UpdateExam.m
//  Docquity
//
//  Created by Docquity-iOS on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "UpdateExam.h"
#import "DocquityServerEngine.h"
#import "DefineAndConstants.h"
@implementation UpdateExam

- (id)init {
    if (self = [super init]) {
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    }
    return self;
}

-(void)submitExam{
    lArray = [[NSMutableArray alloc]init];
    AllNonSubmitArray = [[NSMutableArray alloc]init];
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT _id,lesson_id,exam_association FROM cme_lesson WHERE isSubmit = '2'"];
    if (dbResult != nil) {
        dbResult = nil;
    }
    dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
   // NSLog(@"dbresult = %@",dbResult);
    
    NSInteger  indexOfLid = [self.dbManager.arrColumnNames indexOfObject:@"lesson_id"];
    NSInteger  indexOfAsid = [self.dbManager.arrColumnNames indexOfObject:@"exam_association"];
    for(NSArray *arr in dbResult){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        NSString *lid   =   [arr objectAtIndex:indexOfLid];
        NSString *aid   =   [arr objectAtIndex:indexOfAsid];
        [dic setObject:lid forKey:@"lesson_id"];
        [dic setObject:aid forKey:@"association_id"];
        [lArray addObject:dic];
    }
    for(NSMutableDictionary *dic in lArray){
        NSMutableDictionary *mainDic = [[NSMutableDictionary alloc]init];
        NSString *lid = [dic valueForKey:@"lesson_id"];
        NSString *aid = [dic valueForKey:@"association_id"];
        [mainDic setObject:lid forKey:@"lesson_id"];
        [mainDic setObject:aid forKey:@"association_id"];
        [self getQuesDataForLessionID:lid dic:mainDic];
        [AllNonSubmitArray addObject:mainDic];
    }
    //NSLog(@"All Array = %@",AllNonSubmitArray);
    [self setSubmitAnswerRequest];
}

-(void)getQuesDataForLessionID:(NSString*)lid dic:(NSMutableDictionary*)dic{
    QArray = [[NSMutableArray alloc]init];
    QnArray = [[NSMutableArray alloc]init];
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT rowid,question_id FROM cme_questions WHERE lesson_id = '%@'",lid];
    if (dbQResult != nil) {
        dbQResult = nil;
    }
    dbQResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
   // NSLog(@"dbQResult = %@",dbQResult);
    NSInteger  indexOfQid = [self.dbManager.arrColumnNames indexOfObject:@"question_id"];
    for(NSArray *arr in dbQResult){
        NSString *Qid   =   [arr objectAtIndex:indexOfQid];
        [QArray addObject:Qid];
    }
    for(NSString *qid in QArray){
        [self getSelectedQAArray:qid LessonDic:dic];
    }
    [dic setObject:QnArray forKey:@"answer"];
}

-(void)getSelectedQAArray:(NSString *)qid LessonDic:(NSMutableDictionary*)ldic{
    NSString *selectAnsQuery = [NSString stringWithFormat:@"SELECT rowid,option_id FROM cme_questions_answer WHERE question_id = '%@' AND isSelected = '1'",qid];
    if (dbQAResult != nil) {
        dbQAResult = nil;
    }
     dbQAResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectAnsQuery]];
   // NSLog(@"dbresult = %@",dbQAResult);
    NSInteger  indexOfOpid = [self.dbManager.arrColumnNames indexOfObject:@"option_id"];
    NSString *collectAns = @"";
    NSMutableDictionary *qadic = [[NSMutableDictionary alloc]init];
    for(NSArray *arr in dbQAResult){
        NSString *optid   =   [arr objectAtIndex:indexOfOpid];
        if(collectAns.length>0){
            collectAns = [NSString stringWithFormat:@"%@|%@",collectAns,optid];
        }else{
            collectAns = optid;
        }
    }
    [qadic setObject:collectAns forKey:@"answer_id"];
    [qadic setObject:qid forKey:@"question_id"];
    [QnArray addObject:qadic];
    //[ldic setObject:qadic forKey:@"arr"];
  }

#pragma mark - set subscribe course  Request
-(void)setSubmitAnswerRequest{
    for(NSMutableDictionary *dic in AllNonSubmitArray)
    {
        NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
        NSString *u_authkey = [userpref objectForKey:userAuthKey]; //mandatory
        NSString *appVer = [userpref objectForKey:kAppVersion];
       // NSLog(@"user authkey = %@",u_authkey);
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[dic valueForKey:@"answer"] options:NSJSONWritingPrettyPrinted error:&error];
        NSString *QAjson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [[DocquityServerEngine sharedInstance]SubmitAnswerRequestWithAuthKey:u_authkey lesson_id:[dic valueForKey:@"lesson_id"] association_id:[dic valueForKey:@"association_id"] qa_json:QAjson device_type:kDeviceType app_version:appVer lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
           // NSLog(@"response  submit answer = %@",responseObject);
             NSString *lessonid = [dic valueForKey:@"lesson_id"];
             long long int currentTime = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
            if(error){
            }else{
                NSDictionary *postResponse=[responseObject objectForKey:@"posts"];
                if ([postResponse isKindOfClass:[NSNull class]]||postResponse ==nil)
                {
                    // [self sign]
                    
                }else{
                    if([[postResponse valueForKey:@"status"]integerValue]==1 || [[postResponse valueForKey:@"status"]integerValue]==2 ){
                         // NSLog(@"Answer submitted successfully");
                       // NSLog(@"postResponse = %@, lessson id = %@",postResponse,lessonid);
                        NSString *remarks = [[postResponse valueForKey:@"data"]valueForKey:@"remark"];
                        NSString *submission = [[postResponse valueForKey:@"data"]valueForKey:@"date_of_submission"];
                          NSString *resultUrl = [[postResponse valueForKey:@"data"]valueForKey:@"pdf_url"];
                        [self UpdateLessonDatawithRemarks:remarks submitStatus:@"1" APIStatus:@"1" lessonid:lessonid time:submission result:resultUrl];
                        
                    }else if([[postResponse valueForKey:@"status"]integerValue]==4)
                    {
                        //NSLog(@"msg = %@",[postResponse valueForKey:@"msg"]);
                        [self UpdateLessonDatawithRemarks:@"NA" submitStatus:@"0" APIStatus:@"1" lessonid:lessonid time:[NSString stringWithFormat:@"%lld",currentTime] result:@""];
                    }
                    else{
                      //  NSLog(@"Answer submit failed");
                     }
                }
            }
        }];
    }
}

#pragma mark - Lesson insert
-(void)UpdateLessonDatawithRemarks:(NSString *)remarks submitStatus:(NSString*)stat APIStatus:(NSString *)apiSync lessonid:(NSString *)lid time:(NSString *)dateOfSub result:(NSString*)url{
   // NSLog(@"update lesson data");
     NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET remarks = '%@', isSubmit = '%@', isApiSync = '%@' ,date_of_submission = '%@',pdf_result_url = '%@' WHERE lesson_id = '%@'",remarks,stat,apiSync,dateOfSub,url,lid];
    //NSLog(@"Query : %@",query);
    [self.dbManager executeQuery:query];
//    if (self.dbManager.affectedRows != 0) {
//        [self fireNotificationForLessonID:lid Remarks:remarks];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateCourseTable" object:self];
//    }
    [self fireNotificationForLessonID:lid Remarks:remarks];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateCourseTable" object:self];
 }

-(void)fireNotificationForLessonID:(NSString*)lid Remarks:(NSString*)remark{
    //NSLog(@"fired notif for lesson - %@ and remakrs - %@",lid,remark);
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    if([remark isEqualToString:@""]){
        localNotification.alertBody = cmeExpireMsg;
    }
    else{
        localNotification.alertBody = resultNotificationMsg;
    }
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"resultSubmit", @"action",lid,@"lesson_id",remark,@"remarks", nil];
    
    localNotification.userInfo = infoDict;
   // NSLog(@"badge- %ld",(long)[[UIApplication sharedApplication] applicationIconBadgeNumber]);
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
