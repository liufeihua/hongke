//
//  Audio-visual Audio-visual Audio-visual Audio-visual Audio_VisualViewController.m
//  iosapp
//
//  Created by redmooc on 16/8/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "Audio_VisualViewController.h"

#import "RadioViewController.h"
#import "StyledPageControl.h"
#import "AudioViewController.h"
#import "NYSegmentedControl.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"

@interface Audio_VisualViewController ()<UIScrollViewDelegate>
{
    NYSegmentedControl *foursquareSegmentedControl;
}

@property (nonatomic,strong)   AudioViewController *videoTableView;
@property (nonatomic,strong)   RadioViewController *radioTableView;
@property (nonatomic,assign)   CGRect bounds;
@property (strong, nonatomic) StyledPageControl *pageControl;

@end

@implementation Audio_VisualViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    foursquareSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"视频", @"电台"]];
    foursquareSegmentedControl.titleTextColor = [UIColor whiteColor];
    foursquareSegmentedControl.selectedTitleTextColor = kNBR_ProjectColor;
    foursquareSegmentedControl.selectedTitleFont = [UIFont systemFontOfSize:13.0f];
    foursquareSegmentedControl.segmentIndicatorBackgroundColor = [UIColor whiteColor];
    foursquareSegmentedControl.backgroundColor = kNBR_ProjectColor;
    foursquareSegmentedControl.borderWidth = 0.0f;
    foursquareSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    foursquareSegmentedControl.segmentIndicatorInset = 1.0f;
    foursquareSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    [foursquareSegmentedControl addTarget:self action:@selector(segmentSelect:) forControlEvents:UIControlEventValueChanged];
    [foursquareSegmentedControl sizeToFit];
    self.navigationItem.titleView = foursquareSegmentedControl;
    
    [self.view addSubview:self.pageControl];
    [self performSelector:@selector(addSubViews) withObject:nil afterDelay:0.1];
  
}

- (void)addSubViews
{
    _bounds = self.view.bounds;
    _bounds.origin.y = 64;
    CGFloat tabbarHeight = 49;
    _bounds.size.height = _bounds.size.height - tabbarHeight - 64;
    
    _centerScrollView = [[UIScrollView alloc]initWithFrame:_bounds];
    _centerScrollView.showsHorizontalScrollIndicator = NO;
    _centerScrollView.contentSize = CGSizeMake(_bounds.size.width*2, _bounds.size.height);
    _centerScrollView.pagingEnabled = YES;
    _centerScrollView.delegate = self;
    [self.view addSubview:_centerScrollView];
    
    _bounds.origin.y = 0;
    _videoTableView =[[AudioViewController alloc] init];
    [_videoTableView.view setFrame:_bounds];
    [self addChildViewController:_videoTableView];
    [_centerScrollView addSubview:_videoTableView.view];
    
    _bounds.origin.x += self.view.bounds.size.width;
    _radioTableView =[[RadioViewController alloc] initWithFrameHeight:_bounds.size.height withNumber:@"audio"];
    [_radioTableView.view setFrame:_bounds];
    [self addChildViewController:_radioTableView];
    [_centerScrollView addSubview:_radioTableView.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [foursquareSegmentedControl setSelectedSegmentIndex:page animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    int page = _centerScrollView.contentOffset.x / _centerScrollView.bounds.size.width;
    _pageControl.currentPage = page;
    [foursquareSegmentedControl setSelectedSegmentIndex:page animated:YES];
}

-(void) segmentSelect:(id)sender
{
    int page = (int)foursquareSegmentedControl.selectedSegmentIndex;
    CGFloat width = _centerScrollView.bounds.size.width;
    [_centerScrollView setContentOffset:CGPointMake(width * page, 0) animated:YES];
}

@end
