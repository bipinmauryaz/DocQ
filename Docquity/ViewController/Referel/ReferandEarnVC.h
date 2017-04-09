//
//  ReferandEarnVC.h

//  Docquity
//
//  Created by Arimardan Singh on 06/04/17.
//  Copyright © 2017 Docquity. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ReferandEarnVC : UIViewController
{
    NSString*referlink;
    NSString*referlMsg;
    NSString*referlTc;
    NSString*user_totalPoints;
    IBOutlet UILabel*lbl_msgreferel;
    UIBarButtonItem *pointsButton;
}
@end
