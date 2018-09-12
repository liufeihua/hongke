//
//  GFKDMyCollect.h
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDMyCollect : GFKDBaseObject

@property (nonatomic, assign) NSNumber *articleId;
@property (nonatomic, assign) NSNumber *collectId;
@property (nonatomic, strong) NSString *collectDate;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) NSNumber *comments;
@property (nonatomic, strong) NSString *nodeCode;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *vedio;
@property (nonatomic, assign) NSNumber *browsers;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSNumber *showType;
@property (nonatomic, assign) NSNumber *diggs;
@property (nonatomic, assign) NSNumber *hasImages;
@property (nonatomic, assign) NSNumber *hasVideo;





@end
