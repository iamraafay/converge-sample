//
//  ReaderSettingsViewController.h
//  Commerce Sample
//
//  Created by Pete, Jul 14, 2016.
//  Copyright (c) 2014 Elavon. All rights reserved.
//
// Allow the user to enter connection method (audio or internet)
// and IP and port
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "KeychainWrapper.h"

@interface ReaderSettingsViewController : UIViewController

@property NSString *defConnectionMethod;
@property NSString *defIP;
@property NSString *defPortStr;

@end
