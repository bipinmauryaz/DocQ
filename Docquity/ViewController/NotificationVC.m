//
//  NotificationVC.m
//  Docquity
//
//  Created by Arimardan Singh on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NotificationVC.h"
#import "NotificationTVCell.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "Localytics.h"
#import "CourseModel.h"
#import "UILoadingView.h"
#import "PermissionCheckYourSelfVC.h"
#import "UserTimelineVC.h"
#import "NewProfileVC.h"
#import "ProfileData.h"

@interface NotificationVC ()
{
    int notify_pageCount;
    UIRefreshControl*refreshControl;
    NSString*_processedMsgId;
    NSString*permstus;
}

@end
@implementation NotificationVC
@synthesize notificationTblVw;
@synthesize notify_detailsArr,nilView,indicator;
- (void)viewDidLoad
{
    [super viewDidLoad];
    notify_pageCount = 1;
    self.notify_detailsArr = [[NSMutableArray alloc]init];
    self.notificationTblVw.backgroundView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    
    self.notificationTblVw.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    // Initialize the refresh control.
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor =  [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor lightGrayColor];
    //[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshNotification)
              forControlEvents:UIControlEventValueChanged];
    [self.notificationTblVw insertSubview: refreshControl atIndex:0];
    __weak NotificationVC *weakSelf = self;
    [self.notificationTblVw addPullToRefreshWithActionHandler:^{
       // [Localytics tagEvent:@"NotificationsList PullDown"];
        //Call Notification list here
        [weakSelf  getNotificationsListRequest];
    }
    position:SVPullToRefreshPositionBottom];
    
    [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
          //your data loading
        dispatch_async(dispatch_get_main_queue(), ^{
              [self getNotificationsListRequest];
           // //maybe some visual data reloading that should be run in the main thread
        });
    });
    //dispatch_release(downloadQueue);

}

