//
//  TMESubmitTableCellRight.m
//  PhotoButton
//
//  Created by admin on 12/25/13.
//
//

#import "TMESubmitTableCellRight.h"

@interface TMESubmitTableCellRight()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@end

@implementation TMESubmitTableCellRight

- (void)configCellWithMessage:(TMEMessage *)message andSeller:(TMEUser *)seller
{
    if ([message.from.id isEqual:seller.id]) {
        self.lblUsername.text = seller.fullname;
        [self.imageViewAvatar setImageWithURL:[NSURL URLWithString:seller.photo_url]];
    }
    else
    {
        self.lblUsername.text = message.from.fullname;
        [self.imageViewAvatar setImageWithURL:[NSURL URLWithString:message.from.photo_url]];
    }
    
    self.lblContent.text = message.chat;
    [self.lblContent sizeToFitKeepWidth];
    self.lblTime.text = [message.time_stamp relativeDate];
}

+ (CGFloat)getHeight{
    return 107;
}

- (CGFloat)getHeightWithContent:(NSString *)content{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 295, 26)];
    label.text = content;
    [label sizeToFitKeepWidth];
    return [TMESubmitTableCellRight getHeight] + [label expectedHeight] - 26;
}
@end