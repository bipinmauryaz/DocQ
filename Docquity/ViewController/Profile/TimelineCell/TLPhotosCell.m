//
//  TLPhotosCell.m
//  Docquity
//
//  Created by Docquity-iOS on 31/01/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "TLPhotosCell.h"
#import "UIImageView+WebCache.h"
#import "DefineAndConstants.h"
@implementation TLPhotosCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)configureUserInfoWithData:(NSMutableArray*)imageArray {
    [self hideAllTheImageHolder];
    switch (imageArray.count) {
        case 1:
            [self setupSingleImageView:imageArray];
            break;
        case 2:
            [self setupDoubleImageView:imageArray];
            break;
        case 3:
            [self setupThreeImageView:imageArray];
            break;
        case 4:
            [self setupFourImageView:imageArray];
            break;
        default:
            [self setupMoreImageView:imageArray];
            break;
    }
}


-(void)setupSingleImageView:(NSMutableArray*)data{
    self.view_1imgholder.hidden = false;
    [self setupImageViewHolder:self.view_1imgholder];
    [self.img1_v1 sd_setImageWithURL:[data objectAtIndex:0][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    
    
}

-(void)setupDoubleImageView:(NSMutableArray*)data{

    self.view_2imgholder.hidden = false;
    [self setupImageViewHolder:self.view_2imgholder];
    [self.img1_v2 sd_setImageWithURL:[data objectAtIndex:0][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img2_v2 sd_setImageWithURL:[data objectAtIndex:1][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
}

-(void)setupThreeImageView:(NSMutableArray*)data{

    self.view_3imgholder.hidden = false;
    [self setupImageViewHolder:self.view_3imgholder];
    [self.img1_v3 sd_setImageWithURL:[data objectAtIndex:0][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img2_v3 sd_setImageWithURL:[data objectAtIndex:1][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img3_v3 sd_setImageWithURL:[data objectAtIndex:2][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
}

-(void)setupFourImageView:(NSMutableArray*)data{
    
    self.view_4imgholder.hidden = false;
    [self setupImageViewHolder:self.view_4imgholder];
    [self.img1_v4 sd_setImageWithURL:[data objectAtIndex:0][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img2_v4 sd_setImageWithURL:[data objectAtIndex:1][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img3_v4 sd_setImageWithURL:[data objectAtIndex:2][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img4_v4 sd_setImageWithURL:[data objectAtIndex:3][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
}

-(void)setupMoreImageView:(NSMutableArray*)data{
    
    self.view_5imgholder.hidden = false;
    [self setupImageViewHolder:self.view_5imgholder];
    [self.img1_v5 sd_setImageWithURL:[data objectAtIndex:0][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img2_v5 sd_setImageWithURL:[data objectAtIndex:1][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img3_v5 sd_setImageWithURL:[data objectAtIndex:2][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img4_v5 sd_setImageWithURL:[data objectAtIndex:3][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
    [self.img5_v5 sd_setImageWithURL:[data objectAtIndex:4][@"file_url"] placeholderImage:kfeedImgPlaceholder options:SDWebImageRefreshCached];
}

-(void)hideAllTheImageHolder{
    self.view_1imgholder.hidden = true;
    self.view_2imgholder.hidden = true;
    self.view_3imgholder.hidden = true;
    self.view_4imgholder.hidden = true;
    self.view_5imgholder.hidden = true;
}

-(void)setupImageViewHolder:(UIView*)imageViewHolder {
    for(UIView *subview in imageViewHolder.subviews){
        if([subview isKindOfClass:[UIImageView class]]){
            [self setupImageView:(UIImageView*)subview];
        }
    }
}
-(void)setupImageView:(UIImageView*)imageView {
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = true;
    imageView.layer.borderColor = kBorderLayerColor ;
    imageView.layer.borderWidth = 0.7f;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [imageView addGestureRecognizer:tap];
}


-(void)tapImage:(UITapGestureRecognizer *)tap{
    [self.delegate imgviewTapped:(UIImageView*)tap.view];
}

@end
