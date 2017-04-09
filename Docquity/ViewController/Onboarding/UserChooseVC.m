//
//  UserChooseVC.m
//  Docquity
//
//  Created by Docquity-iOS on 29/12/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "UserChooseVC.h"
#import "UserChoiceCell.h"
#import "VerifyYourSelfVC.h"
@interface UserChooseVC ()
<MFMailComposeViewControllerDelegate>
@end

@implementation UserChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userTypeArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *type1 = [[NSMutableDictionary alloc]init];
    [type1 setObject:@"doctor.png" forKey:@"typeImg"];
    [type1 setObject:@"Doctor" forKey:@"type"];
    
    NSMutableDictionary *type2 = [[NSMutableDictionary alloc]init];
    [type2 setObject:@"student.png" forKey:@"typeImg"];
    [type2 setObject:@"Student" forKey:@"type"];
    
    [self.userTypeArray addObject:type1];
    [self.userTypeArray addObject:type2];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    self.title = @"Register As";
    self.navigationItem.hidesBackButton = true;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbarback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    negativeSpacer.width = -6; // it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, backButton /* this will be the button which you actually need */] animated:NO];
    
    UIBarButtonItem* helpButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"help.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openMail)];
    self.navigationItem.rightBarButtonItem = helpButton;
 }

-(void)backView{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Number?" message:@"Are you sure you want to go back?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userTypeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserChoiceCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"userChoiceCell"];
    NSMutableDictionary *dic = [self.userTypeArray objectAtIndex:indexPath.row];
    [cell.imgUserchoice setImage:[UIImage imageNamed:[dic valueForKey:@"typeImg"]]];
    cell.lblUserchoice.text = [dic valueForKey:@"type"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self pushToVerifyAccount:[self.userTypeArray objectAtIndex:indexPath.row][@"type"]];
}

-(void)pushToVerifyAccount:(NSString*)type{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    VerifyYourSelfVC *selfVerify = [storyboard instantiateViewControllerWithIdentifier:@"verifyYourSelfVC"];
    if([type isEqualToString:@"Doctor"]){
        selfVerify.userType = @"doctor";
    }
    else{
        selfVerify.userType = @"student";
    }
    selfVerify.userMobile = self.userMobile;
    selfVerify.selectedCountry = self.selectedCountry;
    selfVerify.selectedCountryID = self.selectedCountryID;
    selfVerify.isNewUser = self.isNewUser;
    [self.navigationController pushViewController:selfVerify animated:YES];
}

#pragma mark - Mail Service
-(void)openMail{
    
    if (![MFMailComposeViewController canSendMail]) {
        [self singleButtonAlertViewWithAlertTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email." buttonTitle:OK_STRING];
        return;
    }else{
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[SupportEmail]];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)singleButtonAlertViewWithAlertTitle:(NSString*)aTitle message:(NSString *)msg buttonTitle:(NSString *)bTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:bTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
