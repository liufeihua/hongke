//
//  NewShowViewCell.h
//  DouYU
//
//  Created by Alesary on 15/11/2.
//  Copyright © 2015年 Alesary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDDiscover.h"

@protocol NewShowViewCellDelegate
- (void) NewShowViewCellWithModel:(GFKDDiscover*) model;

@end

@interface NewShowViewCell : UITableViewCell

@property (nonatomic, assign) id<NewShowViewCellDelegate> delegate;

-(void)setContentView:(NSArray *)array;


@end
