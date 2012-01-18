//
//  UploadViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "FBConnect.h"

@interface UploadViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBSessionDelegate, FBRequestDelegate> {
    IBOutlet UITableView *tableView;
    
    NSString *tmpImageKey;
    NSString *comment;
    
    NSMutableData *httpResponseData;
    PendingView *pendingView;
    UIAlertView *alertView;
    
    UIBackgroundTaskIdentifier bgTask;
    
    BOOL doUpload;
    BOOL doTweet;
    BOOL doFacebook;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *tmpImageKey;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSMutableData *httpResponseData;
@property (nonatomic, retain) PendingView *pendingView;
@property (nonatomic, retain) UIAlertView *alertView;

@property (nonatomic) BOOL doUpload;
@property (nonatomic) BOOL doTweet;
@property (nonatomic) BOOL doFacebook;

- (void)doneButtonPressed;
- (void)backgroundUploadAction;
- (void)uploadAction:(NSArray*)params;
- (NSString*)data2str:(NSData*)data;

- (void)showPendingView;
- (void)hidePendingView;

- (void)displayTextAndExit:(NSString *)text;
- (void)showTweetView:(NSString*)tweet;

- (void)sendFacebook:(NSString*)url;

@end
