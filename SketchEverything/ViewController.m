//
//  ViewController.m
//  SketchEverything
//
//  Created by Xu He on 16/05/14.
//  Copyright (c) 2014 xhe585. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
{
    CIContext *context1;
    CIFilter *filter;
    CIImage *beginImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picture/background.jpg"]];
    UIImage *initImage = [UIImage imageNamed:@"picture/Pencil-icon.png"];
    self.imageView.image = initImage;
    beginImage = [CIImage imageWithCGImage:initImage.CGImage];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    //------------------bar button---------------------
    UIBarButtonItem *openPic = [[UIBarButtonItem alloc]initWithTitle:@"Open" style:UIBarButtonItemStyleBordered target:self action:@selector(open)];
    UIBarButtonItem *sharePic = [[UIBarButtonItem alloc]initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(share)];
    self.navigationBar.leftBarButtonItem = openPic;
    self.navigationBar.rightBarButtonItem = sharePic;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)open {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Open Photo" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Camera", nil];
    
    sheet.delegate = self;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index {
    if(index == 0)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    if(index == 1)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notice" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
//http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/
- (void)share
{
    NSString *message = @"Share";
    UIImage* imageToShare = self.imageView.image;
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[message, imageToShare]
     applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];

}

- (IBAction)sketchPhoto:(UIButton *)sender {
    UIImage *uiImage = [[UIImage alloc] initWithCIImage:beginImage];
    UIImage *image = [self setImage:uiImage];
    UIImage *realGrayImage = [self toHumanGrayscale:image];
    UIImage *sketchImage = [self sketchImage:realGrayImage :12];
    //UIImage *pencilImage = [self reliefImage:grayImage :0];
    self.imageView.image = sketchImage;
}

- (IBAction)resetPhoto:(UIButton *)sender {
    UIImage *uiImage = [[UIImage alloc] initWithCIImage:beginImage];
    UIImage *image = [self setImage:uiImage];
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (IBAction)reliefPhoto:(UIButton *)sender {
    UIImage *uiImage = [[UIImage alloc] initWithCIImage:beginImage];
    UIImage *image = [self setImage:uiImage];
    UIImage *realGrayImage = [self toHumanGrayscale:image];
    UIImage *sculptureImage = [self sculptureImage:realGrayImage];
    self.imageView.image = sculptureImage;
}






- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    beginImage = [CIImage imageWithCGImage:chosenImage.CGImage];
    self.imageView.image = chosenImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (UIImage *) setImage: (UIImage *) image
{
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect rec = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 0.0f);
    CGContextFillRect(ctx, rec);
    [image drawInRect:rec blendMode:kCGBlendModeLuminosity alpha:1.0f];
    [image drawInRect:rec blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;

}

//http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
- (UIImage *) toHumanGrayscale: (UIImage *) inputI
{
    const int RED = 3;
    const int GREEN = 2;
    const int BLUE = 1;
    
    CGRect imageRect = CGRectMake(0, 0, inputI.size.width * inputI.scale, inputI.size.height * inputI.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    

    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputI CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            uint8_t gray = (uint8_t) ((30 * rgbaPixel[RED] + 59 * rgbaPixel[GREEN] + 11 * rgbaPixel[BLUE]) / 100);
            
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:inputI.scale
                                           orientation:UIImageOrientationUp];
    
    CGImageRelease(image);
    
    return resultUIImage;
}


//http://qinxuye.me/article/implement-sketch-and-pencil-with-pil/
- (UIImage *) sketchImage: (UIImage *) inputI :(int) threshold
{
    const int RED = 3;
    const int GREEN = 2;
    const int BLUE = 1;
    
    CGRect imageRect = CGRectMake(0, 0, inputI.size.width * inputI.scale, inputI.size.height * inputI.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputI CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            if (x == width-1 || y == height-1) {
                continue;
            }
            uint8_t *rgbaPixel_src = (uint8_t *) &pixels[y * width + x];
            uint8_t *rgbaPixel_des = (uint8_t *) &pixels[(y+1) * width + (x+1)];
            uint8_t src = rgbaPixel_src[RED];
            uint8_t des = rgbaPixel_des[RED];
            
            uint8_t diff = abs(src-des);
            if (diff >= threshold) {
                rgbaPixel_src[RED] = 0;
                rgbaPixel_src[GREEN] = 0;
                rgbaPixel_src[BLUE] = 0;
            } else {
                rgbaPixel_src[RED] = 255;
                rgbaPixel_src[GREEN] = 255;
                rgbaPixel_src[BLUE] = 255;
            }
        
        }
    }

    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);

    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:inputI.scale
                                           orientation:UIImageOrientationUp];
    
    CGImageRelease(image);
    
    return resultUIImage;
}

- (UIImage *) sculptureImage:(UIImage *)inputI
{
    const int RED = 3;
    const int GREEN = 2;
    const int BLUE = 1;
    
    CGRect imageRect = CGRectMake(0, 0, inputI.size.width * inputI.scale, inputI.size.height * inputI.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputI CGImage]);
    
    uint8_t *preC = (uint8_t *) &pixels[0];
    uint8_t preR = preC[RED];
    uint8_t preG = preC[GREEN];
    uint8_t preB = preC[BLUE];
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *currC = (uint8_t *) &pixels[y * width + x];
            uint8_t r = currC[RED]-preR+128;
            uint8_t g = currC[GREEN]-preG+128;
            uint8_t b = currC[BLUE]-preB+128;
            uint8_t gray = (uint8_t)(r*0.3+g*0.59+b*0.11);

            preR = currC[RED];
            preG = currC[GREEN];
            preB = currC[BLUE];
            currC[RED] = gray;
            currC[GREEN] = gray;
            currC[BLUE] = gray;
            
        }
    }
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:inputI.scale
                                           orientation:UIImageOrientationUp];
    
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
