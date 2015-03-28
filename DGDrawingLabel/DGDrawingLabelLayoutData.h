//
//  DGDrawingLabelLayoutData.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#include <vector>
typedef struct
{
    float offset;
    NSTextAlignment alignment;
    CGFloat lineWidth;
} DGDrawingLabelLinePosition;
#endif

@interface DGDrawingLabelLayoutData : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSArray *textLines;

#ifdef __cplusplus
- (std::vector<DGDrawingLabelLinePosition> *)lineOrigins;
#endif

@end
