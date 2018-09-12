//
//  CommentsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "GFKDObjsViewController.h"
#import "GFKDNewsComment.h"

typedef NS_ENUM(int, CommentType)
{
    CommentTypeNews = 1,
    CommentTypeTake,
};

@class OSCComment;

@interface CommentsViewController : GFKDObjsViewController

@property (nonatomic, readwrite, assign) int64_t objectAuthorID;

@property (nonatomic, copy) void (^didCommentSelected)(GFKDNewsComment *comment);
@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID;

@end
