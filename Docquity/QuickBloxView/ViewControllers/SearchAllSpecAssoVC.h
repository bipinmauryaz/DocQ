//
//  SearchAllSpecAssoVC.h
//  Docquity
//
//  Created by Docquity-iOS on 15/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAllSpecAssoVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *FinalArray;
@property (nonatomic,strong) NSString *dataFor;
@property (nonatomic,strong) NSString *keyword;
@end
