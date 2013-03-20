//
//  ConstellationsViewController.h
//  Constellations
//
//  Created by Steve on 2/26/13.
//  Copyright (c) 2013 Steve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConstellationsViewController : UIViewController

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIImageView * selectedImage;

@end
