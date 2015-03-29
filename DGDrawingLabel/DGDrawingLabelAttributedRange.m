//
//  DGDrawingLabelAttributedRange.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/28/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "DGDrawingLabelAttributedRange.h"

@implementation DGDrawingLabelAttributedRange

- (id)initWithAttributes:(NSDictionary *)attributes range:(NSRange)range {
    self = [super init];
    if (self) {
        _attributes = attributes;
        _range = range;
    }
    return self;
}

@end
