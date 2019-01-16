//
//  SXMainViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/30.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "SXMainViewController.h"
#import "GFKDObjsViewController.h"
#import "SXTitleLable.h"
#import "UIView+Frame.h"
#import "ColumnViewController.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "GFKDUserNode.h"
#import "NewsViewController.h"
#import "StudySchoolViewController.h"
#import "NewsBarViewcontroller.h"
#import "GFKDTopNodes.h"

@interface SXMainViewController ()<UIScrollViewDelegate,ColumnViewControllerDelegate>
{
    
    NSArray *columOptionalArray;
}


@property(nonatomic,assign,getter=isColumnShow)BOOL columnShow;

@property (nonatomic, strong) UIButton *addColumnBtn;

@property(nonatomic,strong)GFKDObjsViewController *needScrollToTopPage;

//@property (nonatomic, assign) NSArray *columSelectedArray;
//@property (nonatomic, assign) NSArray *columOptionalArray;

@end

@implementation SXMainViewController


- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers  andNodes:(NSArray *)nodes
{
    return [self initWithTitle:title andSubTitles:subTitles andControllers:controllers andNodes:nodes underTabbar:NO];
}

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers  andNodes:(NSArray *)nodes underTabbar:(BOOL)underTabbar
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        if (title) {self.title = title;}
        _underTabbar = underTabbar;
        _columSelectedArray = [NSMutableArray arrayWithArray:nodes];
        _titleName = [NSMutableArray arrayWithArray:subTitles];
        _controllers = [NSMutableArray arrayWithArray:controllers];
        
        NSDictionary *node_1 = @{@"cateName": @"推荐", @"isfixed":@(1)};
        [_columSelectedArray insertObject:node_1 atIndex:0];
    }
    
    return self;
}

#pragma mark - ***************  页面刷新
- (void) viewRefesh {
    [self loadControllerVC];
}


#pragma mark - ******************** 页面首次加载
- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor titleBarColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat titleBarHeight = 40;
    _smallScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 0, self.view.bounds.size.width - 60, titleBarHeight)];
//     _smallScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight)];
    [_smallScrollView setBackgroundColor:[UIColor titleBarColor]];
    [self.view addSubview:_smallScrollView];
    
    _addColumnBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, titleBarHeight)];
    [_addColumnBtn setBackgroundColor:[UIColor titleBarColor]];
    [_addColumnBtn setImage:[UIImage imageNamed:@"gfkd_logo"] forState:UIControlStateNormal];
    [_addColumnBtn addTarget:self action:@selector(showColumnClick) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_addColumnBtn];
    
    
    self.columnShow = NO;
    
    CGFloat height = self.view.bounds.size.height - titleBarHeight - 64 - (_underTabbar ? 49 : 0);
    _bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleBarHeight, self.view.bounds.size.width, height)];
    [self.view addSubview:_bigScrollView];
    
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.smallScrollView.scrollsToTop = NO;
    self.bigScrollView.scrollsToTop = NO;
    self.bigScrollView.delegate = self;
    
    [self loadControllerVC];
    
//    // 添加默认控制器
//    UIViewController *vc = [self.childViewControllers firstObject];
//    vc.view.frame = self.bigScrollView.bounds;
//    [self.bigScrollView addSubview:vc.view];
//    SXTitleLable *lable = [self.smallScrollView.subviews firstObject];
//    lable.scale = 1.0;
//    self.bigScrollView.showsHorizontalScrollIndicator = NO;
//    
//    self.needScrollToTopPage = self.childViewControllers[0];
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
    SXTitleLable *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
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

/** 添加标题栏 */
- (void)addLable
{
    //self.smallScrollView
    for(SXTitleLable *subview in [self.smallScrollView subviews]) {
        [subview removeFromSuperview];
    }
    for (int i = 0;i<_titleName.count; i++) {
        CGFloat lblW = 70;
        CGFloat lblH = 40;
        CGFloat lblY = 0;
        CGFloat lblX = i * lblW;
        SXTitleLable *lbl1 = [[SXTitleLable alloc]init];
        lbl1.text =_titleName[i];
        lbl1.frame = CGRectMake(lblX, lblY, lblW, lblH);
        lbl1.font = [UIFont fontWithName:@"HYQiHei" size:19];
        [self.smallScrollView addSubview:lbl1];
        lbl1.tag = i;
        lbl1.userInteractionEnabled = YES;
        
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
    }
   
    self.smallScrollView.contentSize = CGSizeMake(70 * _titleName.count, 0);
    
}

