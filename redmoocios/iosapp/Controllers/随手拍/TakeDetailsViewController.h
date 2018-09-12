//
//  TakeDetailsViewController.h
//  iosapp
//
//  Created by redmooc on 16/6/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "CommentsViewController.h"
#import "GFKDTakes.h"

@interface TakeDetailsViewController : CommentsViewController

- (instancetype)initWithTakeID:(int64_t)takeID;

- (instancetype)initWithModal:(GFKDTakes*)take;

@property (nonatomic, assign) int                  zanCount;
@property (nonatomic, assign) int                  commentCount;

@end
