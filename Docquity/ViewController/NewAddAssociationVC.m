//
//  NewAddAssociationVC.m
//  Docquity
//
//  Created by Arimardan Singh on 20/10/16.
//  Copyright © 2016 Docquity. All rights reserved.
//

#import "NewAddAssociationVC.h"
#import "AppDelegate.h"
#import "DocquityServerEngine.h"
#import "NSString+HTML.h"
#import "EditProfileVC.h"
#import "NewProfileVC.h"
#import "UserTimelineVC.h"

typedef enum {
    kTAG_datePicker,
    kTAG_MonthPick
}AllTag;


@interface NewAddAssociationVC (){
    BOOL checked;
    BOOL Monthclick;
    BOOL endyearbtnclick;
    
    NSMutableArray *Years; // for manage
    NSMutableArray *endYears; // for manage
    NSMutableArray *Months;
    NSInteger btnTag;
    
    NSString*asso_id;
    NSString*CheckDetails;
    
    UITextField *activeField;
    BOOL keyboardHasAppeard;
    NSArray *inputItems;
}

//private method of keyboard Accessory view
- (void) registerForKeyboardNotifications;
- (void) keyboardWasShown:(NSNotification *)notif;
- (void) keyboardWillBeHidden:(NSNotification *)notif;
- (CGRect) getPaddedFrameForView:(UIView *) view;
- (void) endEditing;
@end

@implementation NewAddAssociationVC
@synthesize profileDic;
@synthesize isSaveBtnClicked;
@synthesize StartYearBtn,EndYearBtn,StartMonthBtn,EndMonthBtn;
@synthesize nextBarBt,previousBarBt,keybAccessory;

