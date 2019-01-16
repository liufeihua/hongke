//
//  NewsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "GFKDNews.h"
#import "GFKDTopNodes.h"
#import "Config.h"
#import "NewsDetailBarViewController.h"
#import "HomeAdCell.h"
#import "NewsImagesViewController.h"
#import "VideoDetailViewController.h"
//#import "VideoDetailBarViewController.h"
#import "CommentsBottomBarViewController.h"
#import "PushNewsMsg.h"
#import "PushWebLinkMsg.h"
#import <MBProgressHUD.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "VideoDetailAuditBarViewController.h"
#import "NewsDetailAuditBarViewController.h"
#import "CYWebViewController.h"
//#import "ReaderViewController.h"

#import "LSYReadViewController.h"
#import "LSYReadPageViewController.h"
#import "LSYReadUtilites.h"
#import "LSYReadModel.h"

#import "EPUBParser.h"
#import "EPUBReadMainViewController.h"

#import "UITableView+Video.h"

#import "HRNavigationController.h"

#import "TracksViewModel.h"
#import "DTracks.h"

static NSString *kNewsCellID = @"NewsCell";

@interface NewsViewController ()<HomeAdCellDelegate,NewsDetailBarViewControllerDelegate,VideoDetailBarViewControllerDelegate,NewsDetailAuditBarViewControllerDelegate>
{
     NSIndexPath    *updateIndexPath;
     NSString       *startTime;
}
@property (nonatomic,assign) CGFloat lastOffsetY;
@end

@implementation NewsViewController

- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial isShowDescendants:(int)isShowDescendants
{
    _isShowDescendants = isShowDescendants;
    return [self initWithNewsListType:type cateId:cateId isSpecial:isSpecial];
}

- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial
{
    self = [super init];
    
    _cateId = cateId;
   // _isHasAdv = isHasAdv;
    _myNewsListType = type;
    
    if (self) {
        __weak NewsViewController *weakSelf = self;
        NSString *token = [Config getToken];
        self.generateURL = ^NSString * (NSUInteger page) {
            if (type == NewsListTypeHomeNews) {//推荐
                NSLog(@"推荐：%@", [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&attr=recommend",GFKDAPI_HTTPS_PREFIX,GFKDAPI_HOMENEWS_LIST,(unsigned long)page,GFKDAPI_PAGESIZE,token]);
                return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&attr=recommend",GFKDAPI_HTTPS_PREFIX,GFKDAPI_HOMENEWS_LIST,(unsigned long)page,GFKDAPI_PAGESIZE,token];
                
            }else if (type == NewsListTypeAuditInfo) {//待审稿件
//                NSLog([NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&type=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_AUDITINFO,(unsigned long)page,GFKDAPI_PAGESIZE,token,cateId]);
                return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&type=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_AUDITINFO,(unsigned long)page,GFKDAPI_PAGESIZE,token,cateId];
            }else if (type == NewsListTypeMsg) {//消息中心
                return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&nodeIds=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_MSG_PAGE,(unsigned long)page,GFKDAPI_PAGESIZE,token,weakSelf.cateId];
            }else if (type == NewsListTypeVideo) {//视频
                return [NSString stringWithFormat:@"%@/m-nodeByNumber.htx?pageNumber=%lu&%@&token=%@&number=video",GFKDAPI_HTTPS_PREFIX,(unsigned long)page,GFKDAPI_PAGESIZE,token];
            }else if (type == NewsListTypeRadio) {//电台
                return [NSString stringWithFormat:@"%@/m-nodeList.htx?pageNumber=%lu&%@&token=%@&number=audio",GFKDAPI_HTTPS_PREFIX,(unsigned long)page,GFKDAPI_PAGESIZE,token];
            }else{//其他
                NSLog(@"%@", [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,weakSelf.cateId,(unsigned long)page,GFKDAPI_PAGESIZE,isSpecial,token]);
                return [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@&showDescendants=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,weakSelf.cateId,(unsigned long)page,GFKDAPI_PAGESIZE,isSpecial,token,weakSelf.isShowDescendants];
            }
            
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
           // if (type >= 4) {weakSelf.lastCell.status = LastCellStatusFinished;}
           // else {
                responseObjectsCount < GFKD_PAGESIZE? (weakSelf.lastCell.status = LastCellStatusFinished) :
                (weakSelf.lastCell.status = LastCellStatusMore);//}
        };
//        if (type == NewsListTypeSpecial) {
//            self.objClass = [GFKDTopNodes class];
//        }else{
//            self.objClass = [GFKDNews class];
//        }
        self.objClass = [GFKDNews class];
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = [NSString stringWithFormat:@"NewsRefreshInterval-%d", type];
        
        self.didRefreshSucceed = ^{
            NSLog(@"count:%ld",weakSelf.objects.count);
            
            if (weakSelf.isHasPlay) {
                for (GFKDNews *obj in weakSelf.objects) {
                    obj.isPlaying = [NSNumber numberWithInt:0];
                }
                GFKDNews *news = weakSelf.objects[0];
                news.isPlaying = [NSNumber numberWithInt:1];
                
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"coverURL"] = news.image;
                userInfo[@"musicURL"] = [NSURL URLWithString:news.audio];
                
                NSInteger indexPathRow = 0;
                NSNumber *indexPathRown = [[NSNumber alloc]initWithInteger:indexPathRow];
                userInfo[@"indexPathRow"] = indexPathRown;
                
                DTracks *track = [[DTracks alloc] init];
                track.list = weakSelf.objects;
                track.pageSize = weakSelf.allCount;
                track.totalCount = weakSelf.objects.count;
                
                TracksViewModel *tracksVM = [[TracksViewModel alloc] initWithCateId:weakSelf.cateId WithCateName:weakSelf.title WithTrack:track];
                
                //专辑
                userInfo[@"theSong"] = tracksVM;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BeginPlay" object:nil userInfo:[userInfo copy]];
                return;
            }
            
            
        };
    }
    return self;
}


