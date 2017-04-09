//
//  SettingVC.h
//  Docquity
//
//  Created by Arimardan Singh on 19/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingVC : UIViewController<UIGestureRecognizerDelegate>{
    IBOutlet UIView*reportIssueView;
    IBOutlet UIView*profileView;
    IBOutlet UIView*notify_View;
    IBOutlet UIView*report_View;
    IBOutlet UILabel*lbl_uName;
    IBOutlet UIImageView*userPImage;
    IBOutlet UILabel*lbl_sound;
    IBOutlet UIImageView*soundImage;
    NSString *mediaPath;
    NSMutableString *dataPath;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lbls;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *cachingSwitch;

- (IBAction)soundSwitchValChanged:(UISwitch *)sender;
- (IBAction)cachingSwitchValChanged:(UISwitch *)sender;

@end
