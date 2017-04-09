/*============================================================================
 PROJECT: Docquity
 FILE:    VerifyYourSelfVC.h
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 01/09/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>

@interface VerifyYourSelfVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITextField *tfInvite;
    NSInteger statusResponse;
  
    BOOL isDontHaveICCode;
    NSInteger lastCellClick;
    NSString *icExample;
    NSString *icType;
    NSMutableDictionary *data_dic;
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray *Arr_specialityId;
    NSString*inviteCodeType;
    NSString*tfplachoder_inviteCodeEXample;
}
@property (nonatomic)BOOL isNewUser;
@property(nonatomic,strong) NSDictionary *verifyCheckDict;
@property (nonatomic,strong) NSString *userType;
@property (nonatomic,strong) NSString *emailValue;
@property (nonatomic,strong) NSString *inviteCodeValue;
@property (nonatomic,strong) NSString *medicalRegValue;
@property (nonatomic,strong) NSString *specialityValue;
@property (weak, nonatomic) IBOutlet UIView *popupBackView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *selectedCountry;
@property (nonatomic,strong) NSString *selectedCountryID;
@property (nonatomic,strong) NSString *userMobile;
@property (weak, nonatomic) IBOutlet UIButton *btnDont;
@property (nonatomic, retain) IBOutlet UITextField *actifText;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory; 
- (IBAction)doneEditing:(id)sender;

@property(nonatomic,strong) NSMutableArray *sepclListArr;
@property (strong, nonatomic) IBOutlet UILabel *lblSelectedCountryNames;

@end

@protocol VerifyYourSelfVC <NSObject>

-(void)UpdateDatalist:(NSMutableArray*)ArryData UpdateDataIdlist:(NSMutableArray*)IdArryData;
@end

