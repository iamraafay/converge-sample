//
//  TransactionDetailViewController.m
//  Commerce Sample
//
//  Created by Rapoport, Julia on 10/28/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "MainViewController.h"
#import "HistorianViewController.h"
#import "FlavorIncludes.h"
#import "ReceiptFeatures.h"
@interface TransactionDetailViewController () <ECLTransactionSearchDelegate>
@property id<ECLHistorianProtocol> historian;
@property id<ECLTransactionSearchCriteriaProtocol> searchCriteriaProtocol;
@property ECLTransactionSearchResult *result;
@end

@implementation TransactionDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _historian = [_account historian];
    
    id<ECLTransactionSearchCriteriaProtocol> searchCriteria = [_historian transactionSearchCriteria];
    [searchCriteria setTransactionIdentifier:[_transaction identifier] dateTime:[_transaction utcDateTime]];
    
    [_historian search:searchCriteria delegate:self];
}

-(void) setLabel:(UILabel *)label
{
    [label setTextColor:[UIColor blackColor]];
    [label setHidden:NO];
}

- (IBAction)printButtonClicked:(id)sender {
    [_receiptFeatures askForPrinter:_result];
}

-(NSString *)isRefundable:(BOOL)refundable
{
    if (refundable) {
        return @"Yes";
    } else {
        return @"No";
    }
}

- (NSString *)tenderTypeToString:(ECLTenderType) tenderType cardType:(ECLCardType)cardType {
    switch (tenderType) {
        case ECLTenderType_Unknown:
            return @"Unknown";
        case ECLTenderType_Card:
        {
            if (cardType == ECLCardType_Credit) {
                return @"Credit";
            }
            else if (cardType == ECLCardType_Debit) {
                return @"Debit";
            }
            return @"Unknown Card Type";
        }
        case ECLTenderType_Cash:
            return @"Cash";
    }
}

- (NSString *)transactionTypeToString:(ECLTransactionType) transactionType {
    switch (transactionType) {
        case ECLTransactionType_LinkedRefund:
            return @"Linked Refund";
        case ECLTransactionType_PreAuth:
            return @"PreAuth";
        case ECLTransactionType_PreAuthComplete:
            return @"PreAuth Complete";
        case ECLTransactionType_PreAuthDelete:
            return @"PreAuth Delete";
        case ECLTransactionType_Sale:
            return @"Sale";
        case ECLTransactionType_ForcedSale:
            return @"Forced Sale";
        case ECLTransactionType_StandaloneRefund:
            return @"Standalone Refund";
        case ECLTransactionType_Void:
            return @"Void";
        case ECLTransactionType_Unknown:
            return @"Unknown";
    }
}

