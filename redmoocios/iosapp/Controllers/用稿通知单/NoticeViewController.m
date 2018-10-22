//
//  NoticeViewController.m
//  iosapp
//
//  Created by redmooc on 18/4/12.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "NoticeViewController.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "OSCAPI.h"

@interface NoticeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label_author;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UIButton *btn_download;
@property (weak, nonatomic) IBOutlet UIImageView *image_notice;
@property (weak, nonatomic) IBOutlet UILabel *label_date;

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *dateStr = [NSString stringWithFormat:@"%@年%@月%@日",[_news_time substringWithRange:NSMakeRange(0,4)],[_news_time substringWithRange:NSMakeRange(5,2)],[_news_time substringWithRange:NSMakeRange(8,2)]];
    _label_author.text = [NSString stringWithFormat:@"%@：",_news_author];
    NSString *content=  [@"        " stringByAppendingString:[NSString stringWithFormat:@"你的作品《%@》%@刊发于红客《%@》栏目，系红客优秀原创稿件，根据学校规定，纳入单位和个人年度用稿统计。",_news_title,dateStr,_news_node]];
    _label_content.attributedText = [self getAttributedStringWithString:content lineSpace:5];
    _label_date.text = dateStr;
}

-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)captureScreen {
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    img = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, CGRectMake(0, 64, kNBR_SCREEN_W*[UIScreen mainScreen].scale, (kNBR_SCREEN_H-64-60)*[UIScreen mainScreen].scale))];
    UIGraphicsEndImageContext();
    return img;
}

- (IBAction)touchUp_download:(id)sender {
//    UIGraphicsBeginImageContext(self.view.bounds.size);     //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//renderInContext呈现接受者及其子范围到指定的上下文
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上下文的图片
//    UIGraphicsEndImageContext();//移除栈顶的基于当前位图的图形上下文
//    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);//然后将该图片保存到图片图
//    viewImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H-60))];
    
    UIImageWriteToSavedPhotosAlbum([self captureScreen], self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}



- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if (!error) {
        HUD.labelText = @"下载成功，已为您保存至相册";
    } else {
        HUD.labelText = [NSString stringWithFormat:@"%@", [error description]];
    }
    
    [HUD hide:YES afterDelay:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
