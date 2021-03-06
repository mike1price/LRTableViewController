//
//  LRTableSection.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "LRTableViewSection.h"
#import "LRTableViewPart.h"

@interface LRTableViewSection() {
    NSMutableArray *_parts;
}

- (LRTableViewPart *)partForRow:(NSInteger)row; 
- (NSInteger)rowOffsetForPart:(LRTableViewPart *)part;

@end

@implementation LRTableViewSection

@synthesize tableView = _tableView, headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize hideHeaderWhenEmpty;
@synthesize delegate = _delegate;
@synthesize tag;

+ (LRTableViewSection *)sectionWithParts:(LRTableViewPart *)part1, ...
{
    LRTableViewSection *section = [[LRTableViewSection alloc] init];
    
    LRTableViewPart *object;
    va_list argumentList;
    
    va_start(argumentList, part1);
    object = part1;
    
    while(1)
    {
        if(!object) break; // we're using 'nil' as a list terminator
        
        [section addPart:object];
        object = va_arg(argumentList, LRTableViewPart *);
    }
    
    va_end(argumentList);
    
    return [section autorelease];
}

- (void)dealloc
{
    self.delegate = nil;
    
    [_parts release]; _parts = nil;
    
    self.tableView = nil;
    self.headerView = nil;
    self.headerTitle = nil;
    
    [super dealloc];
}

- (NSString *)headerTitle
{
    if (self.hideHeaderWhenEmpty) {
        BOOL hide = YES;
        for (LRTableViewPart *part in _parts) {
            if (part.numberOfRows > 0) {
                hide = NO;
                break;
            }
        }
        
        if (!hide) {
            return _headerTitle;
        } else {
            return nil;
        }
    } else {
        return _headerTitle;
    }
}

- (UIView *)headerView
{
    if (self.hideHeaderWhenEmpty) {
        BOOL hide = YES;
        for (LRTableViewPart *part in _parts) {
            if (part.numberOfRows > 0) {
                hide = NO;
                break;
            }
        }
        
        if (!hide) {
            return _headerView;
        } else {
            return nil;
        }
    } else {
        return _headerView;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _parts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setTableView:(UITableView *)tableView
{
    if (_tableView != tableView) {
        if (_tableView != nil) {
            [_tableView release];
            _tableView = nil;
        }
        
        _tableView = tableView;
        
        if (_tableView != nil) {
            [_tableView retain];
            
            for (LRTableViewPart *part in _parts) {
                part.tableView = _tableView;
            }
        }
    }
}

- (void)addPart:(LRTableViewPart *)part
{
    part.tableView = self.tableView;
    part.delegate = self;
    
    [_parts addObject:part];
}

- (void)removeAllParts
{
    for (LRTableViewPart *part in _parts) {
        [part stopObserving];
    }
    
//    [_parts removeAllObjects];
}

- (LRTableViewPart *)partForRow:(NSInteger)row
{
    int partIndex = 0;
    int sumRows = 0;
    
    LRTableViewPart *part = (LRTableViewPart *)[_parts objectAtIndex:partIndex];
    
    while (row >= (sumRows += [part numberOfRows]) && partIndex < _parts.count) {
        part = (LRTableViewPart *)[_parts objectAtIndex:++partIndex];
    }
    return part;
}

- (NSInteger)rowOffsetForPart:(LRTableViewPart *)part
{
    int offset = 0;
    
    for (LRTableViewPart *_part in _parts) {
        if ([_part isEqual:part]) {
            break;
        } else {
            offset += [_part numberOfRows];
        }
    }
    
    return offset;
}

- (NSInteger)numberOfRows
{
    int num = 0;
    
    for (LRTableViewPart *part in _parts) {
        num += [part numberOfRows];
    }
    
    return num;
}

- (UITableViewCell *)cellForRow:(NSInteger)row
{
    LRTableViewPart *part = [self partForRow:row];
    int rowOffset = [self rowOffsetForPart:part];
    
    return [part cellForRow:(row - rowOffset)];
}

- (CGFloat)heightForRow:(NSInteger)row
{
    LRTableViewPart *part = [self partForRow:row];
    int rowOffset = [self rowOffsetForPart:part];
    
    return [part heightForRow:(row - rowOffset)];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRTableViewPart *part = [self partForRow:indexPath.row];
    int rowOffset = [self rowOffsetForPart:part];
    
    [part didSelectRow:(indexPath.row - rowOffset) realIndexPath:indexPath];
}


#pragma mark - LRTableViewPartDelegate

- (void)tableViewPart:(LRTableViewPart *)part insertRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation
{
    if (part != nil && indexset != nil && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(LRTableViewSectionDelegate)]) {
        NSMutableIndexSet *newSet = [[NSMutableIndexSet alloc] init];
        int rowOffset = [self rowOffsetForPart:part];
        
        [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [newSet addIndex:(idx + rowOffset)];
        }];
        
        [self.delegate tableViewSection:self insertRowsInIndexSet:newSet withRowAnimation:animation];
        
        [newSet release];
    }
}

- (void)tableViewPart:(LRTableViewPart *)part deleteRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation
{
    if (part != nil && indexset != nil && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(LRTableViewSectionDelegate)]) {
        NSMutableIndexSet *newSet = [[NSMutableIndexSet alloc] init];
        int rowOffset = [self rowOffsetForPart:part];
        
        [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [newSet addIndex:(idx + rowOffset)];
        }];
        
        [self.delegate tableViewSection:self deleteRowsInIndexSet:newSet withRowAnimation:animation];
        
        [newSet release];
    }
}


@end
