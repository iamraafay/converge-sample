//
//  MainViewController+Receipts.m
//  Commerce Sample
//
//  Created by Bryan, Edward P on 11/10/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "ReceiptFeatures.h"
#import "MainViewController.h"
#import "AlertIDs.h"
#import <ElavonCommon/NSDecimalNumber+ECCMinorUnits.h>

@implementation ReceiptFeatures

- (id)init:(MainViewController *)mainViewControllerParam {
    self = [super init];
    if (self) {
        self.mainViewController = mainViewControllerParam;
    }
    return self;
}

- (void)sendEmailReceipt {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"Enter email address you want receipt sent to" delegate:self cancelButtonTitle:@"Send" otherButtonTitles:nil];
    alert.tag = ALERT_TAG_RECEIPT_EMAIL;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)sendSMSReceipt {
    if (_mainViewController.transaction) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"Enter phone number to send receipt" delegate:self cancelButtonTitle:@"Send" otherButtonTitles:nil];
        alert.tag = ALERT_TAG_RECEIPT_SMS;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"No transaction to send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)printReceipt {
    if (_mainViewController.transaction) {
        
        self.receiptProcessor = [_mainViewController.account receiptProcessor];
        self.receipt = [self.receiptProcessor createReceiptForCurrentTransaction:_mainViewController.transaction using:_mainViewController.tender withOutcome:_mainViewController.theOutcome];
        [self choosePrinterAlertBox];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"No transaction to send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)choosePrinterAlertBox {
    [_mainViewController.account.printers findDevices:self connection:allDeviceConnectionsTypes() timeoutInSeconds:30];
}

- (void)deviceSearchFound:(id<ECLDevicesProtocol>)devices name:(NSString *)name connection:(ECLDeviceConnectionType)connection {
    
}

- (void)deviceSearchDone:(id<ECLDevicesProtocol>)devices searchResults:(NSArray *)searchResults {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"Select Printer" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    for (int i = 0; i< [searchResults count];i++) {
        [alert addButtonWithTitle:((ECLDeviceSearchResult *)searchResults[i]).name];
    }
    alert.tag = ALERT_TAG_RECEIPT_PRINT;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case ALERT_TAG_RECEIPT_EMAIL:
        case ALERT_TAG_HISTORICAL_RECEIPT_EMAIL:
        {
            self.receiptProcessor = [_mainViewController.account receiptProcessor];
            if (alertView.tag == ALERT_TAG_RECEIPT_EMAIL) {
                self.receipt = [self.receiptProcessor createReceiptForCurrentTransaction:_mainViewController.transaction using:_mainViewController.tender withOutcome:_mainViewController.theOutcome];
            } else {
                self.receipt = [self.receiptProcessor createReceiptForHistoricalTransaction:self.theResult];
            }
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            [self.receiptProcessor emailReceipt:self.receipt emailAddress:alertText delegate:self];
            return;
        }
        case ALERT_TAG_RECEIPT_SMS:
        {
            self.receiptProcessor = [_mainViewController.account receiptProcessor];
            self.receipt = [self.receiptProcessor createReceiptForCurrentTransaction:_mainViewController.transaction using:_mainViewController.tender withOutcome:_mainViewController.theOutcome];
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            [self.receiptProcessor smsReceipt:self.receipt phoneNumber:alertText delegate:self];
            return;
        }
        case ALERT_TAG_RECEIPT_PRINT:
        {
            NSString *alertText = [alertView buttonTitleAtIndex:buttonIndex];
            if ([alertText isEqualToString:@"Cancel"]) {
                break;
            }
            else {
                id<ECLPrinterProtocol> printer = (id<ECLPrinterProtocol>)[_mainViewController.account.printers setDeviceToUse:alertText connection:allDeviceConnectionsTypes()];
                if (self.receiptProcessor == nil) {
                    self.receiptProcessor = [_mainViewController.account receiptProcessor];
                }
                if (self.receipt == nil) {
                    self.receipt = [self.receiptProcessor createReceiptForHistoricalTransaction:self.theResult];
                }
               [self.receiptProcessor printReceipt:self.receipt printer:printer delegate:self];
                return;
                
            }
        }
        default:
            [self alertView:alertView clickedButtonAtIndex:buttonIndex];
             break;
    }
}


