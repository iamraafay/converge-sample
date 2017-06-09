//
//  MainViewController.m
//  Commerce
//
//  Copyright (c) 2014 Elavon. All rights reserved.
//


#import <ElavonCommon/ECCLogging.h>
#import <ElavonCommon/ECCCommon.h>
#import <ElavonCommon/ECCSensitiveData.h>
#import <ElavonCommon/ECCTriState.h>

#import <CommerceDataTypes/ECLConnectionConfiguration.h>
#import <CommerceDataTypes/ECLConnectionMethod.h>

#import "HistorianViewController.h"
#import "MainViewController.h"
#import "Flavor.h"
#import "ReceiptFeatures.h"
#import "AlertIDs.h"
#import "SignatureViewController.h"
#import "AccountSettingsViewController.h"
#import "TransactionDetailViewController.h"
#import "TransactionViewController.h"
#import "RetrieveCardDataViewController.h"
#import "RefreshStatusViewController.h"
#import "IpCardReaderSettingsViewController.h"

typedef void (^POST_FOUND_DEVICE_BLOCK)(void);

@interface MainViewController() <ECLTransactionSearchDelegate> {
    ECLTransactionType currentTransactionType;
    ECLTenderType currentTenderType;
    ECLTransactionOutcome *currentOutcome;
    AVSFields *avsField;
    POST_FOUND_DEVICE_BLOCK postFoundDeviceBlock;
    ECLConnectionConfiguration * currentConfigurationUsedForTransaction;
    UIButton * deviceConnectionSettingButton;
}
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    // this must be called before using ECCSensitiveData or before Commerce uses ECCSensitiveData
    NSError *error = [ECLCommerce initializeCommerce];
    if (error != nil) {
        NSLog(@"Failed to initialize commerce: %@", [error debugDescription]);
        return self;
    }
    
    _receiptFeatures = [[ReceiptFeatures alloc] init:self];
    
    // this creates either the Converge or Credit Call specific code
    _flavor = [[Flavor alloc] init:self];
    
    // create an account using delegate for our flavor.
    _accountDelegate = [_flavor createAccountDelegate];
    [_accountDelegate loadIpCardReaderConfiguration];
    
    // tell Commerce to use the main queue to call back on
    [ECLCommerce createAccount:_accountDelegate queue:dispatch_get_main_queue()];
    
    avsField = [[AVSFields alloc]init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add a gesture recognizer so when they tap outside keyboard it goes away
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [_transactionSegmentControl removeAllSegments];
    [_tenderSegmentControl removeAllSegments];
    
    // add buttons for UI
    [self populateActionMenu];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    // stop editing text so keyboard dimisses
    [self.view endEditing:YES];
}

// they pressed the cancel transaction button so call Commerce to cancel
- (IBAction)cancelTransactionPressed {
    if (_transaction) {
        [[_account transactionProcessor] cancelTransaction:_transaction using:_tender delegate:self];
    }
}

- (IBAction)resetCardReaderPressed {
    if (_cardReader == nil) {
        [self addStatusString:@"No card reader connected.\n"];
    }
    else
    {
        [_cardReader reset];
    }
}

- (IBAction)addConnectionListenerPressed {
    id<ECLDevicesProtocol> devices = [_account cardReaders];
    [self addStatusString:@"Trying to find device and add listener...\n"];
    [devices findDevices:self connection:allDeviceConnectionsTypes() timeoutInSeconds:30];
}

- (IBAction)connectCardReaderPressed {
    if (_cardReader == nil) {
        [self addStatusString:@"Please add a connection listener first.\n"];
    }
    else
    {
        [self addStatusString:@"Trying to connect...\n"];
        [_cardReader connectAndInitialize];
    }
}

- (IBAction)disconnectCardReaderPressed {
    if (_cardReader == nil) {
        [self addStatusString:@"Nothing to disconnect.\n"];
    }
    else
    {
        [_cardReader disconnect];
    }
}

