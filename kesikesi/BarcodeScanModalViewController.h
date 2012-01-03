//
//  BarcodeScanModalViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BarcodeScanModalViewDelegate <NSObject>
@required
- (void)setBarcodeAndUpload:(NSString*)barcode;
- (void)showBarcodeScanView;
@end

@interface BarcodeScanModalViewController : UIViewController {
    NSString *barcode;
    IBOutlet UITextView *textView;
    id <BarcodeScanModalViewDelegate> delegate;
}

@property (nonatomic, retain) NSString *barcode;
@property (nonatomic, retain) UITextView *textView;
@property (retain) id delegate;

- (void)showBarcodeScanView;

@end
