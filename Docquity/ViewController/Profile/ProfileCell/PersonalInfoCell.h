//
//  PersonalInfoCell.h
//  Docquity
//
//  Created by Docquity-iOS on 24/11/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_contact;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Contact;
@property (weak, nonatomic) IBOutlet UILabel *lbl_contactInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_email;
@property (weak, nonatomic) IBOutlet UIImageView *img_email;
@property (weak, nonatomic) IBOutlet UILabel *lbl_emailInfo;

@end
