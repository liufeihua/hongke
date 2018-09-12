//
//  SearchArticleViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/24.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "SearchArticleViewController.h"
#import "AppDelegate.h"
#import "GFKDNews.h"
#import "Config.h"
#import "NewsViewController.h"
#import "NewsImagesViewController.h"
#import "NewsDetailBarViewController.h"

#import "SearchArticleResultViewController.h"
#import "CYWebViewController.h"


@interface SearchArticleViewController ()<UISearchBarDelegate,SearchArticleResultViewControllerDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;


@end

@implementation SearchArticleViewController


- (instancetype)init
{
    self = [super init];

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [UISearchBar new];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入关键字";
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        _searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
        _searchBar.barTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    
    self.navigationItem.titleView = _searchBar;
    
}

-(void) pushViewController:(GFKDNews*)news{
        if ([news.isSpecial intValue] == 1) {
                NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[news.specialId intValue] isSpecial:1];
                specalViewController.title = news.specialName;
                [self.navigationController pushViewController:specalViewController animated:YES];
        }else{
            if (((NSNull *)news.detailUrl != [NSNull null]) && (![news.detailUrl isEqualToString:@""])) {
                NSString *newUrl = [Utils replaceWithUrl:news.detailUrl];
                CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
                webViewController.hidesBottomBarWhenPushed = YES;
                webViewController.navigationButtonsHidden = YES;
                webViewController.loadingBarTintColor = [UIColor redColor];
                [self.navigationController pushViewController:webViewController animated:YES];
                return;
            }
            if ([news.hasImages intValue] == 1) {
                NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
                vc.hidesBottomBarWhenPushed = YES;
                vc.newsID = [news.articleId intValue];
                [self.navigationController pushViewController:vc animated:YES];
                self.navigationController.navigationBarHidden = YES;
            }else if ([news.hasVideo intValue] == 1) {
                VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
                [self.navigationController pushViewController:newsDetailVC animated:YES];
                
            }else
            {
                NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
                [self.navigationController pushViewController:newsDetailVC animated:YES];
            }
        }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBar.text.length == 0) {return;}
    
    [searchBar resignFirstResponder];
    if (!_resultVC) {
        _resultVC = [[SearchArticleResultViewController alloc] initWithKeyWord:searchBar.text];
        _resultVC.view.frame = CGRectMake(0,64,kNBR_SCREEN_W,kNBR_SCREEN_H-64);
        _resultVC.delegate = self;
        [self.view addSubview:_resultVC.view];
    }else
    {
        _resultVC.keyword = searchBar.text;
        [_resultVC refresh];
    }
}



@end
