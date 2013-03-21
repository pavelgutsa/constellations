//
//  ConstellationsViewController.m
//  Constellations
//
//  Created by Steve on 2/26/13.
//  Copyright (c) 2013 Steve. All rights reserved.
//

#import "ConstellationsViewController.h"

@interface ConstellationsViewController ()

@property (strong, atomic) UIButton *mSelectImageButton;
@property (strong, atomic) UIImageView *selectedImageView;

@property (strong, nonatomic) UIImagePickerController *picker;
//@property (strong, nonatomic) IBOutlet UIImageView * selectedImageView;

@end

@implementation ConstellationsViewController

@synthesize picker, selectedImageView;
@synthesize mSelectImageButton;
//@synthesize selectedImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup the image select button
    [self createImageSelectButton];
    [self enableImageSelectButton];
}

-(void)createImageSelectButton
{
    // Create the image select button
    UIImage *selectButtonImage = [UIImage imageNamed:@"ImageButton.jpg"];
    mSelectImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mSelectImageButton setBackgroundImage:selectButtonImage forState:UIControlStateNormal];
    
    // Get screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // Get image size
    CGSize selectButtonImageSize = selectButtonImage.size;
    
    // Put the button in the center of the view
    mSelectImageButton.frame = CGRectMake(
      (screenRect.size.width-selectButtonImageSize.width)/2,
      (screenRect.size.height-selectButtonImageSize.height)/2,
      selectButtonImageSize.width,
      selectButtonImageSize.height);
    
    NSLog(@"Select image button frame is set to x=%f, y=%f, width=%f, height=%f",
          (screenRect.size.width-selectButtonImageSize.width)/2,
          (screenRect.size.height-selectButtonImageSize.height)/2,
          selectButtonImageSize.width,
          selectButtonImageSize.height);
    
    [self.view addSubview:mSelectImageButton];
}

-(void)enableImageSelectButton
{
    [mSelectImageButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)disableImageSelectButton
{
    [mSelectImageButton removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)buttonClicked:(id)sender {
    NSLog(@"User clicked the image select button");
    
    // TODO: something useful
    picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //[self presentModalViewController:picker animated:YES];
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentModalViewController:picker animated:YES];
    }
}

// User cancelled image picking
- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    NSLog(@"User cancelled the Image Picker");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// User selects an image or takes a photo with the camera
- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"User selected an image with the Image Picker");
    
    // Assign the selected image
    UIImage* selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Dismiss the image picking dialog
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Get screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // Get image size
    CGSize selectedImageSize = selectedImage.size;

    // Scale the image
    UIImage* scaledImage = [self imageByScalingProportionallyToSize:selectedImage:screenRect.size];

    // Create selected image view
    selectedImageView = [[UIImageView alloc] initWithImage:scaledImage];
    selectedImageView.backgroundColor = [UIColor blackColor];
    
    //selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Put the selected image in the center of the view
    /*selectedImageView.frame = CGRectMake(
      (screenRect.size.width-selectedImageSize.width)/2,
      (screenRect.size.height-selectedImageSize.height)/2,
      selectedImageSize.width,
      selectedImageSize.height);
    
    NSLog(@"Selected image view frame is set to x=%f, y=%f, width=%f, height=%f",
          (screenRect.size.width-selectedImageSize.width)/2,
          (screenRect.size.height-selectedImageSize.height)/2,
          selectedImageSize.width,
          selectedImageSize.height);
    */
    // Sent image view frame to the full screen size
    selectedImageView.frame = [[UIScreen mainScreen] bounds];
    
    NSLog(@"Selected image view frame is set to x=%f, y=%f, width=%f, height=%f",
          selectedImageView.frame.origin.x,
          selectedImageView.frame.origin.y,
          selectedImageView.frame.size.width,
          selectedImageView.frame.size.height);
    
    // Hide the select picture button
    [mSelectImageButton removeFromSuperview];
    
    // Show the selected image view
    [self.view addSubview:selectedImageView];
}

- (UIImage *)imageByScalingProportionallyToSize:(UIImage *)sourceImage:(CGSize)targetSize {
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
