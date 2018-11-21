//
//  GFKDNews.h
//  iosapp
//
//  Created by lfh on 15/11/3.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"

#import "GFKDImages.h"

@interface GFKDNews : GFKDBaseObject

/*
 "image":"http://mapi.nudt.edu.cn/uploads/1/image/public/201511/20151102185240_tgl13rmwaw.jpg",
 "isSpecial":0,
 "articleId":276,
 "hasImages":0,
 "dates":"2015-11-02 18:53:16",
 "title":"【转】小学生的作文《俺的家》，老师笑吐血",
 "browsers":10
 */
@property (nonatomic, assign) NSNumber *articleId;
@property (nonatomic, strong) NSString *dates;
@property (nonatomic, strong) NSURL *image;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) NSNumber *isSpecial;
@property (nonatomic, assign) NSNumber *hasImages;
@property (nonatomic, assign) NSNumber *browsers;

@property (nonatomic, assign) NSNumber *diggs;
@property (nonatomic, assign) NSNumber *comments;
@property (nonatomic, assign) NSNumber *digged;
@property (nonatomic, assign) NSNumber *collected;

@property (nonatomic, assign) NSNumber *hasVideo;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *videoSize;
@property (nonatomic, copy) NSString *videoName;


//@property (nonatomic, strong)   NSDictionary *images;
@property (nonatomic, assign) NSArray *images;

@property (nonatomic, strong) NSMutableAttributedString *attributedTittle;
@property (nonatomic, strong) NSAttributedString *attributedBrowersCount;
@property (nonatomic, strong) NSAttributedString *attributedReplysCount;


@property (nonatomic, assign) NSNumber *cateId;//栏目ID
@property (nonatomic, readonly ,copy) NSString *cateName;
@property (nonatomic, readonly ,copy) NSString *categroy;
@property (nonatomic, readonly ,copy) NSString *number;
//@property (nonatomic, readonly ,copy) NSString *description;
@property (nonatomic, readonly ,copy) NSString *detailUrl;
@property (nonatomic, readonly ,copy) NSURL *smallImage;
@property (nonatomic, assign) NSNumber *articles;
@property (nonatomic, assign) NSNumber *attentions;
@property (nonatomic, assign) NSNumber *treeLevel;
@property (nonatomic, readonly ,copy) NSString *treeNumber;
@property (nonatomic, assign) NSNumber *terminated;
@property (nonatomic, assign) NSNumber *attentioned;

@property (nonatomic, assign) NSString *listTitle;

/*展现模板样式
1|左图右文章标题、摘要
2|三张图片并排
3|左一大图右两小图
4|大图展现 */
@property (nonatomic, assign) NSNumber *showType;

@property (nonatomic, assign) NSNumber *specialId; //专题ID
//1:一院  2:二院... 9:九院  10:策  11:视频  12:音频  13:专题
@property (nonatomic, assign) NSNumber *source;

@property (nonatomic, assign) NSNumber *isToDetail; //是否进入详情页

@property (nonatomic, assign) NSString *specialName; //专题名称

@property (nonatomic, assign) NSString *specialImage; //专题图片

@property (nonatomic, assign) NSString *sourceImage; //来源的小图标

@property (nonatomic, assign) NSNumber *isReject;//1 退稿， 0 正在审核


//文档中有文件
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLength;


@property (nonatomic, assign) NSNumber *hasAudio;
@property (nonatomic, assign) NSString *audio;
@property (nonatomic, assign) NSString *audioName;

@property (nonatomic, assign) NSNumber *infoLevel; //1. 校内可见  2.校外可见，不可分享  3.校外可见，可分享
@property (nonatomic, assign) NSString *shareUrl;

@property (nonatomic, assign) NSNumber *isReader; //是否为电子书
@property (nonatomic, assign) NSString *readerSuffix;  //电子书后缀

@property (nonatomic, assign) NSString *footer;


@property (nonatomic, assign) NSString *author;

@property (nonatomic, assign) NSString *subtitle;
@end
