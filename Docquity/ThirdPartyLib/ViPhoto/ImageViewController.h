/*============================================================================
 PROJECT: Docquity
 FILE:    ImageViewController.h
 AUTHOR:  Copyright © 2015 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/09/15.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UIActionSheetDelegate>{
    UIImageView *imageshow;
    UIScrollView *Img_scroll;
    UIImage *img;
    BOOL isPort;
}
@property (nonatomic, strong)NSString *imgBase64;
@property (nonatomic, strong)NSString *titlebarText;
@end
