//
//  AuditLogViewController.m
//  iosapp
//
//  Created by redmooc on 16/7/21.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditLogViewController.h"
#import "AuditLogTableViewCell.h"
#import "OSCAPI.h"

@interface AuditLogViewController ()

@end

static NSString *kAuditLogCellID = @"AduitLogCell";

@implementation AuditLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"审核流程";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.tableFooterView  = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UINib *nib = [UINib nibWithNibName:@"AuditLogTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kAuditLogCellID ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *cellDict;
    BOOL action = NO;
    if (indexPath.row == _boundDataSource.count) {
        action = YES;
        cellDict = _boundDataSource[indexPath.row-1];
    }else{
        cellDict = _boundDataSource[indexPath.row];
    }
    return [AuditLogTableViewCell heightForDataDict:cellDict isAction:action];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _boundDataSource.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *cellDict;
    BOOL action = NO;
    if (indexPath.row == _boundDataSource.count) {
        action = YES;
        cellDict = _boundDataSource[indexPath.row-1];
    }else{
        cellDict = _boundDataSource[indexPath.row];
    }
    
    AuditLogTableViewCell *cell = [[AuditLogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
    [cell setDateDict:cellDict isAction:action];
    
    return cell;
}


@end
