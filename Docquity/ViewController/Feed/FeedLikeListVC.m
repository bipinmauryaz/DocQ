/*============================================================================
 PROJECT: Docquity
 FILE:    FeedLikeListVC.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 05/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "FeedLikeListVC.h"
#import "AppDelegate.h"
#import "DefineAndConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NewProfileVC.h"
#import "Reachability.h"
#import "Localytics.h"
#import "SVPullToRefresh.h"
#import "DocquityServerEngine.h"
#import "PermissionCheckYourSelfVC.h"
#import "UserTimelineVC.h"
#import "NSString+HTML.h"
/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 Interface: FeedLikeListVC
 =============================================================================*/
@interface FeedLikeListVC (){
    int likepageContent; //page number/number of cells visble to user now
    NSString*permstus;
}
@end

@implementation FeedLikeListVC
@synthesize feedlikeListArr,feedlikeTV,feedLikeTVCell;
@synthesize feedLikeIdStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 1;
    limitpost = 10;
    self.navigationController.navigationBarHidden=YES;
    self.feedlikeTV.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.feedlikeTV.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    stslLbl.hidden =YES;
    UIView *topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    topbar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    UIButton *backBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBarbtn.frame =CGRectMake(8, 28, 28, 28);
    [backBarbtn addTarget:self action:@selector(BackView:) forControlEvents:UIControlEventTouchUpInside];
    [backBarbtn setImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal];
    
    [topbar addSubview:backBarbtn];
    [self.view addSubview:topbar];
    UILabel *titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 34)];
    
    titlelbl.textColor = [UIColor whiteColor];
    titlelbl.backgroundColor = [UIColor clearColor];
    titlelbl.font  = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titlelbl.textAlignment =  NSTextAlignmentCenter;
    titlelbl.text = @"Likes";
    UITapGestureRecognizer *singletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(BackView:)];
    singletap.numberOfTapsRequired = 1;
    [topbar addGestureRecognizer:singletap];
    [topbar addSubview:titlelbl];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    self.feedlikeTV.tableFooterView = spinner;
    self.feedlikeListArr = [[NSMutableArray alloc]init];
   
    likepageContent = 1; //initial state of page that control should start 0 to limit 10
    __weak FeedLikeListVC *weakSelf = self;
    [self.feedlikeTV addPullToRefreshWithActionHandler:^{
        if([weakSelf.dataFor isEqualToString:@"comment"]){
            [weakSelf GetCommentLikeList];
        }else{
            [weakSelf getFeedLikeListRequestApi];
        }
    }
    position:SVPullToRefreshPositionBottom];
    if([self.dataFor isEqualToString:@"comment"]){
        [self GetCommentLikeList];
    }else{
        [self getFeedLikeListRequestApi];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.feedlikeTV.contentOffset = CGPointMake(0.0, 0.0);
    self.feedlikeTV.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [Localytics tagEvent:@"WhatsTrending CommentScreen LikeListScreen"];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - backBtn Action
-(void)BackView:(UIButton*)sender{
    [[AppDelegate appDelegate] getPlaySound];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  [self.feedlikeListArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return heights of rows
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSArray *nib;
    NSString *cellID = @"FeedLikeCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"FeedLikeCell" owner:self options:nil];
        if([nib count] > 0)
        {
            cell = self.feedLikeTVCell;
        }
    }
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *u_Name =nil;
    NSString*spclity = nil;
    NSString*userPic =nil;
    if([self.feedlikeListArr count]>0)
    {
        if([self.feedlikeListArr objectAtIndex:indexPath.row]){
            NSDictionary*feedlikeDic=[self.feedlikeListArr objectAtIndex:indexPath.row];
            if(feedlikeDic && [feedlikeDic isKindOfClass:[NSDictionary class]])
            {
                u_Name = [NSString stringWithFormat:@"%@", [feedlikeDic objectForKey:@"name"]?[feedlikeDic  objectForKey:@"name"]:@""];
                NSString *jbIdStr = [NSString stringWithFormat:@"%@", [feedlikeDic objectForKey:@"feeder_jabber_id"]?[feedlikeDic objectForKey:@"feeder_jabber_id"]:@""];
                NSString*jbId = [jbIdStr lowercaseString];
             //   NSLog(@"%@",jbId);
                NSString *d_Name = [[[u_Name stringByDecodingHTMLEntities] stringByDecodingHTMLEntities]capitalizedString];
                NSString *cust_id =[NSString stringWithFormat:@"%@",[feedlikeDic objectForKey:@"custom_id"]?[feedlikeDic objectForKey:@"custom_id"]:@""];
                
               // NSLog(@"%@",cust_id);
                userPic = [NSString stringWithFormat:@"%@",[feedlikeDic objectForKey:@"profile_pic_path"]?[feedlikeDic objectForKey:@"profile_pic_path"]:@""];
                
                spclity = [NSString stringWithFormat:@"%@", [feedlikeDic objectForKey:@"speciality_name"]?[feedlikeDic  objectForKey:@"speciality_name"]:@""];
                spclity = [[spclity stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
                if ([spclity  isEqualToString:@""] || [spclity  isEqualToString:@"<null>"]) {
                }
                else {
                    spclLbl= (UILabel *)[cell viewWithTag:504];
                    if(spclity != (id)[NSNull null])
                        spclLbl.text=spclity;
                    else
                        spclLbl.text=@" ";
                }
                usrNameLbl= (UILabel *)[cell viewWithTag:502];
                if(d_Name != (id)[NSNull null])
                    usrNameLbl.text=d_Name;
                else
                    usrNameLbl.text=@" ";
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:501];
                [imageView sd_setImageWithURL:[NSURL URLWithString:userPic]
                             placeholderImage:[UIImage imageNamed:@"avatar.png"]
                                      options:SDWebImageRefreshCached];
                
                //set cell Image View Radius corner
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.cornerRadius = imageView.frame.size.width / 2;
                imageView.clipsToBounds = YES;
                
                UITapGestureRecognizer *taponUserNameLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
                [usrNameLbl addGestureRecognizer:taponUserNameLabel];
                [usrNameLbl setUserInteractionEnabled:YES];
                
                UITapGestureRecognizer *taponUserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
                [imageView addGestureRecognizer:taponUserImg];
                [imageView setUserInteractionEnabled:YES];
                
                UITapGestureRecognizer *taponspclNameLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
                [spclLbl addGestureRecognizer:taponspclNameLabel];
                [spclLbl setUserInteractionEnabled:YES];
            }
        }
    }
    return cell;
}

#pragma mark - open profileView Action
- (void)openProfileView:(UITapGestureRecognizer*)gesture
{
    [Localytics tagEvent:@"WhatsTrending CommentScreen LikeListScreen ProfileView Click"];
    CGPoint location = [gesture locationInView:self.feedlikeTV];
    NSIndexPath *tapedIndexPath = [self.feedlikeTV indexPathForRowAtPoint:location];
    NSDictionary *feeddict = [self.feedlikeListArr objectAtIndex:tapedIndexPath.row];
    NSString*custom_uId =  [feeddict objectForKey:@"custom_id"];
    NSString*feedjabId =  [feeddict objectForKey:@"feeder_jabber_id"];
    if (tapedIndexPath != nil)
    {
        //Update like status.. Check Network connection
        Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NoInternetTitle message:NoInternetMessage delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
        UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
        //  NewProfile.userJabberId = feedjabId;
        NewProfile .custid=  custom_uId;
        [AppDelegate appDelegate].isComeFromSettingVC = YES;
        [self.navigationController pushViewController:NewProfile animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - get feed like list api calling
-(void)getFeedLikeListRequestApi{
    NSString *pagestring = [NSString stringWithFormat:@"%d", likepageContent];
    if ([pagestring isEqualToString:@"1"]) {
    }
    NSUserDefaults *userDef =[NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]feedLikeListAPI:[userDef valueForKey:userAuthKey] feed_id:self.feedLikeIdStr app_version:[userDef valueForKey:kAppVersion] lang:kLanguage offset:pagestring limit:@"10" callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"%@",responceObject);
        [self.feedlikeTV.pullToRefreshView stopAnimating];
        self.feedlikeTV.tableFooterView = nil;
        NSDictionary *resposeCode=[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]||resposeCode ==nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                NSDictionary *feedlikeDic=[resposeCode objectForKey:@"data"];
                if ([feedlikeDic isKindOfClass:[NSNull class]]||feedlikeDic == nil)
                {
                    // tel is null
                }
                else {
                    NSMutableArray *temparr = [[NSMutableArray alloc]init];
                    temparr= [[feedlikeDic objectForKey:@"like"] mutableCopy];
                    if ([temparr count]==0) {
                        self.feedlikeTV.hidden = YES;
                    }
                    else {
                        stslLbl.hidden =YES;
                        if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                        {
                            //more data found
                            for(int i=0; i<[temparr count]; i++){
                                NSDictionary *feedLikeListInfo = temparr[i];
                                if (feedLikeListInfo != nil && [feedLikeListInfo isKindOfClass:[NSDictionary class]]) {
                                }
                                [self.feedlikeListArr addObject:feedLikeListInfo];
                            }
                            [self.feedlikeTV reloadData];
                            likepageContent++;
                        }
                    }
                }
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[resposeCode valueForKey:@"status"]integerValue] == 7){
                [self.feedlikeTV setShowsPullToRefresh:NO];
            }
            
            else  if([[resposeCode valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory;
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
             else{
                self.feedlikeTV.hidden =YES;
                stslLbl.hidden = NO;
                stslLbl.text = @"Oops! No Doctor like this.";
            }
        }
    }];
}

#pragma mark - get comment like list
-(void)GetCommentLikeList{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]feedcommentlikelistRequestWithAuthKey:[userDef valueForKey:userAuthKey] feed_id:self.feedLikeIdStr comment_id:self.feedCommentID app_version:[userDef valueForKey:kAppVersion] lang:kLanguage offset:[NSString stringWithFormat:@"%ld",(long)offset] limit:[NSString stringWithFormat:@"%ld",(long)limitpost] callback:^(NSDictionary *responceObject, NSError *error) {
        NSMutableDictionary *responsePost =[[responceObject objectForKey:@"posts"] mutableCopy];
        if ([responsePost isKindOfClass:[NSNull class]] || responsePost == nil)
        {
            // Response is null
        }
        else {
            // NSLog(@"response from comment = %@",responsePost);
            [self.feedlikeTV.pullToRefreshView stopAnimating];
            self.feedlikeTV.tableFooterView = nil;
            if([[responsePost valueForKey:@"status"]integerValue] == 1)
            {
                if(feedlikeListArr == nil){
                    feedlikeListArr = [[NSMutableArray alloc]init];
            }
                NSMutableArray *likeArr = [[responsePost valueForKey:@"data"] valueForKey:@"like"];
                for (NSMutableDictionary *tempLikeDic in likeArr) {
                    [feedlikeListArr addObject:tempLikeDic];
            }
                [self.feedlikeTV reloadData];
                offset ++;
            }
            else  if([[responsePost valueForKey:@"status"]integerValue] == 7)
            {
                [self.feedlikeTV setShowsPullToRefresh:NO];
            }
            else  if([[responsePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate] logOut];
            }
            
            else  if([[responsePost valueForKey:@"status"]integerValue] == 11)
            {
                NSString*userValidateCheck = @"readonly";
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory;
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
            }
            
            else{
            [UIAppDelegate alerMassegeWithError:[responsePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
