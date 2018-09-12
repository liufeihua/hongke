//
//  pointsRuleCell.m
//  iosapp
//
//  Created by redmooc on 16/9/9.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "pointsRuleCell.h"
#import "NTESCommonTableData.h"
#import "UIImageView+Util.h"
#import "UIView+Util.h"
#import "UIView+NTES.h"
#import "GFKDPoints.h"

@interface pointsRuleCell()

@property (nonatomic,strong) UIImageView *ruleImage;
@property (nonatomic,strong) UILabel *ruleName;

@end

@implementation pointsRuleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _ruleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 59, 24)];
        [self addSubview:_ruleImage];
        _ruleName = [[UILabel alloc] initWithFrame:CGRectZero];
        _ruleName.font = [UIFont systemFontOfSize:16.f];
        _ruleName.textColor = [UIColor grayColor];
        [self addSubview:_ruleName];
    }
    return self;
}

- (void)refreshData:(NTESCommonTableRow *)rowData tableView:(UITableView *)tableView{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    GFKDPoints *points = rowData.extraInfo;
    if (![points isKindOfClass:[NSNull class]]) {
        if ([points.pimage isEqualToString:@""]) {
            return;
        }
        [_ruleImage loadPortrait:[NSURL URLWithString:points.pimage]];
        _ruleName.text = points.levelName;
        [_ruleName sizeToFit];
    }
}


#define AvatarRight 15
#define TitleSpacing 12

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.ruleImage.left    = self.frame.size.width - AvatarRight - 59.0f;
    self.ruleImage.centerY = self.height * .5f;
    self.ruleName.centerY = self.height * .5f;
    self.ruleName.right = self.ruleImage.left - TitleSpacing;
}

@end
