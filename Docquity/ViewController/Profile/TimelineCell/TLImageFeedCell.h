//
//  TLImageFeedCell.h
//  Docquity
//
//  Created by Docquity-iOS on 02/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+HTML.h"
#import "KILabel.h"
#import "NSString+GetRelativeTime.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@protocol TLImageFeedCellDelegate;

@interface TLImageFeedCell : UITableViewCell
<
TTTAttributedLabelDelegate
>

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_latestActivity;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FeedCategory;

@property (weak, nonatomic) IBOutlet KILabel *lbl_hashtag;

@property (nonatomic, weak) id<TLImageFeedCellDelegate>delegate;
//@property (weak, nonatomic) UIImage *placeholder;

@property (weak, nonatomic) IBOutlet UIImageView *img_feeder;
@property (weak, nonatomic) IBOutlet UIButton *lbl_feederName;
@property (weak, nonatomic) IBOutlet UIButton *btn_FeedAction;
@property (weak, nonatomic) IBOutlet UIImageView *img_association;
@property (weak, nonatomic) IBOutlet UILabel *lbl_AssoWithTime;
@property (weak, nonatomic) IBOutlet UILabel *lbl_feed_title;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_desc;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FeedLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FeedCommentCount;
@property (weak, nonatomic) IBOutlet UIView *metaview_container;



@property (weak, nonatomic) IBOutlet UIButton *btn_like;

@property (weak, nonatomic) IBOutlet UIImageView *img_single;

@property (weak, nonatomic) IBOutlet UIView *view_2imgholder;
@property (weak, nonatomic) IBOutlet UIImageView *img_first_v2;
@property (weak, nonatomic) IBOutlet UIImageView *img_second_v2;

@property (weak, nonatomic) IBOutlet UIView *view_3imgholder;
@property (weak, nonatomic) IBOutlet UIImageView *img_first_v3;
@property (weak, nonatomic) IBOutlet UIImageView *img_second_v3;
@property (weak, nonatomic) IBOutlet UIImageView *img_third_v3;




@property (weak, nonatomic) IBOutlet UIView *view_4imgholder;

@property (weak, nonatomic) IBOutlet UIImageView *img_first_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img_second_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img_third_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img_forth_v4;

@property (weak, nonatomic) IBOutlet UIButton *btn_moreImage;




@property (nonatomic,strong) NSString *videoURLToPlay;

- (IBAction)didPressLikeBtn:(UIButton*)sender;
- (IBAction)didPressCommentBtn:(UIButton*)sender;
- (IBAction)didPressShareBtn:(UIButton*)sender;
- (IBAction)didPressActionFeedBtn:(UIButton*)sender;

- (IBAction)didPressMoreImgBtn:(id)sender;
- (IBAction)didPressUserName:(id)sender;

@property (nonatomic)BOOL isOwnProfile;
@property (nonatomic,strong)NSMutableArray *specArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCountHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCountBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagHeightEqalRelConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagTopConstraints;

//-(void)configureUserInfoWithData:(NSMutableDictionary*)data;
-(void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath withData:(NSMutableDictionary*)data;
@end

@protocol TLImageFeedCellDelegate<NSObject>

@optional
- (void)didTapOnMoreButton:(TLImageFeedCell *)cell;
- (void)TLImageFeedCell:(TLImageFeedCell *)cell didTapOnHashTag:(NSString *)hashTag;
- (void)TLImageFeedCell:(TLImageFeedCell *)cell didTapOnUserHandle:(NSString *)userHandle;
- (void)TLImageFeedCell:(TLImageFeedCell *)cell didTapOnURL:(NSString *)urlString;
- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didPressLikeBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressCommentBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressShareBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressFeedAction:(UIButton*)sender atPoint:(CGPoint)point;
- (void)imgviewTapped:(UIImageView*)sender;
- (void)imgviewTapped:(UIImageView*)sender atPoint:(CGPoint)point;;
- (void)playVideoByURL:(NSString *)url;
- (void)didPressUserBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didTapUserImage:(UIImageView*)sender atPoint:(CGPoint)point;
- (void)clickedUrl:(NSString *)url;
@end
