//
//  NLTimelineView.m
//  Appline
//
//  Created by Mike Lee on 7/12/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NLTimelineView.h"
#import "NSColor+TimelineColors.h"
#import "NSDictionary+NLSort.h"
#import "NLSalesReport.h"


@implementation NLTimelineView

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect;
{
    [self drawGridInRect:dirtyRect];
    [self drawBarsInRect:dirtyRect];
    [self drawLegendInRect:dirtyRect];
}

- (void)drawBarsInRect:(NSRect)dirtyRect;
{
    // Draw bars
    NSArray *revenueFigures = [self.datesToRevenueUnits valuesSortedByKeyUsingComparator:@selector(compare:)];
    const NSUInteger maxRevenue = [[revenueFigures valueForKeyPath:@"@max.integerValue"] integerValue];

    NSArray *salesFigures = [self.datesToUnitsSold valuesSortedByKeyUsingComparator:@selector(compare:)];
    const NSUInteger maxUnits = [[salesFigures valueForKeyPath:@"@max.integerValue"] integerValue];

    const NSUInteger numberOfBars = salesFigures.count;
    const CGFloat maxHeightPoints = floorf(self.bounds.size.height / 2.0f);
    const CGFloat maxWidthPoints = self.bounds.size.width;
    const CGFloat barWidth = maxWidthPoints / (CGFloat)numberOfBars;
    const CGFloat unitHeight = maxHeightPoints / (CGFloat)maxUnits;
    const CGFloat revenueHeight = maxHeightPoints / (CGFloat)maxRevenue;

    [salesFigures enumerateObjectsUsingBlock:^(NSNumber *unitsSold, NSUInteger barIndex, BOOL *stop) {
        // Draw sales figures
        CGRect graphBar;
        graphBar.origin.x = barIndex * barWidth;
        graphBar.origin.y = maxHeightPoints;
        graphBar.size.width = barWidth;
        graphBar.size.height = unitsSold.integerValue * unitHeight;

        [[NSColor colorWithSale:nil] setFill];
        NSRectFill(graphBar);

        // Draw revenue figures
        graphBar.size.height = [revenueFigures[barIndex] integerValue] * unitHeight; // or revenueHeight for adjusted revenue figures
        graphBar.origin.y = maxHeightPoints - graphBar.size.height;

        [[NSColor colorWithSale:nil] setFill];
        NSRectFill(graphBar);
    }];
}

- (void)drawGridInRect:(NSRect)dirtyRect;
{

}

- (void)drawLegendInRect:(NSRect)dirtyRect;
{

}

- (void)oldDrawRect:(NSRect)dirtyRect;
{
    // Calculate the dimensions
    NSDate *minDate = [self.sales valueForKeyPath:@"@min.beginDate"];
    NSDate *maxDate = [self.sales valueForKeyPath:@"@max.endDate"];
    NSTimeInterval maxSeconds = [maxDate timeIntervalSinceDate:minDate];

    // FIXME: Account for width of time period e.g. a year with 365 units = a day with 1 unit
    NSInteger maxUnits = [[self.sales valueForKeyPath:@"@max.units"] integerValue];

    const CGFloat maxHeightPoints = floorf(self.bounds.size.height / 2.0f);
    const CGFloat maxWidthPoints = self.bounds.size.width;
    const CGFloat pointsPerSecond = maxWidthPoints / maxSeconds;

    __block CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
    CGContextFillRect(context, self.bounds);
    CGContextSaveGState(context);

    // TODO: Avoid overdrawing by calculating the rectangles first, then drawing them
    [self.sales enumerateObjectsUsingBlock:^(NLSalesReport *sale, NSUInteger index, BOOL *stop) {

        CGRect graphBar;
        graphBar.origin.y = 0.0f;
        graphBar.origin.x = [sale.beginDate timeIntervalSinceDate:minDate] * pointsPerSecond;
        graphBar.size.width = 5.0f; // [sale.endDate timeIntervalSinceDate:sale.beginDate] * secondsPerPoint;
        graphBar.size.height = sale.units.integerValue / maxUnits * maxHeightPoints;

        NSLog(@"%@ : %@", NSStringFromRect(graphBar), sale);

        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, [[NSColor colorWithSale:sale] CGColor]);
        CGContextFillRect(context, graphBar);
        CGContextSetStrokeColorWithColor(context, [[NSColor blueColor] CGColor]);
        CGContextStrokeRect(context, graphBar);
        CGContextRestoreGState(context);
    }];

    CGContextSetStrokeColorWithColor(context, [[NSColor blackColor] CGColor]);
    CGContextStrokeRect(context, self.bounds);
    CGContextRestoreGState(context);
}

@end
