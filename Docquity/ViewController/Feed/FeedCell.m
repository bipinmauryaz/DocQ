/*============================================================================
 PROJECT: Docquity
 FILE:    FeedCell.m
 AUTHOR:  Copyright © 2016 Docquity Private Limited All rights reserved.
 DATE:    Created by Docquity Private Limited on 17/01/16.
 =============================================================================*/

/*============================================================================
 MACRO
 =============================================================================*/
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "FeedCell.h"
#import "UIImageView+WebCache.h"
#import "DefineAndConstants.h"
#import "NSString+HTML.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "RFLayout.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "WebVC.h"

@interface FeedCell ()<UITextViewDelegate>
{
    BOOL _showMoreButton;
}
@end
@implementation FeedCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Add container View
        self.contentView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
        
        //[UIColor colorWithRed:217.0/255.0 green:222.0/255.0 blue:225.0/255.0 alpha:1];
        UIColor *color = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1];
        
        // 88, 186 ,72
        UIColor *feedtypecolor = [UIColor colorWithRed:88.0/255.0 green:186.0/255.0 blue:72.0/255.0 alpha:1];
        
        // 90 91 96
        UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor whiteColor];
        _containerView = view;
        
        //Create Border view
        _containerView.layer.cornerRadius = 0.0f;
        [self.contentView addSubview:_containerView];
        
        //Add image views
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        _userImageView = imageView;
        _userImageView.contentMode = UIViewContentModeScaleAspectFill;
        _userImageView.layer.cornerRadius = 4.0f;
        _userImageView.layer.masksToBounds = YES;
        _userImageView.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
        _userImageView.layer.borderWidth = 0.5;
        [_containerView addSubview:_userImageView];
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _feedImageView = imageView;
        [_containerView addSubview:_feedImageView];
        
        //Add image views
        UIView *multiImageView = [[UIView alloc]initWithFrame:CGRectZero];
        multiImageView.backgroundColor = [UIColor clearColor];
        _feedMultipleImageView = multiImageView;
        [_containerView addSubview:_feedMultipleImageView];
        
        //Add first Image
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _firstImageView = imageView;
        [_feedMultipleImageView addSubview:_firstImageView];
        
        //Add second Image
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _secondImageView = imageView;
        [_feedMultipleImageView addSubview:_secondImageView];
        
        //Add third Image
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _thirdImageView = imageView;
        [_feedMultipleImageView addSubview:_thirdImageView];
        
        //Add fourth Image
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _fourthImageView = imageView;
        [_feedMultipleImageView addSubview:_fourthImageView];
        
        //Add video ThumnailImg
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _videoThumbnailImgView = imageView;
        [_containerView addSubview:_videoThumbnailImgView];
        
        //Document Preview Holder
        view = [[UIView alloc]initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
        _documentView = view;
        [_containerView addSubview:_documentView];
        
        //Add document ThumnailImg
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _documentThumbnailImgView = imageView;
        [_documentView addSubview:_documentThumbnailImgView];
        
        //add document name and file icon view
        view = [[UIView alloc]initWithFrame:CGRectZero];
        _documentContainerVw = view;
        [_documentView addSubview:_documentContainerVw];
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _img_document_type = imageView;
        [_documentContainerVw addSubview:_img_document_type];
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _feedTypeImageView = imageView;
        [_containerView addSubview:_feedTypeImageView];
        
        //Add WebView
        UIWebView*metacontentWv = [[UIWebView alloc]initWithFrame:CGRectZero];
        metacontentWv.backgroundColor = [UIColor clearColor];
        metacontentWv.contentMode = UIViewContentModeScaleToFill;
        metacontentWv.clipsToBounds = YES;
        [metacontentWv.scrollView setScrollEnabled:NO];
        _feedmetaWebView = metacontentWv;
        _feedmetaWebView.layer.borderWidth = 1.0;
        _feedmetaWebView.layer.borderColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0].CGColor;
        [_containerView addSubview:_feedmetaWebView];
        
        //Add Labels
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14.0f];
        label.textColor = [UIColor blackColor];
        [_containerView addSubview:label];
        _userNameLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        [_containerView addSubview:label];
        _lastActivityLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = feedtypecolor;
        label.font = [UIFont systemFontOfSize:12.0f];
        [_containerView addSubview:label];
        _feedTypelabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = color;
        label.alpha = 0.5f;
        [_containerView addSubview:label];
        _lastActivitySepLineLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = color;
        label.font = [UIFont systemFontOfSize:12.0f];
        [_containerView addSubview:label];
        _timeLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = color;
        label.font = [UIFont systemFontOfSize:12.0f];
        [_containerView addSubview:label];
        _assoLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        [_containerView addSubview:label];
        _titleLabel = label;
        
        KILabel*klabel = [[KILabel alloc]initWithFrame:CGRectZero];
        klabel.backgroundColor = [UIColor grayColor];
        //label.numberOfLines = 0;
        klabel.font = [UIFont systemFontOfSize:13.0f];
        [_containerView addSubview:klabel];
        _specialityTagNameLabel = klabel;
        
        UITextView*texView = [[UITextView alloc]initWithFrame:CGRectZero];
        texView.backgroundColor = [UIColor clearColor];
        texView.textColor =  color;
        texView.editable = NO;
        texView.selectable = YES;
        texView.scrollEnabled = NO;
        texView.text = nil;
        texView.delegate = self;
        texView.showsVerticalScrollIndicator = NO;
        texView.dataDetectorTypes = UIDataDetectorTypeAll;
        texView.font = [UIFont systemFontOfSize:13.0f];
        [_containerView addSubview:texView];
        texView.textContainer.maximumNumberOfLines = 3;
        texView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentTextView = texView;
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _likeImageView = imageView;
        [_containerView addSubview:_likeImageView];
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = color;
        label.font = [UIFont systemFontOfSize:13.0f];
        [_containerView addSubview:label];
        _poplaritlyLabel = label;
        
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = color;
        label.alpha = 0.5f;
        [_containerView addSubview:label];
        _sepLine = label;
        
        //Add action
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
        [_containerView addSubview:button];
        _trustButton = button;
        [_trustButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(5, -2, 0, 0);
        [button setTitle:@"Comment" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateNormal];
        [_containerView addSubview:button];
        _commentButton = button;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(5, -2, 0, 0);
        [button setTitle:@"Share" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setImage:[UIImage imageNamed:@"Shared"] forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateNormal];
        [_containerView addSubview:button];
        _shareButton = button;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:@"See more" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:152.0/255.0 green:152.0/255.0 blue:152.0/255.0 alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        _seeMoreButton = button;
        [_containerView addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
        [_containerView addSubview:button];
        _editButton = button;
        
        //Add metalink button WebView
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        _openMetaDataButton = button;
        [_containerView addSubview:button];
        
        //Add video Play button
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        _videoplayBtn = button;
        [_containerView addSubview:button];
        
        //Add document file open button
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        _documentBtn = button;
        [_containerView addSubview:button];
        
        //PDF File Name show
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:15.0f];
        _lbl_doc_file_name = label;
        [_documentContainerVw addSubview:_lbl_doc_file_name];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect mainFrame = self.contentView.frame;
    float x_position = 0.0f;
    // float originx_position = 10.0f;
    float y_poistion = 5.0f;
    float padding = 4.0f;
    _containerView.frame = CGRectMake(x_position, y_poistion, mainFrame.size.width-2*x_position, mainFrame.size.height-2*y_poistion);
    
    //Last Activity update label
    _lastActivityLabel.frame = CGRectMake(x_position+10, 5, _containerView.frame.size.width , 25.0f);
    
    // Last Activity bottom sep label
    _lastActivitySepLineLabel.frame = CGRectMake(0, _lastActivityLabel.frame.size.height+10, CGRectGetWidth(_containerView.frame), 0.5);
    
    //set frame feed filter type image view
    // _feedFilterImageView.frame = CGRectMake(_lastActivityLabel.frame.size.width-25, 10, 16, 16);
    
    _feedTypelabel.frame = CGRectMake(_lastActivityLabel.frame.size.width-50, 8, 50, 20);
    
    //set frame for userImageView
    _userImageView.frame = CGRectMake(x_position+10, _lastActivityLabel.frame.size.height+14+10, 40, 40);
    _userImageView.layer.masksToBounds = YES;
    _userImageView.layer.cornerRadius = 4.0;
    //_userImageView.frame.size.height/2;
    x_position = _userImageView.frame.size.width + x_position + padding;
    _userNameLabel.frame = CGRectMake(x_position+15, _lastActivityLabel.frame.size.height+14+8, _containerView.frame.size.width-100, 20.0f);
    y_poistion += _userNameLabel.frame.size.height;
    
    _feedTypeImageView.frame = CGRectMake(x_position+15, _lastActivityLabel.frame.size.height+14+y_poistion+8, 16, 16);
    _assoLabel.frame = CGRectMake(x_position+_feedTypeImageView.frame.size.width+padding+10+3, _lastActivityLabel.frame.size.height+14+y_poistion+8, _containerView.frame.size.width-(x_position+_feedTypeImageView.frame.size.width+padding), 20.0f);
    _assoLabel.numberOfLines =0 ;
    [_assoLabel sizeToFit];
    _timeLabel.frame = CGRectMake(_assoLabel.frame.size.width + _assoLabel.frame.origin.x +4, _assoLabel.frame.origin.y, _containerView.frame.size.width-(x_position+_feedTypeImageView.frame.size.width+padding), _assoLabel.frame.size.height);
    
    y_poistion += _timeLabel.frame.size.height+padding+3;
    x_position = 5.0f;
    _titleLabel.frame = CGRectMake(10, _lastActivityLabel.frame.size.height+14+y_poistion+8, _containerView.frame.size.width-20, 30+padding);
    // [_titleLabel sizeToFit];
    
    if (IS_IPHONE_6_PLUS) {
        _editButton.frame = CGRectMake(360, _lastActivityLabel.frame.size.height+14-12, 60, 60.0f);
    }
    else if(IS_IPHONE_6){
        _editButton.frame = CGRectMake(320, _lastActivityLabel.frame.size.height+14-12, 60, 60.0f);
    }else{
        _editButton.frame = CGRectMake(270, _lastActivityLabel.frame.size.height+14-12, 60, 60.0f);
    }

    //Change y_position
    y_poistion += _titleLabel.frame.size.height+padding;
    if([[_feedData valueForKey:@"speciality"]count]>0) {
         _specialityTagNameLabel.hidden =NO;
        _specialityTagNameLabel.frame = CGRectMake(10, _lastActivityLabel.frame.size.height+14+y_poistion+5, _containerView.frame.size.width-16, 15);
        CGRect tempFrameLblsoecilityframe = _specialityTagNameLabel.frame;
        _specialityTagNameLabel.numberOfLines = 2;
          _specialityTagNameLabel.backgroundColor = [UIColor clearColor];
         _specialityTagNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
         [_specialityTagNameLabel sizeToFit];
          CGRect finalFrameLblSpecility = _specialityTagNameLabel.frame;
          finalFrameLblSpecility.size.width = tempFrameLblsoecilityframe.size.width;
         _specialityTagNameLabel.frame = finalFrameLblSpecility;
    }
    else{
        _specialityTagNameLabel.hidden =YES;
    }
    CGRect  lblRect = [_contentTextView.text boundingRectWithSize:(CGSize){_containerView.frame.size.width-20, MAXFLOAT}
                                                          options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    
    if ((IS_IPHONE_5)||(IS_IPHONE_4)) {
        if (lblRect.size.height>50) {
            lblRect.size.height = 50;
        }
    }else if (IS_IPHONE_6_PLUS || IS_IPHONE_6){
        if (lblRect.size.height>45) {
            lblRect.size.height = 45;
        }
    }

    if (_showMoreButton)
    {
        if([[_feedData valueForKey:@"speciality"]count]>0)
    {
        if ((IS_IPHONE_5)||(IS_IPHONE_4)) {
              _contentTextView.frame = CGRectMake(8-padding, _specialityTagNameLabel.frame.size.height+14+y_poistion+28, _containerView.frame.size.width-16, lblRect.size.height+4*padding+32);
        }
        else{
        _contentTextView.frame = CGRectMake(8-padding, _specialityTagNameLabel.frame.size.height+14+y_poistion+30, _containerView.frame.size.width-16, lblRect.size.height+4*padding+32);
        }
        
        if (IS_IPHONE_6_PLUS) {
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-38, [UIScreen mainScreen].bounds.size.width+300, 30.0f);
        }
        else if(IS_IPHONE_6){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-38, [UIScreen mainScreen].bounds.size.width+250, 30.0f);
        }
        else if(IS_IPHONE_4){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-38, [UIScreen mainScreen].bounds.size.width+180, 30.0f);
        }
        else if(IS_IPHONE_5){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-38, [UIScreen mainScreen].bounds.size.width+180, 30.0f);
        }
    }
    else{
        _contentTextView.frame = CGRectMake(8-padding, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width-16, 65.0f);
        if (IS_IPHONE_6_PLUS) {
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-15, [UIScreen mainScreen].bounds.size.width+300, 30.0f);
        }
        else if(IS_IPHONE_6){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-15, [UIScreen mainScreen].bounds.size.width+250, 30.0f);
        }
        else if(IS_IPHONE_4){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-15, [UIScreen mainScreen].bounds.size.width+180, 30.0f);
        }
        else if(IS_IPHONE_5){
            _seeMoreButton.frame = CGRectMake(x_position-padding, CGRectGetMaxY(_contentTextView.frame)-15, [UIScreen mainScreen].bounds.size.width+180, 30.0f);
        }
     }
          y_poistion += 30.0f;
          _seeMoreButton.hidden = NO;
    }
    else
    {
    _seeMoreButton.hidden = YES;
    if([[_feedData valueForKey:@"speciality"]count]>0) {
        _contentTextView.frame = CGRectMake(8-padding, _specialityTagNameLabel.frame.size.height+14+y_poistion+28, _containerView.frame.size.width-16, lblRect.size.height+4*padding+32);
        }
    else {
        _contentTextView.frame = CGRectMake(8-padding, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width-16, lblRect.size.height+4*padding);
        }
     }
    _documentBtn.hidden = YES;
    _openMetaDataButton.hidden =YES;
    _videoplayBtn.hidden= YES;
    //y_poistion += _contentTextView.frame.size.height+padding;
    y_poistion += _contentTextView.frame.size.height-5;
    
    //Check if FeedImage is hidden or not..
    if (!_feedImageView.hidden) {
        _feedImageView.frame = CGRectMake(0.0, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width, 250.0f);
        _openMetaDataButton.hidden =YES;
        _documentContainerVw.hidden =YES;
        _videoplayBtn.hidden = YES;
        _documentBtn.hidden =YES;
        y_poistion += _feedImageView.frame.size.height+padding;
    }
    //Check if FeedMultiImage is hidden or not..
    if (!_feedMultipleImageView.hidden) {
        _feedMultipleImageView.frame = CGRectMake(0.0, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width, 250.0f);
        _openMetaDataButton.hidden =YES;
        _documentContainerVw.hidden =YES;
        _videoplayBtn.hidden = YES;
        _documentContainerVw.hidden =YES;
        y_poistion += _feedMultipleImageView.frame.size.height+padding;
    }
    
    //Check if FeedVideo is hidden or not.
    if (!_videoThumbnailImgView.hidden) {
        _videoThumbnailImgView.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width-2*x_position, 250.0f);
        _documentContainerVw.hidden =YES;
        _openMetaDataButton.hidden =YES;
        _videoplayBtn.hidden =NO;
        _documentBtn.hidden =YES;
        _documentContainerVw.hidden =YES;
        y_poistion += _videoThumbnailImgView.frame.size.height+padding;
        CGRect frame = _videoThumbnailImgView.frame;
        _videoplayBtn.frame = frame;
        //y_poistion += _openMetaDataButton.frame.size.height+padding;
    }
    if (!_documentView.hidden) {
        _documentView.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width-2*x_position, 132.0f);
        _documentThumbnailImgView.frame = CGRectMake(5, 5, _documentView.frame.size.width-10, 85.0f);
        _documentContainerVw.frame = CGRectMake(5, 90, _documentView.frame.size.width-10, 37.0f);
        _documentContainerVw.hidden = NO;
        _documentContainerVw.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        _img_document_type.frame = CGRectMake(5, 5, 25, 25);
        _lbl_doc_file_name.frame = CGRectMake(35 ,5 , _documentThumbnailImgView.frame.size.width -40, 25.0f);
        _documentBtn.hidden = NO;
        _openMetaDataButton.hidden = YES;
        _videoplayBtn.hidden = YES;
        y_poistion += _documentView.frame.size.height+padding;
        CGRect frame = _documentView.frame;
        _documentBtn.frame = frame;
        //y_poistion += _openMetaDataButton.frame.size.height+padding;
    }
    //Check if FeedMetaview is hidden or not.
    if (!_feedmetaWebView.hidden) {
        
        _feedmetaWebView.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, _containerView.frame.size.width-2*x_position, 270.0f);

        // }
           _openMetaDataButton.hidden =NO;
        y_poistion += _feedmetaWebView.frame.size.height+padding;
        CGRect frame = _feedmetaWebView.frame;
        _openMetaDataButton.frame = frame;
        //y_poistion += _openMetaDataButton.frame.size.height+padding;
    }
    //likes and commnent label
    if (!_poplaritlyLabel.hidden) {
        _poplaritlyLabel.frame = CGRectMake(10, _lastActivityLabel.frame.size.height+14+y_poistion, CGRectGetWidth(_containerView.frame), 20.0f);
        y_poistion += _poplaritlyLabel.frame.size.height+padding;
    }
    //sep label
    _sepLine.frame = CGRectMake(0, _lastActivityLabel.frame.size.height+14+y_poistion, CGRectGetWidth(_containerView.frame), 0.5);
    
    //Set Actions frame i.e Trust and Comment Button
    y_poistion += 1;
    _trustButton.frame = CGRectMake(x_position-10, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);
    
    if(IS_IPHONE_6_PLUS){
        x_position += 60.0f+_trustButton.frame.size.width;
        _commentButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);;
    }
    else if (IS_IPHONE_6){
        x_position += 40.0f+_trustButton.frame.size.width;
        _commentButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);;
    }
    else{
        x_position += 20.0f+_trustButton.frame.size.width;
        _commentButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);
    }
    if(IS_IPHONE_6_PLUS){
        x_position += 60.0f+_commentButton.frame.size.width;
        _shareButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);
    }
    else if (IS_IPHONE_6){
        x_position += 50.0f+_commentButton.frame.size.width;
        _shareButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);
    }
    else{
        x_position += 20.0f+_commentButton.frame.size.width;
        _shareButton.frame = CGRectMake(x_position, _lastActivityLabel.frame.size.height+14+y_poistion, 90.0f, 31.0f);
    }
    
    if([[_feedData valueForKey:@"image_list"]count]==2) {
        _firstImageView.frame  = CGRectMake(0, 0, _feedMultipleImageView.frame.size.width, (_feedMultipleImageView.frame.size.height/2)-3);
        _secondImageView.frame  = CGRectMake(0, _firstImageView.frame.size.height+6+_firstImageView.frame.origin.y, _feedMultipleImageView.frame.size.width, (_feedMultipleImageView.frame.size.height/2)-3);
        
        [self imageViewSetup:_firstImageView];
        [self imageViewSetup:_secondImageView];
        _thirdImageView.hidden = YES;
        _fourthImageView.hidden = YES;
        
    }else if([[_feedData valueForKey:@"image_list"]count]==3) {
        _thirdImageView.hidden = false;
        _firstImageView.frame  = CGRectMake(0, 0, _feedMultipleImageView.frame.size.width, (_feedMultipleImageView.frame.size.height/2)-3);
        _secondImageView.frame  = CGRectMake(0, _firstImageView.frame.size.height+6+_firstImageView.frame.origin.y, (_feedMultipleImageView.frame.size.width/2)-3, (_feedMultipleImageView.frame.size.height/2)-3);
        
        _thirdImageView.frame  = CGRectMake(_secondImageView.frame.size.width+6, _secondImageView.frame.origin.y, (_feedMultipleImageView.frame.size.width/2)-3,_secondImageView.frame.size.height);
        
        [self imageViewSetup:_firstImageView];
        [self imageViewSetup:_secondImageView];
        [self imageViewSetup:_thirdImageView];
        _fourthImageView.hidden = YES;
        
    } else if([[_feedData valueForKey:@"image_list"]count]==4) {
        _fourthImageView.hidden = false;
        _thirdImageView.hidden = false;
        _firstImageView.frame  = CGRectMake(0, 0, (_feedMultipleImageView.frame.size.width/2)-3, (_feedMultipleImageView.frame.size.height/2)-3);
        
        _secondImageView.frame  = CGRectMake(_firstImageView.frame.size.width+6, _firstImageView.frame.origin.y, (_feedMultipleImageView.frame.size.width/2)-3, _firstImageView.frame.size.height);
        
        _thirdImageView.frame  = CGRectMake(0,_firstImageView.frame.size.height+6+_firstImageView.frame.origin.y, _firstImageView.frame.size.width,(_feedMultipleImageView.frame.size.height/2)-3);
        
        _fourthImageView.frame  = CGRectMake(_thirdImageView.frame.size.width+6, _thirdImageView.frame.origin.y, _secondImageView.frame.size.width,_thirdImageView.frame.size.height);
        [self imageViewSetup:_firstImageView];
        [self imageViewSetup:_secondImageView];
        [self imageViewSetup:_thirdImageView];
        [self imageViewSetup:_fourthImageView];
    }
}


