/*============================================================================
 PROJECT: Docquity
 FILE:    Utils.m
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 02/10/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "Utils.h"


#import "QuartzCore/QuartzCore.h"
#import <MessageUI/MessageUI.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppSettings.h"
#import <EventKit/EventKit.h>
#import "AppDelegate.h"
#import "DefineAndConstants.h"

SystemSoundID click2SoundId;
SystemSoundID clickSoundId;
SystemSoundID pageflipSoundId;
SystemSoundID chimemelodySoundId;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@interface Utils ()

+(void) playSoundForSoundId:(SystemSoundID) soundId;
@end

@implementation Utils

+(void)doAppInitialization
{
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    BOOL isInitialAppSetupDone = [userPref boolForKey:@"isInitialAppSetupDone"];
    if (NO == isInitialAppSetupDone) {
        
        //Set the Default Reminder Settings
        [userPref setBool:NO forKey:@"firstTimeLogin"];
        [userPref setBool:NO forKey:@"userSignOut"];
        
        [userPref setBool:NO forKey:signInnormal];
        [userPref setObject:@"" forKey:useremail1];
        [userPref setObject:@"" forKey:password1];

        //Mark that initialAppSetup has been done
        [userPref setBool:YES forKey:@"isInitialAppSetupDone"];
        [userPref synchronize];
    }
}

+(void) addShadowToView:(UIView *) view
{
    view.layer.shadowColor = [[UIColor whiteColor] CGColor];
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 0.6;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.masksToBounds = NO;
}

void shiftUIView(UIView *view,CGFloat x, CGFloat y)
{
    view.frame = CGRectOffset(view.frame, x, y);
}

+(CGFloat) adaptUILabel:(UILabel *) lbl forText:(NSString *) text
{
    CGFloat changeInHeight = 0;
    lbl.text = text;
    if ((nil == text) || (0 == text.length)) { //Text is empty
        
        if (NO == lbl.hidden) {//View is not already hidden
            changeInHeight -= CGRectGetHeight(lbl.frame);
        }
        //hide the detail label
        lbl.hidden = YES;
    }else{ //Text is nonEmpty
        
        if (YES == lbl.hidden) { //View was hidden
            changeInHeight += CGRectGetHeight(lbl.frame);
        }
        
        //View should be Visible
        lbl.hidden = NO;
        
        //Adapting View according to its content
        CGRect frameBefore = lbl.frame;
        [lbl sizeToFit];
        //Maintain the Width so that it wont change
        CGRect frame = lbl.frame;
        frame.size.width = frameBefore.size.width;
        lbl.frame = frame;
        CGRect frameAfter = lbl.frame;
        changeInHeight += frameAfter.size.height - frameBefore.size.height;
    }
    return changeInHeight;
}

+(CGFloat) adaptView:(UIView *) view forUrl:(NSURL *) url
{
    CGFloat changeInHeight = 0;
    //URL validation
    BOOL urlValid = NO;
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        urlValid = YES;
    }
    //Adapting the View
    if (NO == urlValid) { //Invalid URL
        
        if (view.hidden == NO) { //View should hide
            changeInHeight -= view.frame.size.height;
        }
        
        view.hidden = YES;
    }else{ //Valid URL
        
        if (view.hidden == YES) { //View should be visible
            changeInHeight += view.frame.size.height;
        }
         view.hidden = NO;
    }
    return changeInHeight;
}

+(CGFloat) adaptView:(UIView *) view forEmailAddress:(NSString *) emailAddStr
{
    CGFloat changeInHeight = 0;
    
    //Email validation
    //http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
    BOOL emailValid = YES;
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailAddStr options:0 range:NSMakeRange(0, [emailAddStr length])];
    if (regExMatches != 1) {
        emailValid = NO;
    }
    
    //Adapting the View
    if (NO == emailValid) { //Invalid URL
        
        if (view.hidden == NO) { //View should hide
            changeInHeight -= view.frame.size.height;
        }
        
        view.hidden = YES;
    }else{ //Valid URL
        
        if (view.hidden == YES) { //View should be visible
            changeInHeight += view.frame.size.height;
        }
        
        view.hidden = NO;
    }
    return changeInHeight;
}

+(void) playClick2Sound
{
    if (0 == click2SoundId) {
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"iphonenotification" withExtension:@"mp3"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)path,&click2SoundId);
        //DLog(@"click2SoundId initialized");
    }
    [self playSoundForSoundId:click2SoundId];
}

+(void) playClickSound
{
    if (0 == clickSoundId) {
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)path,&clickSoundId);
        
       // DLog(@"clickSoundId initialized");
    }
    [self playSoundForSoundId:clickSoundId];
}

+(void) playPageFlipSound
{
    if (0 == pageflipSoundId) {
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"pageflip" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)path,&pageflipSoundId);
        
        //DLog(@"pageflipSoundId initialized");
    }
    [self playSoundForSoundId:pageflipSoundId];
}

+(void) playChimeMelodySound
{
    if (0 == chimemelodySoundId) {
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"chimemelody" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)path,&chimemelodySoundId);
        
       // DLog(@"chimemelodySoundId initialized");
    }
    
    [self playSoundForSoundId:chimemelodySoundId];
}

+(void) playSoundForSoundId:(SystemSoundID) soundId
{
    if ([AppSettings soundOn]) {
        AudioServicesPlaySystemSound(soundId);
    }
}

+(CGRect) getRectForImageInImageView:(UIImageView *) iv
{
    CGRect imageFrame = iv.bounds;
    if (iv.contentMode == UIViewContentModeScaleAspectFit) {
        
        //Code COPY-PASTE from stackoverflow.com
        CGSize imageSize = iv.image.size;
        CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
        CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
        imageFrame = CGRectMake(floorf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), floorf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height);
    }
    
    return imageFrame;
}

+(void) adaptPicShadow:(UIImageView *) picShadowImgView forPic:(UIImageView *) picImgView
{
    CGRect rect = [self getRectForImageInImageView:picImgView];
    //Adjusting width and position of shadow
    CGRect frame = picShadowImgView.frame;
    frame.size.width = rect.size.width;
    frame.origin.y = CGRectGetMaxY(rect) + picImgView.frame.origin.y;
    frame.origin.x = CGRectGetMinX(rect) + picImgView.frame.origin.x;
    picShadowImgView.frame = frame;
}

+(NSDate *) parseDateFromString:(NSString *) dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:dateStr];
}

+(UIImage *)image:(UIImage *) img rotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,img.size.width, img.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-img.size.width / 2, -img.size.height / 2, img.size.width, img.size.height), [img CGImage]);
    
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
