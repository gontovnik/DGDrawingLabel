//
//  DGDrawingLabelLayoutData.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "DGDrawingLabelLayoutData.h"

@interface DGDrawingLabelLayoutData () {
    std::vector<DGDrawingLabelLinePosition> _lineOrigins;
    std::vector<DGDrawingLabelLinkData> _links;
}

@end

@implementation DGDrawingLabelLayoutData

- (std::vector<DGDrawingLabelLinePosition> *)lineOrigins {
    return &_lineOrigins;
}

- (std::vector<DGDrawingLabelLinkData> *)links {
    return &_links;
}

- (DGDrawingLabelLinkData)linkAtPoint:(CGPoint)point {
    std::vector<DGDrawingLabelLinkData>::iterator linksBegin = self.links->begin();
    std::vector<DGDrawingLabelLinkData>::iterator linksEnd = self.links->end();

    __block DGDrawingLabelLinkData linkData;
    for (std::vector<DGDrawingLabelLinkData>::iterator linkIt = linksBegin; linkIt != linksEnd; linkIt++) {
        [linkIt->rects enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL *stop) {
            if (CGRectContainsPoint([rectValue CGRectValue], point)) {
                linkData = (*linkIt);
                *stop = YES;
            }
        }];
        if (linkData.link) {
            break;
        }
    }
    return linkData;
}

@end
