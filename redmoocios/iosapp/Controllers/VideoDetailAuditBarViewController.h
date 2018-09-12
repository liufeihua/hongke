//
//  VideoDetailAuditBarViewController.h
//  iosapp
//
//  Created by redmooc on 16/5/18.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditInfoBottomBarViewController.h"

//@protocol VideoDetailAuditBarViewControllerDelegate <NSObject>
//
//@optional
//
//- (void) UpdateIndex;
//
//@end

@interface VideoDetailAuditBarViewController : AuditInfoBottomBarViewController

- (instancetype)initWithNewsID:(int)newsID;

//@property (nonatomic,assign) id<VideoDetailAuditBarViewControllerDelegate> delegate;

@end
