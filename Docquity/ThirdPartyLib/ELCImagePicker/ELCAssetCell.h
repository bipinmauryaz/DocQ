//
//  AssetCell.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ELCAssetCell : UITableViewCell

@property (nonatomic, assign) BOOL alignmentLeft;
@property (nonatomic, assign) CGFloat itemPadding;//Ashutosh Change
@property (nonatomic, assign) NSInteger numberOfColumns;//Ashutosh Change

- (void)setAssets:(NSArray *)assets;
@end
