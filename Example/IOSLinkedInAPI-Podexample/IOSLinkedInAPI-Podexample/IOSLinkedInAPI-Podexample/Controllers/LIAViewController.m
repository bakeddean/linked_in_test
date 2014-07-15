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
#import "LIATableViewCell.h"
#import "LIACompany.h"
#import "NZDFLinkedInViewController.h"

#define LINKEDIN_TOKEN_KEY @"linkedin_token"    // Move this from httpclient.m to .h
#define COLOR_RGBA(RED,GREEN,BLUE,ALPHA) [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:ALPHA/1.0f]

#define BASE_URL @"https://api.linkedin.com/v1"

#define DESCRIPTION_TEXT_DEFAULT_HEIGHT 175.0f

@interface LIAViewController () <UITableViewDataSource>

@property (nonatomic, strong) LIACompany *company;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// Company name/data properties
@property (weak, nonatomic) IBOutlet UIImageView *companyLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFollowersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (weak, nonatomic) IBOutlet UITableView *rightTableView;

// Description properties
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionDisclosureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionFadeImageView;

// Careers properties
@property (weak, nonatomic) IBOutlet UIImageView *squareLogoImageView;

@end

@implementation LIAViewController {
  LIALinkedInHttpClient *_client;
  NSArray *_leftTableTitles, *_rightTableTitles;
}

#pragma mark - View Controller life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  _client = [self client];
  
  self.followButton.layer.cornerRadius = 3.0f;
  self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 20, 10);
  
  self.leftTableView.dataSource = self;
  self.rightTableView.dataSource = self;
  _leftTableTitles = @[@"Headquarters",@"Website"];
  _rightTableTitles = @[@"Type",@"Industry",@"Company Size"];
  
  [self.leftTableView registerNib:[UINib nibWithNibName:@"LIATableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
  [self.rightTableView registerNib:[UINib nibWithNibName:@"LIATableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
  
  [self getCompanyInfoWithToken:[self accessToken]];
}

#pragma mark

// Use the model data to populate the view.
- (void)populateView {
    self.companyNameLabel.text = self.company.name;
    self.numFollowersLabel.text = [NSString stringWithFormat:@"%@ followers", self.company.numFollowers];
    self.textView.text = self.company.description;
    
    [self loadImageView:self.companyLogoImageView withURL:self.company.logoUrl];
    [self loadImageView:self.squareLogoImageView withURL:self.company.squareLogoUrl];
    
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
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
    NSString *request = [NSString stringWithFormat:@"%@/people/~?oauth2_access_token=%@&format=json",BASE_URL,accessToken];
    [self.client GET:request parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (void)getCompanyInfoWithToken:(NSString *)accessToken {
    NSString *fields = @":(id,name,description,logo-url,square-logo-url,num-followers,locations,website-url,company-type,industries,employee-count-range)";
    NSString *universalName = @"new-zealand-defence-force";
    NSString *request = [NSString stringWithFormat:@"%@/companies/universal-name=%@%@?oauth2_access_token=%@&format=json", BASE_URL,universalName,fields,accessToken];
    
    [self.client GET:request parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        self.company = [[LIACompany alloc]initWithDictionary:result];
        [self populateView];
        
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

// Get people connected to the the current user. Need vetted access!
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

#pragma mark

// User has tapped on the Description header view. Toggle between the truncated
// or full display of the description text.
- (IBAction)descriptionGestureTap:(UITapGestureRecognizer *)sender {

    // Calculate the required size for the text and adjust the constraint
    CGSize maxSize = CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX);
    CGSize requiredSize = [self.textView sizeThatFits:maxSize];
    float rotation = 0;
    float fadeImageViewAlpha = 1.0f;

    if(self.descriptionTextViewHeightConstraint.constant == DESCRIPTION_TEXT_DEFAULT_HEIGHT) {
        self.descriptionTextViewHeightConstraint.constant = requiredSize.height;
        fadeImageViewAlpha = 0.0f;
        rotation = M_PI/2;
    }
    else
        self.descriptionTextViewHeightConstraint.constant = DESCRIPTION_TEXT_DEFAULT_HEIGHT;
    
    // Animate the text view height change
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.descriptionDisclosureImageView.transform = CGAffineTransformMakeRotation(rotation);
        self.descriptionFadeImageView.alpha = fadeImageViewAlpha;
    } completion:^(BOOL finished){
        CGRect textViewFrame = self.textView.frame;
        textViewFrame.size.height += 20.0f;
        [self.scrollView scrollRectToVisible:textViewFrame animated:YES];
    }];
}

#pragma mark - TableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.leftTableView ? [_leftTableTitles count] : [_rightTableTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    LIATableViewCell *cell = (LIATableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Left table
    if(tableView == self.leftTableView) {
        cell.leftLabel.text = _leftTableTitles[indexPath.row];
        if(indexPath.row == 0)
            cell.rightLabel.text = self.company.locations;
        else if(indexPath.row == 1){
            cell.rightLabel.text = self.company.websiteUrl;
            cell.rightLabel.textColor = [UIColor blueColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openLink)];
            tap.numberOfTapsRequired = 1;
            cell.rightLabel.userInteractionEnabled = YES;
            [cell.rightLabel addGestureRecognizer:tap];
        }
    }
    
    // Right table
    else {
        cell.leftLabel.text = _rightTableTitles[indexPath.row];
        if(indexPath.row == 0)
            cell.rightLabel.text = self.company.companyType;
        else if (indexPath.row == 1)
            cell.rightLabel.text = self.company.industries;
        else if (indexPath.row == 2)
            cell.rightLabel.text = self.company.employeeCountRange;
    }
    return cell;
}

- (void)openLink {
    NSLog(@"Open link");
    NZDFLinkedInViewController *bob = [self.storyboard instantiateViewControllerWithIdentifier:@"LinkedInViewController"];
    [self.navigationController pushViewController:bob animated:YES];
}

#pragma mark - UIViewController orientation event

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if(self.descriptionTextViewHeightConstraint.constant != DESCRIPTION_TEXT_DEFAULT_HEIGHT) {
        CGSize maxSize = CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX);
        CGSize requiredSize = [self.textView sizeThatFits:maxSize];
        self.descriptionTextViewHeightConstraint.constant = requiredSize.height;
    
        // Animate the text view height change
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
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
