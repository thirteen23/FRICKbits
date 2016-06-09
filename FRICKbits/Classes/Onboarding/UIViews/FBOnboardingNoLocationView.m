//
//  FBOnboardingNoLocationView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingNoLocationView.h"
#import "FBOnboardingPresentationView.h"
#import "FBHeaderView.h"
#import "FBChrome.h"
#import "FBUtils.h"

static NSString *const noLocationText =
    @"FRICKbits won't work without access to your location and permission to "
    @"run in the background.\nFRICKbits uses only approximate and significant "
    @"changes in location, and won't kill your battery. In the Settings app, "
    @"go to General and then Background App Refresh as well as Privacy and "
    @"then Location to enable access for FRICKbits.";

@interface FBOnboardingNoLocationView ()

@property(nonatomic, strong) UIImageView *noLocationImageView;
@property(nonatomic, strong) FBOnboardingPresentationView *noLocationView;
@property(nonatomic, strong) NSMutableArray *noLocationViewConstraints;
@property(nonatomic, strong) UILabel *noLocationTextLabel;

@end

@implementation FBOnboardingNoLocationView

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  _noLocationViewConstraints = [[NSMutableArray alloc] init];

  /*
   * No Location Error Text
   */
  NSRange newline = [noLocationText rangeOfString:@"\n"];
  NSString *noLocation = [NSString
      stringWithString:[noLocationText substringToIndex:newline.location + 1]];

  NSMutableAttributedString *noLocationAttrText =
      [[FBChrome attributedTextTitle:noLocation] mutableCopy];

  NSAttributedString *noLocationAttrTextBody =
      [FBChrome attributedParagraphForOnboarding:
                    [noLocationText substringFromIndex:newline.location + 1]];

  [noLocationAttrText appendAttributedString:noLocationAttrTextBody];

  _noLocationTextLabel = [[UILabel alloc] init];
  _noLocationTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _noLocationTextLabel.backgroundColor = [UIColor clearColor];

  _noLocationTextLabel.attributedText = noLocationAttrText;
  _noLocationTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _noLocationTextLabel.numberOfLines = 0;
  [_noLocationTextLabel sizeToFit];

  /*
   * No Location Error Presentation View
   */
  _noLocationView = [[FBOnboardingPresentationView alloc]
      initWithViews:_noLocationTextLabel, nil];

  [self addSubview:_noLocationView];

  [_noLocationViewConstraints
      addObject:[_noLocationView autoPinEdge:ALEdgeTop
                                      toEdge:ALEdgeBottom
                                      ofView:self]];

  [_noLocationViewConstraints addObject:[_noLocationView autoPinEdge:ALEdgeLeft
                                                              toEdge:ALEdgeLeft
                                                              ofView:self]];

  [_noLocationViewConstraints addObject:[_noLocationView autoPinEdge:ALEdgeRight
                                                              toEdge:ALEdgeRight
                                                              ofView:self]];

  /*
   * No Location Error Image View
   */
  _noLocationImageView = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:@"locationerror.png"]];
  _noLocationImageView.translatesAutoresizingMaskIntoConstraints = NO;
  _noLocationImageView.alpha = 0.0f;
  _noLocationImageView.backgroundColor = [UIColor clearColor];

  [self addSubview:_noLocationImageView];
  [self sendSubviewToBack:_noLocationImageView];

  [_noLocationImageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self];

  NSLayoutConstraint *bottomConstraint =
      [_noLocationImageView autoPinEdge:ALEdgeBottom
                                 toEdge:ALEdgeTop
                                 ofView:_noLocationView
                             withOffset:-20.0f];
  bottomConstraint.priority = UILayoutPriorityDefaultHigh;

  [_noLocationImageView autoPinEdge:ALEdgeTop
                             toEdge:ALEdgeTop
                             ofView:self
                         withOffset:(20.0f + [FBHeaderView heightOfHeaderView])
                           relation:NSLayoutRelationGreaterThanOrEqual];
}

- (void)doNoLocationErrorTransition {
  [self doNoLocationErrorTransitionWithCompletion:nil];
}

- (void)doNoLocationErrorTransitionWithCompletion:(dispatch_block_t)completion {

  [FBUtils
      doTransitionAnimationWithDuration:0.17f
                             startDelay:0.0f
                               fromView:nil
                        fromConstraints:nil
                                 toView:_noLocationView
                          toConstraints:_noLocationViewConstraints
                         withCompletion:^(void) {

                             [UIView
                                 animateWithDuration:0.17f
                                               delay:0.0f
                                             options:
                                                 (UIViewAnimationOptionBeginFromCurrentState)
                                          animations:^(void) {
                                              _noLocationImageView.alpha = 1.0f;
                                          }
                                          completion:nil];
                         }];
}

@end
