//
//  XHYScrollingNavBarViewController.m
//  XHYScrollingNavBarViewController
//
//  Created by smm_imac on 14-3-7.
//  Copyright (c) 2014年 XHY. All rights reserved.
//

#import "XHYScrollingNavBarViewController.h"
#define NavBarFrame self.navigationController.navigationBar.frame

@interface XHYScrollingNavBarViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIView *scrollView;
@property (retain, nonatomic)UIPanGestureRecognizer *panGesture;
@property (retain, nonatomic)UIView *overLay;
@property (assign, nonatomic)BOOL isHidden;

@end

@implementation XHYScrollingNavBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        if (IOS7) {
//            self.edgesForExtendedLayout = UIRectEdgeNone;
//            self.automaticallyAdjustsScrollViewInsets=NO;
//        }
    }
    return self;
}

//设置跟随滚动的滑动试图
-(void)followRollingScrollView:(UIView *)scrollView
{
    self.scrollView = scrollView;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] init];
    self.panGesture.delegate=self;
    self.panGesture.minimumNumberOfTouches = 1;
    [self.panGesture addTarget:self action:@selector(handlePanGesture:)];
    [self.scrollView addGestureRecognizer:self.panGesture];
    
    self.overLay = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.overLay.alpha=0;
    self.overLay.backgroundColor=self.navigationController.navigationBar.barTintColor;
    [self.navigationController.navigationBar addSubview:self.overLay];
    [self.navigationController.navigationBar bringSubviewToFront:self.overLay];
}

#pragma mark - 兼容其他手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - 手势调用函数
-(void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:[self.scrollView superview]];
//    NSLog(@"%f",translation.y);
//    CGFloat detai = self.lastContentset - translation.y;
    //显示
    if (translation.y >= 5) {
        if (self.isHidden) {
            [self showViewNav];
        }
    }
    //隐藏
    if (translation.y <= -20) {
        if (!self.isHidden) {
            [self hiddenViewNav];
        }
    }
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController.navigationBar bringSubviewToFront:self.overLay];
}
- (void)viewWillDisappear:(BOOL)animated{
    //视图将被从屏幕上移除之前执行  显示导航，方便后面界面显示。
    [self showViewNav];
}

- (void)showViewNav{
    self.overLay.alpha=0;
    CGRect navBarFrame=NavBarFrame;
    CGRect scrollViewFrame=self.scrollView.frame;
    
    navBarFrame.origin.y = 20;
//    scrollViewFrame.origin.y += 44;
//    scrollViewFrame.size.height -= 44;
    scrollViewFrame.origin.y = navBarFrame.origin.y + navBarFrame.size.height;
    scrollViewFrame.size.height -= navBarFrame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        NavBarFrame = navBarFrame;
        self.scrollView.frame=scrollViewFrame;
    }];
    self.isHidden= NO;
}

- (void)hiddenViewNav{
    CGRect frame =NavBarFrame;
    CGRect scrollViewFrame=self.scrollView.frame;
    frame.origin.y = -24;
//    scrollViewFrame.origin.y -= 44;
//    scrollViewFrame.size.height += 44;
    scrollViewFrame.origin.y = frame.origin.y + frame.size.height;
    scrollViewFrame.size.height += frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        NavBarFrame = frame;
        self.scrollView.frame=scrollViewFrame;
    } completion:^(BOOL finished) {
        self.overLay.alpha=1;
    }];
    self.isHidden=YES;
}


@end
