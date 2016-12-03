//
//  NoteDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/19.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "NotePropertyView.h"
#import "YYText.h"
#import "AppDelegate.h"
#import "PopupViewController.h"
#import "TextButtonLine.h"
#import "CLDropDownMenu.h"
#import "NotePCustmiseViewController.h"
#import "NoteModel.h"
#import "NoteDetailCell.h"
#import "NoteShareViewController.h"
@interface NoteDetailViewController () <UITableViewDataSource, UITableViewDelegate,
                                        UITextFieldDelegate,
                                        UITextViewDelegate,
                                        YYTextViewDelegate,
                                        JSDropDownMenuDataSource,JSDropDownMenuDelegate>

@property (nonatomic, strong) NoteModel                *noteModel;
@property (nonatomic, assign) BOOL                      isCreateMode;
@property (nonatomic, assign) BOOL                      isStoredToLocal;

@property (nonatomic, strong) NoteParagraphModel       *titleParagraph;
@property (nonatomic, strong) NSMutableArray<NoteParagraphModel*> *contentParagraphs;


@property (nonatomic, strong) NSMutableDictionary *optumizeHeights;

@property (nonatomic, strong) NSIndexPath *indexPathOnEditing;
@property (nonatomic, strong) NSString *dueEditing;

@property (nonatomic, strong) NSIndexPath *indexPathOnCustmizing;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableNoteParagraphs;
@property (nonatomic, strong) UITextView *textViewEditing;
@property (nonatomic, strong) UIView *textViewEditingContainer;


//关于筛选.
@property (nonatomic, assign) CGFloat heightNoteFilter;
@property (nonatomic, strong) UIView *noteFilter;

@property (nonatomic, strong) NSMutableArray *  filterDataClassifications;
@property (nonatomic, assign) NSInteger         idxClassifications;

@property (nonatomic, strong) NSMutableArray *filterDataColors;
@property (nonatomic, assign) NSInteger         idxColor;

@property (nonatomic, assign) CGFloat           heightFitToKeyboard;



//@property (nonatomic, strong) UIWebView *webView;

@end

@implementation NoteDetailViewController





