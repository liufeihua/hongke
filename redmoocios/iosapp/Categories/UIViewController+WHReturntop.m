//
//  UIViewController+WHReturntop.m
//  WHReturntop
//
//  Created by dkluhck on 15/4/30.
//  Copyright (c) 2015年 dkluhck. All rights reserved.
//

#import "UIViewController+WHReturntop.h"
#import <objc/runtime.h>

@implementation UIViewController (WHReturntop)


static char WHTopButtonkey;

-(void)setTop:(WHTopButton *)Top
{
    if (Top != self.Top) {
        [self.Top removeFromSuperview];
        
        [self willChangeValueForKey:@"button"];
        objc_setAssociatedObject(self, &WHTopButtonkey,
                                 Top,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"button"];
        [self.view addSubview:Top];
    }
}

-(WHTopButton *)Top
{
    return objc_getAssociatedObject(self, &WHTopButtonkey);
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.Top.startContentOffsetY = scrollView.contentOffset.y ;
    
}

//* 重写父类这个方式发一定要调用super方法 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 500) {
        self.Top.hidden = YES;
    }
    if (scrollView.isDragging == YES) {
        if (scrollView.contentOffset.y > self.Top.startContentOffsetY) {  //让开始contentoffsety值跟着scrollview.contentoffent.y相差5,
            self.Top.startContentOffsetY = scrollView.contentOffset.y - 1;
            
        }
        if (scrollView.contentOffset.y < self.Top.startContentOffsetY) {
            self.Top.startContentOffsetY = scrollView.contentOffset.y + 1;
        }
        if (self.Top.startContentOffsetY - scrollView.contentOffset.y <0) {//由于值相差5,且跟着,所以这里所减法判断的时候就知道是向上还是向下滑动了
            self.Top.hidden = YES;
        }else{
            self.Top.hidden = NO;
        }
    }

}

-(void )AddWHReturnTop:(CGRect)buttonCGRect BackImage:(UIImageView *)imageView CallBackblock:(void (^)())Callblock
{
    if (self.Top == nil) {
        WHTopButton *button = [WHTopButton AddWHReturnTop:buttonCGRect BackImage:imageView CallBackblock:Callblock];
        self.Top = button;
        self.Top.frame = buttonCGRect;
        [self.Top setBackgroundImage:imageView.image forState:UIControlStateNormal];
        [self.Top addTarget:self.Top.WHReturnTopTarget action:self.Top.WHReturnTopAction forControlEvents:UIControlEventTouchUpInside];
        
    }

}

@end
