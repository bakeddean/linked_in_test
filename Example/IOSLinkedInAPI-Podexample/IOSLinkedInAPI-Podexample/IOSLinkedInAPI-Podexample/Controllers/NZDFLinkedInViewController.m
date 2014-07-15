//
//  NZDFLinkedInViewController.m
//  NZDF
//
//  Created by Dean Woodward on 9/07/14.
//  Copyright (c) 2014 Datacom. All rights reserved.
//

#import "NZDFLinkedInViewController.h"

@interface NZDFLinkedInViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NZDFLinkedInViewController

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
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [[NSURL alloc]initWithString:self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backTapped:(UIBarButtonItem *)sender {
    if(self.webView.canGoBack)
        [self.webView goBack];
}

- (IBAction)refreshTapped:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (IBAction)homeTapped:(UIBarButtonItem *)sender {
    NSURL *url = [[NSURL alloc]initWithString:self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    self.backButton.enabled = self.webView.canGoBack;
    
    // Check if we are on the self.url page
    NSString *url = [self.webView.request.URL  absoluteString];
    url = [[url componentsSeparatedByString:@"?"]firstObject];
    self.homeButton.enabled = ![url isEqualToString:self.url];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

@end
