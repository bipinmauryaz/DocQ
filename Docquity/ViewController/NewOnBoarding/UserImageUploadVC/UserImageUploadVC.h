//
//  UserImageUploadVC.h
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewUploadVC.h"

@interface UserImageUploadVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSString *u_ImgType;
    NSString *base64EncodedString;
    NSString *mediaPath;
    NSMutableString *dataPath;
    NSInteger statusResponse;
    NSString *imgUrl;
    NSUserDefaults *userdef;
}
@property(weak, nonatomic)NSString*registeredUserType;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property(weak,nonatomic)IBOutlet UIImageView *imageViewUserImage;
@end
