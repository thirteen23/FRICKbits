//
// Created by Matt McGlincy on 4/9/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAppDelegate.h"
#import "FBColorPaletteManager.h"
#import "FBDataset.h"
#import "FBDateRangeOverlayView.h"
#import "FBDialogView.h"
#import "FBFrickView.h"
#import "FBLocationManager.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Gesture.h"
#import "FBMapViewController+Map.h"
#import "FBMapViewController+Menu.h"
#import "FBMenuItem.h"
#import "FBNotReadyYetViewController.h"
#import "FBOnboarding.h"
#import "FBOnboardingNavigationController.h"
#import "FBSettingsManager.h"
#import "FBUtils.h"
#import "MBProgressHUD.h"
#import "MBXMapKit.h"
#import "T23AtomicBoolean.h"

typedef NS_ENUM(NSInteger, FBMenuItemTag) {
  FBMenuItemTagChangePalette,
  FBMenuItemTagSelectDateRange,
  FBMenuItemTagShareScreenshot,
  FBMenuItemTagExportData,
  FBMenuItemTagClearAllData,
  FBMenuItemTagFAQ,
};

static NSInteger FBDialogTagConfirmDeleteData = 1001;
static NSInteger FBDialogTagNoEmail = 1002;

@implementation FBMapViewController (Menu)

#pragma mark - define menu items

- (NSArray *)menuItems {
  return @[
    [FBMenuItem menuItemWithTag:FBMenuItemTagChangePalette
                          title:@"CHANGE PALETTE"
                           icon:[UIImage imageNamed:@"menu_changepalette.png"]],
    [FBMenuItem menuItemWithTag:FBMenuItemTagSelectDateRange
                          title:@"SELECT DATE RANGE"
                           icon:[UIImage imageNamed:@"menu_daterange.png"]],
    [FBMenuItem menuItemWithTag:FBMenuItemTagShareScreenshot
                          title:@"SHARE IMAGE"
                           icon:[UIImage imageNamed:@"menu_share.png"]],
    [FBMenuItem menuItemWithTag:FBMenuItemTagExportData
                          title:@"EXPORT DATA"
                           icon:[UIImage imageNamed:@"menu_export.png"]],
    [FBMenuItem menuItemWithTag:FBMenuItemTagClearAllData
                          title:@"CLEAR ALL DATA"
                           icon:[UIImage imageNamed:@"menu_cleardata.png"]],
    [FBMenuItem menuItemWithTag:FBMenuItemTagFAQ
                          title:@"FAQ"
                           icon:[UIImage imageNamed:@"menu_faq.png"]],
  ];
}

#pragma mark - button handler

- (void)menuButtonPressed:(id)sender {
  [self showMenuView];
}

#pragma mark - show&hide

- (void)showMenuView {
  self.menuButton.alpha = 0.0;
  self.menuButton.enabled = NO;

  // take snapshot, then move onto screen once complete
  [FBUtils
      takeRicePaperSnapshotOfView:self.view
                            frame:CGRectMake(
                                      0, self.view.frame.size.height -
                                             self.menuViewController.menuHeight,
                                      self.view.frame.size.width,
                                      self.menuViewController.menuHeight)
                  completionBlock:^(UIImage *snapshot) {
                      self.menuViewController.backgroundImageView.image =
                          snapshot;
                      [UIView animateWithDuration:0.2
                          delay:0.0
                          options:UIViewAnimationOptionCurveEaseOut
                          animations:^{
                              self.menuViewController.view.frame = CGRectMake(
                                  0, 0,
                                  self.menuViewController.view.frame.size.width,
                                  self.menuViewController.view.frame.size
                                      .height);
                          }
                          completion:^(BOOL finished) {}];
                  }];
}

- (void)hideMenuView {
  // hide controls, so we're back to "clean slate"
  [self hideControlsWithAnimation:YES];

  [UIView animateWithDuration:0.2
      delay:0.0
      options:UIViewAnimationOptionCurveEaseIn
      animations:^{
          self.menuViewController.view.frame =
              CGRectMake(0, self.view.frame.size.height,
                         self.menuViewController.view.frame.size.width,
                         self.menuViewController.view.frame.size.height);
      }
      completion:^(BOOL finished) {}];
}

#pragma mark - FBMenuItemViewControllerDelegate

- (void)menuViewControllerDidCancel:(FBMenuViewController *)vc {
  [self hideMenuView];
}

