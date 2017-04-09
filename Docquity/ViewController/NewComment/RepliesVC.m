//
//  RepliesVC.m
//  Docquity
//
//  Created by Docquity-iOS on 28/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "RepliesVC.h"
#import "RepliesCell.h"
#import "NSString+HTML.h"
#import "DefineAndConstants.h"
#import "UIImageView+WebCache.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"
#import "UIViewController+KeyboardAnimation.h"
#import "Localytics.h"
#import "WebVC.h"
#import "MailActivity.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "SSCWhatsAppActivity.h"
#import "FeedLikeListVC.h"
#import "editCommentVC.h"
#import "SVPullToRefresh.h"
#import "PermissionCheckYourSelfVC.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"

@interface RepliesVC (){
    
    NSString * permstus;
}
@property(nonatomic, strong)NSMutableArray <RepliesModel *> *data;
@end

@implementation RepliesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 1;
    selectedRow = 0;
    isEdit = NO;
    isDelete = NO;
    isLike = NO;
    limit = @"10";
    _replyArray = [[NSMutableArray alloc]init];
    _replyArray = [self.commentDic valueForKey:@"reply"];
    self.commentid = [self.commentDic valueForKey:@"comment_id"];
    if(_data == nil) {
        _data = [NSMutableArray array];
    }
    for (NSMutableDictionary *dic in self.replyArray) {
        RepliesModel *replyModel = [RepliesModel new];
        replyModel.userName = [dic valueForKey:@"name"];
        replyModel.reply_id = [dic valueForKey:@"comment_reply_id"];
        replyModel.replyer_jabber_id = [dic valueForKey:@"comment_replyer_jabber_id"];
        replyModel.custom_id = [dic valueForKey:@"custom_id"];
        replyModel.commentDate = [dic valueForKey:@"date_of_creation"];
        replyModel.userImgUrl = [dic valueForKey:@"profile_pic_path"];
        replyModel.commentContent = [dic valueForKey:@"reply_comment"];
        replyModel.like_status = [dic valueForKey:@"reply_like_status"];
        replyModel.total_reply_like = [dic valueForKey:@"total_reply_like"];
        replyModel.replyer_user_id = [dic valueForKey:@"commented_by"];
        [_data addObject:replyModel];
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    self.tableView.tableFooterView = spinner;
    
    __weak RepliesVC *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [Localytics tagEvent:@"WhatsTrending PullDown"];
        //Call Feeds here
        [weakSelf getlistCommentReply];
    }position:SVPullToRefreshPositionBottom];
    [self getlistCommentReply];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Replies";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica SemiBold" size:16.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width - 70, 32)];
    
    commentTextView.textContainer.lineFragmentPadding = 8;
    //   commentTextView.contentInset = UIEdgeInsetsMake(0, 4, 0, 0);
    //    [commentTextView setTextContainerInset:0,4,0,0];
    commentTextView.delegate = self;
    commentTextView.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
    commentTextView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    commentTextView.layer.cornerRadius = 4.0;
    commentTextView.layer.borderWidth = 0.5f;
    commentTextView.font = [UIFont systemFontOfSize:13.0];
    
    placeholder = [[UILabel alloc]initWithFrame:CGRectMake(8, 1, commentTextView.frame.size.width, 30)];
    placeholder.font = [UIFont systemFontOfSize:13.0];
    placeholder.textColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
    [commentTextView addSubview:placeholder];
    BOOL isSelfCommenter = NO;
    if([[[NSUserDefaults standardUserDefaults]valueForKey:userId]isEqualToString:[self.commentDic valueForKey:@"commented_by"]]){
        isSelfCommenter = YES;
    }
    NSString *commenterName = [self.commentDic valueForKey:@"name"];
    commenterName = isSelfCommenter?@"your comment":commenterName;
    placeholder.text = [NSString stringWithFormat:@"Replying to %@",commenterName];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:commentTextView];
    
    //    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //    spacer.width = 16;
    postbtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postButtonAction)];
    
    [postbtn setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium]} forState:UIControlStateNormal];
    
    [self.toolbar setItems:[[NSArray alloc] initWithObjects:barItem,postbtn,nil]];
    //    [self.toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    if([commentTextView hasText]){
        postbtn.enabled = YES;
        commentTextView.scrollEnabled = YES;
        placeholder.hidden = YES;
        
    }else{
        postbtn.enabled = NO;
        commentTextView.scrollEnabled = NO;
        placeholder.hidden = NO;
    }
    
    [self.view setNeedsLayout];
    
    [self subscribeToKeyboard];
    //[commentTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
}


