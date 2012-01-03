//
//  UploadViewController.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "UploadViewController.h"
#import "AppDelegate.h"
#import "JSON.h"

@implementation UploadViewController

@synthesize httpResponseData;
@synthesize pendingView;
@synthesize alertView;
@synthesize tableView;
@synthesize tmpImageKey;
@synthesize comment;
@synthesize doUpload;
@synthesize doTweet;

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
    
    self.tmpImageKey = @"";
    self.comment = @"";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(uploadButtonPressed)];
    
    [self performSelectorOnMainThread:@selector(backgroundUploadAction) withObject:nil waitUntilDone:YES];
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

- (void)uploadButtonPressed {
    [self showPendingView];
    
    // Close Software Keyboard.
    UITextField *textField = (UITextField*)[self.view viewWithTag:1001];
    [textField resignFirstResponder];
    
    if ([textField.text length] > 0) {
        self.comment = textField.text;
    } else {
        self.comment = @"";
    }
    
    if ([self.tmpImageKey length] > 0) {
        NSArray *params = [[NSArray alloc] initWithObjects:self.tmpImageKey, self.comment, nil];
        [self performSelectorOnMainThread:@selector(uploadAction:) withObject:params waitUntilDone:YES];
    } else {
        self.doUpload = YES;
    }
}

- (void)backgroundUploadAction {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"backgroundUploadAction");
    
    UIImage *originalImage = appDelegate.originalImage;
    UIImage *maskImage = appDelegate.maskImage;
    NSString *maskMode = appDelegate.maskMode;
    NSString *accessCode = appDelegate.accessCode;
    
    NSString *urlString;
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = @"http://localhost:8089/api/upload_image";
    } else {
        urlString = @"https://kesikesi-hr.appspot.com/api/upload_image";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
	
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSData *maskImageData = UIImagePNGRepresentation(maskImage);
    NSData *originalImageData = UIImagePNGRepresentation(originalImage);
	
	NSMutableData *body = [NSMutableData data];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"mask_mode"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", maskMode] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"access_code"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", accessCode] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"original_image\"; filename=\"original_image.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:originalImageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"mask_image\"; filename=\"mask_image.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:maskImageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
	[NSURLConnection connectionWithRequest:request delegate:self];	
}

- (void)uploadAction:(NSArray*)params {
    NSLog(@"uploadAction");
    
    NSString *urlString;
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = @"http://localhost:8089/api/upload";
    } else {
        urlString = @"https://kesikesi-hr.appspot.com/api/upload";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
	
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"tmp_image_key"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [params objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"comment"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [params objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
	[NSURLConnection connectionWithRequest:request delegate:self];	
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    //if (httpResponseData != nil) [httpResponseData release];
    httpResponseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [httpResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    NSString *returnString = [self data2str:httpResponseData];
    NSLog(@"returnString: %@", returnString);
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    httpResponseData=nil;
    
    [self hidePendingView];
    
	id jsonTmpDic = [returnString JSONValue];
    
    NSLog(@"JSON: %@", jsonTmpDic);
	
	if ([jsonTmpDic isKindOfClass:[NSDictionary class]]) {
		if ([[jsonTmpDic valueForKey:@"image_key"] isKindOfClass:[NSString class]]) {
            if ([[jsonTmpDic valueForKey:@"image_key"] length] == 32) {
                self.tmpImageKey = [jsonTmpDic valueForKey:@"image_key"];
                NSLog(@"TmpImageKey: %@", self.tmpImageKey);
                
                if (self.doUpload) {
                    NSArray *params = [[NSArray alloc] initWithObjects:self.tmpImageKey, self.comment, nil];
                    [self performSelectorOnMainThread:@selector(uploadAction:) withObject:params waitUntilDone:YES];
                }
            } else {
                appDelegate.imageKey = [jsonTmpDic valueForKey:@"image_key"];
                NSLog(@"ImageKey: %@", appDelegate.imageKey);
                
                if (doTweet) {
                    NSString *tweetMessage;
                    if ([comment length] > 0) {
                        tweetMessage = comment;
                    } else {
                        tweetMessage = NSLocalizedString(@"TWEET_MESSAGE", @"");
                    }
                    [self showTweetView:[NSString stringWithFormat:@"%@ http://www.kesikesi.me/%@ via @kesikesi_me", tweetMessage, appDelegate.imageKey]];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            
            return;
		}
	}
    
	alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"UPLOAD_FAILED", @"Upload failed.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
	[alertView show];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"didFailWithError");
    
    [self hidePendingView];
    
	alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"CONNECTION_FAILURE", @"Connection failure.") delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.view.subviews containsObject:pendingView]) {
        float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
        float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
        pendingView.progressView.hidden = NO;
        pendingView.progressView.progress = progress/total;
    }
}

- (NSString*)data2str:(NSData*)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)showPendingView {
    if (pendingView == nil && ![self.view.subviews containsObject:pendingView]) {
        pendingView = [[PendingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        pendingView.titleLabel.text = @"Please wait...";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"OPTION", @"");
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TableViewCell";
    
    UITableViewCell *cell;
    
    cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 30)];
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.tag = 1001;
        textField.placeholder = NSLocalizedString(@"COMMENT", @"");
        
        [cell.contentView addSubview:textField];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, 100, 30)];
        label.text = NSLocalizedString(@"TWEET", @"");
        label.backgroundColor = [UIColor clearColor];
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        
        [switchView setOn:NO animated:NO];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:label];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog(@"Tweet is %@", switchControl.on ? @"ON" : @"OFF");
    
    doTweet = switchControl.on;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSLog(@"textFieldShouldReturn");
    
    [textField resignFirstResponder];
    
    comment = textField.text;
    
    return YES;
}

- (void)displayTextAndExit:(NSString *)text {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showTweetView:(NSString*)tweet {
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
                    output = NSLocalizedString(@"TWEET_SENDED", @"");
                    break;
                default:
                    break;
            }
            
            [self performSelectorOnMainThread:@selector(displayTextAndExit:) withObject:output waitUntilDone:NO];
            
            // Dismiss the tweet composition view controller.
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        // Present the tweet composition view controller modally.
        [self presentModalViewController:tweetViewController animated:YES];
    } else {
        [self displayTextAndExit:NSLocalizedString(@"CAN_NOT_TWEET", @"")];
    }
}

@end
