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
}

@end

@implementation DGDrawingLabelLayoutData

- (std::vector<DGDrawingLabelLinePosition> *)lineOrigins {
    return &_lineOrigins;
}

@end
