//
//  NewsViewController.m
//  DGDrawingLabelExample
//
//  Created by Danil Gontovnik on 3/26/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "NewsViewController.h"

#import "NewsTableViewCell.h"
#import "DGDrawingLabel.h"

#import "NewsModel.h"

@interface NewsViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    NSArray *_news;
}

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([NewsTableViewCell class])];
    _tableView.tableFooterView = [UIView new];
    self.view = _tableView;
    
    [self loadNews];
}

#pragma mark -
#pragma mark Methods

- (void)loadNews {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"news" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        if (json[@"news"]) {
            _news = [NewsModel arrayOfModelsFromDictionaries:json[@"news"]];
        }
    }
}

#pragma mark -
#pragma mark Getters

- (DGDrawingLabelLayoutData *)precalculatedLayoutForModelAtIndexPath:(NSIndexPath *)indexPath {
    NewsModel *model = _news[indexPath.row];
    if (!model.precalculatedLayout) {
        model.precalculatedLayout = [DGDrawingLabel calculateLayoutWithText:model.text
                                                                       font:[UIFont systemFontOfSize:16.0f]
                                                              textAlignment:NSTextAlignmentCenter
                                                                  textColor:[UIColor grayColor]
                                                                   maxWidth:_tableView.bounds.size.width];
    }
    return model.precalculatedLayout;
}

#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NewsTableViewCell class]) forIndexPath:indexPath];
    
    [cell setPrecalculatedLayout:[self precalculatedLayoutForModelAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NewsTableViewCell heightWithLayout:[self precalculatedLayoutForModelAtIndexPath:indexPath]];
}

@end
