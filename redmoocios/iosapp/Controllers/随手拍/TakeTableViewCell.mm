//
//  TakeTableViewCell.m
//  iosapp
//
//  Created by redmooc on 16/6/15.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "TakeTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import "OSCAPI.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "AvatarImageView.h"

@interface TakeTableViewCell()
{
    GFKDTakes       *entity;
    NSMutableArray  *subImageViews;
    
    UIImage         *zanImg;
    UIImage         *nozanImg;
    UIImage         *starImg;
    UIImage         *nostarImg;
}

@end


@implementation TakeTableViewCell

@synthesize avterImageView;
@synthesize nikeNameLable;
@synthesize contentLable;
@synthesize addressLable;
@synthesize commitDateLable;
@synthesize rangeLable;


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)awakeFromNib {
    
}

- (void) configView
{
    subImageViews = [[NSMutableArray alloc] init];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    
    //头像
    avterImageView = [[AvatarImageView alloc] initWithFrame:CGRectMake(10, 5, 43.0f, 43.0f)];
    [avterImageView sd_setImageWithURL:[NSURL URLWithString:entity.photo] placeholderImage:[UIImage imageNamed:@"default-portrait"]];
    avterImageView.layer.cornerRadius = CGRectGetWidth(avterImageView.frame) / 2.0f;
    avterImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:avterImageView];
    
    
    //昵称
    nikeNameLable = [[UILabel alloc] initWithFrame:CGRectMake(63,
                                                              5,
                                                              kNBR_SCREEN_W - (43 + 10 * 3 + 150),
                                                              25.0f)];
    nikeNameLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:15.0f];
    nikeNameLable.textColor = kNBR_ProjectColor;
    nikeNameLable.text = entity.username;
    nikeNameLable.autoresizingMask = NO;
