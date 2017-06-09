//
//  TransactionDetailViewController.h
//  Commerce Sample
//
//  Created by Rapoport, Julia on 10/28/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "HistorianViewController.h"
#import "FlavorIncludes.h"

@interface TransactionDetailViewController : UIViewController

//@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property id<ECLAccountProtocol> account;
@property ECLTransactionSearchResult* transaction;
@property (weak, nonatomic) IBOutlet UILabel *voidableLabel;
@property ECLTransactionType transactionTypeToPerform;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *authCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *refundableLabel;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;
@property (weak, nonatomic) IBOutlet UIButton *voidButton;
@property (weak, nonatomic) IBOutlet UIButton *completePreAuthButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelPreAuthButton;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *verificationResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *verificationMethodLabel;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property ReceiptFeatures *receiptFeatures;

-(void)transactionToDisplay:(ECLTransactionSearchResult *) transaction;
-(void)accountFromPastView:(id<ECLAccountProtocol>)account;
-(void) setLabel:(UILabel *)label;
- (IBAction)printButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *emailButtonClicked;
- (IBAction)emailButtonClicked:(id)sender;

@end
