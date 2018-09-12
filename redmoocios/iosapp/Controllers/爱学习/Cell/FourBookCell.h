//
//  FourBookCell.h
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FourBookCellDelegate <NSObject>

- (void) imageViewClick:(NSInteger)tag;

@end

/**爱学习  一行四列**/
@interface FourBookCell : UITableViewCell

@property (nonatomic, weak) id<FourBookCellDelegate> delegate;
/**  跳转按钮0 */
@property (nonatomic,strong) UIImageView *clickBtn0;
/**  跳转按钮1 */
@property (nonatomic,strong) UIImageView *clickBtn1;
/**  跳转按钮2 */
@property (nonatomic,strong) UIImageView *clickBtn2;
/**  跳转按钮3 */
@property (nonatomic,strong) UIImageView *clickBtn3;
/**  跳转按钮介绍0 */
@property (nonatomic,strong) UILabel *detailLb0;
/**  跳转按钮介绍1 */
@property (nonatomic,strong) UILabel *detailLb1;
/**  跳转按钮介绍2 */
@property (nonatomic,strong) UILabel *detailLb2;
/**  跳转按钮介绍3 */
@property (nonatomic,strong) UILabel *detailLb3;

/**  返回本类计算行高 */
@property (nonatomic,assign) CGFloat cellHeight;

@end
