//
//  Sale.h
//  Appline
//
//  Created by Mike Lee on 7/11/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NLSalesReport : NSManagedObject

@property (nonatomic) NSDate *beginDate, *endDate;
@property (nonatomic) NSDecimalNumber *customerPrice, *developerProceeds;
@property (nonatomic) NSNumber *units;
@property (nonatomic) NSString *appleIdentifier, *countryCode, *currencyOfProceeds, *customerCurrency, *developer, *parentIdentifier, *period, *productTypeIdentifier, *promoCode, *provider, *providerCountry, *report, *sku, *subscription, *title, *version;

@end
