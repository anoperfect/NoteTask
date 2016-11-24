//
//  NSObject+Util.h
//  NoteTask
//
//  Created by Ben on 16/3/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSObject(Uitl)

+ (void)objectClassTest:(NSObject*)obj;

- (void)performSelectorByString:(NSString*)selString;


@end



@interface NSString (DateString)

+ (BOOL)stringIsAllDigtal:(NSString*)string;
+ (BOOL)stringIsValidDayString:(NSString*)dayString;

+ (NSString*)dayStringToday;
+ (NSString*)dayStringTomorrow;

+ (NSString*)stringDateTimeNow;
+ (NSDate*)stringToDate:(NSString*)s;
@end


@interface NSString (Htm)

+ (NSString*)htmEncode:(NSString*)s;
+ (NSString*)htmDecode:(NSString*)s;
@end







@interface NSString (Random)
+ (NSString*)randomStringWithLength:(NSInteger)length andType:(NSInteger)type;
@end



@interface NSString (NSAttributedString)
+(NSMutableAttributedString*)attributedStringWith:(NSString*)s
                                             font:(UIFont*)font
                                        textColor:(UIColor*)textColor
                                  backgroundColor:(UIColor*)backgroundColor
                                           indent:(NSInteger)indent;



@end


@interface NSString (NSArrayCombine)

+ (NSString*)arrayDescriptionConbine:(NSArray*)array seprator:(NSString*)seprator;

@end