- (void)receiptDidSucceed:(id<ECLReceiptProtocol>)receipt output:(ECLReceiptOutputType)output {
    [_mainViewController addStatusString:@"Receipt was sent\n"];
}

- (void)receiptDidFail:(id<ECLReceiptProtocol>)receipt output:(ECLReceiptOutputType)output error:(NSError *)error {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Receipt failed to be sent: %@\n",[error debugDescription]]];
}

- (NSString *)receiptShouldProvideLocalizedText:(id<ECLReceiptProtocol>)receipt for:(ECLReceiptTextIdentifier)textIdentifier {
    // should return localized text based on the textIdentifier
    NSString *rv;
    switch (textIdentifier) {
        case ECLReceipt_Card: rv = @"Card"; break;
        case ECLReceipt_Start: rv = @"Start"; break;
        case ECLReceipt_Expiry: rv = @"Expiry"; break;
        case ECLReceipt_Sale: rv = @"Sale"; break;
        case ECLReceipt_Refund: rv = @"Refund"; break;
        case ECLReceipt_Gratuity: rv = @"Tip"; break;
        case ECLReceipt_Total: rv = @"Total"; break;
        case ECLReceipt_Approved: rv = @"Approved"; break;
        case ECLReceipt_Declined: rv = @"Declined"; break;
        case ECLReceipt_Reference: rv = @"Ref"; break;
        case ECLReceipt_Merchant: rv = @"Merchant"; break;
        case ECLReceipt_RetentionReminder: rv = @"Please retain for your records"; break;
        case ECLReceipt_PleaseSignBelow: rv = @"Please sign below"; break;
        case ECLReceipt_PleaseDebit: rv = @"Please debit my account with the total shown"; break;
        case ECLReceipt_PleaseCredit: rv = @"Please credit my account with the total shown"; break;
        case ECLReceipt_Receipt: rv = @"Receipt"; break;
        case ECLReceipt_AuthCode: rv = @"Auth Code"; break;
        case ECLReceipt_PanSequenceNo: rv = @"PAN Sequence Number"; break;
        case ECLReceipt_TacDefault: rv = @"TAC Default"; break;
        case ECLReceipt_TacDenial: rv = @"TAC Denial"; break;
        case ECLReceipt_TacOnline: rv = @"TAC Online"; break;
        case ECLReceipt_Discount: rv = @"Discount"; break;
        case ECLReceipt_Tax: rv = @"Tax"; break;
        case ECLReceipt_Net: rv = @"Net"; break;
        case ECLReceipt_Subtotal: rv = @"Subtotal"; break;
        case ECLReceipt_Cash: rv = @"Cash"; break;
        case ECLReceipt_Check: rv = @"Cheque"; break;
        case ECLReceipt_AmountTendered: rv = @"Amount Tendered"; break;
        case ECLReceipt_ChangeDue: rv = @"Change Due"; break;
        case ECLReceipt_TransactionType: rv = @"Transaction Type"; break;
        case ECLReceipt_TransactionReference: rv = @"Trans Ref"; break;
        case ECLReceipt_TenderType: rv = @"Tender Type"; break;
        case ECLReceipt_EntryMethod: rv = @"Entry Method"; break;
        case ECLReceipt_CardNumber: rv = @"Card Number"; break;
        case ECLReceipt_CardType: rv = @"Card Type"; break;
        case ECLReceipt_ApprovalCode: rv = @"Approval Code"; break;
        case ECLReceipt_AID: rv = @"AID"; break;
        case ECLReceipt_TVR: rv = @"TVR"; break;
        case ECLReceipt_TSI: rv = @"TSI"; break;
        case ECLReceipt_Signature: rv = @"SIGNATURE"; break;
        case ECLReceipt_CardHolderWillPay: rv = @"CARDHOLDER WILL PAY CARD ISSUER ABOVE AMOUNT PURSUANT TO CARDHOLDER AGREEMENT"; break;
        case ECLReceipt_CardHolderVerification: rv = @"Verification"; break;
        case ECLReceipt_From: rv = @"From"; break;
        case ECLReceipt_IccApplicationID: rv = @"Application ID"; break;
        case ECLReceipt_IccTransactionCounter: rv = @"Transaction Counter"; break;
        case ECLReceipt_IccFallbackSwipe: rv = @"Fallback Swiped"; break;
        case ECLReceipt_Vat: rv = @"Vat"; break;
        case ECLReceipt_Application: rv = @"Application"; break;
        case ECLReceipt_BalanceDue: rv = @"Balance Due"; break;
        case ECLReceipt_AmountAuthorized: rv = @"Amount Approved"; break;
        
    }
    
    return rv;
}

