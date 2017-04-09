//
//  iImagePickerController.h
//  iimagePickerContoller
//
//  Created by Rajesh on 9/11/15.
//  Copyright (c) 2015 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newFeedPostViewController.h"

@interface iImagePickerController : UIViewController

@property(nonatomic, weak) newFeedPostViewController *viewController;
@property (nonatomic,assign)id delegate;
@property (nonatomic)NSInteger maximumImageClick;
@end


@protocol revertImage <NSObject>
-(void)imagesPickingFinish:(NSMutableArray*)array;
@end
