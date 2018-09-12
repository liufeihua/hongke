//
//  popTransition.m
//  TranistionAnimate
//
//  Created by peng_qitao on 16/10/11.
//  Copyright © 2016年 peng_qitao. All rights reserved.
//

#import "popTransition.h"

@implementation popTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.7f;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    [self doPopAnimation:transitionContext];
}

- (void)doPopAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    //获取转场动画开始，结束的控制器
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //确定结束控制器的视图大小
    CGRect finalFrameForVC = [transitionContext finalFrameForViewController:toViewController];
    UIView *containerView = [transitionContext containerView];
    //设置结束控制器的视图大小
    toViewController.view.frame = finalFrameForVC;
    toViewController.view.alpha = 1.0f;
    [containerView addSubview:toViewController.view];
    [containerView sendSubviewToBack:toViewController.view];
    //开始控制器视图的快照
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = fromViewController.view.frame;
    [containerView addSubview:snapshotView];
    [fromViewController.view removeFromSuperview];
    
    //执行关键帧动画
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    void (^anima)() = ^(){
        for (int i = 0; i < 5; i++) {
            //添加5帧动画，缩放Y轴的大小
            [UIView addKeyframeWithRelativeStartTime:((i/5) * duration) relativeDuration:(0.2)*duration animations:^{
                snapshotView.transform = CGAffineTransformMakeScale(1, 1 - (i+1)/5);
                snapshotView.alpha = 0.0;
            }];
        }
    };
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:anima completion:^(BOOL finished) {
        
        if (finished) {
            [snapshotView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }
    }];
}
@end
