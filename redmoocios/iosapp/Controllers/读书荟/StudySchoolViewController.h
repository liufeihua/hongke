//
//  StudySchoolViewController.h
//  iosapp
//  基本类 实现有子栏目页面
//  Created by redmooc on 2018/10/16.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudySchoolViewController : UIViewController

- (instancetype)initWithNumber:(NSString *)number WithNav:(BOOL) isShowNav;

- (instancetype)initWithParentId:(NSNumber *)parentId WithNav:(BOOL) isShowNav;

//- (instancetype)initWithArray:(NSArray *)array;

@end
