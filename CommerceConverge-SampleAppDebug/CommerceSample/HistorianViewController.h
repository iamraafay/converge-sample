//
//  HistorianViewController.h
//  Commerce Sample
//
//  Created by Rapoport, Julia on 10/16/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface HistorianViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *lastFourDigits;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *resultsTable;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *fromLabel;
@property (weak, nonatomic) IBOutlet UITextField *toLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *transactionCell;
@property id<ECLAccountProtocol> account;

@property (weak, nonatomic) IBOutlet UILabel *transactionID;
@property (weak, nonatomic) IBOutlet UILabel *taxedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tippedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *tippedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property ReceiptFeatures *receiptFeatures;

-(void)accountFromPastView:(id<ECLAccountProtocol>)account;

@end
