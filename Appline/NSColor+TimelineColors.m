//
//  NSColor+TimelineColors.m
//  Appline
//
//  Created by Mike Lee on 7/12/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSColor+TimelineColors.h"

@implementation NSColor (TimelineColors)

+ (instancetype)colorWithSale:(NLSalesReport *)sale;
{
    // TODO: Return something other than a random color
    return [NSColor colorWithDeviceRed:(arc4random_uniform(255) / 255.0f) green:(arc4random_uniform(255) / 255.0f) blue:(arc4random_uniform(255) / 255.0f) alpha:0.5f];
}

@end
