//
//  TMEBrowserCollectionCell.m
//  PhotoButton
//
//  Created by Triệu Khang on 13/10/13.
//
//

#import "TMEBrowserCollectionCell.h"

@interface TMEBrowserCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *lblProductName;
@property (weak, nonatomic) IBOutlet UILabel *lblProductPrice;

@end

@implementation TMEBrowserCollectionCell

- (void)configCellWithData:(TMEProduct *)product {
	NSArray *images = product.images;

	if (images.count > 0) {
		TMEProductImage *image = [images firstObject];
		NSURL *imageUrl = image.mediumURL;
		[self.imgProduct setImageWithURL:imageUrl
		                placeholderImage:[UIImage imageNamed:@"photo-placeholder"]];
	}

	self.lblProductName.text = product.name;
	self.lblProductPrice.text = [NSString stringWithFormat:@"%@ VND", product.price];
}

- (void)didSelectCellAnimation {
	[CAAnimation addAnimationToLayer:self.layer withKeyPath:@"transform.scale" duration:1 from:1 to:0.97 easingFunction:CAAnimationEasingFunctionEaseOutBack];
}

- (void)didDeselectCellAnimation {
	[CAAnimation addAnimationToLayer:self.layer withKeyPath:@"transform.scale" duration:1 from:0.97 to:1 easingFunction:CAAnimationEasingFunctionEaseOutBack];
}

+ (CGSize)productCellSize {
	return CGSizeMake(153, 190);
}

@end
