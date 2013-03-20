//
//  RootSchemeViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootSchemeViewController : UIViewController {
    
}

- (void)showPendingView;
- (void)hidePendingView;

- (void)cancelButtonPressed;
- (NSDictionary *)getMaskModeJsonArray:(NSString*)imageKey;

@end
