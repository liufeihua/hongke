//
//  HomeAdCell.m
//  OneYuan
//
//  Created by Peter Jin (https://github.com/JxbSir) on  15/2/19.
//  Copyright (c) 2015年 PeterJin.   Email:i@jxb.name      All rights reserved.
//

#import "HomeAdCell.h"
#import "JxbAdPageView.h"
#import "OSCAPI.h"
#import "GFKDHomeAd.h"

@interface HomeAdCell ()<JxbAdPageViewDelegate>
{
    __weak id<HomeAdCellDelegate> delegate;
    JxbAdPageView      *adPage;
    __block  NSArray            *adArr;
}

@end

@implementation HomeAdCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        adPage = [[JxbAdPageView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 9*kNBR_SCREEN_W/16)];
      // adPage = [[JxbAdPageView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 160*KWidth_Scale)];
        adPage.delegate = self;
        [self addSubview:adPage];

    }
    return self;
}

- (void)getAds:(NSArray *)objectsDict
{
//    [HomeModel getAds:^(AFHTTPRequestOperation* operation,NSObject* result){
//        HomeAdList* ads = [[HomeAdList alloc] initWithDictionary:(NSDictionary*)result];
//        adArr = ads.Rows;
//        NSMutableArray* arrNames = [NSMutableArray array];
//        for (HomeAd* ad in ads.Rows) {
//            [arrNames addObject:ad.src];
//        }
//        if([OyTool ShardInstance].bIsForReview)
//        {
//            [adPage setAds:@[@"http://img.1yyg.com/Poster/20140918182340689.jpg"]];
//        }
//        else
//            [adPage setAds:arrNames];
//    } failure:^(NSError* error){
//        //[[XBToastManager ShardInstance] showtoast:[NSString stringWithFormat:@"获取首页顶部异常：%@",error]];
//    }];

    
//    NSMutableArray* arrNames = [NSMutableArray array];
//    for (NSDictionary *objectDict in objectsDict) {
//        GFKDHomeAd *adv = [[GFKDHomeAd alloc] initWithDict:objectDict];
//        [arrNames addObject:adv.imgUrl];
//        
//    }
//    [adPage setAds:arrNames];
    adArr = objectsDict;
    [adPage setAds:objectsDict];
    
}

- (void)click:(int)index
{
    if(delegate)
    {
        GFKDHomeAd* ad = [[GFKDHomeAd alloc] initWithDict:[adArr objectAtIndex:index]];
        //GFKDHomeAd* ad = [adArr objectAtIndex:index];
        [delegate adClick:ad];
    }
}
@end
