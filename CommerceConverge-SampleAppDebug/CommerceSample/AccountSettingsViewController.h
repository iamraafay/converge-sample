//
//  AccountSettingsViewController.h
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/20/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AccountSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property MainViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *serverTypeControl;

- (void) passMainViewController: (MainViewController *) controller;

@end
