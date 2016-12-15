//
//  NoteParagraph.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteParagraph.h"

@implementation NoteParagraphModel




+ (NoteParagraphModel*)noteParagraphFromString:(NSString*)string
{
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    
    //没有css标记的时候必须填style="".
    NSRange range0 = [string rangeOfString:@"<p style=\""];
    NSRange range1 = [string rangeOfString:@"\">"];
    NSRange range2 = [string rangeOfString:@"</p>"];
    if(range0.length > 0 && range1.length > 0 && range2.length > 0
       && range0.location == 0 && range2.location == string.length - @"</p>".length
       && range1.location > range0.location && range2.location > range1.location) {
        
        NSString *styleString = [string substringWithRange:NSMakeRange(range0.location + range0.length, range1.location - (range0.location + range0.length))];
        
        noteParagraph.content = [string substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))];
        noteParagraph.content = [NSString htmDecode:noteParagraph.content];
        
        noteParagraph.styleDictionay = [self styleParseFromString:styleString];
    }
    else {
        NSLog(@"#error - ParagraphString format checked failed. [%@]", string);
        noteParagraph.content = @"";
    }
    
    return noteParagraph;
}


+ (NSString*)noteParagraphToString:(NoteParagraphModel*)noteParagraph
{
    return [NSString stringWithFormat:
            @"<p style=\"%@\">%@</p>"
            , [NoteParagraphModel styleDictionaryToString:noteParagraph.styleDictionay]
            , [NSString htmEncode:noteParagraph.content]];
}


