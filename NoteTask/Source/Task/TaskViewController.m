//
//  TaskViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskModel.h"
#import "TaskInfoManager.h"
#import "TaskRecord.h"
#import "TaskCell.h"
#import "AppConfig.h"
#import "TaskDetailViewController.h"


@interface TaskViewController () <UITableViewDelegate, UITableViewDataSource
                                    >

@property (nonatomic, strong) UITableView *tasksView;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*,NSNumber*> *taskCellOptumizeHeights;



@property (nonatomic, assign) BOOL dayMode;

@property (nonatomic, strong) TaskInfoManager *taskInfoManager;

@property (nonatomic, strong) NSIndexPath *indexPathDetaied; //只有一个可以点击后展开状态. 展开前需关闭前一个.
@property (nonatomic, assign) CGFloat heightDetailedCell; //纪录下展开的cell的fit高度.


@property (nonatomic, strong) NSMutableArray *sectionsWrap;
@property (nonatomic, assign) BOOL isDisplayBeforeTask;
@property (nonatomic, assign) CGFloat contentOffsetYMonitor; //监测上拉距离. 以打开section之前.

@end





@implementation TaskViewController
#pragma mark - Custom override view.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"任务";
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    
    //返回只有一个箭头.
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
    
    self.sectionsWrap = [[NSMutableArray alloc] init];
    self.taskCellOptumizeHeights = [[NSMutableDictionary alloc] init];
    
    [self dataTasksReload];
    
    [self subviewBuild];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tasksView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
#if 0
    //    导航栏变为透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:0];
    //    让黑线消失的方法
    self.navigationController.navigationBar.shadowImage=[UIImage new];
#endif
 
    self.navigationController.navigationBar.translucent = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - View build and customize.
- (void)subviewBuild
{
    [self navigationItemRightInit];
    [self tasksViewBuild];
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataCreate = [[PushButtonData alloc] init];
    buttonDataCreate.actionString = @"taskCreate";
    buttonDataCreate.imageName = @"TaskAdd";
    PushButton *buttonCreate = [[PushButton alloc] init];
    buttonCreate.frame = CGRectMake(0, 0, 44, 44);
    buttonCreate.actionData = buttonDataCreate;
    buttonCreate.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonCreate setImage:[UIImage imageNamed:buttonDataCreate.imageName] forState:UIControlStateNormal];
    [buttonCreate addTarget:self action:@selector(actionCreate) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCreate = [[UIBarButtonItem alloc] initWithCustomView:buttonCreate];
    
    
    PushButtonData *buttonDataMore = [[PushButtonData alloc] init];
    buttonDataMore.actionString = @"more";
    buttonDataMore.imageName = @"more";
    PushButton *buttonMore = [[PushButton alloc] init];
    buttonMore.frame = CGRectMake(0, 0, 44, 44);
    buttonMore.actionData = buttonDataMore;
    buttonMore.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonMore setImage:[UIImage imageNamed:buttonDataMore.imageName] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(actionMore) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemMore,
                                                itemCreate,
                                                ];
    
    
    
    
}


- (void)tasksViewBuild
{
    self.tasksView = [[UITableView alloc] initWithFrame:VIEW_BOUNDS style:UITableViewStylePlain];
    [self.contentView addSubview:self.tasksView];
    self.tasksView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tasksView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tasksView.dataSource   = self;
    self.tasksView.delegate     = self;
    self.tasksView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //注册UITableViewCell重用.
    [self.tasksView registerClass:[TaskCell class] forCellReuseIdentifier:@"TaskCell"];
    
    /*添加轻扫手势*/
    //注意一个轻扫手势只能控制一个方向，默认向右，通过direction进行方向控制
    UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewSwipeToRight:)];
    //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认为向右轻扫
    [self.tasksView addGestureRecognizer:swipeGestureToRight];
    
    UISwipeGestureRecognizer *swipeGestureToLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewSwipeToLeft:)];
    swipeGestureToLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.tasksView addGestureRecognizer:swipeGestureToLeft];
}


