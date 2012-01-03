//
//  MasterViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "FingerPaintViewController.h"
#import "ScratchViewController.h"
#import "AuthViewController.h"
#import "NSString+MD5.h"
#import "ImageUtil.h"

@implementation MasterViewController

@synthesize webView;
@synthesize pendingView;
@synthesize actionButton;
@synthesize pickerMode;
@synthesize imagePickerMode;
@synthesize pickerView;
@synthesize pickerToolbar;
@synthesize pickerViewPopup;
@synthesize refreshArchive;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setTitle:@"KesiKesi"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(composeButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOME", @"HOME") style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed)];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    
    refreshArchive = YES;
    
    imagePickerMode = [[NSArray alloc] initWithObjects:@"CHOOSE_FROM_LIBRARY", @"TAKE_PHOTO", nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:92/255.0 green:92/255.0 blue:159/255.0 alpha:0.7];
    
    // workaround for ios5.
    if ([self.navigationController.navigationBar
         respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        UIImage *navBGImage = [UIImage imageNamed:@"header_bg.png"];
        [self.navigationController.navigationBar setBackgroundImage:navBGImage
                                                      forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    webView.delegate = self;
    
    NSString *url;
    
    BOOL LOGIN = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults valueForKey:@"LOGIN"] boolValue]) {
        LOGIN = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    if (!LOGIN) {
        if (TARGET_IPHONE_SIMULATOR) {
            url = @"http://localhost:8089/page/welcome?version=2";
        } else {
            url = @"http://kesikesi-hr.appspot.com/page/welcome?version=2";
        }
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        if (refreshArchive || [appDelegate.imageKey length] > 0) {
            [self refreshMyArchives];
        }
    }
    
    NSLog(@"reload...");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    webView.delegate = nil;
    [self hidePendingView];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}


- (void)webViewDidStartLoad:(UIWebView *)wv {
    [self showPendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {	
    [self hidePendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = YES;	
}

- (void)refreshMyArchives {
    NSLog(@"refresh");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *url;
    
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8089/page/archives?version=2";
    } else {
        url = @"https://kesikesi-hr.appspot.com/page/archives?version=2";
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    refreshArchive = NO;
    appDelegate.imageKey = @"";
}

- (void)composeButtonPressed {    
    [self showPickerView];
}

- (void)homeButtonPressed {
    [self refreshMyArchives];
}

- (void)showCameraView {
    if (TARGET_IPHONE_SIMULATOR) {
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.imageSource = [UIImage imageNamed:@"test.jpg"];
        
        FingerPaintViewController *fingerPaintViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FingerPaintView"];
        [self.navigationController pushViewController:fingerPaintViewController animated:YES];
    } else {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return;
        }
        
        pickerMode = @"camera";
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        [self presentModalViewController:imagePicker animated:YES];
    }
}

- (void)showLibraryView {
    pickerMode = @"library";
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)exportButtonPressed:(id)sender {
    [self showExportView];
}

- (void)showExportView {
	pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"CANCEL", @"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"OPEN_IN_SAFARI", @""), NSLocalizedString(@"EMAIL_LINK", @""), NSLocalizedString(@"TWEET", @""), nil];
    [pickerViewPopup showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *host =[webView.request.URL host]; 
    NSNumber *port = [webView.request.URL port];
    NSString *path = [webView.request.URL path];
    
    NSString *url;
    if (port) {
        url = [NSString stringWithFormat:@"http://%@:%@%@", host, port, path];
    } else {
        url = [NSString stringWithFormat:@"http://www.kesikesi.me%@", path];
    }
    
    if (buttonIndex == 0) {
        // Open in Safari
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else if (buttonIndex == 1) {
        // E-Mail Link
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"KesiKesi"];
        
        // Fill out the email body text
        NSString *emailBody = url;
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
    } else if (buttonIndex == 2) {
        // Tweet
        NSString *tweet = [NSString stringWithFormat:@"%@ %@ via @kesikesi_me", NSLocalizedString(@"TWEET_MESSAGE", @""), url];
        
        if ([TWTweetComposeViewController canSendTweet]) {
            // Set up the built-in twitter composition view controller.
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            
            // Set the initial tweet text. See the framework for additional properties that can be set.
            [tweetViewController setInitialText:tweet];
            
            // Create the completion handler block.
            [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                NSString *output;
                
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        // The cancel button was tapped.
                        output = NSLocalizedString(@"TWEET_CANCELED", @"");
                        break;
                    case TWTweetComposeViewControllerResultDone:
                        // The tweet was sent.
                        output = NSLocalizedString(@"TWEET_SENT", @"");
                        break;
                    default:
                        break;
                }
                
                [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                
                // Dismiss the tweet composition view controller.
                [self dismissModalViewControllerAnimated:YES];
            }];
            
            // Present the tweet composition view controller modally.
            [self presentModalViewController:tweetViewController animated:YES];
        } else {
            [self displayText:NSLocalizedString(@"CAN_NOT_TWEET", @"")];
        }
    }
}

- (void)displayText:(NSString *)text {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	NSString *message;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			message = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			message = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			message = @"Result: failed";
			break;
		default:
			message = @"Result: not sent";
			break;
	}
    
    NSLog(@"MFMail Message: %@", message);
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showPickerView {
	pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Choose from..."
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
	
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPicker:)];
	[barItems addObject:cancelBtn];
    
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePicker:)];
	[barItems addObject:doneBtn];
    
	[pickerToolbar setItems:barItems animated:YES];
	
	[pickerViewPopup addSubview:pickerToolbar];
	[pickerViewPopup addSubview:pickerView];
	[pickerViewPopup showInView:self.view];
	[pickerViewPopup setBounds:CGRectMake(0,0,320, 475)];
}

