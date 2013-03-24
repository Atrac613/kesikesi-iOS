//
//  ScratchViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ScratchViewController.h"
#import "NSString+MD5.h"

@implementation ScratchViewController

@synthesize imageKey;
@synthesize originalImage;
@synthesize maskImage;
@synthesize maskMode;
@synthesize accessCode;
@synthesize comment;
@synthesize commentLabel;
@synthesize soundTimer;
@synthesize bannerIsVisible;

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
    
    [self.navigationItem setTitle:@"KesiKesi"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
    
    NSLog(@"maskMode: %@", maskMode);
    NSLog(@"accessCode: %@", accessCode);
    NSLog(@"comment: %@", comment);
    
    commentLabel.text = comment;
    
    [self performSelectorOnMainThread:@selector(loadItems) withObject:self waitUntilDone:YES];
    
    if ([maskMode isEqualToString:@"sound_level"]) {
        NSArray *filepaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
                                                                 NSUserDomainMask,
                                                                 YES);
        NSString *documentDir = [filepaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:@"recording.caf"];
        NSURL *recordingURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        
        recorder = [[AVAudioRecorder alloc] initWithURL:recordingURL
                                               settings:nil
                                                  error:&error];
        
        
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        
        soundTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(summaryVolume:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [recorder record];
    } else if ([maskMode isEqualToString:@"accelerometer1"]) {
        accel = [UIAccelerometer sharedAccelerometer];
        accel.delegate = self;
        accel.updateInterval = 0.01f;
        moveSpeed = 0.f;
    } else if ([maskMode isEqualToString:@"accelerometer2"]) {
        accel = [UIAccelerometer sharedAccelerometer];
        accel.delegate = self;
        accel.updateInterval = 0.2f;
        moveSpeed = 0.f;
    } else if ([maskMode isEqualToString:@"barcode"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SCAN", @"") style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonPressed)];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString([maskMode uppercaseString], @"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([maskMode isEqualToString:@"sound_level"]) {
        [soundTimer invalidate];
        soundTimer = nil;
    } else if ([maskMode isEqualToString:@"accelerometer1"] || [maskMode isEqualToString:@"accelerometer2"]) {
        [accel setDelegate:nil];
        accel = nil;
    }
}


- (void)doneButtonPressed {
    NSLog(@"doneButtonPressed");
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)startActivityIndicator {
    UIActivityIndicatorView *beforeActivityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:100];
    
    if (beforeActivityIndicator) {
        [beforeActivityIndicator startAnimating];
        
        beforeActivityIndicator = nil;
    } else {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                       initWithFrame:CGRectMake(0, 0, 32.0f, 32.0f)];
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityIndicator.frame    = CGRectMake(0, 0, 32.0f, 32.0f);
        activityIndicator.tag = 100;
        
        [activityIndicator setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
    }
}

-(void)stopActivityIndicator {
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:100];
    
    if (activityIndicator) {
        [activityIndicator stopAnimating];
        activityIndicator = nil;
    }
}

- (void)loadItems {
    if (imageKey) {
        NSString *originalImageUrl;
        if (TARGET_IPHONE_SIMULATOR) {
            originalImageUrl = [NSString stringWithFormat:@"http://localhost:8089/api/v2/get_original_image?id=%@", [[NSString stringWithFormat:@"%@-%@", SECRET_IMAGE_KEY, imageKey] md5sum]];
        } else {
            originalImageUrl = [NSString stringWithFormat:@"http://kesikesi.atrac613.io/api/v2/get_original_image?id=%@", [[NSString stringWithFormat:@"%@-%@", SECRET_IMAGE_KEY, imageKey] md5sum]];
        }
        
        NSURL *url = [NSURL URLWithString:originalImageUrl];
        //originalImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL: url]]];
        
        originalImage.image = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:url]];
        
        NSString *maskImageUrl;
        if (TARGET_IPHONE_SIMULATOR) {
            maskImageUrl = [NSString stringWithFormat:@"http://localhost:8089/api/v2/get_mask_image?id=%@", [[NSString stringWithFormat:@"%@-%@", SECRET_MASK_KEY, imageKey] md5sum]];
        } else {
            maskImageUrl = [NSString stringWithFormat:@"http://kesikesi.atrac613.io/api/v2/get_mask_image?id=%@", [[NSString stringWithFormat:@"%@-%@", SECRET_MASK_KEY, imageKey] md5sum]];
        }
        
        url = [NSURL URLWithString:maskImageUrl];
        maskImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL: url]]];
        
        [self.view addSubview:maskImage];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![maskMode isEqualToString:@"scratch"]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![maskMode isEqualToString:@"scratch"]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];    
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(CGSizeMake(320, 320));
    [maskImage.image drawInRect:CGRectMake(0, 0, 320, 320)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGImageAlphaNone);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 30.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0, 0, 30);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    maskImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![maskMode isEqualToString:@"scratch"]) {
        return;
    }
    
    return;
}

- (void)summaryVolume:(NSTimer*)timer
{
    [recorder updateMeters];
    float pdB = [recorder peakPowerForChannel:0];
    float adB = [recorder averagePowerForChannel:0];
    
    /*
     count++;
     if(count > 200)
     {
     count = 0;
     [recorder stop];
     [recorder deleteRecording];
     [recorder record];
     }
     */
    
    float averageHeight = 1 + (adB /120 *2);
    float peakHeight    = 1 + (pdB /120 *2);
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    
    if (averageHeight > 0.6f) {
        [maskImage setAlpha:1.f - averageHeight*1.4f];
    } else {
        [maskImage setAlpha:1.f];
    }
    
    [UIView commitAnimations];
    
    NSLog(@"peakH:%f averageH:%f\n", peakHeight, averageHeight);
}

- (void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)acceleration {
    //NSLog(@"x: %g, %g, %g", acceleration.x, acceleration.y, acceleration.z);
    
    if ([maskMode isEqualToString:@"accelerometer1"]) {
        NSLog(@"Y: %f, X: %f", acceleration.y, ((10.f - (10.f + (acceleration.y)*10.f))) / 10.f);
        [maskImage setAlpha:((10.f - (10.f + (acceleration.y)*10.f))) / 10.f];
    } else if ([maskMode isEqualToString:@"accelerometer2"]) {
        NSTimeInterval elapsedTime = acceleration.timestamp - lastAccelTimestamp;
        
        float velocity = acceleration.x * elapsedTime;
        
        float alpha;
        if (velocity < 0) {
            alpha = 1.f - (10.f - (10.f + (velocity*2.3f)*10.f)) / 10.f;
        } else {
            alpha = 1.f - velocity*2.3f;
        }
        
        //NSLog(@"Velocity: %f", velocity);
        NSLog(@"Alpha: %f", alpha);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        [maskImage setAlpha:alpha];
        
        [UIView commitAnimations];
        
        lastAccelTimestamp = acceleration.timestamp;
    }
}

- (void)scanButtonPressed {
    ZBarReaderViewController *zBarReaderViewController = [ZBarReaderViewController new];
    zBarReaderViewController.readerDelegate = self;
    ZBarImageScanner *scanner = zBarReaderViewController.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self.navigationController presentModalViewController:zBarReaderViewController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    NSString *searchString;
    
    for(symbol in results) {
        searchString = symbol.data;
        NSLog(@"Code: %@", searchString);
        
        [self dismissModalViewControllerAnimated:YES];
        
        if ([searchString isEqualToString:accessCode]) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:4];
            [UIView setAnimationDelegate:self];
            
            [maskImage setAlpha:0.f];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            [UIView commitAnimations];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BARCODE_INVALID", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        
    }
    
    results = nil;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

@end
