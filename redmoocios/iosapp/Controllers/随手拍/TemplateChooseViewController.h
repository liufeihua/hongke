//
//  TemplateChooseViewController.h
//  iosapp
//
//  Created by redmooc on 2018/11/9.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateChooseViewController : UIViewController

@property (nonatomic, copy) NSString *imgsStr;
@property (nonatomic, copy) NSString *titleStr;

-(instancetype)initWithImgs:(NSString *)imgs WithTitle:(NSString *)title;

@property (nonatomic, assign) UIViewController *addPhotoVC;

@end
