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

#define kRectW_four_1Ratio1 (kWindowW - 50)/4
#define kRectH_four_1Ratio1 kRectW_four*1/1.0      //W:H=1:1

#define kRectH_one  75
#define kRectH_oneTitle  25

#define kRectH_oneStar  120

#define kRectH_image (kWindowW/2.0-10)*5/9.0 //W:H=9:5
//typeId
//0:两列样式(图片宽高比1:1)
//1:三列样式(图片宽高比4:3)
//2:四列样式(图片宽高比3:4)
//3:滑动样式(图片宽高比4:3)
//4:四列样式(图片宽高比1:1)
//5:左图右标题(图片宽高比4:3)
//6:左标题右作者(无图片)
//7:左图右简介-个人之星(图片宽高比3:4)
//8:左右左三图片(图片宽高比9:5)

@implementation NodeBaseCell
{
    NSMutableArray *dataArray_childNode;
}

- (void) setNode:(GFKDTopNodes *)node{
    _node = node;
    [self loadChildNodeList:node.cateId];
    
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
    _label_subTitle_1.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_1_label_sub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_1)];
    [_label_subTitle_1 addGestureRecognizer:singleTap_1_label_sub];
    _label_author_1.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_1_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_1)];
    [_label_author_1 addGestureRecognizer:singleTap_1_author];
    
    _image2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_image2 addGestureRecognizer:singleTap_2];
    _label2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_label2 addGestureRecognizer:singleTap_2_label];
    _label_subTitle_2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2_label_sub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_label_subTitle_2 addGestureRecognizer:singleTap_2_label_sub];
    _label_author_2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_2_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_2)];
    [_label_author_2 addGestureRecognizer:singleTap_2_author];
    
    _image3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_image3 addGestureRecognizer:singleTap_3];
    _label3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_label3 addGestureRecognizer:singleTap_3_label];
    _label_subTitle_3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3_label_sub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_label_subTitle_3 addGestureRecognizer:singleTap_3_label_sub];
    _label_author_3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_3_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_3)];
    [_label_author_3 addGestureRecognizer:singleTap_3_author];
    
    _image4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_4)];
    [_image4 addGestureRecognizer:singleTap_4];
    _label4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_4_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_4)];
    [_label4 addGestureRecognizer:singleTap_4_label];
    _label_author_4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_4_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_4)];
    [_label_author_4 addGestureRecognizer:singleTap_4_author];
    
    _label5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_5_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_5)];
    [_label5 addGestureRecognizer:singleTap_5_label];
    
    _label_author_5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_5_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_5)];
    [_label_author_5 addGestureRecognizer:singleTap_5_author];
}

- (void) loadVieDottedLine{
    [self addBorderToLayer:_view_dotted_1];
    [self addBorderToLayer:_view_dotted_2];
    [self addBorderToLayer:_view_dotted_3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForRow:(GFKDTopNodes *)node{
    if ([node.typeId isKindOfClass:[NSNull class]]){
        node.typeId = [NSNumber numberWithInt:0];
    }
    switch ([node.typeId intValue]) {
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
        case 4:
        {
            return kRectH_four_1Ratio1+10+20+10+10;
        }
            break;
        case 5:
        {
            return kRectH_one*3+6*10;
        }
            break;
        case 6:
        {
            return kRectH_oneTitle*5+6*10;
        }
            break;
        case 7:
        {
            return kRectH_oneStar + 20;
        }
            break;
        case 8:
        {
            return kRectH_image*3+15*2+6*2;
        }
            break;
            
        default:
        {
            return kRectH_three+10+40+10+10;;
        }
            break;
    }
}

+ (NSString *)idForRow:(GFKDTopNodes *)node{
    if ([node.typeId isKindOfClass:[NSNull class]]){
        node.typeId = [NSNumber numberWithInt:0];
    }
    switch ([node.typeId intValue]) {
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
        case 4:
        {
            return @"NodeFour_1ratio1Cell";
        }
            break;
        case 5:
        {
            return @"NodeOneCell";
        }
            break;
        case 6:
        {
            return @"NodeOneTitleCell";
        }
            break;
        case 7:
        {
            return @"NodeOneStar";
        }
            break;
        case 8:
        {
            return @"NodeImageCell";
        }
            break;
            
        default:
        {
            return @"NodeThreeCell";
        }
            break;
    }
}


- (void) loadChildNodeList:(NSNumber *)parentId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"parentId":parentId}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             [self loadVieDottedLine]; //画虚线
             
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
                 if (i == 5) {
//                     [self.image5 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label5.text = node.cateName;
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
        [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,cateId,@"pageSize=5",0,[Config getToken]]
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
                         if (news.images.count>0){
                              [self.image1 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                            [self.image1 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label1.text = news.title;
                         self.label_subTitle_1.text = news.dataDict[@"description"];
                         self.label_author_1.text = news.author;
                         self.label_job_1.text = news.subtitle;
                     }
                     if (i == 1) {
                         if (news.images.count>0){
                             [self.image2 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image2 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label2.text = news.title;
                         self.label_subTitle_2.text = news.dataDict[@"description"];
                         self.label_author_2.text = news.author;
                     }
                     if (i == 2) {
                         if (news.images.count>0){
                             [self.image3 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image3 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label3.text = news.title;
                         self.label_subTitle_3.text = news.dataDict[@"description"];
                         self.label_author_3.text = news.author;
                     }
                     if (i == 3) {
                         if (news.images.count>0){
                             [self.image4 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image4 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label4.text = news.title;
                       //   self.label_date_4.text = news.dates;
                         self.label_author_4.text = news.author;
                     }
                     if (i == 4) {
//                         [self.image5 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         self.label5.text = news.title;
                         //self.label_date_5.text = news.dates;
                         self.label_author_5.text = news.author;
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
- (void) Click_5{
    if (dataArray_childNode.count > 4){
        if ([dataArray_childNode[4] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[4];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[4] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[4];
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
            vc.parentVC = _parentVC;
            [_parentVC presentViewController:vc animated:YES completion:nil];
            
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

- (void)addBorderToLayer:(UIView *)view
{
    CAShapeLayer *border = [CAShapeLayer layer];
    
    border.strokeColor = kNBR_ProjectColor.CGColor;
    
    border.fillColor = nil;
    
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    border.frame = view.bounds;
    
    border.lineWidth = 2;
    
    border.lineCap = @"square";
    
    border.lineDashPattern = @[@2, @6];
    
    [view.layer addSublayer:border];
}

@end