#pragma mark - Tableview Delegates and DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RepliesCell *replyCell  = [tableView dequeueReusableCellWithIdentifier:@"RepliesCell"];
    if (replyCell == nil){
        replyCell  = [[RepliesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RepliesCell"];
    }
    RepliesModel *rModel = [_data objectAtIndex:indexPath.row];
    NSString *profileImgURL = rModel.userImgUrl;
    [replyCell.imgUser sd_setImageWithURL:[NSURL URLWithString:profileImgURL] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
    
    replyCell.imgUser.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    replyCell.imgUser.layer.borderWidth = 0.5;
    replyCell.imgUser.contentMode = UIViewContentModeScaleAspectFill;
    replyCell.imgUser.layer.masksToBounds = YES;
    
    replyCell.lbl_userName.text = rModel.userName;
    replyCell.lbl_time.text = [NSString stringWithFormat:@"%@ \u2022 ",[self setUpdateTimewithString:rModel.commentDate]];
    
    NSString *content =[NSString stringWithFormat:@"%@",rModel.commentContent];
    content = [content stringByDecodingHTMLEntities];
    content = [content stringByReplacingOccurrencesOfString: @"<br>" withString: @" "];
    content = [content stringByReplacingOccurrencesOfString:@"<br/>" withString: @" "];
    content=  [content stringByReplacingOccurrencesOfString:@"<br />" withString: @" "];
    
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            //NSLog(@"found URL: %@", url);
            //content = [url absoluteString];
        }
    }
    if ([content.lowercaseString containsString:[NSString stringWithFormat:@"%@",url]]) {
        // NSLog(@"mesg: %@",content);
        content =  [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",url] withString:[NSString stringWithFormat:@"%@",url] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
        
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        
    }else if ([content.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
        content =  [content stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    }
    
    replyCell.txt_userComment.backgroundColor = [UIColor clearColor];
    replyCell.txt_userComment.text = content;
    [replyCell.txt_userComment setTextContainerInset:UIEdgeInsetsZero];
    CGFloat fixedWidth = replyCell.txt_userComment.frame.size.width;
    CGSize newSize = [replyCell.txt_userComment sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = replyCell.txt_userComment.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    replyCell.txt_userComment.frame = newFrame;
    //    LblDesc.scrollEnabled = NO;
    //    LblDesc.editable = NO;
    replyCell.txt_userComment.dataDetectorTypes = UIDataDetectorTypeLink;
    if([rModel.like_status integerValue]==0){
        [replyCell.btnLike setTitle:@"Like" forState:UIControlStateNormal];
    }else{
        [replyCell.btnLike setTitle:@"Liked" forState:UIControlStateNormal];
    }
    
    [replyCell.btnLike addTarget:self action:@selector(likeRepliedComment:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [replyCell addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *TaponReplyerImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openReplyerProfile:)];
    TaponReplyerImage.delegate = self;
    TaponReplyerImage.numberOfTapsRequired = 1;
    TaponReplyerImage.numberOfTouchesRequired = 1;
    replyCell.imgUser.userInteractionEnabled = YES;
    [replyCell.imgUser addGestureRecognizer:TaponReplyerImage];
    return replyCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [self sectionHeaderViewForSection:section];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self sectionHeaderViewForSection:section].frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // Removes extra padding in Grouped style
    return CGFLOAT_MIN;
}

#pragma mark - Custom View for Header for Section
-(UIView *)sectionHeaderViewForSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    header.backgroundColor = [UIColor whiteColor];
    CGRect headerFrame;
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    NSMutableDictionary *secDic = self.commentDic;
   
    UIImageView *commenterImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    NSString *imgFileUrl = [secDic valueForKey:@"profile_pic_path"];
    [commenterImg sd_setImageWithURL:[NSURL URLWithString:imgFileUrl] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
    commenterImg.layer.cornerRadius = 4.0;
    commenterImg.contentMode = UIViewContentModeScaleAspectFill;
    commenterImg.layer.masksToBounds = YES;
    
    commenterImg.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
    commenterImg.layer.borderWidth = 0.5;
    
    //Set open profile View
    UITapGestureRecognizer *taponUserPic = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
    [commenterImg setUserInteractionEnabled:YES];
    [commenterImg addGestureRecognizer:taponUserPic];
    
    UILabel *lblname = [[UILabel alloc]initWithFrame:CGRectMake(commenterImg.frame.origin.x + commenterImg.frame.size.width + 10, commenterImg.frame.origin.y, totalWidth,16)];
    lblname.text = [secDic valueForKey:@"name"];
    lblname.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    
    //Set open profile View
    UITapGestureRecognizer *taponUserNameLbl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openProfileView:)];
    [lblname setUserInteractionEnabled:YES];
    [lblname addGestureRecognizer:taponUserNameLbl];
    
    
    
    UITextView * mainComment = [[UITextView alloc]init];
    mainComment.frame = CGRectMake(lblname.frame.origin.x, lblname.frame.origin.y + lblname.frame.size.height + 3, totalWidth -(lblname.frame.origin.x + 4 ), 1);
    mainComment.textContainer.lineFragmentPadding = 0;
    [mainComment setTextContainerInset:UIEdgeInsetsZero];
    mainComment.font = [UIFont systemFontOfSize:13.0];
    NSString *content =[NSString stringWithFormat:@"%@",[secDic valueForKey:@"comment"]];
    mainComment.backgroundColor = [UIColor clearColor];
    mainComment.text = content;
    CGFloat fixedWidth = mainComment.frame.size.width;
    
    CGSize newSize = [mainComment sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = mainComment.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    mainComment.frame = newFrame;
    
    mainComment.scrollEnabled = NO;
    mainComment.editable = NO;
    mainComment.backgroundColor = [UIColor clearColor];
    mainComment.editable = NO;
    mainComment.scrollEnabled = NO;
    mainComment.dataDetectorTypes = UIDataDetectorTypeAll;
    
    UILabel *lblTime = [[UILabel alloc]initWithFrame:CGRectMake(lblname.frame.origin.x, mainComment.frame.size.height + mainComment.frame.origin.y + 4, totalWidth, 21)];
    lblTime.text = [NSString stringWithFormat:@"%@  \u2022",[self setUpdateTimewithDic:secDic]];
    lblTime.font = [UIFont systemFontOfSize:11.0];
    lblTime.textColor = [UIColor lightGrayColor];
    
    CGRect rect = lblTime.frame;
    rect.size = [lblTime.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    lblTime.frame = rect;
    
    UIButton *likecomment = [[UIButton alloc]initWithFrame:CGRectMake(lblTime.frame.origin.x + lblTime.frame.size.width, lblTime.frame.origin.y, 100, lblTime.frame.size.height)];
    [likecomment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    likecomment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    if([[secDic valueForKey:@"comment_like_status"]integerValue] == 0){
        [likecomment setTitle:[NSString stringWithFormat:@"  Like  \u2022  "] forState:UIControlStateNormal];
        [likecomment addTarget:self action:@selector(likeComment:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [likecomment setTitle:[NSString stringWithFormat:@"  Liked  \u2022  "] forState:UIControlStateNormal];
    }
    rect = likecomment.frame;
    rect.size = [likecomment.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    likecomment.frame = rect;
    UIImageView *imgLiked = [[UIImageView alloc]initWithFrame:CGRectMake(likecomment.frame.origin.x + likecomment.frame.size.width, lblTime.frame.origin.y, 13, 13)];
    imgLiked.image = [UIImage imageNamed:@"liked.png"];
    [header addSubview:imgLiked];
    
    UILabel *lblTotallikeCount = [[UILabel alloc]initWithFrame:CGRectMake(imgLiked.frame.origin.x + imgLiked.frame.size.width + 4, lblTime.frame.origin.y, 20, 21)];
    // lblTotallikeCount.text = [NSString stringWithFormat:@"%@  ",[self setUpdateTimewithDic:secDic]];
    lblTotallikeCount.font = [UIFont systemFontOfSize:11.0];
    lblTotallikeCount.textColor = [UIColor lightGrayColor];
    [header addSubview:lblTotallikeCount];
    UIButton *likeCount = [[UIButton alloc]init];
    
    if([[secDic valueForKey:@"total_comment_like"]integerValue] == 0){
        CGRect reFrame = imgLiked.frame;
        reFrame.size.width = 0;
        imgLiked.frame = reFrame;
        
        reFrame = lblTotallikeCount.frame;
        reFrame.size.width = 0 ;
        lblTotallikeCount.frame = reFrame;
        
    }else{
        NSString *totalCmtlike = [secDic valueForKey:@"total_comment_like"];
        lblTotallikeCount.text = [NSString stringWithFormat:@"%@  \u2022",totalCmtlike];
        [likeCount addTarget:self action:@selector(likeCommentCount:) forControlEvents:UIControlEventTouchUpInside];
        rect = lblTotallikeCount.frame;
        rect.size = [lblTotallikeCount.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
        lblTotallikeCount.frame = rect;
    }
    likeCount.frame = CGRectMake(imgLiked.frame.origin.x, imgLiked.frame.origin.y, imgLiked.frame.size.width + lblTotallikeCount.frame.size.width, imgLiked.frame.size.height);
    
    UIButton *replycomment = [[UIButton alloc]initWithFrame:CGRectMake(likeCount.frame.origin.x + likeCount.frame.size.width, likecomment.frame.origin.y, 70, likecomment.frame.size.height)];
    [replycomment setTitle:@"  Reply" forState:UIControlStateNormal];
    [replycomment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    replycomment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [replycomment addTarget:self action:@selector(openkeyboard) forControlEvents:UIControlEventTouchUpInside];
    rect = replycomment.frame;
    rect.size = [replycomment.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0]}];
    replycomment.frame = rect;
    
    UILabel *lblSep = [[UILabel alloc]initWithFrame:CGRectMake(0, replycomment.frame.size.height + replycomment.frame.origin.y + 9, totalWidth, 0.5)];
    lblSep.backgroundColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:0.5];
    
    if(![[secDic valueForKey:@"reply"]count]){
        [header addSubview:lblSep];
    }
    headerFrame.size.width = totalWidth;
    headerFrame.size.height = replycomment.frame.size.height + replycomment.frame.origin.y + 10;
    headerFrame.origin.x = 0;
    headerFrame.origin.y = 0;
    
    header.frame = headerFrame;
    [header addSubview:commenterImg];
    [header addSubview:lblname];
    [header addSubview:mainComment];
    [header addSubview:lblTime];
    [header addSubview:likecomment];
    [header addSubview:likeCount];
    [header addSubview:replycomment];
    
    UITapGestureRecognizer *tapOnSection = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [header setUserInteractionEnabled:YES];
    [header addGestureRecognizer:tapOnSection];
    return header;
}

#pragma mark - set time
-(NSString *)setUpdateTimewithString:(NSString *)dateStr{
    NSString *date1;
    NSString *exactDatestr;
    date1 = dateStr;
    long long int timestamp = [date1 longLongValue]/1000;
    NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
    exactDatestr = [self updatedTimeLabelWithDate:dates];
    return exactDatestr;
}

#pragma mark - set time
-(NSString *)setUpdateTimewithDic:(NSDictionary *)timeInfo{
    NSString *date1;
    NSString *exactDatestr;
    if(timeInfo!=nil && [timeInfo isKindOfClass:[NSDictionary class]]){ //check if bite dictionary exist
        date1=[timeInfo objectForKey:@"date_of_creation"];
        long long int timestamp = [date1 longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        exactDatestr = [self updatedTimeLabelWithDate:dates];
    }
    return exactDatestr;
}

#pragma mark - Calculating Posting Time
-(NSString *)updatedTimeLabelWithDate:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    NSString *calculatedStr= [self relativeDateStringForDate:date];
    return calculatedStr;
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitWeekOfYear;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components1];
    
    components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *thatdate = [cal dateFromComponents:components1];
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:thatdate
                                                                     toDate:today
                                                                    options:0];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years", (long)components.year];
    } else if (components.month > 0) {
        return [self getOnlyDate:thatdate];
        //return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [self getOnlyDate:thatdate];
        //return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* component = [calender components:NSCalendarUnitWeekday fromDate:thatdate];
            return [self getDay:[component weekday]];
            // return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        
        return [self getTodayCurrTime:date];
    }
}

-(NSString *)getOnlyDate:(NSDate*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    // [df setDateFormat:@"dd/MM/YY"];
    [df setDateFormat:@"MMM dd, yyyy"];
    //df.dateStyle = NSDateFormatterShortStyle;
    //df.doesRelativeDateFormatting = NO;
    return [df stringFromDate:date];
}

-(NSString*)getDay:(NSInteger)dayInt{
    // NSLog(@"%ld",(long)dayInt);
    NSMutableArray *day= [[NSMutableArray alloc]initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [day objectAtIndex:dayInt-1];
}

-(NSString *)getTodayCurrTime:(NSDate*)date{
    NSString *exactDatestr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter  stringFromDate:date];
    
    if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){ //if date exist then calculate it
        // change of date formatter
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-10-21 03:19:32
        NSInteger seconds = [date timeIntervalSinceDate:currentTime];
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        
        NSInteger minutes = (int) (floor(seconds / 60));
        if(minutes) seconds -= minutes * 60;
        
        if(hours) {
            if (hours==-1) {
                exactDatestr = @"1 hr";
            }
            else {
                exactDatestr = [NSString stringWithFormat: @"%ld hrs", (long)hours*-1];
            }
        }
        else if(minutes){
            if (minutes==-1) {
                exactDatestr = @"1 min";
            }
            else
            { exactDatestr = [NSString stringWithFormat: @"%ld mins", (long)minutes*-1];
            }
        }
        else if(seconds)
            exactDatestr= [NSString stringWithFormat: @"%ld sec", (long)seconds*-1];
        else
            exactDatestr= [NSString stringWithFormat: @"Just now"];
    }
    return exactDatestr;
}

#pragma mark - Keybaord Action

- (void)subscribeToKeyboard {
    
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            //  UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.size.height, 0.0);
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
            [self animateTextView:YES withKBHeight:keyboardRect.size.height];
            
            keyboardIsVisible = YES;
        } else {
            CGRect inputviewFrame = self.toolbar.frame;
            //            inputviewFrame.origin.y = [UIScreen mainScreen].bounds.size.height - inputviewFrame.size.height;
            
            //            self.toolbar.frame = inputviewFrame;
            self.BottomConstraintsToolbar.constant = 0;
            [UIView commitAnimations];
            //  UIScrollView *ScrV = (UIScrollView*)[self.view viewWithTag:kTag_scroll];
            //            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, inputviewFrame.size.height - 44, 0.0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
            keyboardIsVisible = NO;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void) animateTextView:(BOOL)up withKBHeight:(float)kbheight
{
    const int movementDistance = kbheight; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    //   NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.BottomConstraintsToolbar.constant = kbheight;
    [UIView commitAnimations];
}

#pragma mark - Reset constraints
-(void)resetConstraintsForToolbar{
    self.BottomConstraintsToolbar.constant = 0;
    self.toolBarHeightConstraints.constant = 44;
    CGRect textviewrect = commentTextView.frame;
    textviewrect.size.height = 32;
    commentTextView.frame = textviewrect;
    [self.view endEditing:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([commentTextView hasText]){
        postbtn.enabled = YES;
        //commentTextView.scrollEnabled = YES;
        placeholder.hidden = YES;
        
    }else{
        postbtn.enabled = NO;
        commentTextView.scrollEnabled = NO;
        placeholder.hidden = NO;
    }
    _previousContentHeight = textView.frame.size.height;
    CGFloat maxHeight = 90.0f;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fminf(newSize.height, maxHeight));
    textView.frame = newFrame;
    
    if(newSize.height > 90){
        commentTextView.scrollEnabled = YES;
    }else{
        commentTextView.scrollEnabled = NO;
    }
    if (_previousContentHeight<newSize.height) {
        
        self.toolBarHeightConstraints.constant = self.toolBarHeightConstraints.constant + (newFrame.size.height-_previousContentHeight);
    }else if (_previousContentHeight>newSize.height){
        
        self.toolBarHeightConstraints.constant = self.toolBarHeightConstraints.constant - (_previousContentHeight - newFrame.size.height);
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.height -self.toolbar.frame.origin.y - 50, 0.0);
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

-(void)getlistCommentReply{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]listCommentReplyRequestWithAuthkey:[userDef valueForKey:userAuthKey] feed_id:self.feedid comment_id:self.commentid device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage offset:[NSString stringWithFormat:@"%ld",(long)offset] limit:limit callback:^(NSDictionary *responseObject, NSError *error) {
        
        if(error){
            if(offset==1){
                  __weak RepliesVC *weakSelf = self;
                [self.tableView addPullToRefreshWithActionHandler:^{
                    [Localytics tagEvent:@"WhatsTrendingComment PullDown"];
                    //Call Feeds here
                    [weakSelf getlistCommentReply];
                }position:SVPullToRefreshPositionBottom];
            }
            [self.tableView.pullToRefreshView stopAnimating];
        }
        else{
            NSMutableDictionary *responsePost =[[responseObject objectForKey:@"posts"] mutableCopy];
            if ([responsePost isKindOfClass:[NSNull class]] || (responsePost == nil))
            {
                [[AppDelegate appDelegate]hideIndicator];
                // NSLog(@"response from comment reply = %@",responsePost);
             }
            else if ([responsePost isKindOfClass:[NSMutableDictionary class]]){
                
                //NSLog(@"response from comment reply = %@",responsePost);
                if([[responsePost valueForKey:@"status"]integerValue] == 0){
                    [[AppDelegate appDelegate]hideIndicator];
                    [UIAppDelegate alerMassegeWithError:[responsePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
                }
                else if([[responsePost valueForKey:@"status"]integerValue] == 9){
                    [[AppDelegate appDelegate]hideIndicator];
                    [[AppDelegate appDelegate]logOut];
                }else if([[responsePost valueForKey:@"status"]integerValue] == 7){
                    self.tableView.showsPullToRefresh = NO;
                }
                else  if([[responsePost valueForKey:@"status"]integerValue] == 11)
                {
                    NSString*userValidateCheck = @"readonly";
                    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                    [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                    [userpref synchronize];
                    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                    if ([u_permissionstus isEqualToString:@"readonly"]) {
                        [self getcheckedUserPermissionData];
                    }
                }
                else if([[responsePost valueForKey:@"status"]integerValue] == 1)
                {
                    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]init];
                    dataDic = (NSMutableDictionary*)[responsePost valueForKey:@"data"];
                    //NSLog(@"Status 1 response from comment reply = %@",responsePost);
                    for (int i =0; i< [[dataDic valueForKey:@"reply"]count]; i++) {
                        RepliesModel *replyModel = [RepliesModel new];
                        NSMutableDictionary *dic = [[dataDic valueForKey:@"reply"]objectAtIndex:i];
                        BOOL found = false;
                        for (int k =0; k<self.data.count; k++) {
                            RepliesModel *replyM = [self.data objectAtIndex:k];
                            NSString *replId = [NSString stringWithFormat:@"%@",replyM.reply_id];
                            NSString *comReplId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"comment_reply_id"]];
                            if ([replId isEqualToString:comReplId]) {
                                found = true;
                                break;
                            }
                        }
                        if(!found){
                            replyModel.userName = [dic valueForKey:@"name"];
                            replyModel.reply_id = [dic valueForKey:@"comment_reply_id"];
                            replyModel.replyer_jabber_id = [dic valueForKey:@"comment_replyer_jabber_id"];
                            replyModel.custom_id = [dic valueForKey:@"custom_id"];
                            replyModel.commentDate = [dic valueForKey:@"date_of_creation"];
                            replyModel.userImgUrl = [dic valueForKey:@"profile_pic_path"];
                            replyModel.commentContent = [dic valueForKey:@"reply_comment"];
                            replyModel.like_status = [dic valueForKey:@"reply_like_status"];
                            replyModel.total_reply_like = [dic valueForKey:@"total_reply_like"];
                            replyModel.replyer_user_id = [dic valueForKey:@"commented_by"];
                            [_data addObject:replyModel];
                        }
                    }
                    [self.tableView reloadData];
                    if(offset==1){
                        __weak RepliesVC *weakSelf = self;
                        [self.tableView addPullToRefreshWithActionHandler:^{
                            [Localytics tagEvent:@"WhatsTrendingComment PullDown"];
                            //Call Feeds here
                            [weakSelf getlistCommentReply];
                        }position:SVPullToRefreshPositionBottom];
                    }
                    offset ++ ;
                    [self.tableView.pullToRefreshView stopAnimating];
                    
                    self.tableView.tableFooterView = nil;
                    
                    if([[dataDic valueForKey:@"reply"]count]<10){
                        [self.tableView setShowsPullToRefresh:NO];
                    }
                }
            }
        }
    }];
}

-(void)setCommentReplyAction:(NSString *)action replyID:(NSString*)comRepID{
    isEdit = YES;
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[DocquityServerEngine sharedInstance]feedactioncommentreplyRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid comment_id:self.commentid comment_reply_id:comRepID action:action reply:result device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
            [[AppDelegate appDelegate]hideIndicator];
            // NSLog(@"response from comment reply = %@",resposePost);
            
        }
        else {
            //NSLog(@"response from comment reply = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 0){
                [[AppDelegate appDelegate]hideIndicator];
                [UIAppDelegate alerMassegeWithError:[resposePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate]hideIndicator];
                [[AppDelegate appDelegate]logOut];
            }  else if([[resposePost valueForKey:@"status"]integerValue] == 11){
                [[AppDelegate appDelegate]hideIndicator];
                [UIAppDelegate alerMassegeWithError:[resposePost valueForKey:@"msg"] withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                RepliesModel *replyModel = [RepliesModel new];
                [[AppDelegate appDelegate]hideIndicator];
                if([action  isEqualToString:@"add"])
                {
                    long long int myInt = (long long int)[[NSDate date] timeIntervalSince1970]*1000;
                    NSString * timestamp = [NSString stringWithFormat:@"%lld",myInt];
                    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
                    replyModel.userName = [NSString stringWithFormat:@"%@ %@",[userdef objectForKey:dc_firstName],[userdef objectForKey:dc_lastName]];
                    replyModel.reply_id = [[resposePost valueForKey:@"data"] valueForKey:@"comment_reply_id"];
                    replyModel.replyer_jabber_id = [userdef objectForKey:jabberId];
                    replyModel.custom_id = [userdef objectForKey:ownerCustId];
                    replyModel.commentDate = timestamp;
                    replyModel.userImgUrl = [NSString stringWithFormat:@"%@",[userdef objectForKey:profileImage]];
                    replyModel.commentContent = commentTextView.text;
                    replyModel.like_status = @"0";
                    replyModel.total_reply_like = @"0";
                    replyModel.replyer_user_id = [userdef valueForKey:userId];
                    [_data insertObject:replyModel atIndex:0];
                    [self resetCommentTextView];
                    [self resetConstraintsForToolbar];
                    [self.tableView reloadData];
                }else if([action isEqualToString:@"delete"]){
                    isDelete = YES;
                    [self.data removeObjectAtIndex:selectedRow];
                    [self.tableView reloadData];
                }
            }
        }
    }];
}

