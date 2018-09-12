//
//  NewsSegmentedViewController.m
//  iosapp
//
//  Created by redmooc on 16/10/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "NewsSegmentedViewController.h"
#import "NYSegmentedControl.h"
#import "StyledPageControl.h"
#import "UIColor+Util.h"
#import "SXMainViewController.h"
#import "TakesTabViewController.h"
#import "STTabViewController.h"
#import "NewsViewController.h"
#import "GFKDTopNodes.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "SVSegmentedControl.h"
#import "JRSegmentViewController.h"


@interface NewsSegmentedViewController ()<UIScrollViewDelegate>
{
    SVSegmentedControl *newsSegmentedControl;
    SXMainViewController *newsMain;
    STTabViewController *STVC;
    TakesTabViewController *takesVC;
}

@property (nonatomic,assign)   CGRect bounds;
@property (strong, nonatomic)  StyledPageControl *pageControl;

@end

@implementation NewsSegmentedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    newsSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"红讯",@"视听", @"圈子"]];
//    newsSegmentedControl.titleTextColor = [UIColor whiteColor];
//    newsSegmentedControl.selectedTitleTextColor = [UIColor colorWithHex:0x861917];
//    newsSegmentedControl.selectedTitleFont = [UIFont systemFontOfSize:13.0f];
//    newsSegmentedControl.segmentIndicatorBackgroundColor = [UIColor whiteColor];
//    newsSegmentedControl.backgroundColor = [UIColor colorWithHex:0x861917];
//    newsSegmentedControl.borderWidth = 0.0f;
//    newsSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
//    newsSegmentedControl.segmentIndicatorInset = 1.0f;
//    newsSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
//    newsSegmentedControl.segmentIndicatorAnimationDuration = 0.3f;
//    [newsSegmentedControl addTarget:self action:@selector(segmentSelect:) forControlEvents:UIControlEventValueChanged];
//    [newsSegmentedControl sizeToFit];
//    self.navigationItem.titleView = newsSegmentedControl;
    
//    newsSegmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"红讯",@"视听", @"圈子", nil]];
//    [newsSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//    newsSegmentedControl.crossFadeLabelsOnDrag = YES;
//    newsSegmentedControl.font = [UIFont systemFontOfSize:13.0f];;
//    newsSegmentedControl.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
//    newsSegmentedControl.height = 30;
//    [newsSegmentedControl setSelectedSegmentIndex:2 animated:NO];
//    newsSegmentedControl.thumb.tintColor = [UIColor whiteColor];
//    newsSegmentedControl.thumb.textColor = [UIColor colorWithHex:0x861917];;
//    newsSegmentedControl.thumb.textShadowColor = [UIColor whiteColor];
//    newsSegmentedControl.thumb.textShadowOffset = CGSizeMake(0, 1);
//    self.navigationItem.titleView = newsSegmentedControl;
    
    [self loadTOPList];
    
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nodeDic"]!=nil){
//        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[user objectForKey:@"nodeDic"]];
//        [self showTopNodes:mutableArray];
//    }
    
//    [self.view addSubview:self.pageControl];
    //[self performSelector:@selector(addSubViews) withObject:nil afterDelay:0.1];
    
}

