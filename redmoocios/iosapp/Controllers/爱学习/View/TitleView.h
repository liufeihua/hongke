//
//  TitleView.h
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

//监听更多按钮点击事件协议
@protocol TitleViewDelegate <NSObject>

- (void) titleViewDidClick:(NSInteger)tag;

@end

@interface TitleView : UIView

@property (nonatomic, weak) id<TitleViewDelegate> delegate;
-(instancetype)initWithTitle:(NSString *)title hasMore:(BOOL)more;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titleLb;

@property (nonatomic, strong) UILabel *descriptionLb;

@property (nonatomic, strong) UILabel *hotLb;

@end
