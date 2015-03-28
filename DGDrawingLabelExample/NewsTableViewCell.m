//
//  NewsTableViewCell.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "NewsTableViewCell.h"

static const CGFloat kVerticalSpacing = 10.0f;

@interface NewsTableViewCell () {
    DGDrawingLabel *textLabel;
}

@end

@implementation NewsTableViewCell

#pragma mark -
#pragma mark Constructors

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        textLabel = [[DGDrawingLabel alloc] init];
        textLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:textLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark -
#pragma mark Setters

- (void)setPrecalculatedLayout:(DGDrawingLabelLayoutData *)precalculatedLayout {
    textLabel.precalculatedLayout = precalculatedLayout;
    
    CGRect frame = CGRectZero;
    frame.origin.y = kVerticalSpacing;
    frame.size.width = self.contentView.bounds.size.width;
    frame.size.height = precalculatedLayout.size.height;
    textLabel.frame = frame;
}

#pragma mark -
#pragma mark Getters

+ (CGFloat)heightWithLayout:(DGDrawingLabelLayoutData *)layout {
    return layout.size.height + kVerticalSpacing * 2;
}

#pragma mark -
#pragma mark Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    textLabel.precalculatedLayout = nil;
}

@end