- (NSString *)transactionResultToString:(ECLTransactionResult) transactionResult {
    switch(transactionResult) {
        case ECLTransactionResult_Unknown: return @"Unknown";
        case ECLTransactionResult_Approved: return @"Approved";
        case ECLTransactionResult_PartiallyApproved: return @"PartiallyApproved";
        case ECLTransactionResult_SwipedSuccessfully: return @"SwipedSuccessfully";
        case ECLTransactionResult_SecurityCodeFailure: return @"SecurityCodeFailure";
        case ECLTransactionResult_Declined: return @"Declined";
        case ECLTransactionResult_VoiceReferral: return @"VoiceReferral";
        case ECLTransactionResult_Rejected: return @"Rejected";
        case ECLTransactionResult_TemporarilyUnavailable: return @"TemporarilyUnavailable";
        case ECLTransactionResult_ExpiredCard: return @"ExpiredCard";
        case ECLTransactionResult_PreValidCard: return @"PreValidCard";
        case ECLTransactionResult_FailedLuhnCheck: return @"FailedLuhnCheck";
        case ECLTransactionResult_IssueNumberMissing: return @"IssueNumberMissing";
        case ECLTransactionResult_IssueNumberInvalid: return @"IssueNumberInvalid";
        case ECLTransactionResult_UnknownAcquirer: return @"UnknownAcquirer";
        case ECLTransactionResult_AcquirerDisabled: return @"AcquirerDisabled";
        case ECLTransactionResult_UnknownMerchant: return @"UnknownMerchant";
        case ECLTransactionResult_UnknownTerminal: return @"UnknownTerminal";
        case ECLTransactionResult_MerchantDisabled: return @"MerchantDisabled";
        case ECLTransactionResult_CardBlacklisted: return @"CardBlacklisted";
        case ECLTransactionResult_CardBlocked: return @"CardBlocked";
        case ECLTransactionResult_CardUsageExceededLimits: return @"CardUsageExceededLimits";
        case ECLTransactionResult_CardSchemeUnknown: return @"CardSchemeUnknown";
        case ECLTransactionResult_AmountMissing: return @"AmountMissing";
        case ECLTransactionResult_AmountError: return @"AmountError";
        case ECLTransactionResult_AmountTooSmall: return @"AmountTooSmall";
        case ECLTransactionResult_AmountTooLarge: return @"AmountTooLarge";
        case ECLTransactionResult_CurrencyCodeMissing: return @"CurrencyCodeMissing";
        case ECLTransactionResult_UnknownCurrencyCode: return @"UnknownCurrencyCode";
        case ECLTransactionResult_UnsupportedCurrencyCode: return @"UnsupportedCurrencyCode";
        case ECLTransactionResult_ApplTypeError: return @"ApplTypeError";
        case ECLTransactionResult_SystemError: return @"SystemError";
        case ECLTransactionResult_IncorrectPin: return @"IncorrectPin";
        case ECLTransactionResult_InvalidCard: return @"InvalidCard";
        case ECLTransactionResult_InvalidCAVV: return @"InvalidCAVV";
        case ECLTransactionResult_InvalidRoutingNumber: return @"InvalidRoutingNumber";
        case ECLTransactionResult_InvalidServiceEntitlementNumber: return @"InvalidServiceEntitlementNumber";
        case ECLTransactionResult_MICR_ReadError: return @"MICR_ReadError";
        case ECLTransactionResult_OpenBatchTooOld: return @"OpenBatchTooOld";
        case ECLTransactionResult_SequenceError: return @"SequenceError";
        case ECLTransactionResult_ExceededNumberOfChecks: return @"ExceededNumberOfChecks";
        case ECLTransactionResult_MaximumAmountLoadedOnCard: return @"MaximumAmountLoadedOnCard";
        case ECLTransactionResult_CardNotReloadable: return @"CardNotReloadable";
        case ECLTransactionResult_TransactionNotAllowed: return @"TransactionNotAllowed";
        case ECLTransactionResult_InvalidTransactionType: return @"InvalidTransactionType";
        case ECLTransactionResult_CardAlreadyActive: return @"CardAlreadyActive";
        case ECLTransactionResult_CardNotActive: return @"CardNotActive";
        case ECLTransactionResult_DuplicateTransaction: return @"DuplicateTransaction";
        case ECLTransactionResult_InvalidBatchID: return @"InvalidBatchID";
        case ECLTransactionResult_InvalidTender: return @"InvalidTender";
        case ECLTransactionResult_InvalidData: return @"InvalidData";
        case ECLTransactionResult_DuplicateCheckNumber: return @"DuplicateCheckNumber";
        case ECLTransactionResult_MaximumVolumeReached: return @"MaximumVolumeReached";
        case ECLTransactionResult_InvalidService: return @"InvalidService";
        case ECLTransactionResult_IssuerNeedsToBeContacted: return @"IssuerNeedsToBeContacted";
        case ECLTransactionResult_EngineersTest: return @"EngineersTest";
        case ECLTransactionResult_Offline_Not_Allowed: return @"Offline_Not_Allowed";
        case ECLTransactionResult_ReenterPin: return @"ReenterPin";
        case ECLTransactionResult_DeclinedContactSupportCenter: return @"DeclinedContactSupportCenter";
        case ECLTransactionResult_DeclinedByCard: return @"DeclinedByCard";
        case ECLTransactionResult_DeclinedDueToCommunicationError: return @"DeclinedDueToCommunicationError";
        case ECLTransactionResult_EMVPostAuthError: return @"EMVPostAuthError";
        case ECLTransactionResult_AvsMismatch: return @"AvsMismatch";
    }
    
}
- (NSString *)cardTypeToString:(ECLCardType) cardType {
    switch (cardType) {
        case ECLCardType_Credit:
            return @"Credit";
        case ECLCardType_Debit:
            return @"Debit";
        case ECLCardType_None:
            return @"None";
    }
}

