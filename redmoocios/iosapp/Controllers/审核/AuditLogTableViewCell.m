//
//  AuditLogTableViewCell.m
//  iosapp
//
//  Created by redmooc on 16/7/21.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditLogTableViewCell.h"
#import "OSCAPI.h"

@implementation AuditLogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.layer.masksToBounds = YES;
    }
    
    return self;
}
+ (CGFloat) heightForDataDict : (NSDictionary *) _dataDict isAction : (BOOL) isAction
{
    NSMutableParagraphStyle *contentViewStyle = [[NSMutableParagraphStyle alloc] init];
    contentViewStyle.lineHeightMultiple = 1;
    contentViewStyle.lineSpacing = 4.0f;
    contentViewStyle.paragraphSpacing = 3.0f;
    UIFont *contentFont = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:13.0f];
    
    NSDictionary *formatDict = @{
                                 NSFontAttributeName               : contentFont,
                                 NSParagraphStyleAttributeName     : contentViewStyle,
                                 NSForegroundColorAttributeName    : kNBR_ProjectColor_DeepBlack,
                                 };
    NSString *opinionStr = _dataDict[@"opinion"]==NULL?@"":_dataDict[@"opinion"];
     NSString *contentStr;
    if (isAction) {
        if ([_dataDict[@"to"] isEqualToString:@"结束"]) {
            contentStr = [NSString stringWithFormat:@"[%@] ",_dataDict[@"to"]];
        }else{
            contentStr = [NSString stringWithFormat:@"[%@] 正在审核中。。。",_dataDict[@"to"]];
        }
    }else{
        contentStr = [opinionStr isEqualToString:@""]?[NSString stringWithFormat:@"[%@] 已审核",_dataDict[@"from"]]:[NSString stringWithFormat:@"[%@] 已审核  \n退稿意见:%@",_dataDict[@"from"],opinionStr];
    }
    CGRect contentStringSize = [contentStr boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W - 60, 200)
                                                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                   attributes:formatDict
                                                                                      context:nil];
    
    return contentStringSize.size.height + 30;
}

