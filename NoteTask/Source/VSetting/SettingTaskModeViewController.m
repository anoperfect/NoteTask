//
//  SettingTaskModeViewController.m
//  NoteTask
//
//  Created by Ben on 16/12/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "SettingTaskModeViewController.h"
#import "TaskInfoManager.h"






@interface SettingTaskModeViewController ()

@property (nonatomic, strong) UILabel *titleDefaultMode;
@property (nonatomic, strong) UISegmentedControl *selectorMode;
@property (nonatomic, strong) NSDictionary *modeIndexAndNames;
@property (nonatomic, strong) NSArray *modeNames;


@end


@implementation SettingTaskModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self memberObjectCreate];
    
    self.titleDefaultMode.text = @"默认显示模式";
    self.modeIndexAndNames = [TaskInfo modeIndexAndNames];
    self.modeNames = self.modeIndexAndNames.allValues;
    
    for(NSInteger idx = 0; idx < self.modeNames.count; idx ++) {
        [self.selectorMode insertSegmentWithTitle:self.modeNames[idx] atIndex:idx animated:YES];
    }
    [self.selectorMode addTarget:self action:@selector(actionModeTypeSelector:) forControlEvents:UIControlEventValueChanged];
    
    NSString *modeString = [[AppConfig sharedAppConfig] configSettingGet:@"TaskModeDefault"];
    NSInteger idx = NSNotFound;
    if(modeString.length > 0) {
        NSLog(@"TaskModeDefault : [%@]", modeString);
        if(NSNotFound != (idx = [self.modeNames indexOfObject:modeString])) {
            self.selectorMode.selectedSegmentIndex = idx ;
        }
        else {
            NSLog(@"#error - TaskModeDefault : [%@]", modeString);
        }
    }
    else {
        NSLog(@"TaskModeDefault not set.");
    }
    
    [self addSubview:self.titleDefaultMode];
    [self addSubview:self.selectorMode];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 20, 0, 20);
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            
                            [FrameLayoutView viewWithName:@"titleDefaultModePadding" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_titleDefaultMode" value:36 edge:edge],
                            [FrameLayoutView viewWithName:@"_selectorMode" value:36 edge:edge],
                            
                            ]
     ];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.title = @"设置-任务";
    
    self.navigationItem.title = @"设置-任务";
    
}


- (void)actionModeTypeSelector:(UISegmentedControl*)segmentedControl
{
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    NSLog(@"idx : %zd, name : %@", idx, self.modeNames[idx]);
    
    [[AppConfig sharedAppConfig] configSettingSetKey:@"TaskModeDefault" toValue:self.modeNames[idx] replace:YES];
}



@end


