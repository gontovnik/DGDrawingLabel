//
//  DGDrawingLabel.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "DGDrawingLabelLayoutData.h"
#import "DGDrawingLabelAttributedRange.h"

typedef enum {
    DGDrawingLabelDetectionUsernames = 1ULL << 0,
    DGDrawingLabelDetectionHashtags = 1ULL << 1,
    DGDrawingLabelDetectionURLs = 1ULL << 2
} DGDrawingLabelDetection;

@protocol DGDrawingLabelDelegate;
@interface DGDrawingLabel : UIView

@property (nonatomic, unsafe_unretained) id<DGDrawingLabelDelegate> delegate;
@property (nonatomic, strong) DGDrawingLabelLayoutData *precalculatedLayout;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes
                                     attributedRanges:(NSArray *)attributedRanges;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                             maxWidth:(float)maxWidth
                                        linkDetection:(int)linkDetection
                                       linkAttributes:(NSDictionary *)linkAttributes;

+ (void)drawTextInRect:(CGRect)rect withPrecalculatedLayout:(DGDrawingLabelLayoutData *)precalculatedLayout;

@end

@protocol DGDrawingLabelDelegate <NSObject>

@optional

- (void)drawingLabel:(DGDrawingLabel *)drawingLabel didPressAtLink:(NSString *)link withType:(DGDrawingLabelLinkType)linkType;

@end