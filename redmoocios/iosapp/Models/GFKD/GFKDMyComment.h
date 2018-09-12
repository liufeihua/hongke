//
//  GFKDMyComment.h
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDMyComment : GFKDBaseObject


@property (nonatomic, strong) NSString *fromUser;//
@property (nonatomic, assign) NSNumber *infoId;  //文章ID
@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *ftype;
@property (nonatomic, assign) NSNumber *fid;
@property (nonatomic, assign) NSNumber *commentId;
@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSString *creatorPhoto;

@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) NSNumber *hasImages;
@property (nonatomic, assign) NSNumber *hasVideo;
@property (nonatomic, assign) NSNumber *specialId;
@property (nonatomic, assign) NSNumber *isSpecial;
@property (nonatomic, strong) NSString *video;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *nodeCode;  //"readilyTake"随手拍


@end
