//
//  LIAViewController.m
//  IOSLinkedInAPI-Podexample
//
//  Created by Jacob von Eyben on 16/12/13.
//  Copyright (c) 2013 Eyben Consult ApS. All rights reserved.
//

#import "LIAViewController.h"
#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInClientExampleCredentials.h"
#import "LIALinkedInApplication.h"

#define LINKEDIN_TOKEN_KEY @"linkedin_token"    // Move this from httpclient.m to .h
#define COLOR_RGBA(RED,GREEN,BLUE,ALPHA) [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:ALPHA/1.0f]

@interface LIAViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *companyLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *numFollowersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *squareLogoImageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewHeightConstraint;

@end

@implementation LIAViewController {
  LIALinkedInHttpClient *_client;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _client = [self client];
  
  // Style follow button
  //self.followButton.layer.borderWidth = 1.0f;
  //self.followButton.layer.borderColor = COLOR_RGBA(233,172,26,1).CGColor;
  self.followButton.layer.cornerRadius = 3.0f;
  
  [self getCompanyInfoWithToken:[self accessToken]];
}

#pragma mark - Button actions

// Sign in to LinkedIn
- (IBAction)didTapConnectWithLinkedIn:(id)sender {
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self requestMeWithToken:accessToken];
        } failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    } cancel:^{
        NSLog(@"Authorization was cancelled by user");
    } failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}

// Get job postings
- (IBAction)jobsTapped:(id)sender {
    //[self getCompanyJobPostings:[self accessToken]];
    [self getConnectionsWithToken:[self accessToken]];
}

#pragma mark - LinkedIn requests

- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (void)getCompanyInfoWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/companies/universal-name=new-zealand-defence-force:(id,name,description,logo-url,square-logo-url,num-followers)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"company %@", result);
        
        // Images
        [self loadImageView:self.companyLogoImageView withURL:result[@"logoUrl"]];
        [self loadImageView:self.squareLogoImageView withURL:result[@"squareLogoUrl"]];
        
        // Load company name
        self.companyNameLabel.text = result[@"name"];
        
        // Number of followers
        self.numFollowersLabel.text = [result[@"numFollowers"] stringValue];
        
        // Company description
        self.textView.text = result[@"description"];
        
        // Calculate the required size for the text and adjust the constraint
        CGSize maxSize = CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX);
        CGSize requiredSize = [self.textView sizeThatFits:maxSize];
        self.descriptionTextViewHeightConstraint.constant = requiredSize.height;
        
        // Animate the text view height change
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get company info %@", error);
    }];
}

- (void)getCompanyJobPostings:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/companies/14148/updates?event-type=job-posting&oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"jobs %@", result);
        // "_total" = 0;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get company job postings %@", error);
    }];
}

- (void)followCompany:(int)companyId {
    // POST
    // http://api.linkedin.com/v1/people/~/following/companies
    /*<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <company>
            <id>1337</id>
        </company>*/
}

// Get people connected to the the current user.
// Need vetted access!
- (void)getConnectionsWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people-search?company-name=new-zealand-defence-force&oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"connections %@", result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get connections info %@", error);
    }];
    
    // http://api.linkedin.com/v1/people/~:(connections:(id,first-name,last-name,picture-url,headline,site-standard-profile-request:(url),positions:(company)))
    // http://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,picture-url,headline,site-standard-profile-request:(url)),num-results)?facet=network,F,S&company-name={0}&current-company=true&count=1
    // http://api.linkedin.com/v1/people-search?company-name={company name}


}

#pragma mark - Helpers

// Get the Access Token stored in user defaults.
- (NSString *)accessToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefaults objectForKey:LINKEDIN_TOKEN_KEY];
    assert(accessToken != nil || ![accessToken isEqualToString:@""]);
    return accessToken;
}

// Load image view with image located at given URL.
- (void)loadImageView:(UIImageView *)imageView withURL:(NSString *)url {
    NSURL *imageURL = [NSURL URLWithString:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithData:imageData];
        });
    });
}

// Initialise a LinkedInClient
- (LIALinkedInHttpClient *)client {
  LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                  clientId:LINKEDIN_CLIENT_ID
                                                                              clientSecret:LINKEDIN_CLIENT_SECRET
                                                                                     state:@"DCEEFWF45453sdffef424"
                                                                             grantedAccess:@[@"r_fullprofile", @"r_network"]];
  return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
