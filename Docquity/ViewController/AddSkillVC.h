/*============================================================================
 PROJECT: Docquity
 FILE:    AddSkillVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 16/06/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>

@interface AddSkillVC : UIViewController<UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
   
    IBOutlet UITextField*addSkillTF;
     UIPickerView *pickerView;
     NSMutableArray *editdatainfo;
}

@property(nonatomic,strong)  UIPickerView *pickerView;
@property(nonatomic,strong) NSMutableArray *sepclListArr;
@property(nonatomic) BOOL isSaveBtnClicked;
@property(nonatomic,strong) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property(nonatomic,strong) UIToolbar *myToolbar;

-(IBAction)doneEditing:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)saveBtn:(id)sender;
-(IBAction)saveAndMoreBtn:(id)sender;

@property (strong, nonatomic)IBOutlet UITextField*addSkillTF;


@end

