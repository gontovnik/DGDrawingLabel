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

@interface DGDrawingLabel : UIView

@property (nonatomic, strong) DGDrawingLabelLayoutData *precalculatedLayout;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth
                                     attributedRanges:(NSArray *)attributedRanges;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                        textAlignment:(NSTextAlignment)textAlignment
                                            textColor:(UIColor *)textColor
                                             maxWidth:(float)maxWidth;

+ (DGDrawingLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                                 font:(UIFont *)font
                                             maxWidth:(float)maxWidth;

+ (void)drawTextInRect:(CGRect)rect withPrecalculatedLayout:(DGDrawingLabelLayoutData *)precalculatedLayout;

@end
