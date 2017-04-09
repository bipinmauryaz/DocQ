//
//  CMEResultVC.h
//  Docquity
//
//  Created by Docquity-iOS on 19/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMEResultVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (nonatomic,strong) NSString *Msg;
@property (nonatomic,strong) NSString *remarks;
@property (nonatomic,strong) NSString *pdfURL;
@property (weak, nonatomic) IBOutlet UIButton *btn_transcript;
@property (nonatomic) BOOL confirmation;
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (strong, nonatomic) NSString *associationid;
@property (strong, nonatomic) NSString *accerediation;
@property (strong, nonatomic) NSString *courseTitle;
@end
