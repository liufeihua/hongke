//
//  GFKDObjsViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/3.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MJRefresh.h>

#import "Utils.h"
#import "OSCAPI.h"
#import "LastCell.h"

typedef NS_ENUM(int, ObjsHttpType)
{
    objsHttpTypeGET = 0,
    objsHttpTypePOST = 1
};


@interface GFKDObjsViewController : UITableViewController


@property (nonatomic, copy) NSString * (^generateURL)(NSUInteger page);
@property (nonatomic, copy) id (^generateParameters)(NSUInteger page);

@property (nonatomic, copy) void (^tableWillReload)(NSUInteger responseObjectsCount);
@property (nonatomic, copy) void (^didRefreshSucceed)();

@property Class objClass;

@property (nonatomic, assign) BOOL shouldFetchDataAfterLoaded;
@property (nonatomic, assign) BOOL needRefreshAnimation;
@property (nonatomic, assign) BOOL needCache;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, assign) int allCount;
@property (nonatomic, strong) LastCell *lastCell;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, assign) BOOL needAutoRefresh;
@property (nonatomic, copy) NSString *kLastRefreshTime;
@property (nonatomic, assign) NSTimeInterval refreshInterval;

@property (nonatomic, copy) void (^anotherNetWorking)();


@property (nonatomic, assign) ObjsHttpType HttpType;

- (NSArray *)parseDICT:(NSDictionary *)dict;
- (void)fetchMore;
- (void)refresh;


@end