- (instancetype)initWithNoteModel:(NoteModel*)noteModel
{
    self = [super init];
    if (self) {
        self.noteModel = noteModel;
        [self parseNoteParagraphs];
        
        self.optumizeHeights = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


#define CREATE_PLACEHOLD_TITLE                  @"点击输入标题"
#define CREATE_PLACEHOLD_CONTENTPARAGRAPH       @"点击编辑内容"



//新建跟编辑的流程类似.
- (instancetype)initWithCreateNoteModel
{
    self = [super init];
    if (self) {
        self.isCreateMode = YES;
        
        NoteModel* noteModel = [[NoteModel alloc] init];
        noteModel.identifier    = [NoteModel randonIdentifierStringWithLength:6];
        NSLog(@"---%@", noteModel.identifier);
        noteModel.title         = @"";
        noteModel.content       = @"";
        noteModel.summary       = @"";
        noteModel.classification = @"个人笔记";
        noteModel.color = @"";
        noteModel.thumb = @"";
        noteModel.audio = @"",
        noteModel.location = @"CHINA";
        noteModel.createdAt = [NSString stringDateTimeNow];
        noteModel.modifiedAt = noteModel.createdAt;
        noteModel.browseredAt = noteModel.createdAt;
        noteModel.deletedAt = @"";
        noteModel.source = @"";
        noteModel.synchronize = @"";
        noteModel.countCollect = 0;
        noteModel.countLike = 0;
        noteModel.countDislike = 0;
        noteModel.countBrowser = 0;
        noteModel.countEdit = 0;
        self.noteModel = noteModel;
        
        self.titleParagraph = [[NoteParagraphModel alloc] init];
        self.titleParagraph.content = @""; //CREATE_PLACEHOLD_TITLE;
        self.titleParagraph.isTitle = YES;
        
        NoteParagraphModel *contentParagraph = [[NoteParagraphModel alloc] init];
        contentParagraph.content = @""; CREATE_PLACEHOLD_CONTENTPARAGRAPH;
        self.contentParagraphs = [[NSMutableArray alloc] initWithObjects:contentParagraph, nil];
        
        self.noteModel.title = [NoteParagraphModel noteParagraphToString:self.titleParagraph];
        self.noteModel.content = [NoteParagraphModel noteParagraphsToString:self.contentParagraphs];
        
        self.optumizeHeights = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.noteModel.title;
    self.titleLabel.numberOfLines = 0;
    //[self.view addSubview:self.titleLabel];
    
    //UITextView导致加载卡顿,因此延迟加载.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    LOG_POSTION
        
    self.tableNoteParagraphs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.tableNoteParagraphs];
    self.tableNoteParagraphs.dataSource = self;
    self.tableNoteParagraphs.delegate = self;
    self.tableNoteParagraphs.backgroundColor = [UIColor colorWithName:@"NoteParagraphs"];
    self.tableNoteParagraphs.backgroundColor = [UIColor colorWithName:@"NoteParagraphs"];
    [self.tableNoteParagraphs registerClass:[NoteDetailCell class] forCellReuseIdentifier:@"NoteDetail"];
    
    self.textViewEditingContainer = [[UIView alloc] init];
    [self addSubview:self.textViewEditingContainer];
    self.textViewEditingContainer.hidden = YES;
    self.textViewEditingContainer.backgroundColor = [UIColor whiteColor];
        
    self.textViewEditing = [[UITextView alloc] init];
    self.textViewEditing.attributedText = [[NSAttributedString alloc] initWithString:@""];
    self.textViewEditing.editable = NO;
    [self addSubview:self.textViewEditing];
    self.textViewEditing.hidden = YES;
    self.textViewEditing.delegate = self;
        
        //显式调用一次布局.否则显示有问题.
        [self.view setNeedsLayout];
        
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    NSLog(@"%@", self.noteModel);
    


}

#define YBLOW 64
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    LOG_POSTION
    
    CGRect frameTitleLabel = CGRectMake(0, YBLOW, VIEW_WIDTH, 100);
    CGSize size = [self.titleLabel sizeThatFits:frameTitleLabel.size];
    frameTitleLabel.size.height = size.height;
    self.titleLabel.frame = frameTitleLabel;
    
    frameTitleLabel.size.height = 0;
    
    CGRect frameNoteParagraphs = CGRectMake(0,
                                            0, /*frameTitleLabel.origin.y + frameTitleLabel.size.height,*/
                                            VIEW_WIDTH,
                                            VIEW_HEIGHT - (frameTitleLabel.origin.y + frameTitleLabel.size.height));
    frameNoteParagraphs = VIEW_BOUNDS;
    self.tableNoteParagraphs.frame = frameNoteParagraphs;
    
    
    self.heightFitToKeyboard = self.heightFitToKeyboard < 1 ? 200. : self.heightFitToKeyboard;
    CGRect frameTextViewEditingContainer = CGRectMake(0, 0, VIEW_WIDTH, self.heightFitToKeyboard);
    CGRect frameTextViewEditing = frameTextViewEditingContainer;
    frameTextViewEditing = UIEdgeInsetsInsetRect(frameTextViewEditing, NOTEDETAILCELL_EDGE_CONTAINER);
    frameTextViewEditing = UIEdgeInsetsInsetRect(frameTextViewEditing, NOTEDETAILCELL_EDGE_LABEL);
    self.textViewEditing.frame = frameTextViewEditing;
    self.textViewEditingContainer.frame = frameTextViewEditingContainer;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = !self.isCreateMode? @"笔记详情":@"新笔记";
    [self navigationItemRightInit];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.title = @"";
}


- (void)navigationItemRightInit
{
    UIImage *rightItemImage = [UIImage imageNamed:@"NoteShare"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [button setImage:rightItemImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionShare) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}


- (void)parseNoteParagraphs
{
    NSLog(@"identifier : %zd", self.noteModel.identifier);
    
    self.titleParagraph = [NoteParagraphModel noteParagraphFromString:self.noteModel.title];
    self.titleParagraph.isTitle = YES;
    
    NSArray<NoteParagraphModel *> *contentNoteParagraphs = [NoteParagraphModel noteParagraphsFromString:self.noteModel.content];
    self.contentParagraphs = [NSMutableArray arrayWithArray:contentNoteParagraphs];
    NSLog(@"content paragraph count : %zd", self.contentParagraphs.count);
    
    return ;
}


#if 0
- (NSMutableAttributedString*)titleParagraphAttrbutedStringOnDisplay:(BOOL)onDisplay
{
    NoteParagraphModel* noteParagraphModel = self.titleParagraph;
    NSString *string = noteParagraphModel.content;
    //在非显示模式下, 内容为空的话显示placehold.
    if(string.length == 0) {
        if(onDisplay) {
            if(!self.isCreateMode) {
                string = @"无标题";
            }
            else {
                string = CREATE_PLACEHOLD_TITLE;
            }
        }
    }
    
    noteParagraphModel.content = string;
    return [noteParagraphModel attributedTextGenerated];
    

}
#endif


//noteParagraph内容显示到Lable和Text的NSMutableAttributedString.
- (NSMutableAttributedString*)noteParagraphAttrbutedString:(NoteParagraphModel*)noteParagraphModel onDisplay:(BOOL)onDisplay
{
    NSString *string = noteParagraphModel.content;
    //在非显示模式下, 内容为空的话显示placehold.
    if(string.length == 0) {
        if(onDisplay) {
            if(!self.isCreateMode) {
                string = @"   ";
            }
            else {
                string = CREATE_PLACEHOLD_CONTENTPARAGRAPH;
            }
        }
    }
    
    noteParagraphModel.content = string;
    return [noteParagraphModel attributedTextGenerated];
}







- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0;
    
    if([indexPath isEqual:self.indexPathOnEditing]) {
        
    }
    else {
        NSNumber *heightNumber = self.optumizeHeights[indexPath];
        if([heightNumber isKindOfClass:[NSNumber class]]) {
            height = [heightNumber floatValue];
        }
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    return sections;
}


#define ROW_NUMBER_TITLE    2
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = self.contentParagraphs.count;
    return rows + ROW_NUMBER_TITLE; /*title一栏, 信息一栏.*/
}





- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteDetailCell *cell
            = [tableView dequeueReusableCellWithIdentifier:@"NoteDetail" forIndexPath:indexPath];

    //属性栏.
    if(indexPath.row == 1) {
        [cell setClassification:self.noteModel.classification color:self.noteModel.color];
        NSLog(@"property height : %f", cell.optumizeHeight);
    }
    else {
        NoteParagraphModel *noteParagraph = [self indexPathNoteParagraph:indexPath];
        [cell setNoteParagraph:noteParagraph isTitle:indexPath.row == 0 sn:indexPath.row - 1 onDisplayMode:!self.isCreateMode];
        NSLog(@"noteparag %zd height : %f", indexPath.row - 1, cell.optumizeHeight);
    }
    
    self.optumizeHeights[indexPath] = @(cell.optumizeHeight);
    return cell;
}




- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"row : %zd", indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //属性框显示的时候. 点击任意栏会执行关闭属性框.
    if([self filterViewisShow]) {
        NSLog(@"filterViewHidden");
        [self filterViewHidden];
        return ;
    }
    
    if(indexPath.row == 1) {
        [self filterViewBuild];
        
        return ;
    }
    
    CGFloat width = 45;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width - 10, 64 + 10, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = nil;
    NoteParagraphModel *noteParagraphModel;
    
    if([self indexPathIsTitle:indexPath]) {
        actionStrings = @[@"复制", @"编辑", @"样式"];
        if([self.titleParagraph.content isEqualToString:@""]) {
            [self editNoteParagraphAtIndexPath:indexPath due:@"编辑"];
            return ;
        }
    }
    else if(nil != (noteParagraphModel = [self indexPathContentNoteParagraph:indexPath])) {
        actionStrings = @[@"复制", @"编辑", @"插入", @"增加", @"样式"];
        if([noteParagraphModel.content isEqualToString:@""]) {
            [self editNoteParagraphAtIndexPath:indexPath due:@"编辑"];
            return ;
        }
    }
    else {
        NSLog(@"#error - ");
        return ;
    }
    
    [v setTexts:actionStrings];
    __weak typeof(self) weakSelf = self;
    [v setButtonActionByText:^(NSString* actionText) {
        [weakSelf dismissPopupView];
        [weakSelf action:actionText OnIndexPath:indexPath];
    }];
    
    [self showPopupView:v];
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.indexPathOnEditing) {
        if([indexPath isEqual:self.indexPathOnEditing]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}


- (void)editNoteParagraphAtIndexPath:(NSIndexPath*)indexPath due:(NSString*)dueEditing
{
    //edit功能只针对title 和 content paragraph.
    
    
    NoteParagraphModel *noteParagraph = [self indexPathNoteParagraph:indexPath];
    if(!noteParagraph) {
        NSLog(@"#error - ");
        return;
    }
    
    self.indexPathOnEditing = indexPath;
    self.dueEditing         = dueEditing;
    
    [self.tableNoteParagraphs scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    NoteDetailCell *cell = [self.tableNoteParagraphs cellForRowAtIndexPath:indexPath];
    
    UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 36)];
    keyboardAccessory.backgroundColor = [UIColor whiteColor];
    [keyboardAccessory setItems:@[
                                  [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(removeUpdate:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithTitle:@"下一段" style:UIBarButtonItemStylePlain target:self action:@selector(doneUpdateAndNext:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithTitle:@"输入完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneUpdate:)]
                                  ]
                       animated:YES];
    
    //重用cell中的textview有刷新逻辑设计的问题. 用一个单独的textview用于编辑.
    self.heightFitToKeyboard = self.heightFitToKeyboard < 1 ? 200. : self.heightFitToKeyboard;
    self.textViewEditing.attributedText = [noteParagraph attributedTextGenerated];
    self.textViewEditing.editable = YES;
    self.textViewEditing.inputAccessoryView = keyboardAccessory;
    [self.contentView bringSubviewToFront:self.textViewEditing];
    [self.textViewEditing becomeFirstResponder];
    
    self.textViewEditing.hidden = NO;
    self.textViewEditingContainer.hidden = NO;
    
    [self.view setNeedsLayout];
    
    if([self indexPathIsTitle:indexPath]) {
        self.title = @"编辑中 - 标题";
    }
    else {
        NSInteger noteParagraphIndex = [self indexPathContentNoteParagraphIndex:indexPath];
        self.title = [NSString stringWithFormat:@"编辑中 - 第%zd段", noteParagraphIndex + 1];
    }
}


- (void)withdrawEditingNoteParagraphAtIndexPath:(NSIndexPath*)indexPath
{
    [self.textViewEditing resignFirstResponder];
    self.textViewEditing.hidden = YES;
    self.textViewEditingContainer.hidden = YES;
    self.indexPathOnEditing = nil;
    
    if([self.dueEditing isEqualToString:@"编辑"]) {
        //数据源不更新,直接刷新显示.
        [self.tableNoteParagraphs reloadData];
    }
    else if([self.dueEditing isEqualToString:@"插入"] || [self.dueEditing isEqualToString:@"增加"]) {
        //删除新增加的NoteParagraph.
        NSInteger idxNoteParagraph = [self indexPathContentNoteParagraphIndex:indexPath];
        [self.contentParagraphs removeObjectAtIndex:idxNoteParagraph];
//        NoteParagraphModel *noteParagraph =
        
        [self.tableNoteParagraphs reloadData];
    }
    else {
        NSLog(@"#error - dueEditing nil.");
        [self.tableNoteParagraphs reloadData];
    }
}


- (void)finishEditingNoteParagraphAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *content = [self.textViewEditing.attributedText string];
    self.indexPathOnEditing = nil;
    
    [self.textViewEditing resignFirstResponder];
    self.textViewEditing.hidden = YES;
    self.textViewEditingContainer.hidden = YES;
    
    if([self indexPathIsTitle:indexPath]) {
        [self updateNoteTitleWithContent:content];
    }
    else {
        [self updateNoteParagraphOnIndex:[self indexPathContentNoteParagraphIndex:indexPath] withContent:content];
    }
    
    //刷新显示.
    [self.tableNoteParagraphs reloadData];
    
    //标记indexPathOnEditing.
    self.indexPathOnEditing = nil;
    
    self.title = !self.isCreateMode? @"笔记详情":@"新笔记";
}


- (void)reloadNoteParagraphAtIndexPath:(NSIndexPath*)indexPath due:(NSString*)due
{
    if(!indexPath) {
        NSLog(@"#error - reloadNoteParagraphAtIndexPath nil");
        return ;
    }
    
    NSLog(@"reload cell %zd:%zd due : %@.", indexPath.section, indexPath.row, due);
    
    [self.tableNoteParagraphs beginUpdates];
    [self.tableNoteParagraphs reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableNoteParagraphs endUpdates];
}


- (void)action:(NSString*)string OnIndexPath:(NSIndexPath*)indexPath
{
    if([string isEqualToString:@"编辑"]) {
        
        if(self.indexPathOnEditing) {
            [self action:@"编辑完成" OnIndexPath:self.indexPathOnEditing];
            self.indexPathOnEditing = nil;
        }
        
        [self editNoteParagraphAtIndexPath:indexPath due:@"编辑"];

        return ;
    }

    
    if([string isEqualToString:@"插入"]) {
        NSInteger idxInsert = [self indexPathContentNoteParagraphIndex:indexPath];
        NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
        noteParagraph.content = @"";
        [self.contentParagraphs insertObject:noteParagraph atIndex:idxInsert];
        
        [self.tableNoteParagraphs beginUpdates];
        [self.tableNoteParagraphs insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableNoteParagraphs endUpdates];
        
        [self.tableNoteParagraphs reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self editNoteParagraphAtIndexPath:indexPath due:@"插入"];
        });
        
        return;
        
    }
    
    if([string isEqualToString:@"增加"]) {
    
        NSInteger idxAppend = [self indexPathContentNoteParagraphIndex:indexPath];
        if(idxAppend == NSNotFound) {
            NSLog(@"#error - ");
        }
        else if(idxAppend == self.contentParagraphs.count - 1) {
            [self.contentParagraphs addObject:[self newNoteParagraph]];
        }
        else {
            [self.contentParagraphs insertObject:[self newNoteParagraph] atIndex:idxAppend + 1];
        }
        
        NSIndexPath *indexPathAppend = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [self.tableNoteParagraphs beginUpdates];
        [self.tableNoteParagraphs insertRowsAtIndexPaths:@[indexPathAppend] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableNoteParagraphs endUpdates];
        
        [self.tableNoteParagraphs reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self editNoteParagraphAtIndexPath:indexPathAppend due:@"增加"];
        });
        
        return;
        
    }
    
    if([string isEqualToString:@"样式"]) {
        
        self.indexPathOnCustmizing = indexPath;
        NoteParagraphModel *noteParagraph = [self indexPathNoteParagraph:indexPath];
        
//        NoteParagraphCustmiseViewController *vc = [[NoteParagraphCustmiseViewController alloc] initWithStyleDictionary:noteParagraph.styleDictionay];
        NoteParagraphCustmiseViewController *vc = [[NoteParagraphCustmiseViewController alloc] initWithNoteParagraph:noteParagraph];
        //通过block的方式将定制的内容传回此ViewController.
        __weak typeof(self) _self = self;
        [vc setStyleFinishHandle:^(NSDictionary *styleDictionary) {
            [_self finishStyleCustmize:styleDictionary];
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
        return ;
    }
    
    NSLog(@"action not implemented.");
}


- (void)finishStyleCustmize:(NSDictionary*)stypleDictionary
{
    NSLog(@"finishStyleCustmize : %@. ", stypleDictionary);
    NSLog(@"indexPathOnCustmizing : %@%zd:%zd",
          self.indexPathOnCustmizing?@"":@"nil --------",  self.indexPathOnCustmizing.section, self.indexPathOnCustmizing.row);
    if(!self.indexPathOnCustmizing) {
        NSLog(@"#error - indexPathOnCustmizing nil.");
        return ;
    }
    
    NoteParagraphModel *noteParagraphOnCustmizing = [self indexPathNoteParagraph:self.indexPathOnCustmizing];
    NSLog(@"before custmize : %@", noteParagraphOnCustmizing);
    noteParagraphOnCustmizing.styleDictionay = [NSMutableDictionary dictionaryWithDictionary:stypleDictionary];
    NSLog(@"after  custmize : %@", noteParagraphOnCustmizing);
    
    
    //更改过样式后, 重新生成title和content.
    self.noteModel.title = [NoteParagraphModel noteParagraphToString:self.titleParagraph];
    self.noteModel.content = [NoteParagraphModel noteParagraphsToString:self.contentParagraphs];
    
    //更新到本地数据库.
    [[AppConfig sharedAppConfig] configNoteUpdate:self.noteModel];
    
    NSLog(@"%@", self.noteModel);
    
    [self reloadNoteParagraphAtIndexPath:self.indexPathOnCustmizing due:@"after custmize"];
}


- (BOOL)indexPathIsTitle:(NSIndexPath*)indexPath
{
    return indexPath.row == 0;
}


- (BOOL)indexPathIsLast:(NSIndexPath*)indexPath
{
    NSInteger noteIndex = [self indexPathContentNoteParagraphIndex:indexPath];
    return noteIndex == (self.contentParagraphs.count - 1);
}


- (NSInteger)indexPathContentNoteParagraphIndex:(NSIndexPath*)indexPath
{
    NSInteger noteIndex = indexPath.row - ROW_NUMBER_TITLE;
    if(noteIndex >= 0 && noteIndex < self.contentParagraphs.count) {
        
    }
    else {
        NSLog(@"#error - ");
        noteIndex = NSNotFound;
    }
    
    return noteIndex;
}


- (NSIndexPath*)indexPathOnNoteParagraphIndex:(NSInteger)noteParagraphIndex
{
    return [NSIndexPath indexPathForRow:noteParagraphIndex+ROW_NUMBER_TITLE inSection:0];
}


//返回Content的NoteParagraph.
- (NoteParagraphModel*)indexPathContentNoteParagraph:(NSIndexPath*)indexPath
{
    NSInteger noteParagraphIndex = [self indexPathContentNoteParagraphIndex:indexPath];
    if(noteParagraphIndex >= 0 && noteParagraphIndex < self.contentParagraphs.count) {
        return self.contentParagraphs[noteParagraphIndex];
    }
    else {
        NSLog(@"#error - noteParagraphOnIndexPath row %zd, contentParagraphs count %zd.", noteParagraphIndex, self.contentParagraphs.count);
        return nil;
    }
}


//返回title或者Content的NoteParagraph.
- (NoteParagraphModel*)indexPathNoteParagraph:(NSIndexPath*)indexPath
{
    if([self indexPathIsTitle:indexPath]) {
        return self.titleParagraph;
    }
    
    return [self indexPathContentNoteParagraph:indexPath];
}


- (NoteParagraphModel*)newNoteParagraph
{
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"";
    
    return noteParagraph;
}


- (void)updateNoteTitleWithContent:(NSString*)content
{
    self.titleParagraph.content = content;
    NSString *titleContent = [NoteParagraphModel noteParagraphToString:self.titleParagraph];
    self.noteModel.title = titleContent;
    
    [self updateNoteToLocal];
}


- (void)updateNoteParagraphOnIndex:(NSInteger)noteParagraphIndex withContent:(NSString*)content
{
    NoteParagraphModel *noteParagraph = self.contentParagraphs[noteParagraphIndex];
    noteParagraph.content = content;
    
    NSString *noteContent = [NoteParagraphModel noteParagraphsToString:self.contentParagraphs];
    self.noteModel.content = noteContent;
    
    [self updateNoteToLocal];
}


- (BOOL)addNoteToLocal
{
    NSLog(@"addNoteToLocal : %@", self.noteModel.identifier);
    BOOL result = [[AppConfig sharedAppConfig] configNoteAdd:self.noteModel];
    if(result) {
        self.isStoredToLocal = YES;
    }
    return result;
}


- (void)updateNoteToLocal
{
    NSLog(@"updateNoteToLocal");
    
    //新建模式下, 保存之前先写入存储.
    if(self.isCreateMode && !self.isStoredToLocal) {
        //内容不为空的话才保存.
        if(self.titleParagraph.content.length > 0
           || self.contentParagraphs.count > 1
           || (self.contentParagraphs.count == 1 &&  self.contentParagraphs[0].content.length > 0 )) {
            [self addNoteToLocal];
        }
        else {
            NSLog(@"none content. it would not store to local.");
        }
            
        return ;
    }
    
    //更新本地存储.
    [[AppConfig sharedAppConfig] configNoteUpdate:self.noteModel];
}





- (void)removeUpdate:(id)sender
{
    [self withdrawEditingNoteParagraphAtIndexPath:self.indexPathOnEditing];
}


- (void)doneUpdate:(id)sender
{
    [self finishEditingNoteParagraphAtIndexPath:self.indexPathOnEditing];
}


- (void)doneUpdateAndNext:(id)sender
{
    NSIndexPath *indexPathOnEditing = self.indexPathOnEditing;
    [self doneUpdate:sender];
    
    if([self indexPathIsTitle:indexPathOnEditing]) {
        [self action:@"编辑" OnIndexPath:[self indexPathOnNoteParagraphIndex:0]];
    }
    else if([self indexPathIsLast:indexPathOnEditing]) {
        NoteParagraphModel *noteParagraph = [self indexPathNoteParagraph:indexPathOnEditing];
        noteParagraph = nil;
        //是否增加最后一段为空的时候, 不允许新增加.
        
        [self action:@"增加" OnIndexPath:indexPathOnEditing];
    }
    else {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPathOnEditing.row+1 inSection:indexPathOnEditing.section];
        [self action:@"编辑" OnIndexPath:nextIndexPath];
    }
}