-(void)resetCommentTextView{
    placeholder.hidden = NO;
    commentTextView.text = @"";
    postbtn.enabled = NO;
    CGRect inputviewFrame = self.toolbar.frame;
    self.BottomConstraintsToolbar.constant = 0;
    self.tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, inputviewFrame.size.height - 44, 0.0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - Gesture Actions
- (void)openProfileView:(UITapGestureRecognizer*)gesture
{
    // NSLog(@"tapped section again = %d",gesture.view.superview.tag);
    NSString*custom_uId = [self.commentDic valueForKey:@"custom_id"];
   // NSString*feedjabId = [self.commentDic valueForKey:@"commenter_jabber_id"];
    
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
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custom_uId;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

- (void)openReplyerProfile:(UITapGestureRecognizer*)gesture
{
    //  NSLog(@"gesture.view.superview section = %d , Row = %d",gesture.view.superview.tag, )
    RepliesCell *replyCell = (RepliesCell*)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:replyCell];
    //NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPath.row,(long)indexPath.section);
    //    selectedRow = indexPath.row;
    //    selectedSection = indexPath.section;
    RepliesModel *repModel = [RepliesModel new];
    repModel = [self.data objectAtIndex:indexPath.row];
    NSString*custom_uId = repModel.custom_id;
   // NSString*feedjabId =  repModel.replyer_jabber_id;
    
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
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custom_uId;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

-(void)likeCommentCount:(UIButton*)sender{
    
    // NSLog(@"SelectedFeed = %@",[self.commentArray objectAtIndex:selectedSection]);
    [Localytics tagEvent:@"WhatsTrending CommentScreen ViewCommentLikeList Click"];
    [[AppDelegate appDelegate] getPlaySound];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSString *xib = nil;
    if (IS_IPHONE_6) {
        xib = @"FeedLikeListVC-i6";
    }
    else if (IS_IPHONE_6_PLUS){
        xib = @"FeedLikeListVC-i6Plus";
    }
    else {
        xib = IS_IPHONE_5?@"FeedLikeListVC-i5":@"FeedLikeListVC";
    }
    FeedLikeListVC*feedlikevw = [[FeedLikeListVC alloc]initWithNibName:xib bundle:nil];
    feedlikevw.dataFor = @"comment";
    feedlikevw.feedCommentID = self.commentid;
    feedlikevw.feedLikeIdStr = self.feedid;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController pushViewController:feedlikevw animated:YES];
}

-(void)likeComment:(UIButton *)sender{
    [self setFeedCommentLikeRequest:self.commentDic];
}

-(void)setFeedCommentLikeRequest:(NSMutableDictionary*)likeDic{
    isLike = YES;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //  NSLog(@"SelectedFeed in api = %@",[self.commentArray objectAtIndex:selectedSection]);
    [[DocquityServerEngine sharedInstance]feedcommentlikeRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid comment_id:[likeDic valueForKey:@"comment_id"] device_type:kDeviceType app_version:[userDef objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]]|| resposePost == nil)
        {
            // Response is null
        }
        else {
            [[AppDelegate appDelegate]hideIndicator];
            // NSLog(@"response from like comment = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                NSInteger totallikeComment = [[likeDic valueForKey:@"total_comment_like"]integerValue];
                totallikeComment++;
                [self.commentDic setValue:@"1" forKey:@"comment_like_status"];
                [self.commentDic setValue:[NSString stringWithFormat:@"%ld",(long)totallikeComment] forKey:@"total_comment_like"];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
               }
            else if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                  [UIAppDelegate alerMassegeWithError:defaultErrorMsg withButtonTitle:OK_STRING autoDismissFlag:NO];
            }
            else if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