- (NSArray *)parseDICT:(NSDictionary *)dict
{
    [self setDict:dict];
    //NSArray *advArray = dict[@"result"][@"adv"];
    if ([dict[@"msg_code"] integerValue] == 0) {
        if (!_isHasAdv) {
            _AdvObjectsDict = dict[@"result"][@"adv"];
            _isHasAdv = _AdvObjectsDict.count ==0 ? FALSE:TRUE;
        }
        return dict[@"result"][@"data"];
    }
    return NULL;
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //前提条件
    _epubParser=[[EPUBParser alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isHasAdv?2:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            NSInteger rows = _isHasAdv?1:self.objects.count;
            return rows;
        }
            break;
            
        case 1:
        {
            return _isHasAdv?self.objects.count:0;
        }
            break;
            
        default:
        {
            return 0;
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((_isHasAdv && indexPath.section == 1) || (!_isHasAdv)) {
        GFKDNews *news = self.objects[indexPath.row];
        NSString *ID = [NewsCell idForRow:news];
        UINib *nib = [UINib nibWithNibName:ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ID ];
       // NewsCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
        NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        
        cell.NewsModel = news;
        cell.indexPathRow = (int)indexPath.row;
        cell.indexPathSection = (int)indexPath.section;
        if (_myNewsListType == NewsListTypeAuditInfo) {//待审稿件没有评论，不显示评论数
            [cell.lblReply setHidden:YES];
        }
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    }else{
        static NSString *CellIdentifier = @"homeAdCell";
        HomeAdCell *AdCell = (HomeAdCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        if(AdCell == nil)
        {
            AdCell = [[HomeAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        AdCell.delegate = self;
        
        if (self.dict != nil) {
            [AdCell getAds:_AdvObjectsDict];
        }
        
        
        return AdCell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_isHasAdv && indexPath.section == 1) || (!_isHasAdv)) {
        GFKDNews *news = self.objects[indexPath.row];
//        if ([news.cateId intValue]== 365) { //思想场  显示样式  showType = 5
//            news.showType = [NSNumber numberWithInt:5];
//        }
        return [NewsCell heightForRow:news];
    }else{
        return 9*kNBR_SCREEN_W/16;
        //return 160*KWidth_Scale;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    updateIndexPath = indexPath;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    startTime = dateTime;
    NSLog(@"beginTime=%@", startTime);
//    if(self.videoViewController!=nil)
//    {
//        [self.videoViewController removeView];
//        [self.videoViewController.view removeFromSuperview];
//        self.videoViewController=nil;
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GFKDNews *news = self.objects[indexPath.row];
    
    if (_isHasPlay) {
        for (GFKDNews *obj in self.objects) {
            obj.isPlaying = [NSNumber numberWithInt:0];
        }
        news.isPlaying = [NSNumber numberWithInt:1];
        [self.tableView reloadData];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"coverURL"] = news.image;
        userInfo[@"musicURL"] = [NSURL URLWithString:news.audio];
        
        NSInteger indexPathRow = indexPath.row;
        NSNumber *indexPathRown = [[NSNumber alloc]initWithInteger:indexPathRow];
        userInfo[@"indexPathRow"] = indexPathRown;
    
        DTracks *track = [[DTracks alloc] init];
        track.list = self.objects;
        track.pageSize = self.allCount;
        track.totalCount = self.objects.count;
        
        TracksViewModel *tracksVM = [[TracksViewModel alloc] initWithCateId:_cateId WithCateName:self.title WithTrack:track];
        
        //专辑
        userInfo[@"theSong"] = tracksVM;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BeginPlay" object:nil userInfo:[userInfo copy]];
        return;
    }
    
    if (([news.isSpecial intValue] == 1) && ([news.isToDetail intValue] != 1) && (_myNewsListType != NewsListTypeAuditInfo)) {

       NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[news.specialId intValue] isSpecial:1];
        specalViewController.hidesBottomBarWhenPushed = YES;
        specalViewController.title = news.specialName;
      [self.navigationController pushViewController:specalViewController animated:YES];
 
    }else{
        if (_myNewsListType == NewsListTypeAuditInfo) {
            NewsDetailAuditBarViewController *newsDetailVC = [[NewsDetailAuditBarViewController alloc] initWithNews:news WithType:_cateId];
            newsDetailVC.delegate = self;
            [self.navigationController pushViewController:newsDetailVC animated:YES];
            return;
        }
        
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
            vc.parentVC = self;
            [self presentViewController:vc animated:YES completion:nil];
        }else if ([news.hasVideo intValue] == 1 || [news.hasAudio intValue] == 1 ) {
            NSString *ID = [NewsCell idForRow:news];
            NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
            //[cell closeVedio];  //改成自动播放 用WMPlayer
            [self.tableView releaseWMPlayer];
            
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            newsDetailVC.delegate = self;
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }else if (((NSNull *)news.isReader != [NSNull null]) && ([news.isReader intValue]== 1)){
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* _filePath = [paths objectAtIndex:0];
            //File Url
            NSString* fileUrl = news.file;
            //Encode Url 如果Url 中含有空格，一定要先 Encode
            fileUrl = [fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //创建 Request
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
            NSString* fileName = [NSString stringWithFormat:@"sqmple.%@",news.readerSuffix];
            NSString* filePath = [_filePath stringByAppendingPathComponent:fileName];
            //下载进行中的事件
            AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = @"正在加载";
            [operation setCompletionBlock:^{
                [HUD hide:YES afterDelay:0];
                if ([news.readerSuffix isEqualToString:@"epub"]) {
                    NSMutableDictionary *fileInfo=[NSMutableDictionary dictionary];
                    [fileInfo setObject:filePath forKey:@"fileFullPath"];
                    
                    EPUBReadMainViewController *epubVC=[EPUBReadMainViewController new];
                    epubVC.epubParser=self.epubParser;
                    epubVC.fileInfo=fileInfo;
                    
                    epubVC.epubReadBackBlock=^(NSMutableDictionary *para1){
                        NSLog(@"回调=%@",para1);
                        [self dismissViewControllerAnimated:YES completion:nil];
                        return 1;
                    };
                    [self.navigationController presentViewController:epubVC animated:YES completion:nil];
                    
                }else if ([news.readerSuffix isEqualToString:@"txt"]){
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
                    LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
                    pageView.resourceURL = fileURL;  //文件位置
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        pageView.model = [LSYReadModel getLocalModelWithURL:fileURL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:pageView animated:YES completion:nil];
                        });
                    });
                }
                //NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"细说明朝"withExtension:@"epub"];
            }];
            
            [operation start];
            
        }else{
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            newsDetailVC.delegate = self;
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}

//- (void)removeController
//{
//    self.videoViewController=nil;
//    
//}

//NewsDetailBarViewControllerDelegate
- (void)GiveBrowersCount:(int)_BrowersCount
{
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:startTime];
    NSDate *date2 = [NSDate date];
    NSTimeInterval aTime = [date2 timeIntervalSinceDate:date1];
    int hour =(int)(aTime/3600);
    int minute = (int)(aTime-hour*3600)/60;
    float second =  aTime - hour*3600 - minute*60;
    NSLog(@"相隔：%f秒",second);
    if (second > 5.0) {//大于5秒 则保存积分
       GFKDNews *news = self.objects[updateIndexPath.row];
        [self addReadPoints:news.articleId];
    }
    
    if (updateIndexPath != nil) {//轮播图返回时不需要更新阅读数
        GFKDNews *news = self.objects[updateIndexPath.row];
        news.browsers = [NSNumber numberWithInt:[news.browsers intValue] + 1];
        NSArray *indexArray=[NSArray arrayWithObject:updateIndexPath];
        [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];   // 更新一行数据
    }
}

- (void) UpdateIndex{
    if (updateIndexPath != nil){
        //[self refresh];
        [self.objects removeObjectAtIndex:updateIndexPath.row];
        NSArray *indexArray=[NSArray arrayWithObject:updateIndexPath];
        [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        //待审稿件数目 －1
    }
}


- (void) fetchCommentsBVCController:(int) newsID
{
    //添加评论区
    CommentsBottomBarViewController  *commentsBVC = [[CommentsBottomBarViewController alloc]initWithCommentType:0 andObjectID:newsID];
    [self.navigationController pushViewController:commentsBVC animated:YES];
}


#pragma mark - delegate;
- (void)adClick:(GFKDHomeAd *)adv
{
    NSLog(@"homeAdv___click");
    updateIndexPath = nil;
//    adv.linkType = @"5";
//    adv.url = @"152";
    [Utils showLinkAD:adv WithNowVC:self];
}

/*
 * 阅读文章增加积分
 */
- (void) addReadPoints:(NSNumber *)articleId{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    NSDictionary *parameters = @{
                   @"articleId": @([articleId intValue]),  //评论或者文章的主键
                   @"token": [Config getToken],
                   };
    
    [manager GET:[NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_READPOINTS]
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}



//视频自动播放
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //如果是待审稿件，不自动播放
    if (_myNewsListType != NewsListTypeAuditInfo){
         [self.tableView handleScrollPlay];
    }
   

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_myNewsListType != NewsListTypeAuditInfo){
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat delaY = offsetY - self.lastOffsetY;
        self.tableView.scrollDirection = delaY > 0 ? LC_SCROLL_UP : LC_SCROLL_DOWN;
        if (delaY == 0) {
            self.tableView.scrollDirection = LC_SCROLL_NONE;
        }
        self.lastOffsetY = offsetY;
        //判断快速滑动期间是否移动到屏幕外
        [self.tableView handleScrollingCellOutScreen];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate]; //上拉加载更多
    if (_myNewsListType != NewsListTypeAuditInfo){
        [self.tableView handleScrollPlay];
    }
}


@end
