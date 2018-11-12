//
//  AddPhotoViewController.m
//  iosapp
//
//  Created by redmooc on 2018/10/22.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "PlaceholderTextView.h"
#import "UIView+TopTag.h"
#import "HXPhotoPicker.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "CYWebViewController.h"
#import "TemplateChooseViewController.h"

static const CGFloat kPhotoViewMargin = 12.0;

@interface AddPhotoViewController ()<HXPhotoViewDelegate,UIImagePickerControllerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    PlaceholderTextView  *commentInpuTextView;
    NSMutableArray  *currentSelectImageViews;
    NSString *imgsToken;
}
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *bottomView;

@property (assign, nonatomic) BOOL needDeleteItem;

@property (assign, nonatomic) BOOL showHud;


@end

@implementation AddPhotoViewController

- (instancetype)initWithInfoType :(int) type{
    self = [super init];
    _infoType = type;
    if (self) {
        
    }
    return self;
}


- (UIButton *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomView setTitle:@"删除" forState:UIControlStateNormal];
        [_bottomView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomView setBackgroundColor:[UIColor redColor]];
        _bottomView.frame = CGRectMake(0, self.view.hx_h - 50, self.view.hx_w, 50);
        _bottomView.alpha = 0;
    }
    return _bottomView;
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        //_manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        _manager.configuration.navigationTitleColor = [UIColor whiteColor];
        //_manager.configuration.navigationTitleSynchColor = YES;
        _manager.configuration.openCamera = YES;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.maxNum = 9;
        _manager.configuration.videoMaxDuration = 500.f;
        _manager.configuration.saveSystemAblum = YES;
        //        _manager.configuration.reverseDate = YES;
        _manager.configuration.showDateSectionHeader = NO;
        _manager.configuration.selectTogether = NO;
        //        _manager.configuration.rowCount = 3;
        //        _manager.configuration.movableCropBox = YES;
        //        _manager.configuration.movableCropBoxEditSize = YES;
        //        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        __weak typeof(self) weakSelf = self;
        //        _manager.configuration.replaceCameraViewController = YES;
        _manager.configuration.albumShowMode = HXPhotoAlbumShowModePopup;
        
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = ( NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = ( NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == HXPhotoConfigurationCameraTypePhoto) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == HXPhotoConfigurationCameraTypeVideo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXPhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [HXPhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [HXPhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_infoType == 1) {
        self.title = @"发布随手拍";
    }else if (_infoType == 2){
        self.title = @"发布跳蚤市场";
    }else if(_infoType == 3){
        self.title = @"发布时光相册";
    }
    //
    currentSelectImageViews = [[NSMutableArray alloc] init];
    positionTitle = @"";
    //CLLocationManager;
    //[CLLocationManager alloc] init;
    //初始化BMKLocationService
    locService = [[BMKLocationService alloc] init];
    locService.delegate = self;
    locService.desiredAccuracy = kCLLocationAccuracyBest;
    
    geocodesearch = [[BMKGeoCodeSearch alloc] init];
    //编码服务的初始化(就是获取经纬度,或者获取地理位置服务)
    geocodesearch.delegate = self;//设置代理为self
    
    
    //启动LocationService
    [locService startUserLocationService];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    commentInpuTextView = [PlaceholderTextView new];
    [commentInpuTextView setFrame:CGRectMake(8, 64 + 8, kNBR_SCREEN_W - 16, 150)];
    commentInpuTextView.placeholder = @"说点什么吧...";
    [commentInpuTextView setCornerRadius:3.0];
    commentInpuTextView.font = [UIFont systemFontOfSize:17];
    commentInpuTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [commentInpuTextView becomeFirstResponder];
    [self.view addSubview:commentInpuTextView];
    
    CGFloat width = scrollView.frame.size.width;
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, 150 + kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    //    photoView.outerCamera = YES;
    photoView.previewStyle = HXPhotoViewPreViewShowStyleDark;

    photoView.previewShowDeleteButton = YES;
    //    photoView.hideDeleteButton = YES;
    photoView.showAddCell = YES;
    //    photoView.disableaInteractiveTransition = YES;
    [photoView.collectionView reloadData];
    photoView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:photoView];
    self.photoView = photoView;
    
    UIBarButtonItem *rightAddItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commentNewContent)];
    self.navigationItem.rightBarButtonItem = rightAddItem;
    
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [commentInpuTextView.rac_textSignal map:^(NSString *content) {
        return @(content.length > 0);
    }];
    
    [self.view addSubview:self.bottomView];
}

