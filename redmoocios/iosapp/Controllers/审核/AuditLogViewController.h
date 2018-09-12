//
//  AuditLogViewController.h
//  iosapp
//
//  Created by redmooc on 16/7/21.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuditLogViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)   UITableView *tableView;

@property (nonatomic, copy)  NSMutableArray  *boundDataSource;

@end
