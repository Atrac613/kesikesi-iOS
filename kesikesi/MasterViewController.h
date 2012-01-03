//
//  MasterViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"
#import "ZBarReaderViewController.h"

@interface MasterViewController : UIViewController <ZBarReaderDelegate, UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIPickerViewDelegate> {
    IBOutlet UIWebView *webView;
    PendingView *pendingView;
    
    NSString *pickerMode;
    
    NSArray *imagePickerMode;
    UIPickerView *pickerView;
	UIToolbar *pickerToolbar;
	UIActionSheet *pickerViewPopup;
    
    BOOL refreshArchive;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) PendingView *pendingView;

@property (nonatomic, retain) NSString *pickerMode;

@property (nonatomic, retain) NSArray *imagePickerMode;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIToolbar *pickerToolbar;
@property (nonatomic, retain) UIActionSheet *pickerViewPopup;

@property (nonatomic) BOOL refreshArchive;

- (void)composeButtonPressed;
- (void)homeButtonPressed;

- (void)refreshMyArchives;

- (void)showPendingView;
- (void)hidePendingView;

- (void)showPickerView;
- (void)showLibraryView;
- (void)showCameraView;

- (NSDictionary *)getMaskModeJsonArray:(NSString*)imageKey;

@end
