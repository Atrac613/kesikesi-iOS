//
//  KesiKesiService.h
//  kesikesi
//
//  Created by Osamu Noguchi on 1/1/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KesiKesiService : NSObject {
    
}

- (id)getArchiveJsonArray:(NSString*)user_id;
- (id)getMaskModeJsonArray:(NSString*)imageKey;
- (id)deleteArchive:(NSString*)user_id imageKey:(NSString*)imageKey;
- (NSDictionary *)uploadArchive:(UIImage*)originalImage maskImage:(UIImage*)maskImage maskMode:(NSString*)maskMode accessCode:(NSString*)accessCode;
- (NSString *)getJsonString:(NSString *)urlString;

@end
