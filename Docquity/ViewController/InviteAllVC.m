/*============================================================================
 PROJECT: Docquity
 FILE:    InviteAllVC.h
 AUTHOR:  Copyright (c) 2016 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 15/07/16.
 =============================================================================*/

/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import "InviteAllVC.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "AppDelegate.h"
#import "DefineAndConstants.h"
#import "InviteMembers.h"
#import "SVProgressHUD.h"

#define TEST_USE_MG_DELEGATE 1

/*============================================================================
 Interface: InviteAllVC
 =============================================================================*/
@interface InviteAllVC ()
{
    NSString *_processedInviteUserId;   //invite userId
    NSInteger _processedInviteIndex;
}

-(void) showSuccessToastWithMsg:(NSString *) msg;
@property (nonatomic, strong)NSMutableArray  *invitedataArray;

@end

@implementation InviteAllVC
{
    NSMutableArray * tests;
    UIBarButtonItem * prevButton;
    UITableViewCellAccessoryType accessory;
    UIImageView * background; //used for transparency test
    BOOL allowMultipleSwipe;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewThanks.hidden = YES;
    indexArray=[[NSMutableArray alloc]init];
    InviteStr= @"";
    self.inviteListArr = [_inviteDic objectForKey:@"list"];
    if(self.inviteListArr !=nil || [self.inviteListArr isKindOfClass:[NSMutableArray class]])
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.inviteListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell * cell;
    static NSString * reuseIdentifier = @"MGSwipeTableCell";
    cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.lblFullName.text =[self.inviteListArr objectAtIndex:indexPath.row][@"first_name"];
    cell.lblAssociation.text = [self.inviteListArr objectAtIndex:indexPath.row][@"institution_name"];
    cell.lblCountry.text = [self.inviteListArr objectAtIndex:indexPath.row][@"country"];
    cell.btnInvite.tag = indexPath.row;
    
    NSString *index=[NSString stringWithFormat:@"%ld ",(long)indexPath.row];
    if ([InviteStr isKindOfClass:[NSNull class]]) {
    }
    else{
        if ([InviteStr rangeOfString:index].location == NSNotFound) {
            [cell.btnInvite setTitle:@"+ Invite" forState: UIControlStateNormal];
        }
        else {
            cell.btnInvite.userInteractionEnabled = NO;
            [cell.btnInvite setTitle:@"Invited" forState: UIControlStateNormal];
            // [cell.btnInvite setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0]];
        }
    }
    [cell.btnInvite addTarget:self action:@selector(inviteBtnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryType = NO;
    cell.delegate = self;
    cell.allowsMultipleSwipe = NO;
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.btnInvite.layer.cornerRadius = 4.0;
    cell.btnInvite.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.btnInvite.layer.borderWidth = 1.0f;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // NSLog(@"didSelectRowAtIndexPath = %d",indexPath.row);
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
//    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
//          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //delete button
        NSIndexPath * path = [_tableView indexPathForCell:cell];
        [self.inviteListArr removeObjectAtIndex:path.row];
        [_tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        if (self.inviteListArr.count == 0) {
            self.tableView.hidden = YES;
            self.viewThanks.hidden = false;
            self.btnInviteAll.enabled = false;
        }
        return NO; //Don't autohide to improve delete expansion animation
    }
      return YES;
}

#pragma webservices methods
- (void) serviceCalling  //set Invite Members for join
{
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: kSetInviteMyAssociationMember], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:_processedInviteUserId,inviteMemberId,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType =  kSetInviteMyAssociationMember;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
}

#pragma mark WebService Calls Response
- (void) requestFinished:(NSDictionary * )responseData
{
    switch (currentRequestType)
    {
        case kSetInviteMyAssociationMember:
            [self InviteAllMemberResponse:responseData];
            break;
        default:
            break;
    }
}

- (IBAction)inviteBtnClicked:(UIButton*)sender event:(id)event{
    NSDictionary *dict;
    // NSIndexPath *indexPath;
    NSString *indexStr=[NSString stringWithFormat:@"%ld",(long)sender.tag];
    [indexArray addObject:indexStr];
    for (int i=0; i<[indexArray count]; i++) {
        NSString *str=[indexArray objectAtIndex:i];
        InviteStr=[InviteStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    dict   = [self.inviteListArr objectAtIndex: sender.tag];
    _processedInviteIndex = sender.tag;
    _processedInviteUserId = [dict objectForKey:@"id"];
    
    UIButton * syncButton = (UIButton *) sender;
    [syncButton setTitle:@"Invited" forState: UIControlStateNormal];
    
    //Update like status.. Check Network connection
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NoInternetTitle message:NoInternetMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: kSetInviteMyAssociationMember], keyRequestType1, nil];
    NSDictionary *dataDic =[NSDictionary dictionaryWithObjectsAndKeys:_processedInviteUserId,inviteMemberId,nil];
    Server *obj = [[Server alloc] init];
    currentRequestType =  kSetInviteMyAssociationMember;
    obj.delegate = self;
    [obj sendRequestToServer:aDic withDataDic:dataDic];
    //[self.tableView reloadData];
}

- (void)InviteAllMemberResponse:(NSDictionary*)response
{
    NSDictionary *resposeCode = [response objectForKey:@"posts"];
    if (![resposeCode isKindOfClass:[NSNull class]])
    {
        NSString *message=  [NSString stringWithFormat:@"%@",[resposeCode objectForKey:@"msg"]?[resposeCode objectForKey:@"msg"]:@""];
        NSString *stus=[NSString stringWithFormat:@"%@", [resposeCode objectForKey:@"status"]?[resposeCode  objectForKey:@"status"]:@""];
        int value = [stus intValue];
        if (value == 1) {
            [self performSelector:@selector(showSuccessToastWithMsg:) withObject:message afterDelay:0.2];
        }
        else if(value==9){
            [[AppDelegate appDelegate] logOut];
        }
        else{
        [UIAppDelegate alerMassegeWithError:message withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
 }
}

- (void) requestError
{
    // NSLog(@"LoginViewController error");
    [[AppDelegate appDelegate] hideIndicator];
}

-(void) showSuccessToastWithMsg:(NSString *) msg{
    [SVProgressHUD showSuccessWithStatus:msg];
}
- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //NSLog(@"Cancel Button clicked");
}

#pragma mark -invite All method
- (IBAction)didPressInviteAll:(id)sender {
    NSMutableArray * matches = [[NSMutableArray alloc] init];
    for (int i = 0; i< self.inviteListArr.count; i++){
        [matches insertObject:[[self.inviteListArr objectAtIndex:i] objectForKey:@"id"] atIndex:i];
    }
    _processedInviteUserId = [[self.inviteListArr valueForKey:@"id"] componentsJoinedByString:@"|"];
    //  NSLog(@"All Member ID %@", _processedInviteUserId);
    [self serviceCalling];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[matchDataArray addObjectsFromArray:matches];
    // NSLog(@"Invite All Button clicked");
}

@end
