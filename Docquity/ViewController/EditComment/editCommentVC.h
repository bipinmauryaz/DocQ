/*============================================================================
 PROJECT: Docquity
 FILE:    editCommentVC.h
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 21/02/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import <UIKit/UIKit.h>
#import "Server.h"

@protocol editCommentDelegate <NSObject>
-(void)editComment:(NSString*)comment feedComID:(NSString*)comID;
-(void)editCommentReplyText:(NSString*)comment;
@end

/*============================================================================
 Interface: editCommentVC
 =============================================================================*/
@interface editCommentVC : UIViewController<UITextViewDelegate,ServerRequestFinishedProtocol>{
    NSMutableString *dataPath;
    ServerRequestType1 currentRequestType;
}

@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (strong, nonatomic) IBOutlet UIButton *BtnUpdate;
@property (strong, nonatomic) IBOutlet UITextView *ContentTV;
@property (strong, nonatomic) IBOutlet UIImageView *ImgUser;
@property (nonatomic,strong)NSString *commentText;
@property (nonatomic,strong)NSString *FeedID;
@property (nonatomic,strong)NSString *commentID;
@property (nonatomic,strong)NSString *commentReplyID;
@property (nonatomic,strong)NSString *Action;

- (IBAction)didPressUpdate:(id)sender;
- (IBAction)didPressCancel:(id)sender;

@property (nonatomic,strong)UIImage *userImg;
@property (nonatomic,assign)id delegate;
@end
