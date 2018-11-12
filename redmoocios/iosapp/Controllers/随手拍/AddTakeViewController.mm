//
//  AddTakeViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AddTakeViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "PlaceholderTextView.h"
#import "UIView+TopTag.h"
#import "JKImagePickerController.h"
#import "XHImageViewer.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>


const CGFloat   CommitImageViewHeightAndWidth = 62.8;
const NSInteger CommitImageViewWidthCount     = 5;

@interface AddTakeViewController ()<UITableViewDelegate,UITableViewDataSource,JKImagePickerControllerDelegate,XHImageViewerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    UITableView *boundTableView;
    PlaceholderTextView  *commentInpuTextView;
    UIView          *selectImgView;
    NSMutableArray  *selectImgDatas;
    NSMutableArray  *currentSelectImageViews;
    UIView          *addImageButton;
}
@end

@implementation AddTakeViewController


- (instancetype)initWithInfoType :(int) type{
    self = [super init];
    _infoType = type;
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_infoType == 1) {
        self.title = @"发布随手拍";
    }else if (_infoType == 2){
        self.title = @"发布跳蚤市场";
    }
    //
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
    
    commentInpuTextView = [PlaceholderTextView new];
    [commentInpuTextView setFrame:CGRectMake(8, 8, kNBR_SCREEN_W - 16, 150)];
    commentInpuTextView.placeholder = @"说点什么吧...";
    [commentInpuTextView setCornerRadius:3.0];
    commentInpuTextView.font = [UIFont systemFontOfSize:17];
    commentInpuTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [commentInpuTextView becomeFirstResponder];
    
    
    
    boundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
    boundTableView.delegate = self;
    boundTableView.dataSource = self;
    [self.view addSubview:boundTableView];
    
    [self drawSendImageUIWithAnimation:UITableViewRowAnimationAutomatic];
    
    UIBarButtonItem *rightAddItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commentNewContent)];
    self.navigationItem.rightBarButtonItem = rightAddItem;
    
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [commentInpuTextView.rac_textSignal map:^(NSString *content) {
        return @(content.length > 0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//提交
- (void) commentNewContent
{
    [self requestAddTake];
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
               UIImageView *imageView = (UIImageView *)currentSelectImageViews[i];
               [formData appendPartWithFileData:[Utils compressImage:imageView.image] name:[NSString stringWithFormat:@"img%d", i+1] fileName:[NSString stringWithFormat:@"img%d.jpg", i+1] mimeType:@"image/jpeg"];
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
            //进入模板选择
            
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

#pragma tableDataSoure
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger imgsViewHIndex = (selectImgDatas.count + 1) / CommitImageViewWidthCount  + ((selectImgDatas.count + 1) % CommitImageViewWidthCount == 0 ? 0 : 1);
    CGSize imgsViewSize = CGSizeMake(CommitImageViewHeightAndWidth * CommitImageViewWidthCount, imgsViewHIndex * CommitImageViewHeightAndWidth);
    
    return 170 + imgsViewSize.height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:commentInpuTextView];
    [cell.contentView addSubview:selectImgView];
    
    return cell;
}


- (void) drawSendImageUIWithAnimation : (UITableViewRowAnimation) _animation
{
    NSInteger imgsViewHIndex = (selectImgDatas.count + 1) / CommitImageViewWidthCount  + ((selectImgDatas.count + 1) % CommitImageViewWidthCount == 0 ? 0 : 1);
    CGSize imgsViewSize = CGSizeMake(CommitImageViewHeightAndWidth * CommitImageViewWidthCount, imgsViewHIndex * CommitImageViewHeightAndWidth);
    
    if (!addImageButton)
    {
        addImageButton = [UIView CreateAddButtonWithFrame:CGRectMake(0, 0, CommitImageViewHeightAndWidth - 5, CommitImageViewHeightAndWidth - 5) color:kNBR_ProjectColor_LightGray];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImgButtonAction:)];
        [addImageButton addGestureRecognizer:tapGesture];
    }
    
    
    if (!selectImgView)
    {
        selectImgView = [[UIView alloc] initWithFrame:CGRectMake(5, 225 - CommitImageViewHeightAndWidth, imgsViewSize.width, CommitImageViewHeightAndWidth * imgsViewSize.height)];
    }
    else
    {
        [selectImgView removeFromSuperview];
        selectImgView = [[UIView alloc] initWithFrame:CGRectMake(5, 225 - CommitImageViewHeightAndWidth, imgsViewSize.width, CommitImageViewHeightAndWidth * imgsViewSize.height)];
    }
    
    currentSelectImageViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < selectImgDatas.count + 1 ; i++)
    {
        
        if (i == selectImgDatas.count)
        {
            //最后一个元素
            addImageButton.frame = CGRectMake((i % CommitImageViewWidthCount) * CommitImageViewHeightAndWidth, (i / CommitImageViewWidthCount) * CommitImageViewHeightAndWidth, CommitImageViewHeightAndWidth - 5, CommitImageViewHeightAndWidth - 5);
            //if (selectImgDatas.count <3 ) {
            [selectImgView addSubview:addImageButton];
            //}
        }
        else
        {
            UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake((i % CommitImageViewWidthCount) * CommitImageViewHeightAndWidth,
                                                                                      (i / CommitImageViewWidthCount) * CommitImageViewHeightAndWidth,
                                                                                      CommitImageViewHeightAndWidth - 5,
                                                                                      CommitImageViewHeightAndWidth - 5)];
            subImageView.layer.cornerRadius = 3.0f;
            subImageView.layer.masksToBounds = 3.0f;
            subImageView.userInteractionEnabled = YES;
            subImageView.tag = 0xCCCC;
            
            UITapGestureRecognizer *subImageViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subSelectImageViewTapGestureAction:)];
            [subImageView addGestureRecognizer:subImageViewTapGesture];
            
            JKAssets *subAsset = selectImgDatas[i];
            
            
            ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:subAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    subImageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                }
            } failureBlock:^(NSError *error) {
                
            }];
            
            
            [currentSelectImageViews addObject:subImageView];
            [selectImgView addSubview:subImageView];
        }
    }
    
    [boundTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:_animation];
}


