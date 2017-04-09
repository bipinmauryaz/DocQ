//
//  SearchAllSpecAssoVC.m
//  Docquity
//
//  Created by Docquity-iOS on 15/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "SearchAllSpecAssoVC.h"
#import "SearchSpecCell.h"
#import "SearchAssociationCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "UIImageView+Letters.h"
@interface SearchAllSpecAssoVC ()

@end

@implementation SearchAllSpecAssoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{

    // Navigation controller background
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

     [self.navigationItem setHidesBackButton:NO animated:YES];
    if([self.dataFor isEqualToString:@"asso"]){
        self.navigationItem.title = [NSString stringWithFormat:@"Association : %@",self.keyword];
    }else if ([self.dataFor isEqualToString:@"spec"]){
        self.navigationItem.title = [NSString stringWithFormat:@"Speciality : %@",self.keyword];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.FinalArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *SpecCellIdentifier = @"AllSpecCell";
    static NSString *AssocCellIdentifier = @"AllAssociationCell";
    UITableViewCell *blankcell;
    
    SearchSpecCell *s_cell = [tableView dequeueReusableCellWithIdentifier:SpecCellIdentifier];
    SearchAssociationCell *a_cell = [tableView dequeueReusableCellWithIdentifier:AssocCellIdentifier];
    
    if([self.dataFor isEqualToString:@"spec"]){
        s_cell.lbl_specName.text = [self parsingHTMLText:[self.FinalArray objectAtIndex:indexPath.row][@"speciality_name"]];
        s_cell.Img_spec.layer.cornerRadius = s_cell.Img_spec.frame.size.width / 2;
        s_cell.Img_spec.clipsToBounds = YES;
        [s_cell.Img_spec  setImageWithString:[self.FinalArray objectAtIndex:indexPath.row][@"speciality_name"] color:nil circular:YES];
        
        return s_cell;
    }else if([self.dataFor isEqualToString:@"asso"]){
        a_cell.lbl_assoname.text =  [self parsingHTMLText:[self.FinalArray objectAtIndex:indexPath.row][@"association_name"]];
        [a_cell.img_asso sd_setImageWithURL:[NSURL URLWithString:[self.FinalArray objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"globe.png"] options:SDWebImageRefreshCached];
        a_cell.lbl_assoCountry.text = [self parsingHTMLText:[self.FinalArray objectAtIndex:indexPath.row][@"country"]];
        a_cell.img_asso.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor;
        a_cell.img_asso.layer.borderWidth = 0.5;
        a_cell.img_asso.contentMode = UIViewContentModeScaleAspectFill;
        a_cell.img_asso.layer.masksToBounds = YES;
        a_cell.img_asso.layer.cornerRadius = 4.0;
        return a_cell;
    }
    return blankcell;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(NSString*)parsingHTMLText:(NSString*)text{
    text = [[text stringByDecodingHTMLEntities]stringByDecodingHTMLEntities];
    return text;
}



@end

