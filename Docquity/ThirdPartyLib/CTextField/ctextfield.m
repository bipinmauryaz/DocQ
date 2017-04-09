/*============================================================================
 PROJECT: Docquity
 FILE:    Cctextfield.m
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 30/04/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "ctextfield.h"
#import "Font.h"
@implementation ctextfield

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    
    //[[UIColor darkGrayColor] setFill];
   // [[UIColor colorWithRed:197.0/255.0 green:199.0/255.0 blue:203.0/255.0 alpha:1] setFill];
    
    [[UIColor colorWithRed:184.0/255.0 green:184.0/255.0 blue:184.0/255.0 alpha:1] setFill];
    
   // CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);

    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);
    [[self placeholder] drawInRect:placeholderRect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
