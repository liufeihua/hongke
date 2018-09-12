//
//  TwoSmallCell.m
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "TwoSmallCell.h"
#import <Masonry/Masonry.h>
#define kWindowH   [UIScreen mainScreen].bounds.size.height //应用程序的屏幕高度
#define kWindowW    [UIScreen mainScreen].bounds.size.width  //应用程序的屏幕宽度

@implementation TwoSmallCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}


#pragma mark -懒加载
- (CategoryButton *) button0 {
    if (!_button0) {
        _button0 = [CategoryButton new];
        [self.contentView addSubview:_button0];
        [_button0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(kWindowW/2-1);
        }];
        [_button0 addTarget:self action:@selector(buttonDidChick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button0;
}

- (CategoryButton *)button1 {
    if (!_button1) {
        _button1 = [CategoryButton new];
        [self.contentView addSubview:_button1];
        // 做分割线
        UIView *partitionView = [UIView new];
        [self.contentView addSubview:partitionView];
        [partitionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(1);
        }];
        partitionView.backgroundColor = [UIColor lightGrayColor];
        
        [_button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.left.mas_equalTo(partitionView.mas_right);
        }];
        [_button1 addTarget:self action:@selector(buttonDidChick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button1;
}

- (UIView *) partitionView {
    if (!_partitionView) {
        _partitionView = [UIView new];
        [self.contentView addSubview:_partitionView];
        [_partitionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0.5);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        _partitionView.backgroundColor = [UIColor grayColor];
    }
    return _partitionView;
}

- (CGFloat)cellHeight {
    return 25;
}

- (void) buttonDidChick:(CategoryButton *)button{
    if ([self.delegate respondsToSelector:@selector(TwoSmallButtonDidChick:)]) {
        [self.delegate TwoSmallButtonDidChick:button.tag];
    }
}

@end
