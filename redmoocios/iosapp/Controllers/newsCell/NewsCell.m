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
#import <Masonry.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define kTopicImageArray @[@"bg_topic_1",@"bg_topic_2",@"bg_topic_3",@"bg_topic_4",@"bg_topic_5"]

#define kRectH_oneStar 120
@interface NewsCell ()
{
    LSPlayerView *playerView;
}

@end

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    if (ratio_W_H != nil) {
//        ratio_W_H = [NSLayoutConstraint constraintWithItem:ratio_W_H.firstItem
//                                                 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:ratio_W_H.secondItem attribute:NSLayoutAttributeHeight multiplier:1 constant:ratio_W_H.constant];
//    }
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
    //self.backgroundColor = [UIColor themeColor];    
    [self.imgIcon sd_setImageWithURL:NewsModel.image placeholderImage:[UIImage imageNamed:@"item_default"]];
   
//    if ([NewsModel.showType intValue] == 4) {
//
//        CGSize imageSize = [Utils getImageSizeWithURL:NewsModel.image];
//        CGFloat width = imageSize.width;
//        CGFloat height = imageSize.height;
//        
//        if (width != 0 && height !=0) { //url存在问题  图片不存在的情况
//            CGFloat newHeight = self.imgIcon.frame.size.width*height/width;
//            NSLog(@"newHeight:%f = %@",newHeight,NewsModel.image);
//            [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(newHeight);
//                
//            }];
//        }
//        
//        
//    }
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
    
    
    if ([self.NewsModel.showType intValue]== 5) {
        self.lblTitle.numberOfLines = 1;
        //NSLog(@"%@",NewsModel.dataDict[@"description"]);
        self.lblSubtitle.text = NewsModel.dataDict[@"description"];
        unsigned long imageType = self.NewsModel.title.length % [kTopicImageArray count];
        self.topicImageView.image = [UIImage imageNamed:kTopicImageArray[imageType]];
    }else if ([self.NewsModel.showType intValue]== 6) {
        self.lblTitle.numberOfLines = 1;
        self.lblSubtitle.text = NewsModel.subtitle;
        self.lblDescribe.text = NewsModel.dataDict[@"description"];
    }else if ([self.NewsModel.showType intValue]== 7) {
        [self playingStatus];
    }
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
       return 44 + titleHeight + kNBR_SCREEN_W*150/360;
   }else if ([NewsModel.showType intValue] == 3){
       return 209+titleHeight;//228
   }else if ([NewsModel.showType intValue] == 5){
       CGFloat subTitleHeight = [NewsModel.dataDict[@"description"] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-35*2, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
       return 100+subTitleHeight;
   }else if ([NewsModel.showType intValue] == 6){
       return kRectH_oneStar + 20;
   }else if ([NewsModel.showType intValue] == 7){
       NSString *titleStr;
       if (NewsModel.listTitle == nil||[NewsModel.listTitle  isEqual: @""]) {
           titleStr = NewsModel.title;
       }else
       {
           titleStr = NewsModel.listTitle;
       }
       
       CGFloat titleHeight = [titleStr boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-20, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
       
       return titleHeight + 40;
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
    4|大图展现
    5|话题展现形式  后台未改，暂时将红讯中思想场自动改为该形式
    6|左图右简介-个人之星(图片宽高比3:4)
    7|标题(无图片)
     */
    
    //NSLog(@"showType:@%@",[NewsModel.showType stringValue]);
    //if (([NewsModel.hasImages intValue] == 1) || ([NewsModel.showType intValue] == 2)){
    if ([NewsModel.showType intValue] == 2){
        return @"ImagesCell";
    }else if (([NewsModel.hasVideo intValue] == 1) || ([NewsModel.showType intValue] == 4)){
        return @"bigImageCell";
    }else if ([NewsModel.showType intValue] == 3){
        return @"ImagesLeftCell";
    }else if ([NewsModel.showType intValue] == 5){
        return @"topicCell";
    }else if ([NewsModel.showType intValue] == 6){
        return @"NewsOneStar";
    }else if ([NewsModel.showType intValue] == 7){
        return @"TitleCell";
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

- (void) playingStatus{
    if ([_NewsModel.isPlaying intValue]== 1) {
        self.playingBtn.hidden = NO;
        
        self.lblTitle.textColor   = UIColorFromRGB(0xC82627);
        
        NSMutableArray *images = [NSMutableArray new];
        
        for (NSInteger i = 0; i < 4; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1]];
            [images addObject:image];
        }
        
        for (NSInteger i = 4; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        self.playingBtn.imageView.animationImages = images;
        self.playingBtn.imageView.animationDuration = 0.85;
        [self.playingBtn.imageView startAnimating];
    }else {
        
        self.playingBtn.hidden = YES;
        [self.playingBtn.imageView stopAnimating];
        
        self.lblTitle.textColor   = [UIColor blackColor];
    }
}


@end
