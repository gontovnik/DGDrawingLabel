//
//  NewsTableViewCell.h
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGDrawingLabel.h"

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic) id<DGDrawingLabelDelegate> drawingLabelDelegate;

- (void)setPrecalculatedLayout:(DGDrawingLabelLayoutData *)precalculatedLayout;

+ (CGFloat)heightWithLayout:(DGDrawingLabelLayoutData *)layout;

@end
