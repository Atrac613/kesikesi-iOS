//
//  RootSchemeViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "RootSchemeViewController.h"
#import "AppDelegate.h"
#import "ScratchViewController.h"
#import "SVProgressHUD.h"

@implementation RootSchemeViewController

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
    
    // for Google Analytics
    self.trackedViewName = NSStringFromClass([self class]);
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *image_key = [defaults valueForKey:@"IMAGE_KEY"]; 
    if ([image_key length]) {
        NSLog(@"IMAGE_KEY: %@", image_key);
        
        [defaults setObject:@"" forKey:@"IMAGE_KEY"];
        [defaults synchronize];
        
        NSArray *params = [[NSArray alloc] initWithObjects:image_key, nil];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronizeGetMaskModeJsonArray:) object:params];
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
        [appDelegate.operationQueue addOperation:operation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showPendingView];
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
    [self hidePendingView];
}

- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"NOT_FOUND", @"Not found.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
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

- (void)showPendingView {
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)hidePendingView {
    [SVProgressHUD dismiss];
}

@end
