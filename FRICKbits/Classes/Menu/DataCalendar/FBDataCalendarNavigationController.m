//
//  FBDataCalendarNavigationController.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 8/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDataCalendarNavigationController.h"
#import "FBChrome.h"
#import "FBUtils.h"
#import "NSDate+FBDateCalculations.h"
#import <PDTSimpleCalendar/PDTSimpleCalendar.h>

@interface FBDataCalendarNavigationController () <PDTSimpleCalendarViewDelegate>

@property(nonatomic, strong) PDTSimpleCalendarViewController *dataCalendar;
@property(nonatomic, strong) NSDate *anchor;
@property(nonatomic, strong) NSDate *selected;
@property(nonatomic, strong) NSDate *previous;
@property(nonatomic) BOOL showResetButton;

@property(nonatomic, strong) NSArray *selectedBetweenDates;
@property(nonatomic, strong) NSArray *previouslySelectedBetweenDates;
@property(nonatomic) BOOL clearPreviouslySelectedBetweenDates;

@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIButton *resetButton;

@property(nonatomic, strong) dispatch_group_t animationGroup;

@end

@implementation FBDataCalendarNavigationController

+ (void)initialize {
  // set appearance for PDFSimpleCalendar
  [[PDTSimpleCalendarViewCell appearance]
      setTextDefaultFont:[FBChrome calendarDayFont]];
  [[PDTSimpleCalendarViewCell appearance]
      setTextDefaultColor:[FBChrome textGrayColor]];
  [[PDTSimpleCalendarViewCell appearance]
      setTextDisabledColor:[FBChrome textDisabledColor]];
  [[PDTSimpleCalendarViewCell appearance]
      setTextTodayColor:[FBChrome textGrayColor]];
  [[PDTSimpleCalendarViewCell appearance]
      setCircleTodayColor:[UIColor clearColor]];
  [[PDTSimpleCalendarViewCell appearance]
      setTextSelectedColor:[FBChrome textGrayColor]];
  [[PDTSimpleCalendarViewCell appearance]
      setCircleSelectedColor:[FBChrome buttonGrayColor]];

  [[PDTSimpleCalendarViewHeader appearance]
      setTextFont:[FBChrome calendarMonthFont]];
}

- (instancetype)initWithStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
                  startFilterDate:(NSDate *)startFilterDate
                    endFilterDate:(NSDate *)endFilterDate {

  if (self = [super init]) {

    _animationGroup = dispatch_group_create();

    /*
     * Sanitize dates just in case
     */
    _startDate = [[startDate dateBackToMidnight]
        earlierDate:[endDate dateBackToMidnight]];
    _endDate =
        [[startDate dateBackToMidnight] laterDate:[endDate dateBackToMidnight]];

    _startFilterDate = ([[startFilterDate dateBackToMidnight]
                           earlierDate:[endFilterDate dateBackToMidnight]])
                           ?: _startDate;
    _endFilterDate = ([[startFilterDate dateBackToMidnight]
                         laterDate:[endFilterDate dateBackToMidnight]])
                         ?: _endDate;

    _showResetButton = ![_startDate equalByDayMonthYear:_startFilterDate] ||
                       ![_endDate equalByDayMonthYear:_endFilterDate];

    _previouslySelectedBetweenDates =
        [_startFilterDate datesBetweenDate:_endFilterDate];

    _dataCalendar = [[PDTSimpleCalendarViewController alloc] init];
    _dataCalendar.delegate = self;
    _dataCalendar.selectedDate = nil;

    _dataCalendar.firstDate = _startDate;
    _dataCalendar.lastDate = _endDate;

    self.screenName = @"Data Calendar Screen";
    self.title = @"Select Date Range";

    self.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;

    _clearPreviouslySelectedBetweenDates = NO;

    [self setViewControllers:@[ _dataCalendar ] animated:NO];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // put a gray background under the status bar
  UIView *view = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  view.backgroundColor = [FBChrome navigationBarColor];
  [self.view addSubview:view];

  _dataCalendar.title = @"Date Range";

  _cancelButton = [FBChrome barButtonWithTitle:@"CANCEL"];
  UIBarButtonItem *cancelBarButton =
      [[UIBarButtonItem alloc] initWithCustomView:_cancelButton];
  [_cancelButton addTarget:self
                    action:@selector(cancelButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];

  _dataCalendar.navigationItem.leftBarButtonItem = cancelBarButton;

  _resetButton = [FBChrome barButtonWithTitle:@"ALL DATA"];
  UIBarButtonItem *resetBarButton =
      [[UIBarButtonItem alloc] initWithCustomView:_resetButton];
  [_resetButton addTarget:self
                   action:@selector(resetButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];

  /*
   * Don't show the reset button if the user already has everything selected
   */
  if (_showResetButton) {
    _dataCalendar.navigationItem.rightBarButtonItem = resetBarButton;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication]
      setStatusBarHidden:NO
           withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - FBDataCalendarViewControllerDelegate

- (void)cancelButtonPressed:(id)sender {
  [self animateBarButtonOpacityOutWithCompletion:^(void) {
      [self signalDelegateWithStartDate:_startFilterDate
                             andEndDate:_endFilterDate];
  }];
}

- (void)resetButtonPressed:(id)sender {

  self.view.userInteractionEnabled = NO;
  _dataCalendar.navigationItem.rightBarButtonItem.enabled = NO;
  _dataCalendar.navigationItem.leftBarButtonItem.enabled = NO;

  _selected = nil;
  _dataCalendar.selectedDate = nil;
  _clearPreviouslySelectedBetweenDates = YES;

  _anchor = nil;
  _previous = nil;

  [self animateBarButtonOpacityOutWithCompletion:^(void) {
      [self signalDelegateWithStartDate:nil andEndDate:nil];
  }];
}

- (void)signalDelegateWithStartDate:(NSDate *)startDate
                         andEndDate:(NSDate *)endDate {

  NSDate *returnStart = nil;
  NSDate *returnEnd = nil;

  /*
   * If the selected dates are the same then return nil for both filters
   */
  if (!((startDate && [startDate equalByDayMonthYear:_startDate]) &&
        (endDate && [endDate equalByDayMonthYear:_endDate]))) {
    returnStart = startDate;
    returnEnd = endDate;
  }

  if ([self.delegate
          respondsToSelector:@selector(dataCalendarNavigationController:
                                                     didSelectStartDate:
                                                                endDate:)]) {
    [self.delegate dataCalendarNavigationController:self
                                 didSelectStartDate:returnStart
                                            endDate:returnEnd];
  }
}

#pragma mark - PDTSimpleCalendarView Helpers

- (void)forceRefreshOfDatesWithCompletion:(dispatch_block_t)completion {

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {

          [[_dataCalendar.collectionView indexPathsForVisibleItems]
              enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                  if (_ISA_(obj, NSIndexPath)) {
                    id cObj = [_dataCalendar.collectionView
                        cellForItemAtIndexPath:(NSIndexPath *)obj];

                    if (_ISA_(cObj, PDTSimpleCalendarViewCell)) {
                      PDTSimpleCalendarViewCell *cell =
                          (PDTSimpleCalendarViewCell *)cObj;

                      /*
                       * Enter the group before we enqueue an animation
                       */
                      dispatch_group_enter(_animationGroup);
                      [UIView animateWithDuration:0.17f
                          delay:0.0f
                          options:(UIViewAnimationOptionBeginFromCurrentState |
                                   UIViewAnimationOptionCurveLinear)
                          animations:^(void) { [cell refreshCellColors]; }
                          completion:^(BOOL finished) {
                              if (finished) {
                                /*
                                 * Dequeue off the group once the animation has
                                 * been completed
                                 */
                                dispatch_group_leave(_animationGroup);
                              }
                          }];
                    }
                  }
              }];
      });

      /*
       * Wait for the last animation to complete
       */
      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);
      dispatch_async(dispatch_get_main_queue(), ^(void) {
          if (completion) {
            completion();
          }
      });
  });
}

