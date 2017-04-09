//
//  SearchUserCell.h
//  Docquity
//
//  Created by Docquity-iOS on 13/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_doc;
@property (weak, nonatomic) IBOutlet UILabel *lbl_fullname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_association;
@property (weak, nonatomic) IBOutlet UILabel *lbl_specialtity;
@property (weak, nonatomic) IBOutlet UILabel *lbl_country;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintAssociation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintSpeciality;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightConstraintCountry;

@end