-(void)likeRepliedComment:(UIButton *)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    selectedRow = indexPath.row;
    
    RepliesModel *repModel = [RepliesModel new];
    repModel = [self.data objectAtIndex:indexPath.row];
    [self setCommentReplyLikeRequestWithReplyID:repModel.reply_id];
}

-(void)setCommentReplyLikeRequestWithReplyID:(NSString *)comRepId{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    isLike = YES;
    // NSLog(@"replylikeDic in api = %@",replylikeDic);
    [[DocquityServerEngine sharedInstance]feedcommentreplylikeRequestWithAuthkey:[userDef objectForKey:userAuthKey] feed_id:self.feedid comment_id:self.commentid comment_reply_id:comRepId device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || resposePost == nil)
        {
            // Response is null
        }
        else {
            // NSLog(@"response from like comment = %@",resposePost);
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                RepliesModel *repModel = [RepliesModel new];
                repModel = [self.data objectAtIndex:selectedRow];
                repModel.like_status = @"1";
                NSInteger totalReplikeComment = repModel.total_reply_like.integerValue;
                totalReplikeComment++;
                repModel.total_reply_like = [NSString stringWithFormat:@"%ld",(long)totalReplikeComment];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                
            }
        }
    }];
}

-(void)cellTapped:(UITapGestureRecognizer*)gesture{
    RepliesCell *replyCell = (RepliesCell*)gesture.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:replyCell];
    // NSLog(@"SelectedCell row = %ld and section  = %ld",(long)indexPath.row,(long)indexPath.section);
    selectedRow = indexPath.row;
    // selectedSection = indexPath.section;
    [self subcommentAlertSheetForRow];
}