#pragma mark - Animation Utilities

- (void)animateBarButtonOpacityOutWithCompletion:(dispatch_block_t)completion {

  [UIView animateWithDuration:0.33f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {
          _resetButton.alpha = 0.5f;
          _cancelButton.alpha = 0.5f;
      }
      completion:^(BOOL finished) {
          if (completion) {
            completion();
          }
      }];
}

#pragma mark - PDTSimpleCalendarViewDelegate

- (void)simpleCalendarViewController:
            (PDTSimpleCalendarViewController *)controller
                       didSelectDate:(NSDate *)date {

  if (date == _selected) {
    return;
  }

  _selected = [date dateBackToMidnight];

  if (_previous) {
    /*
     * Second tap, update previous and color selected.
     */
    _anchor = _selected;
    _previous = nil;

    [self forceRefreshOfDatesWithCompletion:nil];

  } else {

    /*
     * Clear potentially loaded highlighted dates.
     */
    _clearPreviouslySelectedBetweenDates = YES;
    [self forceRefreshOfDatesWithCompletion:nil];

    _previous = _anchor;
    if (!_anchor) {
      _anchor = _selected;
    }
  }

  /*
   * If second tap, test for span and then color dates.
   */
  if (_selected != _anchor) {
    self.view.userInteractionEnabled = NO;
    _dataCalendar.navigationItem.rightBarButtonItem.enabled = NO;
    _dataCalendar.navigationItem.leftBarButtonItem.enabled = NO;

    _selectedBetweenDates = [_selected datesBetweenDate:_anchor];
    _startFilterDate = [_selected earlierDate:_anchor];
    _endFilterDate = [_selected laterDate:_anchor];

    [self forceRefreshOfDatesWithCompletion:^(void) {
        [self animateBarButtonOpacityOutWithCompletion:^(void) {
            [self signalDelegateWithStartDate:_startFilterDate
                                   andEndDate:_endFilterDate];
        }];
    }];
  }
}

- (BOOL)simpleCalendarViewController:
            (PDTSimpleCalendarViewController *)controller
        shouldUseCustomColorsForDate:(NSDate *)date {

  return (_anchor == date || _previous == date ||
          [date foundByDayMonthYearInArray:_selectedBetweenDates] ||
          [date foundByDayMonthYearInArray:_previouslySelectedBetweenDates]);
}

- (UIColor *)simpleCalendarViewController:
                 (PDTSimpleCalendarViewController *)controller
                       circleColorForDate:(NSDate *)date {

  return (((_anchor && !_selected) ||
           ([date foundByDayMonthYearInArray:_previouslySelectedBetweenDates] &&
            _clearPreviouslySelectedBetweenDates)) &&
          ![date foundByDayMonthYearInArray:_selectedBetweenDates])
             ? [UIColor clearColor]
             : [FBChrome buttonGrayColor];
}

- (UIColor *)simpleCalendarViewController:
                 (PDTSimpleCalendarViewController *)controller
                         textColorForDate:(NSDate *)date {
  return [FBChrome textGrayColor];
}

@end
