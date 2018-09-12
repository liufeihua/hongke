//
//  DiscoverReusableView.m
//  iosapp
//
//  Created by redmooc on 16/7/12.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "DiscoverReusableView.h"
#import "Utils.h"

@implementation DiscoverReusableView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self confingSubViews];
    }
    return self;
}
-(void)confingSubViews{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor titleColor];
    [self addSubview:self.titleLabel];
}

@end