- (void)updateClassificationTo:(NSString*)classification
{
    NSLog(@"updateClassificationTo : %@", classification);
    
    //更新存储.
    [[AppConfig sharedAppConfig] configNoteUpdateBynoteIdentifiers:@[self.noteModel.identifier] classification:classification];
    
    //更新数据.
    self.noteModel.classification = classification;
    
    //更新属性显示.
    [self updateNotePropertyDisplay];
}


- (void)updateColorStringTo:(NSString*)colorDisplayString
{
    NSString *colorString = [NoteModel colorDisplayStringToColorString:colorDisplayString];
    NSLog(@"updateColorStringTo : %@", colorString); 
    
    //更新存储.
    [[AppConfig sharedAppConfig] configNoteUpdateBynoteIdentifiers:@[self.noteModel.identifier] colorString:colorString];
    
    //更新数据.
    self.noteModel.color = colorString;
    
    //更新属性显示.
    [self updateNotePropertyDisplay];
}



- (void)filterViewBuild
{
    if(self.noteFilter) {
        NSLog(@"filterView already built.");
        [self.view bringSubviewToFront:self.noteFilter];
        return ;
    }
    
    self.heightNoteFilter = 36;
    
    //使用NoteFilter包裹JSDropDownMenu的时候,获取不到点击事件. 暂时使用JSDropDownMenu demo中的方式.
    //    self.noteFilter = [[NoteFilter alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, heightNoteFilter)];
    //    [self.view addSubview:self.noteFilter];
    //    self.noteFilter.backgroundColor = [UIColor yellowColor];
    //
    //    [self.view bringSubviewToFront:self.noteFilter];
    self.filterDataClassifications = [NSMutableArray arrayWithObjects:@"个人笔记", nil];
    NSArray<NSString*> *addedClassifications = [[AppConfig sharedAppConfig] configClassificationGets];
    if(addedClassifications.count > 0) {
        [self.filterDataClassifications addObjectsFromArray:addedClassifications];
    }
    [self.filterDataClassifications addObject:@"新增类别"];
    
    self.filterDataColors = [[NSMutableArray alloc] init];//[NSMutableArray arrayWithObjects:nil];
    [self.filterDataColors addObjectsFromArray:[NoteModel colorAssignDisplayStrings]];
    JSDropDownMenu *menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:self.heightNoteFilter];
    menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    menu.dataSource = self;
    menu.delegate = self;
    
    self.noteFilter = menu;
    
    [self.contentView addSubview:menu];
    
    //[self showPopupView:menu];
}


