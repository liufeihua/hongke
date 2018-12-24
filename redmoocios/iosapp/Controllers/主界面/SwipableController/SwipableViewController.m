//
//  SwipableViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-19.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "SwipableViewController.h"
#import "Utils.h"
#import "OSCAPI.h"
//#import "GFKDObjsViewController.h"
//#import "TweetsViewController.h"

@interface SwipableViewController ()  <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *controllers;

//@property(nonatomic,strong)GFKDObjsViewController *needScrollToTopPage;

@end



@implementation SwipableViewController


- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers
{
    return [self initWithTitle:title andSubTitles:subTitles andControllers:controllers underTabbar:NO];
}

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers underTabbar:(BOOL)underTabbar
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.navigationController.navigationBar.translucent = NO;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if (title) {self.title = title;}
        
        CGFloat titleBarHeight = 36;
        _titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight) andTitles:subTitles];
        _titleBar.backgroundColor = [UIColor clearColor];
        _titleBar.scrollsToTop = NO;//
        [self.view addSubview:_titleBar];
        
        
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        
        CGFloat height = self.view.bounds.size.height - titleBarHeight - 64 - (underTabbar ? 49 : 0);
        _viewPager.view.frame = CGRectMake(0, titleBarHeight, self.view.bounds.size.width, height);
        _viewPager.tableView.scrollsToTop = NO;

        [self addChildViewController:self.viewPager];
        [self.view addSubview:_viewPager.view];
        
        __weak TitleBarView *weakTitleBar = _titleBar;
        __weak HorizonalTableViewController *weakViewPager = _viewPager;
                
        _viewPager.changeIndex = ^(NSUInteger index) {
            weakTitleBar.currentIndex = index;
            for (UIButton *button in weakTitleBar.titleButtons) {
                if (button.tag != index) {
                    [button setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
                    button.transform = CGAffineTransformIdentity;
                    
                } else {
                    [button setTitleColor:kNBR_ProjectColor forState:UIControlStateNormal];
                    button.transform = CGAffineTransformMakeScale(1.2, 1.2);
                    
                    if (weakTitleBar.sumNumTitle > 4) {
                        CGFloat offsetx = button.center.x - weakTitleBar.frame.size.width * 0.5;
                        
                        CGFloat offsetMax = weakTitleBar.contentSize.width - weakTitleBar.frame.size.width;
                        if (offsetx < 0) {
                            offsetx = 0;
                        }else if (offsetx > offsetMax){
                            offsetx = offsetMax;
                        }
                        CGPoint offset = CGPointMake(offsetx, weakTitleBar.contentOffset.y);
                        [weakTitleBar setContentOffset:offset animated:YES];
                    }
                }
            }
            [weakViewPager scrollToViewAtIndex:index];
        };
    
//        _viewPager.scrollView = ^(CGFloat offsetRatio, NSUInteger focusIndex, NSUInteger animationIndex) {
//            UIButton *titleFrom = weakTitleBar.titleButtons[animationIndex];
//            UIButton *titleTo = weakTitleBar.titleButtons[focusIndex];
//           // CGFloat colorValue = (CGFloat)0x90 / (CGFloat)0xFF;
//            CGFloat colorValue = (CGFloat)0xC0 / (CGFloat)0xFF;
//            [UIView transitionWithView:titleFrom duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
////                [titleFrom setTitleColor:[UIColor colorWithRed:colorValue*(1-offsetRatio) green:colorValue blue:colorValue*(1-offsetRatio) alpha:1.0]
////                                forState:UIControlStateNormal];
//                [titleFrom setTitleColor:[UIColor colorWithRed:colorValue green:colorValue*(1-offsetRatio) blue:colorValue*(1-offsetRatio) alpha:1.0]
//                                forState:UIControlStateNormal];
//                titleFrom.transform = CGAffineTransformMakeScale(1 + 0.2 * offsetRatio, 1 + 0.2 * offsetRatio);
//            } completion:nil];
//            
//            
////            [UIView transitionWithView:titleTo duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
////                [titleTo setTitleColor:[UIColor colorWithRed:colorValue*offsetRatio green:colorValue blue:colorValue*offsetRatio alpha:1.0]
////                              forState:UIControlStateNormal];
//                [UIView transitionWithView:titleTo duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//                    [titleTo setTitleColor:[UIColor colorWithRed:colorValue green:colorValue*offsetRatio blue:colorValue*offsetRatio alpha:1.0]
//                                  forState:UIControlStateNormal];
//                titleTo.transform = CGAffineTransformMakeScale(1 + 0.2 * (1-offsetRatio), 1 + 0.2 * (1-offsetRatio));
//            } completion:nil];
//            
//            
//        };
        
        
        _titleBar.titleButtonClicked = ^(NSUInteger index) {
            [weakViewPager scrollToViewAtIndex:index];
        };
        
        // [weakViewPager scrollToViewAtIndex:0];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeColor];
    
}


- (void)scrollToViewAtIndex:(NSUInteger)index
{
    _viewPager.changeIndex(index);

}

#pragma mark - ScrollToTop

- (void)setScrollToTopWithTableViewIndex:(NSInteger)index
{
//    self.needScrollToTopPage.tableView.scrollsToTop = NO;
//    self.needScrollToTopPage = self.controllers[index];
//    self.needScrollToTopPage.tableView.scrollsToTop = YES;
    
//    self.viewPager.tableView.scrollsToTop = NO;
//    for (int i =0; i<self.childViewControllers.count; i++) {
//        HorizonalTableViewController *page = self.childViewControllers[i];
//        if (i == index) {
//            page.tableView.scrollsToTop = YES;
//        }else{
//            page.tableView.scrollsToTop = NO;
//        }
//    }
//    self.viewPager = self.childViewControllers[index];
//    self.viewPager.tableView.scrollsToTop = YES;
}


@end
