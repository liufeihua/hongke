//
//  MyCommentCell.m
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MyCommentCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import "OSCAPI.h"

@interface MyCommentCell ()
{
    float contentHeight;
}

@end
@implementation MyCommentCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)setMyCommentModel:(GFKDMyComment *)myCommentModel
{
    _myCommentModel = myCommentModel;
    [_portrait sd_setImageWithURL:[NSURL URLWithString:_myCommentModel.creatorPhoto] placeholderImage:[UIImage imageNamed:@"default-portrait"]];
    [_portrait setCornerRadius:5.0];
    _label_userName.text = _myCommentModel.creator;
    _label_commentDate.text = _myCommentModel.creationDate;
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:[NSString stringWithFormat:@": %@",_myCommentModel.text]]];
    
    
    _label_newsTitle.text = _myCommentModel.title;

    NSString *shineText;
    if ([_myCommentModel.ftype  isEqual: @"Info"]) {
        contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:[NSString stringWithFormat:@"评论: %@",_myCommentModel.text]]];
        shineText = @"";
    }else  if ([_myCommentModel.ftype  isEqual: @"Comment"])
    {
        contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:[NSString stringWithFormat:@"回复%@:%@",_myCommentModel.fromUser,_myCommentModel.text]]];
        shineText = _myCommentModel.fromUser;
    }
    
    //TTTAttributedLabel *label = [TTTAttributedLabel new];
    //设置可点击文字的范围
    NSRange boldRange = [[contentString string] rangeOfString:shineText options:NSCaseInsensitiveSearch];
    
    //设定可点击文字的的大小
    UIFont *boldSystemFont = [UIFont fontWithName:@"HYQiHei-EZJ" size:16.0];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
    
    if (font) {
        
        //设置可点击文本的大小
        [contentString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
        
        //设置可点击文本的颜色
        [contentString addAttribute:(NSString*)NSForegroundColorAttributeName value:(id)_label_userName.textColor range:boldRange];
        
        CFRelease(font);
        
    }

    _label_info.text = @"";
    _label_fromUser.text = @"";
    [_label_commentContent setAttributedText:contentString];
  
}

+ (CGFloat)heightForRow:(GFKDMyComment *)myComment
{
    NSMutableAttributedString *contentString;
    if ([myComment.ftype  isEqual: @"Info"]) {
        contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:[NSString stringWithFormat:@"评论: %@",myComment.text]]];
    }else  if ([myComment.ftype  isEqual: @"Comment"])
    {
        contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:[NSString stringWithFormat:@"回复%@:%@",myComment.fromUser,myComment.text]]];
    }
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont fontWithName:@"HYQiHei-EZJ" size:16.0]};
    float Height = [[contentString string] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-16, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
    return 120 - 18 + Height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