//    [nikeNameLable setFrame:CGRectMake(63,
//                                       5,
//                                       nikeNameLable.frame.size.width,
//                                       25.0f)];
    
    self.autoresizesSubviews = NO;
    
    [self.contentView addSubview:nikeNameLable];
    
    //时间
    UIFont *commitDateFont = [UIFont fontAwesomeFontOfSize:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:entity.createTime];
    
    NSString *commentDatesString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date timeAgoSinceNow]];

    CGSize commitDateStringSize = [commentDatesString sizeWithAttributes:@{NSFontAttributeName : commitDateFont}];
    
    commitDateLable = [[UILabel alloc] initWithFrame:CGRectMake(63 ,
                                                                nikeNameLable.frame.origin.y + CGRectGetHeight(nikeNameLable.frame),
                                                                commitDateStringSize.width,
                                                                commitDateStringSize.height)];
    commitDateLable.textColor = [UIColor grayColor];
    commitDateLable.attributedText = [[NSAttributedString alloc] initWithString:commentDatesString
                                                                     attributes:@{
                                                                                  NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                  }];
    [self.contentView addSubview:commitDateLable];
    
    
    //内容
    NSMutableParagraphStyle *contentViewStyle = [[NSMutableParagraphStyle alloc] init];
    contentViewStyle.lineHeightMultiple = 1;
    contentViewStyle.lineSpacing = 4.0f;
    contentViewStyle.paragraphSpacing = 3.0f;
    
    //format attribute string dict
    UIFont *contentFont = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:15.0f];
    
    NSDictionary *formatDict = @{
                                 NSFontAttributeName               : contentFont,
                                 NSParagraphStyleAttributeName     : contentViewStyle,
                                 NSForegroundColorAttributeName    : kNBR_ProjectColor_DeepBlack,
                                 };
    CGFloat contentH;
    if (_isDetailView) {
        contentH = 1000;
    }else
    {
        contentH = 100;
    }
    
    
    NSMutableAttributedString *attString =  [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:entity.title]];
    
    CGRect contentStringSize = [[attString string] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W - ( 10 * 3), contentH)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:formatDict
                                                          context:nil];
    [attString addAttributes:formatDict range:NSMakeRange(0, [Utils emojiStringFromRawString:entity.title].length)];
    
    contentLable = [[UILabel alloc] initWithFrame:CGRectMake(avterImageView.frame.origin.x + 5, avterImageView.frame.origin.y + CGRectGetHeight(avterImageView.frame) + 10, contentStringSize.size.width, contentStringSize.size.height)];
    contentLable.numberOfLines = 0;
    contentLable.lineBreakMode = NSLineBreakByTruncatingTail;
    contentLable.attributedText = attString;//[Utils emojiStringFromRawString:entity.title];
    [self.contentView addSubview:contentLable];
    
    //图片
    NSMutableArray *contentImageViews = [[NSMutableArray alloc] init];
    
    NSInteger widthCount;
    CGSize singleImgSize = CGSizeZero;
    
    switch (entity.images.count)
    {
            break;
            
        case 1:
        {
            widthCount = 1;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 15 * 2 ) / 1.0f,
                                       (kNBR_SCREEN_W - 15 * 2 ) / 1.0f - 100);
        }
            break;
            
        case 2:
        case 4:
        {
            widthCount = 2;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 15 * 2) / 2.0f,
                                       (kNBR_SCREEN_W - 15 * 2)  / 2.0f);
        }
            break;
            
        case 0:
        case 3:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        default:
        {
            widthCount = 3;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 15 * 2)  / 3.0f,
                                       (kNBR_SCREEN_W - 15 * 2)  / 3.0f);
        }
            break;
    }
    
    for (int i = 0; i < entity.images.count; i++)
    {
        if (i >= 9)
        {
            return ;
        }
        
        UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentLable.frame.origin.x + (i % widthCount) * singleImgSize.width,
                                                                                 contentLable.frame.origin.y + contentLable.frame.size.height + (i / widthCount) * singleImgSize.height + 10,
                                                                                 singleImgSize.width - 2, singleImgSize.height - 2)];
        //图片改成缩约图
        //NSString *image_min = NSString stringWithFormat:@"%@_min"
        
        [subImageView sd_setImageWithURL:[NSURL URLWithString:[Utils getMinImageNameWithName:entity.images[i]]] placeholderImage:[UIImage imageNamed:@"item_default"]];
        subImageView.contentMode = UIViewContentModeScaleAspectFill;
        subImageView.layer.masksToBounds = YES;
        subImageView.userInteractionEnabled = YES;
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSubImageView:)];
        [subImageView addGestureRecognizer:tapGesture];
        
        
        [contentImageViews addObject:subImageView];
        [self.contentView addSubview:subImageView];
        [subImageViews addObject:subImageView];
    }
    
    
    NSInteger yIndex = entity.images.count > 9 ? 9 :entity.images.count;
    
    yIndex = yIndex % widthCount == 0 ? yIndex / widthCount : yIndex / widthCount + 1;
    
    
    //点赞图标
    UIView *zanView = [[UIView alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W - 75,
                                                              0,
                                                              40,
                                                              30)];
    
    
    _zanLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                             10,
                                                             20,
                                                             20)];
    nozanImg = [UIImage imageNamed:@"toolbar-zan"];
    zanImg = [UIImage imageNamed:@"toolbar-zan-selected"];
    if ([entity.digged intValue] == 1) {
        _isZaned = YES;
        _zanLogo.image = zanImg;
    }else
    {
        _isZaned = NO;
        _zanLogo.image = nozanImg;
    }
    zanView.userInteractionEnabled = YES;
    UITapGestureRecognizer *zanGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zanImageView:)];
    [zanView addGestureRecognizer:zanGesture];
    //收藏图标
    UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W - 40,
                                                               0,
                                                               40,
                                                               30)];
    
    _starLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                             10,
                                                             20,
                                                             20)];
    nostarImg = [UIImage imageNamed:@"toolbar-star"];
    starImg = [UIImage imageNamed:@"toolbar-star-selected"];
    if ([entity.collected intValue] == 1) {
        _isStared = YES;
        _starLogo.image = starImg;
    }else
    {
        _isStared = NO;
        _starLogo.image = nostarImg;
    }
    starView.userInteractionEnabled = YES;
    UITapGestureRecognizer *starGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starImageView:)];
    [starView addGestureRecognizer:starGesture];
    
    if (self.isDetailView) {
        [self.contentView addSubview:zanView];
        [zanView addSubview:_zanLogo];
        [self.contentView addSubview:starView];
        [starView addSubview:_starLogo];
        //[self.contentView addSubview:_zanLogo];
        //[self.contentView addSubview:_starLogo];
    }
    
    //底部
    UIView *bottonView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  contentLable.frame.origin.y + contentLable.frame.size.height + (yIndex) * singleImgSize.height + (yIndex == 0 ? 0 : 10) + 5.5,
                                                                  kNBR_SCREEN_W - (15 * 2),
                                                                  16)];
    
    [self.contentView addSubview:bottonView];
    
    
    UIFont *countfont = [UIFont fontAwesomeFontOfSize:10];
    //回复数
    NSString *commentString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FAComment], [entity.comments intValue]];
    
    CGSize commentCountStringSize = [commentString sizeWithAttributes:@{
                                                                              NSFontAttributeName : countfont,
                                                                              }];
    
    UILabel *commentCountLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottonView.frame) - commentCountStringSize.width + 13, 0, commentCountStringSize.width, CGRectGetHeight(bottonView.frame))];
    commentCountLable.textColor = [UIColor grayColor];
    commentCountLable.attributedText = [[NSAttributedString alloc] initWithString:commentString
                                                                       attributes:@{
                                                                                    NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                    }];
    
    
    CGFloat nextX = commentCountLable.frame.origin.x;
    //点赞数
    NSString *zanString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FAThumbsUp], [entity.diggs intValue]];
    CGSize zanCountStringSize = [zanString sizeWithAttributes:@{
                                                                                 NSFontAttributeName : countfont,
                                                                                 }];
    UILabel *zanCountLable = [[UILabel alloc] initWithFrame:CGRectMake(nextX - zanCountStringSize.width - 10, 0, zanCountStringSize.width, CGRectGetHeight(bottonView.frame))];
    zanCountLable.textColor = [UIColor grayColor];
    zanCountLable.attributedText = [[NSAttributedString alloc] initWithString:zanString
                                                                   attributes:@{
                                                                                NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                }];
    
    //地址
    NSString *addressStr = [NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForEnum:FAMapMarker],entity.address];
    CGSize addressStringSize = [addressStr sizeWithAttributes:@{NSFontAttributeName : commitDateFont}];
    CGFloat addressWidth;
    if (addressStringSize.width > kNBR_SCREEN_W-16-commentCountStringSize.width-zanCountStringSize.width){
        addressWidth = addressStringSize.width;
    }else{
        addressWidth = kNBR_SCREEN_W-16-commentCountStringSize.width-zanCountStringSize.width - 10;
    }
    addressLable = [[UILabel alloc] initWithFrame:CGRectMake(15,
                                                             2,
                                                             addressWidth,
                                                             addressStringSize.height)];
    addressLable.attributedText = [[NSAttributedString alloc] initWithString:addressStr attributes:@{NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],}];
    addressLable.textColor = [UIColor grayColor];
    if ( ((NSNull *)entity.address != [NSNull null]) && ![entity.address isEqualToString:@""] ) {
        if (_isDetailView){
        [bottonView addSubview:addressLable];
        }
    }
    
    rangeLable = [[UILabel alloc] initWithFrame:CGRectMake(15,
                                                           2,
                                                           kNBR_SCREEN_W-16-commentCountStringSize.width-zanCountStringSize.width,
                                                           16)];
    
    rangeLable.textColor = [UIColor grayColor];
    rangeLable.font = [UIFont fontAwesomeFontOfSize:10];
    CLLocationDistance distance = 0;
    if (((NSNull *)entity.address != [NSNull null]) && ![entity.address isEqualToString:@""] && ((NSNull *)entity.longitude != [NSNull null]) &&  ((NSNull *)entity.latitude != [NSNull null]) && _latitude!=0 && _longitude!=0) {
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(_latitude,_longitude));
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake((CLLocationDegrees)[entity.latitude doubleValue],(CLLocationDegrees)[entity.longitude doubleValue]));
        distance = BMKMetersBetweenMapPoints(point1,point2);
        if (distance < 200) {
            rangeLable.text = @"200 米内";
        }else if (distance < 500) {
            rangeLable.text = @"500 米内";
        }else if (distance < 1000) {
            rangeLable.text = [NSString stringWithFormat:@"约 %.0f 米",distance];
        }else{
            rangeLable.text = [NSString stringWithFormat:@"约 %.0f 千米",distance/1000.0];
        }
        
        if (distance > 0) {
            if (!_isDetailView){
                [bottonView addSubview:rangeLable];
            }
        }
    }
    
    if (!_isDetailView) {
        [bottonView addSubview:commentCountLable];
        [bottonView addSubview:zanCountLable];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) setDateEntity : (GFKDTakes*) _dateEntity
{
    entity = _dateEntity;
    
    [self configView];
}