-(void)subcommentAlertSheetForRow{
    if (keyboardIsVisible){
        [self hideKeyboard];
        
    }else{
        BOOL isSelfReplyer = NO;
        RepliesModel *repModel = [RepliesModel new];
        repModel = [self.data objectAtIndex:selectedRow];
        selectedComment = repModel.commentContent;
        if([[[NSUserDefaults standardUserDefaults]valueForKey:userId]isEqualToString:repModel.replyer_user_id]){
            isSelfReplyer = YES;
        }
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        if(isSelfReplyer){
            [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self editCommentReply];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self copyString];
        }]];
        if(isSelfReplyer){
            [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                
                UIAlertController * confirmAlert= [UIAlertController alertControllerWithTitle:@"Delele reply" message:@"Are you sure you want to delete reply?" preferredStyle:UIAlertControllerStyleAlert];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [confirmAlert addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self setCommentReplyAction:@"delete" replyID:repModel.reply_id];
                }]];
                [self presentViewController:confirmAlert animated:YES completion:nil];
                
            }]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)editCommentReply{
    isEdit = YES;
    [Localytics tagEvent:@"WhatsTrending CommentScreen Edit Click"];
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    editCommentVC *editCom = [storyboard instantiateViewControllerWithIdentifier:@"editCommentVC"];
    editCom.delegate = self;
    editCom.commentText = selectedComment;
    editCom.FeedID = self.feedid;
    editCom.Action = @"Reply";
    editCom.commentID = self.commentid;
    editCom.commentReplyID = [self.data objectAtIndex:selectedRow].reply_id;
    [self presentViewController:editCom animated:YES completion:nil];
}

