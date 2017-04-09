//
//  RepliesVC.h
//  Docquity
//
//  Created by Docquity-iOS on 28/09/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepliesVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate, UIGestureRecognizerDelegate>
{
    UIBarButtonItem *postbtn;
    UITextView *commentTextView;
    UILabel *placeholder;
    float _previousContentHeight;
    NSInteger offset;
    NSString *limit;
    NSInteger selectedRow;
    NSString *selectedComment;
    BOOL isLike;
    BOOL isDelete;
    BOOL isEdit;

@private
    BOOL keyboardIsVisible;
}

@property (nonatomic,assign) id delegate;
@property (nonatomic, strong)NSMutableArray *replyArray;
@property (nonatomic, strong)NSMutableDictionary *commentDic;
@property (weak, nonatomic) NSString *feedid;
@property (weak, nonatomic) NSString *commentid;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomConstraintsToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeightConstraints;

@end
@protocol replyComment <NSObject>

-(void)replyCommentResponseWitheditedDic:(NSMutableDictionary*)dic anyAction:(BOOL)Flag;

@end