- (void)viewDidLoad {
    [super viewDidLoad];
    // CheckDetails = @"0";
    checked = NO;
    startYChoose = false;
    //Registering Touch event on view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    //Get Current Year into year
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int CurrYear  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    //Create Years Array from 1960 to This year
    Years = [[NSMutableArray alloc] init];
    for (int i=1960; i<=CurrYear; i++) {
        [Years addObject:[NSString stringWithFormat:@"%d",i]];
    }
    Months = [[NSMutableArray alloc] initWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct",@"Nov",@"Dec", nil];
    
    ProfessionModel *professModel = [editdatainfo objectAtIndex:indexnum];
    if(professModel && [professModel isKindOfClass:[ProfessionModel class]])
    {
        companyinfo =   [NSString stringWithFormat:@"%@",[professModel.profession_name stringByDecodingHTMLEntities]];
        profile =       [NSString stringWithFormat:@"%@",[professModel.position stringByDecodingHTMLEntities]];
        locations =     [NSString stringWithFormat:@"%@",[professModel.location stringByDecodingHTMLEntities]];
        asso_id =       [NSString stringWithFormat:@"%@",professModel.profession_id];
        asso_StDate =   [NSString stringWithFormat:@"%@",professModel.start_date];
        asso_EndDate =  [NSString stringWithFormat:@"%@",professModel.end_date];
        asso_StMonth =  [NSString stringWithFormat:@"%@",professModel.start_month];
        asso_EndMonth = [NSString stringWithFormat:@"%@",professModel.end_month];
        currProf =      [NSString stringWithFormat:@"%@",professModel.current_prof];
    }
    
    //Initializing the array for inputItems
    inputItems = [NSArray arrayWithObjects:self.CompNameTf,self.TitleTf,self.LocationTf,nil];
    //Create inputAccessoryView for all inputItems
    for (UITextField *tf in inputItems) {
        tf.inputAccessoryView = self.keybAccessory;
    }
    //Registring for keyboard notifications
    [self registerForKeyboardNotifications];
    keyboardHasAppeard = NO;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    if ([currProf isEqualToString:@"1"]) {
        CheckDetails = @"1";
    }
    else{
        CheckDetails = @"0";
    }
    self.scrollView.contentSize=self.scvwContentView.frame.size;
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];
    if (flg==1) {
        self.navigationItem.title = @"Edit Professional Experience";
        _add_assoView.hidden = YES;
        _edit_assoView.hidden = NO;
        _CompNameTf.text = companyinfo;
        _TitleTf.text = profile;
        _LocationTf.text = locations;
    }
    else{
        self.navigationItem.title = @"Add Professional Experience";
        _add_assoView.hidden =  NO;
        _edit_assoView.hidden = YES;
    }
    if (flg==1) {
        if ([asso_StMonth  isEqualToString: @" "]) {
            [StartMonthBtn  setTitle:@"Starting Month" forState:UIControlStateNormal];
        }
        else {
            [StartMonthBtn setTitle:asso_StMonth forState:UIControlStateNormal];
        }
    }
    else {
        [StartMonthBtn setTitle:@"Starting Month" forState:UIControlStateNormal];
    }
    [StartMonthBtn addTarget:self action:@selector(SelectTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    
    if (flg==1) {
        if ([asso_StDate isEqualToString: @" "]) {
            [StartYearBtn setTitle:@"Starting Year" forState:UIControlStateNormal];
        }
        else {
            [StartYearBtn setTitle:asso_StDate forState:UIControlStateNormal];
        }
    }
    else {
        [StartYearBtn setTitle:@"Starting Year" forState:UIControlStateNormal];
    }
    [StartYearBtn addTarget:self action:@selector(SelectTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    if (flg==1) {
        if ([asso_EndMonth isEqualToString: @" "]) {
            [EndMonthBtn  setTitle:@"Ending Month" forState:UIControlStateNormal];
        }
        else {
            [EndMonthBtn  setTitle:asso_EndMonth forState:UIControlStateNormal];
        }
    }
    else {
        [EndMonthBtn  setTitle:@"Ending Month" forState:UIControlStateNormal];
    }
    [EndMonthBtn addTarget:self action:@selector(SelectTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    if (flg==1) {
        if ([asso_EndDate isEqualToString: @" "]) {
            [EndYearBtn  setTitle:@"Ending Year" forState:UIControlStateNormal];
        }
        else {
            [EndYearBtn setTitle:asso_EndDate forState:UIControlStateNormal];
        }
    }
    else {
        [EndYearBtn setTitle:@"Ending Year" forState:UIControlStateNormal];
    }
    [EndYearBtn addTarget:self action:@selector(SelectTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    if (flg==1) {
        if([currProf isEqualToString:@"1"]){
            _CheckBoxCWH.image= [UIImage imageNamed:@"check_box.png"];
            [EndMonthBtn setTitle:@"Ending Month" forState:UIControlStateNormal];
            [EndYearBtn setTitle:@"Ending Year" forState:UIControlStateNormal];
            EndYearBtn.enabled = NO;
            EndMonthBtn.enabled =NO;
            checked = true;
        }
        else {
            _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
            EndYearBtn.enabled = YES;
            EndMonthBtn.enabled = YES;
            checked = false;
        }
    }
    else {
        EndYearBtn.enabled = YES;
        EndMonthBtn.enabled =YES;
        _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
        checked = false;
    }
    UITapGestureRecognizer *taponView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    [_currPurr_assoView setUserInteractionEnabled:YES];
    [_currPurr_assoView addGestureRecognizer:taponView];
    
    UITapGestureRecognizer *tapOncheckbox= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    [_CheckBoxCWH setUserInteractionEnabled:YES];
    [_CheckBoxCWH addGestureRecognizer:tapOncheckbox];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = NO;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
   }

#pragma mark - PickerView Delegate Methods
- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    if (Monthclick) {
        return [Months count];
    }else if (lastButtonClicked.tag == 300) {
        return [Years count];
    }else if (startYChoose)
    {
        NSInteger findstart =0;
        NSInteger startyear = StartYearBtn.titleLabel.text.integerValue;
        tempYear = [NSMutableArray arrayWithArray:Years];
        for (int i=0; i<tempYear.count; i++) {
            NSInteger tempYearAtIndex = [[tempYear objectAtIndex:i]integerValue];
            if(tempYearAtIndex == startyear)
            {
                findstart = i;
                break;
            }
        }
        [tempYear removeObjectsInRange:NSMakeRange(0, findstart)];
        return [tempYear count];
    }else{
        return [Years count];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [self endEditing];
    if (Monthclick) {
        return [Months objectAtIndex:row];
    }else if (lastButtonClicked.tag == 300) {
        return [Years objectAtIndex:row];
    }else if (startYChoose){
        return [tempYear objectAtIndex:row];
    }else{
        return [Years objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (Monthclick) {
        NSString *val = [Months objectAtIndex:row];
        if (btnTag==100) {
            [StartMonthBtn setTitle:val forState:UIControlStateNormal];
        }else{
            [EndMonthBtn setTitle:val forState:UIControlStateNormal];}
    }
    else{
        NSString *val;
        if (lastButtonClicked.tag == 300) {
            val = [Years objectAtIndex:row];
            [StartYearBtn setTitle:val forState:UIControlStateNormal];
            if (![EndYearBtn.titleLabel.text isEqualToString:@"Ending Year"]&&(EndYearBtn.titleLabel.text.integerValue<val.integerValue)) {
                [EndYearBtn setTitle:val forState:UIControlStateNormal];
            }
        }
        else if (lastButtonClicked.tag == 400) {
            val = [tempYear objectAtIndex:row];
            [EndYearBtn setTitle:val forState:UIControlStateNormal];
        }
    }
}

-(void)setData:(NSMutableArray *)Filldata withindex:(NSInteger)index flag:(NSInteger)flag{
    editdatainfo = Filldata;
    indexnum = index;
    flg = flag;
}

#pragma mark - save and AddMore Button Action
-(IBAction)addmore:(UIButton*)sender{
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
    isSaveBtnClicked = NO;
    if ([_CompNameTf.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter your Hospital / Clinic Name." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    else if ([_LocationTf.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter your Location." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    
    if ([StartYearBtn.titleLabel.text isEqualToString:@"Starting Year"]) {
        [StartYearBtn setTitle:@" " forState:UIControlStateNormal];
    }
    if ([EndYearBtn.titleLabel.text isEqualToString:@"Ending Year"]) {
        [EndYearBtn setTitle:@" " forState:UIControlStateNormal];
    }
    if ([StartMonthBtn.titleLabel.text isEqualToString:@"Starting Month"]) {
        [StartMonthBtn setTitle:@" " forState:UIControlStateNormal];
    }
    if ([EndMonthBtn.titleLabel.text isEqualToString:@"Ending Month"]) {
        [EndMonthBtn setTitle:@" " forState:UIControlStateNormal];
    }
    else {
        _CompNameTf.text =  [_CompNameTf.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _TitleTf.text =  [_TitleTf.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _LocationTf.text =  [_LocationTf.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self setCreateAssociationRequest:_CompNameTf.text position:_TitleTf.text location:_LocationTf.text stdate:StartYearBtn.titleLabel.text lastdate:EndYearBtn.titleLabel.text stmonth:StartMonthBtn.titleLabel.text endmonth:EndMonthBtn.titleLabel.text currPursuing:CheckDetails];
    }
}

#pragma mark - save Button Action
-(IBAction)Save:(UIButton*)sender{
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
    isSaveBtnClicked = YES;
    if ([_CompNameTf.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter your Hospital / Clinic Name." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    else if ([_LocationTf.text length] == 0){
        [UIAppDelegate alerMassegeWithError:@"Please enter your Location." withButtonTitle:OK_STRING autoDismissFlag:NO];
        return;
    }
    if ([StartYearBtn.titleLabel.text isEqualToString:@"Starting Year"]) {
        [StartYearBtn setTitle:@" " forState:UIControlStateNormal];
    }
    
    if ([EndYearBtn.titleLabel.text isEqualToString:@"Ending Year"]) {
        [EndYearBtn setTitle:@" " forState:UIControlStateNormal];
    }
    
    if ([StartMonthBtn.titleLabel.text isEqualToString:@"Starting Month"]) {
        [StartMonthBtn setTitle:@" " forState:UIControlStateNormal];
    }
    
    if ([EndMonthBtn.titleLabel.text isEqualToString:@"Ending Month"]) {
        [EndMonthBtn setTitle:@" " forState:UIControlStateNormal];
    }
    if (flg==1) {
        if ([_CompNameTf.text isEqualToString:companyinfo]&& [_TitleTf.text isEqualToString:profile]&&[_LocationTf.text isEqualToString:locations]&&[StartYearBtn.titleLabel.text isEqualToString:asso_StDate]&&[StartMonthBtn.titleLabel.text isEqualToString:asso_StMonth]&&[EndMonthBtn.titleLabel.text isEqualToString:asso_EndMonth]&&[_CompNameTf.text isEqualToString:companyinfo]&&[EndYearBtn.titleLabel.text isEqualToString:asso_EndDate]&&[CheckDetails isEqualToString:currProf]) {
              [self.navigationController popViewControllerAnimated:YES];

            return;
        }
        else if ([_CompNameTf.text isEqualToString:companyinfo]&&[_TitleTf.text isEqualToString:profile]&&[_LocationTf.text isEqualToString:locations]&&[StartYearBtn.titleLabel.text isEqualToString:asso_StDate]&&[StartMonthBtn.titleLabel.text isEqualToString:asso_StMonth]&&[EndMonthBtn.titleLabel.text isEqualToString:@" "]&&[_CompNameTf.text isEqualToString:companyinfo]&&[EndYearBtn.titleLabel.text isEqualToString:@" "]&&[CheckDetails isEqualToString:currProf]) {
            [self.navigationController popViewControllerAnimated:YES];
        
            return;
        }
        else {
            _CompNameTf.text =  [_CompNameTf.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _TitleTf.text =  [_TitleTf.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _LocationTf.text =  [_LocationTf.text stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //calling webservice for Edit Association
            [self setAssociationsRequest:asso_id assoName:_CompNameTf.text position:_TitleTf.text location:_LocationTf.text stdate:StartYearBtn.titleLabel.text lastdate:EndYearBtn.titleLabel.text stmonth:StartMonthBtn.titleLabel.text endmonth:EndMonthBtn.titleLabel.text currPursuing:CheckDetails];
        }
    }
    else{
        _CompNameTf.text =  [_CompNameTf.text stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _TitleTf.text =  [_TitleTf.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _LocationTf.text =  [_LocationTf.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        //calling webservice for new Add Association
        [self setCreateAssociationRequest:_CompNameTf.text position:_TitleTf.text location:_LocationTf.text stdate:StartYearBtn.titleLabel.text lastdate:EndYearBtn.titleLabel.text stmonth:StartMonthBtn.titleLabel.text endmonth:EndMonthBtn.titleLabel.text currPursuing:CheckDetails];
    }
}

#pragma mark - Delete Button Action
-(IBAction)deleteBtn:(UIButton*)sender{
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
    //calling webservice for delete Association
    [self setRemoveAssociationsRequest:asso_id];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TAP Gesture
-(void)tapDetected: (UIImageView *)sender{
    if (checked) {
        CheckDetails = @"0";
        EndMonthBtn.enabled = YES;
        EndYearBtn.enabled = YES;
        _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
        checked = NO;
    }
    else{
        CheckDetails = @"1";
        EndMonthBtn.enabled = NO;
        EndYearBtn.enabled = NO;
        [EndMonthBtn setTitle:@"Ending Month" forState:UIControlStateNormal];
        [EndYearBtn setTitle:@"Ending Year" forState:UIControlStateNormal];
        _CheckBoxCWH.image= [UIImage imageNamed:@"check_box.png"];
        checked = YES;
    }
}

#pragma mark- Select time period
-(void)SelectTimePeriod:(UIButton *)sender{
    //NSLog(@"StartMonthDatePick:");
    lastButtonClicked = sender;
    if (viewopen) {
        return;
    }
    else {
        //NSLog(@"StartMonthDatePick:");
        if ((sender.tag == 100)) {
            //NSLog(@"startmonthbtn cick");
            btnTag = 100;
            Monthclick = YES;
            startMChoose = YES;
        }
        else if((sender.tag == 300)) {
            //NSLog(@"StartYearBtn click");
            btnTag = 300;
            Monthclick = NO;
            startYChoose = YES;
        }else if((sender.tag == 200)) {
            //NSLog(@"EndMonthBtn click");
            btnTag = 200;
            Monthclick = YES;
        }
        else{
            // NSLog(@"EndYearButton click");
            btnTag =400;
            Monthclick = NO;
            endyearbtnclick =YES;
        }
        newviewforPicker= [[UIView alloc]init];
        newviewforPicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/3);
        newviewforPicker.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:202.0/255.0 alpha:1.0];
        [self.view addSubview:newviewforPicker];
        
        UILabel *StatusLbl = [[UILabel alloc]init];
        StatusLbl.frame = CGRectMake(20, 10, newviewforPicker.frame.size.width/3, 30);
        StatusLbl.textColor = [UIColor whiteColor];
        StatusLbl.backgroundColor = [UIColor clearColor];
        StatusLbl.font= [UIFont systemFontOfSize:15.0];
        [newviewforPicker addSubview:StatusLbl];
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnDone.frame = CGRectMake(newviewforPicker.frame.size.width- StatusLbl.frame.size.width - StatusLbl.frame.origin.x, 10, newviewforPicker.frame.size.width/3, 30);
        [btnDone setTitle:@"Done" forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDone.titleLabel.font= [UIFont systemFontOfSize:16.0];
        btnDone.titleLabel.backgroundColor = [UIColor clearColor];
        btnDone.layer.cornerRadius = 5.0f;
        [btnDone addTarget:self action:@selector(closeview:) forControlEvents:UIControlEventTouchUpInside];
        [newviewforPicker addSubview:btnDone];
        if (Monthclick) {
            UIPickerView *monthPick= [[UIPickerView alloc]initWithFrame:CGRectMake(0, StatusLbl.frame.origin.y + StatusLbl.frame.size.height+10, newviewforPicker.frame.size.width, newviewforPicker.frame.size.height)];
            monthPick.backgroundColor = [UIColor whiteColor];
            monthPick.delegate=self;
            [newviewforPicker addSubview:monthPick];
            StatusLbl.text = @"Select Month";
            StatusLbl.backgroundColor = [UIColor clearColor];
        }
        else
        {
            StatusLbl.text = @"Select Year";
            StatusLbl.backgroundColor = [UIColor clearColor];
            UIPickerView *YearPick= [[UIPickerView alloc]initWithFrame:CGRectMake(0, StatusLbl.frame.origin.y + StatusLbl.frame.size.height+10, newviewforPicker.frame.size.width, newviewforPicker.frame.size.height)];
            YearPick.backgroundColor = [UIColor whiteColor];
            YearPick.delegate=self;
            [newviewforPicker addSubview:YearPick];
        }
        [self openview:sender];
    }
}

#pragma mark - open Picker View Action
-(void)openview: (UIButton*)sender
{
    if (viewopen) {
        return;
    }
    else{  CGRect newFrame = newviewforPicker.frame;
        newFrame.origin.y = [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.height/3-40;
        [UIView animateWithDuration:0.5
                         animations:^{
                             newviewforPicker.frame = newFrame;
                         }];
        NSString *stchoosen = @"1960";
        if (sender.tag == 300) {
            [StartYearBtn setTitle:stchoosen forState:UIControlStateNormal];
            viewopen=YES;
        }
        else if (sender.tag == 100)   {
            NSString *choosen = @"Jan";
            [StartMonthBtn setTitle:choosen forState:UIControlStateNormal];
            viewopen=YES;
        }
        else if (sender.tag == 200)   {
            NSString *choosen = @"Jan";
            [EndMonthBtn setTitle:choosen forState:UIControlStateNormal];
            viewopen=YES;
        }
        else{
            NSString *endchoosen = StartYearBtn.titleLabel.text;
            [EndYearBtn setTitle:endchoosen forState:UIControlStateNormal];
            viewopen=YES;
        }
    }
}

#pragma mark -  close View Action
-(void)closeview: (UIButton *)sender{
    CGRect newFrame = newviewforPicker.frame;
    newFrame.origin.y = [UIScreen mainScreen].bounds.size.height;    // shift down by 500pts
    [UIView animateWithDuration:1.0
                     animations:^{
                         newviewforPicker.frame = newFrame;
                     }];
    viewopen=NO;
}

#pragma mark - Add/create association api calling
-(void)setCreateAssociationRequest:(NSString *)assoName position:(NSString*)position location:(NSString*)location  stdate:(NSString*)startdate lastdate:(NSString*)lastdate  stmonth:(NSString*)stmonth endmonth:(NSString*)endmonth  currPursuing:(NSString*)currPursuing{
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetCreateAssociationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] current_prof:currPursuing association_name:assoName position:position location:location start_date:startdate end_date:lastdate start_month:stmonth end_month:endmonth format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                if (isSaveBtnClicked){
                    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                    NSString *custmId=[userpref objectForKey:ownerCustId];
                    UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                    UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                    NewProfile .custid=  custmId;
                    NewProfile.hidesBottomBarWhenPushed = YES;
                    [AppDelegate appDelegate].isComeFromSettingVC = NO;
                    [self.navigationController pushViewController:NewProfile animated:YES];
                }
                else{
                    _CheckBoxCWH.image= [UIImage imageNamed:@"uncheck_box.png"];
                    _CompNameTf.text = @"";
                    _TitleTf.text = @"";
                    _LocationTf.text = @"";
                    [StartYearBtn setTitle:@"Starting Year" forState:UIControlStateNormal];
                    [EndYearBtn setTitle:@"Ending Year" forState:UIControlStateNormal];
                    [StartMonthBtn setTitle:@"Starting Month" forState:UIControlStateNormal];
                    [EndMonthBtn setTitle:@"Ending Month" forState:UIControlStateNormal];
                }
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - set edit/update assotiation api calling
-(void)setAssociationsRequest:(NSString *)asso_Id assoName:(NSString *)association_name position:(NSString*)position location:(NSString*)location  stdate:(NSString*)startdate lastdate:(NSString*)lastdate  stmonth:(NSString*)stmonth endmonth:(NSString*)endmonth currPursuing:(NSString*)currPursuing {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetAssociationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId]association_id:asso_Id current_prof:currPursuing association_name:association_name position:position location:location start_date:startdate end_date:lastdate  start_month:stmonth end_month:endmonth format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                NSString *custmId=[userpref objectForKey:ownerCustId];
                UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                NewProfile .custid=  custmId;
                NewProfile.hidesBottomBarWhenPushed = YES;
                [AppDelegate appDelegate].isComeFromSettingVC = NO;
                [self.navigationController pushViewController:NewProfile animated:YES];
                
            }else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - remove Association api calling
-(void)setRemoveAssociationsRequest:(NSString *)asso_Id  {
    [[AppDelegate appDelegate]showIndicator];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [[DocquityServerEngine sharedInstance]SetRemoveAssociationRequest:[userDef objectForKey:userAuthKey] user_id:[userDef objectForKey:userId] association_id:asso_Id format:jsonformat callback:^(NSMutableDictionary *responceObject, NSError *error) {
        [[AppDelegate appDelegate]hideIndicator];
        NSDictionary *resposePost =[responceObject objectForKey:@"posts"];
        if ([resposePost isKindOfClass:[NSNull class]] || (resposePost == nil))
        {
            // Response is null
        }
        else {
            NSString *message=  [NSString stringWithFormat:@"%@",[resposePost objectForKey:@"msg"]?[resposePost objectForKey:@"msg"]:@""];
            if([[resposePost valueForKey:@"status"]integerValue] == 1)
            {
                NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
                NSString *custmId=[userpref objectForKey:ownerCustId];
                UIStoryboard *obstoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
                UserTimelineVC *NewProfile  = [obstoryboard instantiateViewControllerWithIdentifier:@"UserTimelineVC"];
                NewProfile .custid=  custmId;
                NewProfile.hidesBottomBarWhenPushed = YES;
                [AppDelegate appDelegate].isComeFromSettingVC = NO;
                [self.navigationController pushViewController:NewProfile animated:YES];
            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
            else  if([[resposePost valueForKey:@"status"]integerValue] == 9)
            {
                [[AppDelegate appDelegate]logOut];
            }
        }
    }];
}

#pragma mark - next Button Action
- (IBAction)nextInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *nextInputField = [inputItems objectAtIndex:(idx + 1)];
    [nextInputField becomeFirstResponder];
}

#pragma mark - previous Button Action
- (IBAction)previousInputField:(id)sender
{
    NSUInteger idx = [inputItems indexOfObject:activeField];
    UITextField *prevInputField = [inputItems objectAtIndex:(idx - 1)];
    [prevInputField becomeFirstResponder];
}

#pragma mark - Done Button Action
- (IBAction)doneEditing:(id)sender
{
    [self endEditing];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    //Adjust he inputAccessory according to the position of textField in inputItems
    NSUInteger idx = [inputItems indexOfObject:textField];
    self.previousBarBt.enabled = YES;
    self.nextBarBt.enabled = YES;
    if (idx == 0) {
        self.previousBarBt.enabled = NO;
    }else if(idx == (inputItems.count - 1)){
        self.nextBarBt.enabled = NO;
    }
    //scrolling the textField to visible area
    if (keyboardHasAppeard)
        [self.scrollView scrollRectToVisible:[self getPaddedFrameForView:textField] animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    // NSLog(@"textFieldDidEndEditingcalled");
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark private methods
- (CGRect) getPaddedFrameForView:(UIView *) view
{
    CGFloat padding = 5;
    CGRect frame = view.frame;
    frame.size.height += 2 * padding;
    frame.origin.y -= padding;
    return frame;
}

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark Notification handlers
- (void)keyboardWasShown:(NSNotification*)notif
{
    NSDictionary* info = [notif userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    //scrolling the active field to visible area
    if ((nil != activeField) && (keyboardHasAppeard == NO))
        [self.scrollView scrollRectToVisible:[self getPaddedFrameForView:activeField] animated:YES];
    keyboardHasAppeard = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)notif
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
    keyboardHasAppeard = NO;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setCompNameTf:nil];
    [self setTitleTf:nil];
    [self setLocationTf:nil];
    inputItems = nil;
    [self setScvwContentView:nil];
    [super viewDidUnload];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
