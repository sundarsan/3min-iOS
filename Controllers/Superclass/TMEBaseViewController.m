//
//  TMETMEBaseViewController.m
//  MyBaseProject
//
//  Created by Torin on 1/12/12.
//  Copyright (c) 2012 MyCompany. All rights reserved.
//

#import "TMEBaseViewController.h"

#define DEFAULT_KEYBOARD_HEIGHT   216

@class ADFormViewController;

@interface TMEBaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSValue *keyboardFrame;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, strong) UITapGestureRecognizer *tapToDismissKeyboardGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeToDimissKeyboardGestureRecognizer;

@end

@implementation TMEBaseViewController

- (UIViewController*)initWithNib
{
    NSString *className = NSStringFromClass([self class]);
    self = [self initWithNibName:className bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil)
        return self;
    
    self.shouldAvoidKeyboard = YES;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Tap to dismiss keyboard
    self.isKeyboardShowing = NO;
    self.tapToDismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    self.tapToDismissKeyboardGestureRecognizer.delegate = self;
    self.tapToDismissKeyboardGestureRecognizer.numberOfTapsRequired = 1;
    self.tapToDismissKeyboardGestureRecognizer.numberOfTouchesRequired = 1;
    [[self getScrollableView] addGestureRecognizer:self.tapToDismissKeyboardGestureRecognizer];
    
    [self addNavigationItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    DLog(@"Warning: Do not put any code in viewDidUnload. Deprecated since iOS 6.0");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Google Analytics
    self.trackedViewName = self.title;
    
    if (self.shouldAvoidKeyboard) {
        [self registerForKeyboardNotifications];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (NSString *notification in [self listNotificationInterests]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:notification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.parentViewController != nil) {
        [super viewDidDisappear:animated];
        return;
    }
    
    if (self.previousVCIsHome == NO) {
        [super viewDidDisappear:animated];
        return;
    }
    
    [super viewDidDisappear:animated];
}

#pragma mark - Rotations

//iOS 5.0 Rotations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

//iOS 6.0 Rotations
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait ;
}



#pragma mark - UI Helpers

- (UIViewController*)getViewControllerWithClassName:(NSString*)theClassName
{
    if ([theClassName length] <= 0)
        return nil;
    
    //Dynamically load the class
    Class theClass = NSClassFromString(theClassName);
    if (theClass == nil)
        return nil;
    
    NSObject* myViewController = [[theClass alloc] init];
    if (myViewController == nil)
        return nil;
    if ([myViewController isMemberOfClass:[UIViewController class]])
        return nil;
    
    return (UIViewController*)myViewController;
}

/*
 * Use a standard 'Back' button in navbar instead of title of previous view controller
 */
- (void)useStandardNavbarBackButton
{
    if (self.navigationController == nil)
        return;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:nil
                                                                     action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

- (void)setCustomNavbarLeftButtonTitle:(NSString*)title selector:(SEL)selector
{
    if (self.navigationController == nil)
        return;
    if ([title length] <= 0)
        return;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(title, title)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:selector];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)setCustomNavbarRightButtonTitle:(NSString*)title selector:(SEL)selector
{
    if (self.navigationController == nil)
        return;
    if ([title length] <= 0)
        return;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(title, title)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:selector];
    self.navigationItem.rightBarButtonItem = barButton;
}

/*
 * Auto adjust content size for UIScrollView according to its subviews
 */
- (void)autoAdjustScrollViewContentSize
{
    UIView * scrollView = [self getScrollableView];
    if ([scrollView respondsToSelector:@selector(autoAdjustScrollViewContentSize)])
        [scrollView performSelector:@selector(autoAdjustScrollViewContentSize)];
}

/*
 * Try to get the main scrollview in this VC, ignore if it's not scrollable
 */
- (UIView *)getScrollableView
{
    UIView *scrollView = nil;
    NSArray * propertyNames = @[@"scrollView", @"tableView", @"collectionView"];
    
    for (NSString * propertyName in propertyNames)
    {
        if (scrollView != nil)
            break;
        if ([self respondsToSelector:NSSelectorFromString(propertyName)] == NO)
            continue;
        
        UIScrollView * tempScrollView = [self valueForKey:propertyName];
        if (tempScrollView.userInteractionEnabled == NO)
            continue;
        if (tempScrollView.scrollEnabled == NO)
            continue;
        
        scrollView = tempScrollView;
    }
    
    if (scrollView == nil)
        scrollView = self.view;
    
    return scrollView;
}


#pragma mark - Helpers

//- (void)showWebviewWithURL:(NSString *)urlString
//{
//    BaseWebViewController *vc = [[BaseWebViewController alloc] initWithNib];
//    vc.url = urlString;
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Actions

