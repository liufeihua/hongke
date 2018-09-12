//
//  CatagoryNewsViewController.m
//  iosapp
//
//  Created by redmooc on 16/11/9.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "CatagoryNewsViewController.h"
#import "PGCategoryView.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "GFKDTopNodes.h"
#import "NewsViewController.h"

@interface CatagoryNewsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_leftTable;
    NewsViewController *_rightTable;
    //UIView *_contentView;
    NSMutableArray *_dataArray;
    int _nowRow;
    
}
@property (strong, nonatomic) PGCategoryView *categoryView;

@end

@implementation CatagoryNewsViewController

- (instancetype)initWithNumber:(NSString *)number{
    self = [super init];
    if (self) {
        _number = number;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _dataArray = [[NSMutableArray alloc] init];
     _nowRow = 0;
//    _contentView = [[UIView alloc] init];
//    _contentView.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height);
//    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    _contentView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:_contentView];
    
    _rightTable = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[_number intValue] isSpecial:0 isShowDescendants:1];
    _rightTable.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
    [self addChildViewController:_rightTable];
    [self.view addSubview:_rightTable.view];
    
    _leftTable = [[UITableView alloc] init];
    _leftTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    _leftTable.dataSource = self;
    _leftTable.delegate = self;
    _leftTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _leftTable.showsVerticalScrollIndicator = NO;
    _leftTable.tableFooterView = [[UIView alloc] init];
    [self.view insertSubview:_leftTable belowSubview:_rightTable.view];
    
    //[_contentView addSubview:_rightTable.view];
    
    CGRect frame = _rightTable.view.frame;
    frame.origin.x = 0;
    frame.size.width = 30;
    _categoryView = [PGCategoryView categoryRightView:_rightTable.view];
    _categoryView.frame = frame;
    [self.view addSubview:_categoryView];
    
    [self loadData];
}

- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"parentId":_number}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [_dataArray removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [_dataArray addObject:nodes];
             }
             [_leftTable reloadData];
             
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

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = UIColorFromRGB(0x8E5F5F);//
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"全部";
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        GFKDTopNodes *nodes = _dataArray[indexPath.row-1];
        cell.textLabel.text = nodes.cateName;
    }
    return cell;
}

#pragma mark - tableView 代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _nowRow = (int)indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _leftTable) {
        [_categoryView show];
        __weak CatagoryNewsViewController *weakSelf = self;
        if (indexPath.row == 0) {
            _rightTable.generateURL = ^NSString * (NSUInteger page) {
                return [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@&showDescendants=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,[weakSelf.number intValue],(unsigned long)page,GFKDAPI_PAGESIZE,0,[Config getToken],1];
            };
        }else{
            GFKDTopNodes *nodes = _dataArray[indexPath.row-1];
            _rightTable.generateURL = ^NSString * (NSUInteger page) {
                return [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,[nodes.cateId intValue],(unsigned long)page,GFKDAPI_PAGESIZE,0,[Config getToken]];
            };
        }
        [_rightTable refresh];
        for (int i=0; i<_dataArray.count+1; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:index];
            if (i == _nowRow) {
                cell.textLabel.textColor = [UIColor redColor];
            }else{
                cell.textLabel.textColor = UIColorFromRGB(0x8E5F5F);
            }
            
        }
        
        
    }
}

@end
