//
//  TMEEditProductNameVC.m
//  ThreeMin
//
//  Created by Khoa Pham on 11/18/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

#import "TMEEditProductNameVC.h"
#import <CoreLocation/CoreLocation.h>
#import <SZTextView.h>

@interface TMEEditProductNameVC () <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet SZTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@property (nonatomic, strong) CLGeocoder *geoCoder;

@end

@implementation TMEEditProductNameVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationItems];
    [self setupTableView];
    [self setupGR];

    self.descriptionTextView.placeholder = @"Product description";

    [self displayProduct];
    [self setupLocationInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.view removeGestureRecognizer:self.tapGR];
}


#pragma mark - Setup
- (void)setupNavigationItems
{
    self.title = @"Description";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem cancelItemWithTarget:self action:@selector(cancelTouched:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneItemWithTarget:self action:@selector(doneTouched:)];
}

- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setupGR
{
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:self.tapGR];
}

- (void)setupLocationInfo
{
    self.locationTextField.text = nil;

    self.geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.product.venueLat.doubleValue longitude:self.product.venueLong.doubleValue];

    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.lastObject;
        if (placemark && placemark.locality && placemark.country) {
            self.locationTextField.text = NSStringf(@"%@, %@", placemark.locality, placemark.country);
        }
    }];
}

- (void)displayProduct
{
    self.nameTextField.text = self.product.name;
    self.descriptionTextView.text = self.product.productDescription;
}

#pragma mark - Action
- (void)viewTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)doneTouched:(id)sender
{
    self.product.name = self.nameTextField.text;
    self.product.productDescription = self.descriptionTextView.text;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 2) {
        // Location
    }
}

@end
