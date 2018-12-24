//
//  GFKDObjsViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/3.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDObjsViewController.h"
#import "GFKDBaseObject.h"
#import "LastCell.h"

#import <MBProgressHUD.h>
#import "UIViewController+WHReturntop.h"

@interface GFKDObjsViewController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDate *lastRefreshTime;

@end

@implementation GFKDObjsViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _objects = [NSMutableArray new];
        _page = 1;
        _needRefreshAnimation = YES;
        _shouldFetchDataAfterLoaded = YES;
        _HttpType = objsHttpTypeGET;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    
    _lastCell = [[LastCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchMore)]];
    self.tableView.tableFooterView = _lastCell;
    
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.font = [UIFont boldSystemFontOfSize:14];
    _lastCell.textLabel.textColor = [UIColor colorWithHex:0x909090];
    
    
    /*** 自动刷新 ***/
    
    if (_needAutoRefresh) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _lastRefreshTime = [_userDefaults objectForKey:_kLastRefreshTime];
        
        if (!_lastRefreshTime) {
            _lastRefreshTime = [NSDate date];
            [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
        }
    }
    
    
    _manager = [AFHTTPRequestOperationManager OSCManager];
    
    if (!_shouldFetchDataAfterLoaded) {return;}
    if (_needRefreshAnimation) {
        [self.tableView.mj_header beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height)
                                animated:YES];
    }
    
    if (_needCache) {
        _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    [self fetchObjectsOnPage:0 refresh:YES];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_needAutoRefresh) {
        NSDate *currentTime = [NSDate date];
        if ([currentTime timeIntervalSinceDate:_lastRefreshTime] > _refreshInterval) {
            _lastRefreshTime = currentTime;
            
            [self refresh];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dawnAndNight" object:nil];
}



-(void)dawnAndNightMode:(NSNotification *)center
{
    _lastCell.textLabel.backgroundColor = [UIColor themeColor];
    _lastCell.textLabel.textColor = [UIColor titleColor];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.separatorColor = [UIColor separatorColor];
    
    return _objects.count;
}



#pragma mark - 刷新

- (void)refresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [self fetchObjectsOnPage:0 refresh:YES];
    });
    
    //刷新时，增加另外的网络请求功能
    if (self.anotherNetWorking) {
        self.anotherNetWorking();
    }
}




#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        [self fetchMore];
    }
}

- (void)fetchMore
{
    if (!_lastCell.shouldResponseToTouch) {return;}
    
    _lastCell.status = LastCellStatusLoading;
    _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [self fetchObjectsOnPage:++_page refresh:NO];
}


#pragma mark - 请求数据

- (void)fetchObjectsOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
    if (self.HttpType == objsHttpTypePOST) {
        [_manager POST:self.generateURL(page)
            parameters:self.generateParameters(page)
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                   NSString *errorMessage = responseObject[@"reason"];
                   if (errorCode == 1) {
                       NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                       [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                       return;
                   }
                   
                   _allCount = [responseObject[@"total_size"] intValue];
                   NSArray *objectsDICT = [self parseDICT:responseObject];
                   
                   if (refresh) {
                       _page = 1;
                       [_objects removeAllObjects];
//                       if (_didRefreshSucceed) {_didRefreshSucceed();}
                   }
                   
                   
                   for (NSDictionary *objectDict in objectsDICT) {
                       BOOL shouldBeAdded = YES;
                       id obj = [[_objClass alloc] initWithDict:objectDict];
                       
                       for (GFKDBaseObject *baseObj in _objects) {
                           if ([obj isEqual:baseObj]) {
                               shouldBeAdded = NO;
                               break;
                           }
                       }
                       if (shouldBeAdded) {
                           [_objects addObject:obj];
                       }
                   }
                   if (_didRefreshSucceed) {_didRefreshSucceed();}
                   
                   if (_needAutoRefresh) {
                       [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (self.tableWillReload) {self.tableWillReload(objectsDICT.count);}
                       else {
                           if (_page == 1 && objectsDICT.count == 0) {
                               _lastCell.status = LastCellStatusEmpty;
                           } else if (objectsDICT.count == 0 || (_page == 1 && objectsDICT.count < GFKD_PAGESIZE)) {
                               _lastCell.status = LastCellStatusFinished;
                           } else {
                               _lastCell.status = LastCellStatusMore;
                           }
                       }
                       
                       if (self.tableView.mj_header.isRefreshing) {
                           [self.tableView.mj_header endRefreshing];
                       }
                       
                       [self.tableView reloadData];
                   });
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   MBProgressHUD *HUD = [Utils createHUD];
                   HUD.mode = MBProgressHUDModeCustomView;
                   HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                   HUD.detailsLabelText = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                   
                   [HUD hide:YES afterDelay:1];
                   
                   _lastCell.status = LastCellStatusError;
                   if (self.tableView.mj_header.isRefreshing) {
                       [self.tableView.mj_header endRefreshing];
                   }
                   [self.tableView reloadData];
               }
         ];
    }else
    {
        [_manager GET:self.generateURL(page)
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                   NSString *errorMessage = responseObject[@"reason"];
                   if (errorCode == 1) {
                       NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                       [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                       return;
                   }
                   
                   _allCount = [responseObject[@"total_size"] intValue];
                   NSArray *objectsDICT = [self parseDICT:responseObject];
                   
                   if (refresh) {
                       _page = 1;
                       [_objects removeAllObjects];
//                       if (_didRefreshSucceed) {_didRefreshSucceed();}
                   }
                   
                   
                   for (NSDictionary *objectDict in objectsDICT) {
                       BOOL shouldBeAdded = YES;
                       id obj = [[_objClass alloc] initWithDict:objectDict];
                       
                       for (GFKDBaseObject *baseObj in _objects) {
                           if ([obj isEqual:baseObj]) {
                               shouldBeAdded = NO;
                               break;
                           }
                       }
                       if (shouldBeAdded) {
                           [_objects addObject:obj];
                       }
                   }
                   if (_didRefreshSucceed) {_didRefreshSucceed();}
                   
                   if (_needAutoRefresh) {
                       [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (self.tableWillReload) {self.tableWillReload(objectsDICT.count);}
                       else {
                           if (_page == 1 && objectsDICT.count == 0) {
                               _lastCell.status = LastCellStatusEmpty;
                           } else if (objectsDICT.count == 0 || (_page == 1 && objectsDICT.count < GFKD_PAGESIZE)) {
                               _lastCell.status = LastCellStatusFinished;
                           } else {
                               _lastCell.status = LastCellStatusMore;
                           }
                       }
                       
                       if (self.tableView.mj_header.isRefreshing) {
                           [self.tableView.mj_header endRefreshing];
                       }
                       
                       [self.tableView reloadData];
                   });
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   MBProgressHUD *HUD = [Utils createHUD];
                   HUD.mode = MBProgressHUDModeCustomView;
                   HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                   HUD.detailsLabelText = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                   
                   [HUD hide:YES afterDelay:1];
                   
                   _lastCell.status = LastCellStatusError;
                   if (self.tableView.mj_header.isRefreshing) {
                       [self.tableView.mj_header endRefreshing];
                   }
                   [self.tableView reloadData];
               }
         ];
    }
    
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    NSAssert(false, @"Over ride in subclasses");
    return nil;
}


@end