- (void) addImgButtonAction : (id) sender
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;
    imagePickerController.maximumNumberOfSelection = 9;
    imagePickerController.selectedAssetArray = selectImgDatas;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}


//点击单个选择的图片，放大显示
- (void) subSelectImageViewTapGestureAction : (UITapGestureRecognizer*) _gesture
{
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    [imageViewer showWithImageViews:currentSelectImageViews selectedView:(UIImageView *)_gesture.view];
}

- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView
{
    return;
}


#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    selectImgDatas = [NSMutableArray arrayWithArray:assets];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [self drawSendImageUIWithAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    latitude = userLocation.location.coordinate.latitude;
    longitude = userLocation.location.coordinate.longitude;
    [self onClickReverseGeocode];
}

-(void)viewWillAppear:(BOOL)animated {
    locService.delegate = self;
    geocodesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    locService.delegate = nil;
    geocodesearch.delegate = nil;
}

-(void)onClickReverseGeocode  //发送反编码请求的.
{
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};//初始化
    if (locService.userLocation.location.coordinate.longitude!= 0
        && locService.userLocation.location.coordinate.latitude!= 0) {
        //如果还没有给pt赋值,那就将当前的经纬度赋值给pt
        pt = (CLLocationCoordinate2D){locService.userLocation.location.coordinate.latitude,
            locService.userLocation.location.coordinate.longitude};
    }
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];//初始化反编码请求
    reverseGeocodeSearchOption.reverseGeoPoint = pt;//设置反编码的店为pt
    BOOL flag = [geocodesearch reverseGeoCode:reverseGeocodeSearchOption];//发送反编码请求.并返回是否成功
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        MKPointAnnotation* item = [[MKPointAnnotation alloc] init];
        item.coordinate = result.location;
        item.title = result.address;
        positionTitle = item.title;
    }
}

@end
