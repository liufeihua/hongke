//
//  NewsImagesViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/19.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "NewsImagesViewController.h"

#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "UIImageView+WebCache.h"

#import <MBProgressHUD.h>
#import "GFKDNewsDetail.h"
#import "GFKDImages.h"
#import "UIView+Frame.h"
#import "CommentsBottomBarViewController.h"
#import "UMSocial.h"
#import <Masonry/Masonry.h>

@interface NewsImagesViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentText;

@property (weak, nonatomic) IBOutlet UITextView *headerText;

- (IBAction)backBtnClick:(id)sender;
@property (nonatomic, strong) UIImageView *currentImageView;

@property (nonatomic, strong) GFKDNewsDetail *newsDetailObj;

//@property (nonatomic, assign) float lastScale;
@property (nonatomic, assign) BOOL zoomOut;

@end

@implementation NewsImagesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 0.0;
    _zoomOut = false;
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowColor];
    self.navigationItem.title = @"图集详情";
    
    UIImage *buttonImage = [UIImage imageNamed:@"contentview_commentbacky"];
    buttonImage = [buttonImage stretchableImageWithLeftCapWidth:floorf(buttonImage.size.width/2) topCapHeight:floorf(buttonImage.size.height/2)];
    
    [self.replyBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?articleId=%d&token=%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_DETAIL,_newsID,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             //NSLog(@"%@",responseObject[@"result"]);
             self.newsDetailObj = [[GFKDNewsDetail alloc] initWithDict:responseObject[@"result"]];
             self.photoSet = self.newsDetailObj.images;
             [self setLabelWithModel:self.newsDetailObj];
             [self setImageViewWithModel];
             
             CGFloat count =  [self.newsDetailObj.comments intValue];
             NSString *displayCount;
             if (count > 10000) {
                 displayCount = [NSString stringWithFormat:@"%.1f万条评论",count/10000];
             }else{
                 displayCount = [NSString stringWithFormat:@"%.0f条评论",count];
             }
             [self.replyBtn setTitle:displayCount forState:UIControlStateNormal];
             
             if ([_newsDetailObj.collected intValue] == 1) {
                 [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
             } else {
                 [_btn_star setImage:[UIImage imageNamed:@"write-star"] forState:UIControlStateNormal];
             }
             
             
             if ([_newsDetailObj.digged intValue] == 1) {
                 [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan-selected"] forState:UIControlStateNormal];
             } else {
                 [_btn_zan setImage:[UIImage imageNamed:@"write-zan"] forState:UIControlStateNormal];
             }
             
             _label_zanNum.text = [_newsDetailObj.diggs intValue]>0?[_newsDetailObj.diggs stringValue ]:@"";
             _label_zanNum.hidden = [_newsDetailObj.diggs intValue]>0?NO:YES;
             
             
             if ([_newsDetailObj.infoLevel intValue] == 3){
                 [_btn_share setHidden:NO];
             }else{
                 [_btn_share mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.width.equalTo(@0);
                 }];
                 [_btn_share setHidden:YES];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.tabBarController.tabBar.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 设置页面文字 */
- (void)setLabelWithModel:(GFKDNewsDetail *)news
{
    self.titleLabel.text = news.title;
    if (((NSNull *)news.header != [NSNull null]) && news.header != nil) {
        self.headerText.text = news.header;
    }
   // self.headerText.text = @"作者：小  一审：刘  \n二审：空";
    // 设置新闻内容
    [self setContentWithIndex:0];
    
    NSString *countNum = [NSString stringWithFormat:@"1/%ld",_photoSet.count];
    self.countLabel.text = countNum;
    
    
}

/** 设置页面imgView */
- (void)setImageViewWithModel
{
    NSUInteger count = _photoSet.count;
    
    for (int i = 0; i < count; i++) {
        UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(self.photoScrollView.width*i, 0, self.photoScrollView.width, self.photoScrollView.height)];
        s.backgroundColor = [UIColor clearColor];
        s.contentSize = CGSizeMake(self.photoScrollView.width, self.photoScrollView.height);
        s.delegate = self;
        s.minimumZoomScale = 1.0;
        s.maximumZoomScale = 3.0;
        [s setZoomScale:1.0];
        
        UIImageView *imageView = [[UIImageView alloc]init];
                imageView.height = self.photoScrollView.height;
                imageView.width = self.photoScrollView.width;
                imageView.y = 0;
                imageView.x = 0;
        
        // 图片的显示格式为合适大小
        imageView.contentMode= UIViewContentModeCenter;
        imageView.contentMode= UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [imageView addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *subImageViewLongPressGesture  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(subSelectImageViewLongPressAction:)];
        subImageViewLongPressGesture.minimumPressDuration = 0.8;
        [imageView addGestureRecognizer:subImageViewLongPressGesture];
        
        
        [s addSubview:imageView];
        [self.photoScrollView addSubview:s];
        
    }
    
    // 因为scroll尼玛默认就有两个子控件好吧
   // [self setImgWithIndex:0];
    
    
    //设置实现缩放
    //设置代理scrollview的代理对象
    self.photoScrollView.delegate=self;
    //设置最大伸缩比例
    self.photoScrollView.maximumZoomScale=2.0;
    //设置最小伸缩比例
    self.photoScrollView.minimumZoomScale=0.5;
    self.photoScrollView.contentOffset = CGPointZero;
    self.photoScrollView.contentSize = CGSizeMake(self.photoScrollView.width * count, 0);
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
    self.photoScrollView.showsVerticalScrollIndicator = NO;
    self.photoScrollView.scrollEnabled = YES;
    self.photoScrollView.pagingEnabled = YES;
    
    [self setImgWithIndex:0];
}

/** 添加内容 */
- (void)setContentWithIndex:(int)index
{
    GFKDImages *imageObj  = [[GFKDImages alloc] initWithDict :_photoSet[index]];
    
    self.contentText.text = [NSString stringWithFormat:@"%d/%ld %@",index+1,self.photoSet.count,(NSNull *)imageObj.text  == [NSNull null] ?@"":imageObj.text];
    
    //self.contentText.text = (NSNull *)imageObj.text  == [NSNull null] ?@"":imageObj.text;
}

/** 懒加载添加图片！这里才是设置图片 */
- (void)setImgWithIndex:(int)i
{
    _currentImageView = self.photoScrollView.subviews[i].subviews[0];
//    UIImageView *photoImgView = nil;
//    photoImgView = self.photoScrollView.subviews[i].subviews[0];
    
    GFKDImages *imageObj  = [[GFKDImages alloc] initWithDict :_photoSet[i]];
    NSURL *purl = [NSURL URLWithString:imageObj.image];
    
    // 如果这个相框里还没有照片才添加
    if (_currentImageView.image == nil) {
        [_currentImageView sd_setImageWithURL:purl placeholderImage:[UIImage imageNamed:@"item_default"]];
    }
}

/** 滚动完毕时调用 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = self.photoScrollView.contentOffset.x / self.photoScrollView.width;
    // 添加图片
    [self setImgWithIndex:index];
    
    // 添加文字
    NSString *countNum = [NSString stringWithFormat:@"%d/%ld",index+1,self.photoSet.count];
    self.countLabel.text = countNum;
    
    // 添加内容
    [self setContentWithIndex:index];
    
    if (scrollView == self.photoScrollView){
        CGFloat x = scrollView.contentOffset.x;
        if (x==offset){
            
        }
        else {
            offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0];
                }
            }
        }
    }
    
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (IBAction)replyBtnAction:(id)sender {
    CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:0 andObjectID:self.newsID];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:commentsBVC animated:YES];
    
}

- (IBAction)btnZanClick:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [_newsDetailObj.digged intValue] == 1? GFKDAPI_ARTICLE_REDIGG: GFKDAPI_ARTICLE_DIGG;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId": @(self.newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             
             if (errorCode == 0) {
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                 HUD.labelText = [_newsDetailObj.digged intValue] == 1? @"取消点赞成功": @"添加点赞成功";
                 if ([_newsDetailObj.digged intValue] == 1) {
                     if ([_newsDetailObj.diggs intValue]==0) {
                         _newsDetailObj.diggs = [NSNumber numberWithInt: 0];
                         _label_zanNum.text = @"";
                         _label_zanNum.hidden = YES;
                     }else{
                         _newsDetailObj.diggs = [NSNumber numberWithInt:[_newsDetailObj.diggs intValue] - 1];
                         _label_zanNum.text = [_newsDetailObj.diggs stringValue];
                         _label_zanNum.hidden = NO;
                     }
                     _newsDetailObj.digged = [NSNumber numberWithInt: 0];
                     
                     [_btn_zan setImage:[UIImage imageNamed:@"write-zan"] forState:UIControlStateNormal];
                 }else
                 {
                     _newsDetailObj.digged = [NSNumber numberWithInt: 1];
                     [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan-selected"] forState:UIControlStateNormal];
                     
                     if ([_newsDetailObj.diggs intValue]==0) {
                         _newsDetailObj.diggs = [NSNumber numberWithInt: 1];
                         _label_zanNum.text = [_newsDetailObj.diggs stringValue];
                         _label_zanNum.hidden = NO;
                     }else{
                          _newsDetailObj.diggs = [NSNumber numberWithInt:[_newsDetailObj.diggs intValue] + 1];
                         _label_zanNum.text = [_newsDetailObj.diggs stringValue];
                         _label_zanNum.hidden = NO;
                     }
                 }
                 [HUD hide:YES afterDelay:1];
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
    
}

- (IBAction)btnStarClick:(id)sender {
    if ([_newsDetailObj.collected intValue] == 1) {
        [_btn_star setImage:[UIImage imageNamed:@"write-star"] forState:UIControlStateNormal];
    } else {
        [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [_newsDetailObj.collected intValue] == 1? GFKDAPI_ARTICLE_RECOLLECT: GFKDAPI_ARTICLE_COLLECT;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId": @(self.newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 0) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                 HUD.labelText = [_newsDetailObj.collected intValue] == 1? @"取消收藏成功": @"添加收藏成功";
                 if ([_newsDetailObj.collected intValue] == 1) {
                     _newsDetailObj.collected = [NSNumber numberWithInt: 0];
                     [_btn_star setImage:[UIImage imageNamed:@"write-star"] forState:UIControlStateNormal];
                 }else
                 {
                     _newsDetailObj.collected = [NSNumber numberWithInt: 1];
                     [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
                 }
                  [HUD hide:YES afterDelay:1];
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
            
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}

- (IBAction)btnShareClick:(id)sender {
    NSString *title = _newsDetailObj.title;
    NSString *URL;
    if ((NSNull *)_newsDetailObj.shareUrl != [NSNull null]) {
        URL = _newsDetailObj.shareUrl == nil?@"":_newsDetailObj.shareUrl;
    }else{
        URL = @"https://mapi.nudt.edu.cn";
    }
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = URL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = URL;
    [UMSocialData defaultData].extConfig.title = title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = title;
    [UMSocialData defaultData].extConfig.qqData.url = URL;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:URL];
    NSData * imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:_newsDetailObj.image]];
    // 复制链接
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5698bd72e0f55a6d460029b8"
                                      shareText: [NSString stringWithFormat:@"《%@》，分享来自 %@", title, URL]
                                     shareImage: [UIImage imageWithData:imageData]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}


#pragma mark - ScrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in scrollView.subviews){
        return v;
    }
    return nil;
}


#pragma mark -
-(void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    
    CGFloat newScale = _zoomOut ? [(UIScrollView*)gesture.view.superview zoomScale] * 1.5 :[(UIScrollView*)gesture.view.superview zoomScale] / 1.5;
    _zoomOut = !_zoomOut;
    //float newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale  inView:(UIScrollView*)gesture.view.superview withCenter:[gesture locationInView:gesture.view]];
    [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
}

- (void) subSelectImageViewLongPressAction : (UILongPressGestureRecognizer*) _gesture
{
    if (_gesture.state == UIGestureRecognizerStateBegan) // Handle the press
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看大图",@"保存图片", nil];
        
        actionSheet.tag = 0xAAAAAA;
        [actionSheet showInView:self.view];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0xAAAAAA)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                //查看大图
                UIImageView *currentImageView = _currentImageView;
                NSString *currentUrlStr = [_currentImageView.sd_imageURL absoluteString];
                
                [currentImageView sd_setImageWithURL:[NSURL URLWithString:[Utils getMaxImageNameWithName:currentUrlStr]] placeholderImage:[UIImage imageNamed:@"item_default"]];
            }
                break;
                
            case 1:
            {
                //保存图片
                UIImageView *currentImageView = _currentImageView;
                UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
                break;
                
            default:
                break;
        }
        return;
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if (!error) {
        HUD.labelText = @"保存图片成功";
    } else {
        HUD.labelText = [NSString stringWithFormat:@"%@", [error description]];
    }
    
    [HUD hide:YES afterDelay:1];
}


#pragma mark - Utility methods

- (CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

/*
- (void)handleSingleTap
{
   // [_HUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    CGFloat power = _zoomOut ? 1/_photoScrollView.maximumZoomScale : _photoScrollView.maximumZoomScale;
    _zoomOut = !_zoomOut;
    
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = _photoScrollView.zoomScale * power;
    
    CGSize scrollViewSize = _photoScrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = _photoScrollView.center.y - (height / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [_photoScrollView zoomToRect:rectToZoomTo animated:YES];
}

// 缩放
-(void)scale:(id)sender {
    [self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
    //当手指离开屏幕时,将lastscale设置为1.0
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [[(UIPinchGestureRecognizer*)sender view]setTransform:newTransform];
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
    
}*/

@end
