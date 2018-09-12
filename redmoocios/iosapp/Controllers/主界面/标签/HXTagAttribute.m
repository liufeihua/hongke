//
//  HXTagAttribute.m
//  HXTagsView https://github.com/huangxuan518/HXTagsView
//  博客地址 http://blog.libuqing.com/
//  Created by Love on 16/6/30.
//  Copyright © 2016年 IT小子. All rights reserved.
//
#define RGBA(r,g,b,a)      [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

#import "HXTagAttribute.h"
#import "OSCAPI.h"

@implementation HXTagAttribute

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIColor *borderColor =  RGBA(211, 211, 211, 1);
        UIColor *textColor = RGBA(101, 101, 101, 1);
        UIColor *normalBackgroundColor = [UIColor clearColor];
        UIColor *selectedBackgroundColor = kNBR_ProjectColor ;//RGBA(134, 25, 23, 1);//0x861917
        
        _borderWidth = 0.45f;
        _borderColor = borderColor;
        _cornerRadius = 15.0;
        _normalBackgroundColor = normalBackgroundColor;
        _selectedBackgroundColor = selectedBackgroundColor;
        _titleSize = 14;
        _textColor = textColor;
        _keyColor = [UIColor redColor];
        _tagSpace = 26;
        
        _selectTextColor = [UIColor whiteColor];
    }
    return self;
}

@end
