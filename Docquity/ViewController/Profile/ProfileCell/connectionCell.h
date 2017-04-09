//
//  connectionCell.h
//  Docquity
//
//  Created by Docquity-iOS on 05/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface connectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_total_connection;
@property (weak, nonatomic) IBOutlet UILabel *lbl_total_cme;
@property (weak, nonatomic) IBOutlet UILabel *lbl_connection_static;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CmeStatic;

@end
