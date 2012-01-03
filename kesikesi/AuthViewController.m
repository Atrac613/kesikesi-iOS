//
//  AuthViewController.m
//  kesikesi
//
//  Created by 修 野口 on 1/3/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "AuthViewController.h"
#import "AppDelegate.h"

@implementation AuthViewController

@synthesize navigationBar;
@synthesize navigationItem;
@synthesize webView;
@synthesize pendingView;

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
    
    [self.navigationItem setTitle:NSLocalizedString(@"AUTHENTICATION", @"")];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)]];
    
    self.navigationBar.tintColor = [UIColor colorWithRed:92/255.0 green:92/255.0 blue:159/255.0 alpha:0.7];
    
    UIImage *navBGImage = [UIImage imageNamed:@"header_bg.png"];
    [self.navigationBar setBackgroundImage:navBGImage forBarMetrics:UIBarMetricsDefault];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    webView.delegate = self;
    
    NSString *url;
    
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8089/page/auth";
    } else {
        url = @"https://kesikesi-me.appspot.com/page/auth";
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)webViewDidStartLoad:(UIWebView *)wv {
    [self showPendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {	
    [self hidePendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = YES;	
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	NSURL *baseUrl = [request URL];
	NSString *url = [baseUrl absoluteString];
	NSString *schema = [baseUrl scheme];
	NSString *path = [baseUrl path];
	
	NSLog(@"path: %@", [path substringFromIndex:1]);
    
	NSRange hostResult	= [url rangeOfString:@"www.kesikesi.me"];
    
    if ([schema isEqualToString:@"ksks"] && hostResult.location != NSNotFound) {
        if ([url rangeOfString:@"page/auth/success"].location != NSNotFound) {
            NSLog(@"Auth Success action detected.");
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"LOGIN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Workaround
            // Force Reload.
            appDelegate.imageKey = @"reload";
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        } else if ([url rangeOfString:@"page/auth/fail"].location != NSNotFound) {
            NSLog(@"Auth Fail action detected.");
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)showPendingView {
    if (pendingView == nil && ![self.view.subviews containsObject:pendingView]) {
        pendingView = [[PendingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40)];
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

@end
