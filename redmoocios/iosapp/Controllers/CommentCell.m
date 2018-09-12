//
//  CommentCell.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentCell.h"
#import "GFKDNewsComment.h"
#import "Utils.h"
#import "Config.h"
#import "AppDelegate.h"
//#import "AvatarImageView.h"

@interface CommentCell ()

@property (nonatomic, strong) UIView *currentContainer;

@end

@implementation CommentCell

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
    self.portrait = [AvatarImageView new];
    self.portrait.contentMode = UIViewContentModeScaleAspectFit;
    self.portrait.userInteractionEnabled = YES;
    [self.portrait setCornerRadius:5.0];
    [self.contentView addSubview:self.portrait];
    
    self.authorLabel = [UILabel new];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:14];
    self.authorLabel.textColor = [UIColor nameColor];
    self.authorLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:self.authorLabel];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.timeLabel];
    
    self.appclientLabel = [UILabel new];
    self.appclientLabel.font = [UIFont systemFontOfSize:12];
    self.appclientLabel .textAlignment = NSTextAlignmentLeft;
    self.appclientLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.appclientLabel];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.contentLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_authorLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_authorLabel]->=5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-10-[_appclientLabel]->=8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}



- (void)setContentWithComment:(GFKDNewsComment *)comment
{
    [_portrait loadPortrait:[NSURL URLWithString:comment.creatorPhoto]];
   
    _authorLabel.text = comment.creator;
    _timeLabel.attributedText = [Utils attributedTimeStringFormStr:comment.creationDate];
//    _appclientLabel.attributedText = [Utils getAppclient:comment.appclient];
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.text]];

    [_contentLabel setAttributedText:contentString];
    
 
}


#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyText:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}




@end
