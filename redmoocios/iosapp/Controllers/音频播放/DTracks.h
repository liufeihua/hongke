//
//  DTracks.h
//  iosapp
//
//  Created by redmooc on 2018/12/6.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFKDNews.h"

@interface DTracks : NSObject

@property (nonatomic, assign) NSInteger maxPageId;

@property (nonatomic, strong) NSArray<GFKDNews *> *list;

@property (nonatomic, assign) NSInteger pageId;

@property (nonatomic, assign) NSInteger pageSize;

@property (nonatomic, assign) NSInteger totalCount;


@end