-(BOOL)cancelPicker:(id)sender
{
	[pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    
	return YES;
}

-(BOOL)closePicker:(id)sender
{
    NSString *mode = [self.imagePickerMode objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSLog(@"mode: %@", mode);
    
	[pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([mode isEqualToString:@"TAKE_PHOTO"]) {
        [self performSelector:@selector(showCameraView) withObject:nil afterDelay:0.5f];
    } else {
        [self performSelector:@selector(showLibraryView) withObject:nil afterDelay:0.5f];
    }
    
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [imagePickerMode count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return NSLocalizedString([imagePickerMode objectAtIndex:row], @"");
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *baseUrl = [request URL];
	NSString *url = [baseUrl absoluteString];
	NSString *schema = [baseUrl scheme];
	NSString *path = [baseUrl path];
	
	NSLog(@"path: %@", [path substringFromIndex:1]);
    
    // workaround.
    if ([url rangeOfString:@"google.com"].location != NSNotFound) {
        [webView setBackgroundColor:[UIColor whiteColor]];
        [webView setOpaque:YES];
    } else {
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setOpaque:NO];
    }
    
    NSRange hostResult	= [url rangeOfString:@"www.kesikesi.me"];
    
    if ([schema isEqualToString:@"ksks"] && hostResult.location != NSNotFound) {
        if ([url rangeOfString:@"page/auth"].location != NSNotFound) {
            NSLog(@"Auth action detected.");
            
            AuthViewController *authViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthView"];
            [self presentModalViewController:authViewController animated:YES];
            
            return NO;
        } else if ([url rangeOfString:@"logout/success"].location != NSNotFound) {
            NSLog(@"Logout action detected.");
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"LOGIN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            return NO;
        } else if ([url rangeOfString:@"login/success"].location != NSNotFound) {
            NSLog(@"Login action detected.");
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"LOGIN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            return NO;
        } else if ([[path substringFromIndex:1] length] == 6) {
            NSLog(@"KesiKesi action detected.");
            
            [self showPendingView];
            
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSArray *params = [[NSArray alloc] initWithObjects:[path substringFromIndex:1], nil];
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronizeGetMaskModeJsonArray:) object:params];
            [operation setQueuePriority:NSOperationQueuePriorityHigh];
            [appDelegate.operationQueue addOperation:operation];
            
            return NO;
        } else if ([url rangeOfString:@"actionButton/on"].location != NSNotFound) {
            [actionButton setEnabled:YES];
            
            return NO;
        } else if ([url rangeOfString:@"actionButton/off"].location != NSNotFound) {
            [actionButton setEnabled:NO];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)showPendingView {
    if (pendingView == nil && ![self.view.subviews containsObject:pendingView]) {
        pendingView = [[PendingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
        pendingView.titleLabel.text = @"Please wait...";
        pendingView.userInteractionEnabled = NO;
        [self.view addSubview:pendingView];
    }
    
    [pendingView showPendingView];
}

- (void)hidePendingView {
    if ([self.view.subviews containsObject:pendingView]) {
        [pendingView hidePendingView];
        
        pendingView = nil;
    }
}

- (void)synchronizeGetMaskModeJsonArray:(NSArray*)params {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    NSString *imageKey = [params objectAtIndex:0];
    
    NSDictionary *maskMode = [self getMaskModeJsonArray:imageKey];
    
    params = [[NSArray alloc] initWithObjects:imageKey, maskMode, nil];
    
    [self performSelectorOnMainThread:@selector(completeGetMaskModeJsonArray:) withObject:params waitUntilDone:NO];
}

- (void)completeGetMaskModeJsonArray:(NSArray*)params {
    NSLog(@"completeGetMaskModeJsonArray");
    
    NSString *imageKey = [params objectAtIndex:0];
    NSDictionary *maskMode = [params objectAtIndex:1];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([maskMode count]) {
        ScratchViewController *scratchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScratchView"];
        scratchViewController.imageKey = imageKey;
        scratchViewController.maskMode = [maskMode objectForKey:@"mask_mode"];
        scratchViewController.accessCode = [maskMode objectForKey:@"access_code"];
        scratchViewController.comment = [maskMode objectForKey:@"comment"];
        [self.navigationController pushViewController:scratchViewController animated:YES];
    } else {
        [self hidePendingView];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"NOT_FOUND", @"Not found.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (NSDictionary*)getMaskModeJsonArray:(NSString*)imageKey {
	AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *results = [[NSDictionary alloc] init];
    
	@try {
		id jsonTmpArray	= [appDelegate.kService getMaskModeJsonArray:imageKey];
		
		NSLog(@"jsonTmpArray: %@", jsonTmpArray);
		
		if ([jsonTmpArray isKindOfClass:[NSDictionary class]]) {
			results =  jsonTmpArray;
		}
		
		jsonTmpArray = nil;
	} @catch (NSException *exception) {
		NSLog(@"NSException: %@: %@", [exception name], [exception reason]);
	}
    
    return results;
}

- (IBAction)scanButtonPressed {
    pickerMode = @"zbar";
    
    ZBarReaderViewController *zBarReaderViewController = [ZBarReaderViewController new];
    zBarReaderViewController.readerDelegate = self;
    ZBarImageScanner *scanner = zBarReaderViewController.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self.navigationController presentModalViewController:zBarReaderViewController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([pickerMode isEqualToString:@"zbar"]) {
        id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
        
        ZBarSymbol *symbol = nil;
        NSString *searchString;
        
        for(symbol in results) {
            searchString = symbol.data;
            NSLog(@"Code: %@", searchString);
            
            NSURL *baseUrl = [[NSURL alloc] initWithString:searchString];
            NSString *url = [baseUrl absoluteString];
            NSString *path = [baseUrl path];
            
            NSRange hostResult	= [url rangeOfString:@"www.kesikesi.me"];
            
            if (hostResult.location != NSNotFound && [[path substringFromIndex:1] length] == 6) {
                NSLog(@"kesikesi.me Detected.");
                
                [self dismissModalViewControllerAnimated:YES];
                [self showPendingView];
                
                NSArray *params = [[NSArray alloc] initWithObjects:[path substringFromIndex:1], nil];
                
                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronizeGetMaskModeJsonArray:) object:params];
                [operation setQueuePriority:NSOperationQueuePriorityHigh];
                [appDelegate.operationQueue addOperation:operation];
            }
        }
        
        results = nil;
    } else if ([pickerMode isEqualToString:@"camera"]) {
        @try {
            [self dismissModalViewControllerAnimated:YES];
            
            // Crop to square image.
            ImageUtil *util = [[ImageUtil alloc] init];
            appDelegate.imageSource = [util getResizeImage:[info objectForKey:UIImagePickerControllerEditedImage] targetSize:CGSizeMake(640, 640) contentMode:UIViewContentModeScaleAspectFit];
            
            UIImageWriteToSavedPhotosAlbum(appDelegate.imageSource, nil, nil, nil);
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            FingerPaintViewController *fingerPaintViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FingerPaintView"];
            [self.navigationController pushViewController:fingerPaintViewController animated:YES];
        } @catch (NSException * e) {
            NSLog(@"NSException: %@: %@", [e name], [e reason]);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } else if ([pickerMode isEqualToString:@"library"]) {
        @try {
            [self dismissModalViewControllerAnimated:YES];
            
            // Crop to square image.
            ImageUtil *util = [[ImageUtil alloc] init];
            appDelegate.imageSource = [util getResizeImage:[info objectForKey:UIImagePickerControllerEditedImage] targetSize:CGSizeMake(640, 640) contentMode:UIViewContentModeScaleAspectFit];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            FingerPaintViewController *fingerPaintViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FingerPaintView"];
            [self.navigationController pushViewController:fingerPaintViewController animated:YES];
        } @catch (NSException * e) {
            NSLog(@"NSException: %@: %@", [e name], [e reason]);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}

@end
