//
//  GFKDTopNodes.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/2.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDTopNodes : GFKDBaseObject

/*
 "cateId":52,
 "cateName":"新闻",
 "number":"campus",
 "description":"新闻",
 "detailUrl":"http://mapi.nudt.edu.cn/node/52.htx",
 "smallImage":"http://mapi.nudt.edu.cn/template/1/complex/_files/images/no_picture.jpg",
 "articles":31,
 "attentions":0,
 "treeLevel":1,
 "treeNumber":"0000-0000",
 "terminated":1,
 "attentioned":0,
 "isSpecial":0
 */
@property (nonatomic, assign) NSNumber *cateId;
@property (nonatomic, readonly ,copy) NSString *cateName;
@property (nonatomic, readonly ,copy) NSString *number;
//@property (nonatomic, readonly ,copy) NSString *description;
@property (nonatomic, readonly ,copy) NSURL *smallImage;
@property (nonatomic, assign) NSNumber *articles;
@property (nonatomic, assign) NSNumber *attentions;
@property (nonatomic, assign) NSNumber *treeLevel;
@property (nonatomic, readonly ,copy) NSString *treeNumber;
@property (nonatomic, assign) NSNumber *terminated;
@property (nonatomic, assign) NSNumber *attentioned;
@property (nonatomic, assign) NSNumber *isSpecial;
@property (nonatomic, assign) NSNumber *twoColumn;
@property (nonatomic, assign) NSNumber *isfixed;
//"twoColumn":0,"isfixed":0

@property (nonatomic, assign) NSNumber *typeId;
@property (nonatomic, assign) NSNumber *showTitle;

@property (nonatomic, assign) NSNumber *showChildNode;  //是否显示子栏目


@property (nonatomic, strong) NSString *linkType; //1  网站链接  2文章链接
@property (nonatomic, readonly ,copy) NSString *detailUrl;
@property (nonatomic, strong) NSNumber *nodeModelId; //模型ID  后台管理系统定   3:新闻  4.图集   8.视频  20.音频


@end
