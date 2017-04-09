//
//  QBSearchFriendsViewController.m
//  Docquity
//
//  Created by Docquity-iOS on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "QBSearchFriendsViewController.h"
#import "DefineAndConstants.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "ChatViewController.h"
#import "ServicesManager.h"
#import "SearchUserCell.h"
#import "SearchAssociationCell.h"
#import "SearchSpecCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Letters.h"
#import "SearchAllSpecAssoVC.h"
#import "UserSearchViewController.h"
#import "SVPullToRefresh.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"
#import "PermissionCheckYourSelfVC.h"
#import "NSString+HTML.h"
@interface QBSearchFriendsViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
UITextFieldDelegate
>
{
    int pageCount;
    NSString *limit;
}

//@property (weak, nonatomic) IBOutlet UISearchBar *searchController;
//@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSArray *filteredSList;
@property (strong, nonatomic) NSArray *filteredAList;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation QBSearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    backbuttonPress =  NO;
    shouldShowSearchResults = NO;
    pageCount = 1;
    limit = @"10";
    UIColor *thColor = kThemeColor;
    self.searchBar = [[UISearchBar alloc] init];
    dataDic = [[NSMutableDictionary alloc]init];
    _searchBar.showsCancelButton = YES;
    _searchBar.placeholder = @"Search Doctors";
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:thColor];
    _searchBar.delegate = self;
    
    friendsArray = [[NSArray alloc]init];
    assoArray = [[NSArray alloc]init];
    specArray = [[NSArray alloc]init];
    _filteredList = [NSArray new];
    _filteredSList = [NSArray new];
    _filteredAList = [NSArray new];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);

    __weak QBSearchFriendsViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
            [weakSelf getsearchData:nil];
        }position:SVPullToRefreshPositionBottom];

    if(!shouldShowSearchResults){
        [self.tableView setShowsPullToRefresh:NO];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.title = @"Search Peers";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem * rightitem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(SearchControllAppear)];
    self.navigationItem.rightBarButtonItem = rightitem;
    [self SearchControllAppear];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    UIColor *thColor = kThemeColor;
    self.navigationController.navigationBar.barTintColor = thColor;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],NSForegroundColorAttributeName,nil]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    [self.searchBar removeFromSuperview];
    [self.searchBar resignFirstResponder];
}

