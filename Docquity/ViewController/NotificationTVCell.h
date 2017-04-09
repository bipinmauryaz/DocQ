//
//  NotificationTVCell.h
//  Docquity
//
//  Created by Arimardan Singh on 12/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTVCell : UITableViewCell
@property(nonatomic, weak)IBOutlet UIImageView*userImg;
@property(nonatomic, weak)IBOutlet UILabel*lbl_notifydetail;
@property(nonatomic, weak)IBOutlet UILabel*lbl_time;

- (void)setInfo:(NSDictionary*)notifyInfo;

@end
