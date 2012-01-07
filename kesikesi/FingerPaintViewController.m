//
//  FingerPaintViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FingerPaintViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+MD5.h"
#import "BarcodeScanModalViewController.h"
#import "UploadViewController.h"

@implementation FingerPaintViewController

@synthesize imageView;
@synthesize drawImage;
@synthesize maskImage;
@synthesize alertView;
@synthesize chooseLabel;
@synthesize indicator;
@synthesize pickerView;
@synthesize pickerToolbar;
@synthesize pickerViewPopup;
@synthesize maskModeArray;
@synthesize maskTypeArray;
@synthesize scrollView;
@synthesize frameThumnailView;
@synthesize currentMaskId;
@synthesize currentMask;
@synthesize alertMode;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NEXT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed)];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    imageView.image = appDelegate.imageSource;
    
    maskImage = [[UIImageView alloc] initWithImage:nil];
	maskImage.frame = CGRectMake(0, 0, 320, 320);
    maskImage.backgroundColor = [UIColor whiteColor];
    
    drawImage = [[UIImageView alloc] initWithImage:nil];
	drawImage.frame = CGRectMake(0, 0, 320, 320);
	mouseMoved = 0;
    
    maskModeArray = [[NSArray alloc] initWithObjects:@"scratch", @"accelerometer1", @"accelerometer2", @"sound_level", @"barcode", nil];
    
    maskTypeArray = [[NSArray alloc] initWithObjects:@"black", @"mosaic", @"caution", @"zebra", @"note", nil];
    
    alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"RUB_WITH_YOUR_FINGER", @"Rub with your finger the area that you want to hide.") delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    
    chooseLabel.text = NSLocalizedString(@"CHOOSE_MASK_TYPE", @"");
    
    NSMutableArray* imageList = [NSMutableArray array];
    for (int i=0; i < 6; i++) {
        UIImage* image = [UIImage imageNamed:
                          [NSString stringWithFormat:@"btn%d.png", i]];
        [imageList addObject:image];
    }
    
    self.frameThumnailView.imageList = imageList;
    CGRect rect = CGRectMake(10, 0, (70+5)*6 + 13, 70);
    self.frameThumnailView.frame = rect;
    self.scrollView.contentSize = rect.size;
    
    currentMaskId = 0;
    
    [self makeMaskImage:currentMaskId];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//if ([self.view.subviews containsObject:pendingView]) {
    //    return;
    //}
	mouseSwiped = NO;
	UITouch *touch = [touches anyObject];
	
	lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //if ([self.view.subviews containsObject:pendingView]) {
    //    return;
    //}
    
	mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self.view];
	
	UIGraphicsBeginImageContext(self.maskImage.frame.size);
	[maskImage.image drawInRect:CGRectMake(0, 0, 320, 320)];
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	maskImage.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    [self replaceDrawImage:currentMaskId];
	
	lastPoint = currentPoint;
	
	mouseMoved++;
	
	if (mouseMoved == 10) {
		mouseMoved = 0;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//if ([self.view.subviews containsObject:pendingView]) {
    //    return;
    //}
	
	if(!mouseSwiped) {
		UIGraphicsBeginImageContext(self.maskImage.frame.size);
		[maskImage.image drawInRect:CGRectMake(0, 0, 320, 320)];
		CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		CGContextFlush(UIGraphicsGetCurrentContext());
		maskImage.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
        [self replaceDrawImage:currentMaskId];
	}
}

- (void)cancelButtonPressed {
    NSLog(@"cancelButtonPressed");
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)nextButtonPressed {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self makeImage];
    
    appDelegate.maskMode = @"scratch";
    appDelegate.maskType = [maskTypeArray objectAtIndex:currentMaskId];
    appDelegate.accessCode = @"";
    
    UploadViewController *uploadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadView"];
    [self.navigationController pushViewController:uploadViewController animated:YES];
}

