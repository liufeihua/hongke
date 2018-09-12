//
//  UIImageView+TopTag.h
//  NeighborsApp
//
//  Created by Martin.Ren on 15/4/14.
//  Copyright (c) 2015年 Martin.Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(TopTag)

+ (UIView*) CreateTopTagNumberView : (NSString*) _tagString;

- (void) addTopTagNumberView : (NSString*) _tagString;

- (void) addTopTagNumberView : (NSString*) _tagString fixOrigin : (CGPoint) _point;

+ (UIView*) CreateAddButtonWithFrame : (CGRect) buttonFrame color : (UIColor*) _color;

@end