-(void)SearchControllAppear{
    [UIView animateWithDuration:0. animations:^{
        _searchButton.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        // remove the search button
        self.navigationItem.rightBarButtonItem = nil;
        // add the search bar (which will start out hidden).
        //        [self.navigationItem setHidesBackButton:YES animated:YES];
        self.navigationItem.titleView = _searchBar;
        _searchBar.alpha = 0.0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _searchBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_searchBar becomeFirstResponder];
                         }];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Delegates and Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(shouldShowSearchResults){
        if(section == 0){
            if(self.filteredSList.count >=1){
                return 1;
            }else{
                return 0;
            }
        }else if (section == 1){
            if(self.filteredAList.count >=1){
                return 1;
            }else{
                return 0;
            }
        }else if (section == 2){
            return self.filteredList.count;
        }else{
            return 0;
        }
    }else{
        
        if(section == 0){
            if(specArray.count >=1){
                return 1;
            }else{
                return 0;
            }
        }else if (section == 1){
            if(assoArray.count >=1){
                return 1;
            }else{
                return 0;
            }
        }else if (section == 2){
            return friendsArray.count;
        }else{
            return 0;
        }
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSInteger height = 0;
    if(shouldShowSearchResults) {
        switch (section) {
            case 0:
                if(self.filteredSList.count >0){
                    height = 30;
                }
                break;
                
            case 1:
                if(self.filteredAList.count >0){
                    height = 30;
                }
                break;
                
            case 2:
                if(self.filteredList.count >0){
                    height = 30;
                }
                break;
                
            default:
                height = 0;
                break;
        }
    }else{
       // height = 0;
        
        switch (section) {
            case 0:
                if(specArray.count >0){
                    height = 30;
                }
                break;
                
            case 1:
                if(assoArray.count >0){
                    height = 30;
                }
                break;
                
            case 2:
                if(friendsArray.count >0){
                    height = 30;
                }
                break;
                
            default:
                height = 0;
                break;
        }
    }
//    NSLog(@"Height = %ld",(long)height);
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    headerView.backgroundColor=[UIColor colorWithRed:237/255.0f green:237/255.0f blue:237/255.0f alpha:1.0f];
    UILabel *lbl  = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 30)];
    lbl.backgroundColor=[UIColor clearColor];
    [headerView addSubview:lbl];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-60, 0, 50, 30)];
    [moreButton setTitle:@"more" forState:UIControlStateNormal];
    UIColor *thColor = kThemeColor;
    moreButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    moreButton.tag = section;
    [moreButton setTitleColor:thColor forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(didPressMore:) forControlEvents:UIControlEventTouchUpInside];
    
    if (section==0) {
        lbl.text=@"SPECIALIZATION";
        if(self.filteredSList.count>1) [headerView addSubview:moreButton];
    }
    if (section==1) {
        lbl.text=@"ASSOCIATION";
        if(self.filteredAList.count>1) [headerView addSubview:moreButton];
    }
    if (section==2){
        lbl.text=@"NAME";
    }
    lbl.backgroundColor = [UIColor clearColor];
    [lbl setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
    lbl.textColor=[UIColor colorWithRed:143/255.0f green:143/255.0f blue:143/255.0f alpha:1.0f];
    
    return headerView;
    
    //    if (shouldShowSearchResults) {
    //        return headerView;
    //    }
    //    else{
    //        return nil;
    //    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *UserCellIdentifier = @"SearchUserCell";
    static NSString *SpecCellIdentifier = @"SearchSpecCell";
    static NSString *AssocCellIdentifier = @"SearchAssociationCell";
    UITableViewCell *blankcell;
    SearchUserCell *u_cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    SearchSpecCell *s_cell = [tableView dequeueReusableCellWithIdentifier:SpecCellIdentifier];
    SearchAssociationCell *a_cell = [tableView dequeueReusableCellWithIdentifier:AssocCellIdentifier];
    u_cell.HeightConstraintAssociation.constant = 17.5;
    u_cell.HeightConstraintSpeciality.constant = 14.5;
    u_cell.HeightConstraintCountry.constant = 14.5;
    if(indexPath.section == 0){
        if(shouldShowSearchResults)
        {
            NSString *spcName = [self.filteredSList objectAtIndex:indexPath.row][@"speciality_name"];
            if([spcName isKindOfClass:[NSNull class]]){
                spcName = @"";
            }
            s_cell.lbl_specName.text = [self parsingHTMLText:spcName];
            s_cell.Img_spec.layer.cornerRadius = s_cell.Img_spec.frame.size.width / 2;
            s_cell.Img_spec.clipsToBounds = YES;
            [s_cell.Img_spec  setImageWithString:[self.filteredSList objectAtIndex:indexPath.row][@"speciality_name"] color:nil circular:YES];
            
        }
        else{
            s_cell.Img_spec.layer.cornerRadius = s_cell.Img_spec.frame.size.width / 2;
            s_cell.Img_spec.clipsToBounds = YES;
            [s_cell.Img_spec  setImageWithString:[specArray objectAtIndex:indexPath.row][@"speciality_name"] color:nil circular:YES];
            
            NSString *spcName =  [specArray objectAtIndex:indexPath.row][@"speciality_name"];
            if([spcName isKindOfClass:[NSNull class]]){
                spcName = @"";
            }
            s_cell.lbl_specName.text = [self parsingHTMLText:spcName];
            
            
        }
        return s_cell;
    }else if(indexPath.section == 1){
        if(shouldShowSearchResults)
        {
            NSString *assoName =  [self.filteredAList objectAtIndex:indexPath.row][@"association_name"];
            if([assoName isKindOfClass:[NSNull class]]){
                assoName = @"";
            }
            a_cell.lbl_assoname.text = [self parsingHTMLText:assoName];
            [a_cell.img_asso sd_setImageWithURL:[NSURL URLWithString:[self.filteredAList objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
            a_cell.lbl_assoCountry.text = [self.filteredAList objectAtIndex:indexPath.row][@"country"];
            a_cell.img_asso.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
            a_cell.img_asso.layer.borderWidth = 0.5;
            a_cell.img_asso.contentMode = UIViewContentModeScaleAspectFill;
            a_cell.img_asso.layer.masksToBounds = YES;
            a_cell.img_asso.layer.cornerRadius = 4.0;
        }
        else{
            NSString *assoName =  [[[assoArray objectAtIndex:indexPath.row][@"association_name"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
            if([assoName isKindOfClass:[NSNull class]]){
                assoName = @"";
            }
            a_cell.lbl_assoname.text = [self parsingHTMLText:assoName];
            [a_cell.img_asso sd_setImageWithURL:[NSURL URLWithString:[assoArray objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
            a_cell.lbl_assoCountry.text = [self parsingHTMLText: [assoArray objectAtIndex:indexPath.row][@"country"]];
            a_cell.img_asso.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
            a_cell.img_asso.layer.borderWidth = 0.5;
            a_cell.img_asso.contentMode = UIViewContentModeScaleAspectFill;
            a_cell.img_asso.layer.masksToBounds = YES;
            a_cell.img_asso.layer.cornerRadius = 4.0;
            
        }
        a_cell.img_asso.contentMode = UIViewContentModeScaleAspectFill;
        a_cell.img_asso.layer.masksToBounds = YES;
        a_cell.img_asso.layer.cornerRadius = 4.0;
        return a_cell;
    } else if(indexPath.section == 2) {
        if(shouldShowSearchResults)
        {
            NSString *ufullname = [NSString stringWithFormat:@"%@",[self.filteredList objectAtIndex:indexPath.row][@"name"]?[self.filteredList objectAtIndex:indexPath.row][@"name"]:@""];
//            u_cell.lbl_fullname.text = [NSString stringWithFormat:@"%@",[self.filteredList objectAtIndex:indexPath.row][@"name"]?[self.filteredList objectAtIndex:indexPath.row][@"name"]:@""];
            u_cell.lbl_fullname.text = [self parsingHTMLText:ufullname];
            [u_cell.img_doc sd_setImageWithURL:[NSURL URLWithString:[self.filteredList objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
            u_cell.lbl_country.text = [self parsingHTMLText:[self.filteredList objectAtIndex:indexPath.row][@"country"]];
            if([[self.filteredList objectAtIndex:indexPath.row][@"country"] isEqualToString:@""]){
                u_cell.HeightConstraintCountry.constant = 0;
            }
            u_cell.lbl_association.text = [self parsingHTMLText:[self.filteredList objectAtIndex:indexPath.row][@"institution_name"]];
            if([[self.filteredList objectAtIndex:indexPath.row][@"institution_name"] isEqualToString:@""]){
                u_cell.HeightConstraintAssociation.constant = 0;
            }
            NSString *spcName = [self.filteredList objectAtIndex:indexPath.row][@"speciality_name"];
            
            if([spcName isKindOfClass:[NSNull class]]){
                spcName = @"";
                u_cell.HeightConstraintSpeciality.constant = 0;
            }
            u_cell.lbl_specialtity.text = [self parsingHTMLText:spcName];
        }
        else{
            NSString *fullname = [NSString stringWithFormat:@"%@",[friendsArray objectAtIndex:indexPath.row][@"name"]?[friendsArray objectAtIndex:indexPath.row][@"name"]:@""];

            u_cell.lbl_fullname.text  = [self parsingHTMLText:fullname];
//            u_cell.lbl_fullname.text = [NSString stringWithFormat:@"%@",[friendsArray objectAtIndex:indexPath.row][@"name"]?[friendsArray objectAtIndex:indexPath.row][@"name"]:@""];
            
            [u_cell.img_doc sd_setImageWithURL:[NSURL URLWithString:[friendsArray objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
            
            u_cell.lbl_country.text =  [self parsingHTMLText:[friendsArray objectAtIndex:indexPath.row][@"country"]];
            
            if([[friendsArray objectAtIndex:indexPath.row][@"country"] isEqualToString:@""]){
                u_cell.HeightConstraintCountry.constant = 0;
            }
            u_cell.lbl_association.text = [self parsingHTMLText: [friendsArray objectAtIndex:indexPath.row][@"institution_name"]];
            
            if([[friendsArray objectAtIndex:indexPath.row][@"institution_name"] isEqualToString:@""]){
                u_cell.HeightConstraintAssociation.constant = 0;
            }
            NSString *spcName =  [friendsArray objectAtIndex:indexPath.row][@"speciality_name"];
            if([spcName isKindOfClass:[NSNull class]]){
                spcName = @"";
                u_cell.HeightConstraintSpeciality.constant = 0;
            }
            u_cell.lbl_specialtity.text = [self parsingHTMLText:spcName];
            
        }
        u_cell.img_doc.contentMode = UIViewContentModeScaleAspectFill;
        u_cell.img_doc.layer.masksToBounds = YES;
        u_cell.img_doc.layer.cornerRadius = 4.0;
        u_cell.img_doc.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
        u_cell.img_doc.layer.borderWidth = 0.5;
        return u_cell;
    }else{
        return blankcell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fullName = @"";
    NSString *loginid = @"";
    NSUInteger chatID = 0;
    QBUUser *User = [QBUUser new];
    if(shouldShowSearchResults){
        switch (indexPath.section) {
            case 0:
                showAsso = NO;
                [self performSegueWithIdentifier:kGoToSingleUserSegueIdentifier sender:self];
                break;
                
            case 1:
                showAsso = YES;
                [self performSegueWithIdentifier:kGoToSingleUserSegueIdentifier sender:self];
                break;
                
            default:
                fullName = [NSString stringWithFormat:@"%@",[self.filteredList objectAtIndex:indexPath.row][@"name"]?[self.filteredList objectAtIndex:indexPath.row][@"name"]:@""];
                NSString *cid = [self.filteredList objectAtIndex:indexPath.row][@"chat_id"];
                selectedFCustid = [NSString stringWithFormat:@"%@",[self.filteredList objectAtIndex:indexPath.row][@"custom_id"]];
                if([cid isKindOfClass:[NSNull class]]){
                    cid = @"0";
                }
                chatID = cid.integerValue;
                loginid = [self.filteredList objectAtIndex:indexPath.row][@"jabber_id"];
                if(chatID == 0){
                    UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    confAl.tag = 888;
                    [confAl show];
                    return;
                  }
                User.ID = chatID;
                User.login = loginid;
                User.fullName = fullName;
                selectedFStatus = [NSString stringWithFormat:@"%@",[self.filteredList objectAtIndex:indexPath.row][@"friend_status"]];
//                [self joinChatWithUser:User];
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
                else{
                    [self joinChatWithUser:User];
                }
                break;
        }
        
    }else{
        
        switch (indexPath.section) {
            case 0:
                showAsso = NO;
                [self performSegueWithIdentifier:kGoToSingleUserSegueIdentifier sender:self];
                break;
                
            case 1:
                showAsso = YES;
                [self performSegueWithIdentifier:kGoToSingleUserSegueIdentifier sender:self];
                break;
                
            default:
                fullName = [NSString stringWithFormat:@"%@",[friendsArray objectAtIndex:indexPath.row][@"name"]];
                NSString *cid = [friendsArray objectAtIndex:indexPath.row][@"chat_id"];
                selectedFCustid = [NSString stringWithFormat:@"%@",[friendsArray objectAtIndex:indexPath.row][@"custom_id"]];
                if([cid isKindOfClass:[NSNull class]]){
                    cid = @"0";
                }
                chatID = cid.integerValue;
                loginid = [friendsArray objectAtIndex:indexPath.row][@"jabber_id"];
                if(chatID == 0){
                    UIAlertView *confAl = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ "QBUserNotExistMsg,fullName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    confAl.tag = 888;
                    [confAl show];
                    return;
                }
                User.ID = chatID;
                User.login = loginid;
                User.fullName = fullName;
                selectedFStatus = [NSString stringWithFormat:@"%@",[friendsArray objectAtIndex:indexPath.row][@"friend_status"]];
//                [self joinChatWithUser:User];
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                if ([u_permissionstus isEqualToString:@"readonly"]) {
                    [self getcheckedUserPermissionData];
                }
                else{
                    [self joinChatWithUser:User];
                }
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (alertView.tag == 888){
        if (buttonIndex == 1) {
            [self didPressoOKforNotifyUpgradeChat];
        }
    }
}


//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"section  = %d , row = %d", indexPath.section, indexPath.row);
//    if(indexPath.row == 8 && indexPath.section == 2){
//        [self getsearchData:nil];
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 28)];
    footerLbl.text =[NSString stringWithFormat:@"%@ \uE312",@"That's All Folks."];
    footerLbl.textColor = [UIColor lightGrayColor];
    footerLbl.font = [UIFont systemFontOfSize:14];
    footerLbl.shadowColor = [UIColor whiteColor];
    footerLbl.shadowOffset = CGSizeMake(0, 1);
    footerLbl.textAlignment = NSTextAlignmentCenter;
    footerLbl.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    footerLbl.opaque = NO;
    return footerLbl;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Searchbar Delegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    shouldShowSearchResults =  YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    shouldShowSearchResults =  NO;
    [UIView animateWithDuration:0.5f animations:^{
        _searchBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.navigationItem.titleView = nil;
        UIBarButtonItem * rightitem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(SearchControllAppear)];
        self.navigationItem.rightBarButtonItem = rightitem;
        [self.navigationItem setHidesBackButton:NO animated:YES];
        _searchButton.alpha = 0.0;  // set this *after* adding it back
        [UIView animateWithDuration:0.5f animations:^ {
            _searchButton.alpha = 1.0;
        }];
    }];
    friendsArray = self.filteredList.copy;
//    NSLog(@"searchBarCancelButtonClicked , friendsArray = %@",friendsArray);
    assoArray = self.filteredAList.copy;
    specArray = self.filteredSList.copy;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!shouldShowSearchResults) {
        shouldShowSearchResults = YES;
        [self.tableView reloadData];
    }
    [self.searchBar resignFirstResponder];
    friendsArray = self.filteredList.copy;
    assoArray = self.filteredAList.copy;
    specArray = self.filteredSList.copy;
}

//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
//    [self updateSearchResultsForSearchController:self.searchController];
//}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
   if(searchText.length == 0){
        return;
    }
    //    if(backbuttonPress){
    //
    //    }else{
    ////        NSLog(@"text = %@, Whole string= %@",searchText,searchBar.text);
    ////        NSLog(@"backspace Not tapped");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getsearchData:) object:nil];
    
    NSString *trimmedString = [searchText stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqualToString:@""]) {
    }
    else{
        if(![searchText isEqualToString:@""]){
            [self performSelector:@selector(getsearchData:) withObject:nil afterDelay:1.0];
        }
    }
}


//-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if (range.length==1 && text.length==0)
//    {
//        backbuttonPress = YES;
//    }else{
//        backbuttonPress = NO;
//    }
//    return YES;
//}

//- (void)filterContentForSearchText:(NSString*)searchText
//{
//    NSString *searchString = searchText;
//    self.filteredList = nil;
//    NSString *predicateFormat = @"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@";
//    NSString *searchFNameAttribute = @"Name";
//    NSString *searchLNameAttribute = @"Name";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchString];
//    self.filteredList = [friendsArray filteredArrayUsingPredicate:predicate];
//    [self.tableView reloadData];
//
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
//    searchResults = [recipes filteredArrayUsingPredicate:resultPredicate];
//}

//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
//{
//   // [self.tableView reloadData];
//}


//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
//{
//    NSString *searchString = searchController.searchBar.text;
//    self.filteredList = nil;
//    NSString *predicateFormat = @"%K CONTAINS[cd] %@";
//    NSString *searchAttribute = @"Name";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchString];
//    self.filteredList = [friendsArray filteredArrayUsingPredicate:predicate];
//    [self.tableView reloadData];
//}

#pragma mark - get search list api calling
-(void)getsearchData:(NSString*)searchTxt{
   // NSLog(@"getsearchData - %@ withpagecount = %d",searchTxt,pageCount);
    searchTxt = self.searchBar.text;
    if(![lastSearch isEqualToString:searchTxt]){
        pageCount = 1;
        [self.tableView setShowsPullToRefresh:YES];
    }
    lastSearch = searchTxt;
    if([dataDic valueForKey:searchTxt] && pageCount == 1){
       // NSLog(@"Data got for key %@ = %@",searchTxt,[dataDic valueForKey:searchTxt]);
        [self dataForTableReload:[dataDic valueForKey:searchTxt]];
    }
    else {
        if([searchTxt isEqualToString:@""]){
            [self.tableView setShowsPullToRefresh:NO];
            return;
        }
        self.tableView.tableFooterView = pageCount == 1?self.spinner:nil;
      //  NSLog(@"getsearchData enter for text = %@ with page count = %d",searchTxt,pageCount);
        NSUserDefaults *userDef =[NSUserDefaults standardUserDefaults];
        [[DocquityServerEngine sharedInstance]searchcheckingAPI:[userDef valueForKey:userAuthKey] offset:[NSString stringWithFormat:@"%d",pageCount] device_type:kDeviceType app_version:[userDef valueForKey:kAppVersion] lang:kLanguage keyword:searchTxt callback:^(NSMutableDictionary *responseObject, NSError *error) {
            [self.tableView.pullToRefreshView stopAnimating];
            
            NSMutableDictionary *responseDic =[responseObject objectForKey:@"posts"];
        //    NSLog(@"Response for %@ withpage = %d  %@",searchTxt,pageCount,responseDic);
            
            if ([responseDic isKindOfClass:[NSNull class]]|| responseDic ==nil)
            {
           //     NSLog(@"%@ Response for %@",searchTxt,responseDic);
            }
            else
            {
                pageCount == 1?[dataDic setObject:responseDic forKey:searchTxt]:nil;
                if([[responseDic valueForKey:@"status"]integerValue] == 1){
                    NSArray *userListArr = [responseDic objectForKey:@"user_list"];
                    NSArray *specListArr = [responseDic objectForKey:@"speciality_list"];
                    NSArray *assoListArr = [responseDic objectForKey:@"association_list"];
                    
                    if(pageCount == 1){
                        _filteredList = [NSArray new];
                        _filteredSList = [NSArray new];
                        _filteredAList = [NSArray new];
                    }
                    
                    if([assoListArr isKindOfClass:[NSArray class]] && assoListArr.count > 0){
                        if(shouldShowSearchResults){
                            _filteredAList = [_filteredAList arrayByAddingObjectsFromArray:assoListArr];
                        }else{
                            assoArray = [assoArray arrayByAddingObjectsFromArray:assoListArr];
                        }
                    }
                    
                    if([specListArr isKindOfClass:[NSArray class]] && specListArr.count > 0){
                        if(shouldShowSearchResults){
                            _filteredSList = [_filteredSList arrayByAddingObjectsFromArray:specListArr];
                        }else{
                            specArray = [specArray arrayByAddingObjectsFromArray:specListArr];
                        }
                    }
                    
                    if([userListArr isKindOfClass:[NSArray class]] && userListArr.count > 0){
                        if(shouldShowSearchResults){
                            _filteredList = [_filteredList arrayByAddingObjectsFromArray:userListArr];
                            _filteredList.count>=10?[self.tableView setShowsPullToRefresh:YES]:[self.tableView setShowsPullToRefresh:NO];
                        }else{
                            friendsArray = [friendsArray arrayByAddingObjectsFromArray:userListArr];
                            friendsArray.count>=10?[self.tableView setShowsPullToRefresh:YES]:[self.tableView setShowsPullToRefresh:NO];
                        }
                    }
                    
                    self.tableView.tableFooterView = nil;
                    [self.tableView reloadData];
                    pageCount ++;
                }
                else if([[responseDic valueForKey:@"status"]integerValue] == 7){
                    [self.tableView setShowsPullToRefresh:NO];
                    self.tableView.tableFooterView = nil;
//                    self.tableView.tableFooterView = [self tableView:self.tableView viewForFooterInSection:0];
                }
                else if([[responseDic valueForKey:@"status"]integerValue] == 5)
                {
                    [[AppDelegate appDelegate]ShowPopupScreen];
                }
                else if([[responseDic valueForKey:@"status"]integerValue] == 9){
                    [[AppDelegate appDelegate] hideIndicator];
                    [[AppDelegate appDelegate] logOut];
                }
                else  if([[responseDic  valueForKey:@"status"]integerValue] == 11)
                {
                    NSString*userValidateCheck = @"readonly";
                    NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                    [userpref setObject:userValidateCheck?userValidateCheck:@"" forKey:user_permission];//mandatory
                    [userpref synchronize];;
                    NSString *u_permissionstus = [userpref objectForKey:user_permission]; //mandatory
                    if ([u_permissionstus isEqualToString:@"readonly"]) {
                        [self getcheckedUserPermissionData];
                    }
                }

            }
        }];
    }
}


-(void)dataForTableReload:(NSMutableDictionary *)dic{
    
    if([[dic valueForKey:@"status"]integerValue] == 1){
        
        NSArray *userListArr = [dic objectForKey:@"user_list"];
        NSArray *specListArr = [dic objectForKey:@"speciality_list"];
        NSArray *assoListArr = [dic objectForKey:@"association_list"];
        
        if(pageCount == 1){
            _filteredList = [NSArray new];
            _filteredSList = [NSArray new];
            _filteredAList = [NSArray new];
        }
        if([assoListArr isKindOfClass:[NSArray class]] && assoListArr.count > 0){
            if(shouldShowSearchResults){
                _filteredAList = [_filteredAList arrayByAddingObjectsFromArray:assoListArr];
            }else{
                assoArray = [assoArray arrayByAddingObjectsFromArray:assoListArr];
            }
        }
        if([specListArr isKindOfClass:[NSArray class]] && specListArr.count > 0){
            if(shouldShowSearchResults){
                _filteredSList = [_filteredSList arrayByAddingObjectsFromArray:specListArr];
            }else{
                specArray = [specArray arrayByAddingObjectsFromArray:specListArr];
            }
        }
        
        if([userListArr isKindOfClass:[NSArray class]] && userListArr.count > 0){
            if(shouldShowSearchResults){
                _filteredList = [_filteredList arrayByAddingObjectsFromArray:userListArr];
            }else{
                friendsArray = [friendsArray arrayByAddingObjectsFromArray:userListArr];
            }
        }
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
        pageCount ++;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    if(shouldShowSearchResults)
    friendsArray = self.filteredList.copy;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* viewController = segue.destinationViewController;
        viewController.dialog = sender;
        viewController.friendStatus = selectedFStatus;
        viewController.oppCustid = selectedFCustid;
    }else if([segue.identifier isEqualToString:kGoToShowAllAssoSegueIdentifier]){
        SearchAllSpecAssoVC* viewController = segue.destinationViewController;
        if(showAsso) {
            viewController.FinalArray = self.filteredAList;
            viewController.dataFor = @"asso";
            viewController.keyword = self.searchBar.text;
        }
        else {
            viewController.FinalArray = self.filteredSList;
            viewController.dataFor = @"spec";
            viewController.keyword = self.searchBar.text;
        }
    }else if([segue.identifier isEqualToString:kGoToSingleUserSegueIdentifier]){
        UserSearchViewController* viewController = segue.destinationViewController;
        viewController.hidesBottomBarWhenPushed =YES;
        if(showAsso) {
            
            viewController.type = @"association";
            viewController.typeID = [self.filteredAList objectAtIndex:0][@"association_id"];
            viewController.keyword = [self.filteredAList objectAtIndex:0][@"association_name"];
        }
        else {
            viewController.type = @"speciality";
            viewController.typeID = [self.filteredSList objectAtIndex:0][@"speciality_id"];
            viewController.keyword = [self.filteredSList objectAtIndex:0][@"speciality_name"];
        }
    }
}

- (void)navigateToChatViewControllerWithDialog:(QBChatDialog *)dialog {
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

-(void)joinChatWithUser:(QBUUser*)user {
    __weak __typeof(self) weakSelf = self;
    [self createChatWithName:nil selectedUser:user completion:^(QBChatDialog *dialog) {
        __typeof(self) strongSelf = weakSelf;
        if( dialog != nil ) {
            [strongSelf navigateToChatViewControllerWithDialog:dialog];
        }
        else {
           // [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
        }
    }];
}

- (void)createChatWithName:(NSString *)name selectedUser:(QBUUser*)user completion:(void(^)(QBChatDialog *dialog))completion {
    
    // Creating private chat dialog.
    [ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:user completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        if (!response.success && createdDialog == nil) {
            if (completion) {
                completion(nil);
            }
        }
        else {
            if (completion) {
                completion(createdDialog);
            }
        }
    }];
}


-(void)didPressMore:(UIButton*)sender{
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    if(sender.tag == 0){
        showAsso = NO;
 //       NSLog(@"Specialization clicked");
    }else if(sender.tag == 1){
        showAsso = YES;
   //     NSLog(@"Associtation clicked");
    }
    [self performSegueWithIdentifier:kGoToShowAllAssoSegueIdentifier sender:self];
}


- (IBAction)didPressChatBtn:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (IBAction)didPressViewProfile:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if(shouldShowSearchResults){
        [self viewProfileWithCustId:[self.filteredList objectAtIndex:indexPath.row][@"custom_id"] UserJabberId:[self.filteredList objectAtIndex:indexPath.row][@"jabber_id"]];
        
    }else{
        [self viewProfileWithCustId:[friendsArray objectAtIndex:indexPath.row][@"custom_id"] UserJabberId:[friendsArray objectAtIndex:indexPath.row][@"jabber_id"]];
    }
  }

-(void)viewProfileWithCustId:(NSString *)custid UserJabberId:(NSString *)userJabId{
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
    NewProfile .custid=  custid;
    [AppDelegate appDelegate].isComeFromSettingVC = YES;
    NewProfile.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:NewProfile animated:YES];
}

-(void)didPressoOKforNotifyUpgradeChat{
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetNotify_to_upgrade_for_chatWithAuthKey:[userdef objectForKey:userAuthKey] custom_id:selectedFCustid device_type:kDeviceType app_version:[userdef objectForKey:kAppVersion] lang:kLanguage callback:^(NSDictionary *responceObject, NSError *error) {
        NSDictionary *resposeCode =[responceObject objectForKey:@"posts"];
        if ([resposeCode isKindOfClass:[NSNull class]]|| resposeCode == nil)
        {
            // tel is null
        }
        else {
            if([[resposeCode valueForKey:@"status"]integerValue] == 1){
                }
            }
    }];
}

#pragma mark - checkPermission API Calling for readOnly
-(void)getcheckedUserPermissionData{
    NSUserDefaults *userdef=[NSUserDefaults standardUserDefaults];//mandatory
    [[DocquityServerEngine sharedInstance]check_user_permissionRequest:[userdef objectForKey:userAuthKey] callback:^(NSDictionary* responceObject, NSError* error) {
        //NSLog(@"responceObject = %@",responceObject);
        NSDictionary *postDic =[responceObject objectForKey:@"posts"];
        if ([postDic isKindOfClass:[NSNull class]] || postDic == nil)
        {
            //tel is null
        }
        else {
            NSString * stusmsg =[NSString stringWithFormat:@"%@",[postDic objectForKey:@"msg"]?[postDic objectForKey:@"msg"]:@""];
            NSString * ICNumber;
            NSString * Identity;
            NSString *InviteCodeExample;
            NSString * InviteCodeTyp;
            NSString * IdentityMsg;
            NSDictionary *dataDict=[postDic objectForKey:@"data"];
            if ([dataDict isKindOfClass:[NSNull class]]||dataDict == nil)
            {
                // tel is null
            }
            else {
                permstus = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"permission"]?[dataDict objectForKey:@"permission"]:@""];
                NSDictionary *reqDic=[dataDict objectForKey:@"requirement"];
                if ([reqDic isKindOfClass:[NSNull class]]|| reqDic ==nil)
                {
                    // tel is null
                }
                else {
                    ICNumber =[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"ic_number"]?[reqDic objectForKey:@"ic_number"]:@""];
                    
                    Identity=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity"]?[reqDic objectForKey:@"identity"]:@""];
                    
                    IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    if ([IdentityMsg  isEqualToString:@""] || [IdentityMsg isEqualToString:@"<null>"]) {
                    }
                    else {
                        IdentityMsg=[NSString stringWithFormat:@"%@",[reqDic objectForKey:@"identity_message"]?[reqDic objectForKey:@"identity_message"]:@""];
                    }
                    NSDictionary *IC_reqDic=[reqDic objectForKey:@"ic_requirement"];
                    if ([IC_reqDic isKindOfClass:[NSNull class]]||IC_reqDic ==nil)
                    {
                        // tel is null
                    }
                    else {
                        InviteCodeExample =[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_example"]?[IC_reqDic objectForKey:@"invite_code_example"]:@""];
                        InviteCodeTyp=[NSString stringWithFormat:@"%@",[IC_reqDic objectForKey:@"invite_code_type"]?[IC_reqDic objectForKey:@"invite_code_type"]:@""];
                    }
                }
            }
            if([[postDic valueForKey:@"status"]integerValue] == 1){
                NSUserDefaults *userpref=[NSUserDefaults standardUserDefaults];
                [userpref setObject:permstus?permstus:@"" forKey:user_permission];//mandatory
                [userpref synchronize];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 9){
                [[AppDelegate appDelegate] logOut];
            }
            else if([[postDic valueForKey:@"status"]integerValue] == 11){
                [self pushToVerifyAccount:stusmsg invite_codeType:InviteCodeTyp invite_code_example:InviteCodeExample ic_number:ICNumber identity:Identity identity_message:IdentityMsg];
            }
            else{
                //  [UIAppDelegate alerMassegeWithError: stusmsg withButtonTitle:@"OK" autoDismissFlag:NO];
            }
        }
    }];
}

-(void)pushToVerifyAccount:(NSString*)stusmsg invite_codeType:(NSString*)InviteCodeTyp invite_code_example:(NSString*)InviteCodeExample ic_number:(NSString*)ICNumber identity:(NSString*)Identity identity_message:(NSString*)IdentityMsg{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    PermissionCheckYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"PermissionCheckYourSelfVC"];
    selfVerify.titleMsg = stusmsg;
    selfVerify.titledesc = InviteCodeTyp;
    selfVerify.tf_placeholder = InviteCodeExample;
    selfVerify.IcnumberValue = ICNumber;
    selfVerify.idetityValue = Identity;
    selfVerify.identityTypMsg = IdentityMsg;
    [self.navigationController presentViewController:selfVerify animated:NO completion:nil];
}

-(NSString*)parsingHTMLText:(NSString*)text{
   text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}

@end
