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
#import "RadioListViewController.h"
#import "CWCarousel.h"
#import "CWPageControl.h"
#import "StudySchoolViewController.h"

static NSString *CarouselCellIdentifier = @"CarouselCell";

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

#define kRectH_radio (kWindowW-32)*2/7.0  //W:H=7:2

#define kRectH_carousel_small kWindowW*2/9.0   //W:H=9:2
#define kRectH_carousel_normal kWindowW*9/16.0   //W:H=16:9
#define kRectH_carousel_H3 (kWindowW - 40 - 18)*9/16.0   //W:H=16:9

#define kRectH_Special (kWindowW-20)*5/12.0  //W:H=12:5

#define kRectW_four_2row (kWindowW - 100)/4.0
#define kRectH_four_2row kRectW_four_2row      //W:H=1:1

#define kRectH_one_big  120

#define kRectW_video  (kWindowW - 100)
#define kRectH_video  kRectW_video*9/16.0

#define kRectW_qiangjun  (kWindowW - 10)/2.0
#define kRectH_qiangjun  kRectW_qiangjun*9/16.0

//typeId
//0:两列样式(图片宽高比1:1)
//1:三列样式(图片宽高比4:3)
//2:四列样式(图片宽高比3:4)
//3:滑动样式(图片宽高比4:3)
//4:四列样式(图片宽高比1:1)
//5:左图右标题(图片宽高比4:3)
//6:单行标题(无图片)
//7:左图右简介-个人之星(图片宽高比3:4)
//8:左右左三图片(图片宽高比9:5)
//9:音频样式(图片宽高比7:2)
//10:小图轮播样式(图片宽高比9:2)
//11:普通轮播样式(图片宽高比16:9)
//12:两边被遮挡轮播样式(图片宽高比16:9)
//13:专题样式(图片宽高比12:5)
//14:二行四列样式(图片宽高比1:1)
//15:左标题右图片(图片宽高比4:3)
//16:可左右切换视频样式(图片宽高比16:9)
//17:强军两列样式(图片宽高比16:9)

@interface NodeBaseCell ()<CWCarouselDelegate,CWCarouselDatasource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation NodeBaseCell
{
    NSMutableArray *dataArray_childNode;
    int selectedNum;
}

- (void) setNode:(GFKDTopNodes *)node{
    if ([node.linkType intValue] == 6)  // 跳转到栏目 6
    {
        node.cateId = [NSNumber numberWithInt:[node.detailUrl intValue]];
    }
    _node = node;
    if ([node.nodeModelId intValue] == 20) {
        _showRadioPlay = YES;
    }
    [self loadChildNodeList:node.cateId];
    //显示子栏目
    if ([_node.showChildNode intValue] == 1) {
        switch (selectedNum) {
            case 0:
                {
                    _label1.textColor = kNBR_ProjectColor;
                    _view_selected_1.hidden = NO;
                }
                break;
            case 1:
            {
                _label2.textColor = kNBR_ProjectColor;
                _view_selected_2.hidden = NO;
            }
                break;
            case 2:
            {
                _label3.textColor = kNBR_ProjectColor;
                _view_selected_3.hidden = NO;
            }
                break;
            case 3:
            {
                _label4.textColor = kNBR_ProjectColor;
                _view_selected_4.hidden = NO;
            }
                break;
            default:
                break;
        }
        
    }
    
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
    
    _image5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_5)];
    [_image5 addGestureRecognizer:singleTap_5];
    _label5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_5_label = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_5)];
    [_label5 addGestureRecognizer:singleTap_5_label];
    
    _label_author_5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_5_author = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_5)];
    [_label_author_5 addGestureRecognizer:singleTap_5_author];
    
    _image6.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_6)];
    [_image6 addGestureRecognizer:singleTap_6];
    
    _image7.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_7)];
    [_image7 addGestureRecognizer:singleTap_7];
    
    _image8.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap_8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Click_8)];
    [_image8 addGestureRecognizer:singleTap_8];
    
    selectedNum = 0;
    
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
}

