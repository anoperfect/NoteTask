//
//  CustomViewController.h
//  NoteTask
//
//  Created by Ben on 16/8/20.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController



@property (nonatomic, assign) BOOL      contentViewScrolled;
@property (nonatomic, strong) UIView    *contentView;


- (void)addSubview:(UIView*)view;
- (void)addSubviews:(NSArray<UIView*>*)views;


- (void)showIndicationText:(NSString*)text inTime:(NSTimeInterval)secs;
- (void)dismissIndicationText;

- (void)showProgressText:(NSString*)text inTime:(NSTimeInterval)secs;
- (void)dismissProgressText;

- (void)showPopupView:(UIView*)view
           commission:(NSDictionary*)commission
       clickToDismiss:(BOOL)clickToDismiss
              dismiss:(void(^)(void))dismiss;
- (void)dismissPopupView;
- (void)pushViewControllerByName:(NSString*)name;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;


- (void)showMenus:(NSArray<NSDictionary*>*)menus selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction;
- (void)dismissMenus;

//override.
- (void)pushBackAction;








@end











@interface CustomTableView : UIView

- (void)setMenuDatas:(NSArray<NSDictionary*>*)menus selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction;

@end













#define VIEW_WIDTH      self.contentView.bounds.size.width
#define VIEW_HEIGHT     self.contentView.bounds.size.height
#define VIEW_SIZE       self.contentView.bounds.size
#define VIEW_BOUNDS     self.contentView.bounds

#define SCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE       [UIScreen mainScreen].bounds.size
#define SCREEN_BOUNDS     [UIScreen mainScreen].bounds

