//
//  Sale.m
//  Appline
//
//  Created by Mike Lee on 7/11/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NLSalesReport.h"


@implementation NLSalesReport

@dynamic appleIdentifier, beginDate, countryCode, currencyOfProceeds, customerCurrency, customerPrice, developer, developerProceeds, endDate, parentIdentifier, period, productTypeIdentifier, promoCode, provider, providerCountry, report, sku, subscription, title, units, version;

- (NSString *)description;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;

    return [NSString stringWithFormat:@"%@ x %@ at %@ %@ in %@ from %@ to %@", self.version, self.units, self.customerPrice, self.customerCurrency, self.countryCode, [dateFormatter stringFromDate:self.beginDate], [dateFormatter stringFromDate:self.endDate]];
}

- (void)setValue:(id)value forKey:(NSString *)key;
{
    NSDictionary *properites = self.entity.propertiesByName;
    NSAttributeDescription *attribute = properites[key];
    NSAssert([attribute isKindOfClass:[NSAttributeDescription class]], @"Property %@ is not an attribute. It is: %@", key, attribute);

    switch (attribute.attributeType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            value = [NSNumber numberWithInteger:[value integerValue]];
            break;

        case NSDoubleAttributeType:
            value = [NSNumber numberWithDouble:[value doubleValue]];
            break;
            
        case NSFloatAttributeType:
            value = [NSNumber numberWithFloat:[value floatValue]];
            break;

        case NSDecimalAttributeType:
            value = [NSDecimalNumber decimalNumberWithString:value];
            break;

        case NSBooleanAttributeType:
            value = [NSNumber numberWithBool:[value boolValue]];
            break;

        case NSDateAttributeType:
            value = [NSDate dateWithNaturalLanguageString:value];
            break;

        case NSBinaryDataAttributeType:
            ; // TODO: Handle this case
            break;

        default:
            break;
    }

    [super setValue:value forKey:key];
}

@end
