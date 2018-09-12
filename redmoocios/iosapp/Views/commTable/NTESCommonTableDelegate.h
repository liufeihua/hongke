//
//  NTESCommonTableDelegate.h
//  NIM
//
//  Created by chris on 15/6/29.
//  Copyright (c) 2015年 Netease. All rights reserved.
//
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NTESCommonTableDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>

- (instancetype) initWithTableData:(NSArray *(^)(void))data;

@property (nonatomic,assign) CGFloat defaultSeparatorLeftEdge;

@end
