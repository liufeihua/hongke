//
//  CommentsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "GFKDNewsComment.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "IQKeyBoardManager.h"
#import "ReplyCommentCell.h"


static NSString *kCommentCellID = @"CommentCell";


@interface CommentsViewController ()
{
    BOOL _wasKeyboardManagerEnabled; //系统IQKeyboardManager不可用
}

@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsViewController


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
}

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super init];
    
    if (self) {
        _objectID = objectID;
        _commentType = commentType;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            
            return [NSString stringWithFormat:@"%@%@?articleId=%lld&pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,objectID,(long)page,GFKDAPI_PAGESIZE,[Config getToken]];
        };
        self.objClass = [GFKDNewsComment class];
        self.needAutoRefresh = NO;
    }
    
    return self;
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    return dict[@"result"];
}



- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.lastCell.emptyMessage = @"暂无评论";
    
//    NSLog(@"h1:%f",self.tableView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDNewsComment *comment = self.objects[row];
    
    if ([comment.ftype  isEqual: @"Info"]) {
        
        CommentCell *cell = [CommentCell new];
        [self setBlockForCommentCell:cell];
        [cell setContentWithComment:comment];
        cell.contentLabel.textColor = [UIColor contentTextColor];
        cell.portrait.tag = row; cell.authorLabel.tag = row;
        [cell.portrait enableAvatarModeWithUserInfoDict:[comment.creatorid intValue] pushedView:self];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        return cell;
    }else  if ([comment.ftype  isEqual: @"Comment"]) {
        ReplyCommentCell *cell = [ReplyCommentCell new];
        
        [cell setContentWithComment:comment];
        //cell.contentLabel.textColor = [UIColor contentTextColor];
        cell.authorLabel.tag = row;
        //[cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDNewsComment *comment = self.objects[indexPath.row];
    
    if (comment.cellHeight) {return comment.cellHeight;}
    
    if ([comment.ftype  isEqual: @"Info"]) {
        NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.text]];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont boldSystemFontOfSize:15];
        [label setAttributedText:contentString];
        __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
        
        comment.cellHeight = height + 61;
    }else  if ([comment.ftype  isEqual: @"Comment"])
    {
        NSString * contStr = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.creator,comment.fromUser,comment.text];
        NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:contStr]];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont boldSystemFontOfSize:15];
        [label setAttributedText:contentString];
        __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
        
        comment.cellHeight = height + 10;
    }
    
    return comment.cellHeight;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDNewsComment *comment = self.objects[indexPath.row];
    
    if (self.didCommentSelected) {
        self.didCommentSelected(comment);
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// 参考 http://stackoverflow.com/questions/12290828/how-to-show-a-custom-uimenuitem-for-a-uitableviewcell

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}


- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            return YES;
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        //删除评论
    };
}



#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && self.didScroll) {
        self.didScroll();
    }
}




#pragma mark - 跳转到用户详情页

- (void)pushDetailsView:(UITapGestureRecognizer *)tapGesture
{
//    OSCComment *comment = self.objects[tapGesture.view.tag];
//    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:comment.authorID];
//    [self.navigationController pushViewController:userDetailsVC animated:YES];
}



@end