- (IBAction)removeConnectionListenerPressed {
    if (_cardReader == nil) {
        [self addStatusString:@"No reader to disconnect.\n"];
    }
    else
    {
        [_cardReader disconnect];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case ALERT_TAG_TOKEN:
        {
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            ((id<ECLCardTenderProtocol>)_tender).tokenizedCardNumber = alertText;
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_CARD_PRESENT:
        {
            switch(buttonIndex) {
                case 0:
                    ((id<ECLCardTenderProtocol>)_tender).cardPresent = ECCTriState_No;
                    break;
                case 1:
                    ((id<ECLCardTenderProtocol>)_tender).cardPresent = ECCTriState_Yes;
                    break;
            }
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_FINAL_AMOUNT:
        {
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            NSNumber *finalNumber = [formatter numberFromString:alertText];
            [((id<ECLPreAuthTransactionProtocol>)_transaction) setAmount:[[ECLMoney alloc] initWithMinorUnits:finalNumber.longValue withCurrencyCode:_defaultCurrencyCode]]	;
            _statusLabel.text = @"starting transaction\n";
            [[_account transactionProcessor] processTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_ADDRESS:
        {
            [_tender setAVSField:ECLAVS_CardholderAddress withValue:[alertView textFieldAtIndex:0].text];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];

            return;
        }
        case ALERT_TAG_AVS_ZIP:
        {
            [_tender setAVSField:ECLAVS_CardholderZip withValue:[alertView textFieldAtIndex:0].text];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_CITY:
        {
            [_tender setAVSField:ECLAVS_CardholderCity withValue:[alertView textFieldAtIndex:0].text];
            [avsField setCityRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_STATE:
        {
            [_tender setAVSField:ECLAVS_CardholderState withValue:[alertView textFieldAtIndex:0].text];
            [avsField setStateRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_EMAIL:
        {
            [_tender setAVSField:ECLAVS_CardholderEmail withValue:[alertView textFieldAtIndex:0].text];
            [avsField setEmailRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_FIRSTNAME:
        {
            [_tender setAVSField:ECLAVS_CardholderFirstName withValue:[alertView textFieldAtIndex:0].text];
            [avsField setFirstNameRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_LASTNAME:
        {
            [_tender setAVSField:ECLAVS_CardholderLastName withValue:[alertView textFieldAtIndex:0].text];
            [avsField setLastNameRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_AVS_COUNTRY:
        {
            [_tender setAVSField:ECLAVS_CardholderCountry withValue:[alertView textFieldAtIndex:0].text];
            [avsField setCountryRequirementComplete];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
        case ALERT_TAG_FORCE_SALE_CODE:
        {
            [(id<ECLCardTenderProtocol>)_tender setVoiceReferralHandledAndApproved:[alertView textFieldAtIndex:0].text];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
            return;
        }
    }
}

- (void)callTransactionProcessor {
    //WARNING: Do not change setting during a transaction, the following code is only to disable the function within the sample app.
    [deviceConnectionSettingButton setEnabled:NO];
    [deviceConnectionSettingButton setAlpha:0.5];
    
    _statusLabel.text = @"starting transaction\n";
    [avsField resetAVSFieldValues];
    
   [[_account transactionProcessor] processTransaction:_transaction using:_tender delegate:self];
}

- (void)addStatusString:(NSString *)text {
    if (text == nil) {
        return;
    }
    NSString *origText = _statusLabel.text;
    _statusLabel.text = [origText stringByAppendingString:text];
    if (_statusLabel.text.length > 0)
    {
        NSRange range = NSMakeRange(_statusLabel.text.length - 1, 1);
        [_statusLabel scrollRangeToVisible:range];
    }
}

#pragma mark - ECLTransactionProcessingDelegate

- (void)transactionDidComplete:(id<ECLTransactionProtocol>)transaction using:(id<ECLTenderProtocol>)tender outcome:(ECLTransactionOutcome *)outcome {
    [deviceConnectionSettingButton setEnabled:YES];
    [deviceConnectionSettingButton setAlpha:1.0];
    
    _theOutcome = outcome;
    
    if (_theOutcome.error != nil) {
        [self addStatusString:[NSString stringWithFormat:@"error: %@\n",[_theOutcome.error debugDescription]]];
        [self transactionEnd];
    } else {
        if (_theOutcome.signatureError != nil) {
            [self addStatusString:[NSString stringWithFormat:@"sig error: %@\n",[_theOutcome.signatureError debugDescription]]];
        }
        [self addStatusString:[NSString stringWithFormat:@"result:%@\n", [ECLDebugDescriptions descriptionOfTransactionResult:_theOutcome.result]]];
        if (_theOutcome.result == ECLTransactionResult_PartiallyApproved) {
            [self addStatusString:[NSString stringWithFormat:@"amount authorized:%@\n", [ECLMoneyUtil stringFromMoney:((ECLCardTransactionOutcome *)_theOutcome).amountAuthorized withSymbol:YES withSeparators:YES]]];
            [self addStatusString:[NSString stringWithFormat:@"balance due:%@\n", [ECLMoneyUtil stringFromMoney:((ECLCardTransactionOutcome *)_theOutcome).balanceDue withSymbol:YES withSeparators:YES]]];
        }
        
        id<ECLTransactionSearchCriteriaProtocol> searchCriteria = self.account.historian.transactionSearchCriteria;
        [searchCriteria setTransactionIdentifier:outcome.identifier dateTime:outcome.dateTime];
        [self.account.historian search:searchCriteria delegate:self];
        
        
        if ([_theOutcome isKindOfClass:[ECLCardTransactionOutcome class]]) {
            
            if (((ECLCardTransactionOutcome *)_theOutcome).token.length != 0) {
                [self addStatusString:[NSString stringWithFormat:@"token:%@\n", ((ECLCardTransactionOutcome *)_theOutcome).token]];
            }
            if (((ECLCardTransactionOutcome *)_theOutcome).avsResponse.length != 0) {
                [self addStatusString:[NSString stringWithFormat:@"AVS response:%@\n", ((ECLCardTransactionOutcome *)_theOutcome).avsResponse]];
            }
            
            ECLTransactionResult *tempresult = ((ECLCardTransactionOutcome *)_theOutcome).result;
            NSLog(@"descriptionOfTransactionResult ->%@",[ECLDebugDescriptions descriptionOfTransactionResult:_theOutcome.result]);
            NSLog(@"Response_code ->%@",((ECLCardTransactionOutcome *)_theOutcome).avsResponse);
            NSLog(@"Result_Identifier ->%@",_theOutcome.identifier);
            NSLog(@"AUTH_CODE ->%@",((ECLCardTransactionOutcome *)_theOutcome).authCode);
            NSLog(@"TOKEN ->%@",((ECLCardTransactionOutcome *)_theOutcome).token);
            NSLog(@"code_is ->%@",((ECLCardTransactionOutcome *)_theOutcome).responseCode.code);
            NSLog(@"code_is ->%ld",((ECLCardTransactionOutcome *)_theOutcome).balanceDue.amount);
        }
        
        /*
        if ([outcome isKindOfClass:[ECLEmvCardTransactionOutcome class]]) {
            
        }*/
    }
    _transactionInProgress = NO;
    _currentTransactionProgress = ECLTransactionProgressUndefined;
}

#pragma -- ECLTransactionSearchDelegate

- (void)transactionSearchDidSucceed:(id<ECLTransactionSearchCriteriaProtocol>)criteria results:(ECLTransactionSearchResults *)results {
    if(results.count){
        ECLTransactionSearchResult *result = [results objectAtIndexedSubscript:0];
        
        NSLog(@"avs response -->%@",result.avsResponse);
        NSLog(@"Invoice no -->%@",result.invoiceNumber);
        NSLog(@"card Last Four -->%@",result.cardLastFour);
        NSLog(@"Auth Code -->%@",result.authCode);
    }
}

- (void)transactionDidCancel:(id<ECLTransactionProtocol>)transactionParam using:(id<ECLTenderProtocol>)tenderParam {
    [deviceConnectionSettingButton setEnabled:YES];
    [deviceConnectionSettingButton setAlpha:1.0];
    _theOutcome = nil;
    [self addStatusString:[NSString stringWithFormat:@"%@ canceled\n",[ECLDebugDescriptions descriptionOfTransactionProgress:_currentTransactionProgress]]];
    [self transactionEnd];
}

- (void)transactionDidFail:(id<ECLTransactionProtocol>)transactionParam using:(id<ECLTenderProtocol>)tenderParam errors:(NSArray *)arrayOfNSErrors {
    [deviceConnectionSettingButton setEnabled:YES];
    _theOutcome = nil;
    [self addStatusString:[NSString stringWithFormat:@"Transaction failed: %@\n",[arrayOfNSErrors[0] debugDescription]]];
    [self transactionEnd];
}

- (void)transactionEnd {
    [deviceConnectionSettingButton setEnabled:YES];
    [deviceConnectionSettingButton setAlpha:1.0];
    _transaction = nil;
    _tender = nil;
    _transactionInProgress = NO;
    _currentTransactionProgress = ECLTransactionProgressUndefined;
}

// we need to provide something for the transaction or tender.
// Commerce will keep calling back to this method unless we provide the information it needs
- (void)shouldProvideInformation:(id<ECLTransactionProtocol>)transactionParam tender:(id<ECLTenderProtocol>)tenderParam transactionRequires:(id<ECLTransactionRequirementsProtocol>)transactionRequires tenderRequires:(id<ECLTenderRequirementsProtocol>)tenderRequires {
    BOOL continueTransaction = NO;
    
    if (transactionRequires.requiresTax || transactionRequires.requiresDiscount || transactionRequires.requiresGratuity) {
        [self addStatusString:@"Transaction requires:\n"];
        if (transactionRequires.requiresTax) {
            [self addStatusString:@"   Tax\n"];
            if ([transactionParam conformsToProtocol:@protocol(ECLCurrencyTransactionProtocol)]) {
                id<ECLCurrencyTransactionProtocol> currencyTransaction = (id<ECLCurrencyTransactionProtocol>)transactionParam;
                [currencyTransaction setTax:[[ECLMoney alloc] initWithMinorUnits:0 withCurrencyCode:_defaultCurrencyCode]];
                continueTransaction = YES;
            }
        }
        if (transactionRequires.requiresDiscount) {
            [self addStatusString:@"   Discount\n"];
            if ([transactionParam conformsToProtocol:@protocol(ECLCurrencyTransactionProtocol)]) {
                id<ECLCurrencyTransactionProtocol> currencyTransaction = (id<ECLCurrencyTransactionProtocol>)transactionParam;
                [currencyTransaction setDiscount:[[ECLMoney alloc] initWithMinorUnits:0 withCurrencyCode:_defaultCurrencyCode]];
                continueTransaction = YES;
            }
        }
        if (transactionRequires.requiresGratuity) {
            [self addStatusString:@"   Gratuity\n"];
            if ([transactionParam conformsToProtocol:@protocol(ECLCurrencyTransactionProtocol)]) {
                id<ECLCurrencyTransactionProtocol> currencyTransaction = (id<ECLCurrencyTransactionProtocol>)transactionParam;
                [currencyTransaction setGratuity:nil];
                continueTransaction = YES;
            }
        }
    }
    
    if (tenderRequires.requiresDigitalSignature
        || (tenderRequires.requiresVoiceReferral != ECLVoiceReferral_NotRequired)
        || (tenderRequires.requiresSignatureVerification != ECLSignatureVerification_NotRequired)) {
        [self addStatusString:@"Tender requires:\n"];
        if (tenderRequires.requiresDigitalSignature) {
            [self addStatusString:@"   Signature\n"];
        }
        if (tenderRequires.requiresVoiceReferral != ECLVoiceReferral_NotRequired) {
            [self addStatusString:@"   Voice Referral\n"];
        }
        if (tenderRequires.requiresSignatureVerification != ECLSignatureVerification_NotRequired) {
            [self addStatusString:@"   Signature Verification\n"];
        }
    }
    if (tenderRequires.requiresVoiceReferral != ECLVoiceReferral_NotRequired) {
        [self addStatusString:@"Providing voice referral\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter Auth Code" tag:ALERT_TAG_FORCE_SALE_CODE andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if (tenderRequires.requiresSignatureVerification != ECLSignatureVerification_NotRequired) {
        [self addStatusString:@"Providing signature verification\n"];
        [(id<ECLCardTenderProtocol>)tenderParam setSignatureVerificationHandledAndVerified];
        continueTransaction = YES;
    }
    
    if (tenderRequires.requiresCardData && [_tender isTokenizedCard]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter Credit Card Token" tag:ALERT_TAG_TOKEN andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    
    if (tenderRequires.requiresSpecifyingCardPresence) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithYesNo:@"Card Present?" tag:ALERT_TAG_CARD_PRESENT];
        });
        return;
    }
    
    if ([avsField isCityRequired]) {
        [self addStatusString:@"Providing City\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter City" tag:ALERT_TAG_AVS_CITY andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if ([avsField isStateRequired]) {
        [self addStatusString:@"Providing State\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter State" tag:ALERT_TAG_AVS_STATE andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if ([avsField isEmailRequired]) {
        [self addStatusString:@"Providing Email\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter Email" tag:ALERT_TAG_AVS_EMAIL andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if ([avsField isFirstNameRequired]) {
        [self addStatusString:@"Providing First Name\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter First Name" tag:ALERT_TAG_AVS_FIRSTNAME andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if ([avsField isLastNameRequired]) {
        [self addStatusString:@"Providing Last Name\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter Last Name" tag:ALERT_TAG_AVS_LASTNAME andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    if ([avsField isCountryRequired]) {
        [self addStatusString:@"Providing Country\n"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self launchAlertWithMessage:@"Enter Country" tag:ALERT_TAG_AVS_COUNTRY andStyle:UIAlertViewStylePlainTextInput];
        });
        return;
    }
    
    if (tenderRequires.requiresDigitalSignature){
        [self addStatusString:@"Providing signature\n"];
        [self performSegueWithIdentifier:@"signatureScreenSegue" sender:self];
        return;
    }

    if (continueTransaction) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[_account transactionProcessor] continueProcessingTransaction:transactionParam using:tenderParam delegate:self];
        });
    } else {
        [self addStatusString:@"We could not provide what Commerce wanted. Need to cancel transaction."];
    }
}

-(void)launchAlertWithMessage:(NSString *)message tag:(NSInteger)tag andStyle:(UIAlertViewStyle)style {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Commerce Sample" message:message delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
    alert.tag = tag;
    alert.alertViewStyle = style;
    [alert show];
}

-(void)launchAlertWithDefaultAmount:(NSString *)message tag:(NSInteger)tag andStyle:(UIAlertViewStyle)style andDefaultAmount:(NSString *)defaultAmount{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Commerce Sample" message:message delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
    alert.tag = tag;
    alert.alertViewStyle = style;
    UITextField* textField = [alert textFieldAtIndex:0];
    textField.text = defaultAmount;
    [alert show];
}

-(void)launchAlertWithYesNo:(NSString *)message tag:(NSInteger)tag {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:message delegate:self cancelButtonTitle:@"No"otherButtonTitles:@"Yes", nil];
    alert.tag = tag;

    [alert show];
}

// There are multiple card readers to use
- (void)shouldSetCardReaderToUse:(id<ECLTransactionProtocol>)transactionParam tender:(id<ECLTenderProtocol>)tenderParam cardReaders:(NSArray *)cardReadersReadyForUse {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if ([cardReadersReadyForUse count] > 0)
        {
            _statusLabel.text = @"Setting reader to:\n";
            [self addStatusString:cardReadersReadyForUse[0]];
            [self addStatusString:@"\n"];
            [[_account cardReaders] setDeviceToUse:cardReadersReadyForUse[0] connection:allDeviceConnectionsTypes()];
            [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
        } else {
            [self addStatusString:@"Canceling: no readers\n"];
            [[_account transactionProcessor] cancelTransaction:_transaction using:_tender delegate:self];
        }
    });
}

- (void)transactionProgress:(ECLTransactionProgress)progress transaction:(id<ECLTransactionProtocol>)transactionParam using:(id<ECLTenderProtocol>)tenderParam {
    if (progress == ECLTransactionProgressPinPadResetting) {
        [self addStatusString:[NSString stringWithFormat:@"%@ canceled\n",[ECLDebugDescriptions descriptionOfTransactionProgress:_currentTransactionProgress]]];
    }
    _currentTransactionProgress = progress;
    [self addStatusString:[NSString stringWithFormat:@"%@\n",[ECLDebugDescriptions descriptionOfTransactionProgress:progress]]];
}

- (void)updateKeysFailed:(NSError *)error {
    [self addStatusString:[NSString stringWithFormat:@"UpdateKeys failed: %@\n",[error debugDescription]]];
}

- (void)updateKeysCompleted {
    // we let the progress message update the UI
}

- (void)updateKeysProgress:(ECLTransactionProgress)progress {
    [self addStatusString:[NSString stringWithFormat:@"%@\n",[ECLDebugDescriptions descriptionOfTransactionProgress:progress]]];
}

- (void)fillSegmentControls {
    [self fillTransactionSegmentControl];
    [self fillTenderSegmentControl];
}

- (void)accountInformationRetrievalDidSucceed:(id<ECLAccountProtocol>)account accountInformation:(ECLAccountInformation *)accountInformation {
    [self addStatusString:@"Account Info Retrieval succeeded\n"];
    if ([accountInformation.name length] > 0) {
        [self addStatusString:accountInformation.name];
        [self addStatusString:@"\n"];
    }
    if ([accountInformation.businessEmail length] > 0) {
        [self addStatusString:accountInformation.businessEmail];
        [self addStatusString:@"\n"];
    }
    if ([accountInformation.address1 length] > 0) {
        [self addStatusString:accountInformation.address1];
        [self addStatusString:@"\n"];
    }
    if ([accountInformation.city length] > 0) {
        [self addStatusString:accountInformation.city];
        if ([accountInformation.stateProvince length] > 0) {
            [self addStatusString:@", "];
            [self addStatusString:accountInformation.stateProvince];
        }
        [self addStatusString:@" "];
        if ([accountInformation.postalCode length] > 0) {
            [self addStatusString:accountInformation.postalCode];
        }
        [self addStatusString:@"\n"];
    }
    
    [self fillSegmentControls];
    self.defaultCurrencyCode = accountInformation.currencyCode;
}

- (void)accountInformationRetrievalDidFail:(id<ECLAccountProtocol>)account error:(NSError *)error {
    [self addStatusString:[NSString stringWithFormat:@"Account Info Retrieval failed: %@\n",[error debugDescription]]];
    [self fillSegmentControls];
    // Lets default to USD but that could be a problem
    self.defaultCurrencyCode = ECLCurrencyCode_USD;
}

- (void)fillTenderSegmentControl
{
    NSInteger selectedTender = _tenderSegmentControl.selectedSegmentIndex;
    [_tenderSegmentControl removeAllSegments];

    ECLTransactionType transactionType;
    NSArray *supportedTransactions = [self supportedTransactionsForTenderWithoutID];
    NSInteger selectedTransactionIndex = _transactionSegmentControl.selectedSegmentIndex;
    if (selectedTransactionIndex == -1) {
        if ([supportedTransactions count] == 0) {
            return;
        }
        selectedTransactionIndex = 0;
    }
    transactionType = (ECLTransactionType)[supportedTransactions[selectedTransactionIndex] intValue];
    NSArray *supportedTenders = [[_account transactionProcessor] supportedTendersForTransaction:transactionType];
    NSUInteger index = 0;
    for (NSNumber *tenderTypeNum in supportedTenders) {
        ECLTenderType tenderType = (ECLTenderType)[tenderTypeNum intValue];
        [_tenderSegmentControl insertSegmentWithTitle:[self tenderTypeToString:tenderType] atIndex:index++ animated:NO];
    }
    if (index > 0) {
        if ((selectedTender == -1) || (selectedTender >= index)) {
            _tenderSegmentControl.selectedSegmentIndex = 0;
        } else {
            _tenderSegmentControl.selectedSegmentIndex = selectedTender;
        }
    }
}

- (NSArray *)supportedTransactionsForTenderWithoutID {
    NSArray *supportedTransactions = [[_account transactionProcessor] supportedTransactions];
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (NSNumber *transactionTypeNum in supportedTransactions) {
        ECLTransactionType transactionType = (ECLTransactionType)[transactionTypeNum intValue];
        // filter out transaction types that need a ID added (these are done thru search transaction)
        if (transactionType != ECLTransactionType_PreAuthComplete && transactionType != ECLTransactionType_PreAuthDelete && transactionType != ECLTransactionType_Void && transactionType != ECLTransactionType_LinkedRefund) {
            [finalArray addObject:@(transactionType)];
        }
    }
    return finalArray;
}

- (void)fillTransactionSegmentControl
{
    NSInteger selectedTransaction = _transactionSegmentControl.selectedSegmentIndex;
    NSArray *supportedTransactions = [self supportedTransactionsForTenderWithoutID];
    [_transactionSegmentControl removeAllSegments];
    NSUInteger index = 0;
    for (NSNumber *transactionTypeNum in supportedTransactions) {
        ECLTransactionType transactionType = (ECLTransactionType)[transactionTypeNum intValue];
        [_transactionSegmentControl insertSegmentWithTitle:[self transactionTypeToString:transactionType] atIndex:index++ animated:NO];
    }
    if (index > 0) {
        if ((selectedTransaction == -1) || (selectedTransaction >= index)) {
            _transactionSegmentControl.selectedSegmentIndex = 0;
        } else {
            _transactionSegmentControl.selectedSegmentIndex = selectedTransaction;
        }
    }
}

- (NSString *)transactionTypeToString:(ECLTransactionType) transactionType {
    switch(transactionType) {
        case ECLTransactionType_Sale:
            return @"Sale";
        case ECLTransactionType_ForcedSale:
            return @"Forced Sale";
        case ECLTransactionType_LinkedRefund:
            return @"L Refund";
        case ECLTransactionType_StandaloneRefund:
            return @"S Refund";
        case ECLTransactionType_Void:
            return @"Void";
        case ECLTransactionType_PreAuth:
            return @"PreAuth";
        case ECLTransactionType_PreAuthComplete:
            return @"PreAuth_Complete";
        case ECLTransactionType_PreAuthDelete:
            return @"PreAuth_Delete";
        case ECLTransactionType_Unknown:
            return @"Unknown";
    }
}

- (NSString *)tenderTypeToString:(ECLTenderType) tenderType {
    switch(tenderType) {
        case ECLTenderType_Cash:
            return @"Cash";
        case ECLTenderType_Card:
            return @"Card";
        case ECLTenderType_Unknown:
            return @"Unknown";
    }
}

- (IBAction)startTransaction {
    
    if (_transactionSegmentControl.numberOfSegments == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No transaction types. Probably unable to contact server. Click 'Get Account Info'" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    NSInteger selectedTransactionIndex = [_transactionSegmentControl selectedSegmentIndex];
    NSInteger selectedTenderIndex = [_tenderSegmentControl selectedSegmentIndex];
    NSArray *supportedTransactions = [self supportedTransactionsForTenderWithoutID];
    if (selectedTransactionIndex == -1) {
        selectedTransactionIndex = 0;
    }
    ECLTransactionType transactionType;
    transactionType = (ECLTransactionType)[supportedTransactions[selectedTransactionIndex] integerValue];
    if ((transactionType == ECLTransactionType_LinkedRefund)
        || (transactionType == ECLTransactionType_Void)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[self transactionTypeToString:transactionType] message:@"Use transaction history to do void or linked refund" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    NSArray *tenders = [[_account transactionProcessor] supportedTendersForTransaction:transactionType];
    currentTenderType = (ECLTenderType)[tenders[selectedTenderIndex] integerValue];
    currentTransactionType = transactionType;
    [self performSegueWithIdentifier:@"TransactionSegue" sender:self];
}
- (IBAction)validateAccount {
    _statusLabel.text = @"validating account\n";
    [_account validateAccount:self];
}

- (IBAction)retrieveAccountInformation {
    _statusLabel.text = @"retrieving account info\n";
    [_account retrieveAccountInformation:self];
}
- (IBAction)transactionHistory {
    [self performSegueWithIdentifier:@"transactionHistorySegue" sender:self];
}

- (IBAction)editAccountSettings {
    [self performSegueWithIdentifier:@"accountSettingsSegue" sender:self];
}

- (void)accountDidValidate:(id<ECLAccountProtocol>)account {
    [self addStatusString:@"Account validated\n"];
}

- (IBAction)retrieveCardData {
    [self performSegueWithIdentifier:@"retrieveCardDataSegue" sender:self];
}

- (IBAction)retrievePin {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (_prevMagStripeCardData == nil) {
            [self addStatusString:@"Please perform a card read first\n"];
        } else {
            if (_cardReader == nil) {
                [self addStatusString:@"No card reader connected.\n"];
                
            }
            else
            {
                [_cardReader retrievePin:self forCardData:_prevMagStripeCardData];
            }
        }
        
    });
}

- (IBAction)refreshStatus {
    [self performSegueWithIdentifier:@"refreshStatusSegue" sender:self];
}

- (IBAction)getEnvironmentInfo {
    _statusLabel.text = @"Environment Info:\n";
    [self addStatusString:@"=================\n"];
    [self addStatusString:[NSString stringWithFormat:@"iOS version: %@\n", [[UIDevice currentDevice] systemVersion]]];
    [self addStatusString:[NSString stringWithFormat:@"Model: %@\n", [[UIDevice currentDevice] model]]];
}

- (IBAction)getVersionInfo {
    _statusLabel.text = @"Version Info:\n";
    [self addStatusString:@"=================\n"];
    
    NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    if (appVersion != nil)
    {
        [self addStatusString:[NSString stringWithFormat:@"Sample app version: %@\n", appVersion]];
    }
    
    NSString *commerceSDKVersion = [ECLCommerce versionString];
    if ([commerceSDKVersion length] != 0)
    {
        [self addStatusString:[NSString stringWithFormat:@"Commerce version: %@\n", commerceSDKVersion]];
    }
    
    NSString *commonVersion = [ECCCommon versionString];
    if ([commonVersion length] != 0)
    {
        [self addStatusString:[NSString stringWithFormat:@"Common version: %@\n", commonVersion]];
    }
    
    NSString *commonDataVersion = [ECLCommerceDataTypes versionString];
    if ([commonDataVersion length] != 0)
    {
        [self addStatusString:[NSString stringWithFormat:@"CommerceDataTypes version: %@\n", commonDataVersion]];
    }
}

- (IBAction)ipCardReaderSettings {
    [self performSegueWithIdentifier:@"ipCardReaderSettingsSegue" sender:self];
}

- (void)accountDidValidateWithExpiredPassword:(id<ECLAccountProtocol>)account {
    [self addStatusString:@"Account validated w/ expired pwd\n"];
}

- (BOOL)shouldCheckPasswordExpiration {
    return YES;
}


/// \brief Notification that the account was not validated
/// \param account The account which was not validated
/// \param error Indicates the reason that the account was not validated
- (void)accountDidFailToValidate:(id<ECLAccountProtocol>)account error:(NSError *)error {
    [self addStatusString:[NSString stringWithFormat:@"Account failed to be validated: %@\n", [error debugDescription]]];
}

- (UIButton*) addButton:(id)target selector:(SEL) selector withTitle:(NSString*) title atVerticalPosition:(NSInteger)verticalButtonPosition
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor: [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState: UIControlStateNormal];
    button.frame = CGRectMake(0, verticalButtonPosition, self.view.frame.size.width, 20.0);
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.actionScrollView addSubview:button];
    return button;
}

- (void) populateActionMenu {
    
    NSInteger verticalButtonPosition = 0;
    [self.actionScrollView setContentSize: CGSizeMake(self.view.frame.size.width, self.actionScrollView.frame.size.height + 500)];
    
    //common actions
    [self addButton:self selector:@selector(startTransaction) withTitle:@"Start Transaction" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(cancelTransactionPressed) withTitle:@"Cancel Transaction" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(resetCardReaderPressed) withTitle:@"Reset Card Reader" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(transactionHistory) withTitle:@"Search Transactions" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(validateAccount) withTitle:@"Validate Account" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(retrieveAccountInformation) withTitle:@"Get Account Info" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(editAccountSettings) withTitle:@"Edit Account Settings" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(addConnectionListenerPressed) withTitle:@"Find/Connect Card Reader" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(removeConnectionListenerPressed) withTitle:@"Disconnect Card Reader" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(retrieveCardData) withTitle:@"Retrieve Card Data" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(retrievePin) withTitle:@"Retrieve Pin" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(refreshStatus) withTitle:@"Refresh Status" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(getEnvironmentInfo) withTitle:@"Get Environment Info" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [self addButton:self selector:@selector(getVersionInfo) withTitle:@"Get Version Info" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    deviceConnectionSettingButton = [self addButton:self selector:@selector(ipCardReaderSettings) withTitle:@"IP Card Reader Settings" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    
    [_flavor addButtons:verticalButtonPosition];    
}

#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"transactionHistorySegue"]) {
        HistorianViewController *historianViewController = (HistorianViewController *)segue.destinationViewController;
        [historianViewController accountFromPastView:_account];
        historianViewController.receiptFeatures = _receiptFeatures;
    }
    if ([segue.identifier isEqualToString:@"accountSettingsSegue"]) {
        AccountSettingsViewController *accountSettingsViewController = (AccountSettingsViewController *)segue.destinationViewController;
        [accountSettingsViewController passMainViewController:self];
    }
    if ([segue.identifier isEqualToString:@"TransactionSegue"]) {
        TransactionViewController *cardTransactionViewController = (TransactionViewController *)segue.destinationViewController;
        cardTransactionViewController.transactionType = currentTransactionType;
        cardTransactionViewController.tenderType = currentTenderType;
        cardTransactionViewController.transactionString = [self transactionTypeToString:currentTransactionType];
        cardTransactionViewController.tenderString = [self tenderTypeToString:currentTenderType];
        cardTransactionViewController.processor = [_account transactionProcessor];
        cardTransactionViewController.currency = _defaultCurrencyCode;
    }
    if ([segue.identifier isEqualToString:@"retrieveCardDataSegue"]) {
        RetrieveCardDataViewController *retrieveCardDataViewController = (RetrieveCardDataViewController *)segue.destinationViewController;
        [retrieveCardDataViewController passMainViewController:self];
    }
    if ([segue.identifier isEqualToString:@"refreshStatusSegue"]) {
        RefreshStatusViewController *refreshStatusViewController = (RefreshStatusViewController *)segue.destinationViewController;
        [refreshStatusViewController passMainViewController:self];
    }
    if ([segue.identifier isEqualToString:@"ipCardReaderSettingsSegue"]) {
        IpCardReaderSettingsViewController *ipCardReaderSettingsViewController = (IpCardReaderSettingsViewController *)segue.destinationViewController;
        [ipCardReaderSettingsViewController passMainViewController:self];
    }
}

-(IBAction)returnFromSettings:(UIStoryboardSegue *)unwindSegue
{
    
}

-(IBAction)returnfromSignatureScreen:(UIStoryboardSegue *)unwindSegue
{
    UIImage *signature = [unwindSegue.sourceViewController sign];
    if (signature != nil) {
        [(id<ECLCardTenderProtocol>)_tender setDigitalSignature:[[ECLSignatureData alloc] initWithImageRef:[signature CGImage]]];
    } else {
        [(id<ECLCardTenderProtocol>)_tender cancelSignature];
    }
    [[_account transactionProcessor] continueProcessingTransaction:_transaction using:_tender delegate:self];
}

- (void)deviceSearchFound:(id<ECLDevicesProtocol>)cardReaders name:(NSString *)name connection:(ECLDeviceConnectionType)connection {
    
}

-(IBAction)unwindToMainView:(UIStoryboardSegue *)unwindSegue
{
    if ([unwindSegue.sourceViewController isKindOfClass:[TransactionDetailViewController class]])
    {
        ECLTransactionType transactionType = ((TransactionDetailViewController *)unwindSegue.sourceViewController).transactionTypeToPerform;
        ECLTransactionSearchResult* transaction = ((TransactionDetailViewController *)unwindSegue.sourceViewController).transaction;
        ECLTenderType tenderType = transaction.tenderType;
        ECLCardType cardType = transaction.cardType;
        
        if (transactionType == ECLTransactionType_PreAuthComplete) {
            // preauth only works for cards
            _tender = [[_account transactionProcessor] createCardTender];
            _transaction = [[_account transactionProcessor] createPreAuthCompleteTransactionWithTotal:transaction.amountAuthorized transactionID:transaction.identifier];
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self launchAlertWithDefaultAmount:@"Enter Final Sale Amount" tag:ALERT_TAG_FINAL_AMOUNT andStyle:UIAlertViewStylePlainTextInput andDefaultAmount:
                 [[NSNumber numberWithLong:transaction.amountAuthorized.amount] stringValue]];
            });
            return;
        }
        
        if (transactionType == ECLTransactionType_Void) {
            _transaction = [[_account transactionProcessor] createVoidTransactionWithTotal:transaction.amountRefundable transactionID:transaction.identifier];
        } else if (transactionType == ECLTransactionType_LinkedRefund) {
            // linked refunds for cash are not supported
            if (tenderType == ECLTenderType_Cash) {
                _transaction = [[_account transactionProcessor] createStandaloneRefundTransactionWithTotal:transaction.amountRefundable];
            } else {
                _transaction = [[_account transactionProcessor] createLinkedRefundTransactionWithTotal:transaction.amountRefundable transactionID:transaction.identifier];
            }
        } else if (transactionType == ECLTransactionType_PreAuthDelete) {
            _transaction = [[_account transactionProcessor] createPreAuthDeleteTransactionWithTotal:transaction.amountRefundable transactionID:transaction.identifier];
        }

        if (tenderType == ECLTenderType_Card) {
            id<ECLCardTenderProtocol> cardTender = [[_account transactionProcessor] createCardTender];
            [cardTender setAllowedCardTypes:cardType];
            _tender = cardTender;
        }
        else if (tenderType == ECLTenderType_Cash) {
            id<ECLCashTenderProtocol> cashTender = [[_account transactionProcessor] createCashTender];
            [cashTender setAmountTendered:transaction.amountRefundable];
            _tender = cashTender;
        }
        
        [self callTransactionProcessor];
    }
    if ([unwindSegue.sourceViewController isKindOfClass:[TransactionViewController class]])
    {
        if (_transactionInProgress == YES)
        {
            [self addStatusString:@"Transaction failed:\n"];
            [self addStatusString:@"TransactionOtherTransactionBeingProcessed\n"];
            return;
        }
        TransactionViewController *cardTransactionViewController = (TransactionViewController *)unwindSegue.sourceViewController;
        if (cardTransactionViewController.resultingTender != nil && cardTransactionViewController.resultingTransaction != nil) {
            _tender = cardTransactionViewController.resultingTender;
            _transaction = cardTransactionViewController.resultingTransaction;
            _transactionInProgress = YES;
            [self callTransactionProcessor];
        }
    }
    if ([unwindSegue.sourceViewController isKindOfClass:[IpCardReaderSettingsViewController class]]) {
        id<ECLDevicesProtocol> devices = [_account cardReaders];

        [self addStatusString:@"setDeviceToUse nil\n"];
        [devices setDeviceToUse:nil connection:allDeviceConnectionsTypes()];
    }
}

- (void)deviceSearchDone:(id<ECLDevicesProtocol>)cardReaders searchResults:(NSArray *)searchResults {
    // continue the transaction
    dispatch_async(dispatch_get_main_queue(), ^() {
        if ([searchResults count] > 0)
        {
            _statusLabel.text = @"Setting reader to:\n";
            [self addStatusString:((ECLDeviceSearchResult *)searchResults[0]).name];
            [self addStatusString:@"\n"];
            [cardReaders setDeviceToUse:((ECLDeviceSearchResult *)searchResults[0]).name connection:((ECLDeviceSearchResult *)searchResults[0]).connectionTypes];
            
            _cardReader =  (id<ECLCardReaderProtocol>)[cardReaders selectedDevice];
            [_cardReader addConnectionDelegate:self];
            [_cardReader addStatusDelegate:self];
            [self addStatusString:@"Connection listener added.\n"];

            [_cardReader connectAndInitialize];
            [self addStatusString:@"Initializing...\n"];
        } else {
            [self addStatusString:@"Canceling: no readers\n"];
            [cardReaders setDeviceToUse:nil connection:allDeviceConnectionsTypes()];
            _cardReader = nil;
        }
    });
    
}

- (void)printDidSucceed:(id<ECLPrinterProtocol>)printer {
    
}
- (void)printDidFail:(id<ECLPrinterProtocol>)printer error:(ECLError *)error {
    
}

- (IBAction)transactionSegmentChanged:(id)sender {
    [self fillTenderSegmentControl];
}

- (void)cardReaderRetrievePin:(id<ECLCardReaderProtocol>)cardReader providedPin:(ECLCardReaderPin *)pinResult {
    [self addStatusString:@"Retrieve Pin Data:\n"];
    [self addStatusString:[NSString stringWithFormat:@"Encryption Format : %@\n",[ECLDebugDescriptions descriptionOfPinEncryptionMethod:pinResult.encryptionMethod]]];
    [self addStatusString:[NSString stringWithFormat:@"Ksn : %@\n", pinResult.ksn]];
    [self addStatusString:[NSString stringWithFormat:@"Pin : %@\n", pinResult.pin]];
}
     
- (void)cardReaderRetrievePin:(id<ECLCardReaderProtocol>)cardReader error:(NSError *)error {
    [self addStatusString:[NSString stringWithFormat:@"Retrieve Pin failed: %@\n",[error debugDescription]]];
}
- (void)cardReaderRetrievePin:(id<ECLCardReaderProtocol>)cardReader progress:(ECLTransactionProgress)progress {
    [self addStatusString:[NSString stringWithFormat:@"%@\n",[ECLDebugDescriptions descriptionOfTransactionProgress:progress]]];
}

- (void)cardReaderConnectedAndWillInitialize:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReaderInitialized:(id<ECLCardReaderProtocol>)cardReader {
    [self addStatusString:@"Reader initialized\n"];
}
- (void)cardReader:(id<ECLCardReaderProtocol>)cardReader erroredConnectingOrInitializating:(NSError *)error {}
- (void)cardReaderWillUpdateConfiguration:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReaderUpdateSucceeded:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReader:(id<ECLCardReaderProtocol>)cardReader erroredUpdating:(NSError *)error {}  // TODO do we need this or is error good enough?
- (void)cardReaderWillReboot:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReaderShouldManuallyReboot:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReader:(id<ECLCardReaderProtocol>)cardReader erroredRebooting:(NSError *)error {}
- (void)cardReaderWillReset:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReaderDidReset:(id<ECLCardReaderProtocol>)cardReader {}
- (void)cardReader:(id<ECLCardReaderProtocol>)cardReader erroredResetting:(NSError *)error {}
- (void)cardReaderDisconnected:(id<ECLCardReaderProtocol>)cardReader isStillTransacting:(BOOL)isStillTransacting {
    [self addStatusString:@"Reader disconnected\n"];
}
- (void)cardReader:(id<ECLCardReaderProtocol>)cardReader progress:(ECLTransactionProgress)progress {}


- (void)deviceConnectionStateChanged:(id<ECLDeviceProtocol>)device deviceConnectionState:(ECLDeviceConnectionState)deviceConnectionState {
    [self addStatusString:[NSString stringWithFormat:@"Card reader %@ is %@\n", [(id<ECLCardReaderProtocol>)device name ], [self connectionStatusToString:deviceConnectionState]]];
}

- (void)devicePowerStateChanged:(id<ECLDeviceProtocol>)device devicePowerState:(ECLDevicePowerState *)devicePowerState {
    [self addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charge level: %@\n", [(id<ECLCardReaderProtocol>)device name], [[devicePowerState batteryChargeLevel] chargeLevel]]];
    [self addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charge state: %@\n", [(id<ECLCardReaderProtocol>)device name], [self batteryLevelToString:[[devicePowerState batteryChargeLevel] chargeLevelState]]]];
    [self addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charging state: %@\n", [(id<ECLCardReaderProtocol>)device name], [self batteryChargingStateToString:[devicePowerState batteryChargingState]]]];
}

- (void)refreshStatusDidFail:(id<ECLDeviceProtocol>)device errors:(NSArray *)arrayOfNSErrors {
}

- (NSString *)connectionStatusToString:(ECLDeviceConnectionState) connectionStatus {
    switch(connectionStatus) {
        case ECLDeviceConnectionState_Connected:
            return @"Connected";
        case ECLDeviceConnectionState_Disconnected:
            return @"Disconnected";
        case ECLDeviceConnectionState_ConnectedNotReady:
            return @"Connected Not Ready";
        case ECLDeviceConnectionState_Unknown:
            return @"Unknown";
        case ECLDeviceConnectionState_UnSet:
            return @"UnSet";
    }
}

- (NSString *)batteryChargingStateToString:(ECLDeviceBatteryChargingState) chargingState {
    switch(chargingState) {
        case ECLDeviceBatteryChargingState_Charging:
            return @"Charging";
        case ECLDeviceBatteryChargingState_ChargingUsb:
            return @"Charging Usb";
        case ECLDeviceBatteryChargingState_ChargingAc:
            return @"Charging AC";
        case ECLDeviceBatteryChargingState_Discharging:
            return @"Discharging";
        case ECLDeviceBatteryChargingState_Unknown:
            return @"Unknown";
        case ECLDeviceBatteryChargingState_UnSet:
            return @"UnSet";
    }
}

- (NSString *)batteryLevelToString:(ECLDeviceBatteryChargeLevelState) batteryLevel {
    switch(batteryLevel) {
        case ECLDeviceBatteryChargeLevelState_Full:
            return @"Full";
        case ECLDeviceBatteryChargeLevelState_Good:
            return @"Good";
        case ECLDeviceBatteryChargeLevelState_Low:
            return @"Low";
        case ECLDeviceBatteryChargeLevelState_Critical:
            return @"Critical";
        case ECLDeviceBatteryChargeLevelState_Unknown:
            return @"Unknown";
        case ECLDeviceBatteryChargeLevelState_UnSet:
            return @"UnSet";
    }
}

@end
