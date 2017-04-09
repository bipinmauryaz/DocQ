//
//  LPPopupListView.m
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Luka Penger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPPopupListView.h"
#import "AppDelegate.h"
#import "AssociationModel.h"
#import "UIImageView+WebCache.h"
#define navigationBarHeight 44.0f
#define seachBarWidth 20.0f
#define separatorLineHeight 1.0f
#define closeButtonWidth 30.0f
#define navigationBarTitlePadding 12.0f
#define animationsDuration 0.25f


@interface LPPopupListView ()<UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, strong) NSString *navigationBarTitle;
@property (nonatomic, assign) BOOL isMultipleSelection;
@property (nonatomic, strong) AssociationModel *assoModel;
@end


@implementation LPPopupListView
{
    //Content View
    UIView *contentView;
}

static BOOL isShown = false;

#pragma mark - Lifecycle

- (id)initWithTitle:(NSString *)title list:(NSArray *)list selectedIndexes:(NSIndexSet *)selectedList point:(CGPoint)point size:(CGSize)size multipleSelection:(BOOL)multipleSelection disableBackgroundInteraction:(BOOL)diableInteraction
{
    CGRect contentFrame = CGRectMake(point.x, point.y,size.width,size.height);
    
    //Disable background Interaction
    if (diableInteraction)
    {
        self = [super initWithFrame:[UIScreen mainScreen].bounds];
    }
    else
    {
        self = [super initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        contentFrame = CGRectMake(point.x, point.y, size.width, size.height);
    }
    
    
    if (self)
    {
        shouldShowSearchResults = false;
        //Content View
        contentView = [[UIView alloc] initWithFrame:contentFrame];
        contentView.layer.cornerRadius = 6.0;
        contentView.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0];
        
        self.cellHighlightColor = [UIColor colorWithRed:(0.0/255.0) green:(60.0/255.0) blue:(127.0/255.0) alpha:0.5f];
        
        self.navigationBarTitle = title;
        self.arrayList = [NSArray arrayWithArray:list];
        self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedList];
        self.isMultipleSelection = multipleSelection;

        self.navigationBarView = [[UIView alloc] init];
        self.navigationBarView.layer.cornerRadius = 6.0;
        self.navigationBarView.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0];
        [contentView addSubview:self.navigationBarView];

        self.separatorLineView = [[UIView alloc] init];
        self.separatorLineView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
        [contentView addSubview:self.separatorLineView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.userInteractionEnabled = YES;
        self.titleLabel.text = self.navigationBarTitle;
        self.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        self.titleLabel.textColor =[UIColor colorWithRed:163.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:1.0];
        [self.navigationBarView addSubview:self.titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSearchbar)];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"cross-mark.png"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [self.navigationBarView addSubview:self.closeButton];
       
        self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.searchBtn setImage:[UIImage imageNamed:@"search-asso.png"] forState:UIControlStateNormal];
        [self.searchBtn addTarget:self action:@selector(showSearchbar) forControlEvents: UIControlEventTouchUpInside];
        self.searchBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 1);
        if ([self.navigationBarTitle isEqualToString:@"Select Country"]){
            [self.titleLabel addGestureRecognizer:tap];
            [self.navigationBarView addSubview:self.searchBtn];
        }
        
        
        self.searchbar = [[UISearchBar alloc] init];
        self.searchbar.delegate = self;
        self.searchbar.alpha = 0.0;
        self.searchbar.placeholder = @"Search Country";
        self.searchbar.showsCancelButton = true;
        self.searchbar.barTintColor = kThemeColor;
        
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
        self.searchbar.layer.mask = maskLayer;
        self.searchbar.layer.masksToBounds = YES;
        self.searchbar.clipsToBounds = YES;
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor whiteColor],
           NSBackgroundColorAttributeName:[UIColor redColor]
           } forState:UIControlStateNormal];
        
        [self.navigationBarView addSubview:self.searchbar];
    
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [contentView addSubview:self.tableView];
        [self addSubview: contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:contentView.bounds];
    contentView.layer.masksToBounds = NO;
    contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    contentView.layer.shadowOpacity = 0.5f;
    contentView.layer.shadowPath = shadowPath.CGPath;
    contentView.clipsToBounds = YES;
    self.navigationBarView.frame = CGRectMake(0.0f, 0.0f, contentView.frame.size.width, navigationBarHeight);
    
    self.separatorLineView.frame = CGRectMake(0.0f, self.navigationBarView.frame.size.height, contentView.frame.size.width, separatorLineHeight);
    
    self.closeButton.frame = CGRectMake((self.navigationBarView.frame.size.width-closeButtonWidth - 5), 10.0f, closeButtonWidth, closeButtonWidth);
    
    self.searchBtn.frame = CGRectMake((self.navigationBarView.frame.size.width-closeButtonWidth - seachBarWidth - 12), 14.0f, seachBarWidth, seachBarWidth);
    
    self.titleLabel.frame = CGRectMake(navigationBarTitlePadding, 0.0f, (self.navigationBarView.frame.size.width-seachBarWidth-closeButtonWidth-(navigationBarTitlePadding * 2)), navigationBarHeight);
    
    self.searchbar.frame = CGRectMake(0.0f, 0.0f, self.navigationBarView.frame.size.width, navigationBarHeight);
    
    
    self.tableView.frame = CGRectMake(0.0f, (navigationBarHeight + separatorLineHeight), contentView.frame.size.width, (contentView.frame.size.height-(navigationBarHeight + separatorLineHeight)));
    
    
}

