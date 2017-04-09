//
//  NewAssoicationVC.m
//  Docquity
//
//  Created by Docquity-iOS on 01/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "NewAssoicationVC.h"
#import "NewUserMobileVC.h"
#import "CodeClaimVC.h"
#import "NewUserDetailsVC.h"

@interface NewAssoicationVC ()

@end

@implementation NewAssoicationVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithHeaderLogoImageAndBarButtonItems:@"Select Your Associations"];
    _selectedCell = [NSMutableArray array];
    _arrayAssociationId = [NSMutableArray array];
    [self ServiceHitForGetAssociationListByCountry];
   // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
     [Localytics tagEvent:@"OnboardingSelectAssociationScreen Visit"];
    [self callingGoogleAnalyticFunctionWithOutTrackerId:@"OnboardingSelectAssociationScreen" screenAction:@"OnboardingSelectAssociationScreen Visit"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getAssociationListByCountry
-(void)ServiceHitForGetAssociationListByCountry{
    [WebServiceCall showHUD];
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@association/get?rquest=association_list_by_country&version=%@&registered_user_type=%@&country_id=%@&iso_code=&lang=%@",NewWebUrl,kApiVersion,_registered_userType,_Id_country,kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
        if (response) {
            [SVProgressHUD dismiss];
         //   NSLog(@"%@",response);
            NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
            if ([[responseDict valueForKeyPath:@"posts.msg"] isEqualToString:@"Success."] && [[responseDict valueForKeyPath:@"posts.status"] integerValue]== 1 && ![[responseDict valueForKeyPath:@"posts.data.association_list"] isKindOfClass:[NSNull class]]) {
                _arrayAssociation = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.association_list"]];
                [associationCollection reloadData];
            }
             else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 0)
            {
                [WebServiceCall showAlert:AppName andMessage:[responseDict valueForKeyPath:@"posts.msg"] withController:self];
            }
            else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
}
        else if (error){
            [SVProgressHUD dismiss];
            NSLog(@"%@",error);
        }
    }];
}

#pragma mark UIButton Actions
-(IBAction)btnNextClicked:(id)sender{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"newOnBoarding" bundle:nil];
    if ([btnNext.titleLabel.text isEqualToString:@"SKIP"]) {
        // is not linked to an account. Click to complete your registration process.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppName message:@"You have not selected any Medical Association." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:kCountinueMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NewUserMobileVC *newMobile = [storyboard instantiateViewControllerWithIdentifier:@"NewUserMobileVC"];
            newMobile.countryCode = _asso_countryCode;
            newMobile.strCountryCode  = [NSString stringWithFormat:@"+%@",_asso_countryCode];
            newMobile.registered_userType = _registered_userType;
            newMobile.assoIdArr = _arrayAssociationId.mutableCopy;
            newMobile.associationDic = dict;
            [self.navigationController pushViewController:newMobile animated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        NewUserMobileVC *newMobile = [storyboard instantiateViewControllerWithIdentifier:@"NewUserMobileVC"];
        newMobile.countryCode = _asso_countryCode;
        newMobile.strCountryCode  = [NSString stringWithFormat:@"+%@",_asso_countryCode];
        newMobile.registered_userType = _registered_userType;
        newMobile.assoIdArr = _arrayAssociationId.mutableCopy;
        newMobile.associationDic = dict;
        [self.navigationController pushViewController:newMobile animated:YES];
    }
}

#pragma mark - UICollectionView Delegates and DataSource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"newAssocaitionCell";
    NewAssociationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.layer.borderWidth = 1.0f;
    NSNumber *num = [NSNumber numberWithInteger:indexPath.row];
    if ([_selectedCell containsObject:num])
    {
        cell.imageSelection.image = [UIImage imageNamed:@"checkbox_active_green"];
        cell.layer.borderColor = [UIColor colorWithRed:43.0/255.0 green:181.0/255.0 blue:115.0/255.0 alpha:1.0].CGColor;
        }
    else
    {
        cell.imageSelection.image = [UIImage imageNamed:@"checkbox_nonactive"];
        cell.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor;
    }
    cell.lbl_assoName.text = [[_arrayAssociation objectAtIndex:indexPath.row][@"association_abbreviation"]stringByDecodingHTMLEntities];
    [cell.imageLogo sd_setImageWithURL:[NSURL URLWithString:[_arrayAssociation objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"globe.png"] options:SDWebImageRefreshCached];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *cellSelected = [NSNumber numberWithInteger:indexPath.row];
   // cellSelected = [_arrayAssociation objectAtIndex:indexPath.row][@"association_id"];
    if (indexPath.section ==0) {
        if(indexPath.row<[_arrayAssociation count]){
            dict = [_arrayAssociation  objectAtIndex: indexPath.row];
            associationId  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"association_id"]];
            cardImgUrl = [NSString stringWithFormat:@"%@", [dict valueForKey:@"file_url"]];
            inviteExample  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"invite_code_example"]];
            invideCodeType  = [NSString stringWithFormat:@"%@", [dict valueForKey:@"invite_code_type"]];
        }
    }
    if ([_selectedCell containsObject:cellSelected]) {
        [_arrayAssociationId removeObject:associationId];
        [_selectedCell removeObject:cellSelected];
    }
    else
    {
    [_arrayAssociationId addObject:associationId];
    [_selectedCell addObject:cellSelected];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayAssociationId forKey:@"AssociationIdArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [associationCollection reloadData];
    if (_selectedCell.count) {
     [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    }
    else
    [btnNext setTitle:@"SKIP" forState:UIControlStateNormal];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayAssociation.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
