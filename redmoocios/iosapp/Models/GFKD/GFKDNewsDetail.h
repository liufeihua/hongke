//
//  GFKDNewsDetail.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/5.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"
/*
 
 articleId = 297;
 attention = 0;
 author = "\U9648\U7389\U6559";
 authorId = 11;
 authorPhoto = "http://mapi.nudt.edu.cn/uploads/1/image/public/201510/20151031145859_h3l9jfrtu5.jpg";
 browsers = 50;
 cateId = 90;
 collected = 0;
 comments = 0;
 content =
 dates = "2015-11-04 12:59:04";
 description =
 detailUrl = "http://mapi.nudt.edu.cn/info/297.htx";
 digged = 0;
 diggs = 1;
 hasImages = 0;
 image = "http://mapi.nudt.edu.cn/uploads/1/image/public/201511/20151104125919_2dvncy6k8d";
 images =     (
 );
 title
 */

@interface GFKDNewsDetail : GFKDBaseObject

@property (nonatomic, assign) NSNumber *articleId;
@property (nonatomic, assign) NSNumber *attention;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, assign) NSNumber *authorId;
@property (nonatomic, strong) NSString *authorPhoto;
@property (nonatomic, strong) NSNumber *browsers;
@property (nonatomic, strong) NSNumber *cateId;
@property (nonatomic, strong) NSNumber *collected;//是否收藏
@property (nonatomic, strong) NSNumber *comments;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *digged; //是否点赞
@property (nonatomic, strong) NSNumber *diggs;//点赞数
@property (nonatomic, strong) NSNumber *hasImages;
@property (nonatomic, strong) NSString *dates;
@property (nonatomic, strong) NSString *description_news;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *videoSize;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *fullTitle;
@property (nonatomic, strong) NSString *video;
@property (nonatomic, strong) NSString *videoTime;
@property (nonatomic, strong) NSString *detailUrl;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSNumber *hasVideo;
@property (nonatomic, strong) NSString *sourceUrl;
@property (nonatomic, strong) NSString *categroy;
@property (nonatomic, strong) NSString *listTitle;

@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSString *editionUnit;

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

@property (nonatomic, assign) NSString *footer;  //
@property (nonatomic, assign) NSString *header;

@end