//+ (CGFloat) heightWithEntity : (FriendCircleContentEntity*) _dateEntity
+ (CGFloat) heightWithEntity : (GFKDTakes*) _dateEntity isDetail:(BOOL)_isDeatil
{
    GFKDTakes *entity = _dateEntity;
    //头像
    UIImageView *avterImageView = [[UIImageView alloc] init];
    avterImageView.frame = CGRectMake(10, 5, 43.0f, 43.0f);
    
    //昵称
    UILabel *nikeNameLable = [[UILabel alloc] initWithFrame:CGRectMake(63,
                                                                       5,
                                                                       kNBR_SCREEN_W - (43 + 10 * 3),
                                                                       25.0f)];
    
    //内容
    NSMutableParagraphStyle *contentViewStyle = [[NSMutableParagraphStyle alloc] init];
    contentViewStyle.lineHeightMultiple = 1;
    contentViewStyle.lineSpacing = 4.0f;
    contentViewStyle.paragraphSpacing = 3.0f;
    
    //format attribute string dict
    UIFont *contentFont = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:15.0f];
    
    NSDictionary *formatDict = @{
                                 NSFontAttributeName               : contentFont,
                                 NSParagraphStyleAttributeName     : contentViewStyle,
                                 NSForegroundColorAttributeName    : kNBR_ProjectColor_DeepBlack,
                                 };
    CGFloat contentH;
    if (_isDeatil) {
        contentH = 1000;
    }else
    {
        contentH = 100;
    }
   
    NSMutableAttributedString *attString =  [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:entity.title]];
    
    CGRect contentStringSize = [[attString string] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W - ( 10 * 3), contentH)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:formatDict
                                                                context:nil];
    
    UILabel *contentLable = [[UILabel alloc] initWithFrame:CGRectMake(avterImageView.frame.origin.x + 5, avterImageView.frame.origin.y + CGRectGetHeight(avterImageView.frame) + 10, contentStringSize.size.width, contentStringSize.size.height)];
    //图片
    NSInteger widthCount;
    CGSize singleImgSize = CGSizeZero;
    
    switch (entity.images.count)
    {
        case 1:
        {
            widthCount = 1;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 10 * 3) / 1.0f,
                                       (kNBR_SCREEN_W - 10 * 3) / 1.0f - 100);
        }
            break;
            
        case 2:
        case 4:
        {
            widthCount = 2;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 15 * 2) / 2.0f,
                                       (kNBR_SCREEN_W - 15 * 2) / 2.0f);
        }
            break;
            
        case 0:
        case 3:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        default:
        {
            widthCount = 3;
            singleImgSize = CGSizeMake((kNBR_SCREEN_W - 15 * 2) / 3.0f,
                                       (kNBR_SCREEN_W - 15 * 2) / 3.0f);
        }
            break;
    }
    
    NSInteger yIndex = entity.images.count > 9 ? 9 : entity.images.count;
    
    yIndex = yIndex % widthCount == 0 ? yIndex / widthCount : yIndex / widthCount + 1;
    
    
    //查看次数，点赞数量，回复数量
    UIView *bottonView = [[UIView alloc] initWithFrame:CGRectMake(nikeNameLable.frame.origin.x + 16,
                                                                  contentLable.frame.origin.y + contentLable.frame.size.height + (yIndex) * singleImgSize.height + (yIndex == 0 ? 0 : 10) + 5.5,
                                                                  kNBR_SCREEN_W - (15 * 2),
                                                                  16)];
    if ((((NSNull *)entity.address == [NSNull null]) || [entity.address isEqualToString:@""]) && _isDeatil){
        return  bottonView.frame.origin.y + 8;
    }else{
        return bottonView.frame.origin.y + CGRectGetHeight(bottonView.frame) + 8;
    }
}


