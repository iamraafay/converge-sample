//
//  RefreshStatusViewController.h
//  CommerceSample
//
//  Created by Phan, Trac B on 6/20/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface RefreshStatusViewController : UIViewController<ECLDeviceStatusDelegate>

@property MainViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *availableDevices;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

- (void) passMainViewController: (MainViewController *) controller;
@end