//
//  AppDelegate.m
//  Commerce Sample
//
//  Created by Bryan, Edward P on 3/5/14.
//  Copyright (c) 2014 The Grove. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Method to be defined within the UIApplicationDelegate
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    // Disable custom keyboards on iOS 8
    return NO;
}
@end
