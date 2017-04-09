/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationPickerVC.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 07/02/17.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "SpecialityPickerVC.h"
#import "SpecialityCell.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "UIImageView+Letters.h"
#import "NSString+HTML.h"
#import "DocquityServerEngine.h"
/*============================================================================
 Interface: AssociationPickerVC
 =============================================================================*/
@interface SpecialityPickerVC (){
    NSString* selectedSpecialityId;
    NSString*searchTypeStr;
    NSMutableArray*searchArr;
    NSString*specialityName;
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *pickedSpecialityIcon;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation SpecialityPickerVC
@synthesize array,specialityListArr;
@synthesize searchNameTF;
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.array == nil) {
        [self getSpecialityRequestWithAuthkey];
    }
    selectedIndexes = [[NSMutableArray alloc]init];
    filteredContentList = [[NSMutableArray alloc] init];
   // selectedContentList = [[NSMutableArray alloc]init];
    selectedSpecilityList = [[NSMutableArray alloc]init];
    self.tableView.allowsMultipleSelection = YES;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl .backgroundColor = [UIColor colorWithRed:237.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1];
    refreshControl .tintColor = [UIColor lightGrayColor];
    //[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1];
    [refreshControl  addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview: refreshControl atIndex:0];
    selectedSpecilityList = specialityListArr.mutableCopy;
    for(int i=0; i<[selectedSpecilityList count]; i++)
    {
        NSDictionary *speclityInfo =  selectedSpecilityList[i];
        if (speclityInfo != nil && [speclityInfo isKindOfClass:[NSDictionary class]])
        {
            [selectedIndexes addObject:speclityInfo[@"speciality_id"]];
            [selectedIndexes addObject:[[speclityInfo[@"speciality_name"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
        }
    }
    specialityNameArrData=[[NSMutableArray alloc]init];
    specialityIdArrData=[[NSMutableArray alloc]init];
     for (int i=0; i<selectedIndexes.count; i++) {
        if (i%2==1)
        {
        [ specialityNameArrData addObject:[selectedIndexes objectAtIndex:i]];
         }
        else
        {
            [specialityIdArrData addObject:[selectedIndexes objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];
    /*
     if(array.count==1)
     {
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
     // NSLog(@"Seelcted id: %@",selectedAssoId);
     }
     */
}

-(void)viewWillAppear:(BOOL)animated{
    //[self registerNotification];
    [super viewWillAppear:animated];
}

-(void)refreshData{
    [self getSpecialityRequestWithAuthkey];
    if (refreshControl) {
        NSString *title = @"Reloading...";
        UIColor *color = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
    }
}
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"gotMySpeciality" object:nil];
}
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"gotMySpeciality"])
    {
        //NSLog (@"Successfully received MyAssociation");
        [self.tableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (isSearching) {
        return [filteredContentList count];
    }
    else
    {
        return  [self.array count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SpecialityCell *cell = (SpecialityCell*)[self.tableView dequeueReusableCellWithIdentifier:@"specCell" forIndexPath:indexPath];
        if (isSearching)
        {
            if([filteredContentList count]>0)
            {
                if([filteredContentList objectAtIndex:indexPath.row])
                {
                    cell.LblSpecialityName.text = [filteredContentList objectAtIndex:indexPath.row][@"speciality_name"];
                    cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
                    cell.cellSelected = NO;
                    cell.ImgSpecialityImage.backgroundColor = [UIColor whiteColor];
                    cell.ImgSpecialityImage.layer.cornerRadius = cell.ImgSpecialityImage.frame.size.width/2.0;
                    cell.ImgSpecialityImage.layer.masksToBounds = YES;
                    cell.ImgSpecialityImage.contentMode = UIViewContentModeScaleAspectFill;
                    cell.ImgSpecialityImage.layer.borderColor = [UIColor colorWithRed:184.0/255.0 green:184.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor;
                    
                    cell.LblspecialityDescription.text = [NSString stringWithFormat:@"With all member of %@", [filteredContentList objectAtIndex:indexPath.row][@"speciality_name"]];
                    
                    //Create user ImageView
                    cell.ImgSpecialityImage.layer.cornerRadius = cell.ImgSpecialityImage.frame.size.width / 2;
                    cell.ImgSpecialityImage.clipsToBounds = YES;
                     NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
                    NSString *resultString = [[cell.LblSpecialityName.text  componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
                 //   NSLog (@"Result: %@", resultString);
                    
                    [cell.ImgSpecialityImage  setImageWithString:resultString color:nil circular:YES];
                     for (int i=0; i<selectedSpecilityList.count; i++) {
                        if ([[selectedSpecilityList objectAtIndex:i][@"speciality_id"] isEqualToString:[filteredContentList objectAtIndex:indexPath.row][@"speciality_id"]]) {
                            cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
                            [cell setSelected:YES animated:YES];
                            cell.cellSelected = YES;
                            break;
                        }
                        else
                        {
                            cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
                            cell.cellSelected = NO;
                            // [cell setSelected:false animated:YES];
                        }
                    }
                }
            }
        }
        else{
            if([array count]>0)
            {
                cell.LblSpecialityName.text = [array objectAtIndex:indexPath.row][@"speciality_name"];
                cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
                cell.cellSelected = NO;
                cell.ImgSpecialityImage.backgroundColor = [UIColor whiteColor];
                cell.ImgSpecialityImage.layer.cornerRadius = cell.ImgSpecialityImage.frame.size.width/2.0;
                cell.ImgSpecialityImage.layer.masksToBounds = YES;
                cell.ImgSpecialityImage.contentMode = UIViewContentModeScaleAspectFill;
                cell.ImgSpecialityImage.layer.borderColor = [UIColor colorWithRed:184.0/255.0 green:184.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor;
                cell.LblspecialityDescription.text = [NSString stringWithFormat:@"With all member of %@", [array objectAtIndex:indexPath.row][@"speciality_name"]];
                
                //Create user ImageView
                cell.ImgSpecialityImage.layer.cornerRadius = cell.ImgSpecialityImage.frame.size.width / 2;
                cell.ImgSpecialityImage.clipsToBounds = YES;
                NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
                NSString *resultString = [[cell.LblSpecialityName.text  componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
                
                [cell.ImgSpecialityImage  setImageWithString:resultString color:nil circular:YES];
                
                for (int i=0; i<selectedSpecilityList.count; i++) {
                    if ([[selectedSpecilityList objectAtIndex:i][@"speciality_id"] isEqualToString:[array objectAtIndex:indexPath.row][@"speciality_id"]]) {
                        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
                        cell.cellSelected = YES;
                        //[cell setSelected:YES animated:YES];
                        break;
                    }else{
                        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
                        cell.cellSelected = NO;
                        //[cell setSelected:false animated:YES];
                    }
                }
            }
        }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     SpecialityCell *cell = (SpecialityCell*)[tableView cellForRowAtIndexPath:indexPath] ;
    if(cell.cellSelected){
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        return;
    }
    if (isSearching)
    {
        [selectedSpecilityList addObject:[filteredContentList objectAtIndex:indexPath.row]];
        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
        cell.cellSelected = YES;
        //Create user ImageView
        self.pickedSpecialityIcon.layer.cornerRadius = self.pickedSpecialityIcon.frame.size.width / 2;
        self.pickedSpecialityIcon.clipsToBounds = YES;
    
        specialityNameArrData=[[NSMutableArray alloc]init];
        specialityIdArrData=[[NSMutableArray alloc]init];
        
        [selectedIndexes addObject:[[filteredContentList objectAtIndex:indexPath.row]valueForKey:@"speciality_id"]];
        [selectedIndexes addObject:[[filteredContentList objectAtIndex:indexPath.row]valueForKey:@"speciality_name"]];
        for (int i=0; i<selectedIndexes.count; i++)
        {
            if (i%2==1) {
                [ specialityNameArrData addObject:[selectedIndexes objectAtIndex:i]];
            }
            else{
                [specialityIdArrData addObject:[selectedIndexes objectAtIndex:i]];
            }
        }
    }
    else
    {
        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
        cell.cellSelected = YES;
        //Create user ImageView
        [selectedSpecilityList addObject:[array objectAtIndex:indexPath.row]];
        self.pickedSpecialityIcon.layer.cornerRadius = self.pickedSpecialityIcon.frame.size.width / 2;
        self.pickedSpecialityIcon.clipsToBounds = YES;
        specialityNameArrData=[[NSMutableArray alloc]init];
        specialityIdArrData=[[NSMutableArray alloc]init];
    [selectedIndexes addObject:[[array objectAtIndex:indexPath.row]valueForKey:@"speciality_id"]];
    [selectedIndexes addObject:[[array objectAtIndex:indexPath.row]valueForKey:@"speciality_name"]];
        for (int i=0; i<selectedIndexes.count; i++) {
            if (i%2==1) {
                [ specialityNameArrData addObject:[selectedIndexes objectAtIndex:i]];
            }
            else{
                [specialityIdArrData addObject:[selectedIndexes objectAtIndex:i]];
            }
        }
    }
 //   [cell setSelected:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpecialityCell *cell = (SpecialityCell*)[tableView cellForRowAtIndexPath:indexPath];
    if(!cell.cellSelected){
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
    cell.cellSelected = NO;
    if (isSearching)
    {
        [selectedIndexes removeObject:[[filteredContentList objectAtIndex:indexPath.row]objectForKey:@"speciality_id"]];
        [selectedIndexes removeObject:[[filteredContentList objectAtIndex:indexPath.row]objectForKey:@"speciality_name"]];
    
        for (int i =0;i<selectedSpecilityList.count;i++){
            if([[[filteredContentList objectAtIndex:indexPath.row]objectForKey:@"speciality_id"]isEqualToString:[selectedSpecilityList objectAtIndex:i][@"speciality_id"]]){
                [selectedSpecilityList removeObjectAtIndex:i];
                break;
            }
        }
        
    }else{
    
        [selectedIndexes removeObject:[[array objectAtIndex:indexPath.row]objectForKey:@"speciality_id"]];
        [selectedIndexes removeObject:[[[array objectAtIndex:indexPath.row]objectForKey:@"speciality_name"] stringByDecodingHTMLEntities]];
    
        for (int i =0;i<selectedSpecilityList.count;i++){
            if([[[array objectAtIndex:indexPath.row]objectForKey:@"speciality_id"]isEqualToString:[selectedSpecilityList objectAtIndex:i][@"speciality_id"]]){
                [selectedSpecilityList removeObjectAtIndex:i];
                break;
            }
        }
    }
    specialityNameArrData=[[NSMutableArray alloc]init];
    specialityIdArrData=[[NSMutableArray alloc]init];
    
    for (int i=0; i<selectedIndexes.count; i++) {
        if (i%2==1) {
             [ specialityNameArrData addObject:[selectedIndexes objectAtIndex:i]];
        }
        else{
            [specialityIdArrData addObject:[selectedIndexes objectAtIndex:i]];
        }
    }
}

- (IBAction)didPressCancel:(id)sender {
    //[self.delegate selectedAssociation:@"cancel"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)didPressDone:(id)sender {
    // [self.delegate selectedSpecialityName:self.SpecialityTF.text specialityID:selectedSpecialityId];
    //[AppDelegate appDelegate].ispostingWIthTagged = YES;
//    [self.delegate selectedSpecialityName:specialityNameArrData specialityID:specialityIdArrData];
    [self.delegate selectedSpecialityName:specialityNameArrData specialityID:specialityIdArrData spacialityArray:selectedSpecilityList];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    isSearching = false;
    isContactAdd = true;
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    isContactAdd = false;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

#pragma mark - search Function
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *searchString;
    if (string.length > 0) {
        searchString = [NSString stringWithFormat:@"%@%@",textField.text, string];
    } else {
        searchString = [textField.text substringToIndex:[textField.text length] - 1];
    }
    if(string.length == 0)
    {
        isSearching = FALSE;
    }
    else
    {    isSearching = TRUE;
        if (filteredContentList == nil)
            filteredContentList = [[NSMutableArray alloc] init];
        else
            [filteredContentList removeAllObjects];
        
        for (int i=0; i<self.array.count; i++) {
            NSMutableDictionary * specialityDic = [[NSMutableDictionary alloc] initWithDictionary:[self.array objectAtIndex:i]];
            NSString*specility_name = [NSString stringWithFormat:@"%@", [specialityDic objectForKey:@"speciality_name"]?[specialityDic  objectForKey:@"speciality_name"]:@""];
            
            NSString *f_Upper  =  [specility_name capitalizedString];
            NSRange nameRange = [f_Upper rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            if(nameRange.location != NSNotFound)
            {
                [filteredContentList addObject:specialityDic];
            }
        }
    }
    [self.tableView reloadData];
   // [self.tableView  reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - getSpecialityRequest
-(void)getSpecialityRequestWithAuthkey{
    self.tableView.tableFooterView = self.spinner ;
    NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]getSpecialityRequestWithAuthKey:[userPref valueForKey:userAuthKey] device_type:kDeviceType app_version:[userPref valueForKey:kAppVersion] lang:kLanguage callback:^(NSMutableDictionary *responseObject, NSError *error)
     {
         self.tableView.tableFooterView = nil ;
         [refreshControl endRefreshing];
         //NSLog(@"responseObject get specility:%@",responseObject);
         if(error){
             if (error.code == NSURLErrorTimedOut) {
                 //time out error here
                  [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];
             }
             else{
                  [self singleButtonAlertViewWithAlertTitle:AppName message:defaultErrorMsg buttonTitle:OK_STRING];
             }
         }else
         {
             // NSLog(@"responseObject get profile:%@",responseObject);
             NSMutableDictionary *resposeDic=[responseObject objectForKey:@"posts"];
             if ([resposeDic isKindOfClass:[NSNull class]]||resposeDic ==nil)
             {
                 // tel is null
                  [self singleButtonAlertViewWithAlertTitle:InternetSlow message:InternetSlowMessage buttonTitle:OK_STRING];
             }
             else
             {
                 if([[resposeDic valueForKey:@"status"]integerValue] == 1)
                 {
                     NSMutableDictionary *dataDic=[resposeDic objectForKey:@"data"];
                     if ([dataDic isKindOfClass:[NSNull class]]||dataDic == nil)
                     {
                         // tel is null
                     }
                     else{
                         array = [[NSMutableArray alloc]init];
                         array =[dataDic objectForKey:@"specility"];
                         [self.tableView reloadData];
                     }
                     // NSLog(@"data get for feed timeline:%@",dataDic);
                 }
                 //timeline Data Entry End
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 9)
                 {
                     [[AppDelegate appDelegate] logOut];
                 }
                 else  if([[resposeDic valueForKey:@"status"]integerValue] == 11)
                 {
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 5)
                 {
                     [[AppDelegate appDelegate]ShowPopupScreen];
                 }
                 else if([[resposeDic valueForKey:@"status"]integerValue] == 0)
                 {
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

//-(BOOL)textFieldShouldClear:(UITextField *)textField{
//    isSearching = false;
//    [self.tableView reloadData];
//    return YES;
//}

@end
