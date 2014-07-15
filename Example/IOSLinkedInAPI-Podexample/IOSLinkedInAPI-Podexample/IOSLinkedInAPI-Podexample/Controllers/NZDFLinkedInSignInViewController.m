//
//  NZDFLinkedInSignInViewController.m
//  IOSLinkedInAPI-Podexample
//
//  Created by Dean Woodward on 15/07/14.
//  Copyright (c) 2014 Eyben Consult ApS. All rights reserved.
//

#import "NZDFLinkedInSignInViewController.h"
#import "LIAViewController.h"

@interface NZDFLinkedInSignInViewController ()

@end

@implementation NZDFLinkedInSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LIAViewController *liaViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LIAViewController"];
    liaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:liaViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Check user defaults for access token - check if expired?
// If no token - present sign in controller - if access token present linked in view
// Sign in to LinkedIn
//- (void)connectWithLinkedIn:(id)sender {
//    [self.client getAuthorizationCode:^(NSString *code) {
//        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
//            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
//            [self requestMeWithToken:accessToken];
//        } failure:^(NSError *error) {
//            NSLog(@"Quering accessToken failed %@", error);
//        }];
//    } cancel:^{
//        NSLog(@"Authorization was cancelled by user");
//    } failure:^(NSError *error) {
//        NSLog(@"Authorization failed %@", error);
//    }];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