- (void) loadVieDottedLine{
    [self addBorderToLayer:_view_dotted_1];
    [self addBorderToLayer:_view_dotted_2];
    [self addBorderToLayer:_view_dotted_3];
    [self addBorderToLayer:_view_dotted_4];
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
        case 9:
        {
            return kRectH_radio*5+20*5+20;
        }
            break;
        case 10:
        {
            return kRectH_carousel_small;
        }
            break;
        case 11:
        {
            return kRectH_carousel_normal;
        }
            break;
        case 12:
        {
            return kRectH_carousel_H3 + 10;
        }
            break;
        case 13:
        {
            return kRectH_Special + 20 + 8 + 20;
        }
            break;
        case 14:
        {
            return kRectW_four_2row *2 +60;
        }
            break;
        case 15:
        {
            return kRectH_one_big*3+6*10;
        }
            break;
        case 16:
        {
            return kRectH_video+30+30+30;
        }
            break;
        case 17:
        {
            return 57+10+8+kRectH_qiangjun+20*2+10+8;
        }
            break;
        default:
        {
            return kRectH_one*3+6*10;
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
        case 9:
        {
            return @"NodeRadioCell";
        }
            break;
        case 10:
        {
            return @"NodeCarouselCell";
        }
            break;
        case 11:
        {
            return @"NodeCarouselCell";
        }
            break;
        case 12:
        {
            return @"NodeCarouselCell";
        }
            break;
        case 13:
        {
            return @"NodeSpecialCell";
        }
            break;
        case 14:
        {
            return @"NodeFour_2row";
        }
            break;
        case 15:
        {
            return @"NodeOne_bigCell";
        }
            break;
        case 16:
        {
            return @"NodeVideoCell";
        }
            break;
        case 17:
        {
            return @"NodeQiangjunCell";
        }
            break;
        default:
        {
            return @"NodeOneCell";
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
                 //[self loadArticleList:[_node.cateId intValue]];
                 [self loadArticleList:[parentId intValue]];
                 return;
             }
             [dataArray_childNode removeAllObjects];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *node = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [dataArray_childNode addObject:node];
                 
                 if (i == 0) {
                     [self.image1 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label1.text = node.cateName;
                     self.label_subTitle_1.text = node.dataDict[@"description"];
                 }
                 if (i == 1) {
                     [self.image2 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label2.text = node.cateName;
                     self.label_subTitle_2.text = node.dataDict[@"description"];
                 }
                 if (i == 2) {
                     [self.image3 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label3.text = node.cateName;
                     self.label_subTitle_3.text = node.dataDict[@"description"];
                 }
                 if (i == 3) {
                     [self.image4 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label4.text = node.cateName;
                     self.label_subTitle_4.text = node.dataDict[@"description"];
                 }
                 if (i == 4) {
                    [self.image5 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
                     self.label5.text = node.cateName;
                     self.label_subTitle_5.text = node.dataDict[@"description"];
                 }
                 if (i == 5) {
                     [self.image6 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
//                     self.label6.text = node.cateName;
//                     self.label_subTitle_6.text = node.dataDict[@"description"];
                 }
                 if (i == 6) {
                     [self.image7 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
//                     self.label7.text = node.cateName;
//                     self.label_subTitle_7.text = node.dataDict[@"description"];
                 }
                 if (i == 7) {
                     [self.image8 sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
//                     self.label5.text = node.cateName;
//                     self.label_subTitle_5.text = node.dataDict[@"description"];
                 }
             }
             if ([_node.typeId intValue] == 10 || [_node.typeId intValue] == 11 || [_node.typeId intValue] == 12){
                 [self loadCarouselView];
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
        [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=0",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,cateId,@"pageSize=5",0,[Config getToken]]
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
                     NSString *titleStr;
                     if (news.listTitle == nil||[news.listTitle  isEqual: @""]) {
                         titleStr = news.title;
                     }else
                     {
                         titleStr = news.listTitle;
                     }
                     if (i == 0) {
                         if (news.images.count>0){
                              [self.image1 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                            [self.image1 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label1.text = titleStr;
                         self.label_subTitle_1.text = news.dataDict[@"description"];
                         self.label_author_1.text = news.author;
                         self.label_job_1.text = news.subtitle;
                         if ([news.hasVideo intValue] == 1) {
                             self.btn_viedo_1.hidden = NO;
                         }
                     }
                     if (i == 1) {
                         if (news.images.count>0){
                             [self.image2 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image2 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label2.text = titleStr;
                         self.label_subTitle_2.text = news.dataDict[@"description"];
                         self.label_author_2.text = news.author;
                         if ([news.hasVideo intValue] == 1) {
                             self.btn_viedo_2.hidden = NO;
                         }
                     }
                     if (i == 2) {
                         if (news.images.count>0){
                             [self.image3 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image3 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label3.text = titleStr;
                         self.label_subTitle_3.text = news.dataDict[@"description"];
                         self.label_author_3.text = news.author;
                         if ([news.hasVideo intValue] == 1) {
                             self.btn_viedo_3.hidden = NO;
                         }
                     }
                     if (i == 3) {
                         if (news.images.count>0){
                             [self.image4 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image4 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label4.text = titleStr;
                         self.label_subTitle_4.text = news.dataDict[@"description"];
                         self.label_author_4.text = news.author;
                         if ([news.hasVideo intValue] == 1) {
                             self.btn_viedo_4.hidden = NO;
                         }
                     }
                     if (i == 4) {
                         if (news.images.count>0){
                             [self.image5 sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }else{
                             [self.image5 sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
                         }
                         self.label5.text = titleStr;
                         self.label_subTitle_5.text = news.dataDict[@"description"];
                         self.label_author_5.text = news.author;
                     }
                 }
                 
                 if ([_node.typeId intValue] == 10 || [_node.typeId intValue] == 11 || [_node.typeId intValue] == 12){
                     [self loadCarouselView];
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
- (IBAction)btn_Click_1:(id)sender {
    [self Click_1];
}

- (void) Click_1{
    if (dataArray_childNode.count > 0){
        if ([dataArray_childNode[0] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[0];
            if ([_node.showChildNode intValue] == 1) {
                _label1.textColor = kNBR_ProjectColor;
                _view_selected_1.hidden = NO;
                _label2.textColor = [UIColor titleColor];
                _view_selected_2.hidden = YES;
                _label3.textColor = [UIColor titleColor];
                _view_selected_3.hidden = YES;
                _label4.textColor = [UIColor titleColor];
                _view_selected_4.hidden = YES;
                selectedNum = 0;
                if (self.delegate)
                {
                    [self.delegate NodeChick:_indexTag withNode:node];
                }
                
            }else{
               [self pushNodeDetail:node];
            }
        }else if ([dataArray_childNode[0] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[0];
            [self pushArticleDetail:news];
        }
    }
}
- (IBAction)btn_click_2:(id)sender {
    [self Click_2];
}

- (void) Click_2{
    if (dataArray_childNode.count > 1){
        if ([dataArray_childNode[1] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[1];
            if ([_node.showChildNode intValue] == 1) {
                _label1.textColor = [UIColor titleColor];
                _view_selected_1.hidden = YES;
                _label2.textColor = kNBR_ProjectColor;
                _view_selected_2.hidden = NO;
                _label3.textColor = [UIColor titleColor];
                _view_selected_3.hidden = YES;
                _label4.textColor = [UIColor titleColor];
                _view_selected_4.hidden = YES;
                selectedNum = 1;
                if (self.delegate)
                {
                    [self.delegate NodeChick:_indexTag withNode:node];
                }
            }else{
                [self pushNodeDetail:node];
            }
        }else if ([dataArray_childNode[1] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[1];
            [self pushArticleDetail:news];
        }
    }
}
- (IBAction)btn_click_3:(id)sender {
    [self Click_3];
}
- (void) Click_3{
    if (dataArray_childNode.count > 2){
        if ([dataArray_childNode[2] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[2];
            if ([_node.showChildNode intValue] == 1) {
                _label1.textColor = [UIColor titleColor];
                _view_selected_1.hidden = YES;
                _label2.textColor = [UIColor titleColor];
                _view_selected_2.hidden = YES;
                _label3.textColor = kNBR_ProjectColor;
                _view_selected_3.hidden = NO;
                _label4.textColor = [UIColor titleColor];
                _view_selected_4.hidden = YES;
                selectedNum = 2;
                if (self.delegate)
                {
                    [self.delegate NodeChick:_indexTag withNode:node];
                }
            }else{
                [self pushNodeDetail:node];
            }
        }else if ([dataArray_childNode[2] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[2];
            [self pushArticleDetail:news];
        }
    }
}
- (IBAction)btn_click_4:(id)sender {
    [self Click_4];
}
- (void) Click_4{
    if (dataArray_childNode.count > 3){
        if ([dataArray_childNode[3] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[3];
            if ([_node.showChildNode intValue] == 1) {
                _label1.textColor = [UIColor titleColor];
                _view_selected_1.hidden = YES;
                _label2.textColor = [UIColor titleColor];
                _view_selected_2.hidden = YES;
                _label3.textColor = [UIColor titleColor];
                _view_selected_3.hidden = YES;
                _label4.textColor = kNBR_ProjectColor;
                _view_selected_4.hidden = NO;
                selectedNum = 3;
                if (self.delegate)
                {
                    [self.delegate NodeChick:_indexTag withNode:node];
                }
            }else{
                [self pushNodeDetail:node];
            }
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

- (void) Click_6{
    if (dataArray_childNode.count > 5){
        if ([dataArray_childNode[5] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[5];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[5] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[5];
            [self pushArticleDetail:news];
        }
    }
}

- (void) Click_7{
    if (dataArray_childNode.count > 6){
        if ([dataArray_childNode[6] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[6];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[6] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[6];
            [self pushArticleDetail:news];
        }
    }
}

- (void) Click_8{
    if (dataArray_childNode.count > 7){
        if ([dataArray_childNode[7] isKindOfClass:[GFKDTopNodes class]]) {
            GFKDTopNodes *node = dataArray_childNode[7];
            [self pushNodeDetail:node];
        }else if ([dataArray_childNode[7] isKindOfClass:[GFKDNews class]]){
            GFKDNews *news = dataArray_childNode[7];
            [self pushArticleDetail:news];
        }
    }
}

- (void) pushNodeDetail:(GFKDTopNodes *)node{
    //首先判断一下是否有链接类型和链接地址，如果有则执行链接
    if (![node.linkType isEqualToString:@""]) {
        [Utils showLinkLinkType:node.linkType WithUrl:node.detailUrl WithNowVC:_parentVC];
        return;
    }
    if (!_showRadioPlay){
        if ([node.terminated intValue] == 1){ //没有子栏目了
            NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
            newsVC.hidesBottomBarWhenPushed = YES;
            newsVC.title = node.cateName;
            [_parentVC.navigationController pushViewController:newsVC animated:YES];
            
        }else{
            StudySchoolViewController *newsVC = [[StudySchoolViewController alloc] initWithParentId:node.cateId WithNav:YES];
            newsVC.hidesBottomBarWhenPushed = YES;
            newsVC.title = node.cateName;
            [_parentVC.navigationController pushViewController:newsVC animated:YES];
        }
    }else{
//        RadioListViewController *radioVC = [[RadioListViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
        RadioListViewController *radioVC = [[RadioListViewController alloc] initWithNode:node];
        radioVC.hidesBottomBarWhenPushed = YES;
        radioVC.newsVC.title = node.cateName;
        [_parentVC.navigationController pushViewController:radioVC animated:YES];
    }
    
//    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
//    newsVC.hidesBottomBarWhenPushed = YES;
//    newsVC.title = node.cateName;
//    [_parentVC.navigationController pushViewController:newsVC animated:YES];
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

- (void)loadCarouselView{
//    CATransition *tr = [CATransition animation];
//    tr.type = @"cube";
//    tr.subtype = kCATransitionFromRight;
//    tr.duration = 0.25;
//    [self.animationView.layer addAnimation:tr forKey:nil];
//
//    self.view.backgroundColor = [UIColor whiteColor];
//    if(self.carousel) {
//        [self.carousel releaseTimer];
//        [self.carousel removeFromSuperview];
//        self.carousel = nil;
//    }
//
    //@[@"正常样式", @"横向滑动两边留白", @"横向滑动两边留白渐变效果", @"两边被遮挡效果"];
    NSUInteger carouselStyle = 0;
    if ([self.node.typeId intValue] == 10 ||[self.node.typeId intValue] == 11) {
        carouselStyle = CWCarouselStyle_Normal;
    }
    if ([self.node.typeId intValue] == 12) {
        carouselStyle = CWCarouselStyle_H_3;
    }
    CWFlowLayout *flowLayout = [[CWFlowLayout alloc] initWithStyle:carouselStyle];
    
    
    CWCarousel *carousel = [[CWCarousel alloc] initWithFrame:CGRectZero
                                                    delegate:self
                                                  datasource:self
                                                  flowLayout:flowLayout];
    carousel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.carouselView addSubview:carousel];
    NSDictionary *dic = @{@"view" : carousel};
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:dic]];
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:dic]];
   
    carousel.isAuto = YES;
    carousel.autoTimInterval = 3;
    carousel.endless = YES;
    carousel.backgroundColor = [UIColor whiteColor];
    [carousel registerViewClass:[UICollectionViewCell class] identifier:CarouselCellIdentifier];
    [carousel freshCarousel];
    
}

#pragma mark - Delegate

- (NSInteger)numbersForCarousel {
    return dataArray_childNode.count;
}

- (UICollectionViewCell *)viewForCarousel:(CWCarousel *)carousel indexPath:(NSIndexPath *)indexPath index:(NSInteger)index{
    UICollectionViewCell *cell = [carousel.carouselView dequeueReusableCellWithReuseIdentifier:CarouselCellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = [cell.contentView viewWithTag:666];
    if(!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imgView.tag = 666;
        imgView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        imgView.userInteractionEnabled = YES;
    }
    if ([dataArray_childNode[index] isKindOfClass:[GFKDNews class]]) {
        GFKDNews *news = dataArray_childNode[index];
        if (news.images.count>0){
            [imgView sd_setImageWithURL:news.images[0][@"image"] placeholderImage:[UIImage imageNamed:@"item_default"]];
        }else{
            [imgView sd_setImageWithURL:news.image placeholderImage:[UIImage imageNamed:@"item_default"]];
        }
    }else if ([dataArray_childNode[index] isKindOfClass:[GFKDTopNodes class]]) {
        GFKDTopNodes *node = dataArray_childNode[index];
        [imgView sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
    }
    //imgView.alpha = 0.5;
    return cell;
}

- (void)CWCarousel:(CWCarousel *)carousel didSelectedAtIndex:(NSInteger)index {
    NSLog(@"...%ld...", (long)index);
    if ([dataArray_childNode[index] isKindOfClass:[GFKDNews class]]) {
        GFKDNews *news = dataArray_childNode[index];
        [self pushArticleDetail:news];
    }else if ([dataArray_childNode[index] isKindOfClass:[GFKDTopNodes class]]) {
        GFKDTopNodes *node = dataArray_childNode[index];
        [self pushNodeDetail:node];
    }
}


#pragma mark - UIScrollViewDelegate

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}



- (void)setConttentOffset:(NSNumber*)x
{
    _scrollView.contentOffset = CGPointMake([x floatValue], 0);
}

- (IBAction)btn_prevClick:(id)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    //NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentOffset.x-pageWidth, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
}

- (IBAction)btn_nextClick:(id)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
   // NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentOffset.x+pageWidth, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
}



@end