- (void)makeImage {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect screenRect = CGRectMake(0, 0, 320, 320);
	UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor clearColor] set];
	CGContextFillRect(ctx, screenRect);
	
	[self.drawImage.layer renderInContext:ctx];
	
	appDelegate.maskImage = UIGraphicsGetImageFromCurrentImageContext();
	//UIImageWriteToSavedPhotosAlbum(maskImage, nil, nil, nil);
	UIGraphicsEndImageContext();
    
    /*
     screenRect = CGRectMake(0, 0, 320, 320);
     UIGraphicsBeginImageContext(screenRect.size);
     
     ctx = UIGraphicsGetCurrentContext();
     [[UIColor clearColor] set];
     CGContextFillRect(ctx, screenRect);
     
     [self.imageView.layer renderInContext:ctx];
     */
    
	appDelegate.originalImage = appDelegate.imageSource;
	//UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
	//UIGraphicsEndImageContext();
}

- (void)showMaskModePickerView {
	pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Mask mode"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
	
	pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,44,0,0)];
	
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;
	
	pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePicker:)];
	[barItems addObject:doneBtn];
    
	[pickerToolbar setItems:barItems animated:YES];
	
	[pickerViewPopup addSubview:pickerToolbar];
	[pickerViewPopup addSubview:pickerView];
	[pickerViewPopup showInView:self.view];
	[pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
}

-(BOOL)closePicker:(id)sender
{
    NSString *maskMode = [self.maskModeArray objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSLog(@"maskMode: %@", maskMode);
    
	[pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([maskMode isEqualToString:@"barcode"]) {
        [self showBarcodeScanView];
    } else {
        //[self showPendingView];
        
        NSArray *params = [[NSArray alloc] initWithObjects:maskMode, @"", nil];
        [self performSelectorOnMainThread:@selector(uploadFingerPaint:) withObject:params waitUntilDone:YES];
    }
    
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [maskModeArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return NSLocalizedString([[maskModeArray objectAtIndex:row] uppercaseString], @"");
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    NSString *searchString;
    
    for(symbol in results) {
        searchString = symbol.data;
        NSLog(@"Code: %@", searchString);
        
        [self dismissModalViewControllerAnimated:YES];
        
        NSArray *params = [[NSArray alloc] initWithObjects:searchString, nil];
        [self performSelector:@selector(showBarcodeScanModalView:) withObject:params afterDelay:0.5];
    }
    
    results = nil;
}

- (void)showBarcodeScanModalView:(NSArray*)params {
    BarcodeScanModalViewController *barcodeScanModalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BarcodeScanModalView"];
    barcodeScanModalViewController.delegate = self;
    barcodeScanModalViewController.barcode = [params objectAtIndex:0];
    [self.navigationController presentModalViewController:barcodeScanModalViewController animated:YES];
}

- (void)setBarcodeAndUpload:(NSString*)barcode {
    [self dismissModalViewControllerAnimated:YES];
    //[self showPendingView];
    
    NSArray *params = [[NSArray alloc] initWithObjects:@"barcode", barcode, nil];
    [self performSelectorOnMainThread:@selector(uploadFingerPaint:) withObject:params waitUntilDone:YES];
}

- (void)showBarcodeScanView {
    ZBarReaderViewController *zBarReaderViewController = [ZBarReaderViewController new];
    zBarReaderViewController.readerDelegate = self;
    ZBarImageScanner *scanner = zBarReaderViewController.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self.navigationController presentModalViewController:zBarReaderViewController animated:YES];
}

- (void)touchedAtIndex:(NSInteger)index
{
    if (index == 5) {
        alertMode = @"ClearConfirm";
        alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CLEAR_MASK_CONFIRM", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") otherButtonTitles:NSLocalizedString(@"DELETE", @""), nil];
        [alertView show];
    } else {
        currentMaskId = index;
    
        [self makeMaskImage:currentMaskId];
        [self replaceDrawImage:currentMaskId];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertMode isEqualToString:@"ClearConfirm"]) {
        if (buttonIndex == 1) {
            [drawImage removeFromSuperview];
            
            maskImage = nil;
            maskImage = [[UIImageView alloc] initWithImage:nil];
            maskImage.frame = CGRectMake(0, 0, 320, 320);
            maskImage.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)replaceDrawImage:(NSInteger)maskId; {
    [drawImage removeFromSuperview];
    
    drawImage.image = [self maskImage:maskId];
    
    [self.view addSubview:drawImage];
}

- (UIImage*)maskImage:(NSInteger)maskId {
    // Mask image.
    UIColor *color = [UIColor whiteColor];
    CGRect rect = CGRectMake(0.0f, 0.0f, 320.f, 320.f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *baseLayer = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(320, 320));  
    [baseLayer drawInRect:rect];  
    [maskImage.image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];  
    UIImage *maskImage_ = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext(); 
    
    // Mask image convert to CGImage.
    CGImageRef maskRef = maskImage_.CGImage; 
    // Create mask.
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    // Clip from mask.
    CGImageRef masked = CGImageCreateWithMask([currentMask CGImage], mask);
    // CGImage convert to UIImage.
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return maskedImage;
}

- (UIImage*)filterImage:(NSInteger)filterId originalImage:(UIImage *)originalImage {
    CIImage *inputImage = [[CIImage alloc] initWithImage: originalImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setDefaults];
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:100.f] forKey:@"inputScale"];
	[filter setValue:[CIVector vectorWithX:0 Y:0] forKey:@"inputCenter"];

    
    CIImage *outputImage = [filter valueForKey:@"outputImage"];
    
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect: outputImage.extent];
    UIImage *convertImage = [UIImage imageWithCGImage: cgImage];
    
    return convertImage;
}

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;

    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height),
                             IPL_DEPTH_8U, 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef;
    contextRef = CGBitmapContextCreate(
                                       iplimage->imageData,
                                       iplimage->width,
                                       iplimage->height,
                                       iplimage->depth,
                                       iplimage->widthStep,
                                       colorSpace,
                                       kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
	
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2RGB);
    cvReleaseImage(&iplimage);
    
    return ret;
}

