//
//  NewAddAssociationVC.h
//  Docquity
//
//  Created by Arimardan Singh on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileData.h"

@interface NewAddAssociationVC : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UIGestureRecognizerDelegate>
{
    UIView *newviewforPicker;
    bool viewopen;
    
    NSString *companyinfo;
    NSString* profile;
    NSString* locations;
    NSString*asso_StMonth;
    NSString*asso_EndMonth;
    NSString*asso_StDate;
    NSString*asso_EndDate;
    NSString*asso_Desc;
    NSString*currProf;
    NSInteger flg, indexnum;
    NSMutableArray *editdatainfo;
    BOOL startMChoose,startYChoose;
    NSMutableArray *tempYear;
    UIButton *lastButtonClicked;
    IBOutlet UIButton *AddmoreBtn;
    IBOutlet UIButton *SaveBtn;
    IBOutlet UIButton *deleteBtn;
}

@property(nonatomic,weak) IBOutlet UIImageView *CheckBoxCWH;
@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (strong, nonatomic) IBOutlet UIView *currPurr_assoView;
@property (strong, nonatomic) IBOutlet UIView *add_assoView;
@property (strong, nonatomic) IBOutlet UIView *edit_assoView;
@property(nonatomic,weak)IBOutlet UITextField *CompNameTf;
@property(nonatomic,weak)IBOutlet UITextField *TitleTf;
@property(nonatomic,weak)IBOutlet UITextField *LocationTf;
@property(nonatomic,weak)IBOutlet UIButton *StartYearBtn;
@property(nonatomic,weak)IBOutlet UIButton *EndYearBtn;
@property(nonatomic,weak)IBOutlet UIButton *StartMonthBtn;
@property(nonatomic,weak)IBOutlet UIButton *EndMonthBtn;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousBarBt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;
@property(nonatomic,strong) NSMutableDictionary *profileDic;
@property(nonatomic) BOOL isSaveBtnClicked;

-(void) setData : (NSMutableArray *)Filldata withindex: (NSInteger)index flag: (NSInteger)flag;

-(IBAction)addmore:(UIButton*)sender;
-(IBAction)Save:(UIButton*)sender;
-(IBAction)deleteBtn:(UIButton*)sender;

//private method of keyboard Accessory view
- (IBAction)nextInputField:(id)sender;
- (IBAction)previousInputField:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end
