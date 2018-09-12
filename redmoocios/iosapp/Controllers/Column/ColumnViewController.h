//
//  ColumnViewController.h
//  Column
//
//  Created by fujin on 15/11/18.
//  Copyright © 2015年 fujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SXMainViewController.h"

@protocol ColumnViewControllerDelegate

- (void) updateNodes:(NSMutableArray *)selectColumns;

@end

@interface ColumnViewController : UIViewController
/**
 *  已选的数据
 */
@property (nonatomic, strong)NSMutableArray *selectedArray;
/**
 *  可选的数据
 */
@property (nonatomic, strong)NSMutableArray *optionalArray;

@property (nonatomic, assign) id  <ColumnViewControllerDelegate> delegate;

@property (nonatomic, strong)SXMainViewController *parentView;
@end
