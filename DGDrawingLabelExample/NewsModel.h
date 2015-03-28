//
//  NewsModel.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DGDrawingLabelLayoutData.h"

@interface NewsModel : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)arrayOfModelsFromDictionaries:(NSArray *)dictionaries;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) DGDrawingLabelLayoutData *precalculatedLayout;

@end