- (void)tableViewSwipeToRight:(UISwipeGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.tasksView];
    NSIndexPath *indexPath = [self.tasksView indexPathForRowAtPoint:point];
    if(indexPath) {
        [self actionOnIndexPath:indexPath byString:@"finish"];
    }
}


- (void)tableViewSwipeToLeft:(UISwipeGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.tasksView];
    NSIndexPath *indexPath = [self.tasksView indexPathForRowAtPoint:point];
    if(indexPath) {
        [self actionOnIndexPath:indexPath byString:@"redo"];
    }
}


#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
    if(!self.isDisplayBeforeTask && [taskArrangeGroup.arrangeName isEqualToString:@"之前"]) {
        return 0;
    }
    
    return 45.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
    if(!self.isDisplayBeforeTask && [taskArrangeGroup.arrangeName isEqualToString:@"之前"]) {
        return nil;
    }
    
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
    sectionHeaderView.tag = section;
    
    UIEdgeInsets edgeContainer = UIEdgeInsetsMake(2, 0, 2, 0);
    CGRect frameContainer = UIEdgeInsetsInsetRect(sectionHeaderView.bounds, edgeContainer);
    UIView *container = [[UIView alloc] initWithFrame:frameContainer];
    [sectionHeaderView addSubview:container];
    container.backgroundColor = [UIColor colorWithName:@"TaskSectionHeaderBackground"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:container.bounds];
    NSMutableAttributedString *attributedString =
                    [NSString attributedStringWith:taskArrangeGroup.arrangeName
                                              font:[UIFont fontWithName:@"TaskSectionHeader"]
                                            indent:36
                                         textColor:[UIColor colorWithName:@"TaskSectionHeaderText"]
                     ];
    NSString *numberTasks = [NSString stringWithFormat:@"[%zd]", taskArrangeGroup.taskInfoArranges.count];
    [attributedString appendAttributedString:[NSString attributedStringWith:numberTasks
                                                                       font:[UIFont fontWithName:@"small"]
                                                                    indent:0
                                                                  textColor:[UIColor colorWithName:@"TaskSectionHeaderText"]
                                              ]
     ];
    label.attributedText = attributedString;
    [container addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSectionTap:)];
    tap.numberOfTapsRequired = 1;
    [sectionHeaderView addGestureRecognizer:tap];
    
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80.0;
    if([self.indexPathDetaied isEqual:indexPath]) {
        height = self.heightDetailedCell;
    }
    
    NSNumber *heightNumber;
    if(nil != (heightNumber = self.taskCellOptumizeHeights[indexPath])) {
        height = [heightNumber floatValue];
    }
    
    NSLog(@"---tableview height row : %lf", height);
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections ;
    sections = self.taskInfoManager.taskArrangeGroups.count;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
    
    if((!self.isDisplayBeforeTask && [taskArrangeGroup.arrangeName isEqualToString:@"之前"])
       || [self.sectionsWrap indexOfObject:@(section)] != NSNotFound) {
        rows = 0;
    }
    else {
        rows = taskArrangeGroup.taskInfoArranges.count;
    }
    
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_POSTION
    TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
    NSArray<TaskFinishAt*> *finishedAts = [self.taskInfoManager queryFinishedAtsOnSn:taskInfoArrange.taskinfo.sn on:taskInfoArrange.arrangeDays];
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    [cell setTaskInfo:taskInfoArrange.taskinfo finishedAts:finishedAts];
    
    self.taskCellOptumizeHeights[indexPath] = @(cell.frame.size.height);

    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
    [self enterTaskDetailInArrangeMode:taskInfoArrange];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


