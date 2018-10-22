//
//  SXMenuViewController.m
//  iosapp
//
//  Created by redmooc on 16/10/31.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "SXMenuViewController.h"
#import "GFKDObjsViewController.h"
//#import "SXTitleLable.h"
#import "UIView+Frame.h"
#import "HXTagsView.h"
#import "JRSegmentViewController.h"
#import "SearchArticleViewController.h"

#import "UIView+TYAlertView.h"
#import "TYAlertController+BlurEffects.h"
#import "floatADView.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#define NavBarFrame self.navigationController.navigationBar.frame

@interface SXMenuViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    floatADView *floatView;
}

@property (nonatomic, strong) HXTagsView *tagsView;//tagsView
@property(nonatomic,strong)GFKDObjsViewController *needScrollToTopPage;
@property (nonatomic, assign) int tagsHeight;
@property (nonatomic, strong) UIView *moreBtnBgView;

//
@property (retain, nonatomic)UIPanGestureRecognizer *panGesture;
@property (retain, nonatomic)UIView *overLay;
@property (assign, nonatomic)BOOL isHidden;

@end



@implementation SXMenuViewController

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers
{
    return [self initWithTitle:title andSubTitles:subTitles andControllers:controllers underTabbar:NO];
}

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers underTabbar:(BOOL)underTabbar
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        if (title) {self.title = title;}
        _underTabbar = underTabbar;
        _titleName = [NSMutableArray arrayWithArray:subTitles];
        _controllers = [NSMutableArray arrayWithArray:controllers];
        
    }
    
    return self;
}

- (void) viewWillDisappear:(BOOL)animated{
    if (floatView != nil && floatView.isHidden==NO) {
        [floatView hideView];
    }
    //视图将被从屏幕上移除之前执行  显示导航，方便后面界面显示。
    if (self.isHidden) {
        [self showViewNav];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor titleBarColor];
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64 - (_underTabbar ? 49 : 0))];
//    [self.view addSubview:bgView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat titleBarHeight = 40;
    _smallScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight)];
    [_smallScrollView setBackgroundColor:[UIColor titleBarColor]];
    [self.view addSubview:_smallScrollView];
    
    CGFloat height = self.view.bounds.size.height - titleBarHeight - 64 - (_underTabbar ? 49 : 0);
    _bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleBarHeight, self.view.bounds.size.width, height)];
    [self.view addSubview:_bigScrollView];
    
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.smallScrollView.scrollsToTop = NO;
    self.bigScrollView.scrollsToTop = NO;
    self.bigScrollView.delegate = self;
    
    //[self followRollingScrollView:bgView];
    
    [self loadControllerVC];
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.bigScrollView.bounds;
    [self.bigScrollView addSubview:vc.view];
//    SXTitleLable *lable = [self.smallScrollView.subviews firstObject];
//    lable.scale = 1.0;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    
    self.needScrollToTopPage = self.childViewControllers[0];
    
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    recognizerUp.delegate = self;  //增加 delegate  设置代理是为了开启手势的并发操作
    recognizerUp.numberOfTouchesRequired = 1;
    [recognizerUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.bigScrollView addGestureRecognizer:recognizerUp];
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    recognizerDown.delegate = self;
    recognizerDown.numberOfTouchesRequired = 1;
    [recognizerDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.bigScrollView addGestureRecognizer:recognizerDown];
    
    [self AD_UIConfigChange];
    
    //
    self.panGesture = [[UIPanGestureRecognizer alloc] init];
    self.panGesture.delegate=self;
    self.panGesture.minimumNumberOfTouches = 1;
    [self.panGesture addTarget:self action:@selector(handlePanGesture:)];
    [self.bigScrollView addGestureRecognizer:self.panGesture];
    
    self.overLay = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.overLay.alpha=0;
    self.overLay.backgroundColor= self.navigationController.navigationBar.barTintColor;
    [self.navigationController.navigationBar addSubview:self.overLay];
    [self.navigationController.navigationBar bringSubviewToFront:self.overLay];
}

