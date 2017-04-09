/*============================================================================
 PROJECT: Docquity
 FILE:    EditProfileVC.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 30/04/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>
#import "ProfileData.h"
@protocol PImageUpdate <NSObject>

-(void)PicimageUpdate;

@end

/*============================================================================
 Interface: EditProfileVC
 =============================================================================*/
@interface EditProfileVC : UIViewController<UITextViewDelegate,UIScrollViewDelegate>{
    NSMutableString *dataPath;
    NSString*summary;
    NSUserDefaults *userdef;
}
@property(nonatomic,assign)id delegate;
@property(nonatomic,strong) ProfileData *data;
@end

@protocol EditProfileVC <NSObject>
-(void)ProfileViewCallWithCustomid:(NSString*)custom_id update_summary:(NSString *)update_summary;

-(void)ProfileViewCallWithCustomid:(NSString*)custom_id update_firstName:(NSString*)update_firstName update_lastName:(NSString *)update_lastName update_email:(NSString *)update_email update_city:(NSString*)update_city update_country:(NSString *)update_country update_state:(NSString *)update_state;
@end