- (UIImage *)CreateUIImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CFDataRef data = CFDataCreate(NULL, (UInt8 *)image->imageData,  image->imageSize );
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height, 
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
	
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    CFRelease(data);
	
    return ret;
}

- (IplImage *)doMosaic:(IplImage*)sourceImage x0:(int)x0 y0:(int)y0 width:(int)width height:(int)height size:(int)size {
    int b, g, r, col, row;
    
    int xMin = size*(int)floor((double)x0/size);
    int yMin = size*(int)floor((double)y0/size);
    int xMax = size*(int)ceil((double)(x0+width)/size);
    int yMax = size*(int)ceil((double)(y0+height)/size);
    
    for(int y=yMin; y<yMax; y+=size){
        for(int x=xMin; x<xMax; x+=size){
            b = g = r = 0;
            for(int i=0; i<size; i++){
                if( y+i > sourceImage->height ){
                    break;
                }
                row = i;
                for(int j=0; j<size; j++){
                    if( x+j > sourceImage->width ){
                        break;
                    }
                    b += (unsigned char)sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3];
                    g += (unsigned char)sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3+1];
                    r += (unsigned char)sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3+2];
                    col = j;
                }
            }
            row++;
            col++;
            for(int i=0;i<row;i++){
                for(int j=0;j<col;j++){
                    sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3]   = cvRound((double)b/(row*col));
                    sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3+1] = cvRound((double)g/(row*col));
                    sourceImage->imageData[sourceImage->widthStep*(y+i)+(x+j)*3+2] = cvRound((double)r/(row*col));
                }
            }
        }
    }
    
    return sourceImage;
}

- (void)makeMaskImage:(NSInteger)maskId {
    if (maskId == 1) {
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        IplImage *image = [self CreateIplImageFromUIImage:appDelegate.imageSource];
        image = [self doMosaic:image x0:0 y0:0 width:640 height:640 size:20];
        currentMask = [self CreateUIImageFromIplImage:image];
        
        //originalImage = [self filterImage:0 originalImage:imageView.image];
    } else {
        currentMask = [UIImage imageNamed:[NSString stringWithFormat:@"mask%d.png", maskId]];
    }
}

@end
