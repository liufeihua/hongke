//
//  ReplyCommentCell.h
//  iosapp
//
//  Created by redmooc on 16/3/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFKDNewsComment;

@interface ReplyCommentCell : UITableViewCell

@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *fromUserLabel;
@property (nonatomic, strong) UILabel *contentLabel;


- (void)setContentWithComment:(GFKDNewsComment *)comment;

@end
