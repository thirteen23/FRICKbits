//
// Created by Matt McGlincy on 4/2/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMenuItem.h"


@implementation FBMenuItem {

}

+ (FBMenuItem *)menuItemWithTag:(NSInteger)tag title:(NSString *)title icon:(UIImage *)icon {
  FBMenuItem *item = [[FBMenuItem alloc] init];
  item.tag = tag;
  item.title = title;
  item.icon = icon;
  return item;
}

@end