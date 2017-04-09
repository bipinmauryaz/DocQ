/*============================================================================
 PROJECT: Docquity
 FILE:    SpecialityPickerVC.h
 AUTHOR:  Copyright © 2017 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 07/02/17.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <UIKit/UIKit.h>


/*============================================================================
 Interface: SpecialityPickerVC 
 =============================================================================*/
@interface SpecialityPickerVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *selectedIndexes;
    NSMutableArray *specialityNameArrData;
    NSMutableArray *specialityIdArrData;
    
    IBOutlet UIImageView*crossImg;
    IBOutlet UIImageView *searchLensImg;
    IBOutlet UITextField *searchNameTF;
   
    NSMutableArray *filteredContentList;
    NSMutableArray *selectedContentList;
    NSMutableArray *selectedSpecilityList;
    BOOL isSearching;
    BOOL isContactAdd;
    NSMutableArray *resultArray;
}

@property (nonatomic,assign)id delegate;
@property (nonatomic,strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) IBOutlet UITextField *searchNameTF;
@property (nonatomic, strong) NSString *searchingString;
@property (nonatomic, strong) NSMutableArray *specialityListArr;

@end

@protocol selectSpeicality <NSObject>
-(void)selectedSpecialityName:(NSMutableArray*)SpecialityNameArry specialityID:(NSMutableArray*)specialityIdArr;
//-(void)selectedSpecialityName:(NSString*)Name specialityID:(NSString*)specialityId;
-(void)selectedSpecialityName:(NSMutableArray*)Name specialityID:(NSMutableArray*)specialityId spacialityArray:(NSMutableArray*)specMainArr;
@end