- (void)AD_UIConfigChange{
    if ((((AppDelegate *)[UIApplication sharedApplication].delegate).floatAD == nil) || (((AppDelegate *)[UIApplication sharedApplication].delegate).floatAD.dataDict == nil)) {
        return;
    }
    
    NSString *urlStr = ((AppDelegate *)[UIApplication sharedApplication].delegate).floatAD.imgUrl;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    floatView = [floatADView createViewFromNib];
    [floatView.image_AD sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"item_default"]];
    
   CGFloat widthRatio = [((AppDelegate *)[UIApplication sharedApplication].delegate).floatAD.imgWRatio floatValue];
    CGSize imageSize = [Utils getImageSizeWithURL:url];
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if (width == 0 || height ==0) { //url存在问题  图片不存在的情况
        return;
    }
    
    CGFloat newWidth = kNBR_SCREEN_W*widthRatio;
    CGFloat newHeight = kNBR_SCREEN_W*widthRatio*height/width + 60;
    [floatView setFrame:CGRectMake((kNBR_SCREEN_W-newWidth)/2, (kNBR_SCREEN_H-newHeight)/2.0, newWidth, newHeight)];
    floatView.image_AD.userInteractionEnabled = YES;
    [floatView.image_AD addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(image_ADChick:)]];
    [floatView showInWindow];
    
//    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:floatView preferredStyle:TYAlertControllerStyleAlert];
//    alertController.backgoundTapDismissEnable = NO;
//    [self presentViewController:alertController animated:YES completion:nil];
}


-(void) image_ADChick:(id)sender{
    [floatView hideView];
    [Utils showLinkAD:((AppDelegate *)[UIApplication sharedApplication].delegate).floatAD WithNowVC:self];
}

- (void)showViewNav{
    [self.navigationController.navigationBar sendSubviewToBack:self.overLay];
    self.overLay.alpha=0;
    CGRect navBarFrame=NavBarFrame;
    CGRect scrollViewFrame=self.view.frame;
    
    navBarFrame.origin.y = 20;
    scrollViewFrame.origin.y = 0;//navBarFrame.origin.y + navBarFrame.size.height;
    scrollViewFrame.size.height -= navBarFrame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        NavBarFrame = navBarFrame;
        self.view.frame=scrollViewFrame;
    }];
    
    if ([self.parentViewController isKindOfClass:[JRSegmentViewController class]]){
        JRSegmentViewController *segmentVC =  (JRSegmentViewController *)self.parentViewController;
        [segmentVC reloadScrollView:64];
        [segmentVC.view sendSubviewToBack:self.overLay];
    }
    self.isHidden= NO;
}

- (void)hiddenViewNav{
    CGRect frame =NavBarFrame;
    CGRect scrollViewFrame=self.view.frame;
    frame.origin.y = -24;
    scrollViewFrame.origin.y = -44;//frame.origin.y + frame.size.height;
    scrollViewFrame.size.height += frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        NavBarFrame = frame;
        self.view.frame=scrollViewFrame;
    } completion:^(BOOL finished) {
        [self.navigationController.navigationBar bringSubviewToFront:self.overLay];
        self.overLay.alpha=1;
    }];
    
    if ([self.parentViewController isKindOfClass:[JRSegmentViewController class]]){
        JRSegmentViewController *segmentVC =  (JRSegmentViewController *)self.parentViewController;
        [segmentVC reloadScrollView:20];
        [segmentVC.view bringSubviewToFront:self.overLay];
    }
    
    self.isHidden=YES;
}

//-(void)viewDidAppear:(BOOL)animated{
//    [self.navigationController.navigationBar bringSubviewToFront:self.overLay];
//}


#pragma mark - 兼容其他手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - 手势调用函数
-(void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:[self.view superview]];
    //    NSLog(@"%f",translation.y);
    //    CGFloat detai = self.lastContentset - translation.y;
    //显示
    if (translation.y >= 5) {
        if (self.isHidden) {
            [self showViewNav];
            [UIView animateWithDuration:0.3 animations:^{
                [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, _tagsHeight)];

                CGFloat bigHeight = self.view.bounds.size.height - _tagsHeight - (_underTabbar ? 49 : 0);
                [self.bigScrollView setFrame:CGRectMake(0, _tagsHeight, self.view.bounds.size.width, bigHeight)];
            }];
        }
    }
    //隐藏
    if (translation.y <= -20) {
        if (!self.isHidden) {
            [self hiddenViewNav];
            [UIView animateWithDuration:0.3 animations:^{
                CGFloat height = 0;
                [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];

                CGFloat bigHeight = self.view.bounds.size.height - height - (_underTabbar ? 49 : 0);
                [self.bigScrollView setFrame:CGRectMake(0, height, self.view.bounds.size.width, bigHeight)];
            }];
        }
    }
    
    
    
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        
        //NSLog(@"swipe down");
        //显示