- (void)refreshNotification
{
   //Reload table data
    is_topRefreshing =YES;
    notify_pageCount = 1;
    if (self.notify_detailsArr == nil)
    {
        self.notify_detailsArr = [[NSMutableArray alloc]init];
    }
    [self getNotificationsListRequest];
    [self.notificationTblVw reloadData];

    // End the refreshing
    if (refreshControl) {
    // [Localytics tagEvent:@"NotificationList PullUP"];
        NSString *title = [NSString stringWithFormat:@"Refreshing..."];
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [Localytics tagEvent:@"Notification Tab Click"];
    indicator = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    indicator.hidden = NO;
    UIBarButtonItem* spinner = [[UIBarButtonItem alloc] initWithCustomView: indicator];
    self.navigationItem.rightBarButtonItem = spinner;
    [indicator setHidesWhenStopped:YES];
     [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];
    self.navigationItem.title = @"Notifications";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
}

-(void)viewWillDisappear:(BOOL)animated{
   // self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
   // self.navigationController.navigationBar.translucent = YES;
   // self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
  //  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notify_detailsArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
    static NSString *simpleTableIdentifier = @"NotificationTVCell";
    NotificationTVCell *notifycell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (notifycell == nil) {
    notifycell = [[NotificationTVCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    //notifycell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        NSDictionary *notifyDic;
        notificationTblVw.hidden=NO;
        notifyDic= self.notify_detailsArr [indexPath.row];
       NSString*notify_status =   [notifyDic objectForKey:@"read_status"];
        if ([notify_status isEqualToString:@"read"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // NSLog(@"responseObject sesson= %@",json);
               notifycell.backgroundColor = [UIColor whiteColor];
            });
            //backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"notify_bg.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                // NSLog(@"responseObject sesson= %@",json);
                notifycell.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:245.0/255.0 blue:254.0/255.0 alpha:1.0];
            });

                }
        [notifycell setInfo:notifyDic];
       // if ( indexPath.row % 2 == 0 )
          //  notifycell.backgroundColor = [UIColor orangeColor];
        //else
           // notifycell.backgroundColor = [UIColor redColor];
            return notifycell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[self.notify_detailsArr count]){
    NSDictionary *dict = [self.notify_detailsArr objectAtIndex: indexPath.row];
    _processedMsgId=  [dict objectForKey:@"message_id"];
    NSString*notify_tatgetId =  [dict objectForKey:@"target_id"];
    NSString*notify_identifier =  [dict objectForKey:@"identifier"];
    NSString*notify_status =   [dict objectForKey:@"read_status"];
    if (indexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
         else{
            if ([notify_identifier isEqualToString:@"feed"]) {
                if(notify_tatgetId == nil || [notify_tatgetId isEqualToString:@""]){
                 [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                [[AppDelegate appDelegate] navigateToTabBarScren:0];
                if ([notify_status isEqualToString:@"unread"]) {
                        NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                        NSError * error;
                        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                        // NSLog(@"jsonString =%@",jsonString);
                        [self setReadNotification:jsonString];
                }
            }
                else{
                    [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                    [self getFeedDetailsRequest:notify_tatgetId];
                    if ([notify_status isEqualToString:@"unread"]) {
                    NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                    NSError * error;
                    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                   // NSLog(@"jsonString =%@",jsonString);
                    [self setReadNotification:jsonString];
                    }
                  }
                }
              else if ([notify_identifier isEqualToString:@"cme"]) {
                    if(notify_tatgetId == nil || [notify_tatgetId isEqualToString:@""]){
                     [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                     [[AppDelegate appDelegate] navigateToTabBarScren:1];
                    if ([notify_status isEqualToString:@"unread"]) {
                        NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                        NSError * error;
                        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                        
                        // NSLog(@"jsonString =%@",jsonString);
                        [self setReadNotification:jsonString];
                    }
                  }
                else{
                   // [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                    [self openCourseDetailView:notify_tatgetId];
                    if ([notify_status isEqualToString:@"unread"]) {
                        NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                        NSError * error;
                        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                        //NSLog(@"jsonString =%@",jsonString);
                        [self setReadNotification:jsonString];
                    }
                }
            }
              else if ([notify_identifier isEqualToString:@"upgrade"]) {
                  if(notify_tatgetId == nil || [notify_tatgetId isEqualToString:@""]){
                       [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                      if ([notify_status isEqualToString:@"unread"]) {
                          NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                          NSError * error;
                          NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                          NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                          //NSLog(@"jsonString =%@",jsonString);
                          [self setReadNotification:jsonString];
                       }
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://apple.co/1TJwLM6"]];
                    }
                  else{
                       [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                      if ([notify_status isEqualToString:@"unread"]) {
                          NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                          NSError * error;
                          NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                          NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                          //NSLog(@"jsonString =%@",jsonString);
                          [self setReadNotification:jsonString];
                            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://apple.co/1TJwLM6"]];
                      }
                  }
              }
              else if ([notify_identifier isEqualToString:@"profile"]) {
                  if(notify_tatgetId == nil || [notify_tatgetId isEqualToString:@""]){
                      [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                      [self openProfileView];
                     // [[AppDelegate appDelegate] navigateToTabBarScren:1];
                      if ([notify_status isEqualToString:@"unread"]) {
                          NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                          NSError * error;
                          NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                          NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                          
                          // NSLog(@"jsonString =%@",jsonString);
                          [self setReadNotification:jsonString];
                      }
                  }
                  else{
                       [AppDelegate appDelegate].isComeFromNotificationScreen =YES;
                     // [self openCourseDetailView:notify_tatgetId];
                      if ([notify_status isEqualToString:@"unread"]) {
                          NSArray* arrayOfStrings = [_processedMsgId componentsSeparatedByString:@","];
                          NSError * error;
                          NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:arrayOfStrings  options:NSJSONWritingPrettyPrinted error:&error];
                          NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
                          //NSLog(@"jsonString =%@",jsonString);
                          [self setReadNotification:jsonString];
                      }
                  }
              }
         }
    }
 }
}

#pragma mark - open Course Details View From Notification Screen
- (void)openCourseDetailView:(NSString*)lessionID{
    if (_courseDetailControllerRefrence != nil) {
        //First remove _courseDetailControllerRefrence without animation and push
        [_courseDetailControllerRefrence.navigationController popViewControllerAnimated:NO];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    CourseDetailVC *courseDetail = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:courseDetail];
    courseDetail.lessionID = lessionID;
    courseDetail.btnShow = YES;
    CourseModel *cModel = [CourseModel new];
    cModel.lesson_id = lessionID;
    courseDetail.model = cModel;
    courseDetail.hidesBottomBarWhenPushed = YES;
    courseDetail.isShowdownloadedData = @"0";
    courseDetail.isNoifPView = YES;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController pushViewController:courseDetail animated:YES];
 }

#pragma mark - getNotificationsListRequest
-(void)getNotificationsListRequest{
   NSString *pagestring = [NSString stringWithFormat:@"%d",notify_pageCount];
    NSUserDefaults *userDef =[NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getNotificationListRequestWithAuthKey:[userDef valueForKey:userAuthKey] offset:pagestring limit:@"10" device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion]  lang:kLanguage callback:^(NSDictionary* responceObject, NSError* error) {
      [[AppDelegate appDelegate] hideIndicator];
     //   NSLog(@" notification list %@",responceObject);
        if ([pagestring isEqualToString:@"1"]) {
            if (is_topRefreshing==YES) {
                is_topRefreshing = NO;
            }
            else{
                [[self.view.subviews lastObject] removeFromSuperview]; //removes the UILoadingView
                // [[AppDelegate appDelegate] showIndicator];
            }
        }
        [refreshControl endRefreshing];
        [self.notificationTblVw.pullToRefreshView stopAnimating];
        self.notificationTblVw.tableFooterView = nil;
        NSDictionary *resposeCode=[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                NSDictionary *notifyInfoDic=[resposeCode objectForKey:@"data"];
                if ([notifyInfoDic isKindOfClass:[NSNull class]]||notifyInfoDic == nil)
                {
                    // tel is null
                }
                else {
                    notify_pageCount==1?[self.notify_detailsArr removeAllObjects]:nil;
                    notify_pageCount ==1?[refreshControl endRefreshing]:nil;
                    NSMutableArray *temparr = [[NSMutableArray alloc]init];
                    temparr= [[notifyInfoDic objectForKey:@"notification_list"] mutableCopy];
                    if ([temparr count]==0) {
                        self.notificationTblVw.hidden = YES;
                        self.nilView.hidden = NO;
                        nilLbl.hidden = NO;
                    }
                    else {
                        lbl_notifyStatus.hidden =YES;
                        if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                        {
                            //more data found
                            for(int i=0; i<[temparr count]; i++){
                                NSDictionary *NotificationListInfo = temparr[i];
                                if (NotificationListInfo != nil && [NotificationListInfo isKindOfClass:[NSDictionary class]]) {
                                }
                                [self.notify_detailsArr addObject:NotificationListInfo];
                              }
                            self.notificationTblVw.hidden = NO;
                            self.nilView.hidden = YES;
                            nilLbl.hidden = YES;
                            [self.notificationTblVw reloadData];
                            notify_pageCount++;
                        }
                    }
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 5)
            {
                [[AppDelegate appDelegate]ShowPopupScreen];
            }
            else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
            {
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 7){
                if (notify_pageCount==1) {
                    self.nilView.hidden = NO;
                    self.notificationTblVw.hidden = YES;
                    nilLbl.hidden = NO;
                    nilLbl.text = @"You have no notifications.";
                    [refreshControl endRefreshing];
                }
                [self.notificationTblVw setShowsPullToRefresh:NO];
            }
            else{
                self.notificationTblVw.hidden =YES;
                self.nilView.hidden = NO;
                nilLbl.hidden = NO;
                nilLbl.text = @"You have no notifications.";
            }
        }
    }];
}

#pragma mark - getFeedDetailsRequest api calling
-(void)getFeedDetailsRequest:(NSString*)feedId{
   [indicator startAnimating];
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]singlefeedRequest:[userdef valueForKey:userAuthKey] feed_id:feedId device_type:kDeviceType app_version:[userdef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
         [indicator stopAnimating];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                //NSLog(@"Feed response for feed_id %@ = %@",feedId,resposePost);
                [self openSingleFeedView:resposePost.mutableCopy];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

- (void)openSingleFeedView:(NSMutableDictionary*)feedDict{
    if (_NewCommentRefrence != nil) {
        //First remove NewCommentRefrence without animation and push
        [_NewCommentRefrence.navigationController popViewControllerAnimated:NO];
    }
    NSMutableDictionary *feed = [feedDict valueForKey:@"data"][@"feed"];
    NSString *tlike =  [feed objectForKey:@"total_like"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    NewCommentVC *newcomment = [storyboard instantiateViewControllerWithIdentifier:@"NewCommentVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newcomment];
    newcomment.feedDict = feed;
    newcomment.isNoifPView = YES;
    newcomment.t_likeStr = tlike;
    newcomment.hidesBottomBarWhenPushed = YES;
    newcomment.delegate = self;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [nav setNavigationBarHidden:NO animated:NO];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = kThemeColor;
    [nav.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController pushViewController:newcomment animated:YES];
    //self.window.rootViewController = nav;
}

#pragma mark -invite All method
- (void)setReadNotification:(NSString*)messageIds{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]setReadNotificationRequestWithAuthKey:[userdef valueForKey:userAuthKey] message_id_json:messageIds device_type:kDeviceType app_version:[userdef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            
          //  NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
               // UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:OK_STRING otherButtonTitles: nil];
                //[alert show];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
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
            if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
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
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:@"OK" autoDismissFlag:NO];
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


#pragma mark - OpenProfileView
-(void)openProfileView{
    //Profile Tab Config
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *custmId=[userpref objectForKey:ownerCustId];
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custmId;
    NewProfile.delegate = self;
    NewProfile.hidesBottomBarWhenPushed = YES;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

@end
