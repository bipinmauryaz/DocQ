//
//  CountryCellTableViewCell.h
//  Docquity
//
//  Created by Docquity-iOS on 24/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryCellTableViewCell : UITableViewCell
@property(weak,nonatomic) IBOutlet UILabel *lblCountryName;
@property(weak,nonatomic) IBOutlet UILabel *lblCountryCode;
@property(weak,nonatomic) IBOutlet UIImageView *imageCountryFlag;

@end
