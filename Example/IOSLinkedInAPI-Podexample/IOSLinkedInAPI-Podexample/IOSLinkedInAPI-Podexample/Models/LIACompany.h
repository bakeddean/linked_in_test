//
//  LIACompany.h
//  IOSLinkedInAPI-Podexample
//
//  Created by Dean Woodward on 14/07/14.
//  Copyright (c) 2014 Eyben Consult ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIACompany : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *websiteUrl;
@property (nonatomic, strong) NSString *companyType;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *locations;
@property (nonatomic, strong) NSString *industries;
@property (nonatomic, strong) NSString *employeeCountRange;
@property (nonatomic, strong) NSNumber *numFollowers;
@property (nonatomic, strong) NSString *logoUrl;
@property (nonatomic, strong) NSString *squareLogoUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
