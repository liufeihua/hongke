//
//  LSTableViewCell.h
//  LSPlayer
//
//  Created by ls on 16/3/8.
//  Copyright © 2016年 song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDNews.h"

@interface LSTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picView;

@property (nonatomic, strong) GFKDNews *model;

@property (nonatomic, assign) NSInteger index;//方便在滚动时取出对应cell的frame

+(instancetype)cellWithTabelView:(UITableView*)tableview;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com