// set Info data on feed lists
- (void)setInfo:(NSDictionary*)feedInfo
{
    _feedData = feedInfo;
    NSString* cus_uId =  [feedInfo objectForKey:@"custom_id"];
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    NSString *cuId=[userpref objectForKey:ownerCustId];
    if([cus_uId isEqualToString:cuId]) {
        _editButton.hidden = NO;
    }
    else{
        _editButton.hidden = YES;
    }
    //Set user name
    _userNameLabel.text = [[[[[NSString stringWithFormat:@"%@",[feedInfo objectForKey:@"name"]?[feedInfo objectForKey:@"name"]:@""] stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]capitalizedString];
    if ([feedInfo[@"see_more"] integerValue] == 1) {
        _showMoreButton = YES;
    }
    else{
        _showMoreButton = NO;
    }
    NSMutableArray *assoarr = [[NSMutableArray alloc]init];
    assoarr =[feedInfo objectForKey:@"association_list"];
    NSMutableString *assoImg;
    NSMutableString *assoName;
    for(int i=0; i<[assoarr count]; i++)
    {
        NSDictionary *assoInfo =  assoarr[i];
        if ([assoarr count]==1){
            if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
            {
                //asId = assoInfo[@"association_id"];
                assoImg = assoInfo[@"association_pic"];
                assoName = assoInfo[@"association_name"];
                _assoLabel.text = [NSString stringWithFormat:@" %@ \uA789",assoName];
                [_feedTypeImageView sd_setImageWithURL:[NSURL URLWithString:assoImg]
                                      placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                               options:SDWebImageRefreshCached];
            }
        }
        else if ([assoarr count]>1) {
            if (assoInfo != nil && [assoInfo isKindOfClass:[NSDictionary class]])
            {
            NSInteger assoCountNumber = ([assoarr count]-1);
             NSString*assoNumbers =  [NSString stringWithFormat:@"%ld", assoCountNumber];
                //asId = assoInfo[@"association_id"];
                assoImg = [assoarr objectAtIndex:0][@"association_pic"];
                assoName = [assoarr objectAtIndex:0][@"association_name"];
                
               // [assoInfo[@"association_pic"]objectAtIndex:0];
                //assoName = [assoInfo[@"association_name"]objectAtIndex:0];
                _assoLabel.text = [NSString stringWithFormat:@" %@ + %@ \uA789",assoName,assoNumbers];
                [_feedTypeImageView sd_setImageWithURL:[NSURL URLWithString:assoImg]
                                      placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                               options:SDWebImageRefreshCached];
            }

//            _assoLabel.text = @" Everyone \uA789";
//            _feedTypeImageView.image = [UIImage imageNamed:@"globe.png"];
       }
    }
    NSMutableArray* Specialityarr = [[NSMutableArray alloc]init];
    Specialityarr = [feedInfo valueForKey:@"speciality"];
    if ([Specialityarr count] == 0) {
        
    }
    else{
        NSString*specialityId;
        NSString*specialityName;
        NSMutableArray* SpecialityNamearr = [[NSMutableArray alloc]init];
        NSMutableArray* SpecialityIdArr = [[NSMutableArray alloc]init];
        for(int i=0; i<[Specialityarr count]; i++)
        {
            NSDictionary *speclityInfo =  Specialityarr[i];
            if (speclityInfo != nil && [speclityInfo isKindOfClass:[NSDictionary class]])
            {
                specialityId = speclityInfo[@"speciality_id"];
                specialityName = speclityInfo[@"speciality_name"];
            }
            [SpecialityNamearr addObject:specialityName];
            [SpecialityIdArr addObject:specialityId];
        }
        NSString * myspeciality = [[SpecialityNamearr valueForKey:@"description"] componentsJoinedByString:@" #"];
       // NSLog(@"Speciality Name: %@",myspeciality);
        _specialityTagNameLabel.text =     [NSString stringWithFormat:@"#%@", [myspeciality stringByDecodingHTMLEntities]];
        //NSLog(@"specialityId: %@",SpecialityIdArr);
     }

    //set User Imag
    NSString*urslStrig = [NSString stringWithFormat:@"%@",[feedInfo objectForKey:@"profile_pic_path"]?[feedInfo objectForKey:@"profile_pic_path"]:@""];
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:urslStrig]
                      placeholderImage:[UIImage imageNamed:@"avatar.png"]
                               options:SDWebImageRefreshCached];
    
    //Check Feed type and set Feed link
    if ([[feedInfo valueForKey:@"file_type"]isEqualToString:@"link"])
    {
        _feedmetaWebView.hidden = NO;
        _feedImageView.hidden = YES;
        _videoplayBtn.hidden = YES;
        _documentBtn.hidden =YES;
        _documentView.hidden =YES;
        _videoThumbnailImgView.hidden = YES;
        _feedMultipleImageView.hidden = YES;
        
        //Set Feed meta data
        urslStrig = feedInfo[@"file_url"];
        urslStrig = [urslStrig stringByDecodingHTMLEntities];
        _feedmetaWebView.opaque = NO;
        CGRect rect;
        _feedmetaWebView.backgroundColor = [UIColor clearColor];
        rect = _feedmetaWebView.frame;
        rect.size.height = 1;
        _feedmetaWebView.frame = rect;
        [_feedmetaWebView loadHTMLString:urslStrig baseURL:nil];
    }
    else{
        _feedmetaWebView.hidden = YES;
    }
    //Check Feed type and set Feed image
    if ([[feedInfo valueForKey:@"file_type"]isEqualToString:@"image"])
    {
        if ([[feedInfo valueForKey:@"image_list"]count]==1) {
            _feedImageView.hidden = NO;
            _feedMultipleImageView.hidden = YES;
            _feedmetaWebView.hidden = YES;
            _documentBtn.hidden =YES;
            _documentView.hidden =YES;
            _videoplayBtn.hidden = YES;
            _videoThumbnailImgView.hidden = YES;
            
            //Set Feed Image
            urslStrig = feedInfo[@"file_url"];
            [_feedImageView sd_setImageWithURL:[NSURL URLWithString:urslStrig]
                              placeholderImage:[UIImage imageNamed:@"img-not.png"]];
        }
        else if([[feedInfo valueForKey:@"image_list"]count]==2) {
            _feedImageView.hidden = YES;
            _feedMultipleImageView.hidden = NO;
            _feedmetaWebView.hidden = YES;
            _documentBtn.hidden =YES;
            _documentView.hidden =YES;
            _videoplayBtn.hidden = YES;
            _videoThumbnailImgView.hidden = YES;
            _thirdImageView.hidden = YES;
            _fourthImageView.hidden = YES;
            
            //Set Feed Image
            NSString* firstImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:0]valueForKey:@"multiple_file_url"];
            
            NSString* secondImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:1]valueForKey:@"multiple_file_url"];
            [_firstImageView sd_setImageWithURL:[NSURL URLWithString:firstImgUrl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            
            [_secondImageView sd_setImageWithURL:[NSURL URLWithString:secondImgUrl]
                                placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            
        }else if([[feedInfo valueForKey:@"image_list"]count]==3) {
            _feedImageView.hidden = YES;
            _feedMultipleImageView.hidden = NO;
            _feedmetaWebView.hidden = YES;
            _documentBtn.hidden =YES;
            _documentView.hidden =YES;
            _videoplayBtn.hidden = YES;
            _videoThumbnailImgView.hidden = YES;
            _thirdImageView.hidden = NO;
            _fourthImageView.hidden = YES;
            
            //Set Feed Image
            NSString* firstImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:0]valueForKey:@"multiple_file_url"];
            
            NSString* secondImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:1]valueForKey:@"multiple_file_url"];
            
            NSString* thirdImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:2]valueForKey:@"multiple_file_url"];
            
            [_firstImageView sd_setImageWithURL:[NSURL URLWithString:firstImgUrl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            
            [_secondImageView sd_setImageWithURL:[NSURL URLWithString:secondImgUrl]
                                placeholderImage:[UIImage imageNamed:@"img-not.png"]];
             
            
            [_thirdImageView sd_setImageWithURL:[NSURL URLWithString:thirdImgUrl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]];
             
        }else if([[feedInfo valueForKey:@"image_list"]count]==4) {
            _feedImageView.hidden = YES;
            _feedMultipleImageView.hidden = NO;
            _feedmetaWebView.hidden = YES;
            _documentBtn.hidden =YES;
            _documentView.hidden =YES;
            _videoplayBtn.hidden = YES;
            _videoThumbnailImgView.hidden = YES;
            _thirdImageView.hidden = NO;
            _fourthImageView.hidden = NO;
            
            //Set Feed Image
            NSString* firstImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:0]valueForKey:@"multiple_file_url"];
            
            NSString* secondImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:1]valueForKey:@"multiple_file_url"];
            
            NSString* thirdImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:2]valueForKey:@"multiple_file_url"];
            
            NSString* fourthImgUrl = [[[feedInfo valueForKey:@"image_list"]objectAtIndex:3]valueForKey:@"multiple_file_url"];
            
            [_firstImageView sd_setImageWithURL:[NSURL URLWithString:firstImgUrl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            
            [_secondImageView sd_setImageWithURL:[NSURL URLWithString:secondImgUrl]
                                placeholderImage:[UIImage imageNamed:@"img-not.png"]];
            
            [_thirdImageView sd_setImageWithURL:[NSURL URLWithString:thirdImgUrl]
                               placeholderImage:[UIImage imageNamed:@"img-not.png"]];
             
            [_fourthImageView sd_setImageWithURL:[NSURL URLWithString:fourthImgUrl]
                                placeholderImage:[UIImage imageNamed:@"img-not.png"]];
             
        }
    }
    else{
        _feedImageView.hidden = YES;
        _feedMultipleImageView.hidden = YES;
    }
    
    //Check Feed type and set Feed video
    if ([[feedInfo valueForKey:@"file_type"]isEqualToString:@"video"])
    {
        //Set Feed video
        NSString*video_thumbnailUrl = feedInfo[@"video_image_url"];
        [_videoThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:video_thumbnailUrl]
                                  placeholderImage:[UIImage imageNamed:@"videoPlaceholder.png"]];
        _feedmetaWebView.hidden = YES;
        _feedMultipleImageView.hidden = YES;
        _feedImageView.hidden = YES;
        _documentBtn.hidden =YES;
        _documentView.hidden =YES;
        _videoThumbnailImgView.hidden = NO;
        _videoplayBtn.hidden = NO;
    }
    else{
        _videoThumbnailImgView.hidden = YES;
    }
    
    //Check Feed type and set Feed file like pdf and docs.
    if ([[feedInfo valueForKey:@"file_type"]isEqualToString:@"document"])
    {
        _feedImageView.hidden = YES;
        _feedMultipleImageView.hidden = YES;
        _feedmetaWebView.hidden = YES;
        _videoplayBtn.hidden = YES;
        _videoThumbnailImgView.hidden = YES;
        _documentBtn.hidden =NO;
        _documentView.hidden =NO;
        
        //Set Feed document
        NSString*document_thumbnailUrl = feedInfo[@"video_image_url"];
        NSString *name = feedInfo[@"file_name"];
        NSString *type = [name pathExtension];
        
        name = [name stringByReplacingOccurrencesOfString:type withString:@""];
        name = [name substringToIndex:name.length-(name.length>0)];
        _lbl_doc_file_name.text = name;
        
        if([type isEqualToString:@"pdf"]){
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]
                                         placeholderImage:[UIImage imageNamed:@"pdf_placeholder.png"]];
            self.img_document_type.image = [UIImage imageNamed:@"pdf.png"];
        }else if([type containsString:@"xls"]){
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]
                                         placeholderImage:[UIImage imageNamed:@"xls_placeholder.png"]];
            self.img_document_type.image = [UIImage imageNamed:@"xls.png"];
        }else if([type containsString:@"ppt"]){
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]
                                         placeholderImage:[UIImage imageNamed:@"ppt_placeholder.png"]];
            self.img_document_type.image = [UIImage imageNamed:@"ppt.png"];
        }else if([type containsString:@"doc"]){
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]
                                         placeholderImage:[UIImage imageNamed:@"doc_placeholder.png"]];
            self.img_document_type.image = [UIImage imageNamed:@"doc.png"];
        }else if ([type isEqualToString:@"rtf"]){
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]
                                         placeholderImage:[UIImage imageNamed:@"rtf_placeholder.png"]];
            self.img_document_type.image = [UIImage imageNamed:@"rtf.png"];
        }else if ([type isEqualToString:@"txt"]){
            self.img_document_type.image = [UIImage imageNamed:@"txt.png"];
            [_documentThumbnailImgView sd_setImageWithURL:[NSURL URLWithString:document_thumbnailUrl]placeholderImage:[UIImage imageNamed:@"txt_placeholder.png"]];
        }
    }
    else{
        _documentView.hidden = YES;
    }
    
    ////// video work
    _titleLabel.text = [feedInfo objectForKey:@"title"];
    NSString*message  = [feedInfo objectForKey:@"content"];
    NSURL *url;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:message options:0 range:NSMakeRange(0, [message length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            url = [match URL];
            // NSLog(@"found URL: %@", url);
        }
    }
    if ([message.lowercaseString containsString:[NSString stringWithFormat:@"%@",url]]) {
        //  NSLog(@"mesg: %@",message);
        message =  [message stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",url] withString:[NSString stringWithFormat:@"%@",url] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [message length])];
    }
    else if ([message.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""]]) {
        
        message =  [message stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"http://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [message length])];
    }
    else if ([message.lowercaseString containsString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""]]) {
        message =  [message stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] withString:[[NSString stringWithFormat:@"%@",url]stringByReplacingOccurrencesOfString:@"https://" withString:@""] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [message length])];
    }
    message = [message stringByReplacingOccurrencesOfString: @"<br>" withString: @" "];
    message = [message stringByReplacingOccurrencesOfString:@"<br/>" withString: @" "];
    message= [message stringByReplacingOccurrencesOfString:@"<br />" withString: @" "];
    if([[feedInfo valueForKey:@"classification"] isEqualToString:@"cme"]){
        if (IS_IPHONE_6) {
            message = [NSString stringWithFormat:@"Fellow Doctors, I earned CPD credits on Docquity CME for the above course. Click here to get your CPD credits \nnow."];
        }
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:message  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(Click here)" options:kNilOptions error:nil]; // Matches 'Click here' case SENSITIVE
        
        NSRange range = NSMakeRange(0 ,message.length);
        
        // Change all words that are equal to 'Click here' to hyperlink color in the attributed string
        [regex enumerateMatchesInString:message options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange subStringRange = [result rangeAtIndex:0];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] range:subStringRange];
        }];
        _contentTextView.attributedText = mutableAttributedString;
    }
    else{
        //create your attributed string
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
        _contentTextView.attributedText = attributedString;
    }
    [self showtimeFromDict:feedInfo];
    [self showUpdateLastActivitytimeFromDict:feedInfo];
    
    [self setlike:feedInfo[@"total_like"] andComment:feedInfo[@"total_comments"]];
    //Set Button
    if ([feedInfo[@"like_status"]integerValue]==1)
    {
        [_trustButton setTitleColor: [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1] forState:UIControlStateNormal];
        [_trustButton setTitle:@"Liked" forState:UIControlStateNormal];
        [_trustButton setImage:[UIImage imageNamed:@"trust"] forState:UIControlStateNormal];
        _trustButton.userInteractionEnabled = NO;
    }
    else
    {
        [_trustButton setTitleColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
        [_trustButton setImage:[UIImage imageNamed:@"trust-hover"] forState:UIControlStateNormal];
        [_trustButton setTitle:@"Like" forState:UIControlStateNormal];
        _trustButton.userInteractionEnabled = YES;
    }
    [self layoutIfNeeded];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //Resize the webView to its Contentsize
    CGFloat height = webView.scrollView.contentSize.height;
    CGRect rect = webView.frame;
    rect.size.height = height;
    webView.frame = rect;
    [webView.superview sizeToFit];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // NSLog(@"%@",error);
}

