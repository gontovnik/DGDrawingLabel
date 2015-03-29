//
//  DGDrawingLabelAttributedRange.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/28/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGDrawingLabelAttributedRange : NSObject

- (id)initWithAttributes:(NSDictionary *)attributes range:(NSRange)range;

@property (nonatomic) NSRange range;
@property (nonatomic, strong) NSDictionary *attributes;

@end
