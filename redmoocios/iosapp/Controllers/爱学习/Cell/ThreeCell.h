//
//  ThreeCell.h
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThreeCellDelegate <NSObject>

- (void) ThreeCellImageViewDidChick:(NSInteger)tag cellTag:(NSInteger)cellTag;

@end

@interface ThreeCell : UITableViewCell

@property (nonatomic, weak) id<ThreeCellDelegate> delegate;
/**  跳转按钮0 */
@property (nonatomic,strong) UIImageView *clickBtn0;
/**  跳转按钮1 */
@property (nonatomic,strong) UIImageView *clickBtn1;
/**  跳转按钮2 */
@property (nonatomic,strong) UIImageView *clickBtn2;
/**  跳转按钮介绍0 */
@property (nonatomic,strong) UILabel *detailLb0;
/**  跳转按钮介绍1 */
@property (nonatomic,strong) UILabel *detailLb1;
/**  跳转按钮介绍2 */
@property (nonatomic,strong) UILabel *detailLb2;
/**  返回本类计算行高 */
@property (nonatomic,assign) CGFloat cellHeight;

@end
