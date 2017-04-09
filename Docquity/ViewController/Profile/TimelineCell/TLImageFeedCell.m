//
//  TLImageFeedCell.m
//  Docquity
//
//  Created by Docquity-iOS on 02/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "TLImageFeedCell.h"
#import "DefineAndConstants.h"
#import "UIImageview+WebCache.h"
@implementation TLImageFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)didPressMoreImgBtn:(UIButton*)sender {
}

- (IBAction)didPressUserName:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressUserBtn:sender atPoint:center];
}


#pragma mark - Configure Cell For Row 
-(void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath withData:(NSMutableDictionary*)data{
    if([[data valueForKey:@"posted_by"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [[data valueForKey:@"posted_by"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        _isOwnProfile = YES;
    }else{
        _isOwnProfile = NO;
    }
    [self setupTags:data];
    self.lbl_hashtag.backgroundColor = [UIColor clearColor];
    // Block to handle all our taps, we attach this to all the label's handlers
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self.delegate tappedLink:string cellForRowAtIndexPath:indexPath];
    };
    self.lbl_desc.delegate = self;
    self.lbl_desc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.lbl_desc.userInteractionEnabled = YES;
    self.lbl_hashtag.userHandleLinkTapHandler = tapHandler;
    self.lbl_hashtag.urlLinkTapHandler = tapHandler;
    self.lbl_hashtag.hashtagLinkTapHandler = tapHandler;
    [self hideAllTheImageHolder];
    [self setupNormalFeed:data];
    if([[data valueForKey:@"file_type"]isEqualToString:kFeedTypeImage])
    {
        NSInteger imageCount = [[data valueForKey:@"image_list"] count];
        NSMutableArray *imageArray = [data valueForKey:@"image_list"];
        switch (imageCount) {
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
        
    }else if([[data valueForKey:@"file_type"]isEqualToString:kFeedTypeVideo]){
        [self setupVideoFeed:data];
    }
    
}

#pragma mark - Setup Normal feed
-(void)setupNormalFeed:(NSMutableDictionary*)data{
    self.btn_FeedAction.hidden = !_isOwnProfile;
    NSString *activityText=  @"";
    activityText = _isOwnProfile?@"Last Activity on :":@"You commented on :";
//    self.lbl_latestActivity.text = [NSString stringWithFormat:@"%@ %@",activityText,[NSString setUpdateTimewithString:[data valueForKey:@"date_of_updation"]]];
//    
    
    NSString *activityString = [NSString stringWithFormat:@"%@ %@",activityText,[NSString setUpdateTimewithString:[data valueForKey:@"date_of_updation"]]];
    
    NSString *updateTime = [NSString setUpdateTimewithString:[data valueForKey:@"date_of_updation"]];
    
    [self.lbl_latestActivity setText:activityString afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:updateTime options:NSCaseInsensitiveSearch];
        
        UIFont *boldSystemFont = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:boldRange];
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    
    
    self.lbl_FeedCategory.text = [[data valueForKey:@"feed_kind"]isEqualToString:@"post"]?@"Trends":@"Cases";
    [self.img_feeder sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"avatar.png"] options:SDWebImageRefreshCached];
    [self setupAssociation:data];
    [self.lbl_feederName setTitle:[[[[data valueForKey:@"name"]stringByDecodingHTMLEntities] stringByDecodingHTMLEntities] capitalizedString] forState:UIControlStateNormal];
    self.lbl_feed_title.text = [[[data valueForKey:@"title"]stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    NSString *content = [[[data valueForKey:@"content"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    self.lbl_desc.text =  content;
    [self setupImageView:self.img_feeder];
    NSString *hashString = @"";
    for(NSMutableDictionary *specDic in self.specArray){
        if([hashString isEqualToString:@""]){
            hashString=  [[[NSString stringWithFormat:@"#%@",[specDic valueForKey:@"speciality_name"]] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
        }else{
            hashString = [NSString stringWithFormat:@"%@ #%@",hashString,[[[specDic valueForKey:@"speciality_name"] stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
        }
    }
    
    self.lbl_hashtag.text = hashString;
        
    if(content.length == 0){
        self.lblDescHeightConstraints.constant = 0;
        self.hashTagBottomConstraints.constant = 0;
        // self.lblDescBottomConstraints.constant = 0;
    }else if(self.lblDescHeightConstraints.constant == 0){
        self.lblDescHeightConstraints.constant = 17;
        self.hashTagBottomConstraints.constant = 5.5;
        // self.lblDescBottomConstraints.constant = 6;
    }
//    self.lbl_hashtag.backgroundColor = [UIColor yellowColor];
//    self.lbl_desc.backgroundColor = [UIColor redColor];
//    self.lbl_feed_title.backgroundColor = [UIColor yellowColor];
    [self setupLikeCommentView:data];
    
    if(hashString.length == 0){
        self.hashTagHeightEqalRelConstraints.active = YES;
        self.hashTagHeightConstraints.active = FALSE;
        self.hashTagHeightEqalRelConstraints.constant = 0;
        self.hashTagBottomConstraints.constant = 0;
        self.hashTagTopConstraints.constant = 0;
        // self.lblDescBottomConstraints.constant = 0;
    }else {
        self.hashTagHeightEqalRelConstraints.active = false;
        self.hashTagHeightConstraints.active = true;
        self.hashTagHeightConstraints.constant = 1;
        self.hashTagBottomConstraints.constant = 5.5;
        self.hashTagTopConstraints.constant = 5;
        // self.lblDescBottomConstraints.constant = 6;
    }
    UITapGestureRecognizer *tapOnuserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUser:)];
    tapOnuserImg.numberOfTapsRequired = 1;
    [self.img_feeder addGestureRecognizer:tapOnuserImg];
    
}

-(void)didTapUser:(UITapGestureRecognizer *)tap{
    CGPoint center= tap.view.center;
    [self.delegate didTapUserImage:(UIImageView*)tap.view atPoint:center];
}

#pragma mark - Setup Video

-(void)setupVideoFeed:(NSMutableDictionary*)data{
    self.img_single.hidden = false;
    
    NSString*video_thumbnailUrl = data[@"video_image_url"];
    self.videoURLToPlay = [data valueForKey:@"file_url"];
    [self.img_single sd_setImageWithURL:[NSURL URLWithString:video_thumbnailUrl]
                              placeholderImage:[UIImage imageNamed:@"videoPlaceholder.png"]];
    
    self.img_single.contentMode = UIViewContentModeScaleAspectFill;
    self.img_single.clipsToBounds = true;
    self.img_single.layer.borderColor = kBorderLayerColor ;
    self.img_single.layer.borderWidth = 0.7f;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideo:)];
    self.img_single.userInteractionEnabled = YES;
    [self.img_single addGestureRecognizer:tap];
}


#pragma mark - Setup Association

-(void)setupAssociation:(NSMutableDictionary *)dic{
    if([[dic valueForKey:@"association_list"]count]>1){
    
    NSInteger assoCountNumber = ([[dic valueForKey:@"association_list"]count]-1);
    NSString*assoNumbers =  [NSString stringWithFormat:@"%ld", assoCountNumber];
    NSString*  assoImg = [[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_pic"];
        NSString* assoName = [[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_name"];
    self.lbl_AssoWithTime.text = [NSString stringWithFormat:@"%@ + %@ \uA789 %@ ",assoName,assoNumbers,[NSString setUpdateTimewithString:[dic valueForKey:@"date_of_creation"]]];
        [self.img_association sd_setImageWithURL:[NSURL URLWithString:assoImg]
                              placeholderImage:[UIImage imageNamed:@"image-loader.png"]
                                       options:SDWebImageRefreshCached];
   // }
    
    //            _assoLabel.text = @" Everyone \uA789";
    //            _feedTypeImageView.image = [UIImage imageNamed:@"globe.png"];
//}

//        self.img_association.image = [UIImage imageNamed:@"globe.png"];
//        self.lbl_AssoWithTime.text = [NSString stringWithFormat:@"Everyone \uA789 %@ ",[NSString setUpdateTimewithString:[dic valueForKey:@"date_of_creation"]]];
    }else {
        [self.img_association sd_setImageWithURL:[NSURL URLWithString:[[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_pic"]] placeholderImage:[UIImage imageNamed:@"globe.png"] options:SDWebImageRefreshCached];
        self.lbl_AssoWithTime.text = [NSString stringWithFormat:@"%@ \uA789 %@ ",[[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_name"],[NSString setUpdateTimewithString:[dic valueForKey:@"date_of_creation"]]];
    }
    [self setupImageView:self.img_association];
}

- (IBAction)didPressLikeBtn:(UIButton*)sender{
    CGPoint center= sender.center;
    [self.delegate didPressLikeBtn:sender atPoint:center];
}

- (IBAction)didPressCommentBtn:(UIButton*)sender{
    CGPoint center= sender.center;
    [self.delegate didPressCommentBtn:sender atPoint:center];    
}

- (IBAction)didPressShareBtn:(UIButton*)sender{
     CGPoint center= sender.center;
    [self.delegate didPressShareBtn:sender atPoint:center];
}

- (IBAction)didPressActionFeedBtn:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressFeedAction:sender atPoint:center];
}

#pragma mark Setup Single ImageView
-(void)setupSingleImageView:(NSMutableArray*)data{
    self.img_single.hidden = false;
    [self setupImageView:self.img_single];
    [self.img_single sd_setImageWithURL:[data objectAtIndex:0][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
}

#pragma mark Setup Two ImageView
-(void)setupDoubleImageView:(NSMutableArray*)data{
    self.view_2imgholder.hidden = false;
    [self setupImageViewHolder:self.view_2imgholder];
    [self.img_first_v2 sd_setImageWithURL:[data objectAtIndex:0][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_second_v2 sd_setImageWithURL:[data objectAtIndex:1][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
}

#pragma mark Setup Three ImageView
-(void)setupThreeImageView:(NSMutableArray*)data{

    [self setupImageViewHolder:self.view_3imgholder];
    self.view_3imgholder.hidden = false;
    [self.img_first_v3 sd_setImageWithURL:[data objectAtIndex:0][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_second_v3 sd_setImageWithURL:[data objectAtIndex:1][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_third_v3 sd_setImageWithURL:[data objectAtIndex:2][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
}

#pragma mark Setup Four ImageView
-(void)setupFourImageView:(NSMutableArray*)data{

    [self setupImageViewHolder:self.view_4imgholder];
    self.view_4imgholder.hidden = false;
    self.btn_moreImage.hidden = true;
//    self.btn_moreImage.hidden = false;
//    NSInteger totalImg = data.count;
//    NSString *moreImg = [NSString stringWithFormat:@"+%ld",totalImg - 3];
//    [self.btn_moreImage setTitle:moreImg forState:UIControlStateNormal];
//    self.btn_moreImage.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.65];
    [self.img_first_v4 sd_setImageWithURL:[data objectAtIndex:0][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_second_v4 sd_setImageWithURL:[data objectAtIndex:1][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_third_v4 sd_setImageWithURL:[data objectAtIndex:2][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_forth_v4 sd_setImageWithURL:[data objectAtIndex:3][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
}

#pragma mark Setup MoreImageView
-(void)setupMoreImageView:(NSMutableArray*)data{
    [self setupImageViewHolder:self.view_4imgholder];
    self.view_4imgholder.hidden = false;
    self.btn_moreImage.hidden = false;
    NSInteger totalImg = data.count;
    NSString *moreImg = [NSString stringWithFormat:@"+%ld",totalImg - 3];
    [self.btn_moreImage setTitle:moreImg forState:UIControlStateNormal];
    self.btn_moreImage.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.65];
    [self.btn_moreImage setTitle:moreImg forState:UIControlStateNormal];
    [self.img_first_v4 sd_setImageWithURL:[data objectAtIndex:0][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_second_v4 sd_setImageWithURL:[data objectAtIndex:1][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_third_v4 sd_setImageWithURL:[data objectAtIndex:2][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    [self.img_forth_v4 sd_setImageWithURL:[data objectAtIndex:3][@"multiple_file_url"] placeholderImage:kfeedImgPlaceholder];
    
}

-(void)setupGestureOnImageView:(UIImageView*)imageView{

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tap];
}

#pragma mark - Setup Like Comment View
-(void)setupLikeCommentView:(NSMutableDictionary *)dic{
    [self resetConstraintsForLikeview];
    NSString *totalFLike = [dic valueForKey:@"total_like"];
    NSString *totalFComment = [dic valueForKey:@"total_comments"];
    if(totalFLike.integerValue >0){
        self.lbl_FeedLikeCount.text =  [totalFLike integerValue] > 1?[NSString stringWithFormat:@"%@ Doctors like this",totalFLike ]:[totalFLike integerValue] == 1?[NSString stringWithFormat:@"%@ Doctor like this",totalFLike]:@"";
        
        self.lbl_FeedCommentCount.text =  [totalFComment integerValue] > 1?[NSString stringWithFormat:@"%@ comments",totalFComment ]:[totalFComment integerValue] == 1?[NSString stringWithFormat:@"%@ comment",totalFComment]:@"";
        
    }else if(totalFComment.integerValue <= 0){
        self.likeCountBottomConstraints.constant = 0;
        self.likeCountHeightConstraints.constant = 10;
        self.commentCountBottomConstraints.constant = 0;
        self.commentCountHeightConstraints.constant = 10;
        self.lbl_FeedLikeCount.text = @"";
        self.lbl_FeedCommentCount.text = @"";
     }
     if(totalFComment.integerValue >0 && totalFLike.integerValue <= 0){
         self.lbl_FeedLikeCount.text =  [totalFComment integerValue] > 1?[NSString stringWithFormat:@"%@ comments",totalFComment ]:[totalFComment integerValue] == 1?[NSString stringWithFormat:@"%@ comment",totalFComment]:@"";
        
        self.lbl_FeedCommentCount.text = @"";
    }
     if([[dic valueForKey:@"like_status"]isEqualToString:@"0"]){
        self.btn_like.selected = false;
    }else if([[dic valueForKey:@"like_status"]isEqualToString:@"1"]){
        self.btn_like.selected = true;
    }
 }

#pragma mark - Reset Constraints For Likeview
-(void)resetConstraintsForLikeview {
    self.likeCountBottomConstraints.constant = 0;
    self.likeCountHeightConstraints.constant = 38.5;
    self.commentCountBottomConstraints.constant = 0;
    self.commentCountHeightConstraints.constant = 38.5;

}

#pragma mark - Hide All ImageHolder

-(void)hideAllTheImageHolder{
    self.img_single.hidden      = true;
    self.view_2imgholder.hidden = true;
    self.view_3imgholder.hidden = true;
    self.view_4imgholder.hidden = true;
}

#pragma mark - setup Image View

-(void)setupImageViewHolder:(UIView*)imageViewHolder {
    for(UIView *subview in imageViewHolder.subviews){
        if([subview isKindOfClass:[UIImageView class]]){
            [self setupImageView:(UIImageView*)subview];
        }
    }
}
-(void)setupImageView:(UIImageView*)imageView {
    [self setupGestureOnImageView:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = true;
    imageView.layer.borderColor = kBorderLayerColor ;
    imageView.layer.borderWidth = 0.7f;
}

-(void)setupTags:(NSMutableDictionary*)data{
    self.specArray  =[[NSMutableArray alloc]init];
    NSMutableArray *specArr = [data valueForKey:@"speciality"];
    if(specArr != nil){
        self.specArray = specArr;
    }
    
}

-(void)tapImage:(UITapGestureRecognizer *)tap{
//    [self.delegate imgviewTapped:(UIImageView*)tap.view];
    CGPoint center= tap.view.center;
    [self.delegate imgviewTapped:(UIImageView*)tap.view atPoint:center];
}

-(void)tapVideo:(UITapGestureRecognizer *)tap{
    [self.delegate playVideoByURL:self.videoURLToPlay];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self.delegate clickedUrl:[NSString stringWithFormat:@"%@",url]];
}

@end
