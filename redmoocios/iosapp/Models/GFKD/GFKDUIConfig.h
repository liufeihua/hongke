//
//  GFKDUIConfig.h
//  iosapp
//
//  Created by redmooc on 16/12/20.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDUIConfig : GFKDBaseObject

@property (nonatomic, strong) NSString *topBgColor; //顶部背景色
@property (nonatomic, strong) NSString *topTabFocusBgColor; //顶部TAB背景色（点中状态）
@property (nonatomic, strong) NSString *topTabFontColor; //顶部TAB字体颜色（未点中状态）
@property (nonatomic, strong) NSString *bottomBgColor;  //底部背景颜色
@property (nonatomic, strong) NSArray *bottomItemIcons;  //底部按钮图标（未点中状态）
@property (nonatomic, strong) NSArray *bottomFocusItemIcons;  //部按钮图标（点中状态）
@property (nonatomic, strong) NSString *topLogoImage; //顶部LOGO图片
@property (nonatomic, strong) NSString *topBgImage; //顶部背景图片（为空时不显示）
@property (nonatomic, strong) NSString *topTabFocusFontColor; //顶部TAB字体颜色（点中状态）
@property (nonatomic, strong) NSString *topTabBgColor; //顶部TAB背景色（未点中状态）

@property (nonatomic, strong) NSString *bottomBgImage;

@end
