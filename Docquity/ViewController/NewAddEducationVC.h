//
//  NewAddEducationVC.h
//  Docquity
//
//  Created by Arimardan Singh on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileData.h"

@interface NewAddEducationVC : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>{
    
    NSString *schoolinfo;
    NSString* degree;
    NSString* toYear;
    NSString*fldStdy;
    NSString* yop;
    NSString* courseTp;
    NSString* currPur;
    NSInteger flg, indexnum;
    NSMutableArray *editdatainfo;
    UIView *newviewforPicker;
    bool viewopen;
    
   IBOutlet UIButton *AddmoreBtn;
   IBOutlet UIButton *SaveBtn;
   IBOutlet UIButton *deleteBtn;
   BOOL isback;
}

@property(nonatomic,weak) IBOutlet UIImageView *CheckBoxCWH;
@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (strong, nonatomic) IBOutlet UIView *add_eduView;
@property (strong, nonatomic) IBOutlet UIView *edit_eduView;
@property (strong, nonatomic) IBOutlet UIView *currentPur_eduView;
@property(nonatomic,weak)IBOutlet UITextField *QuaLevelTF;
@property(nonatomic,weak)IBOutlet UITextField *InstNameTf;
@property(nonatomic,weak)IBOutlet UIButton *EndYearBtn;

@property(nonatomic,strong) UIToolbar *myToolbar;
@property(nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,copy)  NSArray *options;
@property (nonatomic,assign) NSInteger selIndex;
@property(nonatomic,strong) NSMutableDictionary* filldicdata;
@property(nonatomic)BOOL isSaveBtnCliked;
-(void) setData : (NSMutableArray *)Filldata withindex: (NSInteger)index flag: (NSInteger)flag;
- (void) endEditing;

-(IBAction)addmore:(UIButton*)sender;
-(IBAction)Save:(UIButton*)sender;
-(IBAction)deleteBtn:(UIButton*)sender;

@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousBarBt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarBt;
//@property (nonatomic,assign)id delegate;

//private method of keyboard Accessory view
- (IBAction)nextInputField:(id)sender;
- (IBAction)previousInputField:(id)sender;
- (IBAction)doneEditing:(id)sender;

    
@end

//@protocol NewAddEducationVC <NSObject>
//
//-(void)EditProfileViewReturnWithEduId:(NSString*)EduId update_InstituteName:(NSString *)update_InstituteName update_degree:(NSString *)update_degree update_passyear:(NSString *)update_passyear update_currpur:(NSString *)update_currpur withindex:(NSInteger)update_index;
//@end