- (void)filterViewHidden
{
    self.noteFilter.hidden = YES;
    [self.noteFilter removeFromSuperview];
    self.noteFilter = nil;
    //[self dismissPopupView];
}


- (BOOL)filterViewisShow
{
    return (nil != self.noteFilter);
}


//新增栏目.
- (void)filterViewAddClassification
{
    CGRect frame = self.noteFilter.frame;
#if 0
    UIView *container = [[UIView alloc] initWithFrame:frame];
    [self.noteFilter addSubview:container];
    container.backgroundColor = [UIColor whiteColor];
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(2, 70, 2, 10));
#endif
    
    frame = CGRectMake(0, 64, self.contentView.bounds.size.width, 36);
    UITextField *classificationInputView = [[UITextField alloc] initWithFrame:frame];
    //[container addSubview:classificationInputView];
    classificationInputView.borderStyle     = UITextBorderStyleLine;
//    classificationInputView.backgroundColor = [UIColor blueColor];
    classificationInputView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    classificationInputView.placeholder     = @"请输入新增的栏目";
    classificationInputView.clearButtonMode = UITextFieldViewModeAlways;
    classificationInputView.returnKeyType = UIReturnKeyDone;
    classificationInputView.delegate        = self;
    
    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, classificationInputView.bounds.size.height / 2, 100)];
    classificationInputView.leftView = leftview;
    classificationInputView.leftViewMode = UITextFieldViewModeAlways;
    
    classificationInputView.layer.cornerRadius = classificationInputView.bounds.size.height / 2;
    classificationInputView.layer.borderWidth = 1.5;
    
    [classificationInputView becomeFirstResponder];
    
    [self showPopupView:classificationInputView];
    
}


