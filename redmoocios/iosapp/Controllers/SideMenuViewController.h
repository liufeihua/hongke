//
//  SideMenuViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 1/31/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UITableViewController

@property (nonatomic, assign) int badgeValue;
@property (nonatomic, assign) int hasAuditInfo;

@property (nonatomic, assign) int AuditInfoBadge;
- (void) getBadgeNum;
- (void) getisAuditpermiss;

- (void)reload;

@end
