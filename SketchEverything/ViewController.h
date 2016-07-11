//
//  ViewController.h
//  SketchEverything
//
//  Created by Xu He on 16/05/14.
//  Copyright (c) 2014 xhe585. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBar;


- (IBAction)sketchPhoto:(UIButton *)sender;
- (IBAction)resetPhoto:(UIButton *)sender;
- (IBAction)reliefPhoto:(UIButton *)sender;





- (UIImage *) setImage: (UIImage *) image;
- (UIImage *) toHumanGrayscale: (UIImage *) inputI;
- (UIImage *) sketchImage: (UIImage *) inputI :(int) threshold;
- (UIImage *) sculptureImage: (UIImage *) inputI;
@end
