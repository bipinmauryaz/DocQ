//
//  SettingVC.h
//  Docquity
//
//  Created by Arimardan Singh on 19/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingVC : UIViewController<UIGestureRecognizerDelegate>
{
    IBOutlet UIView*reportIssueView;
    IBOutlet UIView*profileView;
    IBOutlet UIView*notify_View;
    IBOutlet UIView*report_View;
    IBOutlet UIView*language_View;
    IBOutlet UIView*selectLanguage_View;
    IBOutlet UIView*earnPoints_View;
    IBOutlet UIView*referel_View;
    IBOutlet UIView*pointsView;
    IBOutlet UIView*referelView;
    IBOutlet UILabel*lbl_uName;
    IBOutlet UIImageView*userPImage;
    IBOutlet UILabel*lbl_sound;
    IBOutlet UIImageView*soundImage;
    NSMutableString *dataPath;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lbls;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *cachingSwitch;

- (IBAction)soundSwitchValChanged:(UISwitch *)sender;
- (IBAction)cachingSwitchValChanged:(UISwitch *)sender;

@property (strong, nonatomic) IBOutlet UITableView *languageListTableView;

@end