- (void) setDateDict : (NSDictionary*) _dataDict isAction : (BOOL) isAction
{
   
    //内容
    NSMutableParagraphStyle *contentViewStyle = [[NSMutableParagraphStyle alloc] init];
    contentViewStyle.lineHeightMultiple = 1;
    contentViewStyle.lineSpacing = 4.0f;
    contentViewStyle.paragraphSpacing = 3.0f;
    UIFont *contentFont = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:13.0f];
    
    NSDictionary *formatDict = @{
                                 NSFontAttributeName               : contentFont,
                                 NSParagraphStyleAttributeName     : contentViewStyle,
                                 NSForegroundColorAttributeName    : kNBR_ProjectColor_DeepBlack,
                                 };
    NSString *opinionStr = _dataDict[@"opinion"]==NULL?@"":_dataDict[@"opinion"];
    NSString *contentStr;
    if (isAction) {
        if ([_dataDict[@"to"] isEqualToString:@"结束"]) {
            contentStr = [NSString stringWithFormat:@"[%@] ",_dataDict[@"to"]];
        }else{
            contentStr = [NSString stringWithFormat:@"[%@] 正在审核中。。。",_dataDict[@"to"]];
        }
    }else{
       contentStr = [opinionStr isEqualToString:@""]?[NSString stringWithFormat:@"[%@] 已审核",_dataDict[@"from"]]:[NSString stringWithFormat:@"[%@] 已审核  \n退稿意见:%@",_dataDict[@"from"],opinionStr];
    }
    CGRect contentStringSize = [contentStr boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W - 60, 200)
                                                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                   attributes:formatDict
                                                                                      context:nil];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:contentStr];
    
    [attString addAttributes:formatDict range:NSMakeRange(0, contentStr.length)];
    float contentY;
    if (isAction) {
        contentY = 15;
    }else{
        contentY = 5;
    }
    UILabel *contentLable = [[UILabel alloc] initWithFrame:CGRectMake(50, contentY, contentStringSize.size.width, contentStringSize.size.height)];
    contentLable.attributedText = attString;
    contentLable.numberOfLines = 0;
    [self addSubview:contentLable];
    
    
    UITextField *dateLable = [[UITextField alloc] initWithFrame:CGRectMake(50, contentStringSize.size.height + 10, kNBR_SCREEN_W - 10 - 50, 50.0f / 2.0f - 3)];
    dateLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:13.0f];
    dateLable.userInteractionEnabled = NO;
    dateLable.textColor = kNBR_ProjectColor_DeepBlack;
    dateLable.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    dateLable.text = _dataDict[@"time"];
    
    if (!isAction) {
        [self.contentView addSubview:dateLable];
    }
    
    UIView *actionView;
    UIView *aciontLine;
    
    CGFloat actionY = contentStringSize.size.height + 30;
    if (isAction)
    {
        contentLable.textColor = [UIColor colorWithRed:32.0f / 255.0f green:85.0f / 255.0f blue:123.0f / 255.0f alpha:1.0f];
        dateLable.textColor = [UIColor colorWithRed:32.0f / 255.0f green:85.0f / 255.0f blue:123.0f / 255.0f alpha:1.0f];
        
        actionView = [[UIView alloc] initWithFrame:CGRectMake(50.0f / 2.0f - 20 / 2.0f,
                                                              actionY / 2.0f - 20 / 2.0f - 10,
                                                              20,
                                                              20)];
        actionView.layer.cornerRadius = 20 / 2.0f;
        actionView.layer.borderColor = [UIColor colorWithRed:188.0f / 255.0f green:219.0f / 255.0f blue:241.0f / 255.0f alpha:1.0f].CGColor;
        actionView.layer.borderWidth = 1.5f;
        actionView.backgroundColor = [UIColor colorWithRed:59.0f / 255.0f green:151.0f / 255.0f blue:218.0f / 255.0f alpha:1.0f];
        
        aciontLine = [[UIView alloc] initWithFrame:CGRectMake(50.0f/ 2.0f - 2.0f / 2.0f,
                                                              actionY / 2.0f - 20 / 2.0f - 5,
                                                              2,
                                                              actionY - (actionY / 2.0f - 20 / 2.0f - 5))];
        aciontLine.backgroundColor = [UIColor colorWithRed:198.0f / 255.0f green:199.0f / 255.0f blue:201.0f / 255.0f alpha:1.0f];
        aciontLine.layer.masksToBounds = YES;
        
        UIView *aciontLine_top = [[UIView alloc] initWithFrame:CGRectMake(50.0f/ 2.0f - 2.0f / 2.0f,
                                                              0,
                                                              2,
                                                              actionY / 2.0f - 20 / 2.0f - 10)];
        aciontLine_top.backgroundColor = [UIColor colorWithRed:198.0f / 255.0f green:199.0f / 255.0f blue:201.0f / 255.0f alpha:1.0f];
        aciontLine_top.layer.masksToBounds = YES;
        
        
        self.contentView.layer.masksToBounds = YES;
        [self.contentView addSubview:aciontLine];
        [self.contentView addSubview:aciontLine_top];
        [self.contentView addSubview:actionView];
    }
    else
    {
        actionView = [[UIView alloc] initWithFrame:CGRectMake(50.0f / 2.0f - 15 / 2.0f,
                                                              actionY / 2.0f - 15 / 2.0f - 10,
                                                              15,
                                                              15)];
        actionView.layer.cornerRadius = 15 / 2.0f;
        actionView.backgroundColor = [UIColor colorWithRed:198.0f / 255.0f green:199.0f / 255.0f blue:201.0f / 255.0f alpha:1.0f];
        
        
        aciontLine = [[UIView alloc] initWithFrame:CGRectMake(50.0f / 2.0f - 2.0f / 2.0f,
                                                              0,
                                                              2,
                                                              actionY)];
        aciontLine.backgroundColor = [UIColor colorWithRed:198.0f / 255.0f green:199.0f / 255.0f blue:201.0f / 255.0f alpha:1.0f];
        aciontLine.layer.masksToBounds = YES;
        
        self.contentView.layer.masksToBounds = YES;
        [self.contentView addSubview:aciontLine];
        [self.contentView addSubview:actionView];
    }

    return ;
}

@end
