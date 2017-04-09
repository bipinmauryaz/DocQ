//
//  NewUniversitySearchVC.h
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewUniversityCell.h"
#import "SpecialityVC.h"

@interface NewUniversitySearchVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    IBOutlet UITableView *tableViewSearch;
    IBOutlet UITextField *tfSearch;
    UITextField *activeField;
}

@property (nonatomic,strong) NSString *registered_userType;
@property(strong,nonatomic)NSString *strSearchTerm;
@property(strong,nonatomic)NSMutableArray *arrFiltered;
@property(strong,nonatomic)NSMutableArray *arrayUniSearch;
@property (strong, nonatomic) IBOutlet UIToolbar *keybAccessory;
@property(nonatomic,strong) UIToolbar *myToolbar;

@end
