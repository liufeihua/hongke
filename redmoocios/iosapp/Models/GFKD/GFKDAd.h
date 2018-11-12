//
//  GFKDAd.h
//  iosapp
//
//  Created by redmooc on 2018/11/9.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDAd : GFKDBaseObject

@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, strong) NSString *linkType; //1  网站链接  2文章链接


@end