- (IBAction)onBtnBack:(id)sender
{
    if (self.navigationController == nil || self.navigationController.viewControllers[0] == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    
    //Find the scrollView
    UIScrollView *scrollView = (UIScrollView *)[self getScrollableView];
    if (scrollView == nil)
        return YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [scrollView scrollSubviewToCenter:textField animated:YES];
    });
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.activeTextField = nil;
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - Keyboard events

/*
 * This is needed because iOS always return keyboard size in landscape orientation
 */
- (CGFloat)getCorrectKeyboardHeight:(CGSize)originalSize
{
    return MIN(originalSize.height, originalSize.width);
}

/*
 * This is needed because iOS always return keyboard size in landscape orientation
 */
- (CGFloat)getCorrectKeyboardWidth:(CGSize)originalSize
{
    return MAX(originalSize.height, originalSize.width);
}

- (void)onKeyboardWillShowNotification:(NSNotification *)sender
{
    self.isKeyboardShowing = YES;
    
    self.keyboardFrame = [[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize kbSize = [self.keyboardFrame CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve = [[[sender userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIScrollView *scrollView = (UIScrollView *)[self getScrollableView];
    if ([self respondsToSelector:@selector(textView)])
        scrollView = [self valueForKey:@"textView"];
    
    //Adjust tableView or scrollView inset
    if ([scrollView respondsToSelector:@selector(setContentInset:)])
    {
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
            [scrollView setContentInset:edgeInsets];
            [scrollView setScrollIndicatorInsets:edgeInsets];
        } completion:nil];
        return;
    }
    
    //Shift the entire view
    CGRect selfViewFrame = self.view.bounds;
    selfViewFrame.origin.y = -kbSize.height;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        self.view.frame = selfViewFrame;
    } completion:nil];
}

- (void)onKeyboardWillHideNotification:(NSNotification *)sender
{
    self.isKeyboardShowing = NO;
    
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve = [[[sender userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIScrollView *scrollView = (UIScrollView *)[self getScrollableView];
    if ([self respondsToSelector:@selector(textView)])
        scrollView = [self valueForKey:@"textView"];
    
    //Adjust tableView or scrollView inset
    if ([scrollView respondsToSelector:@selector(setContentInset:)])
    {
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            
            UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
            [scrollView setContentInset:edgeInsets];
            [scrollView setScrollIndicatorInsets:edgeInsets];
        } completion:nil];
        return;
    }
    
    //Shift the entire view
    CGRect selfViewFrame = self.view.bounds;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        self.view.frame = selfViewFrame;
    } completion:nil];
}

- (void)onTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self dismissKeyboard];
}

- (void)onSwipeDownGesture:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissKeyboard];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //Active this gesture only when keyboard is showing
    if ([gestureRecognizer isEqual:self.tapToDismissKeyboardGestureRecognizer])
        return self.isKeyboardShowing;
    if ([gestureRecognizer isEqual:self.swipeToDimissKeyboardGestureRecognizer])
        return self.isKeyboardShowing;
    
    return YES;
}

#pragma mark - Local notification helpers

- (void)sendNotification:(NSString *)notificationName
{
	[self sendNotification:notificationName body:nil type:nil];
}


- (void)sendNotification:(NSString *)notificationName body:(id)body
{
	[self sendNotification:notificationName body:body type:nil];
}

- (void)sendNotification:(NSString *)notificationName body:(id)body type:(id)type
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *dic = nil;
	if (body || type) {
		dic = [[NSMutableDictionary alloc] init];
		if (body) [dic setObject:body forKey:@"body"];
		if (type) [dic setObject:type forKey:@"type"];
	}
	NSNotification *n = [NSNotification notificationWithName:notificationName object:self userInfo:dic];
	[center postNotification:n];
}

- (NSArray *)listNotificationInterests
{
    return [NSArray array];
}

- (void)handleNotification:(NSNotification *)notification
{
    
}

#pragma marks - Some VC stuffs
- (void)addNavigationItems
{
    // Nav left button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (self == [[self.navigationController viewControllers] objectAtIndex:0]) {
        [leftButton setImage:[UIImage imageNamed:@"category-list-icon"] forState:UIControlStateNormal];
//        [leftButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [leftButton setImage:[UIImage imageNamed:@"category-list-icon"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(onBtnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    // Nav right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"grid-view-icon"] forState:UIControlStateNormal];
//    [rightButton addTarget:self.viewDeckController action:@selector(toggleRightView) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)onBtnBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)trackCritercismBreadCrumb:(NSUInteger)lineNumber
{
    NSString *breadcrumb = [NSString stringWithFormat:@"%@:%d", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], lineNumber];
    [Crittercism leaveBreadcrumb:breadcrumb];
}

@end