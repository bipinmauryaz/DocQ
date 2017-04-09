//
//  TableSearchView.m
//  Docquity
//
//  Created by Docquity-iOS on 22/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "TableSearchView.h"
#import "NewHomeVC.h"

@implementation TableSearchView

-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)dataSource viewController:(UIViewController*)currentController{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];
        subView = [[UIView alloc]initWithFrame:CGRectMake(20, 50, frame.size.width-40, frame.size.height-80)];
        subView.backgroundColor = [UIColor whiteColor];
        [self addSubview:subView];
        viewController = currentController;
        
        _arrDataSource = [NSMutableArray arrayWithArray:dataSource];
    
        _tfSearch = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, subView.frame.size.width, 50)];
        _tfSearch.delegate = self;
        _tfSearch.placeholder = @"Search Countries..";
        [subView addSubview:_tfSearch];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        _tfSearch.leftView = paddingView;
        _tfSearch.leftViewMode = UITextFieldViewModeAlways;
        
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tfSearch.frame), subView.frame.size.width, subView.frame.size.height-100)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [subView addSubview:_tableView];
        
        UILabel *lblSep = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tableView.frame), subView.frame.size.width, .5)];
        lblSep.backgroundColor = [UIColor lightGrayColor];
        lblSep.text = @"";
        [subView addSubview:lblSep];
        
        _btnClose = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lblSep.frame), subView.frame.size.width, 49.5)];
        [_btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnClose setTitle:@"CANCEL" forState:UIControlStateNormal];
        _btnClose.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_btnClose addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:_btnClose];
     }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

-(void)didMoveToWindow {
    if (self.window) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyBoardShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyBoardHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

-(void)keyBoardShow:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y, _tableView.frame.size.width,height-40);
    NSLog(@"%d",height);
}

-(void)keyBoardHide:(NSNotification *)notification{
    _tableView.frame = CGRectMake(0, CGRectGetMaxY(_tfSearch.frame), subView.frame.size.width, subView.frame.size.height-100);
}

#pragma mark - UIbutton Actions
-(void)btnCloseClicked:(UIButton *)sender{
    if (strSelectedCountryCode == nil) {
            [WebServiceCall showAlert:@"Docquity" andMessage:@"Please select a country first" withController:viewController];
      }else
    [self removeFromSuperview];
}

#pragma mark - Tableview Delagtes and DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearching) {
        return _arrFiltered.count;
    }else
    return self.arrDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect cellFrame = cell.frame;
        cellFrame.size.width = subView.frame.size.width;
        cell.frame = cellFrame;

        }
    
    for(UILabel *lbl in [cell subviews])
    {
            [lbl removeFromSuperview];
    }
    
    for (UIImageView *imageView in cell.subviews) {
        
            [imageView removeFromSuperview];
    }
    
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 20, 20)];
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    if (isSearching) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:[_arrFiltered objectAtIndex:indexPath.row][@"country_pic"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
    }else
    [imageView sd_setImageWithURL:[NSURL URLWithString:[_arrDataSource objectAtIndex:indexPath.row][@"country_pic"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
    [cell addSubview:imageView];
    
    UILabel *lblCountryCode = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.size.width-50, (cell.frame.size.height-20)/2, 40, 20)];
    lblCountryCode.textColor = [UIColor lightGrayColor];
    lblCountryCode.textAlignment = NSTextAlignmentLeft;
    lblCountryCode.font = [UIFont systemFontOfSize:11];
    NSString *strCountryCode = [NSString stringWithFormat:@"+%@",[[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country_code"]];
    if (isSearching) {
        lblCountryCode.text = [NSString stringWithFormat:@"+%@",[[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country_code"]];

    }else
    
    lblCountryCode.text = strCountryCode;
    [cell addSubview:lblCountryCode];

    
    UILabel *lblCountryName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+10, 20, CGRectGetMinX(lblCountryCode.frame)-10, 20)];
    lblCountryName.textAlignment = NSTextAlignmentLeft;
    lblCountryName.font = [UIFont systemFontOfSize:13];
    lblCountryName.textColor = [UIColor grayColor];
    if (isSearching) {
        lblCountryName.text = [[_arrFiltered objectAtIndex:indexPath.row]objectForKey:@"country"];
    }else
    lblCountryName.text = [[_arrDataSource objectAtIndex:indexPath.row]objectForKey:@"country"];
    [cell addSubview:lblCountryName];
    
    
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([[_arrDataSource objectAtIndex:indexPath.row] isEqualToString:strSelectedValue]) {
//    }else{
//        strSelectedValue = [_arrDataSource objectAtIndex:indexPath.row];
//        [_tableView reloadData];
//    }
}


#pragma mark - UItextfield Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length==0 && [string isEqualToString:@" "]) {
        return NO;
    }
    NSLog(@"%@",string);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@", [textField.text stringByReplacingCharactersInRange:range withString:string]];
    NSArray *filtered = [_arrDataSource filteredArrayUsingPredicate:predicate];
    if (filtered.count) {
        _arrFiltered = [NSMutableArray arrayWithArray:filtered];
        [_tableView reloadData];
    }
    return true;
}

@end
