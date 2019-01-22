//
//  ColumnViewController.m
//  Column
//
//  Created by fujin on 15/11/18.
//  Copyright © 2015年 fujin. All rights reserved.
//

#import "ColumnViewController.h"
#import "CoclumnCollectionViewCell.h"
#import "ColumnReusableView.h"
#import "Header.h"
#import "GFKDUserNode.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "SXTitleLable.h"

#define SPACE 10.0
static NSString *cellIdentifier = @"CoclumnCollectionViewCell";
static NSString *headOne = @"ColumnReusableViewOne";
static NSString *headTwo = @"ColumnReusableViewTwo";
@interface ColumnViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DeleteDelegate>

/**
 *  collectionView
 */
@property (nonatomic, strong)UICollectionView *collectionView;
/**
 *  Whether sort
 */
@property (nonatomic, assign)BOOL isSort;
/**
 * Whether hidden the last
 */
@property (nonatomic, assign)BOOL lastIsHidden;
/**
 *  animation label（insert）
 */
@property (nonatomic, strong)UILabel *animationLabel;
/**
 *  attributes of all cells
 */
@property (nonatomic, strong)NSMutableArray *cellAttributesArray;

@property (nonatomic, assign)BOOL isChange;

@end

@implementation ColumnViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.selectedArray = [[NSMutableArray alloc] init];
        self.optionalArray = [[NSMutableArray alloc] init];
        
        self.cellAttributesArray = [[NSMutableArray alloc] init];
        
        self.animationLabel = [[UILabel alloc] init];
        self.animationLabel.textAlignment = NSTextAlignmentCenter;
        self.animationLabel.font = [UIFont systemFontOfSize:15];
        self.animationLabel.numberOfLines = 1;
        self.animationLabel.adjustsFontSizeToFitWidth = YES;
        self.animationLabel.minimumScaleFactor = 0.1;
        self.animationLabel.textColor = RGBA(101, 101, 101, 1);
        self.animationLabel.layer.masksToBounds = YES;
        self.animationLabel.layer.borderColor = RGBA(211, 211, 211, 1).CGColor;
        self.animationLabel.layer.borderWidth = 0.45;
        self.isChange = NO;
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"所有栏目";
    
    [self setTitleAndCloseBtn];
    [self configCollection];
}

-(void)setTitleAndCloseBtn{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 64)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(kNBR_SCREEN_W - 35, 30, 25, 25);
    [closeButton setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeButton];
}