//上弹超过限定值的话,将之前显示出来.
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    NSLog(@"%f, %f", point.x, point.y);
    
    if(!self.isDisplayBeforeTask) {
        if(point.y < self.contentOffsetYMonitor) {
            self.contentOffsetYMonitor = point.y;
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.contentOffsetYMonitor < - 100 && !self.isDisplayBeforeTask) {
        NSLog(@"- drag to display tasks Before.")
        self.contentOffsetYMonitor = 0;
        self.isDisplayBeforeTask = YES;
        [self.sectionsWrap addObject:@0];
        [self.tasksView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    }
}


#pragma mark - data
- (BOOL)detailModeOnIndexPath:(NSIndexPath*)indexPath
{
    return NO;
//    return [self.indexPathDetaied isEqual:indexPath];
}


- (void)dataTasksReload
{
    self.taskInfoManager = [TaskInfoManager taskInfoManager];
    [self.taskInfoManager reloadAll];
    
    NSLog(@"%@", self.taskInfoManager);
}


- (TaskInfoArrange*)dataTaskInfoArrangeOnIndexPath:(NSIndexPath*)indexPath
{
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[indexPath.section];
    return taskArrangeGroup.taskInfoArranges[indexPath.row];
}


#pragma mark - action

- (void)actionCreate
{
    [self pushViewControllerByName:@"TaskEditViewController"];
}


- (void)pushBackAction
{
    NSLog(@"--------------------------------");
    [self dataTasksReload];
    [self actionReloadTasksView];
}


- (void)actionMore
{
  
}


- (void)actionOpenDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *prevIndexPath = self.indexPathDetaied;
    self.indexPathDetaied = indexPath;
    
    if(prevIndexPath) {
        [self actionReloadTasksViewOnIndexPaths:@[prevIndexPath, indexPath]];
    }
    else {
        [self actionReloadTasksViewOnIndexPath:indexPath];
    }
}


- (void)actionCloseDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    self.indexPathDetaied = nil;
    [self actionReloadTasksViewOnIndexPath:indexPath];
}




- (void)actionSectionTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"---%@ \n---%zd", sender, sender.view.tag);
    NSInteger section = sender.view.tag;
    
    [self actionSectionClick:section];
}


- (void)actionSectionClick:(NSInteger)section
{
    NSInteger idx = [self.sectionsWrap indexOfObject:@(section)];
    if(idx == NSNotFound) {
        [self.sectionsWrap addObject:@(section)];
    }
    else {
        [self.sectionsWrap removeObject:@(section)];
    }
    
    [self actionReloadTasksViewSection:section];
}


- (void)actionFinishOnIndexPath:(NSIndexPath*)indexPath andTaskInfo:(TaskInfo*)taskinfo onArrangeName:(NSString*)name onDays:(NSArray*)days
{
    NSLog(@"finish %@, arrange name %@, days %@", taskinfo.sn, name, days);
    if([name isEqualToString:@"今天"] || [name isEqualToString:@"明天"]) {
        if(days.count == 1) {
            BOOL result = [self.taskInfoManager addFinishedAtOnSn:taskinfo.sn on:days[0] committedAt:[NSString stringDateTimeNow]];
            if(result) {
                [self actionReloadTasksViewOnIndexPath:indexPath];
            }
            else {
                NSLog(@"#error - addFinishedAtOnSn(%@) error.", taskinfo.sn);
                [self showIndicationText:@"设置任务为完成状态不成功." inTime:1];
            }
        }
        else {
            NSLog(@"#error - argument error.");
            [self showIndicationText:@"设置任务为完成状态不成功." inTime:1];
        }
    }

}


