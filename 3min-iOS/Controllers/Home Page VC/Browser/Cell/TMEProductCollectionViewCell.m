//
//  TMEProductCollectionViewCell.m
//  ThreeMin
//
//  Created by Triệu Khang on 9/8/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

@class KHRoundAvatar;

#import <QuartzCore/QuartzCore.h>
#import "TMEProductCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+ProductCollectionCellLoadImage.h"
#import "KHRoundAvatar.h"

@interface TMEProductCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *borderRadiusView;

@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;

@property (weak, nonatomic) IBOutlet UILabel *lblProductPrice;

@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@property (weak, nonatomic) IBOutlet KHRoundAvatar *userAvatar;

@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblDatetime;

@end

@implementation TMEProductCollectionViewCell

#pragma mark - Inits

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self addShadowAndBorderRadius];
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		// Initialization code
		[self addShadowAndBorderRadius];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self addShadowAndBorderRadius];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addShadowAndBorderRadius];
    [self _addGestures];
}

- (void)prepareForReuse {
	[super prepareForReuse];
    [self.imgProduct cancelImageRequestOperation];
    [self.userAvatar cancelImageRequestOperation];
	[self resetContent];
}

#pragma mark -

- (void)_addGestures {
    UITapGestureRecognizer *tapToViewDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCell:)];
    tapToViewDetails.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapToViewDetails];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)addShadowAndBorderRadius {
    self.opaque = YES;

	self.borderRadiusView.layer.cornerRadius = 3.0f;
	self.borderRadiusView.layer.masksToBounds = YES;
	self.layer.shadowColor = [UIColor colorWithHexString:@"#aaa"].CGColor;
	self.layer.shadowRadius = 0;
	self.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    self.layer.shadowOpacity = .3f;

    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

#pragma mark -

- (void)configWithData:(TMEProduct *)product {
	NSCParameterAssert(product);
	NSAssert([product isKindOfClass:[TMEProduct class]], @"Need product to config product cell");

    self.lblProductName.text = product.name;
    self.lblProductName.font = [UIFont openSansRegularFontWithSize:15];
    self.lblProductName.textColor = [UIColor colorWithHexString:@"333"];

    self.lblProductPrice.text = product.price;
    self.lblProductPrice.font = [UIFont openSansRegularFontWithSize:11];
    self.lblProductPrice.textColor = [UIColor colorWithHexString:@"ff401a"];

    self.btnLike.titleLabel.text = NSStringf(@"%d", product.likeCount);
	self.btnLike.selected = product.liked;

	self.btnComment.titleLabel.text = product.comments;

	self.lblUsername.text = product.user.fullName;
    self.lblUsername.font = [UIFont openSansSemiBoldFontWithSize:12];
    self.lblUsername.textColor = [UIColor colorWithHexString:@"333"];
	self.lblUsername.text = [product.createAt relativeDate];
}

- (void)loadImages:(TMEProduct *)product
{
	TMEProductImage *firstImage = [product.images firstObject];
	[self.imgProduct tme_setImageWithURL:firstImage.mediumURL placeholderImage:[UIImage imageNamed:@"photo-placeholder"]];

	NSURL *avatarUrl = [NSURL URLWithString:product.user.avatar];
	[self.userAvatar tme_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar_holding"]];
}

#pragma mark - Reset

- (void)resetContent {
	self.imgProduct.image = nil;

	self.lblProductName.text = @"";
	self.lblProductPrice.text = @"";

	self.btnComment.titleLabel.text = @"";
	self.btnLike.titleLabel.text = @"";

	self.lblDatetime.text = @"";
	self.lblUsername.text = @"";
}

#pragma mark - Actions

- (IBAction)onBtnLike:(UIButton *)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnLikeProductOnCell:)]) {
		return;
	}
	TMEProductCollectionViewCell *cell = [self getCellFromButton:sender];
	[self.delegate tapOnLikeProductOnCell:cell];
}

- (IBAction)onBtnComment:(UIButton *)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnCommentProductOnCell:)]) {
		return;
	}
	TMEProductCollectionViewCell *cell = [self getCellFromButton:sender];
	[self.delegate tapOnCommentProductOnCell:cell];
}

- (IBAction)onBtnShare:(id)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnShareProductOnCell:)]) {
		return;
	}
	TMEProductCollectionViewCell *cell = [self getCellFromButton:sender];
	[self.delegate tapOnShareProductOnCell:cell];
}

- (IBAction)onBtnViewProfile:(id)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnViewProfileOnProductOnCell:)]) {
		return;
	}
	TMEProductCollectionViewCell *cell = [self getCellFromButton:sender];
	[self.delegate tapOnViewProfileOnProductOnCell:cell];
}

- (IBAction)onTapCell:(id)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnDetailsProductOnCell:)]) {
		return;
	}
	[self.delegate tapOnDetailsProductOnCell:self];
}

- (IBAction)onDoubleTap:(id)sender {
	if (![self.delegate respondsToSelector:@selector(tapOnLikeProductOnCell:)]) {
		return;
	}
	[self.delegate tapOnLikeProductOnCell:self];
}

#pragma mark - Helpers

- (TMEProductCollectionViewCell *)getCellFromButton:(UIButton *)button {
	UIView *temp = button;
	while (!([temp.superview isKindOfClass:[UICollectionViewCell class]]
	         || !temp.superview)) {
		temp = temp.superview;
	}

	TMEProductCollectionViewCell *cell = (TMEProductCollectionViewCell *)temp.superview;
	NSAssert([cell isKindOfClass:[UICollectionViewCell class]], @"Something when wrong, cell not be found");
	return cell;
}

@end
