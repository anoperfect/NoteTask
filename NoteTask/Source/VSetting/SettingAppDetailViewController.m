//
//  SettingAppDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/12/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "SettingAppDetailViewController.h"






@interface SettingAppDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingAppDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"关于NoteTask";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 200)];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppDetailIcon"]];
    icon.frame = CGRectMake((tableView.frame.size.width - 100) / 2, 50, 100, 100);
    [view addSubview:icon];
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"版本";
        cell.detailTextLabel.text = @"1.0";
    }
    else if(indexPath.row == 1) {
        cell.textLabel.text = @"意见";
        cell.detailTextLabel.text = @"Ben.ZhaoBin@qq.com";
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end





