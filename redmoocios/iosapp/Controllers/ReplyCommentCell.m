//
//  ReplyCommentCell.m
//  iosapp
//
//  Created by redmooc on 16/3/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "ReplyCommentCell.h"
#import "GFKDNewsComment.h"
#import "Utils.h"

@implementation ReplyCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self initSubviews];
        [self setLayout];
    }
    
    return self;
}

- (void)initSubviews
{
    self.authorLabel = [UILabel new];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:14];
    self.authorLabel.textColor = [UIColor nameColor];
    self.authorLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:self.authorLabel];
    
    self.fromUserLabel = [UILabel new];
    self.fromUserLabel.font = [UIFont boldSystemFontOfSize:14];
    self.fromUserLabel.textColor = [UIColor nameColor];
    self.fromUserLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:self.fromUserLabel];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.font = [UIFont boldSystemFontOfSize:15];
    self.contentLabel.textColor = [UIColor contentTextColor];
    [self.contentView addSubview:self.contentLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings( _authorLabel, _fromUserLabel, _contentLabel);
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_contentLabel]-2-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-52-[_contentLabel]-10-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}

- (void)setContentWithComment:(GFKDNewsComment *)comment
{
    
//    _authorLabel.text = [NSString stringWithFormat:@"%@ 回复",comment.creator];
//    _fromUserLabel.text = [NSString stringWithFormat:@"%@:",comment.fromUser];
    
    NSString * contStr = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.creator,comment.fromUser,comment.text];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:contStr]];
    [contentString addAttribute:NSForegroundColorAttributeName
                          value:[UIColor nameColor]
                          range:NSMakeRange(0, comment.creator.length)];
    
    [contentString addAttribute:NSForegroundColorAttributeName
                          value:[UIColor nameColor]
                          range:NSMakeRange(comment.creator.length +4, comment.fromUser.length)];
    
    
    [_contentLabel setAttributedText:contentString];
    
    //[_contentLabel addLinkToURL:[NSURL URLWithString:substringForMatch] withRange:NSMakeRange(0, comment.creator.length)];
    
    
}

@end
