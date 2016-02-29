//
//  NoteViewController.m
//  TaskNote
//
//  Created by Ben on 16/1/24.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "NoteViewController.h"
#import "UIColor+Util.h"
#import "NSThread+Util.h"
@interface NoteViewController ()




@end

@implementation NoteViewController


- (instancetype)initWithType:(NoteListType)type {
    
    self = [super init];
    
    NSLog(@"type:%zd", type);
    
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"notecell"];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor themeColor];
    
    NSString *urlString = @"http://www.qq.com";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:5.0f];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSLog(@"idx : %zd", [NSThread threadIndex]);
        
        NSLog(@"%@", data);
        
        
    }];
    
        NSLog(@"1 idx : %zd", [NSThread threadIndex]);
}






- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notecell" forIndexPath:indexPath];
    
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 60.0;
    
    
    NSLog(@"height : %f", height);
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
}



@end