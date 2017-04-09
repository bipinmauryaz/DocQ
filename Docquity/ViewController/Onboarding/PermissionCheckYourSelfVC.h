//
//  PermissionCheckYourSelfVC.h
//  Docquity
//
//  Created by Arimardan Singh on 26/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPopupListView.h"
#import "Server.h"

@interface PermissionCheckYourSelfVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LPPopupListViewDelegate,UITableViewDataSource,UITableViewDelegate,ServerRequestFinishedProtocol,UIGestureRecognizerDelegate>{
    NSString *u_ImgType;
    NSString *base64EncodedString;
    NSMutableArray *documentList;
    ServerRequestType1 currentRequestType;
    BOOL isImgUpload;
    BOOL isclick;
    IBOutlet UIButton *uploadIdBtn;
    NSString* fileUrl;
 }

@property (weak, nonatomic) IBOutlet UILabel *lbl_welcomemsg;
@property (weak, nonatomic) IBOutlet UIButton *btn_skip;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *chooseImgHolder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popupParentView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic,strong) NSMutableDictionary *userData;

@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnknowYourIdProof;
@property (nonatomic,strong)NSString *selectedCountry;
@property (nonatomic,strong)NSString *selectedAssoID;

@property (weak, nonatomic) IBOutlet UILabel *lbl_title_desc;
@property (weak, nonatomic) IBOutlet UILabel *lbl_documentUpload;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TitleMsg;
@property (weak, nonatomic) IBOutlet UITextField *tf_RegNo;

@property (weak, nonatomic) NSString*titleMsg;
@property (weak, nonatomic) NSString*titledesc;
@property (weak, nonatomic) NSString*tf_placeholder;
@property (strong, nonatomic) NSString*idetityValue;
@property (strong, nonatomic) NSString*IcnumberValue;
@property (nonatomic,strong)NSString *identityTypMsg;

- (IBAction)didPressGotIT:(id)sender;

@end
