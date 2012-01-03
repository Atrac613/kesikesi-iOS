//
//  AppDelegate.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KesiKesiService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    // edited image.
    UIImage *imageSource;
    
    // maked image.
    UIImage *originalImage;
    UIImage *maskImage;
    NSString *maskMode;
    NSString *accessCode;
    
    NSOperationQueue *operationQueue;
    NSString *imageKey;
    KesiKesiService *kService;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UIImage *imageSource;
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *maskImage;
@property (nonatomic, retain) NSString *maskMode;
@property (nonatomic, retain) NSString *accessCode;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSString *imageKey;
@property (nonatomic, retain) KesiKesiService *kService;

@end
