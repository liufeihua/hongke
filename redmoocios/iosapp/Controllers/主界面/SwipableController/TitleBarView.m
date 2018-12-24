//
//  TitleBarView.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-20.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TitleBarView.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"

@interface TitleBarView ()




@end

@implementation TitleBarView

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    _sumNumTitle = titles.count;
    if (self) {
        _currentIndex = 0;
        _titleButtons = [NSMutableArray new];
        //当标题数目太多时
        CGFloat buttonWidth = frame.size.width / _sumNumTitle;
        CGFloat allWidth = frame.size.width;
        if (_sumNumTitle > 4) {
            buttonWidth = 80;//frame.size.width / 4 ;
            allWidth = _sumNumTitle * buttonWidth;
        }
        CGFloat buttonHeight = frame.size.height;
        
        [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor titleBarColor];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateNormal];
            
            button.frame = CGRectMake(buttonWidth * idx, 0, buttonWidth, buttonHeight);
            button.tag = idx;
            [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [_titleButtons addObject:button];
            [self addSubview:button];
            [self sendSubviewToBack:button];
        }];
        
        self.contentSize = CGSizeMake(allWidth, 25);
        self.showsHorizontalScrollIndicator = NO;
        UIButton *firstTitle = _titleButtons[0];
        [firstTitle setTitleColor:kNBR_ProjectColor forState:UIControlStateNormal];
        firstTitle.transform = CGAffineTransformMakeScale(1.15, 1.15);
    }
    
    return self;
}


- (void)onClick:(UIButton *)button
{
    if (_currentIndex != button.tag) {
        
        
        if (_sumNumTitle > 4) {
            UIButton *newBtn = _titleButtons[button.tag];
            CGFloat offsetx = newBtn.center.x - self.frame.size.width * 0.5;
            
            CGFloat offsetMax = self.contentSize.width - self.frame.size.width;
            if (offsetx < 0) {
                offsetx = 0;
            }else if (offsetx > offsetMax){
                offsetx = offsetMax;
            }
            
            CGPoint offset = CGPointMake(offsetx, self.contentOffset.y);
            [self setContentOffset:offset animated:YES];

        }
        
        UIButton *preTitle = _titleButtons[_currentIndex];
        [preTitle setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
        preTitle.transform = CGAffineTransformIdentity;
        
        [button setTitleColor:kNBR_ProjectColor forState:UIControlStateNormal];
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
        _currentIndex = button.tag;
        _titleButtonClicked(button.tag);
        
        
        
        
//        if (_currentIndex+3<_sumNumTitle){
//            CGPoint offset = CGPointMake(_currentIndex*self.frame.size.width / 4 , self.contentOffset.y);
//            [self setContentOffset:offset animated:YES];
//        }

    }
}

- (void)setTitleButtonsColor
{
    for (UIButton *button in self.subviews) {
        button.backgroundColor = [UIColor titleBarColor];
    }
}

@end
