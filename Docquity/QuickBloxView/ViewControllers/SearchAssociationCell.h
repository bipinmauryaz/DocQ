//
//  SearchAssociationCell.h
//  Docquity
//
//  Created by Docquity-iOS on 14/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAssociationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_asso;
@property (weak, nonatomic) IBOutlet UILabel *lbl_assoname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_assoCountry;

@end
