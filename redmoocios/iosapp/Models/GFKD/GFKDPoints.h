//
//  GFKDPoints.h
//  iosapp
//
//  Created by redmooc on 16/5/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDPoints : GFKDBaseObject

@property (nonatomic, readwrite ,copy) NSString *pimage;  //等级图片
@property (nonatomic, readwrite ,copy) NSString *levelName;  //等级名称
@property (nonatomic, assign) NSNumber *points;         //积分

@end
