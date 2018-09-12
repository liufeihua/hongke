//
//  NewsDetailViewController.h
//  iosapp
//
//  Created by lfh on 15/11/4.
//  Copyright © 2015年 oschina. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NewsDetailBarViewController.h"
#import "GFKDObjsViewController.h"
#import "GFKDNewsDetail.h"
#import "GFKDNewsComment.h"

#import "NewsDetailAuditBarViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>
JSExportAs
(showTitlebar,
 - (void)showTitlebarWithStr:(NSString *)str
 );

JSExportAs
(hideTitlebar,
 - (void)hideTitlebarWithStr:(NSString *)str
 );

JSExportAs
(closeContent,
 - (void)closeContentWithStr:(NSString *)str
 );

JSExportAs
(openContent,
 - (void)openContentWithTitle:(NSString *)title withUrl:(NSString *)url withLinkType:(NSNumber *)linkType
 );

JSExportAs
(getToken,
 - (NSString *)getTokenWithStr:(NSString *)str
 );

JSExportAs
(getIMEI,
 - (NSString *)getIMEIWithStr:(NSString *)str
 );

JSExportAs
(getDeviceType,
 - (NSString *)getDeviceTypeWithStr:(NSString *)str
 );

JSExportAs
(getVerName,
 - (NSString *)getVerNameWithStr:(NSString *)str
 );

JSExportAs
(showToast,
 - (void)showToastWithTitle:(NSString *)title withContent:(NSString *)content
 );


@end

@interface NewsDetailViewController : UITableViewController<TestJSExport>

@property (nonatomic, weak) NewsDetailBarViewController *bottomBarVC;

@property (nonatomic, strong) NSMutableArray *commmentOjbs;

@property (nonatomic, strong) GFKDNewsDetail *newsDetailObj;
@property (nonatomic, strong) LastCell *lastCell;
@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;

@property (nonatomic, strong) UIWebView *newsWebView;
@property (nonatomic, copy)   NSString *HTML;

@property (nonatomic, assign) CGFloat font_scale;

- (instancetype)initWithNewsID:(int)newsID;

@property (nonatomic, copy) void (^didCommentSelected)(GFKDNewsComment *comment);
@property (nonatomic, copy) void (^didScroll)();


//@property (nonatomic, weak) NewsDetailAuditBarViewController *AuditbottomBarVC;

//- (void) getComment;
- (void) getCommentWithURL:(NSString *)allUrlstring;


@property (strong, nonatomic) JSContext *context;

@end