/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
    SXTitleLable *titlelable = (SXTitleLable *)recognizer.view;
    
    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
    
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    [self.bigScrollView setContentOffset:offset animated:YES];
    
    [self setScrollToTopWithTableViewIndex:titlelable.tag];
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
    
    // 滚动标题栏
    SXTitleLable *titleLable = (SXTitleLable *)self.smallScrollView.subviews[index];
    
    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
    
    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }
    
    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    GFKDObjsViewController *newsVc = self.childViewControllers[index];
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            SXTitleLable *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.1;
        }
    }];
    
    if (!newsVc.view.superview){
        newsVc.view.frame = scrollView.bounds;
        [self.bigScrollView addSubview:newsVc.view];
    }
    [self setScrollToTopWithTableViewIndex:index];
    
//    newsVc.view.frame = scrollView.bounds;
//    [self setScrollToTopWithTableViewIndex:index];
//    
//    if (newsVc.view.superview) return;
//    
//    newsVc.view.frame = scrollView.bounds;
//    [self.bigScrollView addSubview:newsVc.view];
//    [self setScrollToTopWithTableViewIndex:index];
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
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    SXTitleLable *labelLeft = self.smallScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.smallScrollView.subviews.count) {
        SXTitleLable *labelRight = self.smallScrollView.subviews[rightIndex];
        labelRight.scale = scaleRight;
    }
    
}


- (void)showColumnClick{
    [self getNotUserNodes];
}


//用户未订制的栏目
-(void) getNotUserNodes{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_MYNOTUSERNODES]
      parameters:@{@"token":[Config getToken],
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
            columOptionalArray = responseObject[@"result"];
            
            ColumnViewController *vc = [[ColumnViewController alloc] init];
             vc.delegate = self;
             vc.parentView = self;
            vc.title = @"栏目选择";
            vc.view.frame = self.view.bounds;
            vc.hidesBottomBarWhenPushed = YES;
            [vc.selectedArray addObjectsFromArray:_columSelectedArray];
            [vc.optionalArray addObjectsFromArray:columOptionalArray];
             
            [self presentViewController:vc animated:YES completion:nil];
            //[self.navigationController pushViewController:vc animated:YES];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，得到用户未订制栏目失败！";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}



- (void)updateNodes:(NSMutableArray *)selectColumns{
//    NSMutableArray *title = [[NSMutableArray alloc] init];
//    [title addObject:@"推荐"];
//    NSMutableArray *controllers = [[NSMutableArray alloc] init];
//    [controllers addObject:[[NewsViewController alloc]  initWithNewsListType:NewsListTypeHomeNews cateId:0  isSpecial:0]];//推荐controller
//     for (int i=1; i<selectColumns.count ; i++) {
//         GFKDUserNode *topNodes = [[GFKDUserNode alloc] initWithDict:selectColumns[i]];
//        [title addObject:topNodes.cateName];
//        [controllers addObject:[[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
//    }
    
    StudySchoolViewController *studyTJVC = [[StudySchoolViewController alloc] initWithNumber:@"tjjm" WithNav:YES];
    
    NSMutableArray *title = [[NSMutableArray alloc] init];
    [title addObject:@"推荐"];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    [controllers addObject:studyTJVC];
    
    for (int i=1; i<selectColumns.count ; i++) {
        GFKDUserNode *topNodes = [[GFKDUserNode alloc] initWithDict:selectColumns[i]];
        [title addObject:topNodes.cateName];
        if ([topNodes.terminated intValue] == 1){ //没有子栏目了
            [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
        }else{
            [controllers addObject: [[StudySchoolViewController alloc] initWithParentId:topNodes.cateId WithNav:YES]];
        }
    }
    

    _columSelectedArray = [NSMutableArray arrayWithArray:selectColumns];
    _titleName = [NSMutableArray arrayWithArray:title];
    _controllers = [NSMutableArray arrayWithArray:controllers];
    
    [self loadControllerVC];
}

@end
