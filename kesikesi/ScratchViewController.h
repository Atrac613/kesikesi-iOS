//
//  ScratchViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderViewController.h"
#import <iAd/iAD.h>

@interface ScratchViewController : UIViewController <ADBannerViewDelegate, AVAudioRecorderDelegate, UIAccelerometerDelegate,ZBarReaderDelegate> {
    NSString *imageKey;
    IBOutlet UIImageView *originalImage;
    UIImageView *maskImage;
    
    CGPoint lastPoint;
	BOOL mouseSwiped;	
	int mouseMoved;
    
    NSString *maskMode;
    NSString *accessCode;
    NSString *comment;
    IBOutlet UILabel *commentLabel;
    
    AVAudioRecorder *recorder;
    NSTimer *soundTimer;
    UIAccelerometer *accel;
    UIButton *scanButton;
    
    float moveSpeed;
    float lastAccelTimestamp;
    
    BOOL bannerIsVisible;
}

@property (nonatomic, retain) NSString *imageKey;
@property (nonatomic, retain) IBOutlet UIImageView *originalImage;
@property (nonatomic, retain) UIImageView *maskImage;
@property (nonatomic, retain) NSString *maskMode;
@property (nonatomic, retain) NSString *accessCode;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;
@property (nonatomic, retain) NSTimer *soundTimer;
@property (nonatomic, assign) BOOL bannerIsVisible;

- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)loadItems;
- (void)doneButtonPressed;
- (void)summaryVolume:(NSTimer*)timer;
- (void)scanButtonPressed;

@end
