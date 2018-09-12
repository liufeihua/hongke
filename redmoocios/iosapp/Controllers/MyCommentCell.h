//
//  MyCommentCell.h
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GFKDMyComment.h"
#import "TTTAttributedLabel.h"

@interface MyCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *label_userName;

@property (weak, nonatomic) IBOutlet UILabel *label_commentDate;
@property (weak, nonatomic) IBOutlet UILabel *label_commentContent;

@property (weak, nonatomic) IBOutlet UILabel *label_newsTitle;

@property (weak, nonatomic) IBOutlet UILabel *label_fromUser;


@property(nonatomic,strong) GFKDMyComment *myCommentModel;
@property (weak, nonatomic) IBOutlet UILabel *label_info;

+ (CGFloat)heightForRow:(GFKDMyComment *)myComment;

@end
