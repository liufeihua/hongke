//
//  TakeDetailsWithBottomBarViewController.h
//  iosapp
//
//  Created by redmooc on 16/6/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "BottomBarViewController.h"
#import "GFKDTakes.h"
@protocol TakeDetailsWithBottomBarViewControllerDelegate <NSObject>

@optional

- (void) GiveCommentCount: (int) _commentCount withZanCount: (int) _zanCount isDel:(bool) _isDel;

@end


@interface TakeDetailsWithBottomBarViewController : BottomBarViewController

- (instancetype)initWithTakeID:(int64_t)takeID;

- (instancetype)initWithModal:(GFKDTakes *)take;

@property (nonatomic,assign) id<TakeDetailsWithBottomBarViewControllerDelegate> delegate;


@end
