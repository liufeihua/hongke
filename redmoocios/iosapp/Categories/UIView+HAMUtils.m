//
//  UIView+HAMUtils.m
//  iosapp
//
//  Created by redmooc on 16/11/2.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "UIView+HAMUtils.h"

@implementation UIView (HAMUtils)

- (void)detectScrollsToTopViews {
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            if (scrollView.scrollsToTop) {
                NSLog(@"ScrollsToTop:%@", scrollView);
            }
        }
        
        [view detectScrollsToTopViews];
    }
}

@end
