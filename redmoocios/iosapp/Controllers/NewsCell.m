//
//  NewsCell.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "LSPlayerView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface NewsCell ()
{
    LSPlayerView *playerView;
}

@end

@implementation NewsCell

- (void)awakeFromNib {
    // Initialization code
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        
//        //[self initSubviews];
//        //[self setLayout];
//    }
//    return self;
//}

- (void)setNewsModel:(GFKDNews *)NewsModel
{
    _NewsModel = NewsModel;
    self.backgroundColor = [UIColor themeColor];    
    [self.imgIcon sd_setImageWithURL:NewsModel.image placeholderImage:[UIImage imageNamed:@"item_default"]];
    NSString *titleStr;
    if (NewsModel.listTitle == nil||[NewsModel.listTitle  isEqual: @""]) {
        titleStr = NewsModel.title;
    }else
    {
        titleStr = NewsModel.listTitle;
    }
    self.lblTitle.text = titleStr ;
    
    self.lblTitle.numberOfLines = 3;
    self.lblSubtitle.text = @"";
//    self.lblSubtitle.text = NewsModel.dataDict[@"description"];
//    if ([NewsModel.dataDict[@"description"]  isEqual: @""]) {
//        self.lblTitle.numberOfLines = 3;
//    }else{
//        self.lblTitle.numberOfLines = 1;
//    }
    [self.img_tuigao setHidden:YES];
    if (((NSNull *)self.NewsModel.isReject != [NSNull null]) && ([self.NewsModel.isReject intValue] == 1)) {//退稿中
        [self.img_tuigao setHidden:NO];
    }

    self.lblDate.text = @"";
    [self.lblDate setHidden:YES];//需求修改 不显示发布时间
    
    [self.lblBrowers setAttributedText:NewsModel.attributedBrowersCount];
    self.lblBrowers.textColor = [UIColor grayColor];
    [self.lblReply setAttributedText:NewsModel.attributedReplysCount];
    self.lblReply.textColor = [UIColor grayColor];
    
    if (((NSNull *)NewsModel.isReader != [NSNull null]) && ([NewsModel.isReader intValue]== 1)){//电子书 暂时
        [self.lblBrowers setHidden:YES];
        [self.lblReply setHidden:YES];
    }
    // 多图cell
    if ([self.NewsModel.showType intValue] == 2 || [self.NewsModel.showType intValue] == 3) {
        if (NewsModel.images.count>0) {
            [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[0][@"image"]]  placeholderImage:[UIImage imageNamed:@"item_default"]];
        }
        if (NewsModel.images.count>1) {
            [self.imgOther1 sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[1][@"image"]] placeholderImage:[UIImage imageNamed:@"item_default"]];
        }
        if (NewsModel.images.count>2) {
            [self.imgOther2 sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[2][@"image"]] placeholderImage:[UIImage imageNamed:@"item_default"]];
            
        }
    }
//    if ([self.NewsModel.hasImages intValue]== 1 ) {
//         if (NewsModel.images.count>0) {
//             [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[0][@"image"]]  placeholderImage:[UIImage imageNamed:@"item_default"]];
//         }
//        if (NewsModel.images.count>1) {
//            [self.imgOther1 sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[1][@"image"]] placeholderImage:[UIImage imageNamed:@"item_default"]];
//        }
//        if (NewsModel.images.count>2) {
//            [self.imgOther2 sd_setImageWithURL:[NSURL URLWithString:self.NewsModel.images[2][@"image"]] placeholderImage:[UIImage imageNamed:@"item_default"]];
//            
//        }
//    }

    if ([_NewsModel.hasVideo intValue ]== 1) {
        [self.VideoImg setHidden:NO];
    }else
    {
        [self.VideoImg setHidden:YES];
    }
    
    if ([_NewsModel.hasAudio intValue ]== 1) {
        [self.audioImg setHidden:NO];
    }else
    {
        [self.audioImg setHidden:YES];
    }
    
    //修改为后台配制
    if ([NewsModel.sourceImage isEqualToString:@""]) {
        self.sourceIcon.image = nil;
    }else{
        //用NSData导致页面卡
//        NSData * data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:NewsModel.sourceImage]];
//        self.sourceIcon.image = [UIImage imageWithData:data];
        [self.sourceIcon sd_setImageWithURL:[NSURL URLWithString:NewsModel.sourceImage] placeholderImage:nil];
    }
}




+ (CGFloat)heightForRow:(GFKDNews *)NewsModel
{
    NSString *titleStr;
    if (NewsModel.listTitle == nil||[NewsModel.listTitle  isEqual: @""]) {
        titleStr = NewsModel.title;
    }else
    {
        titleStr = NewsModel.listTitle;
    }
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont fontWithName:@"HYQiHei-EZJ" size:16.0]};
    CGFloat titleHeight = [titleStr boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-16, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
    
   //if (([NewsModel.hasImages intValue] == 1) || ([NewsModel.showType intValue] == 2)){
    if ([NewsModel.showType intValue] == 2){
        return 121+titleHeight; //140;
   }else if (([NewsModel.hasVideo intValue] == 1) || ([NewsModel.showType intValue] == 4)){
       //大图   图比例为 360/150   8+titleHeight+8+图高＋8+12+8=44+titleHeight+图高
       //return 197+titleHeight;//232;
       return 44 + titleHeight + kNBR_SCREEN_W*152/359;
   }else if ([NewsModel.showType intValue] == 3){
       return 209+titleHeight;//228
   }else{
        return 87;
   }
    return 0;
}

+ (NSString *)idForRow:(GFKDNews *)NewsModel
{
    /* 1|左图右文章标题、摘要
    2|三张图片并排
    3|左一大图右两小图
    4|大图展现 */
    //NSLog(@"showType:@%@",[NewsModel.showType stringValue]);
    //if (([NewsModel.hasImages intValue] == 1) || ([NewsModel.showType intValue] == 2)){
    if ([NewsModel.showType intValue] == 2){
        return @"ImagesCell";
    }else if (([NewsModel.hasVideo intValue] == 1) || ([NewsModel.showType intValue] == 4)){
        return @"bigImageCell";
    }else if ([NewsModel.showType intValue] == 3){
        return @"ImagesLeftCell";
    }else {
        return @"NewsCell";
    }
    
 
}

- (IBAction)videoChick:(id)sender {
    /*暂时改成自动播放
    playerView = [LSPlayerView playerView];

    playerView.indexRow = self.indexPathRow;
    playerView.indexSection = self.indexPathSection;
    CGRect imgRect = self.imgIcon.frame;
    CGRect Rect = self.frame;
    playerView.currentFrame = CGRectMake(imgRect.origin.x, Rect.origin.y+imgRect.origin.y, imgRect.size.width, imgRect.size.height);
    //playerView.currentFrame=self.imgIcon.frame;
    
    //必须先设置tempSuperView在设置videoURL
    playerView.tempSuperView = self.superview;
    playerView.videoURL = self.NewsModel.video;
    */
}

- (void) closeVedio{
    playerView = [LSPlayerView playerView];
    [playerView closeClick];
}


@end
