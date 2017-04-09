//
//  SummaryViewC.h
//  Docquity
//
//  Created by Arimardan Singh on 15/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileData.h"

@interface SummaryViewC : UIViewController<UITextViewDelegate,UIGestureRecognizerDelegate>{
    IBOutlet UILabel *placeholderLabel;
    IBOutlet UITextView *txtvw_summary;
    IBOutlet UILabel *headerLabel;
    BOOL isback;
}

@property (strong, nonatomic)IBOutlet UITextView *txtvw_summary;
@property(strong,nonatomic)NSString*summary;
@property(nonatomic,strong)IBOutlet UILabel *placeholderLabel;
@property (strong, nonatomic)IBOutlet UIToolbar *keybAccessory;
@property(nonatomic,strong) UIToolbar *myToolbar;
@property (nonatomic,assign)id delegate;
@property(nonatomic,strong) ProfileData *data;

#pragma mark -button action
-(IBAction)goBack:(id)sender;
-(IBAction)saveBtn:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end


@protocol SummaryViewC <NSObject>
-(void)EditProfileViewCallWithCustomid:(NSString*)custom_id update_summary:(NSString *)update_summary;

@end

