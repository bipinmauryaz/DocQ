//
//  UniversitySearchVC.h
//  Docquity
//
//  Created by Arimardan Singh on 11/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniversitySearchVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate,UISearchControllerDelegate>{
    NSString *str;
    bool searchBarActive;
    NSArray *dic;
    NSDictionary *dic1;
    NSString *searchTxt;
    IBOutlet UILabel *nilLbl;
}

@property (nonatomic, assign)id delegate;
@property (strong, nonatomic) IBOutlet UIView *nilView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *uni_nameListArr;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@protocol UniversitySearchVC <NSObject>
-(void)UpdateInfoWithUniversityId:(NSString*)update_university_id update_university_name:(NSString*)update_university_name;
@end

