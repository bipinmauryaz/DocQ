//
//  UserChooseVC.h
//  Docquity
//
//  Created by Docquity-iOS on 29/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserChooseVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *userTypeArray;
@property (nonatomic, strong) NSString *userMobile;
@property (nonatomic)BOOL isNewUser;
@property (nonatomic,strong) NSString *selectedCountry;
@property (nonatomic,strong) NSString *selectedCountryID;

@end
