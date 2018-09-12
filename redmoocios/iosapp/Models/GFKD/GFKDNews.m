//
//  GFKDNews.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/3.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDNews.h"

#import "Utils.h"

//#import <DateTools.h>

@implementation GFKDNews



- (NSAttributedString *)attributedTittle
{
    if (!_attributedTittle) {
        
        _attributedTittle = [[NSMutableAttributedString alloc] initWithString:_title];
        
        /*
        if ([_dates daysAgo] == 0) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"widget_taday"];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            _attributedTittle = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            [_attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [_attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:_title]];
        } else {
            _attributedTittle = [[NSMutableAttributedString alloc] initWithString:_title];
        }*/
        
    }
    
    return _attributedTittle;
}

- (NSAttributedString *)attributedBrowersCount
{
//    if (!_attributedBrowersCount) {
        _attributedBrowersCount = [Utils attributedBrowersCount:[_browsers intValue]];
//    }
    
    return _attributedBrowersCount;
}

- (NSAttributedString *) attributedReplysCount
{
    _attributedReplysCount = [Utils attributedCommentCount:[_comments intValue]];
    return _attributedReplysCount;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _articleId == ((GFKDNews *)object).articleId;
    }
    
    return NO;
}

@end
