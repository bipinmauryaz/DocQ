//
//  NewProfileVC.h
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "ProfileData.h"
@interface NewProfileVC : UIViewController{
    BOOL headerViewCreated;
    BOOL isDataGet;
    BOOL isConnectionSendRequest;
    NSMutableString  *dataPath;
    UIRefreshControl *refreshControl;
    BOOL isOwnProfile;
    NSString * permstus; //check readonly permission
    NSString *selectedFStatus;
}
@property (nonatomic)BOOL isDataGet;
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) UIImage *userProfileImage;
@property (nonatomic, strong) IBOutlet UITableView *TableView;
@property (weak, nonatomic) IBOutlet UIView *sectionHeader;
@property (weak, nonatomic) IBOutlet UIButton *btn_status;
@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong)IBOutlet UIImageView *headerBackImg;
@property (nonatomic, strong)IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;
@property (nonatomic,strong) NSString *customUserId;
@property (nonatomic,strong) NSString *userJabberId;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Speciality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_city;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (weak, nonatomic) IBOutlet UILabel *lbl_status;
@property (weak, nonatomic) NSString*checkprofileheader;

- (IBAction)didPressActionBtn:(id)sender;

- (IBAction)didPressNavbarBackButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_status;
@property (weak, nonatomic) IBOutlet UIView *view_action;
@property(nonatomic,assign)id delegate;
@property(nonatomic, strong) ProfileData *profileData;
@end

@protocol NewProfileVC <NSObject>

-(void)TimeLineViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state;

@end


