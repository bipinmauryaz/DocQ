//
//  NewUploadVC.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPopupListView.h"
#import "Server.h"

@interface NewUploadVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LPPopupListViewDelegate,UITableViewDataSource,UITableViewDelegate,ServerRequestFinishedProtocol,UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *btnKnowValid;
    NSMutableArray *documentList;
    NSString *u_ImgType;
    NSString *base64EncodedString;
    NSString *mediaPath;
    NSMutableString *dataPath;
    NSInteger statusResponse;
    NSString *imgUrl;
    NSUserDefaults *userdef;
    ServerRequestType1 currentRequestType;
    NSString* fileUrl;
}

@property(weak,nonatomic)IBOutlet UIImageView *imageViewUserIdentityImage;
@property (weak, nonatomic) IBOutlet UIButton *btn_skip;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *chooseImgHolder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popupParentView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic,strong) NSMutableDictionary *userData;

- (IBAction)didPressGotIT:(id)sender;
-(IBAction)btnKnowValidClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton*IdentityProofBtn;
@property (weak, nonatomic) IBOutlet UIButton*uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;
@property(weak, nonatomic)NSString*registeredUserType;

@end