- (void)closeButtonClicked:(id)sender
{
    [self hideAnimated:self.closeAnimated];

}

-(void)showSearchbar{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.searchBtn.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        self.titleLabel.alpha = 0.0;
        self.searchbar.alpha = 0.0;
        self.closeButton.alpha = 0.0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _searchbar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_searchbar becomeFirstResponder];
                         }];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    shouldShowSearchResults =  NO;
    [UIView animateWithDuration:0.5f animations:^{
        _searchbar.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^ {
            self.searchBtn.alpha = 1.0;
            self.titleLabel.alpha = 1.0f;
            self.closeButton.alpha = 1.0f;
        }];
    }];
    [self.searchbar resignFirstResponder];
    shouldShowSearchResults = false;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(shouldShowSearchResults){
        return  searchResults.count;
    }else
    return [self.arrayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LPPopupListViewCell";
    
    LPPopupListViewCell *cell = [[LPPopupListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    cell.highlightColor = self.cellHighlightColor;

    
    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:indexPath.row]) {
            cell.rightImageView.image = [UIImage imageNamed:@"checkMark"];
        } else {
            cell.rightImageView.image = nil;
        }
    }
    if ([self.navigationBarTitle isEqualToString:@"Select Association"]) {
        self.assoModel = [self.arrayList objectAtIndex:indexPath.row];
        cell.lableTitle.text = self.assoModel.fullname;

        [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:self.assoModel.flagUrl] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else if ([self.navigationBarTitle isEqualToString:@"Select Country"]){
//        cell.lableTitle.text = [self.arrayList objectAtIndex:indexPath.row][@"country"];
//        [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.arrayList objectAtIndex:indexPath.row][@"country_pic"]]] placeholderImage:[UIImage imageNamed:@"no-img.png"] options:SDWebImageRefreshCached];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        
        if(shouldShowSearchResults){
        
            cell.lableTitle.text = [searchResults objectAtIndex:indexPath.row][@"country"];
            [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[searchResults objectAtIndex:indexPath.row][@"country_pic"]]] placeholderImage:[UIImage imageNamed:@"no-img.png"] options:SDWebImageRefreshCached];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else{
        
            cell.lableTitle.text = [self.arrayList objectAtIndex:indexPath.row][@"country"];
            [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.arrayList objectAtIndex:indexPath.row][@"country_pic"]]] placeholderImage:[UIImage imageNamed:@"no-img.png"] options:SDWebImageRefreshCached];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        
        }
    }
    
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:indexPath.row]) {
            [self.selectedIndexes removeIndex:indexPath.row];
        } else {
            [self.selectedIndexes addIndex:indexPath.row];
        }

        [self.tableView reloadData];
    } else {
        isShown = false;
        
        if ([self.navigationBarTitle isEqualToString:@"Select Country"]){
        
            if(shouldShowSearchResults){
                [self.delegate filterdCountry:[searchResults objectAtIndex:indexPath.row][@"country"] countrycode:[searchResults objectAtIndex:indexPath.row][@"country_code"]];
            }else{
                if ([self.delegate respondsToSelector:@selector(popupListView:didSelectIndex:)]) {
                    
                    [self.delegate popupListView:self didSelectIndex:indexPath.row];
                }
            }
            
        }else{
            if ([self.delegate respondsToSelector:@selector(popupListView:didSelectIndex:)]) {
                
                [self.delegate popupListView:self didSelectIndex:indexPath.row];
            }
        }
        [self hideAnimated:self.closeAnimated];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54.0;
}
#pragma mark - Instance methods

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    if(!isShown) {
        isShown = true;
        self.closeAnimated = animated;
        
        if(animated) {
            contentView.alpha = 0.0f;
            [view addSubview:self];
            
            [UIView animateWithDuration:animationsDuration animations:^{
                contentView.alpha = 1.0f;
            }];
        } else {
            [view addSubview:self];
        }
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:animationsDuration animations:^{
            contentView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            isShown = false;
            
            if (self.isMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                    [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
                }
            }
            [self.delegate popupListViewCancel];
            [self removeFromSuperview];
        }];
    } else {
        isShown = false;
        
        if (self.isMultipleSelection) {
            if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
            }
        }
        
        [self removeFromSuperview];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length)
    shouldShowSearchResults = TRUE;
    else
        shouldShowSearchResults = FALSE;
    if(searchResults != nil){
        searchResults = nil;
    }
    searchResults = [[NSArray alloc]init];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"country contains[c] %@", searchText];
    
    searchResults = [NSArray arrayWithArray:[self.arrayList filteredArrayUsingPredicate:resultPredicate]];
    
    [self.tableView reloadData];
    
}



@end
