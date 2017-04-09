/*============================================================================
 PROJECT: Docquity
 FILE:    FeedCell.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 17/01/16.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "RFLayout.h"
#import "KILabel.h"

@interface FeedCell : UITableViewCell
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIImageView *userImageView;
@property (nonatomic, weak) UIImageView *feedImageView;
@property (nonatomic, weak) UIImageView *videoThumbnailImgView;
@property (nonatomic, weak) UIView *documentView;
@property (nonatomic, weak) UIImageView *documentThumbnailImgView;
@property (nonatomic, weak) UIImageView *img_document_type;
@property (nonatomic, weak) UILabel *lbl_doc_file_name;
@property (nonatomic,weak)  UIView *documentContainerVw;
@property (nonatomic, weak) UILabel *userNameLabel;
@property (nonatomic, weak) UILabel *lastActivityLabel;
@property (nonatomic, weak) UILabel *lastActivitySepLineLabel;
@property (nonatomic, weak) KILabel *specialityTagNameLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *assoLabel;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *feedTypelabel;
@property (nonatomic, weak) UIButton *editButton;  // edit btn click
@property (nonatomic, weak) UITextView *contentTextView;
@property (nonatomic, weak) UILabel *sepLine;
@property (nonatomic, weak) UIButton *trustButton;
@property (nonatomic, weak) UIButton *commentButton;
@property (nonatomic, weak) UIButton *shareButton;
@property (nonatomic, weak) UIImageView *likeImageView;
@property (nonatomic, weak) UILabel  *poplaritlyLabel;
@property (nonatomic, weak) UIImageView *feedTypeImageView;
@property (nonatomic, weak) UIButton *seeMoreButton;
@property (nonatomic, weak) UIButton *openProfileButton;
@property (nonatomic, weak) UIButton *openMetaDataButton;
@property (nonatomic, weak) UIWebView *feedmetaWebView;
@property (weak, nonatomic) UIButton *videoplayBtn;
@property (weak, nonatomic) UIButton *documentBtn;
@property (nonatomic, weak) MPMoviePlayerController *videoPlayer;
@property (nonatomic, weak) UIView *feedMultipleImageView;
@property (nonatomic, weak) UIImageView *firstImageView;
@property (nonatomic, weak) UIImageView *secondImageView;
@property (nonatomic, weak) UIImageView *thirdImageView;
@property (nonatomic, weak) UIImageView *fourthImageView;
@property (nonatomic,weak)  NSDictionary *feedData;
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) RFLayout *layout;

- (void)setInfo:(NSDictionary*)feedInfo;
@end
