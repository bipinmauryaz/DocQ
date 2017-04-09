//
//  AvailableCourseVC.m
//  Docquity
//
//  Created by Docquity Services on 04/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "AvailableCourseVC.h"
//#import "CoursesCell.h"
#import "AvailableCourseCell.h"
#import "AppDelegate.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
#import "DocquityServerEngine.h"
#import "SVPullToRefresh.h"
#import "CourseDetailVC.h"
#import "QuesModel.h"
#import "ZipArchive.h"
#import "Localytics.h"
#import "WebVC.h"
#import "UILoadingView.h"
#import "PermissionCheckYourSelfVC.h"
@implementation AvailableCourseVC
@synthesize alreadytaken_button,alreadytakencoursesArr;
@synthesize newcoursesArr,courses_button,completeCoursesArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDirectory:@"CME"];
    isShowSampleCourse = false;
    isSetPullOnAvC = true;
    isSetPullOnComC = true;
    self.newcoursesArr = [[NSMutableArray alloc]init];
    self.completeCoursesArr = [[NSMutableArray alloc]init];
    DataSource = [[NSMutableArray alloc ] init];
    Completepagecount = 1;
    coursepagecount = 1; //initial state of page that control should start 0 to limit 10
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"imps.db"];
    
    // Initialize the refresh control.
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor =[UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor lightGrayColor];
    //[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshCourseData)
              forControlEvents:UIControlEventValueChanged];
    
    blankloaderview = [[UIView alloc]initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60 -48-64)];
    blankloaderview.backgroundColor = [UIColor redColor];
    blankloaderview.hidden = YES;
    [self.view addSubview: blankloaderview];
     loader = [[UILoadingView alloc] initWithFrame:CGRectMake(0, 0, blankloaderview.bounds.size.width, blankloaderview.frame.size.height)];
    [blankloaderview addSubview:loader];
    
//    loader = [[UILoadingView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height-48-60-64)];
    
    self.courseTV.backgroundView.backgroundColor =[UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    
    self.courseTV.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
     [self buttonChangedonClick:courses_button];
 }

