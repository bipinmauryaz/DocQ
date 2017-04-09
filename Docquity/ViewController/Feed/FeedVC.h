/*============================================================================
 PROJECT: Docquity
 FILE:    FeedVC.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 22/10/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KILabel.h"
#import "LPPopupListView.h"
#import "Server.h"

/*============================================================================
 Interface: FeedVC
 =============================================================================*/
@interface FeedVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UIWebViewDelegate,UIActionSheetDelegate,LPPopupListViewDelegate,ServerRequestFinishedProtocol>
{
    //web services request enum type
    ServerRequestType1 currentRequestType;
    
    NSMutableArray *myfeed_casesArr;
    NSMutableArray *myfeedArr;
    IBOutlet UITableView *myfeedTV;
    AVAudioPlayer *audioPlayer;
    IBOutlet UILabel *nilLbl;
    NSMutableData *receivedData;
    IBOutlet UIButton* trends_button;
    IBOutlet UIButton* cases_button;
    
    //Add button icons
    IBOutlet UIImageView*trends_icon;
    IBOutlet UIImageView*cases_icon;
    BOOL isCases;
    BOOL isserviceCall;
    BOOL isClickFromShare;
    BOOL  ischeckCME;
    KILabel*sepcilityLbl;
    BOOL  ischeckAssoctiationlist;
    IBOutlet UIButton *btnKnowValid;
    NSMutableArray *documentList;
    NSMutableArray *associationList;
    NSMutableString *assoName;
    NSMutableArray *myAssociationList;
    
    NSString* JabberName;               // Store user jabber Name
    NSString* JabberID;                 // Store user jabber id
    NSString* jabberPassword;           // User jabber password
    NSString* chatId;                   // User chat ID
}

@property(nonatomic,strong)NSMutableArray *myAssociationList;
@property (strong, nonatomic) IBOutlet UIView *nilView;
@property(nonatomic,strong) NSMutableArray *myfeedArr;
@property(nonatomic,strong) IBOutlet UITableView *myfeedTV;
@property (nonatomic, strong) IBOutlet UITableView* mycaseTV;
@property(nonatomic,strong) NSMutableArray *myfeed_casesArr;

//video play action
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) MPMoviePlayerViewController *moviePlayerViewController;

// button action
@property (nonatomic, strong)  IBOutlet UIButton* trends_button;
@property (nonatomic, strong)  IBOutlet UIButton* cases_button;

-(IBAction)addFeedBtn:(id)sender;
-(IBAction)buttonChangedonClick:(UIButton *)sender;


@property(weak,nonatomic)IBOutlet UIImageView *imageViewUserIdentityImage;
@property (weak, nonatomic) IBOutlet UIButton *btn_skip;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *chooseImgHolder;
@property (weak, nonatomic) IBOutlet UITableView *assotableView;
@property (weak, nonatomic) IBOutlet UIView *popupParentView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic,strong) NSMutableDictionary *userData;

- (IBAction)didPressGotIT:(id)sender;
-(IBAction)btnKnowValidClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton*IdentityProofBtn;
@property (weak, nonatomic) IBOutlet UIButton*uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;


@end
