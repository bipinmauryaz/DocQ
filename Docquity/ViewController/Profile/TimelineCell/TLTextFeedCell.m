//
//  TLTextFeedCell.m
//  Docquity
//
//  Created by Docquity-iOS on 02/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "TLTextFeedCell.h"
#import "DefineAndConstants.h"
#import "NSString+GetRelativeTime.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "SpecialityModel.h"

static NSString *kExpansionToken = @"...Read More";
static NSString *kCollapseToken = @"Read Less";

@implementation TLTextFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didPressShareBtn:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressShareBtn:sender atPoint:center];

}

- (IBAction)didPressActionFeedBtn:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressFeedAction:sender atPoint:center];
}

- (IBAction)didPressMetaFeed:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressMetaBtn:sender atPoint:center];
}

- (IBAction)didPressUserName:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressUserBtn:sender atPoint:center];
}

- (IBAction)didPressDocumentView:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressDocumentBtn:sender atPoint:center];

}

- (IBAction)didPressLikeBtn:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressLikeBtn:sender atPoint:center];
   
}

- (IBAction)didPressCommentBtn:(UIButton*)sender {
    CGPoint center= sender.center;
    [self.delegate didPressCommentBtn:sender atPoint:center];

}


#pragma mark - Configure Cell For Row