- (void) showTopNodes:(NSMutableArray *) array{
//    _bounds = self.view.bounds;
//    _bounds.origin.y = 64;
//    CGFloat tabbarHeight = 49;
//    _bounds.size.height = _bounds.size.height - tabbarHeight - 64;
//    
//    _centerScrollView = [[UIScrollView alloc]initWithFrame:_bounds];
//    _centerScrollView.showsHorizontalScrollIndicator = NO;
//    _centerScrollView.contentSize = CGSizeMake(_bounds.size.width*3, _bounds.size.height);
//    _centerScrollView.pagingEnabled = YES;
//    _centerScrollView.delegate = self;
//    [self.view addSubview:_centerScrollView];
//    
//    
//    
    NSMutableArray *title = [[NSMutableArray alloc] init];
    [title addObject:@"推荐"];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    [controllers addObject:[[NewsViewController alloc]  initWithNewsListType:NewsListTypeHomeNews cateId:0  isSpecial:0]];//推荐controller
    for (int i=0; i<array.count ; i++) {
        GFKDTopNodes *topNodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
        [title addObject:topNodes.cateName];
        [controllers addObject:[[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
    }
//
//    _bounds.origin.y = 0;
    newsMain = [[SXMainViewController alloc] initWithTitle:@"" andSubTitles:title andControllers:controllers andNodes:array underTabbar:YES];
//    [newsMain.view setFrame:_bounds];
//    [self addChildViewController:newsMain];
//    [_centerScrollView addSubview:newsMain.view];
//    
//    _bounds.origin.x += self.view.bounds.size.width;
    STVC =[[STTabViewController alloc] init];
//    [STVC.view setFrame:_bounds];
//    [self addChildViewController:STVC];
//    [_centerScrollView addSubview:STVC.view];
//    
//    _bounds.origin.x += self.view.bounds.size.width;
    takesVC =[[TakesTabViewController alloc] init];
//    [takesVC.view setFrame:_bounds];
//    [self addChildViewController:takesVC];
//    [_centerScrollView addSubview:takesVC.view];
    
    JRSegmentViewController *vc = [[JRSegmentViewController alloc] init];
   // [vc.view setFrame:CGRectMake(0, 0, _bounds.size.width, _bounds.size.height)];
    vc.segmentBgColor = [UIColor colorWithRed:18.0f/255 green:50.0f/255 blue:110.0f/255 alpha:1.0f];
    vc.indicatorViewColor = [UIColor whiteColor];
    vc.titleColor = [UIColor whiteColor];
    
    [vc setViewControllers:@[newsMain, STVC, takesVC]];
    [vc setTitles:@[@"红讯",@"视听", @"圈子"]];
   // [self.view addSubview:vc.view];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) loadTOPList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_MYALLNODES]
      parameters:@{@"token":[Config getToken]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"%@",responseObject);
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             
             NSArray * array = [NSArray arrayWithArray:responseObject[@"result"]];
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults setObject:array forKey:@"nodeDic"];
             
             [self showTopNodes:responseObject[@"result"]];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubViews
{
    
}


- (StyledPageControl*)pageControl
{
    if (_pageControl)
    {
        return _pageControl;
    }
    
    CGFloat originY = 64;
    CGRect pageFrame = CGRectMake(0, originY, self.view.bounds.size.width, 0.1);
    _pageControl = [[StyledPageControl alloc]initWithFrame:pageFrame];
    [_pageControl setFrame:pageFrame];
    _pageControl.backgroundColor = [UIColor clearColor];
    [_pageControl setNumberOfPages:2];
    [_pageControl setCurrentPage:0];
    [_pageControl setPageControlStyle:PageControlStyleThumb];
    //    [_pageControl setThumbImage:[UIImage imageNamed:@"sh_pageControl_normale"]];
    //    [_pageControl setSelectedThumbImage:[UIImage imageNamed:@"sh_pageControl_selected"]];
    [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    return _pageControl;
}

#pragma mark -
#pragma mark UIPageControl

- (void)changePage:(id)sender
{
    int page = _pageControl.currentPage;
    CGFloat width = _centerScrollView.bounds.size.width;
    [_centerScrollView setContentOffset:CGPointMake(width * page, 0) animated:YES];
    [newsSegmentedControl setSelectedSegmentIndex:page animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    int page = _centerScrollView.contentOffset.x / _centerScrollView.bounds.size.width;
    _pageControl.currentPage = page;
    [newsSegmentedControl setSelectedSegmentIndex:page animated:YES];
}

-(void) segmentSelect:(id)sender
{
    int page = (int)newsSegmentedControl.selectedSegmentIndex;
    CGFloat width = _centerScrollView.bounds.size.width;
    [_centerScrollView setContentOffset:CGPointMake(width * page, 0) animated:YES];
}

#pragma mark - UIControlEventValueChanged

- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
    NSLog(@"segmentedControl %i did select index %i (via UIControl method)", segmentedControl.tag, segmentedControl.selectedSegmentIndex);
    int page = (int)newsSegmentedControl.selectedSegmentIndex;
    CGFloat width = _centerScrollView.bounds.size.width;
    [_centerScrollView setContentOffset:CGPointMake(width * page, 0) animated:YES];
}

@end
