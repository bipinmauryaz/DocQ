/*============================================================================
 PROJECT: Docquity
 FILE:    AssociationPickerVC.m
 AUTHOR:  Copyright © 2016 Docquity Services Pvt Ltd All rights reserved.
 DATE:    Created by Docquity Services Pvt Ltd on 04/12/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/

#import "AssociationPickerVC.h"
#import "AssociationCell.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

/*============================================================================
 Interface: AssociationPickerVC
 =============================================================================*/
@interface AssociationPickerVC ()
{
    NSString* selectedAssoId;
    NSMutableArray *selectEveryOneArray;
    NSMutableArray *selectedAssoName;
}
@property (weak, nonatomic) IBOutlet UIImageView *uncheckImg;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *AssociationTF;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *pickedAssociationIcon;
@end

@implementation AssociationPickerVC
@synthesize array,associationListArr;
- (void)viewDidLoad {
    [super viewDidLoad];
    selectEveryOneArray=[[NSMutableArray alloc]init];
    selectedIndexes = [[NSMutableArray alloc]init];
    selectedAssociationList = [[NSMutableArray alloc]init];
    selectedAssoName = [[NSMutableArray alloc]init];

    self.tableView.allowsMultipleSelection = YES;
    selectedAssoId =@"-2";
    self.array = [AppDelegate appDelegate].myAssociationList;
    if (self.array == nil)
    {
        [[AppDelegate appDelegate]GetAssociationList];
    }
    selectedAssociationList = associationListArr.mutableCopy;
    for(int i=0; i<[selectedAssociationList count]; i++)
    {
        NSDictionary *associationInfo =  selectedAssociationList[i];
        if (associationInfo != nil && [associationInfo isKindOfClass:[NSDictionary class]])
        {
            [selectedIndexes addObject:associationInfo[@"association_id"]];
            [selectedIndexes addObject:[[associationInfo[@"association_name"]stringByDecodingHTMLEntities]stringByDecodingHTMLEntities]];
            [selectEveryOneArray addObject:associationInfo[@"association_id"]];
            [selectedAssoName addObject:associationInfo[@"association_name"]];
            NSString *assoID=associationInfo[@"association_id"];
            NSUInteger index = [[self.array valueForKey:@"association_id" ] indexOfObject:assoID];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self registerNotification];
    [super viewWillAppear:animated];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"gotMyAssociation" object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"gotMyAssociation"])
    {
        //NSLog (@"Successfully received MyAssociation");
        [self.tableView reloadData];
    }
}

- (IBAction)didPressEveryOne:(id)sender
{
    if ([selectEveryOneArray count]==[self.array count])
    {
        self.uncheckImg.image = [UIImage imageNamed:@"uncheck.png"];
        [selectEveryOneArray removeAllObjects];
        [selectedAssoName removeAllObjects];
        [self.tableView reloadData];
     }
    else
    {
        [selectEveryOneArray removeAllObjects];
        [selectedAssoName removeAllObjects];
         self.uncheckImg.image = [UIImage imageNamed:@"check.png"];
        for (int count=0; count<self.array.count; count++) {
            //[selectEveryOneArray addObject:[self.array objectAtIndex:count][@"association_id"]];
              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
     // [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AssociationCell *cell = (AssociationCell*)[self.tableView dequeueReusableCellWithIdentifier:@"assoCell"];
    cell.LblAssoName.text = [array objectAtIndex:indexPath.row][@"association_name"];
    cell.ImgAssoImage.backgroundColor = [UIColor whiteColor];
    cell.ImgAssoImage.layer.cornerRadius = cell.ImgAssoImage.frame.size.width/2.0;
    cell.ImgAssoImage.layer.masksToBounds = YES;
    cell.ImgAssoImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.ImgAssoImage.layer.borderColor = [UIColor colorWithRed:184.0/255.0 green:184.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor;
    cell.LblAssoDescription.text = [NSString stringWithFormat:@"With all member of %@", [array objectAtIndex:indexPath.row][@"association_name"]];
    [cell.ImgAssoImage sd_setImageWithURL:[NSURL URLWithString:[array objectAtIndex:indexPath.row][@"profile_pic_path"]] placeholderImage:[UIImage imageNamed:@"image-loader.png"] options:SDWebImageRefreshCached];
    if ([selectEveryOneArray containsObject:[array objectAtIndex:indexPath.row][@"association_id"]])
    {
        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
    }
    else
    {
        cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
    }
    if ([selectEveryOneArray count]==[self.array count])
    {
        self.uncheckImg.image = [UIImage imageNamed:@"check.png"];
     }
    else
    {
      self.uncheckImg.image = [UIImage imageNamed:@"uncheck.png"];
    }
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AssociationCell *cell = (AssociationCell*)[tableView cellForRowAtIndexPath:indexPath];
    [selectEveryOneArray addObject:[self.array objectAtIndex:indexPath.row][@"association_id"]];
    [selectedAssoName addObject:[self.array objectAtIndex:indexPath.row][@"association_name"]];
    cell.ImgCheckUncheck.image = [UIImage imageNamed:@"check.png"];
    if ([selectEveryOneArray count]==[self.array count]) {
        self.uncheckImg.image = [UIImage imageNamed:@"check.png"];
     }
    else
    {
        self.uncheckImg.image = [UIImage imageNamed:@"uncheck.png"];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssociationCell *cell = (AssociationCell*)[tableView cellForRowAtIndexPath:indexPath];
    [selectEveryOneArray removeObject:[self.array objectAtIndex:indexPath.row][@"association_id"]];
    [selectedAssoName removeObject:[self.array objectAtIndex:indexPath.row][@"association_name"]];
     cell.ImgCheckUncheck.image = [UIImage imageNamed:@"uncheck.png"];
    if ([selectEveryOneArray count]==[self.array count])
    {
        self.uncheckImg.image = [UIImage imageNamed:@"check.png"];
    }
    else
    {
      self.uncheckImg.image = [UIImage imageNamed:@"uncheck.png"];
    }
}

- (IBAction)didPressCancel:(id)sender {
    //[self.delegate selectedAssociation:@"cancel"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)didPressDone:(id)sender {
    [selectedAssociationList removeAllObjects];
    for (int i=0; i<[selectEveryOneArray count]; i++) {
        NSDictionary *eventLocation = [NSDictionary dictionaryWithObjectsAndKeys:[selectEveryOneArray objectAtIndex:i],@"association_id",[selectedAssoName objectAtIndex:i],@"association_name", nil];
        [selectedAssociationList addObject:eventLocation];
    }
    [self.delegate selectedAssociationName:selectedAssoName AssoID:selectEveryOneArray associationArray:selectedAssociationList];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
