//
//  NewsModel.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel

#pragma mark -
#pragma mark Constructors

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (dictionary[@"text"]) {
            _text = dictionary[@"text"];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Getters

+ (NSArray *)arrayOfModelsFromDictionaries:(NSArray *)dictionaries {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dictionaries.count];
    
    [dictionaries enumerateObjectsUsingBlock:^(id dictionary, NSUInteger idx, BOOL *stop) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            NewsModel *model = [[NewsModel alloc] initWithDictionary:dictionary];
            [array addObject:model];
        }
    }];
    
    return array;
}

@end
