//
//  PhotoButton.m
//
//  Created by AT on 6/18/12.
//

#import "TMEPhotoButton.h"
#import "PBImageHelper.h"
#import "AFPhotoEditorController.h"

#define DELETE_PHOTO  @"Delete Photo"
#define CHOOSE_PHOTO  @"Choose Photo"
#define TAKE_PHOTO    @"Take Photo"

@implementation TMEPhotoButton

@synthesize viewController;
@synthesize popoverController;
@synthesize photoSize;
@synthesize photoName;

- (void)initCommon
{
    // Create a default image for button
    [self addTarget: self action: @selector(button_clicked:) forControlEvents: UIControlEventTouchUpInside];
    
    UIImage *image = [PBImageHelper loadImageFromDocuments: photoName];
    if (!image) {
        image = [UIImage imageNamed:@"add-photo-placeholder"];
    }
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])){
        [self initCommon];
	}
	return self;
}

- (void)button_clicked: (id)sender
{
	self.selected = !self.selected;
  
  //Checks if button has image, if yes, add destructive button.
  id destructiveButton = self.photoName ? DELETE_PHOTO : nil;
  
    // cancel button will not show up on iPad
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:destructiveButton
                                otherButtonTitles:TAKE_PHOTO, CHOOSE_PHOTO, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  [actionSheet showInView: self.viewController.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:NO completion:nil];
    
    [self beforeGetImageWithPhotoButton:self];
    
    UIImage *image = nil;
    
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image) {
        UIGraphicsBeginImageContext(photoSize);
        [image drawInRect:CGRectMake(0, 0, photoSize.width, photoSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [PBImageHelper saveImageToDocuments:image withName:photoName];
    }
    
    [self didFinishGetImageWithImageUrl:photoName];
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) takeOrChoosePhoto:(BOOL) take
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing=YES;
    
    if (take) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Oh Snap" delegate:nil cancelButtonTitle:@"Failed to load the camera." otherButtonTitles:nil];
            [alert show];
        }
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; 
    }
    
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

- (void)deletePhoto
{
    [PBImageHelper deleteFileFromDocuments: photoName];
    UIImage *image = [UIImage imageNamed:@"add-photo-placeholder"];
    [self setBackgroundImage:image forState:UIControlStateNormal]; 
}

#pragma mark - UIActionSheetDelegate protocol

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index
{
    if ([[actionSheet buttonTitleAtIndex:index] isEqualToString:DELETE_PHOTO]) {        // delete photo
        [self deletePhoto];
    } else if ([[actionSheet buttonTitleAtIndex:index] isEqualToString:TAKE_PHOTO]) { // take photo
        [self takeOrChoosePhoto:TRUE];
    } else if ([[actionSheet buttonTitleAtIndex:index] isEqualToString:CHOOSE_PHOTO]) { // choose photo
        [self takeOrChoosePhoto:FALSE];
    } else {                       // cancel
      return;
    }
}

#pragma mark - Blocks actions
- (void)beforeGetImageWithPhotoButton:(TMEPhotoButton *)photoButton
{
    if ([self.viewController respondsToSelector:@selector(beforeGetImageWithPhotoButton:)]) {
        [self.viewController performSelector:@selector(beforeGetImageWithPhotoButton:) withObject:self];
    }
}
- (void)didFinishGetImageWithImageUrl:(NSString *)localURL
{
    if ([self.viewController respondsToSelector:@selector(didFinishGetImageWithImageUrl:)]) {
        [self.viewController performSelector:@selector(didFinishGetImageWithImageUrl:) withObject:localURL];
    }
}

@end