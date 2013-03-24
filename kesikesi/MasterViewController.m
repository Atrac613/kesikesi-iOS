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
#import "SVProgressHUD.h"
#import "AboutViewController.h"

@implementation MasterViewController

@synthesize webView;
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
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    
    refreshArchive = NO;
    
    imagePickerMode = [[NSArray alloc] initWithObjects:@"CHOOSE_FROM_LIBRARY", @"TAKE_PHOTO", nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:92/255.0 green:92/255.0 blue:159/255.0 alpha:0.7];
    
    // workaround for ios5.
    if ([self.navigationController.navigationBar
         respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        UIImage *navBGImage = [UIImage imageNamed:@"header_bg.png"];
        [self.navigationController.navigationBar setBackgroundImage:navBGImage
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    webView.delegate = self;
    
    NSString *url;
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8089/page/v2/welcome";
    } else {
        url = @"https://kesikesi-hr.appspot.com/page/v2/welcome";
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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
    
    NSLog(@"imageKye: %@", appDelegate.imageKey);
    if (refreshArchive || [appDelegate.imageKey length] > 0) {
        [self refreshMyArchives];
    }
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
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *url;
    
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8089/page/v2/archives";
    } else {
        url = @"https://kesikesi-hr.appspot.com/page/v2/archives";
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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showLibraryView {
    pickerMode = @"library";
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)exportButtonPressed:(id)sender {
    NSArray *validHost = [[NSArray alloc] initWithObjects:@"localhost", @"kesikesi-hr.appspot.com", @"www.kesikesi.me", @"kesikesi.atrac613.io", nil];
    
    NSString *host = [webView.request.URL host];
    NSString *path = [webView.request.URL path];
    
    if ([validHost containsObject:host] && [[path substringFromIndex:1] length] == 8) {
        [self showExportView];
    } else {
        NSLog(@"invalid host: %@", host);
        
        [actionButton setEnabled:NO];
        
        [self displayText:NSLocalizedString(@"INVALID_URL_EXPORT", @"")];
    }
}

- (void)showExportView {
    pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"CANCEL", @"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"OPEN_IN_SAFARI", @""), NSLocalizedString(@"EMAIL_LINK", @""), NSLocalizedString(@"TWEET", @""), NSLocalizedString(@"FACEBOOK_SHARE", @""), nil];
    [pickerViewPopup showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *host =[webView.request.URL host];
    NSNumber *port = [webView.request.URL port];
    NSString *path = [webView.request.URL path];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSString *url;
    if (port) {
        url = [NSString stringWithFormat:@"http://%@:%@%@", host, port, path];
    } else {
        url = [NSString stringWithFormat:@"http://kesikesi.atrac613.io%@", path];
    }

    if (buttonIndex == 0) {
        // Open in Safari
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else if (buttonIndex == 1) {
        // E-Mail Link
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:title];
        
        // Fill out the email body text
        NSString *emailBody = url;
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 2) {
        //Tweet
        
        [self showTweetView:title url:[[NSURL alloc] initWithString:url]];
    } else if (buttonIndex == 3) {
        // Facebook Share
        
        [self showFacebookView:title url:[[NSURL alloc] initWithString:url]];
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
            message = NSLocalizedString(@"EMAIL_CANCELED", @"");
            break;
        case MFMailComposeResultSaved:
            message = NSLocalizedString(@"EMAIL_SAVED", @"");
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"EMAIL_SENT", @"");
            break;
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"EMAIL_FAILED", @"");
            break;
        default:
            message = NSLocalizedString(@"EMAIL_NOT_SENT", @"");
            break;
    }
    
    [self displayText:message];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [webView setOpaque:YES];
    } else {
        [webView setOpaque:NO];
    }
    
    NSRange hostResult1 = [url rangeOfString:@"www.kesikesi.me"];
    NSRange hostResult2 = [url rangeOfString:@"kesikesi.atrac613.io"];
    
    if ([schema isEqualToString:@"ksks"] && (hostResult1.location != NSNotFound || hostResult2.location != NSNotFound)) {
        if ([url rangeOfString:@"page/auth"].location != NSNotFound) {
            NSLog(@"Auth action detected.");
            
            AuthViewController *authViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthView"];
            [self presentViewController:authViewController animated:YES completion:nil];
            
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
        } else if ([url rangeOfString:@"buttonStatus"].location != NSNotFound) {
            NSString *query = [baseUrl query];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [query componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
            
            if ([params objectForKey:@"actionButton"]) {
                if ([[params objectForKey:@"actionButton"] isEqual:@"on"]) {
                    [actionButton setEnabled:YES];
                } else {
                    [actionButton setEnabled:NO];
                }
            }
            
            if ([params objectForKey:@"navigationButton"]) {
                if ([[params objectForKey:@"navigationButton"] isEqual:@"on"]) {
                    [self.navigationItem.leftBarButtonItem setEnabled:YES];
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                } else {
                    [self.navigationItem.leftBarButtonItem setEnabled:NO];
                    [self.navigationItem.rightBarButtonItem setEnabled:NO];
                }
            }
            
            return NO;
        } else if ([url rangeOfString:@"about"].location != NSNotFound) {
            NSLog(@"About action detected.");
            
            AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
            [aboutViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
            [self presentViewController:aboutViewController animated:YES completion:nil];
        }
    }
    
    return YES;
}

- (void)showPendingView {
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)hidePendingView {
    [SVProgressHUD dismiss];
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
        id jsonTmpArray    = [appDelegate.kService getMaskModeJsonArray:imageKey];
        
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
    
    [self presentViewController:zBarReaderViewController animated:YES completion:nil];
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
            
            NSRange hostResult1 = [url rangeOfString:@"www.kesikesi.me"];
            NSRange hostResult2 = [url rangeOfString:@"kesikesi.atrac613.io"];
            
            if ((hostResult1.location != NSNotFound || hostResult2.location != NSNotFound) && [[path substringFromIndex:1] length] == 8) {
                NSLog(@"kesikesi.me Detected.");
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [self showPendingView];
                
                NSArray *params = [[NSArray alloc] initWithObjects:[path substringFromIndex:3], nil];
                
                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronizeGetMaskModeJsonArray:) object:params];
                [operation setQueuePriority:NSOperationQueuePriorityHigh];
                [appDelegate.operationQueue addOperation:operation];
            }
        }
        
        results = nil;
    } else if ([pickerMode isEqualToString:@"camera"]) {
        @try {
            [self dismissViewControllerAnimated:YES completion:nil];
            
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
            [self dismissViewControllerAnimated:YES completion:nil];
            
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

- (void)showTweetView:(NSString*)message url:(NSURL*)url {
    SLComposeViewController *twitterPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostViewController setInitialText:message];
    [twitterPostViewController addURL:url];
    
    [twitterPostViewController setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Cancelled");
                
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Done");
                
            default:
                break;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:twitterPostViewController animated:YES completion:nil];
}

- (void)showFacebookView:(NSString*)message url:(NSURL*)url {
    SLComposeViewController *facebookPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookPostViewController setInitialText:message];
    [facebookPostViewController addURL:url];
    
    [facebookPostViewController setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Cancelled");
                
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Done");
                
            default:
                break;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:facebookPostViewController animated:YES completion:nil];
}

@end