-(void)transactionToDisplay:(ECLTransactionSearchResult *) transaction{
    [self setTransaction:transaction];
}

-(void)accountFromPastView:(id<ECLAccountProtocol>)account
{
    [self setAccount:account];
}

- (void)transactionSearchDidSucceed:(id<ECLTransactionSearchCriteriaProtocol>)criteria results:(ECLTransactionSearchResults *)results
{
    _result = [results objectAtIndexedSubscript:0];
    [_idLabel setText:[_result identifier]];
    [self setLabel:_idLabel];
    [_typeLabel setText:[self transactionTypeToString:[_result type]]];
    [self setLabel:_typeLabel];
    [_tenderLabel setText:[self tenderTypeToString:[_result tenderType] cardType:[_result cardType]]];
    [self setLabel:_tenderLabel];
    [_amountLabel setText:[ECLMoneyUtil stringFromMoney:_result.amount withSymbol:YES withSeparators:NO]];
    [self setLabel:_amountLabel];
    [_tipLabel setText:[ECLMoneyUtil stringFromMoney:_result.gratuity withSymbol:YES withSeparators:NO]];
    [self setLabel:_tipLabel];
    [_taxLabel setText:[ECLMoneyUtil stringFromMoney:_result.salesTax withSymbol:YES withSeparators:NO]];
    [self setLabel:_taxLabel];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:[_result utcDateTime]];
    [_dateLabel setText:formattedDateString];
    [self setLabel:_dateLabel];
    [_resultLabel setText:[self transactionResultToString:[_result result]]];
    [self setLabel:_resultLabel];
    [_authCodeLabel setText:[_result authCode]];
    [self setLabel:_authCodeLabel];
    [_cardNumberLabel setText:[_result maskedCardNumber]];
    [self setLabel:_cardNumberLabel];
    [_cardTypeLabel setText:[self cardTypeToString:[_result cardType]]];
    [self setLabel:_cardTypeLabel];
    [_refundableLabel setText:[self isRefundable:[_result refundable]]];
    [self setLabel:_refundableLabel];
        
    if ([_result refundable])
    {
        _refundButton.hidden = NO;
    } else {
        _refundButton.hidden = YES;
    }
    if ([_result voidable])
    {
        _voidButton.hidden = NO;
    } else {
        _voidButton.hidden = YES;
    }
    if (_result.type == ECLTransactionType_PreAuth)
    {
        _completePreAuthButton.hidden = NO;
        _cancelPreAuthButton.hidden = NO;
    } else {
        _completePreAuthButton.hidden = YES;
        _cancelPreAuthButton.hidden = YES;
    }

}

- (void)transactionSearchDidFail:(id<ECLTransactionSearchCriteriaProtocol>)criteria error:(NSError *)error
{

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender == _refundButton) {
        _transactionTypeToPerform = ECLTransactionType_LinkedRefund;
    } else if (sender == _voidButton) {
        _transactionTypeToPerform = ECLTransactionType_Void;
    } else if (sender == _completePreAuthButton) {
        _transactionTypeToPerform = ECLTransactionType_PreAuthComplete;
    } else if (sender == _cancelPreAuthButton) {
        _transactionTypeToPerform = ECLTransactionType_PreAuthDelete;
    }
}

- (IBAction)emailButtonClicked:(id)sender {
    [_receiptFeatures askForEmailAddress:_result];
}
@end