- (NSString *)receiptShouldProvideLocalizedText:(id<ECLReceiptProtocol>)receipt forTransactionResult:(ECLTransactionResult)result {
    switch(result) {
        case ECLTransactionResult_Unknown: return @"UNKNOWN";
        case ECLTransactionResult_Approved: return @"APPROVED";
        case ECLTransactionResult_PartiallyApproved: return @"PARTIALLY APPROVED";
        case ECLTransactionResult_SwipedSuccessfully: return @"SWIPED SUCCESSFULLY";
        case ECLTransactionResult_SecurityCodeFailure: return @"SECURITY CODE FAILURE";
        case ECLTransactionResult_Declined: return @"DECLINED";
        case ECLTransactionResult_VoiceReferral: return @"VOICE REFERRAL";
        case ECLTransactionResult_Rejected: return @"REJECTED";
        case ECLTransactionResult_TemporarilyUnavailable: return @"TEMPORARILY UNAVAILABLE";
        case ECLTransactionResult_ExpiredCard: return @"EXPIRED CARD";
        case ECLTransactionResult_PreValidCard: return @"PREVALIDCARD";
        case ECLTransactionResult_FailedLuhnCheck: return @"FAILED LUHN CHECK";
        case ECLTransactionResult_IssueNumberMissing: return @"ISSUE NUMBER MISSING";
        case ECLTransactionResult_IssueNumberInvalid: return @"ISSUE NUMBER INVALID";
        case ECLTransactionResult_UnknownAcquirer: return @"UNKNOWN ACQUIRER";
        case ECLTransactionResult_AcquirerDisabled: return @"ACQUIRER DISABLED";
        case ECLTransactionResult_UnknownMerchant: return @"UNKNOWN MERCHANT";
        case ECLTransactionResult_UnknownTerminal: return @"UNKNOWN TERMINAL";
        case ECLTransactionResult_MerchantDisabled: return @"MERCHANT DISABLED";
        case ECLTransactionResult_CardBlacklisted: return @"CARD BLACKLISTED";
        case ECLTransactionResult_CardBlocked: return @"CARD BLOCKED";
        case ECLTransactionResult_CardUsageExceededLimits: return @"CARD USAGE EXCEEDED LIMITS";
        case ECLTransactionResult_CardSchemeUnknown: return @"CARD SCHEME UNKNOWN";
        case ECLTransactionResult_AmountMissing: return @"AMOUNT MISSING";
        case ECLTransactionResult_AmountError: return @"AMOUNT ERROR";
        case ECLTransactionResult_AmountTooSmall: return @"AMOUNT TOO SMALL";
        case ECLTransactionResult_AmountTooLarge: return @"AMOUNT TOO LARGE";
        case ECLTransactionResult_CurrencyCodeMissing: return @"CURRENCY CODE MISSING";
        case ECLTransactionResult_UnknownCurrencyCode: return @"UNKNOWN CURRENCY CODE";
        case ECLTransactionResult_UnsupportedCurrencyCode: return @"UNSUPPORTED CURRENCY CODE";
        case ECLTransactionResult_ApplTypeError: return @"APPL TYPE ERROR";
        case ECLTransactionResult_SystemError: return @"SYSTEM ERROR";
        case ECLTransactionResult_IncorrectPin: return @"INCORRECT PIN";
        case ECLTransactionResult_InvalidCard: return @"INVALID CARD";
        case ECLTransactionResult_InvalidCAVV: return @"INVALID CAVV";
        case ECLTransactionResult_InvalidRoutingNumber: return @"INVALID ROUTING NUMBER";
        case ECLTransactionResult_InvalidServiceEntitlementNumber: return @"INVALID SERVICE ENTITLEMENT NUMBER";
        case ECLTransactionResult_MICR_ReadError: return @"MICR READ ERROR";
        case ECLTransactionResult_OpenBatchTooOld: return @"OPEN BATCH TOO OLD";
        case ECLTransactionResult_SequenceError: return @"SEQUENCE ERROR";
        case ECLTransactionResult_ExceededNumberOfChecks: return @"EXCEEDED NUMBER OF CHECKS";
        case ECLTransactionResult_MaximumAmountLoadedOnCard: return @"MAXIMUM AMOUNT LOADED ON CARD";
        case ECLTransactionResult_CardNotReloadable: return @"CARD NOT RELOADABLE";
        case ECLTransactionResult_TransactionNotAllowed: return @"TRANSACTION NOT ALLOWED";
        case ECLTransactionResult_InvalidTransactionType: return @"INVALID TRANSACTION TYPE";
        case ECLTransactionResult_CardAlreadyActive: return @"CARD ALREADY ACTIVE";
        case ECLTransactionResult_CardNotActive: return @"CARD NOT ACTIVE";
        case ECLTransactionResult_DuplicateTransaction: return @"DUPLICATE TRANSACTION";
        case ECLTransactionResult_InvalidBatchID: return @"INVALID BATCH ID";
        case ECLTransactionResult_InvalidTender: return @"INVALID TENDER";
        case ECLTransactionResult_InvalidData: return @"INVALID DATA";
        case ECLTransactionResult_DuplicateCheckNumber: return @"DUPLICATE CHECK NUMBER";
        case ECLTransactionResult_MaximumVolumeReached: return @"MAXIMUM VOLUME REACHED";
        case ECLTransactionResult_InvalidService: return @"INVALID SERVICE";
        case ECLTransactionResult_IssuerNeedsToBeContacted: return @"CALL AUTH CENTER";
        case ECLTransactionResult_EngineersTest: return @"ENGINEERS TEST";
        case ECLTransactionResult_Offline_Not_Allowed: return @"OFFLINE NOT ALLOWED";
        case ECLTransactionResult_ReenterPin: return @"REENTER PIN";
        case ECLTransactionResult_DeclinedContactSupportCenter: return @"DECLINED - CALL AUTH CENTER";
        case ECLTransactionResult_DeclinedByCard: return @"DECLINED BY CARD";
        case ECLTransactionResult_EMVPostAuthError: return @"EMV POST AUTH ERROR";
        case ECLTransactionResult_DeclinedDueToCommunicationError: return @"DECLINED DUE TO COMM ERROR";
        case ECLTransactionResult_AvsMismatch: return @"AVS MISMATCH";
    }
}

