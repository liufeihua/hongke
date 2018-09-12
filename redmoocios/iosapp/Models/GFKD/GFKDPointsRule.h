//
//  GFKDPointsRule.h
//  iosapp
//
//  Created by redmooc on 16/5/20.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDPointsRule : GFKDBaseObject

@property (nonatomic, readonly,copy) NSString *ruleName;  //名称
@property (nonatomic ,readonly,copy) NSString *caption;   //描述
@property (nonatomic, assign) NSNumber *isas;    //加减状态：1||-1
@property (nonatomic, assign) NSNumber *points;         //积分
@property (nonatomic, assign) NSNumber *maxPoints; //当天最大改变积分
@property (nonatomic, assign) NSNumber *isspecial;
@property (nonatomic ,readonly,copy) NSDictionary *infos;

@end
