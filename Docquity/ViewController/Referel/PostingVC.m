//
//  PostingVC.m
//  Docquity
//
//  Created by Arimardan Singh on 06/04/17.
//  Copyright © 2017 Docquity. All rights reserved.

#import "PostingVC.h"
#import  "QuartzCore/QuartzCore.h"

@interface PostingVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PostingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
    _arr_postingTypeImages = [[NSMutableArray alloc]init];
    _arr_PpstingTypesTitles = [[NSMutableArray alloc]init];
    
    _arr_PpstingTypesTitles = [[NSMutableArray alloc]initWithObjects:@"Medical Case",@"Question",@"Trend",@"Pool Audience",nil];
    
 _arr_postingTypeImages =[[NSMutableArray alloc]initWithObjects:@"MedicalCases.png",@"Question.png",@"TrendsImage.png",@"PoolAudiance.png",nil];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden=NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marl - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arr_PpstingTypesTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    else{
        return 15;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *identifier=@"Cell";
//    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell== nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        UILabel *postingTypeLbl=(UILabel*)[cell viewWithTag:101];
//        postingTypeLbl.text=[_arr_PpstingTypesTitles objectAtIndex:indexPath.row];
//        
//        UIImageView *imageView=(UIImageView*)[cell viewWithTag:100];
//        imageView.image = [UIImage imageNamed:[_arr_postingTypeImages objectAtIndex:indexPath.row]];
//         }
//    
//    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    static NSString *cellIdentifier = @"Cell";
    UILabel *postingTypeLbl  = nil;
    UIImageView  *postingTypeImage = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        tableView.separatorStyle=   UITableViewCellSeparatorStyleSingleLine;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [tableView setSeparatorColor:[UIColor lightGrayColor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    //Get Photo ImageViww
    if (postingTypeImage == nil) {
        postingTypeImage = (UIImageView*)[cell viewWithTag:100];;
    }
    
    //Get User Name Label
    if (postingTypeLbl == nil) {
        postingTypeLbl = (UILabel*)[cell viewWithTag:101];
    }
    
    postingTypeLbl.text=[_arr_PpstingTypesTitles objectAtIndex:indexPath.section];
   postingTypeImage.image = [UIImage imageNamed:[_arr_postingTypeImages objectAtIndex:indexPath.section]];
    
    CALayer *layer = cell.layer;
    [layer setMasksToBounds:YES];
   // [layer setCornerRadius: 4.0];
    [layer setBorderWidth:0.5];
    [layer setBorderColor:[[UIColor colorWithWhite: 0.8 alpha: 1.0] CGColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    headerView.backgroundColor=[UIColor clearColor];
    return headerView;
}

@end