- (NSString *)receiptShouldProvideLocalizedText:(id<ECLReceiptProtocol>)receipt forCardScheme:(ECLCardTenderScheme)cardScheme {
    switch (cardScheme) {
            case ECLCardTenderScheme_Unknown: return @"Unknown";
            case ECLCardTenderScheme_Visa: return @"Visa";
            case ECLCardTenderScheme_MasterCard: return @"MasterCard";
            case ECLCardTenderScheme_Maestro: return @"Maestro";
            case ECLCardTenderScheme_Amex: return @"Amex";
            case ECLCardTenderScheme_JCB: return @"JCB";
            case ECLCardTenderScheme_Diners: return @"Diners";
            case ECLCardTenderScheme_Discover: return @"Discover";
            case ECLCardTenderScheme_CarteBleue: return @"CarteBleue";
            case ECLCardTenderScheme_CarteBlanc: return @"CarteBlanc";
            case ECLCardTenderScheme_Voyager: return @"Voyager";
            case ECLCardTenderScheme_WEX: return @"WEX";
            case ECLCardTenderScheme_ChinaUnionPay: return @"ChinaUnionPay";
            case ECLCardTenderScheme_Style: return @"Style";
            case ECLCardTenderScheme_Laser: return @"Laser";
            case ECLCardTenderScheme_PayPal: return @"PayPal";
            case ECLCardTenderScheme_RPS: return @"RPS";
            case ECLCardTenderScheme_TorontoParkingAuthority: return @"TorontoParkingAuthority";
            case ECLCardTenderScheme_CityOfOttowa: return @"CityOfOttowa";
            case ECLCardTenderScheme_DK12: return @"DK12";
            case ECLCardTenderScheme_GiftCard: return @"GiftCard";
            case ECLCardTenderScheme_MBNA: return @"MBNA";
    }
}