-(void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath withData:(NSMutableDictionary*)data{
    if([[data valueForKey:@"posted_by"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:ownerCustId]] || [[data valueForKey:@"posted_by"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:userId]] ){
        _isOwnProfile = YES;
    }else{
        _isOwnProfile = NO;
    }
    
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
    
    [self setupTags:data];
    [self setupNormalFeed:data];
    
    if([[data valueForKey:@"file_type"]isEqualToString:kFeedTypeMeta])
    {
        if ([data objectForKey:@"meta_array"]) {
            
            [self setupMetaFeed:data];
        }
    }else if([[data valueForKey:@"file_type"]isEqualToString:kFeedTypeDoc]){
        [self setupDocumentFeed:data];
    }
    
}



#pragma mark - Setup Normal Feed

-(void)setupNormalFeed:(NSMutableDictionary*)data{
    self.btn_FeedAction.hidden = !_isOwnProfile;
    NSString *activityText=  @"";
    activityText = _isOwnProfile?@"Last Activity on :":@"You commented on :";
//    self.lbl_latestActivity.text = [NSString stringWithFormat:@"%@ %@",activityText,[NSString setUpdateTimewithString:[data valueForKey:@"date_of_updation"]]];
    
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
    [self.lbl_feederName setTitle:[[[[data valueForKey:@"name"] stringByDecodingHTMLEntities]stringByDecodingHTMLEntities] capitalizedString] forState:UIControlStateNormal];
    self.lbl_feed_title.text = [[[data valueForKey:@"title"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    
    NSString *content = [[[data valueForKey:@"content"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    self.lbl_desc.text =  content;

    if([[data valueForKey:@"classification"] isEqualToString:@"cme"]){
    
        [self.lbl_desc setText:content afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange clickHereRange = [[mutableAttributedString string] rangeOfString:@"Click here" options:NSCaseInsensitiveSearch];
            
            if (clickHereRange.location != NSNotFound) {
                
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:clickHereRange];
            }
            return mutableAttributedString;
        }];
    }

    NSString *hashString = @"";
    for(NSMutableDictionary *specDic in self.specArray){
        if([hashString isEqualToString:@""]){
            hashString=  [[[NSString stringWithFormat:@"#%@",[specDic valueForKey:@"speciality_name"]] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
        }else{
            hashString = [NSString stringWithFormat:@"%@ #%@",hashString,[[[specDic valueForKey:@"speciality_name"] stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
        }
    }
    self.lbl_hashtag.text = hashString;
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
    if(content.length == 0){
        self.lblDescHeightConstraints.constant = 0;
        self.hashTagBottomConstraints.constant = 0;
        // self.lblDescBottomConstraints.constant = 0;
    }else if(self.lblDescHeightConstraints.constant == 0){
        self.lblDescHeightConstraints.constant = 16;
        self.hashTagBottomConstraints.constant = 6.5;
        // self.lblDescBottomConstraints.constant = 6;
    }

    [self setupLikeCommentView:data];
    [self setupImageView:self.img_feeder];
   
    UITapGestureRecognizer *tapOnuserImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUser:)];
    tapOnuserImg.numberOfTapsRequired = 1;
    [self.img_feeder addGestureRecognizer:tapOnuserImg];

}


#pragma mark - Setup MetaFeed
-(void)setupMetaFeed:(NSMutableDictionary*)data{
    NSString *fulldata = [[[data valueForKey:@"meta_array"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    NSError *jsonError;
    NSData *jsonData = [fulldata dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:kNilOptions
                                                                   error:&jsonError];
    self.lbl_MetaTitle.text = [[[jsonResponse valueForKey:@"title"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    self.lbl_metaUrl.text = [[[jsonResponse valueForKey:@"canonicalUrl"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
     [self.img_MetaThumbnail sd_setImageWithURL:[NSURL URLWithString:[jsonResponse valueForKey:@"images"]] placeholderImage:[UIImage imageNamed:@"img-not.png"] options:SDWebImageRefreshCached];
    [self setupImageView:self.img_MetaThumbnail];
}

#pragma mark - Setup Document View

-(void)setupDocumentFeed:(NSMutableDictionary*)data{
    NSString *type = [[data valueForKey:@"file_name"] pathExtension];
    self.lbl_documentName.text  = [[[[[data valueForKey:@"file_name"] lastPathComponent] stringByDeletingPathExtension]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    //self.lbl_documentName.text = [[[data valueForKey:@"file_name"] stringByDecodingHTMLEntities] stringByDecodingHTMLEntities];
    [self.img_documentView sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"video_image_url"]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_placeholder.png",type]] options:SDWebImageRefreshCached];
    self.img_documentType.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",type]];
    [self setupImageView:self.img_documentView];
}

#pragma mark - Setup Associations
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
        
//        self.img_association.image = [UIImage imageNamed:@"globe.png"];
//        self.lbl_AssoWithTime.text = [NSString stringWithFormat:@"Everyone \uA789 %@ ",[NSString setUpdateTimewithString:[dic valueForKey:@"date_of_creation"]]];
    }
    else {
        [self.img_association sd_setImageWithURL:[NSURL URLWithString:[[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_pic"]] placeholderImage:[UIImage imageNamed:@"globe.png"] options:SDWebImageRefreshCached];
        self.lbl_AssoWithTime.text = [NSString stringWithFormat:@"%@ \uA789 %@ ",[[[dic valueForKey:@"association_list"] objectAtIndex:0] valueForKey:@"association_name"],[NSString setUpdateTimewithString:[dic valueForKey:@"date_of_creation"]]];
    }
    [self setupImageView:self.img_association];
}


#pragma mark - Setup Like Comment View
-(void)setupLikeCommentView:(NSMutableDictionary *)dic{
    [self resetConstraintsForLikeview:dic];
    NSString *totalFLike = [dic valueForKey:@"total_like"];
    NSString *totalFComment = [dic valueForKey:@"total_comments"];
    if(totalFLike.integerValue >0){
        self.lbl_FeedLikeCount.text =  [totalFLike integerValue] > 1?[NSString stringWithFormat:@"%@ Doctors like this",totalFLike ]:[totalFLike integerValue] == 1?[NSString stringWithFormat:@"%@ Doctor like this",totalFLike]:@"";
         self.lbl_FeedCommentCount.text =  [totalFComment integerValue] > 1?[NSString stringWithFormat:@"%@ comments",totalFComment ]:[totalFComment integerValue] == 1?[NSString stringWithFormat:@"%@ comment",totalFComment]:@"";
    }
    else if(totalFComment.integerValue <= 0){
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
-(void)resetConstraintsForLikeview :(NSMutableDictionary *)data{
    
    self.likeCountBottomConstraints.constant = 0;
    
    self.commentCountBottomConstraints.constant = 0;
    
    
    if([[data valueForKey:@"file_type"]isEqualToString:kFeedTypeNormal])
    {
        self.commentCountHeightConstraints.constant = 33;
        self.likeCountHeightConstraints.constant = 33;
    }else{
        self.likeCountHeightConstraints.constant = 38;
        self.commentCountHeightConstraints.constant = 38;
    }

}

#pragma mark - Setup for imageView
-(void)setupImageView:(UIImageView*)imageView {
    
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

-(void)didTapUser:(UITapGestureRecognizer *)tap{
    CGPoint center= tap.view.center;
    [self.delegate didTapUserImage:(UIImageView*)tap.view atPoint:center];
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self.delegate clickedUrl:[NSString stringWithFormat:@"%@",url]];
    
}


@end
