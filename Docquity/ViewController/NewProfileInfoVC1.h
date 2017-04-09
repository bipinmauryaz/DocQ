//
//  NewProfileInfoVC.h
//  Docquity
//
//  Created by Arimardan Singh on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ProfileData.h"

@protocol ImageUpdate <NSObject>
-(void)imgupdates:(NSString*)UpdateImageUrl;

@end
@interface NewProfileInfoVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITextField *fNameTF;
    IBOutlet UITextField *lNameTF;
    IBOutlet UITextField *nationalityTF;
    IBOutlet UITextField *cityTF;
    IBOutlet UITextField *emailTF;
    IBOutlet UITextField *stateTF;
    IBOutlet UITextField *contactNoTF;
    IBOutlet UIImageView*u_ProfileImg;
    IBOutlet UIImageView*camImg;
    
    UIImagePickerController *picker;
    NSString *mediaPath;
    NSMutableString *dataPath;
     BOOL isback;
}

@property (strong, atomic) ALAssetsLibrary* library;
@property (strong, nonatomic) IBOutlet UIButton *CountryCodeBtn;
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, assign)id delegate;

@property(nonatomic,strong)   IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (strong, nonatomic) IBOutlet UITextField *fNameTF;
@property (strong, nonatomic) IBOutlet UITextField *lNameTF;
@property (strong, nonatomic) IBOutlet UITextField *stateTF;
@property (strong, nonatomic) IBOutlet UITextField *emailTF;
@property (strong, nonatomic) IBOutlet UITextField *contactNoTF;
@property (strong, nonatomic) IBOutlet UITextField *nationalityTF;
@property (strong, nonatomic) IBOutlet UITextField *cityTF;
@property(nonatomic,strong) ProfileData *data;

@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousBarBt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;

@property(nonatomic,strong)UIImagePickerController *imgPicker;
@property(nonatomic,strong)  UIPickerView *pickerView;
@property(nonatomic) UIImagePickerController *picker;

//private method of keyboard Accessory view
- (IBAction)nextInputField:(id)sender;
- (IBAction)previousInputField:(id)sender;
- (IBAction)doneEditing:(id)sender;
-(IBAction)saveBtnClick:(id)sender;
-(IBAction)profileBtnClick:(id)sender;

@end

@protocol NewProfileInfoVC <NSObject>
-(void)EditProfileViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state;

@end
