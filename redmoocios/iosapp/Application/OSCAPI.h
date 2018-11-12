//
//  OSCAPI.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#ifndef iosapp_OSCAPI_h
#define iosapp_OSCAPI_h

//#define GFKDAPI_HTTPS_PREFIX             @"https://mapi.nudt.edu.cn"
//#define GFKDAPI_PREFIX                   @"http://mapi.nudt.edu.cn"

#define GFKDAPI_HTTPS_PREFIX             @"http://172.20.201.103:8080/app.center"
#define GFKDAPI_PREFIX                   @"http://172.20.201.103:8080/app.center"

//#define GFKDAPI_HTTPS_PREFIX             @"http://172.16.128.83:8080/"
//#define GFKDAPI_PREFIX                   @"http://172.16.128.83:8080/"

//#define GFKDAPI_HTTPS_PREFIX             @"http://192.168.1.159:8080"
//#define GFKDAPI_PREFIX                   @"http://192.168.1.159:8080"

//#define GFKDAPI_HTTPS_PREFIX             @"http://192.168.1.116/moocms_school"
//#define GFKDAPI_PREFIX                   @"http://192.168.1.116/moocms_school"


#define GFKDAPI_LOGIN_VALIDATE           @"/m-token.htx"
#define GFKDAPI_TOP_LIST                 @"/m-topNode.htx"
#define GFKDAPI_NEWS_LIST                @"/m-articlePage.htx"
//#define GFKDAPI_HOMENEWS_LIST            @"/m-home-resourcePage.htx" //首页
#define GFKDAPI_HOMENEWS_LIST            @"/m-articlePage.htx"
#define GFKDAPI_NEWS_DETAIL              @"/m-article.htx"
#define GFKDAPI_NEWS_COMMENT             @"/m-article-commentPage.htx"  //文章评论分页
#define GFKDAPI_NEWS_SPECIAL             @"/m-specialPage.htx"
#define GFKDAPI_NEWS_SENDCOMMENT         @"/m-article-comment.htx"
#define GFKDAPI_USER_PHOTO               @"/m-uploadPhoto.htx"
#define GFKDAPI_USER_CLEARTOKEN          @"/m-clearToken.htx"
#define GFKDAPI_FEEDBCK                  @"/m-feedback.htx"  //意见反馈
#define GFKDAPI_SNSLOG                  @"/m-snsOpLogPage.htx"  //SNS发现
#define GFKDAPI_SNSLOG                  @"/m-snsOpLogPage.htx"  //SNS发现
#define GFKDAPI_MSG_COUNT                @"/m-unRead-Count.htx"  //消息中心  数目
#define GFKDAPI_MSG_PAGE                 @"/m-unRead-Page.htx"   //消息中心  内容
#define GFKDAPI_NEWS_SEARCH               @"/m-fulltext-page.htx"  //全文检索

#define GFKDAPI_ARTICLE_DIGG               @"/m-article-diggs.htx"  //文章点赞
#define GFKDAPI_ARTICLE_REDIGG               @"/m-article-reDiggs.htx"  //取消文章点赞
#define GFKDAPI_ARTICLE_COLLECT            @"/m-article-collect.htx"//文章收藏
#define GFKDAPI_ARTICLE_RECOLLECT           @"/m-article-reCollect.htx"//文章取消收藏

#define GFKDAPI_LAUNCH                    @"/m-ad.htx"//启动页面
#define GFKDAPI_SEND_DEVICETOKEN           @"/m-iostoken.htx"//向服务器发送deviceToken

#define GFKDAPI_UPDATEUSER                    @"/m-updateUser.htx"//修改个人信息
#define GFKDAPI_CHANGEPASSWORD                 @"/m-changePassword.htx"//修改密码
#define GFKDAPI_COMMENTLIST                  @"/m-user-commentPage.htx"//我的评论列表
#define GFKDAPI_COLLECTLIST                  @"/m-collectPage.htx"//我的收藏列表
#define GFKDAPI_READPOINTS                  @"/m-readPoints.htx" //阅读文章增加积分
#define GFKDAPI_MYPOINTS                  @"/m-points.htx" //读取我的积分
#define GFKDAPI_AUDITPERMISS                  @"/m-auditpermiss.htx"  //用户是否有审核权限
#define GFKDAPI_NEWS_AUDITINFO             @"/m-auditInfoPage.htx"  //待审稿件
#define GFKDAPI_AUDITINFO                 @"/m-auditInfo.htx"  //审核稿件
#define GFKDAPI_POINTSRULES                 @"/m-pointsRules.htx"  //读取积分规则
#define GFKDAPI_LEVELPOINTS                 @"/m-levelInfo.htx"  //获取积分等级信息

#define GFKDAPI_PAGEREADILYTAKE             @"/m-pageReadilyTake.htx"  //随手拍列表
#define GFKDAPI_GETREADILYTAKE              @"/m-getReadilyTake.htx"  //根据ID获取随手拍列表
#define GFKDAPI_DELREADILYTAKE             @"/m-delReadilyTake.htx"  //删除拍列表
#define GFKDAPI_ADDREADILYTAKE              @"/m-addReadilyTake.htx"  //添加拍列表

