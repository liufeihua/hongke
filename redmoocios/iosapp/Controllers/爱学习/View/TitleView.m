//
//  TitleView.m
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "TitleView.h"
#import <Masonry/Masonry.h>
#import "MoreButton.h"
#import "OSCAPI.h"

@interface TitleView()

/**  三角剪头 */
@property (nonatomic,strong) UIImageView *arrowIV;
/**  更多按钮 */
@property (nonatomic,strong) UIButton *moreBtn;

@end

@implementation TitleView

-(instancetype)initWithTitle:(NSString *)title hasMore:(BOOL)more
{
    if (self == [super init]) {
        self.title = title;
        self.arrowIV.image = [UIImage imageNamed:@"tabbar_np_play"];
        
//        [self.descriptionLb setTextColor:[UIColor grayColor]];
//        [self.titleLb setTextColor:[UIColor blackColor]];
        if (more) {
            [self.moreBtn setTitle:@"更多 " forState:UIControlStateNormal];
        }
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - 懒加载
- (UIImageView *)arrowIV {
    if (!_arrowIV) {
        _arrowIV = [[UIImageView alloc] init];
        [self addSubview:_arrowIV];
        [_arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.bottom.mas_equalTo(-12);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
    }
    return _arrowIV;
}

- (UILabel *) titleLb {
    if (!_titleLb) {
        _titleLb = [UILabel new];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.arrowIV);
            make.left.mas_equalTo(self.arrowIV.mas_right).mas_equalTo(4);
            //make.width.mas_equalTo(150);
        }];
        _titleLb.font = [UIFont systemFontOfSize:17];
        _titleLb.text = _title;
    }
    return _titleLb;
}

- (UILabel *) descriptionLb {
    if (!_descriptionLb) {
        _descriptionLb = [UILabel new];
        [self addSubview:_descriptionLb];
        [_descriptionLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.titleLb.mas_bottom);
            make.left.mas_equalTo(self.hotLb.mas_right).mas_equalTo(4);
            //make.width.mas_equalTo(150);
           // make.right.lessThanOrEqualTo(-50);
        }];
        _descriptionLb.font = [UIFont systemFontOfSize:15];
        _descriptionLb.textColor = [UIColor grayColor];
        _descriptionLb.textAlignment = NSTextAlignmentLeft;
    }
    return _descriptionLb;
}

- (UILabel *) hotLb {
    if (!_hotLb) {
        _hotLb = [UILabel new];
        [self addSubview:_hotLb];
        [_hotLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.titleLb.mas_bottom);
            make.left.mas_equalTo(self.titleLb.mas_right).mas_equalTo(4);
        }];
        _hotLb.font = [UIFont boldSystemFontOfSize:15];
        _hotLb.textColor = kNBR_ProjectColor;
        _hotLb.textAlignment = NSTextAlignmentLeft;
    }
    return _hotLb;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [MoreButton new];
        [self addSubview:_moreBtn];
        [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-5);
            make.centerY.mas_equalTo(self.titleLb);
            make.size.mas_equalTo(CGSizeMake(60, 20));
        }];
        
        [_moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _moreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_moreBtn setImage:[UIImage imageNamed:@"cell_arrow"] forState:UIControlStateNormal];
        
        // 按钮点击事件
        [_moreBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _moreBtn;
}

- (void)click {
    if ([self.delegate respondsToSelector:@selector(titleViewDidClick:)]) {
        [self.delegate titleViewDidClick:self.tag];
    }
}

@end
