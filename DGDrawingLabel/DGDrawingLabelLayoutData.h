//
//  DGDrawingLabelLayoutData.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DGDrawingLabelLinkType) {
    DGDrawingLabelLinkTypeUsername,
    DGDrawingLabelLinkTypeHashtag,
    DGDrawingLabelLinkTypeURL
};

#ifdef __cplusplus
#include <vector>
typedef struct {
    float horizontalOffset;
    float verticalOffset;
    NSTextAlignment alignment;
    CGFloat lineWidth;
} DGDrawingLabelLinePosition;

typedef struct {
    NSRange range;
    DGDrawingLabelLinkType linkType;
    NSString *link;
    
    NSMutableArray *rects;
} DGDrawingLabelLinkData;
#endif

@interface DGDrawingLabelLayoutData : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSArray *textLines;

#ifdef __cplusplus
- (std::vector<DGDrawingLabelLinePosition> *)lineOrigins;
- (std::vector<DGDrawingLabelLinkData> *)links;
- (DGDrawingLabelLinkData)linkAtPoint:(CGPoint)point;
#endif

@end