#define GFKDAPI_COMMENTPAGE               @"/m-commentPage.htx"  //所有评论动态

#define GFKDAPI_AUDITLOG                 @"/m-viewlog.htx"  //稿件流程  infoId=460&token=
#define GFKDAPI_DELETECOMMENT             @"/m-deletecomment.htx"  //删除评论id=222&token=

#define GFKDAPI_GETUSERINFO             @"/m-personInfo.htx"  //得到用户信息 uid=7&token=…

#define GFKDAPI_MYALLNODES             @"/m-allNodes.htx"    //所有栏目 包括已订制和未订制的 改为 用户订制的栏目
#define GFKDAPI_MYUSERNODES             @"/m-userNodes.htx"  //用户订制的栏目
#define GFKDAPI_MYNOTUSERNODES             @"/m-notUserNodes.htx" //用户没有订制的栏目
#define GFKDAPI_UPDATEUSERNODE             @"/m-updateUserNode.htx"   //更新用户订制栏目 token=...&nodeIds=...

#define GFKDAPI_DISCOVER                 @"/m-discover.htx"   //发现栏目 token=...

#define GFKDAPI_COMMENTS_UNREAD           @"/m-comments-unread.htx" //获取评论未读数
#define GFKDAPI_COMMENTS_CLEAR           @"/m-comments-clear.htx" //清除评论未读数
#define GFKDAPI_ISTOEND                  @"/m-istoend.htx"   //判断是否有终审权限
#define GFKDAPI_TOEND                    @"/m-toend.htx"   //文章终审

#define GFKDAPI_DELARTICLE              @"/m-deleteArticle.htx"  //删除文章

#define GFKDAPI_GETANONYMOUSTOKEN         @"/m-anonymous-token.htx"  //匿名用户

#define GFKDAPI_LISTAD                   @"/m-listAd.htx"  //轮播图

#define GFKDAPI_MESSAGEPAGE              @"/m-message-page.htx"  //消息中心

#define GFKDAPI_PHOTOVIEW                @"/m-photoView.htx"   //预览时光相册
#define GFKDAPI_UPLOADPREVIEW            @"/m-uploadPreview.htx"  //上传时光相册图片
#define GFKDAPI_PUBLISHTIMEPHOTO         @"/m-publishTimePhoto.htx"  //发布时光相册图片


#define HTML_ERWEIMA                     @"https://mapp.nudt.edu.cn/widget/getQrcode"
#define GFKDAPI_PAGESIZE                 @"pageSize=10"
#define GFKD_PAGESIZE    10

#define ITOS(i) ([NSString stringWithFormat:@"%ld", i])

#define kNBR_TABLEVIEW_CELL_NOIDENTIFIER @"NBR_TABLEVIEW_CELL_NOIDENTIFIER"

//相对iphone6 屏幕比
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f
#define kNBR_SCREEN_W [UIScreen mainScreen].bounds.size.width
#define kNBR_SCREEN_H [UIScreen mainScreen].bounds.size.height
#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)

//转换16进制颜色
#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define kNBR_DEFAULT_FONT_NAME       @"Helvetica"
#define kNBR_DEFAULT_FONT_NAME_BLOD  @"Helvetica-Bold"

//白色
#define kNBR_ProjectColor_StandWhite      UIColorFromRGB(0xFFFFFF)

//标准蓝
#define kNBR_ProjectColor_StandBlue       UIColorFromRGB(0x861917)

//背景灰
#define kNBR_ProjectColor_BackGroundGray  UIColorFromRGB(0xF2F3F7)

//浅灰
#define kNBR_ProjectColor_LightGray       UIColorFromRGB(0xE5E5E5)

//边线浅灰
#define kNBR_ProjectColor_LineLightGray   UIColorFromRGB(0xD1D1D1)

//中灰
#define kNBR_ProjectColor_MidGray         UIColorFromRGB(0x999999)

//深灰
#define kNBR_ProjectColor_DeepGray        UIColorFromRGB(0x535353)

//深黑
#define kNBR_ProjectColor_DeepBlack       UIColorFromRGB(0x2E2E2E)

//标准红
#define kNBR_ProjectColor_StandRed        UIColorFromRGB(0xFB4747)

//标准绿
#define kNBR_ProjectColor_StandGreen      UIColorFromRGB(0x8ECD4B)

//标准青
#define kNBR_ProjectColor_StandGreen2     UIColorFromRGB(0x77D0DE)

//标配青
#define kNBR_ProjectColor_GenerallyGreen  UIColorFromRGB(0x7FC6C8)

//标配红
#define kNBR_ProjectColor_GenerallyRed    UIColorFromRGB(0x95ADCD)

//标配蓝
#define kNBR_ProjectColor_GenerallyBlue   UIColorFromRGB(0x95ADCD)

//系统默认主题色
#define kNBR_ProjectColor   UIColorFromRGB(0x861917)   //UIColorFromRGB(0x15A230)

#define NSNotificationCenter_appWillEnterForeground         @"NSNotificationCenter_appWillEnterForeground"


#endif
