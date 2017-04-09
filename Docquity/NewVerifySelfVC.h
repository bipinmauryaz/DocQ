//
//  NewVerifySelfVC.h
//  Docquity
//
//  Created by Arimardan Singh on 23/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewVerifySelfVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tableViewSpeciality;
    IBOutlet UITextField *tfSearch;
    BOOL isSearching;
}

@property (nonatomic,assign)id delegate;
@property(strong,nonatomic)NSMutableArray *arraySpecialityName;
@property(strong,nonatomic)NSMutableArray *arraySpeciality;
@property(strong,nonatomic)NSMutableArray *arraySelectedCell;
@property(strong,nonatomic)NSMutableArray *arrFiltered;
@property (weak, nonatomic)IBOutlet UIButton *btnNext;

@end

@protocol selectInterst <NSObject>
-(void)selectedInterstName:(NSMutableArray*)Name InterestID:(NSMutableArray*)interestId InterestArray:(NSMutableArray*)interestxMainArr;

@end
