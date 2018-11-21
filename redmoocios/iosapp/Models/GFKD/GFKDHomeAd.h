//
//  GFKDHomeAd.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/6.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDHomeAd : GFKDBaseObject

@property (nonatomic, assign) NSNumber *advId;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *advTitle;
//@property (nonatomic, copy)   NSString *description;
@property (nonatomic, strong) NSString *linkType; //1  网站链接  2文章链接

@property (nonatomic, assign) NSNumber *imgWRatio;


@end
