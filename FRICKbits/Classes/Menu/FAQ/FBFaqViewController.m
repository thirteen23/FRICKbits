//
//  FBFaqViewController.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 8/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBFaqViewController.h"
#import "PureLayout.h"

@interface FBFaqViewController () <UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *faqView;

@end

@implementation FBFaqViewController

static NSString *const kFBFaqViewControllerContentURL =
    @"http://frickbits.s3-website-us-east-1.amazonaws.com/faq.html";

- (instancetype)init {
  if (self = [super init]) {
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupPresentationOfView];
  [self loadRequestFromString:kFBFaqViewControllerContentURL];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - View Initialization

- (void)setupPresentationOfView {

  self.screenName = @"FAQ Screen";
  self.title = @"FAQ";

  // put a gray background under the status bar
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  view.backgroundColor = [FBChrome navigationBarColor];
  [self.view addSubview:view];

  UIButton *cancelButton = [FBChrome barButtonWithTitle:@"CANCEL"];
  UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
  [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem = cancelBarButton;

  _faqView = [[UIWebView alloc] init];
  _faqView.delegate = self;
  _faqView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_faqView];

  // top offset below status bar and nav bar
  [_faqView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:(20 + 44)];
  [_faqView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
  [_faqView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
  [_faqView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
}

#pragma mark - FBFaqViewControllerDelegate

- (void)cancelButtonPressed:(id)sender {
  if ([self.delegate
          respondsToSelector:@selector(faqViewControllerDidCancel:)]) {
    [self.delegate faqViewControllerDidCancel:self];
  }
}

#pragma mark - Loading Content

- (void)loadRequestFromString:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  [_faqView loadRequest:urlRequest];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType {
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

@end
