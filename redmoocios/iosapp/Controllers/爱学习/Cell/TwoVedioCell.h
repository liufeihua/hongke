//
//  TwoVedioCell.h
//  iosapp
//
//  Created by redmooc on 17/6/7.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoVedioCell : UITableViewCell


/**  跳转按钮0 */
@property (nonatomic,strong) UIImageView *clickBtn0;
/**  跳转按钮1 */
@property (nonatomic,strong) UIImageView *clickBtn1;
/**  跳转按钮介绍0 */
@property (nonatomic,strong) UILabel *detailLb0;
/**  跳转按钮介绍1 */
@property (nonatomic,strong) UILabel *detailLb1;
/**  返回本类计算行高 */
@property (nonatomic,assign) CGFloat cellHeight;

@property (nonatomic, assign) BOOL isShowVedioImage;

@end
