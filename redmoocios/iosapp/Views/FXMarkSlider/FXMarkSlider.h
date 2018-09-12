//
//  FXMarkSlider.h
//  FXMarkSlider
//
//  Created by ftxbird on 15-3-4.
//  Copyright (c) 2015年 e. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FXMarkSlider;

@protocol FXMarkSliderDelegate <NSObject>
/**
 *  单击手势选择值
 */
- (void)FXSliderTapGestureValue:(CGFloat)selectValue;
@end

@interface FXMarkSlider : UISlider
@property (nonatomic) NSArray *markPositions;
@property (nonatomic) CGFloat currentValue;
@property (nonatomic, weak) id <FXMarkSliderDelegate> delegate;
@end