- (void)filterViewDidAddClassification:(NSString*)classification
{
    //添加到栏目数据库.
    [[AppConfig sharedAppConfig] configClassificationAdd:classification];
    
    //执行修改classification动作. 包括更新存储, 更新数据, 更新属性显示.
    [self updateClassificationTo:classification];
}


- (void)updateNotePropertyDisplay
{
    NSIndexPath *indexPathProperty = [self indexPathProperty];
    if([[self.tableNoteParagraphs indexPathsForVisibleRows] indexOfObject:indexPathProperty] != NSNotFound) {
        //        [self.tableNoteParagraphs reloadData];
        [self reloadNoteParagraphAtIndexPath:indexPathProperty due:@"updateNotePropertyDisplay"];
    }
}


- (NSIndexPath *)indexPathProperty
{
    return [NSIndexPath indexPathForRow:1 inSection:0];
}


//栏目增加的delegate.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    LOG_POSTION
    return YES;
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    LOG_POSTION
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    LOG_POSTION
    
    //官方 取消第一响应者（就是退出编辑模式收键盘）
    [textField resignFirstResponder];
    [self dismissPopupView];
    
    if(textField.text.length > 0) {
        [self filterViewDidAddClassification:textField.text];
    }
    
    return YES;
}


//方法一

- (BOOL)textField1:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (range.location>= 10) {
        return NO;
    }
    
    return YES;
    
}


//方法二
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (toBeString.length > 10) {
        textField.text = [toBeString substringToIndex:10];
        return NO;
    }
    
    return YES;
}


