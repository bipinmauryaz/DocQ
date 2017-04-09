//
//  NewAssoicationVC.h
//  Docquity
//
//  Created by Docquity-iOS on 01/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewAssociationCollectionViewCell.h"

@interface NewAssoicationVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
{
    IBOutlet UIButton *btnNext;
    IBOutlet UICollectionView *associationCollection;
    BOOL isAssociationSelected;
    NSString*cardImgUrl;
    NSString*inviteExample;
    NSString*invideCodeType;
    NSString*associationId;
    NSDictionary *dict;
 }

@property(strong,nonatomic)NSMutableArray *arrayAssociationId;
@property(strong,nonatomic)NSMutableArray *arrayAssociation;
@property(strong,nonatomic)NSMutableArray *selectedCell;
@property (nonatomic,strong) NSString *registered_userType;
@property (nonatomic,strong) NSString *Id_country;
@property (nonatomic,strong) NSString *asso_countryCode;
@end
