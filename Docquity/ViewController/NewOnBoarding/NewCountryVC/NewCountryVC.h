//
//  NewCountryVC.h
//  Docquity
//
//  Created by Docquity-iOS on 24/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryCellTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface NewCountryVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITextField *tfSerchCountry;
    IBOutlet UITableView *tableViewCountry;
    NSString*associationCount;
    NSString*countryId;
    NSString*countryCode;
    NSString*countryName;
    BOOL isSearching;
}
@property (nonatomic,strong) NSString *userType;
@property(strong,nonatomic)NSMutableArray *arrDataSource;
@property(strong,nonatomic)NSMutableArray *arrFiltered;

@end
