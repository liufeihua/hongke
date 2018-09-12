//
//  SettingPortraitCell.m
//  iosapp
//
//  Created by redmooc on 16/9/8.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "SettingPortraitCell.h"
#import "NTESCommonTableData.h"
#import "UIImageView+Util.h"
#import "UIView+Util.h"
#import "UIView+NTES.h"

@interface SettingPortraitCell()

@property (nonatomic,strong) UIImageView *avatar;

@end

@implementation SettingPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat avatarWidth = 55.f;
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarWidth)];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
        [_avatar setCornerRadius:55.f/2.0];
        
        _avatar.userInteractionEnabled = YES;
        
        [self addSubview:_avatar];
    }
    return self;
}

- (void)refreshData:(NTESCommonTableRow *)rowData tableView:(UITableView *)tableView{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    NSString *uid = rowData.extraInfo;
    if ([uid isKindOfClass:[NSString class]]) {
        [_avatar loadPortrait:[NSURL URLWithString:uid]];
    }
}


#define AvatarRight 35

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.avatar.left    = self.frame.size.width - AvatarRight - 55.0f;
    self.avatar.centerY = self.height * .5f;
}

@end
