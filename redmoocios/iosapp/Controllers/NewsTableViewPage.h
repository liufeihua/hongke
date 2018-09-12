//
//  NewsTableViewPage.h
//  iosapp
//
//  Created by redmooc on 16/4/13.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, NewsTableListType)
{
    NewsTableListTypeAllType = 0,
    NewsTableListTypeNews,
    NewsTableListTypeHomeNews,//首页新闻
    NewsTableListTypeSpecial, //专题
    NewsTableListTypeMsg,//消息中心
};

@interface NewsTableViewPage : UITableViewController

@property(nonatomic,copy) NSString *urlString;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic,assign) NSInteger index;

@property (nonatomic, assign) int cateId;
@property (nonatomic, assign) BOOL isHasAdv;  //是否有图片轮播

@property (nonatomic, assign) NewsTableListType myNewsListType;
@property (nonatomic, assign) int isSpecial;

- (instancetype)initWithNewsListType:(NewsTableListType)type cateId:(int)cateId isSpecial:(int)isSpecial;

@end
