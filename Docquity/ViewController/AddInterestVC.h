/*============================================================================
 PROJECT: Docquity
 FILE:    AddInterestVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/05/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "Server.h"

/*============================================================================
 Interface: AddInterestVC
 =============================================================================*/
@interface AddInterestVC : UIViewController<UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>{
    
    IBOutlet UITextField*addIntTF;
    NSMutableArray *editdatainfo;
}

@property(nonatomic) BOOL isSaveBtnClicked;
@property(nonatomic,strong) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *scvwContentView;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property(nonatomic,strong) UIToolbar *myToolbar;
@property (strong, nonatomic)IBOutlet UITextField*addIntTF;


- (IBAction)doneEditing:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)saveBtn:(id)sender;
-(IBAction)saveAndMoreBtn:(id)sender;



@end
