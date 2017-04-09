//
//  LPPopupListViewCell.m
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Luka Penger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPPopupListViewCell.h"


#define rightImageViewWidth 44.0f
#define leftImageViewWidth 30.0f
#define countryCodeWidth 44.0f
#define topMargin 12.0f

@implementation LPPopupListViewCell

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        self.rightImageView = [UIImageView new];
        self.lableTitle = [UILabel new];
        self.leftImageView = [UIImageView new];
 //       self.lblCountryCode = [UILabel new];
        [self addSubview:self.rightImageView];
        [self addSubview:self.lableTitle];
        [self addSubview:self.leftImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftImageView.frame = CGRectMake(topMargin, topMargin, leftImageViewWidth, leftImageViewWidth);
    self.lableTitle.frame = CGRectMake(self.leftImageView.frame.origin.x + leftImageViewWidth + 10, topMargin, self.frame.size.width -(self.leftImageView.frame.origin.x + leftImageViewWidth + 10) , leftImageViewWidth);
    

//    self.textLabel.frame = CGRectOffset(self.textLabel.frame, 6, 0);
    
//    self.rightImageView.frame = CGRectMake((self.frame.size.width - rightImageViewWidth), 0.0f, rightImageViewWidth, self.frame.size.height);
//    self.lblCountryCode.frame = CGRectMake((self.frame.size.width - countryCodeWidth), 0.0f, countryCodeWidth, self.frame.size.height);
//    if (self.rightImageView.image) {
//        CGRect textLabelFrame = self.textLabel.frame;
//        textLabelFrame.size.width -= (16.0f * [[UIScreen mainScreen] scale]);
//        self.textLabel.frame = textLabelFrame;
//    }
//    
//    if (self.lblCountryCode.text.length) {
//        CGRect textLabelFrame = self.textLabel.frame;
//        textLabelFrame.size.width -= (16.0f * [[UIScreen mainScreen] scale]);
//        self.textLabel.frame = textLabelFrame;
//    }
    
    self.lableTitle.textColor = [UIColor blackColor];
    self.lableTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    self.leftImageView.layer.cornerRadius = leftImageViewWidth/2;
    self.leftImageView.layer.borderColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0].CGColor;
    self.leftImageView.layer.borderWidth = 0.5;
    self.leftImageView.layer.masksToBounds = YES;
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self selection:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    [self selection:highlighted];
}

- (void)selection:(BOOL)select
{
    if (select) {
        self.backgroundColor = self.highlightColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
