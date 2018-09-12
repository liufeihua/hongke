//
//  FXMarkSlider.m
//  FXMarkSlider
//
//  Created by ftxbird on 15-3-4.
//  Copyright (c) 2015年 e. All rights reserved.
//

#import "FXMarkSlider.h"
@interface FXMarkSlider ()<UIGestureRecognizerDelegate>
@property (nonatomic) CGFloat StripWidth;

@end

@implementation FXMarkSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.continuous = NO;
    }
    return self;
}


-(void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    CGFloat curruentX  =round(point.x/self.StripWidth);
    self.value = curruentX;
    self.currentValue = curruentX;
    if (self.delegate && [self.delegate respondsToSelector:@selector(FXSliderTapGestureValue:)])
    {
        [self.delegate FXSliderTapGestureValue:curruentX];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self];
        CGFloat curruentX  =round(touchPoint.x/self.StripWidth);
        if (self.delegate && [self.delegate respondsToSelector:@selector(FXSliderTapGestureValue:)])
        {
            [self.delegate FXSliderTapGestureValue:curruentX];
            [self setValue:curruentX animated:NO];
            break;
        }
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self];
        NSInteger currentValue =fabs(round((touchPoint.x/self.StripWidth -0.3)));
        if ((currentValue<self.minimumValue) ||(currentValue>self.maximumValue)||(currentValue == self.value)) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(FXSliderTapGestureValue:)])
        {
            [self.delegate FXSliderTapGestureValue:currentValue];
            [self setValue:currentValue animated:NO];
            break;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //self.value = 0;
    self.value = self.currentValue;
    // 绘制一个区域画直线
    CGRect innerRect = CGRectInset(rect, 0.0, 5.0);
    //选择区域
    UIGraphicsBeginImageContextWithOptions(innerRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线宽度
    CGContextSetLineWidth(context, 0.5);
    //起点
    CGContextMoveToPoint(context, 10, CGRectGetHeight(innerRect)/2);
    //终点
    CGContextAddLineToPoint(context, innerRect.size.width-10, CGRectGetHeight(innerRect)/2);
    //颜色
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.200 alpha:1.000] CGColor]);
    //连接
    CGContextStrokePath(context);
    //生成图片
    UIImage *selectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    // 绘制刻度线
    [selectedSide drawAtPoint:CGPointMake(0,0)];
    
    self.StripWidth = (innerRect.size.width -20)/ self.markPositions.count;
    //中间刻度和 首尾刻度
    for (int i = 0; i < [self.markPositions count]+2; i++) {
        //刻度的宽度
        CGContextSetLineWidth(context, 0.5);
        //遍历的每个起点 0 1 2 3 4 5
        float position = 10 + i * self.StripWidth;
        NSLog(@"起点%f",position);
        //绘制竖直刻度线
        CGContextMoveToPoint(context, position, CGRectGetHeight(innerRect)/2 - 5);
        CGContextAddLineToPoint(context, position, CGRectGetHeight(innerRect)/2 + 5);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.200 alpha:1.000] CGColor]);
        CGContextStrokePath(context);
    }
    //完成
    UIImage *selectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    UIGraphicsEndImageContext();
    
    //设置控件 选择和未选择视图 一致
    [self setMinimumTrackImage:selectedStripSide forState:UIControlStateNormal];
    [self setMaximumTrackImage:selectedStripSide forState:UIControlStateNormal];
    
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
}

@end
