/*============================================================================
 PROJECT: Docquity
 FILE:    FeedLikeListVC.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 05/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

/*============================================================================
 Interface: FeedLikeListVC
 =============================================================================*/
@interface FeedLikeListVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    IBOutlet UITableView *feedlikeTV;
    NSMutableArray *feedlikeListArr;
    IBOutlet UILabel *usrNameLbl;
    IBOutlet UILabel *spclLbl;
    IBOutlet UILabel *stslLbl;
    IBOutlet UIImageView *usrImg;
    AVAudioPlayer *audioPlayer;
    NSInteger offset;
    NSInteger limitpost;
}

@property (strong, nonatomic) IBOutlet UITableView *feedlikeTV;
@property (strong, nonatomic) NSMutableArray *feedlikeListArr;
@property(nonatomic,strong)IBOutlet UITableViewCell *feedLikeTVCell;
@property(nonatomic,strong)NSString*feedLikeIdStr;
@property(nonatomic,strong)NSString *feedCommentID;
@property (nonatomic, strong)NSString *dataFor;

@end