//提交
- (void) commentNewContent
{
    if (_infoType == 3) {
        [self requestUploadView];
    }else{
        [self requestAddTake];
    }
}

- (void) requestUploadView{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_UPLOADPREVIEW]
       parameters:@{@"token":[Config getToken],
                    }
       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           for (int i = 0; i < currentSelectImageViews.count; i++)
           {
               UIImage *image = (UIImage *)currentSelectImageViews[i];
               [formData appendPartWithFileData:[Utils compressImage:image] name:[NSString stringWithFormat:@"img%d", i+1] fileName:[NSString stringWithFormat:@"img%d.jpg", i+1] mimeType:@"image/jpeg"];
           }
        }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                  imgsToken = responseObject[@"result"][@"imgs"];
                  //进入模板选择列表
                  TemplateChooseViewController *templateVC  = [[TemplateChooseViewController alloc] init];
                  [self.navigationController pushViewController:templateVC animated:YES];
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

- (void) requestAddTake{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"正在发布";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_ADDREADILYTAKE]
       parameters:@{@"token":[Config getToken],
                    @"title":[Utils convertRichTextToRawText:commentInpuTextView],
                    @"longitude":@(longitude),
                    @"latitude":@(latitude),
                    @"address":positionTitle,
                    @"infoType":@(_infoType),
                    }
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    for (int i = 0; i < currentSelectImageViews.count; i++)
    {
        UIImage *image = (UIImage *)currentSelectImageViews[i];
        [formData appendPartWithFileData:[Utils compressImage:image] name:[NSString stringWithFormat:@"img%d", i+1] fileName:[NSString stringWithFormat:@"img%d.jpg", i+1] mimeType:@"image/jpeg"];
    }
} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
    if (errorCode == 1) {
        [HUD hide:YES];
        NSString *errorMessage = responseObject[@"reason"];
        NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
        [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
        
        return;
    }
    [locService stopUserLocationService];
    if (_infoType == 3) {
        //如果是时光相册
        NSInteger photoId = [responseObject[@"result"] integerValue];
        NSString *url = [NSString stringWithFormat:@"%@%@?token=%@&id=%ld",GFKDAPI_HTTPS_PREFIX, GFKDAPI_PHOTOVIEW,[Config getToken],photoId];
        CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.navigationButtonsHidden = YES;
        webViewController.loadingBarTintColor = [UIColor redColor];
        [self.navigationController pushViewController:webViewController animated:YES];
        
        //http://172.20.201.103:8080/app.center/m-photoView.htx?token=&id=
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(GiveisAdd:)]) {
            [self.delegate GiveisAdd:YES];
        }
    }
    [HUD hide:YES afterDelay:1];
    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    HUD.labelText = @"网络异常，发布随手拍失败";
    
    [HUD hide:YES afterDelay:1];
}];
}

- (void)dealloc {
    NSSLog(@"dealloc");
}

- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal
{
  
}

- (void)photoView:(HXPhotoView *)photoView imageChangeComplete:(NSArray<UIImage *> *)imageList {
    NSSLog(@"%@",imageList);
    currentSelectImageViews = [imageList mutableCopy];
}

- (void)photoView:(HXPhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl {
    NSSLog(@"%@",networkPhotoUrl);
}

- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    NSSLog(@"%@",NSStringFromCGRect(frame));
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame) + kPhotoViewMargin);
    
}

- (void)photoView:(HXPhotoView *)photoView currentDeleteModel:(HXPhotoModel *)model currentIndex:(NSInteger)index {
    NSSLog(@"%@ --> index - %ld",model,index);
}

- (BOOL)photoViewShouldDeleteCurrentMoveItem:(HXPhotoView *)photoView gestureRecognizer:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    return self.needDeleteItem;
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0.5;
    }];
    NSSLog(@"长按手势开始了 - %ld",indexPath.item);
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 1;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 0.5;
        }];
    }
    NSSLog(@"长按手势改变了 %@ - %ld",NSStringFromCGPoint(point), indexPath.item);
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        self.needDeleteItem = YES;
        [self.photoView deleteModelWithIndex:indexPath.item];
    }else {
        self.needDeleteItem = NO;
    }
    NSSLog(@"长按手势结束了 - %ld",indexPath.item);
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0;
    }];
}

@end
