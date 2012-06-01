//
//  LRTableViewPart.h
//  OttrJam
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OnCellSelectedBlock)(UITableView *tableView, NSIndexPath *realIndexPath, NSInteger partRow);

@interface LRTableViewPart : NSObject

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *bindings;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, strong) OnCellSelectedBlock onCellSelectedBlock; 

- (NSInteger)numberOfRows;
- (UITableViewCell *)cellForRow:(NSInteger)row;
- (CGFloat)heightForRow:(NSInteger)row;
- (void)didSelectRow:(NSInteger)row realIndexPath:(NSIndexPath *)indexPath;
- (void)observeObject:(id)object forKeyPath:(NSString *)keyPath;

@end