- (void)menuViewController:(FBMenuViewController *)vc
         didSelectMenuItem:(FBMenuItem *)menuItem {
  [self hideMenuView];
  switch (menuItem.tag) {
  case FBMenuItemTagChangePalette:
    [self changePalette];
    break;
  case FBMenuItemTagSelectDateRange:
    [self selectDateRange];
    break;
  case FBMenuItemTagExportData:
    [self exportData];
    break;
  case FBMenuItemTagShareScreenshot:
    [self shareScreenshot];
    break;
  case FBMenuItemTagClearAllData:
    [self confirmClearAllData];
    break;
  case FBMenuItemTagFAQ:
    [self showFAQ];
    break;
  default:
    break;
  }
}

#pragma mark - menu actions

- (void)confirmClearAllData {
  FBDialogView *alert =
      [FBDialogView dialogWithMessage:@"Are you sure you want to permanently "
                                       "delete all of your location data?"
                             delegate:self
                    cancelButtonTitle:@"Clear All Data"
                    otherButtonTitles:@"Cancel", nil];
  alert.tag = FBDialogTagConfirmDeleteData;
  [alert showOnView:self.fullMapView];
}

- (void)clearAllData {
  // reset the local data file
  [[FBLocationManager sharedInstance] deleteLocationData];

  self.dataset = nil;

  // go to the "don't have enough data" screen
  FBAppDelegate *appDelegate =
      (FBAppDelegate *)[UIApplication sharedApplication].delegate;
  [appDelegate showNotReadyYetViewController];
}

- (void)changePalette {
  NSUInteger currentPaletteIndex =
      [FBColorPaletteManager sharedInstance].colorPalette.index;
  FBOnboardingNavigationController *nc =
      [[FBOnboardingNavigationController alloc]
          initWithOnboardingViewControllerAtPickerPointWithColorIndex:
              currentPaletteIndex];
  nc.onboardingAnimationDelegate = self;
  [self presentViewController:nc animated:YES completion:nil];
}

- (void)selectDateRange {
  NSDate *startDate = self.dataset.earliestLoadedDate;
  NSDate *endDate = [[NSDate alloc] init]; // now
  NSDate *startFilterDate = (self.dataset.startFilterDate) ?: startDate;
  NSDate *endFilterDate = (self.dataset.endFilterDate) ?: endDate;

  FBDataCalendarNavigationController *nc =
      [[FBDataCalendarNavigationController alloc]
          initWithStartDate:startDate
                    endDate:endDate
            startFilterDate:startFilterDate
              endFilterDate:endFilterDate];
  nc.delegate = self;

  [self presentViewController:nc animated:YES completion:nil];
}

- (void)exportData {
  if (![MFMailComposeViewController canSendMail]) {
    FBDialogView *alert = [FBDialogView
        dialogWithMessage:
            @"Please set up a Mail account in order to export your data."
                 delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    alert.tag = FBDialogTagNoEmail;
    [alert showOnView:self.fullMapView];
    return;
  }

  MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
  vc.mailComposeDelegate = self;
  vc.subject = @"FRICKbits Data";
  [vc setMessageBody:@"Here is my location data." isHTML:NO];
  NSString *filePath = DocumentsFilePath(FBLocationCSVFileName);
  NSData *data = [NSData dataWithContentsOfFile:filePath];
  [vc addAttachmentData:data mimeType:@"text/csv" fileName:@"locationdata.csv"];

  [self presentViewController:vc animated:YES completion:nil];
}

- (void)shareScreenshot {
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.square = NO;
  hud.margin = 0.0;
  // make HUD bigger than screen, to hide rounded corners
  // TODO: eventually the MBProgressHUD cocoapod version will be incremented,
  // and cornerRadius will be exposed as a property.
  CGRect rect = CGRectInset(self.view.bounds, -10, -10);
  hud.minSize = rect.size;
  hud.opacity = 0.4;

  // take a screenshot of the current frickview
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
      [self.snapshotLock lock];
      UIImage *shareImage = UIImageWithView(self.screenshotContainerView);
      [self.snapshotLock unlock];

      // provide ourself as a UIActivityItemSource, so we can provide
      // per-activity text
      NSArray *activityItems = @[ self, shareImage ];
      UIActivityViewController *vc =
          [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                            applicationActivities:nil];
      vc.excludedActivityTypes = @[
        UIActivityTypeAddToReadingList,
        UIActivityTypeAssignToContact,
        UIActivityTypeAirDrop,
        UIActivityTypeCopyToPasteboard
      ];
      dispatch_async(dispatch_get_main_queue(), ^{
          [hud hide:YES];
          [self presentViewController:vc animated:YES completion:nil];
      });
  });
}

