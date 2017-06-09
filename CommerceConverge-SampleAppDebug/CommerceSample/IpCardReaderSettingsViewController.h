//
//  IpCardReaderSettingsViewController.h
//  CommerceSample
//
//  Created by Phan, Trac B on 7/22/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#ifndef IpCardReaderSettingsViewController_h
#define IpCardReaderSettingsViewController_h


#endif /* IpCardReaderSettingsViewController_h */
#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface IpCardReaderSettingsViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *ipAddressTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextView *statusLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *securedSwitch;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *ipSwitch;


@property MainViewController *mainViewController;

- (void) passMainViewController: (MainViewController *) controller;
@end