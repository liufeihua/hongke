//
//  HomeAdCell.h
//  OneYuan
//
//  Created by Peter Jin (https://github.com/JxbSir) on  15/2/19.
//  Copyright (c) 2015年 PeterJin.   Email:i@jxb.name      All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDHomeAd.h"

@protocol HomeAdCellDelegate
- (void)adClick:(GFKDHomeAd*)adv;
@end

@interface HomeAdCell : UITableViewCell
@property(nonatomic,weak)id<HomeAdCellDelegate> delegate;
- (void)getAds:(NSArray *)objectsDict;
@end