+ (NSMutableDictionary*)styleParseFromString:(NSString*)styleString
{
    NSMutableDictionary *styleDictionary = [[NSMutableDictionary alloc] init];
    NSArray<NSString*> *styles = [styleString componentsSeparatedByString:@";"];
    for(NSString *style1String in styles) {
        NSArray<NSString*> *style1pv = [style1String componentsSeparatedByString:@":"];
        if(style1pv.count == 2) {
            NSString *styleProperty = [style1pv[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            styleProperty = [styleProperty lowercaseString];
            NSString *styleValue = [style1pv[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            styleValue = [styleValue lowercaseString];
            styleDictionary[styleProperty] = styleValue;
        }
    }
    
    return styleDictionary;
}


+ (NSString*)styleDictionaryToString:(NSDictionary*)styleDictionary
{
    if(styleDictionary.count == 0) {
        return @"";
    }
    
    NSMutableString *styleString = [[NSMutableString alloc] init];
    for(NSInteger idx = 0; idx < styleDictionary.count ; idx ++) {
        [styleString appendFormat:@"%@: %@", styleDictionary.allKeys[idx], styleDictionary.allValues[idx]];
        if(idx != styleDictionary.count - 1) {
            [styleString appendString:@";"];
        }
    }
    
    return [NSString stringWithString:styleString];
}


//暂时style的value都用字符串表示. 不转换为具体的颜色, 大小值.
+ (NSString*)styleGenerateToString:(NSDictionary*)style
{
    NSMutableString *styleString = [[NSMutableString alloc] init];
    
    NSString *property;
    NSString *value;
    
    property = @"color";
    value = style[property];
    if(!value) {
        value = style[[property uppercaseString]];
    }
    if(value) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"font-size";
    value = style[property];
    if(!value) {
        value = style[[property uppercaseString]];
    }
    if(value) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"font-style";
    value = style[property];
    if([value isEqualToString:@"italic"]) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"text-decoration";
    value = style[property];
    if([value isEqualToString:@"underline"]) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"border";
    value = style[property];
    if([value isEqualToString:@"underline"]) {
        [styleString appendFormat:@"%@: %@ %@;", property, value, @"solid"];
    }
    
    return [NSString stringWithString:styleString];
}


+ (NSArray<NoteParagraphModel*> *)noteParagraphsFromString:(NSString*)string
{
    NSMutableArray *noteParagraphs = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> *paragraphStrings = [string componentsSeparatedByString:@"</p>"];
    for(NSString *paragraphString0 in paragraphStrings) {
        if(paragraphString0.length < 3) {
            continue;
        }
        
        NSString *paragraphString = [paragraphString0 stringByAppendingString:@"</p>"];
        paragraphString = [paragraphString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NoteParagraphModel *noteParagraph = [NoteParagraphModel noteParagraphFromString:paragraphString];
        
        [noteParagraphs addObject:noteParagraph];
    }
    
    return [NSArray arrayWithArray:noteParagraphs];
}


+ (NSString*)noteParagraphsToString:(NSArray<NoteParagraphModel*> *)noteParagraphs
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    for(NoteParagraphModel *noteParagraph in noteParagraphs) {
        [string appendString:[NoteParagraphModel noteParagraphToString:noteParagraph]];
    }
    
    return [NSString stringWithString:string];
}


- (UIFont*)textFont
{
    CGFloat fontSize = self.isTitle?18:16;
    NSString *fontString = self.styleDictionay[@"font-size"];
    CGFloat ptSize;
    if([fontString hasSuffix:@"px"] && (ptSize = [fontString floatValue]) >= 1.0 && ptSize < 100.0) {
        fontSize = ptSize;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    if([self.styleDictionay[@"font-weight"] isEqualToString:@"bold"]) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    else {
        
    }
    //斜体.测试中发现对中文不支持.使用obliq方法.
    //font = [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
    return font;
}


- (UIColor*)textColor
{
    UIColor *textColor = [UIColor blackColor];
    NSString *fontString = self.styleDictionay[@"color"];
    if(fontString.length > 0 && nil != (textColor = [UIColor colorFromString:fontString])) {
        
    }
    else {
        textColor = [UIColor blackColor];
    }
    
    return textColor;
}


- (UIColor*)backgroundColor
{
    return [UIColor whiteColor];
}


- (NSMutableAttributedString*)attributedTextGeneratedOnSn:(NSInteger)sn andEditMode:(BOOL)editMode
{
    NSString *content = @"";
    BOOL textLight = NO;
    if(self.content.length == 0) {
        if(editMode) {
            textLight = YES;
            if(self.isTitle) {
                content = @"请输入标题.";
            }
            else {
                content = [NSString stringWithFormat:@"第 %zd 段.", sn];
            }
        }
        else {
            if(sn == 0) {
                content = @"无标题";
            }
            else {
                content = @"";
            }
        }
    }
    else {
        content = self.content;
    }
    
    NSLog(@"sn: %zd, editMode: %zd, self.content: %@, content: %@", sn, editMode, self.content, content);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange rangeAll = NSMakeRange(0, attributedString.length);
    
    //字体,颜色.
    UIFont *font    = [self textFont];
    UIColor *color  = textLight ? [UIColor lightGrayColor] : [self textColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:rangeAll];
    
    //对齐方式.
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 6.0;
    if([self.styleDictionay[@"text-align"] isEqualToString:@"center"] ||  sn == 0) {
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }
    NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString addAttributes:attributes range:rangeAll];
    
    //斜体.
    if([self.styleDictionay[@"font-style"] isEqualToString:@"italic"]) {
        NSLog(@"attributedString add : italic");
        [attributedString addAttribute:NSObliquenessAttributeName value:@0.5 range:rangeAll];
    }
    
    //下划线.
    if([self.styleDictionay[@"text-decoration"] isEqualToString:@"underline"]) {
        NSLog(@"attributedString add : underline");
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:rangeAll];
    }
    
    //边框.
    NSString *borderPx = self.styleDictionay[@"border"];
    NSInteger px = 0;
    if(borderPx.length > 0 && [borderPx hasSuffix:@"px"] && (px = [borderPx integerValue]) > 0) {
        NSLog(@"attributedString add : border");
        //[attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:rangeAll];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeColor = color;//[UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
        border.strokeWidth = 1;
        border.lineStyle = YYTextLineStyleSingle;
        border.cornerRadius = 0;
        border.insets = UIEdgeInsetsMake(1, 1, 1, 1);
        attributedString.yy_textBackgroundBorder = border;
    }
    
    NS0Log(@"%@", attributedString);
    
    return attributedString;
}


- (NSString*)description
{
    return [NoteParagraphModel noteParagraphToString:self];
}


- (NoteParagraphModel*)copy
{
    NSLog(@"copy");
    NoteParagraphModel *noteParagraphCopy = [[NoteParagraphModel alloc] init];
    noteParagraphCopy.content = self.content;
    noteParagraphCopy.image = self.image;
    noteParagraphCopy.styleDictionay = [[NSMutableDictionary alloc] initWithDictionary:self.styleDictionay];
    
    return noteParagraphCopy;
}

@end