- (NSString *)receiptShouldProvideLocalizedText:(id<ECLReceiptProtocol>)receipt forCardEntryType:(ECLCardEntryType)cardEntryType {
    switch (cardEntryType) {
        case ECLCardEntryType_Token: return @"Token";
        case ECLCardEntryType_EmvContact: return @"Chip";
        case ECLCardEntryType_ManuallyEntered: return @"Manual Entry";
        case ECLCardEntryType_MagneticStripeContactless: return @"Contactless";
        case ECLCardEntryType_MagneticStripeSwipe: return @"Swipe";
        case ECLCardEntryType_None: return @"None";
    }
}

- (NSString *)receiptShouldProvideLocalizedText:(id<ECLReceiptProtocol>)receipt forCardholderVerificationMethodResult:(ECLCardholderVerificationMethod)cardholderVerificationMethodResult {
    switch (cardholderVerificationMethodResult) {
        case ECLCardholderVerificationMethod_Failed: return @"Verification Failed";
        case ECLCardholderVerificationMethod_No_CVM_Required: return @"No CVM Required";
        case ECLCardholderVerificationMethod_Pin: return @"Pin Verified";
        case ECLCardholderVerificationMethod_Signature: return @"Signature Verified";
        case ECLCardholderVerificationMethod_Pin_And_Signature: return @"Pin And Signature Verified";
        case ECLCardholderVerificationMethod_Unknown: return @"Unknown";
    }
}

- (NSString *)receiptShouldProvideLocalizedMoneyText:(id<ECLReceiptProtocol>)receipt amount:(ECLMoney *)amount {
    return [ECLMoneyUtil stringFromMoney:amount withSymbol:NO withSeparators:NO];
}

- (NSString *)receiptShouldProvideLocalizedPercentageText:(id<ECLReceiptProtocol>)receipt for:(NSNumber *)percentage {
    // should check locale
    return [NSString stringWithFormat:@"%d%%", (int)[percentage integerValue]];
}

- (void)askForEmailAddress:(ECLTransactionSearchResult *)result {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample" message:@"Enter email address to send receipt" delegate:self cancelButtonTitle:@"Send" otherButtonTitles:nil];
    alert.tag = ALERT_TAG_HISTORICAL_RECEIPT_EMAIL;
    _theResult = result;
    self.receipt = [self.receiptProcessor createReceiptForHistoricalTransaction:self.theResult];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)askForPrinter:(ECLTransactionSearchResult *)result {
    _theResult = result;
    self.receipt = [self.receiptProcessor createReceiptForHistoricalTransaction:self.theResult];
    [self choosePrinterAlertBox];
}
@end
