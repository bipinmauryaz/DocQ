//
//  QBSearchFriendsViewController.h
//  Docquity
//
//  Created by Docquity-iOS on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBSearchFriendsViewController : UIViewController
{
    NSArray *friendsArray;
    NSArray *assoArray;
    NSArray *specArray;
    BOOL shouldShowSearchResults;
    BOOL backbuttonPress;
    NSInteger numberofsection;
    BOOL showAsso;
    NSString *lastSearch;
    NSMutableDictionary *dataDic;
    NSString *selectedFStatus;
    NSString *selectedFCustid;
    NSString * permstus; //check readonly permission

}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