//        [UIView animateWithDuration:0.3 animations:^{
//                [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, _tagsHeight)];
//
//                CGFloat bigHeight = self.view.bounds.size.height - _tagsHeight - (_underTabbar ? 49 : 0);
//                [self.bigScrollView setFrame:CGRectMake(0, _tagsHeight, self.view.bounds.size.width, bigHeight)];
//        }];
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        
        //NSLog(@"swipe up");
        //隐藏
//        [UIView animateWithDuration:0.3 animations:^{
//            CGFloat height = 0;
//            [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//
//            CGFloat bigHeight = self.view.bounds.size.height - height - (_underTabbar ? 49 : 0);
//            [self.bigScrollView setFrame:CGRectMake(0, height, self.view.bounds.size.width, bigHeight)];
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadControllerVC{
    
    [self addController];
    [self addLable];
    
    CGFloat contentX = self.childViewControllers.count * [UIScreen mainScreen].bounds.size.width;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    CGFloat offsetX = 0;
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    [self.bigScrollView setContentOffset:offset animated:YES];
    [self setScrollToTopWithTableViewIndex:0];
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = CGRectMake(0, 0, self.bigScrollView.bounds.size.width, self.bigScrollView.bounds.size.height);
    [self.bigScrollView addSubview:vc.view];
//    SXTitleLable *lable = [self.smallScrollView.subviews firstObject];
//    lable.scale = 1.0;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    
    self.needScrollToTopPage = self.childViewControllers[0];
    
    
}


#pragma mark - ******************** 添加方法

/** 添加子控制器 */
- (void)addController
{
    for(UIViewController *subVC in [self childViewControllers]) {
        [subVC removeFromParentViewController];
    }
    //    for(UIViewController *subVC in [self.bigScrollView subviews]) {
    //        [subVC.view removeFromSuperview];
    //    }
    for (UIView * subview in [self.bigScrollView subviews]) {
        [subview removeFromSuperview];
    }
    for (UIViewController *controller in _controllers) {
        [self addChildViewController:controller];
    }
}

- (void) addMoreButton
{
    _moreBtnBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.smallScrollView.height - 20, self.view.bounds.size.width, 20)];
    [_moreBtnBgView setBackgroundColor:[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0]];
    
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 50)/2.0, 0, 50, 20)];
    [moreButton setImage:[UIImage imageNamed:@"home_btn_more_normal"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"home_btn_more_selected"] forState:UIControlStateSelected];
    [moreButton addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_moreBtnBgView addSubview:moreButton];
    [self.smallScrollView addSubview:_moreBtnBgView];
}

- (void) moreBtnClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        CGFloat height = [HXTagsView getHeightWithTags:self.tagsView.tags layout:self.tagsView.layout tagAttribute:self.tagsView.tagAttribute width:self.view.frame.size.width] + 10;
        _tagsHeight = height;
    } else {
        _tagsHeight = 98 + 10;
    }
    
    [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, _tagsHeight)];
    
    CGFloat bigHeight = self.view.bounds.size.height - _tagsHeight - (_underTabbar ? 49 : 0);
    [self.bigScrollView setFrame:CGRectMake(0, _tagsHeight, self.view.bounds.size.width, bigHeight)];
    
    [_moreBtnBgView setFrame:CGRectMake(0, self.smallScrollView.height - 20, self.view.bounds.size.width, 20)];
}

