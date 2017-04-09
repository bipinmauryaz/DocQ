//
//  AKTableAlert.m
//
//  Version 1.3
//
//  Created by Matteo Del Vecchio on 11/12/12.
//  Updated on 03/07/2013.
//

//  For the complete copyright notice, read Source Code License.
//

#import "AKTableAlert.h"


#define kTableAlertWidth     284.0
#define kLateralInset         12.0
#define kVerticalInset         8.0
#define kMinAlertHeight      264.0
#define kCancelButtonHeight   44.0
#define kCancelButtonMargin    5.0
#define kTitleLabelMargin     12.0


// Since orientation is managed by view controllers,
// AKTableAlertController is used under the AKTableAlert
// to provide support for orientation and rotation
@interface AKTableAlertController : UIViewController
@end

@implementation AKTableAlertController

// Orientation support
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	else
		return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	AKTableAlert *ta = [self.view.subviews lastObject];
	if (ta != nil && [ta isKindOfClass:[AKTableAlert class]])
	{
		// Rotate the AKTableAlert if orientation changes
		// when it is visible on screen
		[UIView animateWithDuration:duration animations:^{
			[ta sizeToFit];
			
			CGFloat x = CGRectGetMidX(self.view.bounds);
			CGFloat y = CGRectGetMidY(self.view.bounds);
			ta.center = CGPointMake(x, y);
			ta.frame = CGRectIntegral(ta.frame);
		}];
	}
	else
		return;
}

@end


@interface AKTableAlert ()
@property (nonatomic, strong) UIView *alertBg;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleSeperator;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIWindow *appWindow;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cancelButtonTitle;

@property (nonatomic) BOOL cellSelected;

@property (nonatomic, strong) AKTableAlertNumberOfRowsBlock numberOfRows;
@property (nonatomic, strong) AKTableAlertTableCellsBlock cells;

-(void)createBackgroundView;	// Draws and manages the view behind the alert
-(void)animateIn;	 // Animates the alert when it has to be shown
-(void)animateOut;	 // Animates the alert when it has to be dismissed
-(void)dismissTableAlert;	// Dismisses the alert
@end



@implementation AKTableAlert

#pragma mark - AKTableAlert Class Method

+(AKTableAlert *)tableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelBtnTitle numberOfRows:(AKTableAlertNumberOfRowsBlock)rowsBlock andCells:(AKTableAlertTableCellsBlock)cellsBlock
{

	return [[self alloc] initWithTitle:title cancelButtonTitle:cancelBtnTitle numberOfRows:rowsBlock andCells:cellsBlock];
}

#pragma mark - AKTableAlert Initialization

-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle numberOfRows:(AKTableAlertNumberOfRowsBlock)rowsBlock andCells:(AKTableAlertTableCellsBlock)cellsBlock
{
	// Throw exception if rowsBlock or cellsBlock is nil
	if (rowsBlock == nil || cellsBlock == nil)
	{
		[[NSException exceptionWithName:@"rowsBlock and cellsBlock Error" reason:@"These blocks MUST NOT be nil" userInfo:nil] raise];
		return nil;
	}
	
	self = [super init];
	if (self)
	{
		_numberOfRows = rowsBlock;
		_cells = cellsBlock;
		_title = title;
		_cancelButtonTitle = cancelButtonTitle;
		_height = kMinAlertHeight;	// Defining default (and minimum) alert height
	}
	
	return self;
}

#pragma mark - Actions

-(void)configureSelectionBlock:(AKTableAlertRowSelectionBlock)selBlock andCompletionBlock:(AKTableAlertCompletionBlock)comBlock
{
	self.selectionBlock = selBlock;
	self.completionBlock = comBlock;
}

-(void)createBackgroundView
{
	// reset cellSelected value
	self.cellSelected = NO;
	
	// Allocating controller for presenting AKTableAlert
	AKTableAlertController *controller = [[AKTableAlertController alloc] init];
	controller.view.backgroundColor = [UIColor clearColor];
	
	// Creating new UIWindow to manage AKTableAlert and AKTableAlertController
	self.appWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.appWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
	self.appWindow.rootViewController = controller;
	self.appWindow.alpha = 0.0;
	self.appWindow.windowLevel = UIWindowLevelStatusBar;
	self.appWindow.hidden = NO;
	[self.appWindow makeKeyAndVisible];
	
	// Adding AKTableAlert as subview of AKTableAlertController (controller)
	[controller.view addSubview:self];
	
	// setting options to AKTableAlert
	self.frame = self.superview.bounds;
	self.opaque = NO;
	
	// get background color darker
	[UIView animateWithDuration:0.2 animations:^{
		self.appWindow.alpha = 1.0;
	}];
}

