//
//  LIACompany.h
//  IOSLinkedInAPI-Podexample
//
//  Created by Dean Woodward on 14/07/14.
//  Copyright (c) 2014 Eyben Consult ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIACompany : NSObject

@property (nonatomic, strong) NSNumber *identifier;         // = 14148;
@property (nonatomic, strong) NSString *name;               //= "New Zealand Defence Force";
@property (nonatomic, strong) NSString *websiteUrl;         // = "www.nzdf.mil.nz";
@property (nonatomic, strong) NSString *companyType;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *locations;
@property (nonatomic, strong) NSString *industries;
@property (nonatomic, strong) NSString *employeeCountRange; //name = "10001+";
@property (nonatomic, strong) NSNumber *numFollowers;       // = 3839;
@property (nonatomic, strong) NSString *logoUrl;            // = "http://m.c.lnkd.licdn.com/mpr/mpr/p/5/000/1d5/2b3/39efa8b.png";
@property (nonatomic, strong) NSString *squareLogoUrl;      // = "http://m.c.lnkd.licdn.com/mpr/mpr/p/8/000/1d5/2b9/0fb4c2c.png";

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
