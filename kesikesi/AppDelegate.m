//
//  AppDelegate.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "AppDelegate.h"
#import "RootSchemeViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize imageSource;
@synthesize originalImage;
@synthesize maskImage;
@synthesize maskMode;
@synthesize maskType;
@synthesize accessCode;
@synthesize operationQueue;
@synthesize imageKey;
@synthesize kService;
@synthesize tracker;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // operation queue
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    self.kService = [[KesiKesiService alloc] init];
    
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingId];
    
    tracker = [[GAI sharedInstance] defaultTracker];
    
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"Host: %@", [url host]);
    NSLog(@"Path: %@", [url path]);
    
    //NSString *host = @"www.kesikesi.me";
    NSString *path = [url path];
    
    if ([[url scheme] isEqualToString:@"ksks"]) {
        if ([[path substringFromIndex:1] length] == 8) {
            NSLog(@"AppDelegate -> IMAGE_KEY: %@", [path substringFromIndex:1]);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[path substringFromIndex:3] forKey:@"IMAGE_KEY"];
            [defaults synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
            RootSchemeViewController *rootSchemeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RootSchemeView"];
            
            [(UINavigationController *)self.window.rootViewController pushViewController:rootSchemeViewController animated:NO];
        }
        
        return YES;
    }
    
    return NO;
}
                            
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (!SEND_USAGE_STATISTICS) {
        [[GAI sharedInstance] setOptOut:YES];
        
        NSLog(@"Don't send usage statistics.");
    } else {
        [[GAI sharedInstance] setOptOut:NO];
        
        NSLog(@"Send usage staistics.");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