- (void) tapSubImageView : (UIGestureRecognizer*) _gesture
{
    if (self.delegate)
    {
        [self.delegate takeTableViewCell:self tapSubImageViews:(UIImageView*)_gesture.view allSubImageViews:subImageViews];
    }
}


- (void) zanImageView : (UIGestureRecognizer*) _gesture
{
    [self sayDiggWithID];
}

//点赞
- (void) sayDiggWithID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [entity.digged intValue] == 1? GFKDAPI_ARTICLE_REDIGG: GFKDAPI_ARTICLE_DIGG;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId":  @([entity.dataDict[@"id"] integerValue])
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 0) {
                 if ([entity.digged intValue] == 1) {
                     entity.digged = 0;
                     NSInteger points = [entity.diggs integerValue];
                     _zanLogo.image = nozanImg;
                     _isZaned = NO;
                     entity.diggs = [NSNumber numberWithInteger:--points];
                 }else{
                     entity.digged = [NSNumber numberWithInteger:1];
                     NSInteger points = [entity.diggs integerValue];
                     _zanLogo.image = zanImg;
                     _isZaned = YES;
                     entity.diggs = [NSNumber numberWithInteger:++points];
                 }
                 if (self.delegate) {
                     [self.delegate takeTableViewCellWithZanCount:[entity.diggs intValue]];
                 }
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}

- (void) starImageView : (UIGestureRecognizer*) _gesture
{
    [self sayStarWithID];
}

//收藏
- (void) sayStarWithID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [entity.collected intValue]==1? GFKDAPI_ARTICLE_RECOLLECT: GFKDAPI_ARTICLE_COLLECT;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId": @([entity.dataDict[@"id"] integerValue])
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 0) {
                 if ([entity.collected intValue] == 1) {
                     entity.collected = 0;
                     _isStared = NO;
                     _starLogo.image = nostarImg;
                 }else{
                     _isStared = YES;
                     entity.collected = [NSNumber numberWithInteger:1];
                     _starLogo.image = starImg;
                 }
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}


@end
