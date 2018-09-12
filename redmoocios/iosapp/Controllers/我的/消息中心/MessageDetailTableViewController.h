//
//  MessageDetailTableViewController.h
//  iosapp
//
//  Created by redmooc on 16/12/5.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDMessage.h"

@interface MessageDetailTableViewController : UITableViewController

- (instancetype)initWitHMessage:(GFKDMessage *)message;

@end
