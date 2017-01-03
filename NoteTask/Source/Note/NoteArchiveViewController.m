//
//  NoteArchiveViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteArchiveViewController.h"
#import "LineBackgroundView.h"


@interface NoteArchiveViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITextField *inputView;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSArray<NSString*> *sns;

@property (nonatomic, strong) NSMutableArray *classifications;
@property (nonatomic, strong) NSMutableArray *filterDataColors;

@end


@implementation NoteArchiveViewController


- (void)setFrom:(NSString*)from andSns:(NSArray<NSString*>*)sns
{
    self.from = from;
    self.sns = sns;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dateReloadAll];
    
    self.tableView = [[UITableView alloc] init];
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
    self.title = @"分类";
    [self navigationItemRightInit];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


- (void)navigationItemRightInit
{
    PushButtonData *dataMore = [[PushButtonData alloc] init];
    dataMore.imageName = @"more";
    dataMore.actionString = @"more";
    PushButton *buttonMore = [[PushButton alloc] init];
    buttonMore.frame = CGRectMake(0, 0, 44, 44);
    buttonMore.actionData = dataMore;
    buttonMore.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonMore setImage:[UIImage imageNamed:buttonMore.actionData.imageName] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(actionMore) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemMore,
                                                ];
}


- (void)actionMore
{
    CGFloat width = 60;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width, 64, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = @[/*@"新增类别",*/ @"删除类别"];
    if(self.tableView.editing) {
        actionStrings = @[@"取消删除"];
    }
    [v setTexts:actionStrings];
    
    __weak typeof(self) weakSelf = self;
    [v setButtonActionByText:^(NSString* actionText) {
        NSLog(@"action : %@", actionText);
        [weakSelf dismissPopupView];
        [weakSelf actionMenuString:actionText];
        return ;
    }];
    
    [self showPopupView:v commission:nil clickToDismiss:YES dismiss:nil];
}


- (void)actionMenuString:(NSString*)actionText
{
    if([actionText isEqualToString:@"新增类别"]) {
        
        
    }
    
    if([actionText isEqualToString:@"删除类别"]) {
        if(self.classifications.count <= 2) {
            [self showIndicationText:@"没有新增的类别以删除" inTime:1];
            return ;
        }
        
        [self.tableView setEditing:YES animated:YES];
        return ;
    }
    
    if([actionText isEqualToString:@"取消删除"]) {
        [self.tableView setEditing:NO animated:YES];
        return;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"类别", @"标记"][section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#define kheightSection 56.0
    return kheightSection;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *colorText              = [UIColor colorWithName:@"NoteCustomSectionHeader"];
    UIColor *colorSectionBackground = [UIColor colorWithName:@"NoteCustomSectionBackground"];
    UIFont *fontText                = [UIFont fontWithName:@"NoteCustomSectionHeader"];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kheightSection)];
    sectionView.backgroundColor = colorSectionBackground;
    
    LineBackgroundView *lineBackgroundView = [LineBackgroundView createViewWithFrame:CGRectMake(0, 0, Width, 56) lineWidth:4 lineGap:4
                                                                           lineColor:[[UIColor blackColor] colorWithAlphaComponent:0.015]];
    
    
    [sectionView addSubview:lineBackgroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, kheightSection)];
    [sectionView addSubview:titleLabel];
    titleLabel.attributedText = [NSString attributedStringWith:@[@"类别", @"标记"][section]
                                                          font:fontText
                                                        indent:20
                                                     textColor:colorText];
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:sectionView];
    [f frameLayoutVertical:FRAMELAYOUT_NAME_MAIN
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_titleLabel" value:60 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"padding" percentage:1.0 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_inputView" value:160 edge:UIEdgeInsetsMake(10, 0, 10, 0)],
                             [FrameLayoutView viewWithName:@"_addButton" value:60 edge:UIEdgeInsetsZero],
                             ]
     ];
    
    
    titleLabel.frame    = [f frameLayoutGet:@"_titleLabel"];
    
    if(section == 0) {
        _inputView = [[UITextField alloc] init];
        [sectionView addSubview:_inputView];
        _inputView.hidden = YES;
        _inputView.delegate = self;
        _inputView.layer.borderColor = colorText.CGColor;
        _inputView.layer.borderWidth = 1.5;
        _inputView.layer.cornerRadius = 6;
        
        _addButton = [[UIButton alloc] init];
        [sectionView addSubview:_addButton];
        [_addButton setTitle:@"增加" forState:UIControlStateNormal];
        [_addButton setTitleColor:colorText forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(actionAddClassification:) forControlEvents:UIControlEventTouchDown];
        
        _inputView.frame     = [f frameLayoutGet:@"_inputView"];
        _addButton.frame     = [f frameLayoutGet:@"_addButton"];
    }
    
    return sectionView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}


- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return self.classifications.count;
    }
    else if(section == 1) {
        return self.filterDataColors.count;
    }
    
    return 0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if(indexPath.section == 0) {
        cell.textLabel.text = self.classifications[indexPath.row];
    }
    else if(indexPath.section == 1) {
        cell.textLabel.text = self.filterDataColors[indexPath.row];
        NSRange range = NSMakeRange(NSNotFound, 0);
        range = [cell.textLabel.text rangeOfString:@"红色"];
        if(range.location != NSNotFound && range.length > 0) {
            cell.textLabel.textColor = [UIColor redColor];
        }
        range = [cell.textLabel.text rangeOfString:@"黄色"];
        if(range.location != NSNotFound && range.length > 0) {
            cell.textLabel.textColor = [UIColor colorFromString:@"#f1cc56"];
        }
        range = [cell.textLabel.text rangeOfString:@"蓝色"];
        if(range.location != NSNotFound && range.length > 0) {
            cell.textLabel.textColor = [UIColor blueColor];
        }
    }
    
    UIImageView *imageView = [self imageLineWidth:cell.frame.size.width andHeight:0.5];
    imageView.frame = CGRectMake(0, 54, VIEW_WIDTH, 0.5);
    [cell addSubview:imageView];
    
#if 0
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 320, 20)];
    [self.view addSubview:imageView1];
    
    
    UIGraphicsBeginImageContext(imageView1.frame.size);   //开始画线
    [imageView1.image drawInRect:CGRectMake(0, 0, imageView1.frame.size.width, imageView1.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    
    float lengths[] = {10,5};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor redColor].CGColor);
    
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 20.0);    //开始画线
    CGContextAddLineToPoint(line, 310.0, 20.0);
    CGContextStrokePath(line);
    
    imageView1.image = UIGraphicsGetImageFromCurrentImageContext();
#endif
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.from isEqualToString:@"NotesArchiveChange"]) {
        
        if(indexPath.section == 0) {
            [[AppConfig sharedAppConfig] configNotesUpdateClassification:self.classifications[indexPath.row] bySns:self.sns];
        }
        else if(indexPath.section == 1) {
            NSString *colorString = [NoteModel colorDisplayStringToColorString:self.filterDataColors[indexPath.row]];
            [[AppConfig sharedAppConfig] configNotesUpdateColor:colorString bySns:self.sns];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        NSString *text = self.classifications[indexPath.row];
        if(NSNotFound == [[NoteModel classificationPreset] indexOfObject:text]) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.classifications[indexPath.row];
    NSLog(@"%@", text);
    
    [[AppConfig sharedAppConfig] configClassificationRemove:text];
    
    [self.tableView setEditing:NO animated:YES];
    [self dateReloadAll];
    [self.tableView reloadData];
}


- (UIImageView*)imageLineWidth:(CGFloat)width andHeight:(CGFloat)height
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));   //开始画线
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    CGFloat lengths[] = {2,1};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor blueColor].CGColor);
    
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 0.0);    //开始画线
    CGContextAddLineToPoint(line, width, 0.0);
    CGContextStrokePath(line);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    return imageView;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (toBeString.length > 10) {
        textField.text = [toBeString substringToIndex:10];
        [self showIndicationText:@"限定类别长度10" inTime:1.0];
        return NO;
    }
    
    return YES;
}


- (void)actionAddClassification:(UIButton*)button
{
    if([_addButton.titleLabel.text isEqualToString:@"增加"]) {
        _inputView.hidden = NO;
        [_inputView becomeFirstResponder];
        [_addButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    else if([_addButton.titleLabel.text isEqualToString:@"完成"]) {
        _inputView.hidden = YES;
        [_inputView resignFirstResponder];
        [self addClassification:_inputView.text];
        [_addButton setTitle:@"增加" forState:UIControlStateNormal];
    }
}


- (void)addClassification:(NSString*)text
{
    if(text.length == 0) {
        [self showIndicationText:@"类别为空, 无法添加" inTime:1.0];
        return ;
    }
    
    [[AppConfig sharedAppConfig] configClassificationAdd:text];
    [self dateReloadAll];
    [self.tableView reloadData];
}


- (void)dateReloadAll
{
    self.classifications = [[NSMutableArray alloc] init];
    [self.classifications addObjectsFromArray:[[AppConfig sharedAppConfig] configClassificationGets]];
    [self.classifications addObjectsFromArray:[NoteModel classificationPreset]];
    
    self.filterDataColors = [[NSMutableArray alloc] init];
    [self.filterDataColors addObjectsFromArray:[NoteModel colorAssignDisplayStrings]];
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


//限制输入框的字数限制.
#if 0
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


#endif
