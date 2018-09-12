//
//  OneSpecialCell.m
//  iosapp
//
//  Created by redmooc on 17/6/7.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "OneSpecialCell.h"
#import <Masonry/Masonry.h>

#define kSpicWidth  50
#define kSpicHeight kSpicWidth*43/31.0      //一大张纸的尺寸：31x43

@implementation OneSpecialCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 剪头样式
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // 分割线间隔
        self.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    return self;
}


#pragma mark - Cell属性懒加载


//- (UIButton *)coverBtn {
//    if (!_coverBtn) {
//        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.contentView addSubview:_coverBtn];
//        [_coverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(10);
//            make.top.mas_equalTo(10);
//            make.width.mas_equalTo(kSpicWidth);
//            make.height.mas_equalTo(kSpicHeight);
//        }];
//    }
//    return _coverBtn;
//}

- (UIImageView *) coverImage {
    if (!_coverImage) {
        _coverImage = [UIImageView new];
        [self.contentView addSubview:_coverImage];
        [_coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(5);
            make.width.mas_equalTo(kSpicWidth);
            make.height.mas_equalTo(kSpicHeight);
        }];

    }
    return _coverImage;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [UILabel new];
        [self.contentView addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.mas_equalTo(self.coverImage.mas_right).mas_equalTo(12);
            make.right.mas_equalTo(-10);
        }];
        _titleLb.font = [UIFont systemFontOfSize:16];
        
    }
    return _titleLb;
}
- (UILabel *)subTitleLb {
    if (!_subTitleLb) {
        _subTitleLb = [UILabel new];
        [self.contentView addSubview:_subTitleLb];
        [_subTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            // 照片中间
//            make.centerY.mas_equalTo(self.coverImage);
//            make.leadingMargin.mas_equalTo(self.titleLb);
//            make.right.bottom.mas_equalTo(-10);
            
            make.leadingMargin.mas_equalTo(self.titleLb);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(self.titleLb.mas_bottom).mas_equalTo(5);
        }];
        _subTitleLb.textColor = [UIColor lightGrayColor];
        _subTitleLb.font = [UIFont systemFontOfSize:14];
        _subTitleLb.numberOfLines = 2;
    }
    return _subTitleLb;
}
- (CGFloat)cellHeight {
    // kRect图高, 5上间距,5下行留白高度
    return kSpicHeight+5+5;
}



@end
