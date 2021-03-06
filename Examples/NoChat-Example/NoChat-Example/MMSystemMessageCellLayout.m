//
//  MMSystemMessageCellLayout.m
//  NoChat-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MMSystemMessageCellLayout.h"
#import "NOCMessage.h"
#import "UIFont+NoChat.h"
#import "NSAttributedString+NoChat.h"

@implementation MMSystemMessageCellLayout {
    UIEdgeInsets _textLabelInsets;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"MMSystemMessageCell";
        _chatItem = chatItem;
        _width = width;
        _textLabelInsets = UIEdgeInsetsMake(4, 8, 4, 8);
        [self setupBackgroundImage];
        [self setupAttributedText];
        [self calculateLayout];
    }
    return self;
}

- (void)setupBackgroundImage
{
    _backgroundImage = [MMSystemMessageCellLayout systemMessageBackground];
}

- (void)setupAttributedText
{
    NSString *text = self.message.text;
    NSAttributedString *one = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: [MMSystemMessageCellLayout textFont], NSForegroundColorAttributeName: [MMSystemMessageCellLayout textColor] }];
    _attributedText = one;
}

- (void)calculateLayout
{
    self.height = 0;
    self.backgroundImageViewFrame = CGRectZero;
    self.textLabelFrame = CGRectZero;
    
    if (self.attributedText.length == 0) {
        return;
    }
    
    CGSize limitSize = CGSizeMake(ceil(self.width * 0.75), CGFLOAT_MAX);
    CGSize textLabelSize = [self.attributedText noc_sizeThatFits:limitSize];
    
    CGFloat vPadding = 4;
    
    self.textLabelFrame = CGRectMake(self.width/2 - textLabelSize.width/2, vPadding, textLabelSize.width, textLabelSize.height);
    self.backgroundImageViewFrame = CGRectMake(self.textLabelFrame.origin.x - _textLabelInsets.left, self.textLabelFrame.origin.y - _textLabelInsets.top, self.textLabelFrame.size.width + _textLabelInsets.left + _textLabelInsets.right, self.textLabelFrame.size.height + _textLabelInsets.top + _textLabelInsets.bottom);
    
    self.height = vPadding * 2 + self.backgroundImageViewFrame.size.height;
}

- (NOCMessage *)message
{
    return (NOCMessage *)self.chatItem;
}

@end

@implementation MMSystemMessageCellLayout (MMStyle)

+ (UIFont *)textFont
{
    static UIFont *_textFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _textFont = [UIFont systemFontOfSize:15];
    });
    return _textFont;
}

+ (UIColor *)textColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)textBackgroundColor
{
    static UIColor *_textBackgroundColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _textBackgroundColor = [UIColor colorWithWhite:0.2 alpha:0.25];
    });
    return _textBackgroundColor;
}

+ (UIImage *)systemMessageBackground
{
    static UIImage *_systemMessageBackground = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *rawImage = [self generateSystemMessageBackground];
        _systemMessageBackground = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width/2) topCapHeight:(int)(rawImage.size.height/2)];
    });
    return _systemMessageBackground;
}

+ (UIImage *)generateSystemMessageBackground
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(21, 21), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0.5f, 0, 20, 20);
    
    CGFloat radius = 4.0f;
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSaveGState(context);
    
    UIColor *color = [UIColor colorWithWhite:0.2 alpha:0.25];
    
    [color setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset(bounds, -2, -2));
    
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, visiblePath);
    CGContextClip(context);
    
    CGContextSaveGState(context);
    
    [color setFill];
    CGContextAddPath(context, path);
    CGContextEOFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
