//
//  GFKDNewsComment.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/5.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"
#import <UIKit/UIKit.h>

@interface GFKDNewsComment : GFKDBaseObject


@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *ftype;//"Info" "Comment"
@property (nonatomic, assign) NSNumber *fid;  ///ftype="Info" fid=articleId / ftype="Comment" fid=commentId
@property (nonatomic, assign) NSNumber *commentId;
@property (nonatomic, assign) NSNumber *creatorid;
@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSString *creatorPhoto;
@property (nonatomic, strong) NSString *fromUser;

@property (nonatomic, assign) CGFloat cellHeight;

@end
