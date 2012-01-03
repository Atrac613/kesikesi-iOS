//
//  FrameView.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FrameView.h"
#import "FingerPaintViewController.h"


@implementation FrameView
@synthesize viewController;
@synthesize imageList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint p = CGPointZero;
    for (UIImage* image in self.imageList) {
        [image drawAtPoint:p];
        p.x += 70 + 5; // 70(width) + 5(margin)
    }
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{      
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];

    selectedIndex_ = location.x / (70 + 5);
    
    [self setNeedsDisplay];
    [self.viewController touchedAtIndex:selectedIndex_];
}
@end
