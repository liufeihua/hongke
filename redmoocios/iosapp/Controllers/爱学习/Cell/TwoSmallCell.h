//
//  TwoSmallCell.h
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryButton.h"

@protocol TwoSmallCellDelegate <NSObject>

- (void) TwoSmallButtonDidChick:(NSInteger)tag;

@end
@interface TwoSmallCell : UITableViewCell

@property (nonatomic, weak) id<TwoSmallCellDelegate> delegate;

@property (nonatomic, strong) CategoryButton *button0;

@property (nonatomic, strong) CategoryButton *button1;

//分割线
@property (nonatomic, strong) UIView *partitionView;

/**  返回本类计算行高 */
@property (nonatomic,assign) CGFloat cellHeight;

@end
