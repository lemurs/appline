//
//  NSDictionary+NLSort.m
//  Appline
//
//  Created by Mike Lee on 7/12/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSDictionary+NLSort.h"

@implementation NSDictionary (NLSort)

- (NSArray *)valuesSortedByKeyUsingComparator:(SEL)comparator;
{
    NSArray *sortedKeys = [self.allKeys sortedArrayUsingSelector:comparator];
    NSMutableArray *valuesSortedByKey = [NSMutableArray arrayWithCapacity:sortedKeys.count];
    for (id key in sortedKeys)
        [valuesSortedByKey addObject:[self objectForKey:key]];

    return [valuesSortedByKey copy];
}

@end
