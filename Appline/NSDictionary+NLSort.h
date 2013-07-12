//
//  NSDictionary+NLSort.h
//  Appline
//
//  Created by Mike Lee on 7/12/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@interface NSDictionary (NLSort)

- (NSArray *)valuesSortedByKeyUsingComparator:(SEL)comparator;

@end
