//
//  reader-head.h
//  iosapp
//
//  Created by redmooc on 16/11/8.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#ifndef reader_head_h
#define reader_head_h

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#define RGB(R, G, B)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define TopSpacing 40.0f
#define BottomSpacing 40.0f
#define LeftSpacing 20.0f
#define RightSpacing  20.0f
#define DELAYEXECUTE(delayTime,func) (dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{func;}))
#define DistanceFromTopGuiden(view) (view.frame.origin.y + view.frame.size.height)
#define DistanceFromLeftGuiden(view) (view.frame.origin.x + view.frame.size.width)
#define ViewOrigin(view)   (view.frame.origin)
#define ViewSize(view)  (view.frame.size)
#define ScreenSize [UIScreen mainScreen].bounds.size
#import "LSYReadUtilites.h"
#import "LSYReadModel.h"
#import "LSYReadParser.h"

#define LSYNoteNotification @"LSYNoteNotification"
#define LSYThemeNotification @"LSYThemeNotification"
#define LSYEditingNotification @"LSYEditingNotification"
#define LSYEndEditNotification @"LSYEndEditNotification"

#define MinFontSize 11.0f
#define MaxFontSize 20.0f

#endif

#endif /* reader_head_h */