//关于筛选.
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    
    return 2;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    
    if (column==1) {
        
        return YES;
    }
    
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    
    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    
    if (column==0) {
        
        return self.idxClassifications;
        
    }
    if (column==1) {
        
        return self.idxColor;
    }
    
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
    if (column==0) {
        return self.filterDataClassifications.count;
        
    } else if (column==1){
        return self.filterDataColors.count;
    }
    
    return 0;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    
    switch (column) {
        case 0: return self.noteModel.classification;
            break;
        case 1: return [NoteModel colorStringToColorDisplayString:self.noteModel.color];
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if (indexPath.column==0) {
        
        return self.filterDataClassifications[indexPath.row];
        
    } else {
        
        return self.filterDataColors[indexPath.row];
    }
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if(indexPath.column == 0){
        
        self.idxClassifications = indexPath.row;
        
        //新增栏目.
        if(self.filterDataClassifications.count - 1 == indexPath.row) {
            [self filterViewAddClassification];
            [self filterViewHidden];
        }
        else {
            [self updateClassificationTo:self.filterDataClassifications[indexPath.row]];
            //选择后关闭属性栏. 是不是会修改多项时需重新打开...
            [self filterViewHidden];
        }
    } else{
        
        self.idxColor = indexPath.row;
        [self updateColorStringTo:self.filterDataColors[indexPath.row]];
        [self filterViewHidden];
    }
    
    NSLog(@"Classification : %@, color : %@", self.filterDataClassifications[self.idxClassifications], self.filterDataColors[self.idxColor]);
}


- (void)keyboardChangeFrame:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGRect softKeyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //判断软键盘是否隐藏.
    if(!CGRectIntersectsRect(softKeyboardFrame, self.view.frame)) {
        NSLog(@"soft keypad not shown.");
        self.heightFitToKeyboard = 0.0;
        
    }
    else {
        NSLog(@"soft keypad shown.");
        if(self.heightFitToKeyboard != self.contentView.frame.size.height - softKeyboardFrame.size.height) {
            self.heightFitToKeyboard = self.contentView.frame.size.height - softKeyboardFrame.size.height;
        }
    }
    
    [self.view setNeedsLayout];
}



- (void)openClassificationMenu
{
    CLDropDownMenu *dropMenu = [[CLDropDownMenu alloc] initWithBtnPressedByWindowFrame:CGRectMake(100, 100, 100, 100)  Pressed:^(NSInteger index) {
        NSLog(@"点击了第%zd个btn",index+1);
    }];
    
    dropMenu.direction = CLDirectionTypeRight;
    dropMenu.titleList = @[@"添加好友",@"创建群",@"扫一扫"];
    dropMenu.backgroundColor = [UIColor purpleColor];
    
    [self addSubview:dropMenu];
    
    NSLog(@"%@", dropMenu);
}


//UItextView for editing delegate.
-(BOOL) textViewShouldBeginEditing:(UITextView*)textView
{
    LOG_POSTION
    return YES;
}


-(void)textViewDidChange:(UITextView*)textView
{
    LOG_POSTION
}





- (void)actionMore
{
    CGFloat width = 60;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width, 64, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = nil;
    actionStrings = @[@"Pdf分享", @"电脑查看"];
    [v setTexts:actionStrings];
    
    __weak typeof(self) weakSelf = self;
    [v setButtonActionByText:^(NSString* actionText) {
        NSLog(@"action : %@", actionText);
        [weakSelf dismissPopupView];
        
        if([actionText isEqualToString:@"Pdf分享"]) {
            return ;
        }
        
        if([actionText isEqualToString:@"电脑查看"]) {
            return;
        }
        
        if([actionText isEqualToString:@"恢复预制"]) {
            return;
        }
        
    }];
    
    [self showPopupView:v];
}