- (void)refreshCourseData
{
    //Reload table data
    is_topRefreshing = YES;
 
    if (self.newcoursesArr == nil)
    {
        self.newcoursesArr = [[NSMutableArray alloc]init];
    }
    
    if (self.completeCoursesArr == nil)
    {
        self.completeCoursesArr = [[NSMutableArray alloc]init];
    }
    
    if (courses_button.selected == YES) {
        coursepagecount = 1;
        [self getUserCourseListRequestWithType:@""];
        [self.courseTV reloadData];
    }
    
    else if (alreadytaken_button.selected == YES) {
        Completepagecount = 1;
        [self getUserCourseListRequestWithType:@"subscribe"];
        [self.courseTV reloadData];
    }
    // End the refreshing
    if (refreshControl) {
        NSString *title = [NSString stringWithFormat:@"Refreshing..."];
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"CME Available course"];
    [self registerNotification];
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationItem.title = @"Available Courses";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIImage *learnImage = [UIImage imageNamed:@"learnmore.png"];
    UIButton *lmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lmBtn.backgroundColor = [UIColor clearColor];
    [lmBtn setImage:learnImage forState:UIControlStateNormal];
    lmBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40, 3, 28, 28);
    [lmBtn addTarget:self action:@selector(learnMore:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *lmBarBtn = [[UIBarButtonItem alloc] initWithCustomView:lmBtn];
    self.navigationItem.rightBarButtonItem = lmBarBtn;
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    // [self.courseTV reloadData];
}


-(void)learnMore:(UIButton*)sender{
    [Localytics tagEvent:@"CME AvailableCourse Learnmore Click"];
    NSString* documentfeedTitle = @"Learn More";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webvw.fullURL = learnMorelink;
    webvw.documentTitle = documentfeedTitle;
    [self presentViewController:webvw animated:YES completion:nil];
}

#pragma mark UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isShowSampleCourse)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isShowSampleCourse)
    {
        self.emptyView.hidden = true;
        if(section == 0){
            return 1;
        }else{
            if(isNewCourse) return [self.newcoursesArr count];
            else return [self.completeCoursesArr count];
        }
     }
    else{
          if(isNewCourse) {
            if([self.newcoursesArr count] == 0){
                [self emptyViewShowWithText:cmeAvailEmpty WithFlag:YES];
            }else{
                [self emptyViewShowWithText:cmeAvailEmpty WithFlag:NO];
            }
            return [self.newcoursesArr count];
        }
        else
        {
            if([self.completeCoursesArr count] == 0){
                [self emptyViewShowWithText:cmeCompletedEmpty WithFlag:YES];
            }
            else
            {
                [self emptyViewShowWithText:cmeCompletedEmpty WithFlag:NO];
            }
             return [self.completeCoursesArr count];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isShowSampleCourse){
        if(indexPath.section == 0){
            return 30;
        }else{
            return UITableViewAutomaticDimension;
        }
    }else return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isShowSampleCourse){
        if(indexPath.section == 0){
            return 30;
        }else{
            return UITableViewAutomaticDimension;
        }
    }else return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AvailableCourseCell";
    static NSString *cellIdentifierDef = @"cell";
    CourseModel *cModel = [CourseModel new];
    if(isNewCourse)
        cModel= self.newcoursesArr[indexPath.row];
    else
        cModel= self.completeCoursesArr[indexPath.row];
    
    AvailableCourseCell *cell = (AvailableCourseCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UITableViewCell *dCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierDef];
    
    if(isShowSampleCourse)
    {
        if (indexPath.section == 0) {
            if (dCell == nil)
            {
                dCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierDef];
                UILabel *info = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
                info.tag = 29;
                [dCell.contentView addSubview:info];
            }
            UILabel *info = [dCell.contentView viewWithTag:29];
            info.text = [self parsingHTMLText:SampleMsg];
            info.textColor = [UIColor whiteColor];
            info.textAlignment = NSTextAlignmentCenter;
            info.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            dCell.contentView.backgroundColor = kFontDescColor;
            dCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return dCell;
        }
        else{
            if (cell == nil)
            {
                cell = [[AvailableCourseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [cell setInfo:cModel];
            for(UIView * cellSubviews in cell.subviews)
            {
                cellSubviews.userInteractionEnabled = NO;
            }
            return cell;
        }
        
    }else
    {
        
        if (cell == nil)
        {
            cell = [[AvailableCourseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        [cell setInfo:cModel];
        for(UIView * cellSubviews in cell.subviews)
        {
            cellSubviews.userInteractionEnabled = NO;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if((isShowSampleCourse && indexPath.section == 1) || (!isShowSampleCourse)){
        CourseModel *cModel = [CourseModel new];
        if(isNewCourse)
        {
            cModel= self.newcoursesArr[indexPath.row];
        }else{
            cModel= self.completeCoursesArr[indexPath.row];
        }
        verticalContentOffset  = self.courseTV.contentOffset.y;
        if([cModel.subcription isEqualToString:@"1"]){
            selectedIndex = indexPath.row;
            selectedIndexPath = indexPath;
            if([self downloadCheckForLessonID:cModel.lesson_id]){
                [self openCourseDetailView:cModel.lesson_id downloadStat:@"1" data:cModel];
            }else{
                [self openCourseDetailView:cModel.lesson_id downloadStat:@"0" data:cModel];
            }
        }else{
            selectedIndex = indexPath.row;
            selectedIndexPath = indexPath;
            [self openCourseDetailView:cModel.lesson_id downloadStat:@"0" data:cModel];
        }
    }
}

#pragma mark - Open Course Detail
- (void)openCourseDetailView:(NSString*)lessionID downloadStat:(NSString*)downloadStat data:(CourseModel*)data{
    if(![AppDelegate appDelegate].isInternet && [downloadStat isEqualToString:@"0"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CourseDetailVC *courseDetail = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
    courseDetail.lessionID = lessionID;
    courseDetail.model = data;
    courseDetail.hidesBottomBarWhenPushed = YES;
    courseDetail.isShowdownloadedData = downloadStat;
    courseDetail.delegate = self;
    courseDetail.isNoifPView = NO;
    long long int currentTime = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
    if(data.expiry_date.longLongValue < currentTime){
        courseDetail.btnShow  = NO;
    }else{
        courseDetail.btnShow  = YES;
    }
    [self.navigationController pushViewController:courseDetail animated:YES];
}

#pragma mark - get userCourseListRequest
-(void)getUserCourseListRequestWithType:(NSString*)type{
    NSString *pagestring;
    if(isNewCourse){
        pagestring = [NSString stringWithFormat:@"%d", coursepagecount];
        if ([pagestring isEqualToString:@"1"]) {
            if (is_topRefreshing==YES) {
            }
            else{
                [self showLoader];
//                [self.view addSubview:loader];
                // [[AppDelegate appDelegate] showIndicator];
            }
        }
    }else{
        pagestring = [NSString stringWithFormat:@"%d", Completepagecount];
        if ([pagestring isEqualToString:@"1"]) {
            if (is_topRefreshing==YES) {
            }
            else{
                [self showLoader];
                //[self.view addSubview:loader];
               // [[AppDelegate appDelegate] showIndicator];
            }
        }
    }
    
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]GetUserCourseListRequest:[userpref objectForKey:userAuthKey] device_type:kDeviceType app_version:[userpref objectForKey:kAppVersion] lang:kLanguage offset:pagestring limit:@"10" type:type callback:^(NSDictionary* responceObject, NSError* error) {
        [[AppDelegate appDelegate] hideIndicator];
       //  NSLog(@"%@",responceObject);
        [self hideLoader];
        
        [self.courseTV.pullToRefreshView stopAnimating];
        is_topRefreshing = FALSE;
        [refreshControl endRefreshing];
        self.courseTV.tableFooterView = nil;
        NSDictionary *resposeCode=[responceObject objectForKey:@"posts"];
        learnMorelink = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"learn_more"]?[resposeCode objectForKey:@"learn_more"]:@""];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            // response is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                NSDictionary *courseDic=[resposeCode objectForKey:@"data"];
                if ([courseDic isKindOfClass:[NSNull class]]||courseDic == nil)
                {
                    // response is null
                }
                else {
                    if(isNewCourse){
                        isShowSampleCourse = NO;
                        availCourseStatus = @"1";
                        coursepagecount==1?[self.newcoursesArr removeAllObjects]:nil;
                        coursepagecount ==1?[refreshControl endRefreshing]:nil;
                        NSMutableArray *temparr = [[NSMutableArray alloc]init];
                        temparr= [[courseDic objectForKey:@"list"] mutableCopy];
                        if ([temparr count]==0) {
                            self.courseTV.hidden = YES;
                        }
                        else {
                            self.courseTV.hidden = NO;
                            if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                            {
                                //more data found
                                [self SetupCourseModel:temparr];
                                coursepagecount++;
                            }
                        }
                    }
                    else{
                        Completepagecount==1?[self.completeCoursesArr removeAllObjects]:nil;
                        Completepagecount ==1?[refreshControl endRefreshing]:nil;
                        NSMutableArray *temparr = [[NSMutableArray alloc]init];
                        temparr= [[courseDic objectForKey:@"list"] mutableCopy];
                        if ([temparr count]==0) {
                            self.courseTV.hidden = YES;
                        }
                        else {
                            self.courseTV.hidden = NO;
                            if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                            {
                                [self SetupCourseModel:temparr];
                                self.emptyView.hidden = true;
                                [self loadData];    //Fetch From Table
                                //[self.courseTV reloadData];
                                  Completepagecount++;
                            }
                        }
                     }
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 5){
                [[AppDelegate appDelegate]ShowPopupScreen];
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 8){
                SampleMsg = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
                learnMorelink = [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"learn_more"]?[resposeCode objectForKey:@"learn_more"]:@""];
                NSDictionary *courseDic=[resposeCode objectForKey:@"data"];
                if ([courseDic isKindOfClass:[NSNull class]]||courseDic == nil)
                {
                    [self.courseTV reloadData];
                    [self.courseTV setShowsPullToRefresh:NO];
                    // NSLog(@"Status = %d",value);
                    // NSLog(@"data = %@",courseDic);
//                    if(isNewCourse)
//                    {
//                        //[newcoursesArr removeAllObjects];
////                        self.emptyView.hidden = false;
////                        self.lbl_emptyview.text = cmeAvailEmpty;
//                        [self.courseTV reloadData];
//                        [self.courseTV setShowsPullToRefresh:NO];
//                    }else {
//                       // [completeCoursesArr removeAllObjects];
////                        self.emptyView.hidden = false;
////                        self.lbl_emptyview.text = cmeCompletedEmpty;
//                        [self.courseTV reloadData];
//                    }
                }
                else {
                    if(isNewCourse){
                        availCourseStatus = @"8";
                        isShowSampleCourse = YES;
                        coursepagecount==1?[self.newcoursesArr removeAllObjects]:nil;
                        coursepagecount ==1?[refreshControl endRefreshing]:nil;
                        NSMutableArray *temparr = [[NSMutableArray alloc]init];
                        temparr= [[courseDic objectForKey:@"list"] mutableCopy];
                        if ([temparr count]==0) {
                            self.courseTV.hidden = YES;
//                            self.emptyView.hidden = false;
//                            self.lbl_emptyview.text = cmeAvailEmpty;
                        }
                        else {
                            self.courseTV.hidden = NO;
//                            self.emptyView.hidden = TRUE;
                            if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                            {
                                //more data found
                                [self SetupCourseModel:temparr];
                                coursepagecount++;
                            }
                            [self.courseTV setShowsPullToRefresh:NO];
                        }
                    }
                    else{
                        Completepagecount==1?[self.completeCoursesArr removeAllObjects]:nil;
                        Completepagecount ==1?[refreshControl endRefreshing]:nil;
                        NSMutableArray *temparr = [[NSMutableArray alloc]init];
                        temparr= [[courseDic objectForKey:@"list"] mutableCopy];
                        if ([temparr count]==0) {
                            self.courseTV.hidden = YES;
//                            self.emptyView.hidden = false;
//                            self.lbl_emptyview.text = cmeAvailEmpty;
                        }
                        else {
                            self.courseTV.hidden = NO;
//                            self.emptyView.hidden = TRUE;
                            if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                            {
                                [self SetupCourseModel:temparr];
                                [self loadData];    //Fetch From Table
                                //[self.courseTV reloadData];
                                Completepagecount++;
                            }
                        }
                    }
                }
            }
            
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                [userpref synchronize];;
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }

            else  if([[resposeCode valueForKey:@"status"]integerValue] == 7){
                if(isNewCourse){
                    if(coursepagecount == 1){
                        [newcoursesArr removeAllObjects];
//                        self.emptyView.hidden = false;
//                        self.lbl_emptyview.text = cmeAvailEmpty;
                        [self.courseTV reloadData];
                    }else {
                        isSetPullOnAvC = NO;
                    }
                }else{
                    if(Completepagecount == 1){
                        [completeCoursesArr removeAllObjects];
//                        self.emptyView.hidden = false;
//                        self.lbl_emptyview.text = cmeCompletedEmpty;
                        [self.courseTV reloadData];
                    }else{
                        isSetPullOnComC = NO;
                    }
                }
                [self.courseTV setShowsPullToRefresh:NO];
            }
            else{
                [[AppDelegate appDelegate] hideIndicator];
                self.courseTV.hidden =YES;
            }
        }
    }];
}

-(void)SetupCourseModel:(NSMutableArray*)arr{
    if(_data == nil) {
        _data = [NSMutableArray array];
    }
    for (NSDictionary *dic in arr) {
        CourseModel *courseModel        =   [CourseModel new];
        courseModel.accreditation       =   [dic valueForKey:@"accreditation"];
        courseModel.association_name    =   [dic valueForKey:@"association_name"];
        courseModel.course_code         =   [dic valueForKey:@"course_code"];
        courseModel.date_of_submission  =   [dic valueForKey:@"date_of_submission"];
        courseModel.expiry_date         =   [dic valueForKey:@"expiry_date"];
        courseModel.lesson_id           =   [dic valueForKey:@"lesson_id"];
        courseModel.lesson_name         =   [dic valueForKey:@"lesson_name"];
        courseModel.lesson_summary      =   [dic valueForKey:@"lesson_summary"];
        courseModel.date_of_creation 	=   [dic valueForKey:@"start_date"];
        courseModel.total_points        =   [dic valueForKey:@"total_points"];
        courseModel.subcription         =   [dic valueForKey:@"subcription"];
        courseModel.association_pic     =   [dic valueForKey:@"association_pic"];
        courseModel.accreditation_url   =   [dic valueForKey:@"accreditation_url"];
        courseModel.pdf_result_url      =   [dic valueForKey:@"pdf_url"];
        courseModel.total_user          =   [dic valueForKey:@"number_of_user"];
        NSMutableArray *spAr            =   [dic valueForKey:@"speciality"];
        for (NSDictionary *spclDic in spAr){
            if(courseModel.speciality_ids == nil){
                courseModel.speciality_ids = [NSString stringWithFormat:@"%@",[spclDic valueForKey:@"speciality_id"]];
                courseModel.speciality_names = [NSString stringWithFormat:@"%@",[spclDic valueForKey:@"speciality_name"]];
                [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
            }else{
                courseModel.speciality_ids = [NSString stringWithFormat:@"%@,%@",courseModel.speciality_ids,[spclDic valueForKey:@"speciality_id"]];
                
                courseModel.speciality_names = [NSString stringWithFormat:@"%@, %@",courseModel.speciality_names,[spclDic valueForKey:@"speciality_name"]];
                
                [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
            }
        }
        
        if([[dic valueForKey:@"date_of_submission"] isEqualToString:@""]){
            courseModel.date_of_submission = @"0";
        }else{
            courseModel.date_of_submission  =   [dic valueForKey:@"date_of_submission"];
        }
        
        if([[dic valueForKey:@"remark"] isEqualToString:@""]){
            courseModel.remark = @"NA";
        }else{
            courseModel.remark  =   [dic valueForKey:@"remark"];
        }
        if((![courseModel.date_of_submission isEqualToString:@"0"]))
        {
            courseModel.isApiSync     =   @"1";
            courseModel.isSubmitted   =   @"1";
        }else{
            courseModel.isApiSync     =   @"0";
            courseModel.isSubmitted   =   @"0";
        }
        if(isNewCourse){
            [_data addObject:courseModel];
            [self.newcoursesArr addObject:courseModel];
            [self.courseTV reloadData];
        }else{
            // [_data addObject:courseModel];
            //   [self.completeCoursesArr addObject:courseModel];
            [self InsertLessonData:courseModel];   //Table Entry
        }
    }
}

#pragma mark - Data insert in Model
-(void)CourseModelUpdate:(CourseModel*)courseModel withValue:(NSDictionary*)dic{
    
    courseModel.association_name    =   [dic valueForKey:@"association_name"];
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
    NSMutableArray *spAr            =   [dic valueForKey:@"speciality"];
    //  NSMutableArray *queArr          =   [dic valueForKey:@"question_option"];
    
    for (NSDictionary *spclDic in spAr){
        if(courseModel.speciality_ids == nil){
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@",[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }else{
            courseModel.speciality_ids = [NSString stringWithFormat:@"%@,%@",courseModel.speciality_ids,[spclDic valueForKey:@"speciality_id"]];
            [self InsertSpecialityDataWithID:[spclDic valueForKey:@"speciality_id"] SpecialityName:[spclDic valueForKey:@"speciality_name"]];
        }
    }
    [self openCourseDetailView:courseModel.lesson_id downloadStat:courseModel.isDownload data:courseModel];
    //    [self updateLessionData:courseModel];  //Update Lesson Items
    //    [self loadData];
    //    [self.courseTV setContentOffset:CGPointMake(0, verticalContentOffset)];
}

#pragma mark - Lesson insert
-(void)InsertLessonData: (CourseModel *)model{
    NSString *assoName = [model.association_name stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    NSString *lessonName = [model.lesson_name stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    NSString *lessonSummary = [model.lesson_summary stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
    
    NSString *query= [NSString stringWithFormat:@"INSERT INTO  cme_lesson (association_name,course_code,expiry_date,lesson_id,lesson_name,lesson_summary,date_of_creation,total_points,specialities_Ids,isDownload,subcription,remarks,isSubmit,isApiSync,pdf_result_url,total_user,association_pic,accreditation_url,date_of_submission,exam_association) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@', ' %@' ,'%@' , '%@','%@', ' %@' ,'%@' , '%@','%@','');",assoName,model.course_code,model.expiry_date,model.lesson_id,lessonName,lessonSummary,model.date_of_creation,model.total_points,model.speciality_ids,@"0",model.subcription,model.remark, model.isSubmitted, model.isApiSync,model.pdf_result_url,model.total_user,model.association_pic,model.accreditation_url,model.date_of_submission];
    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        // NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        [self updateLessionData:model];
    }
}

-(void)updateLessionData:(CourseModel*)model
{
     NSString *query= [NSString stringWithFormat:@"UPDATE cme_lesson SET pdf_result_url = '%@' WHERE lesson_id = '%@'",model.pdf_result_url, model.lesson_id];
    [self.dbManager executeQuery:query];
    //  [self createDirectory:[NSString stringWithFormat:@"CME/%@",model.lesson_id]];
}

-(void)InsertSpecialityDataWithID: (NSString* )spID SpecialityName:(NSString*)name {
     NSString *query= [NSString stringWithFormat:@"INSERT INTO speciality (speciality_id,speciality_name) VALUES ('%@','%@');",spID,name];
    [self.dbManager executeQuery:query];
}

#pragma mark - Load Data
-(void)loadData{
    if(isNewCourse){
        if(self.newcoursesArr == nil){
            self.newcoursesArr = [[NSMutableArray alloc]init];
        }else{
            [self.newcoursesArr removeAllObjects];
        }
    }
    else {
        
        if(self.completeCoursesArr == nil){
            self.completeCoursesArr = [[NSMutableArray alloc]init];
        }else{
            [self.completeCoursesArr removeAllObjects];
        }
    }
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT _id,association_name,course_code,expiry_date,lesson_id,lesson_name,lesson_summary,date_of_creation,total_points,specialities_Ids,isDownload,subcription,isSubmit,remarks,association_pic,accreditation_url,pdf_result_url,total_user,document_name FROM cme_lesson"];
    
    if (dbResult != nil) {
        dbResult = nil;
    }
    
    dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    //NSLog(@"dbresult = %@",dbResult);
    
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
    NSInteger  indexOfSubmitted = [self.dbManager.arrColumnNames indexOfObject:@"isSubmit"];
    NSInteger  indexOfRemarks = [self.dbManager.arrColumnNames indexOfObject:@"remarks"];
    NSInteger  indexOfAssoPic = [self.dbManager.arrColumnNames indexOfObject:@"association_pic"];
    NSInteger  indexOfAccdURL = [self.dbManager.arrColumnNames indexOfObject:@"accreditation_url"];
    NSInteger  indexOfPDFURL = [self.dbManager.arrColumnNames indexOfObject:@"pdf_result_url"];
    NSInteger  indexOfTUser = [self.dbManager.arrColumnNames indexOfObject:@"total_user"];
    //    NSInteger  indexOfThumb = [self.dbManager.arrColumnNames indexOfObject:@"thumbnail"];
    //    NSInteger  indexOfDocName = [self.dbManager.arrColumnNames indexOfObject:@"document_name"];
    
    if(_fetchdata == nil) {
        _fetchdata = [NSMutableArray array];
    }
    for(NSArray *arr in dbResult){
        CourseModel *courseModel        =   [CourseModel new];
        courseModel.association_name    =   [arr objectAtIndex:indexOfAssoName];
        courseModel.course_code         =   [arr objectAtIndex:indexOfCCode];
        courseModel.expiry_date         =   [arr objectAtIndex:indexOfExpiryDate];
        courseModel.lesson_id           =   [arr objectAtIndex:indexOfLID];
        courseModel.lesson_name         =   [arr objectAtIndex:indexOfLname];
        courseModel.lesson_summary      =   [arr objectAtIndex:indexOfLSummary];
        courseModel.date_of_creation 	=   [arr objectAtIndex:indexOfDOC];
        courseModel.total_points        =   [arr objectAtIndex:indexOfPoints];
        courseModel.subcription         =   [arr objectAtIndex:indexOfSubcription];
        courseModel.isDownload          =   [arr objectAtIndex:indexOfDownload];
        courseModel.isSubmitted         =   [arr objectAtIndex:indexOfSubmitted];
        courseModel.remark              =   [arr objectAtIndex:indexOfRemarks];
        courseModel.association_pic     =   [arr objectAtIndex:indexOfAssoPic];
        courseModel.accreditation_url   =   [arr objectAtIndex:indexOfAccdURL];
        courseModel.pdf_result_url      =   [arr objectAtIndex:indexOfPDFURL];
        courseModel.total_user          =   [arr objectAtIndex:indexOfTUser];
        //    courseModel.documentName        =   [arr objectAtIndex:indexOfDocName];
        //    courseModel.thumbnail           =   [arr objectAtIndex:indexOfThumb];
        
        
        //        courseModel.association_pic     =   [dic valueForKey:@"association_pic"];
        //        courseModel.accreditation_url   =   [dic valueForKey:@"accreditation_url"];
        //        courseModel.pdf_result_url      =   [dic valueForKey:@"pdf_url"];
        //        courseModel.total_user          =   [dic valueForKey:@"number_of_user"];
        //        NSMutableArray *spAr            =   [dic valueForKey:@"speciality"];
        
        
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
        if(isNewCourse){
            if([courseModel.isSubmitted isEqualToString:@"0"]){
                [self.newcoursesArr addObject:courseModel];
            }
        }
        else {
            if([courseModel.isSubmitted isEqualToString:@"1"]||[courseModel.isSubmitted isEqualToString:@"2"]){
                [self.completeCoursesArr addObject:courseModel];
            }
        }
    }
//    if(self.completeCoursesArr.count == 0){
//        self.emptyView.hidden = false;
//        self.lbl_emptyview.text = cmeCompletedEmpty;
//    }else{
//        self.emptyView.hidden = true;
//    }
    [self.courseTV reloadData];
    
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

-(BOOL)downloadCheckForLessonID:(NSString *)lID{
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT _id,isDownload FROM cme_lesson WHERE lesson_id = '%@'",lID];
    if (dbResult != nil) {
        dbResult = nil;
    }
    dbResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:selectQuery]];
    // NSLog(@"dbresult = %@",dbResult);
    if(dbResult.count > 0){
        NSInteger  indexOfDownload = [self.dbManager.arrColumnNames indexOfObject:@"isDownload"];
        NSString *isdwnld = [[dbResult objectAtIndex:0] objectAtIndex:indexOfDownload];
        if([isdwnld isEqualToString:@"1"]){
            return YES;;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

-(IBAction)buttonChangedonClick:(UIButton *)sender{
    self.emptyView.hidden = true;
    courses_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    alreadytaken_button.titleLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1];
    if (1 == sender.tag) {
        if ([availCourseStatus isEqualToString:@"8"]) {
            isShowSampleCourse = YES;
        }else{
            isShowSampleCourse = NO;
        }
        // compCourseContentOffset = self.courseTV.contentOffset.y;
        isNewCourse = YES;
        [self.courseTV insertSubview: refreshControl atIndex:0];
        self.newcoursesArr.count>=10?[self.courseTV setShowsPullToRefresh:isSetPullOnAvC]:nil;
        __weak AvailableCourseVC *weakSelf = self;
        [self.courseTV addPullToRefreshWithActionHandler:^{
            [weakSelf getUserCourseListRequestWithType:@""];
        }
        position:SVPullToRefreshPositionBottom];
        [self removeBottom:sender];
        [self addBottom:sender];
        courses_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
        alreadytaken_button.titleLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1];
        [self deselectModeSender:alreadytaken_button];
        [self callingGoogleAnalyticFunction:@"CME Screen" screenAction:@"New Courses Tab"];
        courses_button.selected =YES;
        alreadytaken_button.selected =NO;
        if ([self.newcoursesArr count]==0) {
             if([AppDelegate appDelegate].isInternet){
//                [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
                dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
                dispatch_async(downloadQueue, ^{
                    //your data loading
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getUserCourseListRequestWithType:@""];
                        // //maybe some visual data reloading that should be run in the main thread
                    });
                });

            }else{
                [self loadData];
            }
        }
        else{
            // nilView.hidden =YES;
            // [self.courseTV setContentOffset:CGPointMake(0, newcourseContentOffset)];
            [self.courseTV reloadData];
        }
    }
    else{
    [self callingGoogleAnalyticFunction:@"CME Screen" screenAction:@"Completed Courses Tab"];
        [Localytics tagEvent:@"CME Completed courses"];
        // newcourseContentOffset  = self.courseTV.contentOffset.y;
        isNewCourse = NO;
        isShowSampleCourse = NO;
        [self.courseTV insertSubview: refreshControl atIndex:0];
        courses_button.titleLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:145.0/255.0 blue:146.0/255.0 alpha:1];
        alreadytaken_button.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
        alreadytaken_button.selected =YES;
        courses_button.selected =NO;
        [self removeBottom:sender];
        [self addBottom:sender];
        [self deselectModeSender:courses_button];
        [self.courseTV insertSubview: refreshControl atIndex:0];
        self.completeCoursesArr.count>=10?[self.courseTV setShowsPullToRefresh:isSetPullOnComC]:nil;
        __weak AvailableCourseVC *weakSelf = self;
        [self.courseTV addPullToRefreshWithActionHandler:^{
            [weakSelf getUserCourseListRequestWithType:@"subscribe"];
        }position:SVPullToRefreshPositionBottom];
        if ([self.completeCoursesArr count]==0) {
             if([AppDelegate appDelegate].isInternet){
//                [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
                 dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
                 dispatch_async(downloadQueue, ^{
                     //your data loading
                     dispatch_async(dispatch_get_main_queue(), ^{
                        [self getUserCourseListRequestWithType:@"subscribe"];
                         // //maybe some visual data reloading that should be run in the main thread
                     });
                 });

            }
            else
            {
                [self loadData];
            }
        }
        else{
            // nilView.hidden =YES;
            // [self.courseTV setContentOffset:CGPointMake(0, compCourseContentOffset)];
            [self.courseTV reloadData];
        }
    }
}

-(void)addBottom:(UIButton *)sender{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height-3, sender.frame.size.width, 3)];
    lineView.backgroundColor = [UIColor colorWithRed:0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    lineView.tag = 1112;
    [sender addSubview:lineView];
}

-(void)deselectModeSender:(UIButton*)sender{
    [sender setTitleColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    UIView *border = (UIView*)[sender viewWithTag:1112];
    [border removeFromSuperview];
}

#pragma mark - remove bottom from superview
-(void)removeBottom:(UIButton*)btn{
    for (UIView *view in btn.subviews) {
        if (view.tag == 1112) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Create Directory
-(void) createDirectory : (NSString *) dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    self.dataPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:dirName];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:self.dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
        // NSLog(@"Couldn't create directory error: %@", error);
    }
    else {
        // NSLog(@"directory created!");
    }
    //  NSLog(@"dataPath : %@ ",self.dataPath); // Path of folder created
}

-(void) updateCMEListing:(CourseModel*)model{
    if(isNewCourse){
        if (([model.subcription isEqualToString:@"0"] && [model.isSubmitted isEqualToString:@"0"]) || ([model.subcription isEqualToString:@"1"] && [model.isSubmitted isEqualToString:@"0"])) {
            [self.newcoursesArr removeObjectAtIndex:selectedIndex];
            [self.newcoursesArr insertObject:model atIndex:selectedIndex];
        }else{
            [self.newcoursesArr removeObjectAtIndex:selectedIndex];
            [self.completeCoursesArr addObject:model];
            [self buttonChangedonClick:self.alreadytaken_button];
            [self.courseTV reloadData];
            return;
        }
    }else{
        [self.completeCoursesArr removeObjectAtIndex:selectedIndex];
        [self.completeCoursesArr insertObject:model atIndex:selectedIndex];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:selectedIndexPath.section];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.courseTV reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"updateCourseTable" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateCourseTable"]) {
        // NSLog (@"Successfully received the test notification!");
        [self.courseTV reloadData];
    }
  }

-(void)emptyViewShowWithText:(NSString *)text WithFlag:(BOOL)Flag{
    self.emptyView.hidden = !Flag;
    self.lbl_emptyview.text = [self parsingHTMLText:text];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    PermissionCheckYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"PermissionCheckYourSelfVC"];
    selfVerify.titleMsg = stusmsg;
    selfVerify.titledesc = InviteCodeTyp;
    selfVerify.tf_placeholder = InviteCodeExample;
    selfVerify.IcnumberValue = ICNumber;
    selfVerify.idetityValue = Identity;
    selfVerify.identityTypMsg = IdentityMsg;
    [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

-(void)hideLoader{
    blankloaderview.hidden = YES;
}

-(void)showLoader{
    blankloaderview.hidden = NO;
}

-(NSString*)parsingHTMLText:(NSString*)text{
    text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}

@end
