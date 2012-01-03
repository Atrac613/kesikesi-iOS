//
//  RootSchemeViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"

@interface RootSchemeViewController : UIViewController {
    PendingView *pendingView;
}

@property (nonatomic, retain) PendingView *pendingView;

- (void)showPendingView;
- (void)hidePendingView;

- (void)cancelButtonPressed;
- (NSDictionary *)getMaskModeJsonArray:(NSString*)imageKey;

@end
