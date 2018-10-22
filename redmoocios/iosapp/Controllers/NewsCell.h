//
//  NewsCell.h
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GFKDNews.h"

@interface NewsCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lblBrowers;
@property (weak, nonatomic) IBOutlet UILabel *lblDate; //时间

/**
 *  图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
/**
 *  标题
 */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/**
 *  回复数
 */
@property (weak, nonatomic) IBOutlet UILabel *lblReply;
/**
 *  描述
 */
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
/**
 *  第二张图片（如果有的话）
 */
@property (weak, nonatomic) IBOutlet UIImageView *imgOther1;
/**
 *  第三张图片（如果有的话）
 */
@property (weak, nonatomic) IBOutlet UIImageView *imgOther2;

@property (weak, nonatomic) IBOutlet UIButton *VideoImg;

@property (weak, nonatomic) IBOutlet UIImageView *sourceIcon;
- (IBAction)videoChick:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *audioImg;

/**
 *  类方法返回可重用的id
 */
+ (NSString *)idForRow:(GFKDNews *)NewsModel;

+ (CGFloat)heightForRow:(GFKDNews *)NewsModel;
@property(nonatomic,strong) GFKDNews *NewsModel;


@property (nonatomic, assign) int indexPathRow;//方便在滚动时取出对应cell的frame
@property (nonatomic, assign) int indexPathSection;
/**
 *  第二张,第三张图片（如果有的话）
 */
//@property (nonatomic, strong) UIImageView *imgOther1;
//@property (nonatomic, strong) UIImageView *imgOther2;

@property (weak, nonatomic) IBOutlet UIImageView *img_tuigao;

@property (weak, nonatomic) IBOutlet UIImageView *topicImageView;

- (void) closeVedio;


@end
