//
//  SpecilityFeedVC.h
//  Docquity
//
//  Created by Docquity-iOS on 13/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefineAndConstants.h"
#import "UINavigationBar+ZZHelper.h"
#import "CAPSPhotoView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ProfileData.h"
@interface SpecilityFeedVC : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableArray *specFeedArr;
    NSInteger offset;
    NSIndexPath *clickedIndexPath;
    NSString*feedShareUrl;
    NSString *selectedFStatus;
    NSString * permstus; //check readonly permission
    NSMutableArray *deleteFeedid;
    BOOL isDeleteFeed;
    CAPSPhotoView *photoView;
 }

@property (retain, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSString *specId;
@property (strong, nonatomic) NSString *commentFeedid;
@property (strong, nonatomic) NSString *specName;
@property (nonatomic,assign)id delegate;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property(nonatomic, strong) ProfileData *profileData;
@property (weak, nonatomic) UIImage *imgUser;
@end


@protocol SpecilityViewDelegate <NSObject>
-(void)specilityViewFindDelete:(BOOL)isDelete deleteFeedID:(NSMutableArray*)deleteFeedID;
//-(void)isComment:(BOOL)isComment isLike:(BOOL)islike;

@end
