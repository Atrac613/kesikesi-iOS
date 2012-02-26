//
//  ImageUtil.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ImageUtil.h"
#import <QuartzCore/CALayer.h>

@implementation ImageUtil

-(UIImage *)getResizeImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize contentMode:(UIViewContentMode)contentMode {
    UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    [canvasView setImage:sourceImage];
    [canvasView setContentMode:contentMode];
    [canvasView setBackgroundColor:[UIColor blackColor]];
    
    UIGraphicsBeginImageContext(targetSize);
    [canvasView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* resizedPhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedPhoto;
}

@end