//
//  OneSpecialCell.h
//  iosapp
//
//  Created by redmooc on 17/6/7.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneSpecialCell : UITableViewCell

//@property (nonatomic,strong) UIButton *coverBtn;
@property (nonatomic,strong) UIImageView *coverImage;
@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UILabel *subTitleLb;


/**  返回本类计算行高 */
@property (nonatomic,assign) CGFloat cellHeight;

@end