-(void)editCommentReplyText:(NSString*)comment{
    // NSLog(@"Edited text = %@",comment);
    [self.data objectAtIndex:selectedRow].commentContent = comment;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Post Button Click
-(void)postButtonAction{
    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
    if ([u_permissionstus isEqualToString:@"readonly"]) {
        [self getcheckedUserPermissionData];
    }
    else{
        [self hideKeyboard];
        isEdit = YES;
        [Localytics tagEvent:@"WhatsTrending CommentScreen CommentReplyPost Click"];
        NSString* result = [commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (result.length > 0)
        {
            [self setCommentReplyAction:@"add" replyID:@""];
        }else{
            if ([commentTextView.text length] == 0){
                [UIAppDelegate alerMassegeWithError:@"Please write a reply." withButtonTitle:OK_STRING autoDismissFlag:NO];
                return;
            }
        }
    }
}

- (void)copyString {
    [Localytics tagEvent:@"WhatsTrending CommentScreen Copy Click"];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:selectedComment];
}

-(void)openkeyboard{
    [commentTextView becomeFirstResponder];
}

#pragma mark - Hide Keyboard
-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSMutableArray *replyArr= [[NSMutableArray alloc]init];
    for (int i=0; i<self.data.count; i++) {
        RepliesModel *replyModel = [RepliesModel new];
        replyModel = [self.data objectAtIndex:i];
        NSMutableDictionary *repDic = [[NSMutableDictionary alloc]init];
        [repDic setValue:replyModel.userName forKey:@"name"];
        [repDic setValue:replyModel.reply_id forKey:@"comment_reply_id"];
        [repDic setValue:replyModel.replyer_jabber_id  forKey:@"comment_replyer_jabber_id"];
        [repDic setValue:replyModel.custom_id  forKey:@"custom_id"];
        [repDic setValue:replyModel.userImgUrl forKey:@"profile_pic_path"];
        [repDic setValue:replyModel.commentContent forKey:@"reply_comment"];
        [repDic setValue:replyModel.commentDate forKey:@"date_of_creation"];
        [repDic setValue:replyModel.like_status forKey:@"reply_like_status"];
        [repDic setValue:replyModel.total_reply_like forKey:@"total_reply_like"];
        [repDic setValue:replyModel.replyer_user_id forKey:@"commented_by"];
        [replyArr addObject:repDic];
    }
    [self.commentDic setValue:replyArr forKey:@"reply"];
    [self.commentDic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.data.count] forKey:@"total_comment_reply"];
    if(isEdit || isLike || isDelete){
        [self.delegate replyCommentResponseWitheditedDic:self.commentDic anyAction:YES];
    }
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
                [userpref setObject:permstus?permstus:@"" forKey:user_permission]; //mandatory
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

@end
