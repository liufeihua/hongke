//
//  GFKDTakes.h
//  iosapp
//
//  Created by redmooc on 16/6/15.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDTakes : GFKDBaseObject

@property (nonatomic, assign) NSNumber *takeId;//json中为“id”
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *diggs; //点赞数
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, assign) NSNumber *userId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *digged;
@property (nonatomic, strong) NSNumber *collected; //是否收藏
@property (nonatomic, strong) NSNumber *comments; //评论数
@property (nonatomic, strong) NSString *metaDescription;
@property (nonatomic, strong) NSArray  *images;

@property (nonatomic, assign) NSNumber *infoLevel; //1. 校内可见  2.校外可见，不可分享  3.校外可见，可分享
@property (nonatomic, assign) NSString *shareUrl;

@end
