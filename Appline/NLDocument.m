//
//  NLDocument.m
//  Appline
//
//  Created by Mike Lee on 7/11/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NLDocument.h"
#import "NLTimelineView.h"
#import "NLSalesReport.h"

@interface NLDocument ()
+ (NSDictionary *)columnNamesToPropertyNames;
@property (nonatomic) NSArray *reports;
@property (nonatomic, readonly) NSDictionary *datesToUnitsSold;
@property (nonatomic) NSString *reportsDirectory;
- (void)loadSalesReportAtPath:(NSString *)reportPath entityName:(NSString *)entityName;
- (NSNumber *)unitsSoldBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;
- (NSNumber *)unitsSoldOnDate:(NSDate *)date;
@end


@implementation NLDocument

- (id)init;
{
    if (!(self = [super init]))
        return nil;

    // TODO: Select this when creating a new document
    self.reportsDirectory = [@"~/Documents/New Lemurs/ Sales Reports" stringByExpandingTildeInPath];

    return self;
}


#pragma mark NSObject

- (NSString *)description;
{
    // Produce a simple description that describes the sales period displayed in the document

    NSFetchRequest *salesReport = [NSFetchRequest fetchRequestWithEntityName:kNLSalesReportEntityName];

    NSError *salesFetchingError;
    NSArray *sales = [self.managedObjectContext executeFetchRequest:salesReport error:&salesFetchingError];
    if (!sales)
        [NSApp presentError:salesFetchingError];

    return sales.description;
}


#pragma mark NSDocument

+ (BOOL)autosavesInPlace
{
    return YES;
}
- (NSString *)windowNibName;
{
    return NSStringFromClass([self class]);
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    [self reloadSalesReports];
    [self refreshSalesReports];
}


#pragma mark API

NSString * const kNLReportPathExtension = @"txt";
NSString * const kNLDescriptionKey = @"description";
NSString * const kNLSalesReportToken = @"S_";
NSString * const kNLDailyReportToken = @"D_";
NSString * const kNLWeeklyReportToken = @"W_";
NSString * const kNLMonthlyReportToken = @"M_";
NSString * const kNLYearlyReportToken = @"Y_";
NSString * const kNLSalesReportEntityName = @"SalesReport";
NSString * const kNLDailySalesReportEntityName = @"DailySalesReport";
NSString * const kNLWeeklySalesReportEntityName = @"WeeklySalesReport";
NSString * const kNLMonthlySalesReportEntityName = @"MonthlySalesReport";
NSString * const kNLYearlySalesReportEntityName = @"YearlySalesReport";

+ (NSDictionary *)columnNamesToPropertyNames;
{
    return @{@"Provider" : @"provider",
             @"Provider Country" : @"providerCountry",
             @"SKU" : @"sku",
             @"Developer" : @"developer",
             @"Title" : @"title",
             @"Version" : @"version",
             @"Product Type Identifier" : @"productTypeIdentifier",
             @"Units" : @"units",
             @"Developer Proceeds" : @"developerProceeds",
             @"Begin Date" : @"beginDate",
             @"End Date" : @"endDate",
             @"Customer Currency" : @"customerCurrency",
             @"Country Code" : @"countryCode",
             @"Currency of Proceeds" : @"currencyOfProceeds",
             @"Apple Identifier" : @"appleIdentifier",
             @"Customer Price" : @"customerPrice", 
             @"Promo Code" : @"promoCode", 
             @"Parent Identifier" : @"parentIdentifier", 
             @"Subscription" : @"subscription", 
             @"Period" : @"period"};
}

- (NSDictionary *)datesToRevenueUnits;
{
    NSArray *sales = [self.reports sortedArrayUsingSelector:@selector(beginDate)];

    NSMutableDictionary *datesToRevenueUnits = [NSMutableDictionary dictionary];
    for (NLSalesReport *sale in sales)
        [datesToRevenueUnits setObject:@((sale.developerProceeds.floatValue < 0.01) ? 0 : sale.units.integerValue + [[datesToRevenueUnits objectForKey:sale.beginDate] integerValue]) forKey:sale.beginDate];

    return [datesToRevenueUnits copy];
}

- (NSDictionary *)datesToUnitsSold;
{
    NSArray *sales = [self.reports sortedArrayUsingSelector:@selector(beginDate)];

    NSMutableDictionary *datesToUnitsSold = [NSMutableDictionary dictionary];
    for (NLSalesReport *sale in sales)
        [datesToUnitsSold setObject:@(sale.units.integerValue + [[datesToUnitsSold objectForKey:sale.beginDate] integerValue]) forKey:sale.beginDate];

    return [datesToUnitsSold copy];
}

