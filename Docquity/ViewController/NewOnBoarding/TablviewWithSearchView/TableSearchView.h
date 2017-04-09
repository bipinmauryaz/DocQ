//
//  TableSearchView.h
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
@interface TableSearchView : UIView<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSString *strSelectedCountryCode;
    BOOL isSearching;
    UIView *subView;
    UIViewController *viewController;
}

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UITextField *tfSearch;
@property(strong,nonatomic)UIButton *btnClose;

@property(strong,nonatomic)NSMutableArray *arrDataSource;
@property(strong,nonatomic)NSMutableArray *arrFiltered;


-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)dataSource viewController:(UIViewController*)currentController;
-(void)btnCloseClicked:(UIButton *)sender;

@end
