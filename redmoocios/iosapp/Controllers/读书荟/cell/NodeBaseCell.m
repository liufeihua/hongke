//
//  NodeBaseCell.m
//  iosapp
//
//  Created by redmooc on 2018/10/16.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "NodeBaseCell.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "GFKDNews.h"
#import "NewsViewController.h"
#import "CYWebViewController.h"
#import "NewsImagesViewController.h"
#import "EPUBReadMainViewController.h"
#import "NewsDetailBarViewController.h"
#import "LSYReadPageViewController.h"

#define kWindowH   [UIScreen mainScreen].bounds.size.height //应用程序的屏幕高度
#define kWindowW    [UIScreen mainScreen].bounds.size.width  //应用程序的屏幕宽度
#define kRectW_three (kWindowW - 40)/3
#define kRectH_three kRectW_three*3/4.0   //W:H=4:3

#define kRectW_four (kWindowW - 50)/4
#define kRectH_four kRectW_four*4/3.0      //W:H=3:4

#define kRectW_N kWindowW/2.0
#define kRectH_N kRectW_N*3/4.0      //W:H=4:3

@implementation NodeBaseCell
{
    NSMutableArray *dataArray_childNode;
}

- (void) setNode:(GFKDTopNodes *)node{
    _node = node;
    [self loadChildNodeList:node.number];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    dataArray_childNode = [[NSMutableArray alloc] init];
    //前提条件
    _epubParser=[[EPUBParser alloc] init];
   
    _image1.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_1)];
    [_image1 addGestureRecognizer:singleTap_1];
    _label1.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_1_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_1)];
    [_label1 addGestureRecognizer:singleTap_1_label];
    
    _image2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_image2 addGestureRecognizer:singleTap_2];
    _label2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_label2 addGestureRecognizer:singleTap_2_label];
    
    _image3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_image3 addGestureRecognizer:singleTap_3];
    _label3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_label3 addGestureRecognizer:singleTap_3_label];
    
    _image4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_4)];
    [_image4 addGestureRecognizer:singleTap_4];
    _label4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_4_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_4)];
    [_label4 addGestureRecognizer:singleTap_4_label];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForRow:(GFKDTopNodes *)node{
    switch ([node.showType intValue]) {
        case 0:
        {
            return 102;
        }
            break;
        case 1:
        {
            return kRectH_three+10+40+10+10;
        }
            break;
        case 2:
        {
            return kRectH_four+10+40+10+10;
        }
            break;
        case 3:
        {
            return kRectH_N+15+20+5+10;
        }
            break;
            
        default:
        {
            return 0;
        }
            break;
    }
}

+ (NSString *)idForRow:(GFKDTopNodes *)node{
    switch ([node.showType intValue]) {
        case 0:
        {
            return @"NodeTwoCell";
        }
            break;
        case 1:
        {
            return @"NodeThreeCell";
        }
            break;
        case 2:
        {
            return @"NodeFourCell";
        }
            break;
        case 3:
        {
            return @"NodeNCell";
        }
            break;
            
        default:
        {
            return @"";
        }
            break;
    }
}


- (void) loadChildNodeList:(NSString *)number
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":number}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             
             NSArray *array = responseObject[@"result"][@"data"];
             if (array.count == 0) {
                 [self loadArticleList:[_node.cateId intValue]];
             }
             [dataArray_childNode removeAllObjects];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *node = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [dataArray_childNode addObject:node];
                 
                 if (i == 0) {
                     [self.image1 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label1.text = node.cateName;
                 }
                 if (i == 1) {
                     [self.image2 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label2.text = node.cateName;
                 }
                 if (i == 2) {
                     [self.image3 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label3.text = node.cateName;
                 }
                 if (i == 3) {
                     [self.image4 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label4.text = node.cateName;
                 }
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

- (void) loadArticleList:(int)cateId{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,cateId,@"pageSize=4",0,[Config getToken]]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                 NSString *errorMessage = responseObject[@"reason"];
    
                 if (errorCode == 1) {
                     NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                     [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                     return;
    
                 }
                 NSArray *array = responseObject[@"result"][@"data"];
                 [dataArray_childNode removeAllObjects];
                 for (int i=0; i<array.count; i++) {
                     GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
                     [dataArray_childNode addObject:news];
                     
                     if (i == 0) {
                         [self.image1 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         self.label1.text = news.title;
                     }
                     if (i == 1) {
                         [self.image2 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         self.label2.text = news.title;
                     }
                     if (i == 2) {
                         [self.image3 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         self.label3.text = news.title;
                     }
                     if (i == 3) {
                         [self.image4 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         self.label4.text = news.title;
                     }
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

- (void) Click_1{
    if (dataArray_childNode.count > 0){
        if ([dataArray_childNode[0] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[0];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[0] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[0];
            [self pushArticleDetail:news];
        }
    }
}
- (void) Click_2{
    if (dataArray_childNode.count > 1){
        if ([dataArray_childNode[1] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[1];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[1] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[1];
            [self pushArticleDetail:news];
        }
    }
}
- (void) Click_3{
    if (dataArray_childNode.count > 2){
        if ([dataArray_childNode[2] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[2];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[2] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[2];
            [self pushArticleDetail:news];
        }
    }
}
- (void) Click_4{
    if (dataArray_childNode.count > 3){
        if ([dataArray_childNode[3] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[3];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[3] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[3];
            [self pushArticleDetail:news];
        }
    }
}

- (void) pushNodeDetail:(GFKDTopNodes *)node{
    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
    newsVC.hidesBottomBarWhenPushed = YES;
    newsVC.title = node.cateName;
    [_parentVC.navigationController pushViewController:newsVC animated:YES];
}

- (void) pushArticleDetail:(GFKDNews *)news{
    if (([news.isSpecial intValue] == 1) && ([news.isToDetail intValue] != 1)) {
        
        NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[news.specialId intValue] isSpecial:1];
        specalViewController.hidesBottomBarWhenPushed = YES;
        specalViewController.title = news.specialName;
        [_parentVC.navigationController pushViewController:specalViewController animated:YES];
        
    }else{
        if (((NSNull *)news.detailUrl != [NSNull null]) && (![news.detailUrl isEqualToString:@""])) {
            NSString *newUrl = [Utils replaceWithUrl:news.detailUrl];
            
            CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
            webViewController.hidesBottomBarWhenPushed = YES;
            webViewController.navigationButtonsHidden = YES;
            webViewController.loadingBarTintColor = [UIColor redColor];
            [_parentVC.navigationController pushViewController:webViewController animated:YES];
            return;
        }
        if ([news.hasImages intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.hidesBottomBarWhenPushed = YES;
            vc.newsID = [news.articleId intValue];
            [_parentVC.navigationController pushViewController:vc animated:YES];
            _parentVC.navigationController.navigationBarHidden = YES;
        }else if ([news.hasVideo intValue] == 1 || [news.hasAudio intValue] == 1 ) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            [_parentVC.navigationController pushViewController:newsDetailVC animated:YES];
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
                        [_parentVC dismissViewControllerAnimated:YES completion:nil];
                        return 1;
                    };
                    [_parentVC.navigationController presentViewController:epubVC animated:YES completion:nil];
                    
                }else if ([news.readerSuffix isEqualToString:@"txt"]){
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
                    LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
                    pageView.resourceURL = fileURL;  //文件位置
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        pageView.model = [LSYReadModel getLocalModelWithURL:fileURL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_parentVC presentViewController:pageView animated:YES completion:nil];
                        });
                    });
                }
            }];
            
            [operation start];
            
        }else{
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            [_parentVC.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}

@end
