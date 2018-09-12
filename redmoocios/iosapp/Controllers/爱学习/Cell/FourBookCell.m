//
//  FourBookCell.m
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "FourBookCell.h"
#import <Masonry/Masonry.h>


#pragma mark - 屏幕相关
#define kWindowH   [UIScreen mainScreen].bounds.size.height //应用程序的屏幕高度
#define kWindowW    [UIScreen mainScreen].bounds.size.width  //应用程序的屏幕宽度
#define kRectW (kWindowW - 50)/4
#define kRectH kRectW*43/31.0      //一大张纸的尺寸：31x43

@implementation FourBookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


#pragma mark - 懒加载并布局
- (UIImageView *) clickBtn0 {
    if (!_clickBtn0) {
        _clickBtn0 = [UIImageView new];
        [self.contentView addSubview:_clickBtn0];
        [_clickBtn0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.size.mas_equalTo(CGSizeMake(kRectW, kRectH));
        }];
        _clickBtn0.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewClick:)];
        [_clickBtn0 addGestureRecognizer:singleTap];
    }
    return _clickBtn0;
}

- (UIImageView *)clickBtn1 {
    if (!_clickBtn1) {
        _clickBtn1 = [UIImageView new];
        [self.contentView addSubview:_clickBtn1];
        [_clickBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(self.clickBtn0.mas_right).mas_equalTo(10);
            make.size.mas_equalTo(self.clickBtn0);
        }];
        _clickBtn1.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewClick:)];
        [_clickBtn1 addGestureRecognizer:singleTap];
    }
    return _clickBtn1;
}
- (UIImageView *)clickBtn2 {
    if (!_clickBtn2) {
        _clickBtn2 = [UIImageView new];
        [self.contentView addSubview:_clickBtn2];
        [_clickBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(self.clickBtn0);
            make.left.mas_equalTo(self.clickBtn1.mas_right).mas_equalTo(10);
        }];
        _clickBtn2.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewClick:)];
        [_clickBtn2 addGestureRecognizer:singleTap];
    }
    return _clickBtn2;
}

- (UIImageView *)clickBtn3 {
    if (!_clickBtn3) {
        _clickBtn3 = [UIImageView new];
        [self.contentView addSubview:_clickBtn3];
        [_clickBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(self.clickBtn0);
            make.left.mas_equalTo(self.clickBtn2.mas_right).mas_equalTo(10);
        }];
        _clickBtn3.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewClick:)];
        [_clickBtn3 addGestureRecognizer:singleTap];
    }
    return _clickBtn3;
}

- (UILabel *)detailLb0 {
    if (!_detailLb0) {
        _detailLb0 = [UILabel new];
        [self.contentView addSubview:_detailLb0];
        [_detailLb0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leadingMargin.mas_equalTo(self.clickBtn0);
            make.trailingMargin.mas_equalTo(self.clickBtn0);
            make.top.mas_equalTo(self.clickBtn0.mas_bottom).mas_equalTo(10);
        }];
        _detailLb0.font = [UIFont systemFontOfSize:16];
        _detailLb0.numberOfLines = 1;
        _detailLb0.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLb0;
}
- (UILabel *)detailLb1 {
    if (!_detailLb1) {
        _detailLb1 = [UILabel new];
        [self.contentView addSubview:_detailLb1];
        [_detailLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leadingMargin.mas_equalTo(self.clickBtn1);
            make.trailingMargin.mas_equalTo(self.clickBtn1);
            make.top.mas_equalTo(self.clickBtn1.mas_bottom).mas_equalTo(10);
            //            make.bottom.mas_equalTo(-8);
        }];
        _detailLb1.font = [UIFont systemFontOfSize:16];
        _detailLb1.numberOfLines = 1;
        _detailLb1.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLb1;
}
- (UILabel *)detailLb2 {
    if (!_detailLb2) {
        _detailLb2 = [UILabel new];
        [self.contentView addSubview:_detailLb2];
        [_detailLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leadingMargin.mas_equalTo(self.clickBtn2);
            make.trailingMargin.mas_equalTo(self.clickBtn2);
            make.top.mas_equalTo(self.clickBtn2.mas_bottom).mas_equalTo(10);
        }];
        _detailLb2.font = [UIFont systemFontOfSize:16];
        _detailLb2.numberOfLines = 1;
        _detailLb2.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLb2;
}
- (UILabel *)detailLb3 {
    if (!_detailLb3) {
        _detailLb3 = [UILabel new];
        [self.contentView addSubview:_detailLb3];
        [_detailLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leadingMargin.mas_equalTo(self.clickBtn3);
            make.trailingMargin.mas_equalTo(self.clickBtn3);
            make.top.mas_equalTo(self.clickBtn3.mas_bottom).mas_equalTo(10);
        }];
        _detailLb3.font = [UIFont systemFontOfSize:16];
        _detailLb3.numberOfLines = 1;
        _detailLb3.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLb3;
}


// 本Cell行高
- (CGFloat)cellHeight {
    // kRect图高, 10描述和图间距, 14描述所用高,10下行留白高度
    return kRectH+10+14+10;
}


- (void)ImageViewClick:(UITapGestureRecognizer *)recognizer{
    if ([self.delegate respondsToSelector:@selector(imageViewClick:)]) {
        [self.delegate imageViewClick:recognizer.view.tag];
    }
}


@end