- (void)actionShare
{
    NoteShareViewController *vc = [[NoteShareViewController alloc] init];
    vc.noteModel = self.noteModel;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end






#if 0

-(UIImage *)screenImageWithSize:(CGSize )imgSize{
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    AppDelegate * app = (AppDelegate *)([UIApplication sharedApplication].delegate); //获取app的appdelegate，便于取到当前的window用来截屏
    [app.window.layer renderInContext:context];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (void)snapshot
{
    UIGraphicsBeginImageContext(VIEW_SIZE);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //将截屏保存到相册
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    UIGraphicsEndImageContext();
    
    UIImage *image = [self screenImageWithSize:[UIScreen mainScreen].bounds.size];
    UIImageWriteToSavedPhotosAlbum(image,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存失败，请检查是否拥有相关的权限");
    }
    else {
        NSLog(@"保存成功！");
    }
}

#endif


#if 0
- (NSMutableAttributedString*)noteParagraphCreateAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    UIFont *font = [UIFont systemFontOfSize:16];
    UIColor *color = [UIColor blackColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    
    //对齐方式.
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 20.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 2.0;
    NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}
#endif


#if 0
NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
UIFont *font    = [noteParagraphModel titleFont];
UIColor *color  = [noteParagraphModel textColor];

[attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
[attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
[attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];

//对齐方式.
NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
paragraphStyle.alignment = NSTextAlignmentCenter;
paragraphStyle.headIndent = 4.0;
paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
paragraphStyle.lineSpacing = 2.0;
NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
[attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];

return attributedString;
#endif

#if 0
NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];

//字体,颜色.
UIFont *font    = [noteParagraphModel textFont];
UIColor *color  = [noteParagraphModel textColor];
[attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
[attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
[attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];

//对齐方式.
NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
paragraphStyle.alignment = NSTextAlignmentLeft;
paragraphStyle.headIndent = 20.0;
paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
paragraphStyle.lineSpacing = 2.0;
NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
[attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];

return attributedString;
#endif


#if 0
- (UITableViewCell*)tableView1:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define TAG_noteParagraphLabel          1000000 + 10
#define TAG_noteParagraphTextView       1000000 + 11
#define TAG_notePropertyView            1000000 + 12
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteParagraph"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        CGRect frame = cell.frame;
        frame.size.width = tableView.frame.size.width;
        [cell setFrame:frame];
        
    }
    else {
        
    }
    
    //属性栏.
    if(indexPath.row == 1) {
        //cell.textLabel.text = @"附加信息";
        CGFloat height = 36.0;
        
        self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:height];
        
        NotePropertyView *notePropertyView = [cell viewWithTag:TAG_notePropertyView];
        if(!notePropertyView) {
            notePropertyView = [[NotePropertyView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, height)];
            
            [cell addSubview:notePropertyView];
            [notePropertyView setTag:TAG_notePropertyView];
        }
        [[cell viewWithTag:TAG_noteParagraphLabel] removeFromSuperview];
        [[cell viewWithTag:TAG_noteParagraphTextView] removeFromSuperview];
        
        
        [notePropertyView setClassification:self.noteModel.classification color:self.noteModel.color];
        
        [notePropertyView setActionPressed:^(NSString *item) {
            if([item isEqualToString:@"Classification"]) {
                //                __weak typeof(self) weakSelf = self;
                //                [weakSelf openClassificationMenu];
            }
        }];
        
        return cell;
    }
    
    NoteParagraphModel *noteParagraph = [self indexPathNoteParagraph:indexPath];
    
#define USE_UILABEL 1
    
#if USE_UILABEL
    //显示用的具体控件的创建.
    UILabel *noteParagraphLabel = [cell viewWithTag:TAG_noteParagraphLabel];
    if(!noteParagraphLabel) {
        noteParagraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 10 * 2, 100)];
        noteParagraphLabel.numberOfLines = 0;
    }
    
    //内容设置.
    noteParagraphLabel.textAlignment = NSTextAlignmentLeft;
    noteParagraphLabel.attributedText = [self noteParagraphAttrbutedString:noteParagraph onDisplay:YES];
    
    //计算可变高度. 同时保存给UITableviewCell的高度计算.
    CGSize sizeOptumize = CGSizeMake(noteParagraphLabel.frame.size.width, 1000);
    sizeOptumize = [noteParagraphLabel sizeThatFits:sizeOptumize];
    
    
    
#endif
    
#if USE_YYLABEL
    //显示用的具体控件的创建.
    YYLabel *noteParagraphLabel = [cell viewWithTag:TAG_noteParagraphLabel];
    if(!noteParagraphLabel) {
        noteParagraphLabel = [[YYLabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 10 * 2, 100)];
        noteParagraphLabel.numberOfLines = 0;
    }
    
    //内容设置.
    noteParagraphLabel.textAlignment = NSTextAlignmentLeft;
    noteParagraphLabel.attributedText = [self noteParagraphAttrbutedString:noteParagraph onDisplay:YES];
    
    //计算可变高度. 同时保存给UITableviewCell的高度计算.
    CGSize sizeOptumize = CGSizeMake(noteParagraphLabel.frame.size.width, 1000);
    sizeOptumize = [noteParagraphLabel sizeThatFits:sizeOptumize];
#endif
    
    //设置边框.
    if([noteParagraph.styleDictionay[@"border"] isEqualToString:@"1px solid #000"]) {
        noteParagraphLabel.layer.borderWidth = 1.0;
        noteParagraphLabel.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
    //设置高度.
    CGFloat heightOptumize = sizeOptumize.height + 20 ;
    self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:heightOptumize];
    CGRect frame = noteParagraphLabel.frame;
    frame.size.height = heightOptumize;
    noteParagraphLabel.frame = frame;
    
    [[cell viewWithTag:TAG_notePropertyView] removeFromSuperview];
    [[cell viewWithTag:TAG_noteParagraphTextView] removeFromSuperview];
    [cell addSubview:noteParagraphLabel];
    [noteParagraphLabel setTag:TAG_noteParagraphLabel];
    
    return cell;
}


- (YYTextView*)textViewOnEditing
{
    YYTextView *noteParagraphTextView = nil;
    
    if(self.indexPathOnEditing
       && [self.tableNoteParagraphs visibleCells].count > 0
       ) {
        
        UITableViewCell *cell = [self.tableNoteParagraphs cellForRowAtIndexPath:self.indexPathOnEditing];
        if(cell) {
            noteParagraphTextView = [cell viewWithTag:TAG_noteParagraphTextView];
        }
    }
    
    return noteParagraphTextView;
}


#endif




@implementation KYPrintPageRenderer
- (CGRect) paperRect
{
    if (!_generatingPdf)
        return [super paperRect];
    return UIGraphicsGetPDFContextBounds();
}


- (CGRect) printableRect
{
    if (!_generatingPdf)
        return [super printableRect];
    return CGRectInset( self.paperRect, 100, 100 );
}


- (NSData*) printToPDF
{
    _generatingPdf = YES;
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, CGRectMake(0, 0, 612, 796), nil );  // letter-size, landscape
    [self prepareForDrawingPages: NSMakeRange(0, 1)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex: i inRect: bounds];
    }
    UIGraphicsEndPDFContext();
    _generatingPdf = NO;
    return pdfData;
}
@end