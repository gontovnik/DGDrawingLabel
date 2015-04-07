//
//  DGDrawingLabel.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "DGDrawingLabel.h"

@interface DGDrawingLabel () {
    BOOL isTouchMoved;
}

@property (nonatomic, assign) DGDrawingLabelLinkData selectedLinkData;

@end

@implementation DGDrawingLabel

#pragma mark -
#pragma mark Setters

- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(self.frame.size, frame.size)) {
        [self setNeedsDisplay];
    }
    [super setFrame:frame];
}

- (void)setSelectedLinkData:(DGDrawingLabelLinkData)selectedLinkData {
    _selectedLinkData = selectedLinkData;
    [self setNeedsDisplay]; // TODO: Redraw with highlighted link
}

#pragma mark -
#pragma mark Getters

+ (NSArray *)arrayOfLinksForType:(DGDrawingLabelLinkType)linkType inText:(NSString *)text {
    switch (linkType) {
        case DGDrawingLabelLinkTypeHashtag:
        {
            NSError *error = nil;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)#([\\w\\_]+)?"
                                                                              options:0
                                                                                error:&error];
            if (!error) {
                return [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
            break;
        }
        case DGDrawingLabelLinkTypeUsername:
        {
            NSError *error = nil;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)@([\\w\\_]+)?"
                                                                              options:0
                                                                                error:&error];
            if (!error) {
                return [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
            break;
        }
        case DGDrawingLabelLinkTypeURL:
        {
            NSError *error = nil;
            NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
            if (!error) {
                return [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
            break;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark -
#pragma mark Calculating layout

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes
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
    
    // TODO: Fix issue with differents fonts at the same time
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
    
    std::vector<DGDrawingLabelLinkData> *links = layout.links;
    
    if (linkDetection & DGDrawingLabelDetectionURLs) {
        NSArray *URLs = [DGDrawingLabel arrayOfLinksForType:DGDrawingLabelLinkTypeURL inText:text];
        [URLs enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult, NSUInteger idx, BOOL *stop) {
            DGDrawingLabelLinkData link = { .linkType = DGDrawingLabelLinkTypeURL, .link = [text substringWithRange:textCheckingResult.range], .range = textCheckingResult.range };
            links->push_back(link);
        }];
    }
    
    if (linkDetection & DGDrawingLabelDetectionHashtags) {
        NSArray *hashtags = [DGDrawingLabel arrayOfLinksForType:DGDrawingLabelLinkTypeHashtag inText:text];
        [hashtags enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult, NSUInteger idx, BOOL *stop) {
            DGDrawingLabelLinkData link = { .linkType = DGDrawingLabelLinkTypeHashtag, .link = [text substringWithRange:textCheckingResult.range], .range = textCheckingResult.range };
            links->push_back(link);
        }];
    }
    
    if (linkDetection & DGDrawingLabelDetectionUsernames) {
        NSArray *usernames = [DGDrawingLabel arrayOfLinksForType:DGDrawingLabelLinkTypeUsername inText:text];
        [usernames enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult, NSUInteger idx, BOOL *stop) {
            DGDrawingLabelLinkData link = { .linkType = DGDrawingLabelLinkTypeUsername, .link = [text substringWithRange:textCheckingResult.range], .range = textCheckingResult.range };
            links->push_back(link);
        }];
    }
    
    if (!links->empty()) {
        std::vector<DGDrawingLabelLinkData>::iterator linksBegin = layout.links->begin();
        std::vector<DGDrawingLabelLinkData>::iterator linksEnd = layout.links->end();

        if (linkAttributes) {
            for (std::vector<DGDrawingLabelLinkData>::iterator linkIt = linksBegin; linkIt != linksEnd; linkIt++) {
                [linkAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id attribute, BOOL *stop) {
                    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeFromNSRange(linkIt->range), adjustKey(key), (__bridge CFTypeRef)attribute);
                }];
            }
        }
    }
    
    std::vector<DGDrawingLabelLinePosition> *lineOrigins = layout.lineOrigins;
    
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
            
            NSTextAlignment alignment = (rightAligned ? NSTextAlignmentRight : textAlignment);
            CGFloat horizontalOffset = 0.0f;
            switch (alignment) {
                case NSTextAlignmentCenter:
                    horizontalOffset = floorf((maxWidth - lineWidth) / 2.0f);
                    break;
                case NSTextAlignmentRight:
                    horizontalOffset = maxWidth - lineWidth;
                    break;
                default:
                    break;
            }
            
            DGDrawingLabelLinePosition linePosition = { .horizontalOffset = static_cast<float>(horizontalOffset),
                                                        .verticalOffset = currentLineOffset,
                                                        .alignment = alignment,
                                                        .lineWidth = lineWidth };
            
            lineOrigins->push_back(linePosition);
            
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
    
    if (!links->empty()) {
        CGSize layoutSize = layout.size;
        
        std::vector<DGDrawingLabelLinkData>::iterator linksBegin = layout.links->begin();
        std::vector<DGDrawingLabelLinkData>::iterator linksEnd = layout.links->end();
        
        for (std::vector<DGDrawingLabelLinkData>::iterator linkIt = linksBegin; linkIt != linksEnd; linkIt++) {
            
            for (int lineIdx = 0; lineIdx < textLines.count; lineIdx++) {
                CTLineRef line = (__bridge CTLineRef)[textLines objectAtIndex:lineIdx];
                CFRange lineRange = CTLineGetStringRange(line);
                
                const DGDrawingLabelLinePosition &linePosition = lineOrigins->at(lineIdx);
                CGPoint lineOrigin = CGPointMake(linePosition.horizontalOffset, linePosition.verticalOffset);
                
                NSRange intersectionRange = NSIntersectionRange(linkIt->range, NSMakeRange(lineRange.location, lineRange.length));
                if (intersectionRange.length != 0) {
                    float startX = 0.0f;
                    float endX = 0.0f;
                    
                    startX = ceilf(CTLineGetOffsetForStringIndex(line, intersectionRange.location, NULL) + lineOrigin.x);
                    endX = ceilf(CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, NULL) + lineOrigin.x);
                    
                    if (startX > endX) {
                        float tmp = startX;
                        startX = endX;
                        endX = tmp;
                    }
                    
                    bool tillEndOfLine = false;
                    if (intersectionRange.location + intersectionRange.length >= lineRange.location + lineRange.length && ABS(endX - layoutSize.width) < 16)
                    {
                        tillEndOfLine = true;
                        endX = layoutSize.width + lineOrigin.x;
                    }
                    
                    CGRect region = CGRectMake(ceilf(startX - 3),
                                               ceilf(lineOrigin.y - fontLineHeight + fontLineHeight * 0.1f),
                                               ceilf(endX - startX + 6),
                                               ceilf(fontLineHeight * 1.1));
                    
                    if (!linkIt->rects) {
                        linkIt->rects = [NSMutableArray array];
                    }
                    NSValue *regionValue = [NSValue valueWithCGRect:region];
                    [linkIt->rects addObject:regionValue];
                }
            }
            
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
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes {
    return [DGDrawingLabel calculateLayoutWithText:text
                                              font:font
                                     textAlignment:textAlignment
                                         textColor:textColor
                                          maxWidth:maxWidth
                                     linkDetection:linkDetection
                                    linkAttributes:linkAttributes
                                  attributedRanges:nil];
}

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes {
    return [DGDrawingLabel calculateLayoutWithText:text
                                              font:font
                                     textAlignment:NSTextAlignmentLeft
                                         textColor:[UIColor blackColor]
                                          maxWidth:maxWidth
                                     linkDetection:linkDetection
                                    linkAttributes:linkAttributes
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

NSRange NSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
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
    
    const std::vector<DGDrawingLabelLinePosition> *lineOrigins = precalculatedLayout.lineOrigins;
    
    CGFloat lineHeight = rect.size.height;
    if (lineOrigins->size() > 1) {
        lineHeight = ABS(lineOrigins->at(0).verticalOffset - lineOrigins->at(1).verticalOffset);
    }
    
    CGFloat upperOriginBound = clipRect.origin.y;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + lineHeight;
    
    for (CFIndex lineIndex = linesRange.location; lineIndex < linesRange.location + linesRange.length; lineIndex++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIndex);
        
        const DGDrawingLabelLinePosition &linePosition = lineOrigins->at(lineIndex);
        
        CGPoint lineOrigin = CGPointMake(linePosition.horizontalOffset, linePosition.verticalOffset);
        
        if (lineOrigin.y < upperOriginBound || lineOrigin.y > lowerOriginBound) {
            continue;
        }
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchMoved = NO;
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    DGDrawingLabelLinkData linkData = [self.precalculatedLayout linkAtPoint:touchLocation];
    
    if (linkData.link) {
        self.selectedLinkData = linkData;
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    isTouchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (isTouchMoved) {
        self.selectedLinkData = {};
        return;
    }
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    DGDrawingLabelLinkData linkData = [self.precalculatedLayout linkAtPoint:touchLocation];
    
    if (linkData.link) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawingLabel:didPressAtLink:withType:)]) {
            [self.delegate drawingLabel:self didPressAtLink:linkData.link withType:linkData.linkType];
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
    
    self.selectedLinkData = {};
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.selectedLinkData = {};
}

@end
