//
//  TransactionViewController.h
//  CommerceSample
//
//  Created by Bryan, Edward P on 11/30/15.
//  Copyright (c) 2015 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlavorIncludes.h"

@interface TransactionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *transactionTypeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cardEntry;
@property (weak, nonatomic) IBOutlet UISwitch *generateTokenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *storeTokenSwitch;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
- (IBAction)continueButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *forceSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tenderTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountTenderedField;
@property (weak, nonatomic) IBOutlet UITextField *tokenField;
- (IBAction)cardEntrySegmentClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *tipOnCardReaderSwitch;
@property (weak, nonatomic) IBOutlet UITextField *taxAmountField;
@property (weak, nonatomic) IBOutlet UISwitch *taxInclusiveSwitch;
@property (weak, nonatomic) IBOutlet UITextField *tipSelection1Field;
@property (weak, nonatomic) IBOutlet UITextField *tipSelection2Field;
@property (weak, nonatomic) IBOutlet UITextField *tipSelection3Field;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSelection1Type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSelection2Type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSelection3Type;
@property (weak, nonatomic) IBOutlet UISwitch *tipCustomAmountSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *partialApprovalSwitch;
@property (weak, nonatomic) IBOutlet UITextView *noteTextField;
@property (weak, nonatomic) IBOutlet UITextField *avsAddress;
@property (weak, nonatomic) IBOutlet UITextField *avsZip;

@property ECLTenderType tenderType;
@property ECLTransactionType transactionType;
@property NSString *transactionString;
@property NSString *tenderString;
@property ECLCurrencyCode currency;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property id<ECLTransactionProcessorProtocol> processor;
@property id<ECLTransactionProtocol> resultingTransaction;
@property id<ECLTenderProtocol> resultingTender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