-(void)animateIn
{
	// UIAlertView-like pop in animation
	self.alertBg.transform = CGAffineTransformMakeScale(0.6, 0.6);
	[UIView animateWithDuration:0.2 animations:^{
		self.alertBg.transform = CGAffineTransformMakeScale(1.1, 1.1);
	} completion:^(BOOL finished){
		[UIView animateWithDuration:1.0/15.0 animations:^{
			self.alertBg.transform = CGAffineTransformMakeScale(0.9, 0.9);
		} completion:^(BOOL finished){
			[UIView animateWithDuration:1.0/7.5 animations:^{
				self.alertBg.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}

-(void)animateOut
{
	[UIView animateWithDuration:1.0/7.5 animations:^{
		self.alertBg.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0/15.0 animations:^{
			self.alertBg.transform = CGAffineTransformMakeScale(1.1, 1.1);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.3 animations:^{
				self.alertBg.transform = CGAffineTransformMakeScale(0.01, 0.01);
				self.appWindow.alpha = 0.3;
			} completion:^(BOOL finished){
				// table alert not shown anymore
				[self removeFromSuperview];
				self.appWindow.hidden = YES;
				[self.appWindow resignKeyWindow];
			}];
		}];
	}];
}

-(void)show
{
	[self createBackgroundView];
	
	// alert view creation
	self.alertBg = [[UIView alloc] initWithFrame:CGRectZero];
	[self addSubview:self.alertBg];
	
	// setting alert background image
	UIImageView *alertBgImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popupbackround.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:30]];
	[self.alertBg addSubview:alertBgImage];
	
	// alert title creation
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
	self.titleLabel.frame = CGRectMake(kLateralInset, 15, kTableAlertWidth - kLateralInset * 2, 22);
	self.titleLabel.text = self.title;
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	[self.alertBg addSubview:self.titleLabel];
    
    self.titleSeperator = [[UILabel alloc]initWithFrame:CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10,kTableAlertWidth,1)];
    self.titleSeperator.backgroundColor = [UIColor whiteColor];
    [self.alertBg addSubview:self.titleSeperator];
	
	// table view creation
	self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.table.frame = CGRectMake(kLateralInset, self.titleSeperator.frame.origin.y + self.titleSeperator.frame.size.height + kTitleLabelMargin, kTableAlertWidth - kLateralInset * 2, (self.height - kVerticalInset * 2) - self.titleSeperator.frame.origin.y - self.titleSeperator.frame.size.height - kTitleLabelMargin - (kCancelButtonMargin + kCancelButtonHeight)*(self.cancelButtonTitle ? 1 : 0));
	self.table.layer.cornerRadius = 6.0;
	self.table.layer.masksToBounds = YES;
	self.table.delegate = self;
	self.table.dataSource = self;
	self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.table.backgroundView = [[UIView alloc] init];
    self.table.backgroundColor = [UIColor clearColor];
    [self.alertBg addSubview:self.table];
//    self.table.backgroundView.backgroundColor = [UIColor clearColor];
	// setting white-to-gray gradient as table view's background
/*	CAGradientLayer *tableGradient = [CAGradientLayer layer];
	tableGradient.frame = CGRectMake(0, 0, self.table.frame.size.width, self.table.frame.size.height);
	tableGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1.0] CGColor], nil];
	[self.table.backgroundView.layer insertSublayer:tableGradient atIndex:0];
	*/
	// adding inner shadow mask on table view
/*	UIImageView *maskShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MLTableAlertShadowMask.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:7]];
	maskShadow.userInteractionEnabled = NO;
	maskShadow.layer.masksToBounds = YES;
	maskShadow.layer.cornerRadius = 5.0;
	maskShadow.frame = self.table.frame;
	[self.alertBg addSubview:maskShadow];
	*/
	// cancel button creation
	if (self.cancelButtonTitle)
	{
		self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.cancelButton.frame = CGRectMake(kLateralInset, self.table.frame.origin.y + self.table.frame.size.height + kCancelButtonMargin, kTableAlertWidth - kLateralInset * 2, kCancelButtonHeight);
		self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
		self.cancelButton.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
		[self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
		[self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.cancelButton setBackgroundColor:[UIColor clearColor]];
		[self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"MLTableAlertButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
		[self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"MLTableAlertButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
		self.cancelButton.opaque = NO;
		self.cancelButton.layer.cornerRadius = 5.0;
		[self.cancelButton addTarget:self action:@selector(dismissTableAlert) forControlEvents:UIControlEventTouchUpInside];
		[self.alertBg addSubview:self.cancelButton];
	}
	
	// setting alert and alert background image frames
	self.alertBg.frame = CGRectMake((self.frame.size.width - kTableAlertWidth) / 2, (self.frame.size.height - self.height) / 2, kTableAlertWidth, self.height - kVerticalInset * 2);
	alertBgImage.frame = CGRectMake(0.0, 0.0, kTableAlertWidth, self.height);
	
	// the alert will be the first responder so any other controls,
	// like the keyboard, will be dismissed before the alert
	[self becomeFirstResponder];
	
	// show the alert with animation
	[self animateIn];
}

-(void)dismissTableAlert
{
	// dismiss the alert with its animation
	[self animateOut];
	
	// perform actions contained in completionBlock if the
	// cancel button of the alert has been pressed
	// if completionBlock == nil, nothing is performed
	if (self.completionBlock != nil)
		if (!self.cellSelected)
			self.completionBlock();
}

// Allows the alert to be first responder
-(BOOL)canBecomeFirstResponder
{
	return YES;
}

// Alert height setter
-(void)setHeight:(CGFloat)height
{
	if (height > kMinAlertHeight)
		_height = height;
	else
		_height = kMinAlertHeight;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// TODO: Allow multiple sections
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// according to the numberOfRows block code
	return self.numberOfRows(section);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// according to the cells block code
    
	return self.cells(self, indexPath);
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// set cellSelected to YES so the completionBlock won't be
	// executed because a cell has been pressed instead of the cancel button
	self.cellSelected = YES;
	// dismiss the alert
	[self dismissTableAlert];
	
	// perform actions contained in the selectionBlock if it isn't nil
	// add pass the selected indexPath
	if (self.selectionBlock != nil)
		self.selectionBlock(indexPath);
}

@end
