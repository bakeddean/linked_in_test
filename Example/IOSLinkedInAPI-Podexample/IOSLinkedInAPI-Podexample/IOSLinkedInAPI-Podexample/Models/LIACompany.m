//
//  LIACompany.m
//  IOSLinkedInAPI-Podexample
//
//  Created by Dean Woodward on 14/07/14.
//  Copyright (c) 2014 Eyben Consult ApS. All rights reserved.
//

#import "LIACompany.h"
#import <objc/runtime.h>

@implementation LIACompany

// Initialise the Company model using the given dictionary.
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if(self) {
        id currentClass = [self class];
        NSString *propertyName;
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            
            id value;
            if([propertyName isEqualToString:@"locations"])
                value = [self locationWithDictionary:dictionary];
            else if([propertyName isEqualToString:@"companyType"] || [propertyName isEqualToString:@"employeeCountRange"] || [propertyName isEqualToString:@"industries"])
                value = [self nameForProperty:propertyName WithDictionary:dictionary];
//            else if([propertyName isEqualToString:@"employeeCountRange"])
//                value = @"bob";
//            else if([propertyName isEqualToString:@"industries"])
//                value = @"bob";

            #warning Fix for id & industries
            
            
            else
                value = [dictionary objectForKey:propertyName];
            
            [self setValue:value forKey:propertyName];
        }
        free(properties);
    }
    return self;
}

// Return address string.
- (NSString *)locationWithDictionary:(NSDictionary *)dictionary {
    NSString *street = ([dictionary valueForKeyPath:@"locations.values.address.street1"])[0];
    NSString *city = ([dictionary valueForKeyPath:@"locations.values.address.city"])[0];
    NSString *postCode = ([dictionary valueForKeyPath:@"locations.values.address.postalCode"])[0];
    return [NSString stringWithFormat:@"%@ %@, %@",street,city,postCode];
}

- (id)nameForProperty:(NSString *)propertyName WithDictionary:(NSDictionary *)dictionary {
    if([dictionary valueForKeyPath:[NSString stringWithFormat:@"%@.name",propertyName]])
        return [dictionary valueForKeyPath:[NSString stringWithFormat:@"%@.name",propertyName]];
    return [dictionary valueForKeyPath:[NSString stringWithFormat:@"%@.values.name",propertyName]];
}

// companyType/name
// employeeCountRange/name
// industries/values/name = Military

// locations/values/address/city = Wellington;
// locations/values/address/postalCode = 0612;
// locations/values/address/street1 = "2-12 Aitken St";

// locations/values/contactInfo/fax = "";
// locations/values/contactInfo/phone1 = "";

@end
