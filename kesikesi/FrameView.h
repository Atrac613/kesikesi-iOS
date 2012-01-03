//
//  FrameView.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FingerPaintViewController;
@interface FrameView : UIView {
    FingerPaintViewController* viewController_;
    
    NSMutableArray* imageList_;
    
    NSInteger selectedIndex_;
}

@property (nonatomic, assign) IBOutlet FingerPaintViewController* viewController;
@property (nonatomic, retain) NSMutableArray* imageList;
@end
