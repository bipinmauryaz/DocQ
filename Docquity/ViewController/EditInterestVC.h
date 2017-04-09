/*============================================================================
 PROJECT: Docquity
 FILE:    EditInterestVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/05/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "ProfileData.h"

/*============================================================================
 Interface: EditInterestVC
 =============================================================================*/
@interface EditInterestVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView*editIntTV;
    NSMutableArray*editIntListArray;
    IBOutlet UILabel *IntNameLbl;
    NSMutableArray *editdatainfo;
    IBOutlet UITextField*addIntTF;
}

@property (nonatomic) NSMutableArray *editIntListArray;
@property (strong, nonatomic) IBOutlet UITableView *editIntTV;
@property(nonatomic,strong)IBOutlet UITableViewCell *editIntCell;
@property(nonatomic,strong) NSString* editIntId;
@property (strong, nonatomic)IBOutlet UITextField*addIntTF;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property(nonatomic,strong) UIToolbar *myToolbar;

-(IBAction)addBtn:(id)sender;
- (IBAction)doneEditing:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)AddBtnClick:(UIButton*)sender event:(id)event;

@end

@protocol  EditInterestVC  <NSObject>
-(void)EditProfileViewReturnWithInterestId:(NSString*)InterestId update_InterstName:(NSString*)update_InterstName withindex:(NSInteger)update_index;
@end
