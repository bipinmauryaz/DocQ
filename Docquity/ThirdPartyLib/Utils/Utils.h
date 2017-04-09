/*============================================================================
 PROJECT: Docquity
 FILE:    Utils.h
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 02/10/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Utils : NSObject

+(void)doAppInitialization;

+(void) addShadowToView:(UIView *) view;
void shiftUIView(UIView *view,CGFloat x, CGFloat y);
+(CGFloat) adaptUILabel:(UILabel *) lbl forText:(NSString *) text;
+(CGFloat) adaptView:(UIView *) view forUrl:(NSURL *) url;
+(CGFloat) adaptView:(UIView *) view forEmailAddress:(NSString *) emailAddStr;

+(void) playClick2Sound;
+(void) playClickSound;
+(void) playPageFlipSound;
+(void) playChimeMelodySound;

+(CGRect) getRectForImageInImageView:(UIImageView *) iv;
+(void) adaptPicShadow:(UIImageView *) picShadowImgView forPic:(UIImageView *) picImgView;

+(NSDate *) parseDateFromString:(NSString *) dateStr;

+(UIImage *)image:(UIImage *) img rotatedByDegrees:(CGFloat)degrees;
@end
