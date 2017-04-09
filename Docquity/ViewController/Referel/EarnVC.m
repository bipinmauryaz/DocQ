//
//  EarnVC.m
//  Docquity
//
//  Created by Arimardan Singh on 06/04/17.
//  Copyright © 2017 Docquity. All rights reserved.
//

#import "EarnVC.h"
#import "WebVC.h"
#import "SVPullToRefresh.h"
#import "NSString+HTML.h"

@interface EarnVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *userPointsListArray;
    int earnPointpageCount; //page number/number of cells visble to user now
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_totalPoints;

@end

@implementation EarnVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // userPointsListArray=[[NSMutableArray alloc]initWithObjects:@"point",@"point",@"point",@"point",@"point", nil];
    // Do any additional setup after loading the view.
      userPointsListArray = [[NSMutableArray alloc]init];
    earnPointpageCount = 1; //initial state of page that control should start 0 to limit 10
    __weak EarnVC *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf serviceHitForGetPointDetailsList];
    }
                                             position:SVPullToRefreshPositionBottom];
    [self serviceHitForGetPointDetailsList];
    //
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
     self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor = [UIColor whiteColor];
    // dispatch_async(dispatch_get_main_queue(), ^{
    // [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.title = @"Earn Points";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    
    //[UIColor whiteColor];
    
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"button.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //        [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
    //                                                                          [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
    //                                                                          [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    
    // });
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden=NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)remindAction:(UIButton*)sender {
}

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userPointsListArray count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // static NSString *indentifier=@"CellRemind";
    
    static NSString *indentifier1=@"CellPoints";
    UITableViewCell *cell;
    cell= [tableView dequeueReusableCellWithIdentifier:indentifier1];
    NSString *str=[userPointsListArray objectAtIndex:indexPath.row];
    UILabel *nameLbl=(UILabel*)[cell viewWithTag:101];
    UILabel *pointsLbl=(UILabel*)[cell viewWithTag:103];
    UILabel *timeLbl=(UILabel*)[cell viewWithTag:104];
    
    if([userPointsListArray count]>0)
    {
        NSString *user_name =nil;
        NSString*user_points = nil;
        if([userPointsListArray objectAtIndex:indexPath.row]){
            NSDictionary*pointsDetailDict = [userPointsListArray objectAtIndex:indexPath.row];
            if(pointsDetailDict  && [pointsDetailDict isKindOfClass:[NSDictionary class]])
            {
                user_name = [NSString stringWithFormat:@"%@",[pointsDetailDict objectForKey:@"name"]?[pointsDetailDict  objectForKey:@"name"]:@""];
                
                user_points = [NSString stringWithFormat:@"%@", [pointsDetailDict objectForKey:@"point"]?[pointsDetailDict  objectForKey:@"point"]:@""];
                nameLbl.text = [user_name capitalizedString];
                pointsLbl.text =  user_points;
            }
        }
    }
    /*
     if ([str isEqualToString:@"remind"]) {
     cell= [tableView dequeueReusableCellWithIdentifier:indentifier];
     UILabel *nameLbl=(UILabel*)[cell viewWithTag:101];
     UIImageView *imageView=(UIImageView*)[cell viewWithTag:100];
     UIButton *remindBtn=(UIButton*)[cell viewWithTag:102];
     
     remindBtn.tag=indexPath.section;
     remindBtn.layer.borderWidth=1.0f;
     remindBtn.layer.borderColor=[UIColor colorWithRed:51/255.0 green:182/255.0 blue:118/255.0 alpha:1.0f].CGColor;
     remindBtn.layer.masksToBounds=YES;
     //    [qtyBtn setTitle:[NSString stringWithFormat:@"%d",[Allprocuct.p_qty intValue]] forState:UIControlStateNormal];
     [remindBtn addTarget:self
     action:@selector(remindAction:)
     forControlEvents:UIControlEventTouchUpInside];
     }
     */
    // else{
    
    // }
    return cell;
}

#pragma mark - GetPointDetailsListRequest
-(void)serviceHitForGetPointDetailsList{
    NSString *pagestring = [NSString stringWithFormat:@"%d",earnPointpageCount];
    if ([pagestring isEqualToString:@"1"]) {
        [WebServiceCall showHUD];
    }
    
    [WebServiceCall callServiceGETWithName:[NSString stringWithFormat:@"%@registration/get.php?rquest=referal_point_list&version=%@limit=%@&offset=%@&iso_code=%@&lang=%@",NewWebUrl,kApiVersion,@"10",pagestring,@"",kLanguage] withHeader:AuthorizationAppKey postData:nil callBackBlock:^(id response, NSError *error)
     {
         if (response) {
             [self.tableView.pullToRefreshView stopAnimating];
             self.tableView.tableFooterView = nil;
             [SVProgressHUD dismiss];
             NSError *errorJson=nil;
             NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
             if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 1)
             {
                 NSDictionary *datadic =[responseDict valueForKeyPath:@"posts.data"];
                 if ([datadic isKindOfClass:[NSNull class]]||datadic == nil)
                 {
                     // tel is null
                 }
                 else {
                     urlpointLink = [[[datadic valueForKey:@"point_link"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
                     total_point = [datadic valueForKey:@"total_point"];
                     _lbl_totalPoints.text = total_point;
                     NSMutableArray *temparr = [[NSMutableArray alloc]init];
                     temparr= [[datadic objectForKey:@"referal_point_list"] mutableCopy];
                     if ([temparr count]==0) {
                         [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
                         self.tableView.hidden = YES;
                     }
                     else {
                         if([temparr count] && [temparr isKindOfClass:[NSMutableArray class]])
                         {
                             //more data found
                             for(int i=0; i<[temparr count]; i++){
                                 NSDictionary *userpointsListInfo = temparr[i];
                                 if (userpointsListInfo != nil && [userpointsListInfo isKindOfClass:[NSDictionary class]]) {
                                 }
                                 [userPointsListArray addObject:userpointsListInfo];
                             }
                             [self.tableView reloadData];
                             earnPointpageCount++;
                         }
                     }
                 }
                 
                 //  userPointsListArray = [NSMutableArray arrayWithArray:[responseDict valueForKeyPath:@"posts.data.referal_point_list"]];
                 
                 
                 //               if (userPointsListArray .count==0)
                 //             {
                 //                 [WebServiceCall showAlert:AppName andMessage:defaultErrorMsg withController:self];
                 //             }
                 // [self.tableView reloadData];
             }
             else if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 7)
             {
                 [self.tableView setShowsPullToRefresh:NO];
             }
             else  if([[responseDict valueForKeyPath:@"posts.status"] integerValue] == 9)
             {
                 [[AppDelegate appDelegate]logOut];
             }
         }
         else if (error)
         {
             [SVProgressHUD dismiss];
             [WebServiceCall showAlert:AppName andMessage:[error localizedDescription] withController:self];
             NSLog(@"%@",error);
         }
     }];
}

#pragma mark - terms and Btn click
- (IBAction)UserPointsBtnClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebVC *webvw  = [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    if(![AppDelegate appDelegate].isInternet){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    webvw.documentTitle = urlpointLink;
    webvw.fullURL = urlpointLink;
    [self presentViewController:webvw animated:YES completion:nil];
}

@end
