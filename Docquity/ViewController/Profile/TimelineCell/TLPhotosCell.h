//
//  TLPhotosCell.h
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLPhotosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img1_v1;
@property (weak, nonatomic) IBOutlet UIImageView *img1_v2;
@property (weak, nonatomic) IBOutlet UIImageView *img2_v2;

@property (weak, nonatomic) IBOutlet UIImageView *img1_v3;
@property (weak, nonatomic) IBOutlet UIImageView *img2_v3;
@property (weak, nonatomic) IBOutlet UIImageView *img3_v3;

@property (weak, nonatomic) IBOutlet UIImageView *img1_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img2_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img3_v4;
@property (weak, nonatomic) IBOutlet UIImageView *img4_v4;

@property (weak, nonatomic) IBOutlet UIImageView *img1_v5;
@property (weak, nonatomic) IBOutlet UIImageView *img2_v5;
@property (weak, nonatomic) IBOutlet UIImageView *img3_v5;
@property (weak, nonatomic) IBOutlet UIImageView *img4_v5;
@property (weak, nonatomic) IBOutlet UIImageView *img5_v5;

-(void)configureUserInfoWithData:(NSMutableArray*)data;

@property (weak, nonatomic) IBOutlet UIView *view_1imgholder;
@property (weak, nonatomic) IBOutlet UIView *view_2imgholder;
@property (weak, nonatomic) IBOutlet UIView *view_3imgholder;
@property (weak, nonatomic) IBOutlet UIView *view_4imgholder;
@property (weak, nonatomic) IBOutlet UIView *view_5imgholder;

@property (nonatomic,assign)id delegate;
@end

@protocol TLPhotoCellDelegate <NSObject>
-(void)imgviewTapped:(UIImageView*)sender;
@end