- (void)actionRedoOnIndexPath:(NSIndexPath*)indexPath andTaskInfo:(TaskInfo*)taskinfo onArrangeName:(NSString*)name onDays:(NSArray*)days
{
    NSLog(@"finish %@, arrange name %@, days %@", taskinfo.sn, name, days);
    if([name isEqualToString:@"今天"] || [name isEqualToString:@"明天"]) {
        if(days.count == 1) {
            BOOL result = [self.taskInfoManager addRedoAtOnSn:taskinfo.sn on:days[0] committedAt:[NSString stringDateTimeNow]];
            if(result) {
                [self actionReloadTasksViewOnIndexPath:indexPath];
            }
            else {
                NSLog(@"#error - addRedoAtOnSn(%@) error.", taskinfo.sn);
                [self showIndicationText:@"设置任务为重新完成状态不成功." inTime:1];
            }
        }
        else {
            NSLog(@"#error - argument error.");
            [self showIndicationText:@"设置任务为重新完成状态不成功." inTime:1];
        }
    }
    
}


- (void)enterTaskDetailInArrangeMode:(TaskInfoArrange*)taskinfoArrange
{
    TaskDetailViewController *vc = [[TaskDetailViewController alloc] init];
    vc.taskinfo = taskinfoArrange.taskinfo;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionOnIndexPath:(NSIndexPath*)indexPath byString:(NSString*)actionString
{
    NSLog(@"action on %zd:%zd with string : %@", indexPath.section, indexPath.row, actionString);
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[indexPath.section];
    TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
    if([actionString isEqualToString:@"finish"]) {
        [self actionFinishOnIndexPath:indexPath andTaskInfo:taskInfoArrange.taskinfo onArrangeName:taskArrangeGroup.arrangeName onDays:taskInfoArrange.arrangeDays];
        return ;
    }

    if([actionString isEqualToString:@"redo"]) {
        [self actionRedoOnIndexPath:indexPath andTaskInfo:taskInfoArrange.taskinfo onArrangeName:taskArrangeGroup.arrangeName onDays:taskInfoArrange.arrangeDays];
        return ;
    }
//
//    if([actionString isEqualToString:@"edit"]) {
//        [self actionEditOnIndexPath:indexPath andTaskDay:taskDay];
//        return ;
//        
//        
//#if 0
//        //编辑时效果. row=0的滚动到row0. row>=1的滚动到row1. 然后计算frame弹出输入框控件.
//        //编辑行滚动到最上行.
////        [self.tasksView moveRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//        
//        [self.tasksView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        TaskCell *cell = [self.tasksView cellForRowAtIndexPath:indexPath];
//        CGRect tmp = [cell.summayView convertRect:cell.summayView.bounds toView:[UIApplication sharedApplication].keyWindow];
//        LOG_RECT(tmp, @"---")
//        
//        UIView *v0 = self.view;
//        while(v0) {
//            NSLog(@"v0 : %@", v0);
//            v0 = [v0 superview];
//        }
//        
//        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, 100)];
//        textView.text = taskDay.taskinfo.content;
//        textView.font = [UIFont systemFontOfSize:14.5];
//        textView.backgroundColor = [UIColor whiteColor];
//        __weak typeof(self) _self = self;
//        __weak typeof(textView) _textView = textView;
//        [self showPopupView:textView containerAlpha:0.3 dismiss:^{
//            [_self actionUpdateTaskContentOn:indexPath to:_textView.text];
//        }];
//        
//        return ;
//#endif
//    }
//    
//    if([actionString isEqualToString:@"more"]) {
//        TaskCellActionMenu *menu = [[TaskCellActionMenu alloc] initWithFrame:CGRectMake(VIEW_WIDTH * 0.2, 0, VIEW_WIDTH * 0.8, VIEW_HEIGHT)];
//        [self.contentView addSubview:menu];
//        
//        menu.backgroundColor = [UIColor blueColor];
//        LOG_VIEW_RECT(menu, @"menu")
//        
//        return ;
//    }
//    
//    
//    
}


- (void)actionReloadTasksViewOnIndexPath:(NSIndexPath*)indexPath
{
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}

- (void)actionReloadTasksViewOnIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}


- (void)actionReloadTasksViewSection:(NSInteger)section
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tasksView beginUpdates];
    [self.tasksView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}


- (void)actionReloadTasksView
{
    [self.tasksView reloadData];
}








@end