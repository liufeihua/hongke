//
//  GFKDUserNode.h
//  iosapp
//
//  Created by redmooc on 16/7/7.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDUserNode : GFKDBaseObject


//"cateId":52,"cateName":"信息","number":"xw","description":"发布学校新闻动态、重要资讯，满足官兵信息获取需求。","detailUrl":"https://mapp.nudt.edu.cn/node/52.htx","smallImage":"https://mapp.nudt.edu.cn/template/1/complex/_files/item_default2.png","articles":470,"attentions":0,"treeLevel":1,"treeNumber":"0000-0000","terminated":1,"attentioned":0,"isSpecial":0,"twoColumn":0,"isfixed":1
@property (nonatomic, assign) NSNumber *cateId;
@property (nonatomic, strong) NSString *cateName;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *Description;
@property (nonatomic, strong) NSString *detailUrl;
@property (nonatomic, strong) NSString *smallImage;
@property (nonatomic, assign) NSNumber *articles;
@property (nonatomic, assign) NSNumber *attentions;
@property (nonatomic, assign) NSNumber *treeLevel;
@property (nonatomic, strong) NSString *treeNumber;
@property (nonatomic, assign) NSNumber *terminated;
@property (nonatomic, assign) NSNumber *attentioned;
@property (nonatomic, assign) NSNumber *isSpecial;
@property (nonatomic, assign) NSNumber *twoColumn;
@property (nonatomic, assign) NSNumber *isfixed;  //1是固定栏目，0是订制栏目


@end