- (void)setlike:(NSString*)like andComment:(NSString*)comment
{
    NSString *str = @"";
    if ([like integerValue] > 0 || [comment integerValue] > 0) {
        if ([like integerValue] == 1 && [comment integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor likes this    %@ Comment",like,comment];
        }
        else if ([like integerValue] > 1 && [comment integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this    %@ Comment",like,comment];
        }
        else if ([like integerValue] > 1 && [comment integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this    %@ Comments",like,comment];
        }
        else if ([like integerValue] == 1 && [comment integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor likes this    %@ Comments",like,comment];
        }
        else if([like integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctor likes this",like];
        }
        else if([like integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Doctors like this",like];
        }
        else if([comment integerValue] == 1)
        {
            str =[NSString stringWithFormat:@"%@ Comment",comment];
        }
        else if([comment integerValue] > 1)
        {
            str =[NSString stringWithFormat:@"%@ Comments",comment];
        }
        _poplaritlyLabel.text = str;
        _likeImageView.image = [UIImage imageNamed:@"liked.png"];
        _likeImageView.hidden = NO;
        _poplaritlyLabel.hidden = NO;
    }
    else
    {
        _likeImageView.hidden = YES;
        _poplaritlyLabel.hidden = YES;
    }
}

// show time on feed
- (void)showtimeFromDict:(NSDictionary*)timeInfo
{
    NSString *date1;
    if(timeInfo!=nil && [timeInfo isKindOfClass:[NSDictionary class]]){
        //check if bite dictionary exist
        //get datestr if exist
        date1=[timeInfo objectForKey:@"date_of_creation"];
        long long int timestamp = [date1 longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [self updateTimeLabelWithDate:dates];
    }
}

-(void)updatelastActivityTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    self.lastActivityLabel.text = [self relativeDateStringForDate:date];
    NSString *wordStr = @"Just now";
    NSString *daystr = @"day";
    NSString *commastr = @",";
    if ([self.lastActivityLabel.text rangeOfString:wordStr].location != NSNotFound)
    {
        self.lastActivityLabel.text = [NSString stringWithFormat:@"Last Activity on this post %@",[self relativeDateStringForDate:date]];
    }
    else if ([self.lastActivityLabel.text rangeOfString:daystr].location != NSNotFound)
    {
        NSString *yesterday = @"Yesterday";
        if ([self.lastActivityLabel.text rangeOfString:yesterday].location != NSNotFound){
            self.lastActivityLabel.text = [NSString stringWithFormat:@"Last Activity on this post %@",[self relativeDateStringForDate:date]];
        }
        else
        {
         self.lastActivityLabel.text = [NSString stringWithFormat:@"Last Activity on this post on %@",[self relativeDateStringForDate:date]];
        }
    }
    else  if ([self.lastActivityLabel.text rangeOfString:commastr].location != NSNotFound)
    {
        self.lastActivityLabel.text = [NSString stringWithFormat:@"Last Activity on this post %@",[self relativeDateStringForDate:date]];
    }
    else{
        self.lastActivityLabel.text = [NSString stringWithFormat:@"Last Activity on this post %@ ago",[self relativeDateStringForDate:date]];
    }
    NSMutableAttributedString *yourAttributedString= [[NSMutableAttributedString alloc] initWithString:self.lastActivityLabel.text];
    [yourAttributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor colorWithRed:152.0/255.0 green:152.0/255.0 blue:152.0/255.0 alpha:1]
                                 range:NSMakeRange(0, 26)];
    [self.lastActivityLabel setAttributedText: yourAttributedString];
    self.lastActivityLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

-(void)updateTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.doesRelativeDateFormatting = YES;
    self.timeLabel.text = [self relativeDateStringForDate:date];
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitWeekOfYear;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components1];
    components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *thatdate = [cal dateFromComponents:components1];
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:thatdate
                                                                     toDate:today
                                                                    options:0];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years", (long)components.year];
    } else if (components.month > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.weekOfYear > 0) {
        return [self getOnlyDate:thatdate];
    } else if (components.day > 0) {
        if (components.day > 1) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* component = [calender components:NSCalendarUnitWeekday fromDate:thatdate];
            return [self getDay:[component weekday]];
        } else {
            return @"Yesterday";
        }
    } else {
        return [self getTodayCurrTime:date];
    }
}

-(NSString*)getDay:(NSInteger)dayInt{
    // NSLog(@"%ld",(long)dayInt);
    NSMutableArray *day= [[NSMutableArray alloc]initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [day objectAtIndex:dayInt-1];
}

-(NSString *)getTodayCurrTime:(NSDate*)date{
    NSString *exactDatestr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter  stringFromDate:date];
    if(stringFromDate!=nil && ![stringFromDate isEqualToString:@""]){ //if date exist then calculate it
        
        // change of date formatter
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-10-21 03:19:32
        NSInteger seconds = [date timeIntervalSinceDate:currentTime];
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        NSInteger minutes = (int) (floor(seconds / 60));
        if(hours) {
            if (hours==-1) {
                exactDatestr = @"1 hr";
            }
            else {
                exactDatestr = [NSString stringWithFormat: @"%ld hrs", (long)hours*-1];
            }
        }
        else if(minutes){
            if (minutes==-1) {
                exactDatestr = @"1 min";
            }
            else
            {
                exactDatestr = [NSString stringWithFormat: @"%ld mins", (long)minutes*-1];
            }
        }
        else if(seconds)
            exactDatestr= [NSString stringWithFormat: @"%ld sec", (long)seconds*-1];
        else
            exactDatestr= [NSString stringWithFormat: @"Just now"];
        return exactDatestr;
    }
    return exactDatestr;
}

//\u2022 \u002E
-(NSString *)getOnlyDate:(NSDate*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd, yyyy"];
    return [df stringFromDate:date];
}

-(void)imageViewSetup:(UIImageView*)imgview{
    imgview.backgroundColor = [UIColor clearColor];
    imgview.contentMode = UIViewContentModeScaleAspectFill;
    imgview.clipsToBounds = YES;
    imgview.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    imgview.layer.borderWidth = 0.7f;
}

// show time on feed
- (void)showUpdateLastActivitytimeFromDict:(NSDictionary*)updateActivitytimeInfo
{
    NSString *date;
    if(updateActivitytimeInfo!=nil && [updateActivitytimeInfo isKindOfClass:[NSDictionary class]]){
        //else get date and claculate
        date=[updateActivitytimeInfo objectForKey:@"date_of_updation"];
        long long int timestamp = [date longLongValue]/1000;
        NSDate *dates = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [self updatelastActivityTimeLabelWithDate:dates];
    }
}



@end
