//
//  BarcodeScanModalViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "BarcodeScanModalViewController.h"

@implementation BarcodeScanModalViewController

@synthesize delegate;
@synthesize barcode;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textView.text = self.barcode;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectButtonPressed:(id)sender {
    [self.delegate setBarcodeAndUpload:self.barcode];
}

- (IBAction)scanButtonPressed:(id)sender {
    [self performSelector:@selector(showBarcodeScanView) withObject:nil afterDelay:0.5];
}

- (void)showBarcodeScanView {
    [self.delegate showBarcodeScanView];
}

@end
