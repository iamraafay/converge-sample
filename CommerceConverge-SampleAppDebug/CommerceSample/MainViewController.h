//
//  MainViewController.h
//  Commerce
//
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flavor.h"
#include "FlavorIncludes.h"
#import "AVSFields.h"
#import <CommerceDataTypes/CommerceDataTypes.h>

@class ReceiptFeatures;
//@class ECLCardTransactionOutcome;
@class ECLEmvCardTransactionOutcome;

@interface MainViewController : UIViewController<ECLTransactionProcessingDelegate,ECLAccountValidationDelegate,ECLAccountInformationRetrievalDelegate,UIAlertViewDelegate,ECLDevicesSearchingDelegate,ECLPrinterDelegate,ECLUpdateKeysDelegate, ECLCardReaderRetrievePinDelegate, ECLCardReaderDelegate, ECLDeviceStatusDelegate>

- (UIButton * ) addButton:(id)target selector:(SEL) selector withTitle:(NSString*) title atVerticalPosition:(NSInteger)verticalButtonPosition;
- (void)addStatusString:(NSString *)text;
- (void)fillSegmentControls;
@property (weak, nonatomic) IBOutlet UITextView *statusLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *actionScrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tenderSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionSegmentControl;
- (IBAction)transactionSegmentChanged:(id)sender;
@property id<ECLAccountProtocol> account;
@property id <ECLAccountDelegate> accountDelegate;
@property id <ECLCardReaderProtocol> cardReader;
@property id<ECLTransactionProtocol> transaction;
@property id<ECLTenderProtocol> tender;
@property ECLTransactionOutcome *theOutcome;
@property ECLCurrencyCode defaultCurrencyCode;
@property ECLMagStripeCardData *prevMagStripeCardData;
@property ECLTransactionProgress currentTransactionProgress;
@property ReceiptFeatures *receiptFeatures;
@property Flavor *flavor;
@property BOOL needToAddConnectionStatusDelegate;
@property BOOL transactionInProgress;




@end
