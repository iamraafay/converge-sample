//
//  MainViewController+Specifics.h
//  Commerce Sample
//
//  Created by Bryan, Edward P on 10/9/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//
@class MainViewController;
@protocol ECLAccountDelegate;
@interface Flavor : NSObject

@property MainViewController *mainViewController;

- (id)init:(MainViewController *)mainViewController;
- (id<ECLAccountDelegate>)createAccountDelegate;
- (void)addButtons:(NSInteger)verticalButtonPosition;

- (NSMutableArray*) createSettingsView:(CGFloat)width;
- (void) setUserDefault: (NSString *)key withValue:(NSString *)value;
- (NSString *)serverType;
- (void)setServerType:(NSString *)server;
@end
