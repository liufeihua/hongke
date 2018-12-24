//
//  NewsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "GFKDObjsViewController.h"
#import "VideoDetailViewController.h"
@class EPUBParser;

typedef NS_ENUM(int, NewsListType)
{
    NewsListTypeAllType = 0,
    NewsListTypeNews,
    NewsListTypeHomeNews,//首页新闻
    //NewsListTypeSpecial, //专题
    NewsListTypeMsg,//消息中心
    NewsListTypeAuditInfo,//待审稿件
    
    NewsListTypeVideo,
    NewsListTypeRadio,
};

@interface NewsViewController : GFKDObjsViewController

@property (nonatomic, assign) int cateId;
@property (nonatomic, assign) BOOL isHasAdv;  //是否有图片轮播

@property (nonatomic, assign) NewsListType myNewsListType;

@property (nonatomic, copy) NSDictionary *dict;

@property (nonatomic, copy) NSArray *AdvObjectsDict;

//@property(strong,nonatomic) VideoDetailViewController *videoViewController;

- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial isShowDescendants:(int)isShowDescendants;
- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial;

- (void)pushMsgShow:(NSNotification *)notification;

@property (nonatomic, assign) int isShowDescendants;  //是否显示子栏目中的文章


@property (strong, nonatomic) EPUBParser *epubParser; //epub解析器，成员变量或全局

@property (nonatomic, assign) BOOL isHasPlay;   //是否有音频播放器

@end
