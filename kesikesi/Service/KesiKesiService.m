//
//  KesiKesiService.m
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "KesiKesiService.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "NSString+MD5.h"

@implementation KesiKesiService

- (id)getArchiveJsonArray:(NSString *)user_id {
	id resultArray = [[NSArray alloc] init];
	
	NSString *urlString;
    
    NSString* baseUrlString;
    if (TARGET_IPHONE_SIMULATOR) {
        baseUrlString = @"http://localhost:8089/api/get_archive_list?id=%@";
    } else {
        baseUrlString = @"https://kesikesi-hr.appspot.com/api/get_archive_list?id=%@";
    }
	
	urlString = [NSString stringWithFormat:baseUrlString, user_id];
	
	NSString *jsonString = [self getJsonString:urlString];
	
	id statuseTmpArray = [jsonString JSONValue];
	if ([statuseTmpArray isKindOfClass:[NSArray class]]) {
		resultArray	= statuseTmpArray;
	}
	
	jsonString = nil;
	statuseTmpArray = nil;
	
	return resultArray;
}

- (id)getMaskModeJsonArray:(NSString *)imageKey {
	id resultArray	= [[NSArray alloc] init];
	
	NSString *urlString;
    
	NSString* baseUrlString;
    if (TARGET_IPHONE_SIMULATOR) {
        baseUrlString = @"http://localhost:8089/api/get_mask_mode?id=%@";
    } else {
        baseUrlString = @"https://kesikesi-hr.appspot.com/api/get_mask_mode?id=%@";
    }
	
    NSString *maskImageKey = [[NSString stringWithFormat:@"%@-%@", SECRET_MASK_KEY, imageKey] md5sum];
    
	urlString = [NSString stringWithFormat:baseUrlString, maskImageKey];
	
	NSString *jsonString = [self getJsonString:urlString];
	
	id statuseTmpArray = [jsonString JSONValue];
	if ([statuseTmpArray isKindOfClass:[NSDictionary class]]) {
		resultArray	= statuseTmpArray;
	}
	
	jsonString = nil;
	statuseTmpArray = nil;
	
	return resultArray;
}

- (id)deleteArchive:(NSString *)user_id imageKey:(NSString *)imageKey {
	id resultArray	= [[NSArray alloc] init];
	
	NSString *urlString;
    
	NSString* baseUrlString;
    if (TARGET_IPHONE_SIMULATOR) {
        baseUrlString = @"http://localhost:8089/api/delete_image?id=%@&user_id=%@";
    } else {
        baseUrlString = @"https://kesikesi-hr.appspot.com/api/delete_image?id=%@&user_id=%@";
    }
	
	urlString = [NSString stringWithFormat:baseUrlString, imageKey, user_id];
	
	NSString *jsonString = [self getJsonString:urlString];
	
	id statuseTmpArray = [jsonString JSONValue];
	if ([statuseTmpArray isKindOfClass:[NSArray class]]) {
		resultArray	= statuseTmpArray;
	}
	
	jsonString = nil;
	statuseTmpArray = nil;
	
	return resultArray;
}


- (NSDictionary*)uploadArchive:(UIImage *)originalImage maskImage:(UIImage *)maskImage maskMode:(NSString *)maskMode accessCode:(NSString *)accessCode {
    NSLog(@"uploadArchive");
    
    NSDictionary *result;
    
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
    
    NSError *error	= nil;
	NSURLResponse *response = nil;
	
	NSData *contentData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *jsonString;
    
	int statusCode = [((NSHTTPURLResponse *)response) statusCode];
	if (statusCode == 420) {
		NSLog(@"Response Code: 420 Enhance Your Calm.");
		NSException *exception = [NSException exceptionWithName:@"Exception" reason:@"HttpResponseCode420" userInfo:nil];
		@throw exception;
	}
	
	if (error) {
		NSLog(@"error: %@", [error localizedDescription]);
		NSException *exception = [NSException exceptionWithName:@"Exception" reason:[error localizedDescription] userInfo:nil];
		@throw exception;
	} else {
		jsonString	= [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
		
        NSLog(@"jsonString: %@", jsonString);
        
        result = [jsonString JSONValue];
	}
    
    return result;
}

- (NSString *)getJsonString:(NSString *)urlString {
	NSLog(@"urlString: %@", urlString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
    
	NSError *error	= nil;
	NSURLResponse *response = nil;
	
	NSData *contentData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *jsonString;
    
	int statusCode = [((NSHTTPURLResponse *)response) statusCode];
	if (statusCode == 420) {
		NSLog(@"Response Code: 420 Enhance Your Calm.");
		NSException *exception = [NSException exceptionWithName:@"Exception" reason:@"HttpResponseCode420" userInfo:nil];
		@throw exception;
	}
	
	if (error) {
		NSLog(@"error: %@", [error localizedDescription]);
		NSException *exception = [NSException exceptionWithName:@"Exception" reason:[error localizedDescription] userInfo:nil];
		@throw exception;
	} else {
		jsonString	= [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
		
        NSLog(@"jsonString: %@", jsonString);
	}
	
	return jsonString;
}

@end
