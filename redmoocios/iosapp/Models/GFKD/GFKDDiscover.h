//
//  GFKDDiscover.h
//  iosapp
//
//  Created by redmooc on 16/7/12.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDDiscover : GFKDBaseObject
//"name":"校报","linktype":"1","image":"/uploads/1/image/public/201603/20160329130554_32r0gndavh.jpg","px":"1","url":""
@property (nonatomic, assign) NSNumber *linkType; //1、站内栏目 2、站内文章 3、站外文章 4、跳蚤市场 5、举报
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;
//@property (nonatomic, strong) NSString *px;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) NSNumber *range;  //1. 校内可见  2.校外可见，不可分享  3.校外可见，可分享

@property (nonatomic, assign) NSNumber *enabled;  //1.可用

@end
