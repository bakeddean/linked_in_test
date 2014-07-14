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
        self.identifier = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.websiteUrl = dictionary[@"websiteUrl"];
        self.companyType = [dictionary valueForKeyPath:@"companyType.name"];
        self.description = dictionary[@"description"];
        self.locations = [self locationsWithDictionary:dictionary];
        self.industries = [self industriesWithDictionary:dictionary];
        self.employeeCountRange = [dictionary valueForKeyPath:@"employeeCountRange.name"];
        self.numFollowers = dictionary[@"numFollowers"];
        self.logoUrl = dictionary[@"logoUrl"];
        self.squareLogoUrl = dictionary[@"squareLogoUrl"];
    }
    return self;
}

// Collect location data.
- (NSString *)locationsWithDictionary:(NSDictionary *)dictionary {
    NSDictionary *values = [dictionary valueForKeyPath:@"locations.values"][0];
    NSString *street = ([values valueForKeyPath:@"address.street1"]);
    NSString *city = ([values valueForKeyPath:@"address.city"]);
    NSString *postCode = ([values valueForKeyPath:@"address.postalCode"]);
    return [NSString stringWithFormat:@"%@ %@, %@",street,city,postCode];
}

// Collect industry data.
- (NSString *)industriesWithDictionary:(NSDictionary *)dictionary {
    NSMutableString *industries = [[NSMutableString alloc] init];
    NSArray *values = [dictionary valueForKeyPath:@"industries.values"];
    for(int i = 0; i < [values count]; i ++){
        [industries appendString:((NSDictionary *)values[i])[@"name"]];
        if(i < [values count]-1)
            [industries appendString:@", "];
    }
    return industries;
}

@end