/** 添加标题栏 */
- (void)addLable
{
    _tagsView = [[HXTagsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    _tagsView.isMultiSelect = NO;
    SXMenuViewController __block *blockSelf = self;
    _tagsView.completion = ^(NSArray *selectTags,NSInteger currentIndex) {
        NSLog(@"selectTags:%@ currentIndex:%ld",selectTags, (long)currentIndex);
        
        CGFloat offsetX = currentIndex * self.bigScrollView.frame.size.width;
        
        CGFloat offsetY = blockSelf.bigScrollView.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        
        [blockSelf.bigScrollView setContentOffset:offset animated:YES];
        
        [blockSelf setScrollToTopWithTableViewIndex:currentIndex];
    };
    self.tagsView.tags = _titleName;
    
    
    _tagsView.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _tagsHeight = 94;
    CGFloat height = [HXTagsView getHeightWithTags:self.tagsView.tags layout:self.tagsView.layout tagAttribute:self.tagsView.tagAttribute width:self.view.frame.size.width];
    
    if (height>_tagsHeight) {
        _tagsHeight += 10;
        height += 10;
    }
    
    [_tagsView setFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [self.smallScrollView addSubview:_tagsView];
    
    [self.smallScrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, _tagsHeight)];
    
    CGFloat bigHeight = self.view.bounds.size.height - _tagsHeight - 64 - (_underTabbar ? 49 : 0);
    [self.bigScrollView setFrame:CGRectMake(0, _tagsHeight, self.view.bounds.size.width, bigHeight)];
    
    if (height>_tagsHeight) {
        [self addMoreButton];
    }
    
    [self.tagsView reloadData];
    
    [self.tagsView.selectedTags addObject:self.tagsView.tags[0]];
    //self.smallScrollView
//    for(SXTitleLable *subview in [self.smallScrollView subviews]) {
//        [subview removeFromSuperview];
//    }
//    for (int i = 0;i<_titleName.count; i++) {
//        CGFloat lblW = 70;
//        CGFloat lblH = 40;
//        CGFloat lblY = 0;
//        CGFloat lblX = i * lblW;
//        SXTitleLable *lbl1 = [[SXTitleLable alloc]init];
//        lbl1.text =_titleName[i];
//        lbl1.frame = CGRectMake(lblX, lblY, lblW, lblH);
//        lbl1.font = [UIFont fontWithName:@"HYQiHei" size:19];
//        [self.smallScrollView addSubview:lbl1];
//        lbl1.tag = i;
//        lbl1.userInteractionEnabled = YES;
//        
//        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
//    }
//    
//    self.smallScrollView.contentSize = CGSizeMake(70 * _titleName.count, 0);
    
}

/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
//    SXTitleLable *titlelable = (SXTitleLable *)recognizer.view;
//    
//    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
//    
//    CGFloat offsetY = self.bigScrollView.contentOffset.y;
//    CGPoint offset = CGPointMake(offsetX, offsetY);
//    
//    [self.bigScrollView setContentOffset:offset animated:YES];
//    
//    [self setScrollToTopWithTableViewIndex:titlelable.tag];
}

#pragma mark - ScrollToTop

- (void)setScrollToTopWithTableViewIndex:(NSInteger)index
{
    //self.needScrollToTopPage.tableView.scrollsToTop = NO;
    self.needScrollToTopPage = self.childViewControllers[index];
    //self.needScrollToTopPage.tableView.scrollsToTop = YES;
}

#pragma mark - ******************** scrollView代理方法

/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    [_tagsView.selectedTags removeAllObjects];
    [_tagsView.selectedTags addObject:self.tagsView.tags[index]];
    [_tagsView reloadData];
//    // 滚动标题栏
//    SXTitleLable *titleLable = (SXTitleLable *)self.smallScrollView.subviews[index];
//    
//    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
//    
//    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
//    if (offsetx < 0) {
//        offsetx = 0;
//    }else if (offsetx > offsetMax){
//        offsetx = offsetMax;
//    }
//    
//    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
//    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    GFKDObjsViewController *newsVc = self.childViewControllers[index];
//    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if (idx != index) {
//            SXTitleLable *temlabel = self.smallScrollView.subviews[idx];
//            temlabel.scale = 0.1;
//        }
//    }];
//    
    if (!newsVc.view.superview){
        newsVc.view.frame = scrollView.bounds;
        [self.bigScrollView addSubview:newsVc.view];
    }
    [self setScrollToTopWithTableViewIndex:index];
}

/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
//    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
//    NSUInteger leftIndex = (int)value;
//    NSUInteger rightIndex = leftIndex + 1;
//    CGFloat scaleRight = value - leftIndex;
//    CGFloat scaleLeft = 1 - scaleRight;
//    SXTitleLable *labelLeft = self.smallScrollView.subviews[leftIndex];
//    labelLeft.scale = scaleLeft;
//    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
//    if (rightIndex < self.smallScrollView.subviews.count) {
//        SXTitleLable *labelRight = self.smallScrollView.subviews[rightIndex];
//        labelRight.scale = scaleRight;
//    }
    
}

@end
