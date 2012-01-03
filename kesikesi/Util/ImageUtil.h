//
//  ImageUtil.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ImageUtil : NSObject {
	
}

-(UIImage *)getResizeImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize contentMode:(UIViewContentMode)contentMode;

@end
