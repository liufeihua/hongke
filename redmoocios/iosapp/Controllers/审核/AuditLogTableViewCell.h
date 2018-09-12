//
//  AuditLogTableViewCell.h
//  iosapp
//
//  Created by redmooc on 16/7/21.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuditLogTableViewCell : UITableViewCell

- (void) setDateDict : (NSDictionary*) _dataDict isAction : (BOOL) isAction;

+ (CGFloat) heightForDataDict : (NSDictionary *) _dataDict isAction : (BOOL) isAction;

@end