-(void)back:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----------------- collectionInscance ---------------------
-(void)configCollection{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-64) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[CoclumnCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[ColumnReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headOne];
    [self.collectionView registerClass:[ColumnReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headTwo];
    [self.collectionView reloadData];
}
#pragma mark ----------------- sort ---------------------
-(void)sortItem:(UIPanGestureRecognizer *)pan{
    CoclumnCollectionViewCell *cell = (CoclumnCollectionViewCell *)pan.view;
    NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];
    
    //开始  获取所有cell的attributes
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.cellAttributesArray removeAllObjects];
        for (NSInteger i = 0 ; i < self.selectedArray.count; i++) {
            [self.cellAttributesArray addObject:[self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }
    
    CGPoint point = [pan translationInView:self.collectionView];
    cell.center = CGPointMake(cell.center.x + point.x, cell.center.y + point.y);
    [pan setTranslation:CGPointMake(0, 0) inView:self.collectionView];
    
    //进行是否排序操作
    BOOL ischange = NO;
    for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
        CGRect rect = CGRectMake(attributes.center.x - 6, attributes.center.y - 6, 12, 12);
        if (CGRectContainsPoint(rect, CGPointMake(pan.view.center.x, pan.view.center.y)) & (cellIndexPath != attributes.indexPath)) {
            
            //后面跟前面交换
            if (cellIndexPath.row > attributes.indexPath.row) {
                //交替操作0 1 2 3 变成（3<->2 3<->1 3<->0）
                for (NSInteger index = cellIndexPath.row; index > attributes.indexPath.row; index -- ) {
                    [self.selectedArray exchangeObjectAtIndex:index withObjectAtIndex:index - 1];
                }
            }
            //前面跟后面交换
            else{
                //交替操作0 1 2 3 变成（0<->1 0<->2 0<->3）
                for (NSInteger index = cellIndexPath.row; index < attributes.indexPath.row; index ++ ) {
                    [self.selectedArray exchangeObjectAtIndex:index withObjectAtIndex:index + 1];
                }
            }
            ischange = YES;
            self.isChange = YES;
            [self.collectionView moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
        }
        else{
            ischange = NO;
        }
    }
    
    //结束
    if (pan.state == UIGestureRecognizerStateEnded){
        if (ischange) {
            self.isChange = YES;
        }
        else{
            cell.center = [self.collectionView layoutAttributesForItemAtIndexPath:cellIndexPath].center;
        }
    }
}

#pragma mark ----------------- delete ---------------------
-(void)deleteItemWithIndexPath:(NSIndexPath *)indexPath{
    //数据整理
    self.isChange = YES;
    [self.optionalArray insertObject:[self.selectedArray objectAtIndex:indexPath.row] atIndex:0];
    [self.selectedArray removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
//    [self.parentView.controllers removeObjectAtIndex:indexPath.row];
//    if (self.parentView.bigScrollView.subviews.count > indexPath.row) {
//        UIView *subView = self.parentView.bigScrollView.subviews[indexPath.row];
//        [subView removeFromSuperview];
//    }
//    SXTitleLable *subTitleView = self.parentView.smallScrollView.subviews[indexPath.row];
//    [subTitleView removeFromSuperview];
    
    //删除之后更新collectionView上对应cell的indexPath
    for (NSInteger i = 0; i < self.selectedArray.count; i++) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CoclumnCollectionViewCell *cell = (CoclumnCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];
        cell.indexPath = newIndexPath;
    }
    
}
#pragma mark ----------------- insert ---------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        self.isChange = YES;
        self.lastIsHidden = YES;
        
        CoclumnCollectionViewCell *endCell = (CoclumnCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        endCell.contentLabel.hidden = YES;
        
        [self.selectedArray addObject:[self.optionalArray objectAtIndex:indexPath.row]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
        //移动开始的attributes
        UICollectionViewLayoutAttributes *startAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        
        self.animationLabel.frame = CGRectMake(startAttributes.frame.origin.x, startAttributes.frame.origin.y, startAttributes.frame.size.width , startAttributes.frame.size.height);
        self.animationLabel.layer.cornerRadius = CGRectGetHeight(self.animationLabel.bounds) * 0.5;
        GFKDUserNode *nodeModel = [[GFKDUserNode alloc] initWithDict:[self.optionalArray objectAtIndex:indexPath.row]];
        self.animationLabel.text = nodeModel.cateName;
        //self.animationLabel.text = [self.optionalArray objectAtIndex:indexPath.row];
        [self.collectionView addSubview:self.animationLabel];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:self.selectedArray.count-1 inSection:0];
        
        //移动终点的attributes
        UICollectionViewLayoutAttributes *endAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:toIndexPath];
        
        typeof(self) __weak weakSelf = self;
        //移动动画
        [UIView animateWithDuration:0.7 animations:^{
            weakSelf.animationLabel.center = endAttributes.center;
            [weakSelf.animationLabel removeFromSuperview];
        } completion:^(BOOL finished) {
            //展示最后一个cell的contentLabel
            CoclumnCollectionViewCell *endCell = (CoclumnCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:toIndexPath];
            endCell.contentLabel.hidden = NO;
            
            weakSelf.lastIsHidden = NO;
            //[weakSelf.animationLabel removeFromSuperview];
            [weakSelf.optionalArray removeObjectAtIndex:indexPath.row];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        
    }
}

#pragma mark ----------------- item(样式) ---------------------
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_SIZE.width - (5*SPACE)) / 4.0, 30);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(SPACE, SPACE, SPACE, SPACE);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return SPACE;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return SPACE;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(SCREEN_SIZE.width, 40.0);
    }
    else{
        return CGSizeMake(SCREEN_SIZE.width, 30.0);
    }
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return  CGSizeMake(SCREEN_SIZE.width, 0.0);
}