- (void)showFAQ {
  FBFaqViewController *vc = [[FBFaqViewController alloc] init];
  vc.delegate = self;
  UINavigationController *nav =
      [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBDialogViewDelegate

- (void)dialogView:(FBDialogView *)dialogView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (dialogView.tag == FBDialogTagConfirmDeleteData && buttonIndex == 0) {
    [self clearAllData];
  }
}

#pragma mark - FBOnboardingNavigationControllerDelegate

- (void)onboardingNavigationController:
            (FBOnboardingNavigationController *)onboardingNC
                 didChooseColorPalette:(FBColorPalette *)colorPalette {
  // immediately clear the frick bits
  [self.frickView clear];
  [self recolorDots];

  // redraw the frick view with the new palette
  [self updateDataDisplay];

  // get rid of the modal
  [onboardingNC dismissViewControllerAnimated:YES completion:nil];
}

- (void)onboardingNavigationControllerDidCancel:
            (FBOnboardingNavigationController *)onboardingNC {
  // get rid of the modal
  [onboardingNC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActivityItemSource

static NSString *FBShareTextDefault =
    @"FRICKbits, take back your data and turn it into art. Here’s me.";
static NSString *FBShareTextEmail =
    @"<html><body>"
    @"<a href='http://www.FRICKbits.com'>FRICKbits</a>, take back your data and turn it into art...here’s mine. "
    @"A free iPhone app from artist Laurie Frick. "
    @"Takes your location and slowly turns it into abstract pattern, works anywhere in the world. "
    @"Super simple, here’s the link. <a href='http://www.FRICKbits.com'>http://www.FRICKbits.com</a>."
    @"</body></html>";
static NSString *FBShareTextFacebook =
    @"FRICKbits...take back your data and turn it into art. "
    @"Did it with free iPhone app from artist Laurie Frick.";
static NSString *FBShareTextTumblr =
    @"FRICKbits, take back your data and turn it into art. "
    @"My location data is art.";
static NSString *FBShareTextTwitter =
    @"Take back your data and turn it into art...a new data-selfie. @FRICKbits";
static NSString *FBShareEmailSubject =
    @"FRICKbits my data is art";

- (id)activityViewControllerPlaceholderItem:
          (UIActivityViewController *)activityViewController {
  return FBShareTextDefault;
}

static NSString *kActivityTypePostToTumblr = @"com.tumblr.tumblr.Share-With-Tumblr";
// TODO: not currently used
//static NSString *kActivityTypePostToPinterest = @"pinterest.ShareExtension";

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
  if ([activityType isEqualToString:UIActivityTypeMail]) {
    return FBShareTextEmail;
  } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
    return FBShareTextFacebook;
  } else if ([activityType isEqualToString:kActivityTypePostToTumblr]) {
    return FBShareTextTumblr;
  } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
    return FBShareTextTwitter;
  } else {
    return FBShareTextDefault;
  }
}

- (NSString *)activityViewController:
                  (UIActivityViewController *)activityViewController
              subjectForActivityType:(NSString *)activityType {
  return FBShareEmailSubject;
}

#pragma mark - FBDataCalendarNavigationControllerDelegate

- (void)dataCalendarNavigationController:
            (FBDataCalendarNavigationController *)nc
                      didSelectStartDate:(NSDate *)startDate
                                 endDate:(NSDate *)endDate {

  self.dataset.startFilterDate = startDate;
  self.dataset.endFilterDate = endDate;
  [self.dateRangeOverlay setStartDate:startDate endDate:endDate];

  [self dismissViewControllerAnimated:YES
                           completion:^(void) {
                               // reload the dataset from file each time,
                               // in case date range is wider than current
                               // filtered set
                               [self.dataset reload];                             
                               if (startDate && endDate) {
                                 [self.dataset
                                     filterDatasetWithStartDate:startDate
                                                        endDate:endDate];
                               }
                               [self.sparseMapGrids removeAllObjects];
                               [self updateDataDisplay];
                           }];
}

- (void)dataCalendarNavigationControllerDidCancel:
            (FBDataCalendarNavigationController *)nc {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBFaqViewControllerDelegate

- (void)faqViewControllerDidCancel:(FBFaqViewController *)vc {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end