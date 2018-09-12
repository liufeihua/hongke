//
//  AuditInfoBottomBarViewController.h
//  iosapp
//
//  Created by redmooc on 16/5/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDNews.h"

@protocol NewsDetailAuditBarViewControllerDelegate <NSObject>
@optional

- (void) UpdateIndex;

@end

@interface AuditInfoBottomBarViewController : UIViewController

@property (nonatomic, strong) NSLayoutConstraint *editingBarYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *editingBarHeightConstraint;

@property (nonatomic, strong) UIView *viewBar;

@property (nonatomic, strong) UIButton *passBtn; //审核通过
@property (nonatomic, strong) UIButton *refuseBtn; //拒绝
@property (nonatomic, strong) UIButton *showProcessBtn; //查看流程

@property (nonatomic, copy) void (^chickAuditInfoPass)();
@property (nonatomic, copy) void (^chickAuditInfoRefuse)();
@property (nonatomic, copy) void (^chickAuditInfoShowProcess)();

//@property (nonatomic, assign) NSNumber *infoLevel; //1：校内 2：校外
@property (nonatomic, assign) int newsID;
@property (nonatomic, assign) BOOL isToEnd;

@property (nonatomic, assign) int type;//1：待审；2：退稿；3：已审核

@property (nonatomic, assign) GFKDNews *news;

@property (nonatomic,assign) id<NewsDetailAuditBarViewControllerDelegate> delegate;

@end
