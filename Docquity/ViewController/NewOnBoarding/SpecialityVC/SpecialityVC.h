//
//  SpecialityVC.h
//  Docquity
//
//  Created by Docquity-iOS on 27/02/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicalSpecialityCell.h"
#import "UserImageUploadVC.h"

@interface SpecialityVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tableViewSpeciality;
    IBOutlet UITextField *tfSearch;
    BOOL isSearching;
    NSString* JabberName;               // Store user jabber Name
    NSString* JabberID;                 // Store user jabber id
    NSString* jabberPassword;           // User jabber password
    NSString* chatId;                   // User chat ID
    NSString* trackId;                  // User track Id
    NSString *mediaPath;                // Store mediapath for profile pic
    NSMutableString *dataPath;          // Store datapath for profile pic folder
    NSString*userPic;                   // Store user Profile pic when we are login
}

@property (nonatomic) NSMutableData *RecvimageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property(strong,nonatomic)NSMutableArray *arraySpeciality;
@property(strong,nonatomic)NSMutableArray *arraySelectedCell;
@property(strong,nonatomic)NSMutableArray *arrFiltered;
@property (weak, nonatomic)IBOutlet UIButton *btnNext;
@property (nonatomic,strong)NSString *registered_userType;
@property (nonatomic,strong)NSDictionary *universityDic;

@end
