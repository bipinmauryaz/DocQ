/*============================================================================
 PROJECT: Docquity
 FILE:    NewCommentVC.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/09/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KILabel.h"

/*============================================================================
 Interface: NewCommentVC
 =============================================================================*/
@interface NewCommentVC : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextViewDelegate,UIToolbarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>{
    BOOL isImg;
    BOOL ismetaData;
    BOOL isVideo;
    BOOL isDocument;
    NSString*feedmetaUrlLink;
    NSString*documentfeedUrlLink;
    NSString*feedsshareUrl;
    UILabel*assoLbl;
    UILabel *LblTitle;
    
    UILabel *LblTime;
    NSString*feed_ImgURL;
    UIButton *BtnLike;
    NSString*fileUrlLink;
    UIView *documentView;
    UILabel *lbl_doc_file_name;
    UIView *documentContainerVw;
    UIImageView *img_document_type;
    NSInteger myLikeStatus;
    UILabel *LbltrustCount;
    NSInteger offset;
    NSString *limit;
    UIBarButtonItem *postbtn;
    UITextView *commentTextView;
    UILabel *placeholder;
    float _previousContentHeight;
    NSString *lastComment;
    NSInteger selectedSection;
    NSInteger selectedRow;
    BOOL isReplyComment;
    NSString *selectedComment;
    NSInteger totalLikes;
    BOOL isMyLike;
    NSInteger totalComment;
    BOOL isClickFromShare;
    
    UIImageView *singleImage;
    UIImageView *imageView;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    UIButton *imgBtn;
    UIButton *imgBtn2;
    UIButton *imgBtn3;
    UIButton *imgBtn4;
    UITapGestureRecognizer *tap;
    BOOL isCommentpost;
    BOOL isCheckviaRefreshComments;
@private
    BOOL keyboardIsVisible;
}
//@property (weak, nonatomic) IBOutlet KILabel *specialityTaglbl;
@property (nonatomic,assign)id delegate;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) NSMutableArray *feedInfo;
@property(nonatomic,strong) NSMutableArray *commentArray;
@property (strong, nonatomic) NSDictionary*feedDict;
@property (strong, nonatomic) NSString *feedid;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (nonatomic) BOOL isNoifPView;
@property(nonatomic,strong)NSString*t_likeStr;
@property(nonatomic,strong)NSString*t_likeStatusStr;
@property(nonatomic,strong)NSString*feedCommentIdStr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomConstraintsToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeightConstraints;
@end

@protocol NewcommentView <NSObject>
-(void)commentviewReturnsForFeedid:(NSString*)feedid commentCount:(NSString*)TotalComment LikesCount:(NSString*)TotalLikes ilike:(BOOL)flag updatedTimeStamp:(NSString *)updateTimeStamp;
-(void)isDeleteFeed:(BOOL)isdelete Feedid:(NSString*)feedid;
-(void)feedHasChanges;
@end
