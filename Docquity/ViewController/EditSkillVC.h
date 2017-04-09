/*============================================================================
 PROJECT: Docquity
 FILE:    EditSkillVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 16/06/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "ProfileData.h"

/*============================================================================
 Interface: EditSkillVC
 =============================================================================*/
@interface EditSkillVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView*editSkillTV;
    NSMutableArray*editSkillListArray;
    IBOutlet UILabel *skillNameLbl;
    NSMutableArray *editdatainfo;
}

@property (nonatomic) NSMutableArray*editSkillListArray;;
@property (strong, nonatomic) IBOutlet UITableView*editSkillTV;
@property(nonatomic,strong)IBOutlet UITableViewCell *editSkillCell;
@property(nonatomic,strong) NSString* editSkillId;

#pragma mark - back Button Action
-(IBAction)goBack:(id)sender;
@end



