//
//  TMEBrowerProductsTableCell.m
//  PhotoButton
//
//  Created by Triệu Khang on 19/9/13.
//
//

#import "TMEBrowserProductsTableCell.h"
#import "PBImageHelper.h"

@interface TMEBrowserProductsTableCell()

// product
@property (weak, nonatomic) IBOutlet UIImageView    * imgProductImage;
@property (weak, nonatomic) IBOutlet UIButton       * btnProductCategory;
@property (weak, nonatomic) IBOutlet UILabel        * lblProductName;
@property (weak, nonatomic) IBOutlet UILabel        * lblProductPrice;

// user
@property (weak, nonatomic) IBOutlet UIImageView    * imgUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel        * lblUserName;
@property (weak, nonatomic) IBOutlet UILabel        * lblTimestamp;

// social
@property (weak, nonatomic) IBOutlet UIButton       * btnFollow;
@property (weak, nonatomic) IBOutlet UIButton       * btnComment;
@property (weak, nonatomic) IBOutlet UIButton       * btnShare;

@end

@implementation TMEBrowserProductsTableCell

- (void)configCellWithProduct:(TMEProduct *)product{
    
    // Follow button
    self.btnFollow.layer.borderWidth = 1;
    self.btnFollow.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnFollow.layer.cornerRadius = 3;
    
    // Comment button
    self.btnComment.layer.borderWidth = 1;
    self.btnComment.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnComment.layer.cornerRadius = 3;
    
    // Share button
    self.btnShare.layer.borderWidth = 1;
    self.btnShare.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnShare.layer.cornerRadius = 3;
    
    // for now when we get product, we get all imformantion about this product like user, category, etc.
    
    // user
    self.imgUserAvatar.image = nil;
    [self.imgUserAvatar setImageWithURL:[NSURL URLWithString:product.user.photo_url] placeholderImage:nil];
    self.lblUserName.text = product.user.username;
    self.lblTimestamp.text = [product.created_at relativeDate];
    
    NSURL *imageURL = [NSURL URLWithString:product.category.photo_url];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.imageView.image = [UIImage imageWithData:imageData];
            [self.btnProductCategory setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        });
    });
    
    TMEProductImages *img = [product.images anyObject];
    [self.imgProductImage setImageWithURL:[NSURL URLWithString:img.medium] placeholderImage:nil];
    [self.imgProductImage clipsToBounds];
    
    self.lblProductName.text = product.name;
    self.lblProductPrice.text = [NSString stringWithFormat:@"$%@", [product.price stringValue]];
    
}
- (IBAction)onBtnComment:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onBtnComment)]) {
        [self.delegate performSelector:@selector(onBtnComment)];
    }
}

+ (CGFloat)getHeight{
    return 440;
}

@end
