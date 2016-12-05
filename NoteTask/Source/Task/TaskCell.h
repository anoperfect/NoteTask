//
//  TaskCellTableViewCell.h
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
#import "TaskInfoManager.h"
@interface TaskCell : UITableViewCell


- (void)setTaskInfo:(TaskInfo*)taskinfo finishedAts:(NSArray<TaskFinishAt*>*)finishedAts; //arrange mode使用此接口赋值.


@end


@interface TaskCellActionMenu : UIView

@end


@interface TaskDetailContentCell : UITableViewCell
@property (nonatomic, strong) TaskInfo *taskinfo;
@property (nonatomic, strong) void(^actionOn)(NSString*);
@end


@interface TaskDetailPropertyCell : UITableViewCell
- (void)setTitle:(NSAttributedString*)titleAttributedString content:(NSAttributedString*)contentAttributedString;
@end

@interface TaskRecordCell : UITableViewCell
@property (nonatomic, strong) TaskRecord *taskRecord;
@end











