//
//  TLTextFeedCell.h
//  Docquity
//
//  Created by Docquity-iOS on 02/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@protocol TLTextFeedCellDelegate;

@interface TLTextFeedCell : UITableViewCell
<
UIWebViewDelegate,
TTTAttributedLabelDelegate

>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_latestActivity;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FeedCategory;
@property (nonatomic, weak) id<TLTextFeedCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet KILabel *lbl_hashtag;

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
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIView *pdf_backView;

@property (weak, nonatomic) IBOutlet UIButton *btn_like;


@property (weak, nonatomic) IBOutlet UIImageView *img_MetaThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *lbl_MetaTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_metaUrl;


@property (weak, nonatomic) IBOutlet UIImageView *img_documentType;
@property (weak, nonatomic) IBOutlet UILabel *lbl_documentName;
@property (weak, nonatomic) IBOutlet UIImageView *img_documentView;
- (IBAction)didPressDocumentView:(UIButton*)sender;


- (IBAction)didPressLikeBtn:(UIButton*)sender;
- (IBAction)didPressCommentBtn:(UIButton*)sender;
- (IBAction)didPressShareBtn:(UIButton*)sender;
- (IBAction)didPressActionFeedBtn:(UIButton*)sender;
- (IBAction)didPressMetaFeed:(UIButton*)sender;
- (IBAction)didPressUserName:(UIButton*)sender;


@property (nonatomic)BOOL isOwnProfile;
@property (nonatomic,strong)NSMutableArray *specArray;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescHeightConstraints;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescBottomConstraints;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCountHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCountBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagTopConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagHeightEqalRelConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagBottomConstraints;


//-(void)configureUserInfoWithData:(NSMutableDictionary*)data;
-(void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath withData:(NSMutableDictionary*)data;
@end

@protocol TLTextFeedCellDelegate<NSObject>

@optional
- (void)didTapOnMoreButton:(TLTextFeedCell *)cell;
- (void)TLTableViewCell:(TLTextFeedCell *)cell didTapOnHashTag:(NSString *)hashTag;
- (void)TLTableViewCell:(TLTextFeedCell *)cell didTapOnUserHandle:(NSString *)userHandle;
- (void)TLTableViewCell:(TLTextFeedCell *)cell didTapOnURL:(NSString *)urlString;
- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didPressLikeBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressCommentBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressShareBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressDocumentBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressFeedAction:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressMetaBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didPressUserBtn:(UIButton*)sender atPoint:(CGPoint)point;
- (void)didTapUserImage:(UIImageView*)sender atPoint:(CGPoint)point;
- (void)clickedUrl:(NSString *)url;
@end
//TLTextFeedCell
