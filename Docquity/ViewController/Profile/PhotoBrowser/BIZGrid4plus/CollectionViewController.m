//
//  CollectionViewController.m
//  ExampleBIZCollectionViewLayout4plus1Grid
//
//  Created by IgorBizi@mail.ru on 12/11/15.
//  Copyright © 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "CollectionViewController.h"
#import "ImageCollectionViewCell.h"
#import "BIZGrid4plus1CollectionViewLayout.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowser.h"
#import "SDCollectionViewDemoCell.h"
#import "SVPullToRefresh.h"
#import "UINavigationBar+ZZHelper.h"
@interface CollectionViewController ()<SDPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *modelsArray;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UICollectionReusableView *theView;

@end


@implementation CollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    limit = @"20";
    offset = 1;
    
    [self getTimelinePhotoRequestWithCustId:self.custmid];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    [self.collectionView addSubview:self.spinner];
    
    __weak CollectionViewController *weakSelf = self;
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf refresh];
    }position:SVPullToRefreshPositionBottom];
    [self.collectionView setShowsPullToRefresh:YES];
}

- (void)refresh {
    // Do refresh stuff here
  //  NSLog(@"// Do refresh stuff here");
    [self getTimelinePhotoRequestWithCustId:self.custmid];
}

-(void)viewWillAppear:(BOOL)animated{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIColor *color    = kThemeColor;
//    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Photos",self.userName];
    self.navigationItem.title = [NSString stringWithFormat:@"Photos"];
    
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
     [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.barTintColor = color;
     [self setBackButton];
}

-(void)setBackButton{
    
   // NSLog(@"setBackButton");
    UIBarButtonItem *backButton;
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(GoToBackView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

-(void)GoToBackView{
   // NSLog(@"GoToBackView");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar zz_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[self.dataSource objectAtIndex:indexPath.row][@"file_url"]] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRefreshCached];
    
   // cell.imageView.image = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = indexPath.item;
    photoBrowser.imageCount = self.modelsArray.count;
    photoBrowser.sourceImagesContainerView = self.collectionView;
    [photoBrowser show];
}

#pragma mark  SDPhotoBrowserDelegate
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    SDCollectionViewDemoCell *cell = (SDCollectionViewDemoCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
     return cell.imageView.image;
 }

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = [[self.modelsArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}

#pragma mark - get userTimeLinePhotoRequest
-(void)getTimelinePhotoRequestWithCustId:(NSString*)custid{
    
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    [[DocquityServerEngine sharedInstance]getUserTimeLinePhotoRequestWithAuthKey:[userPref valueForKey:userAuthKey] custom_id:custid limit:limit offset:[NSString stringWithFormat:@"%ld",(long)offset] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error) {
       // NSLog(@"responseObject for get user Time line photo profile:%@ for offset %ld",responseObject,(long)offset);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
        if(error){
            if (error.code == NSURLErrorTimedOut) {
                
                [self singleButtonAlertViewWithAlertTitle:InternetSlow message:defaultErrorMsg buttonTitle:OK_STRING];
                // time out error here
                
            } else {
                 [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
            }
        }else {
            
            NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
            if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil) {
                [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                
            } else {
                if([[resposeDic valueForKey:@"status"]integerValue] == 1) {
                    NSMutableDictionary *dataDic=[resposeDic objectForKey:@"data"];
                    if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                    {
                        // tel is null
                        
                    } else {
                        NSMutableArray*timeline_PhotoArr = [[NSMutableArray alloc]init];
                        timeline_PhotoArr =[dataDic objectForKey:@"timeline_photo"];
                        if(self.dataSource == nil){
                            self.dataSource  = [[NSMutableArray alloc]init];
                        }
                        [self.dataSource addObjectsFromArray:timeline_PhotoArr];
                        NSMutableArray *temp = [NSMutableArray new];
                        for(NSMutableDictionary *photoDic in self.dataSource)
                        {
                            SDPhotoItem *item = [SDPhotoItem new];
                            item.thumbnail_pic = [photoDic valueForKey:@"file_url"];
                            [temp addObject:item];
                        }
                        self.modelsArray = [temp copy];
                        [self.spinner removeFromSuperview];
                        [self.collectionView reloadData];
                        offset ++ ;
                        [self.collectionView.pullToRefreshView stopAnimating];
                     }
                }
                else if([[resposeDic valueForKey:@"status"]integerValue] == 7)
                {
                    [self.collectionView setShowsPullToRefresh:false];
                }
                else if([[resposeDic valueForKey:@"status"]integerValue] == 9)
                {
                    [[AppDelegate appDelegate] logOut];
                } else  if([[resposeDic valueForKey:@"status"]integerValue] == 11)
                {
                    
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 5)
                {
                    [[AppDelegate appDelegate]ShowPopupScreen];
                } else if([[resposeDic valueForKey:@"status"]integerValue] == 0)
                {
                   [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
                }
            }
        }
    }];
}


#pragma mark - single button Alertview
-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
