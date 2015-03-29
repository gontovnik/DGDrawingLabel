//
//  DGDrawingLabel.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "DGDrawingLabel.h"

@implementation DGDrawingLabel

#pragma mark -
#pragma mark Setters

- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(self.frame.size, frame.size)) {
        [self setNeedsDisplay];
    }
    [super setFrame:frame];
}

#pragma mark -
#pragma mark Calculating layout

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth
                                     attributedRanges:(NSArray *)attributedRanges {
    
    if (!text) {
        return nil;
    }
    
    DGDrawingLabelLayoutData *layout = [[DGDrawingLabelLayoutData alloc] init];
    
    if (!font) {
        font = [UIFont systemFontOfSize:17.0f];
    }
    
    if (!textColor) {
        textColor = [UIColor blackColor];
    }
    
    CTFontRef fontRef = (__bridge CTFontRef)font;
    
    float fontAscent = CTFontGetAscent(fontRef);
    float fontDescent = CTFontGetDescent(fontRef);
    float fontLineHeight = floorf(fontAscent + fontDescent);
    
    NSDictionary *attributes = @{(NSString *)kCTFontAttributeName : (__bridge id)fontRef,
                                 (NSString *)kCTKernAttributeName : [[NSNumber alloc] initWithFloat:0.0f],
                                 (NSString *)kCTForegroundColorAttributeName : (__bridge id)textColor.CGColor};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    if (attributedRanges) {
        [attributedRanges enumerateObjectsUsingBlock:^(DGDrawingLabelAttributedRange *attributedRange, NSUInteger idx, BOOL *stop) {
            [attributedRange.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id attribute, BOOL *stop) {
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeFromNSRange(attributedRange.range), adjustKey(key), (__bridge CFTypeRef)attribute);
            }];
        }];
    }
    
    std::vector<DGDrawingLabelLinePosition> *pLineOrigins = layout.lineOrigins;
    
    CGRect rect = CGRectZero;
    
    NSMutableArray *textLines = [[NSMutableArray alloc] init];
    
    CFIndex lastIndex = 0;
    float currentLineOffset = 0;
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    
    while (true) {
        CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastIndex, maxWidth);
        
        if (lineCharacterCount > 0) {
            CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(lastIndex, lineCharacterCount));
            [textLines addObject:(__bridge id)line];
            
            bool rightAligned = (textAlignment == NSTextAlignmentRight);
            
            CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
            if (CFArrayGetCount(glyphRuns) != 0) {
                if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0)) & kCTRunStatusRightToLeft) {
                    rightAligned = true;
                }
            }
            
            float lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
            
            currentLineOffset += fontLineHeight;
            DGDrawingLabelLinePosition linePosition = { .offset = currentLineOffset,
                .alignment = (rightAligned ? NSTextAlignmentRight : textAlignment),
                .lineWidth = lineWidth};
            pLineOrigins->push_back(linePosition);
            
            rect.size.height += fontLineHeight;
            rect.size.width = MAX(rect.size.width, lineWidth);
            
            if (line != NULL) {
                CFRelease(line);
            }
            
            lastIndex += lineCharacterCount;
        }
        else {
            break;
        }
    }
    
    layout.size = CGSizeMake(floorf(rect.size.width), floorf(rect.size.height + fontLineHeight * 0.4f));
    layout.textLines = textLines;
    
    if (typesetter != NULL) {
        CFRelease(typesetter);
    }
    
    return layout;
}

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth {
    return [DGDrawingLabel calculateLayoutWithText:text
                                              font:font
                                     textAlignment:textAlignment
                                         textColor:textColor
                                          maxWidth:maxWidth
                                  attributedRanges:nil];
}

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                             maxWidth:(float)maxWidth {
    return [DGDrawingLabel calculateLayoutWithText:text
                                              font:font
                                     textAlignment:NSTextAlignmentLeft
                                         textColor:[UIColor blackColor]
                                          maxWidth:maxWidth
                                  attributedRanges:nil];
}

#pragma mark -
#pragma mark Helpers

CFRange CFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

CFStringRef adjustKey(NSString *key) {
    if ([key isEqualToString:NSForegroundColorAttributeName]) {
        return kCTForegroundColorAttributeName;
    }
    
    return (__bridge CFStringRef)key;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    [DGDrawingLabel drawTextInRect:rect withPrecalculatedLayout:_precalculatedLayout];
}

+ (void)drawTextInRect:(CGRect)rect withPrecalculatedLayout:(DGDrawingLabelLayoutData *)precalculatedLayout {
    CFArrayRef lines = (__bridge CFArrayRef)precalculatedLayout.textLines;
    if (!lines) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0f, -1.0f));
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    NSRange linesRange = NSMakeRange(0, numberOfLines);
    
    const std::vector<DGDrawingLabelLinePosition> *pLineOrigins = precalculatedLayout.lineOrigins;
    
    CGFloat lineHeight = rect.size.height;
    if (pLineOrigins->size() > 1) {
        lineHeight = ABS(pLineOrigins->at(0).offset - pLineOrigins->at(1).offset);
    }
    
    CGFloat upperOriginBound = clipRect.origin.y;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + lineHeight;
    
    for (CFIndex lineIndex = linesRange.location; lineIndex < linesRange.location + linesRange.length; lineIndex++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIndex);
        
        const DGDrawingLabelLinePosition &linePosition = pLineOrigins->at(lineIndex);
        
        CGFloat horizontalOffset = 0.0f;
        switch (linePosition.alignment) {
            case NSTextAlignmentCenter:
                horizontalOffset = floorf((rect.size.width - linePosition.lineWidth) / 2.0f);
                break;
            case NSTextAlignmentRight:
                horizontalOffset = rect.size.width - linePosition.lineWidth;
                break;
            default:
                break;
        }
        
        CGPoint lineOrigin = CGPointMake(horizontalOffset, linePosition.offset);
        
        if (lineOrigin.y < upperOriginBound || lineOrigin.y > lowerOriginBound) {
            continue;
        }
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
    }
    
    CGContextRestoreGState(context);
}

@end
