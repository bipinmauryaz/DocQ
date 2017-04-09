//
//  CollectionViewController.h
//  ExampleBIZCollectionViewLayout4plus1Grid
//
//  Created by IgorBizi@mail.ru on 12/11/15.
//  Copyright © 2015 IgorBizi@mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefineAndConstants.h"
#import "DocquityServerEngine.h"
#import "AppDelegate.h"
@interface CollectionViewController : UICollectionViewController {
    NSString *limit;
    NSInteger offset;
    
}
@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSString *custmid;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end
