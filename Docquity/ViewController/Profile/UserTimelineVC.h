//
//  UserTimelineVC.h
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "CAPSPhotoView.h"
#import <MediaPlayer/MediaPlayer.h>
@interface UserTimelineVC : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
TTTAttributedLabelDelegate
>{
    UIRefreshControl *refreshControl;
    BOOL isOwnProfile;
    BOOL headerViewCreated;
    BOOL isDataGet;
    NSString * permstus; //check readonly permission
    NSMutableArray *timelinePhoto;
    NSMutableArray *timelineFeedArr;
    NSInteger pageCount;
    NSIndexPath *clickedIndexPath;
    NSString*feedShareUrl;
    NSString *selectedFStatus;
    CAPSPhotoView *photoView;
    NSMutableString *dataPath;
    NSString *selectedBtnString;
}
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;

@property(nonatomic,assign)id delegate;
@property (weak, nonatomic) UIImage *imgUser;
@property (retain, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;
@property (strong,nonatomic)NSMutableArray *array;
@property (strong,nonatomic)NSString *custid;
@property (nonatomic, strong)IBOutlet UIImageView *avatarImg;
@property (nonatomic, strong)IBOutlet UIImageView *headerBackImg;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_city;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (weak, nonatomic) IBOutlet UILabel *lbl_status;

@property (weak, nonatomic) IBOutlet UIView *view_status;
@property (weak, nonatomic) IBOutlet UIView *view_action;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewStatusHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgStatusHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblStatusTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgStatusTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgStatusBottomConstraints;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (strong, nonatomic) NSString *commentFeedid;
@property (strong, nonatomic) NSString *comefrom;
- (IBAction)didPressNavbarBackButton:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblStatusBottomConstraints;
- (IBAction)didPressSeeAllPhoto:(id)sender;
- (IBAction) didPressStartChat:(UIButton*)sender;
- (void) updateFeed;
@end

@protocol UserTimelineVC <NSObject>

-(void)SettingViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName;

@end
