//
//  UserSearchViewController.h
//  Docquity
//
//  Created by Docquity-iOS on 16/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSearchViewController : UIViewController{
    NSString * permstus; //check readonly permission
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic,strong) NSString *keyword;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *typeID;
@property (nonatomic,strong) NSString *selectedFStatus;
@property (nonatomic,strong) NSString *selectedFCustid;
@end
