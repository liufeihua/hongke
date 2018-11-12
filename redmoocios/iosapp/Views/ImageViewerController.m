//
//  ImageViewerController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//


// 参考 https://github.com/bogardon/GGFullscreenImageViewController

#import "ImageViewerController.h"
#import "Utils.h"

//#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "UIView+Frame.h"

@interface ImageViewerController () <UIScrollViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) BOOL zoomOut;

@property (nonatomic, strong) MBProgressHUD *HUD;


@property(nonatomic,strong) NSArray *photoSet;//多张图片
@property (nonatomic, assign) BOOL hasImageArray;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, strong) NSString *imageStr;
@property (nonatomic, assign) float lastScale;
@end

@implementation ImageViewerController

#pragma mark - init method

- (instancetype)initWithImageURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
         _hasImageArray = NO;
        _imageURL = imageURL;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
         _hasImageArray = NO;
        _image = image;
    }
    
    return self;
}

- (instancetype)initWithImageArray:(NSArray *)imageArray currentImage:(NSString *)imageStr
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _hasImageArray = YES;
        _photoSet = imageArray;
        _imageStr = imageStr;
        _currentIndex = 0;
    }
    
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 2;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    if (_hasImageArray==NO) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        
        if (_image) {
            _imageView.image = _image;
        } else {
//            if (![[SDWebImageManager sharedManager] cachedImageExistsForURL:_imageURL]) {
//                _HUD = [Utils createHUD];
//                _HUD.mode = MBProgressHUDModeAnnularDeterminate;
//                [_HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)]];
//            }
            [[SDWebImageManager sharedManager] cachedImageExistsForURL:_imageURL completion:^(BOOL isInCache) {
                if (!isInCache){
                    _HUD = [Utils createHUD];
                    _HUD.mode = MBProgressHUDModeAnnularDeterminate;
                    [_HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)]];
                }
            }];
            [_imageView sd_setImageWithURL:_imageURL
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload | SDWebImageContinueInBackground
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL * targetURL) {
                                      _HUD.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [_HUD hide:YES];
                                 }];
        }
        
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [_imageView addGestureRecognizer:singleTap];
        
        _scrollView.contentSize = _imageView.frame.size;
        [_scrollView addSubview:_imageView];
    }else
    {
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-50, 100, 20)];
        self.countLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_countLabel];
        [self setImageViewWithModel];
    }
    
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    backView.backgroundColor = [UIColor clearColor];
    backView.alpha = 0.8;
    [self.view addSubview:backView];
    
    _saveButton = [UIButton new];
    CGFloat X = self.view.frame.size.width;
    CGFloat Y = self.view.frame.size.height;
    _saveButton.frame = CGRectMake(X-60, Y-45, 30, 30);
    [_saveButton setImage:[UIImage imageNamed:@"picture_download"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(downloadPicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    
    _imageView.frame = _scrollView.bounds;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}



#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - handle gesture

- (void)handleSingleTap
{
    [_HUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    CGFloat power = _zoomOut ? 1/_scrollView.maximumZoomScale : _scrollView.maximumZoomScale;
    _zoomOut = !_zoomOut;
    
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = _scrollView.zoomScale * power;
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = _scrollView.center.y - (height / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
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

}

//下载保存图片
- (void)downloadPicture
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下载图片至手机相册" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (_hasImageArray) {
           
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }else{
           UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if (!error) {
        HUD.labelText = @"保存成功";
    } else {
        HUD.labelText = [NSString stringWithFormat:@"%@", [error description]];
    }
    
    [HUD hide:YES afterDelay:1];
}


/** 设置页面imgView */
- (void)setImageViewWithModel
{
    NSUInteger count = _photoSet.count;
    
    for (int i = 0; i < count; i++) {
        UIImageView *photoImgView = [[UIImageView alloc]init];
        photoImgView.height = self.scrollView.height;
        photoImgView.width = self.scrollView.width;
        photoImgView.y = -64;
        photoImgView.x = i * photoImgView.width;
        // 图片的显示格式为合适大小
        photoImgView.contentMode= UIViewContentModeScaleAspectFit;
        photoImgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [photoImgView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [photoImgView addGestureRecognizer:singleTap];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [pinchRecognizer setDelegate:self];
        [photoImgView addGestureRecognizer:pinchRecognizer];
        
        [self.scrollView addSubview:photoImgView];
        
        if ([_imageStr isEqualToString: _photoSet[i]]) {
            _currentIndex = i;
            self.imageView = photoImgView;
        }
    }
    
    // 因为scroll尼玛默认就有两个子控件好吧
    
    [self setImgWithIndex:_currentIndex];
    NSString *countNum = [NSString stringWithFormat:@"%d/%ld",_currentIndex+1,self.photoSet.count];
    self.countLabel.text = countNum;
    
    
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * count, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * _currentIndex, 0) animated:YES];
}

/** 懒加载添加图片！这里才是设置图片 */
- (void)setImgWithIndex:(int)i
{
    // 这里不要问我为什么这么写因为尼玛就是有bug
    UIImageView *photoImgView = nil;
//    if (i == 0) {
//        photoImgView = self.scrollView.subviews[i+2];
//    }else{
//        photoImgView = self.scrollView.subviews[i];
//    }
   photoImgView = self.scrollView.subviews[i];
    NSURL *purl = [NSURL URLWithString:_photoSet[i]];
    
    // 如果这个相框里还没有照片才添加
    if (photoImgView.image == nil) {
        [photoImgView sd_setImageWithURL:purl placeholderImage:[UIImage imageNamed:@"item_default"]];
    }
    
}

/** 滚动完毕时调用 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = self.scrollView.contentOffset.x / self.scrollView.width;
    // 添加图片
    [self setImgWithIndex:index];
    
    // 添加文字
    NSString *countNum = [NSString stringWithFormat:@"%d/%ld",index+1,self.photoSet.count];
    self.countLabel.text = countNum;
    
   self.imageView = (UIImageView *)scrollView.subviews[index];
    
}

@end
