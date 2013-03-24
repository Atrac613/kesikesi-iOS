//
//  FingerPaintViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
#import "FrameView.h"
#import <opencv2/imgproc/imgproc_c.h>
#import "GAITrackedViewController.h"

@interface FingerPaintViewController : GAITrackedViewController <UIAlertViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, ZBarReaderDelegate>{
    IBOutlet UIImageView *imageView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *chooseLabel;
    FrameView *frameThumnailView;
    
    CGPoint lastPoint;
    UIImageView *drawImage;
    UIImageView *maskImage;
    BOOL mouseSwiped;    
    int mouseMoved;
    
    UIAlertView *alertView;
    UIActivityIndicatorView *indicator;
    
    UIPickerView *pickerView;
    UIToolbar *pickerToolbar;
    UIActionSheet *pickerViewPopup;
    
    NSArray *maskModeArray;
    NSArray *maskTypeArray;
    
    NSInteger currentMaskId;
    UIImage *currentMask;
    
    NSString *alertMode;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet FrameView *frameThumnailView;
@property (nonatomic, retain) IBOutlet UILabel *chooseLabel;
@property (nonatomic, retain) UIImageView *drawImage;
@property (nonatomic, retain) UIImageView *maskImage;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIToolbar *pickerToolbar;
@property (nonatomic, retain) UIActionSheet *pickerViewPopup;
@property (nonatomic, retain) NSArray *maskModeArray;
@property (nonatomic, retain) NSArray *maskTypeArray;
@property (nonatomic) NSInteger currentMaskId;
@property (nonatomic, retain) UIImage *currentMask;
@property (nonatomic, retain) NSString *alertMode;

- (void)cancelButtonPressed;
- (void)nextButtonPressed;
- (void)makeImage;

- (void)showMaskModePickerView;

- (void)setBarcodeAndUpload:(NSString*)barcode;
- (void)showBarcodeScanModalView:(NSArray*)params;
- (void)showBarcodeScanView;

- (void)touchedAtIndex:(NSInteger)index;

- (void)replaceDrawImage:(NSInteger)maskId;
- (UIImage *)maskImage:(NSInteger)maskId;

- (UIImage*)filterImage:(NSInteger)filterId originalImage:(UIImage *)originalImage;

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
- (UIImage *)CreateUIImageFromIplImage:(IplImage *)image;
- (IplImage *)doMosaic:(IplImage*)sourceImage x0:(int)x0 y0:(int)y0 width:(int)width height:(int)height size:(int)size;

- (void)makeMaskImage:(NSInteger)maskId;

@end
