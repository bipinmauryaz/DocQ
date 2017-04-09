//
//  NewAssociationCollectionViewCell.h
//  Docquity
//
//  Created by Docquity-iOS on 01/03/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAssociationCollectionViewCell : UICollectionViewCell

@property(weak,nonatomic)IBOutlet UIImageView *imageLogo;
@property(weak,nonatomic)IBOutlet UILabel *lbl_assoName;
@property(weak,nonatomic)IBOutlet UIImageView *imageSelection;

@end