- (IBAction)refreshSalesReports:(id)sender;
{
    [self refreshSalesReports];
}

- (IBAction)refreshSalesReports;
{
    const NSArray *reportsInSegmentedController = @[kNLDailySalesReportEntityName, kNLWeeklySalesReportEntityName, kNLMonthlySalesReportEntityName, kNLYearlySalesReportEntityName];
    NSUInteger reportIndex = self.segmentedControl.selectedSegment;
    if (reportIndex >= reportsInSegmentedController.count)
        return;

    self.reports = [self reportsWithEntityName:reportsInSegmentedController[reportIndex]];

    self.timelineView.datesToRevenueUnits = self.datesToRevenueUnits;
    self.timelineView.datesToUnitsSold = self.datesToUnitsSold;
    self.timelineView.sales = self.reports;

    [self.timelineView setNeedsDisplay:YES];
}

- (IBAction)reloadSalesReports;
{
    [self loadSalesReportsWithType:kNLYearlyReportToken];
    [self loadSalesReportsWithType:kNLMonthlyReportToken];
    [self loadSalesReportsWithType:kNLWeeklyReportToken];
    [self loadSalesReportsWithType:kNLDailyReportToken];
}

- (void)loadSalesReportAtPath:(NSString *)reportPath entityName:(NSString *)entityName;
{
    NSError *reportLoadingError;
    NSString *reportContents = [NSString stringWithContentsOfFile:reportPath encoding:NSUTF8StringEncoding error:&reportLoadingError];
    if (!reportContents)
        return (void)[NSApp presentError:reportLoadingError];

    __block NSArray *propertyNames;
    __block NSManagedObjectContext *context = self.managedObjectContext;
    [reportContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSArray *properties = [line componentsSeparatedByString:@"\t"];
        if (!propertyNames) { // The first line contains the headers
            propertyNames = properties;
            return;
        }

        NSManagedObject *sale = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        [sale setValue:[[reportPath lastPathComponent] stringByDeletingPathExtension] forKey:@"report"];
        [properties enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            NSString *key = [NLDocument columnNamesToPropertyNames][propertyNames[index]];
            [sale setValue:object forKey:key];
        }];
    }];
}

- (void)loadSalesReportsWithType:(NSString *)typeToken;
{
    NSError *reportFindingError;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.reportsDirectory error:&reportFindingError];
    if (!directoryContents)
        return (void)[NSApp presentError:reportFindingError];

    NSString * const kNLReportFilterFormat = @"%K BEGINSWITH %@";
    NSPredicate *typeFilter = [NSPredicate predicateWithFormat:kNLReportFilterFormat argumentArray:@[kNLDescriptionKey, [kNLSalesReportToken stringByAppendingString:typeToken ? : @""]]];
    NSArray *filteredReports = [directoryContents filteredArrayUsingPredicate:typeFilter];

    const NSDictionary *typeTokensToEntityNames = @{kNLYearlyReportToken : kNLYearlySalesReportEntityName, kNLMonthlyReportToken : kNLMonthlySalesReportEntityName, kNLWeeklyReportToken : kNLWeeklySalesReportEntityName, kNLDailyReportToken : kNLDailySalesReportEntityName};
    [filteredReports enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger index, BOOL *stop) {
        [self loadSalesReportAtPath:[self.reportsDirectory stringByAppendingPathComponent:fileName] entityName:typeTokensToEntityNames[typeToken]];
    }];
}

- (NSArray *)reportsWithEntityName:(NSString *)entityName;
{
    NSFetchRequest *reportRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];

    NSError *reportFetchingError;
    NSArray *reports = [self.managedObjectContext executeFetchRequest:reportRequest error:&reportFetchingError];
    if (!reports)
        [NSApp presentError:reportFetchingError];

    return reports;
}

- (NSNumber *)unitsSoldBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;
{
    NSPredicate *dateFilter = [NSPredicate predicateWithFormat:@"beginDate >= %@ && endDate <= %@" argumentArray:@[beginDate, endDate]];

    NSArray *sales = [self.reports filteredArrayUsingPredicate:dateFilter];

    return [sales valueForKeyPath:@"@sum.units"];
}

- (NSNumber *)unitsSoldOnDate:(NSDate *)date;
{
    return [self unitsSoldBetweenDate:date andDate:date];
}

@end
