//
//  MMPushService.h
//  yuxi-manager
//
//  Created by Guo Yu on 14-8-27.
//  Copyright (c) 2014年 ylink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPushService : NSObject

+ (MMPushService *)sharedService;

- (void)reconnect;

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