#pragma mark ----------------- collectionView(datasouce) ---------------------

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.isSort) {
        return 1;
    }
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.selectedArray.count;
    }
    else{
        return self.optionalArray.count;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ColumnReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        if (indexPath.section == 0) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headOne forIndexPath:indexPath];
            reusableView.buttonHidden = NO;
            reusableView.clickButton.selected = self.isSort;
            reusableView.backgroundColor = [UIColor whiteColor];
            typeof(self) __weak weakSelf = self;
            [reusableView clickWithBlock:^(ButtonState state) {
                //排序删除
                if (state == StateSortDelete) {
                    weakSelf.isSort = YES;
                }
                //完成
                else{
                    weakSelf.isSort = NO;
                    if (weakSelf.cellAttributesArray.count) {
                        for (UICollectionViewLayoutAttributes *attributes in weakSelf.cellAttributesArray) {
                            CoclumnCollectionViewCell *cell = (CoclumnCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:attributes.indexPath];
                            for (UIPanGestureRecognizer *pan in cell.gestureRecognizers) {
                                [cell removeGestureRecognizer:pan];
                            }
                        }
                    }
                }
                [weakSelf.collectionView reloadData];
            }];
            reusableView.titleLabel.text = @"已选栏目";
            
        }else{
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headTwo forIndexPath:indexPath];
            reusableView.buttonHidden = YES;
            reusableView.backgroundColor = RGBA(240, 240, 240, 1);
            reusableView.titleLabel.text = @"点击添加更多栏目";
        }
    }
    return (UICollectionReusableView *)reusableView;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CoclumnCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [cell configCell:self.selectedArray withIndexPath:indexPath];
        GFKDUserNode *nodeModel = [[GFKDUserNode alloc] initWithDict:self.selectedArray[indexPath.row]];
        if ([nodeModel.isfixed intValue] == 1){
        //if (indexPath.row == 0) {
           cell.deleteButton.hidden = YES;
        }else{
           cell.deleteDelegate = self;
           cell.deleteButton.hidden = !self.isSort;
            if (self.isSort) {
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sortItem:)];
                [cell addGestureRecognizer:pan];
            }
            else{
                
            }
            //最后一位是否影藏(为了动画效果)
            if (indexPath.row == self.selectedArray.count - 1) {
                cell.contentLabel.hidden = self.lastIsHidden;
            }
        }
        
    }else{
        [cell configCell:self.optionalArray withIndexPath:indexPath];
        cell.deleteButton.hidden = YES;
    }
    return cell;
}
-(void)dealloc{
    NSLog(@"dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (self.isChange) {
        [self getNotUserNodes];
    }
    
}
//更新订制的栏目
-(void) getNotUserNodes{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"栏目更新中";
    NSString *nodeIds = @"";
    for (int i = 1; i<self.selectedArray.count; i++) {
        GFKDUserNode *node = [[GFKDUserNode alloc] initWithDict:self.selectedArray[i]];
        nodeIds = [nodeIds stringByAppendingString:[node.cateId stringValue]];
        if (i!=self.selectedArray.count-1) {
            nodeIds = [nodeIds stringByAppendingString:@","];
        }
    }
    //NSLog(@"nodeIds:%@",nodeIds);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_UPDATEUSERNODE]
      parameters:@{@"token":[Config getToken],
                   @"nodeIds":nodeIds,
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             [self.delegate updateNodes:self.selectedArray];
             
             [HUD hide:YES afterDelay:1];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，更新用户订制栏目失败！";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

@end
