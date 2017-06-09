//
//  RetrieveCardDataViewController.h
//  CommerceSample
//
//  Created by Phan, Trac B on 4/27/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface RetrieveCardDataViewController : UIViewController<ECLCardReaderRetrieveCardDataDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *magstripeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *contactlessSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *manualKeySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emvSwitch;

@property MainViewController *mainViewController;

- (void) passMainViewController: (MainViewController *) controller;
@end