//
//  TransactionViewController.m
//  CommerceSample
//
//  Created by Bryan, Edward P on 11/30/15.
//  Copyright (c) 2015 Elavon. All rights reserved.
//

#import "TransactionViewController.h"
#import <CommerceDataTypes/CommerceDataTypes.h>

@interface TransactionViewController ()

@end

@implementation TransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add a gesture recognizer so when they tap outside keyboard it goes away
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    _transactionTypeLabel.text = _transactionString;
    _tenderTypeLabel.text = _tenderString;
    _currencyLabel.text = [ECLCurrencyCodeUtil debugDescriptionOfCurrencyCode:_currency];
    [self enableControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _noteTextField.layer.borderWidth = 1.0f;

    _noteTextField.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
    CGRect bounds = _scrollView.bounds;
    bounds.size.width -= bounds.origin.x;
    bounds.size.height -= bounds.origin.y;
    [_scrollView setContentSize:bounds.size];
    bounds = self.view.bounds;
    [_scrollView setFrame:bounds];
     */
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    // stop editing text so keyboard dimisses
    [self.view endEditing:YES];
}

- (void)enableControls {
    
    ECLCardEntryType cardEntryTypes = [_processor supportedCardEntryTypesForCardTransaction:_transactionType];
    
    // always enabled for default
    if (_tenderType == ECLTenderType_Cash) {
        _cardEntry.selectedSegmentIndex = -1;
    }
    BOOL enableToken = ((_tenderType == ECLTenderType_Card) && ((cardEntryTypes & ECLCardEntryType_Token) != 0));
    if ((enableToken == NO) && (_cardEntry.selectedSegmentIndex == 1)) {
        _cardEntry.selectedSegmentIndex = 0;
    }
    BOOL enableManual = ((_tenderType == ECLTenderType_Card) && ((cardEntryTypes & ECLCardEntryType_ManuallyEntered) != 0));
    if ((enableManual == NO) && (_cardEntry.selectedSegmentIndex == 2)) {
        _cardEntry.selectedSegmentIndex = 0;
    }
    [_cardEntry setEnabled:(_tenderType == ECLTenderType_Card) forSegmentAtIndex:0];
    [_cardEntry setEnabled:enableToken forSegmentAtIndex:1];
    [_cardEntry setEnabled:enableManual forSegmentAtIndex:2];

    _generateTokenSwitch.enabled = (_tenderType == ECLTenderType_Card) && (_transactionType == ECLTransactionType_Sale  || _transactionType == ECLTransactionType_PreAuth) && (_cardEntry.selectedSegmentIndex != 1);
    _storeTokenSwitch.enabled = (_tenderType == ECLTenderType_Card) && (_transactionType == ECLTransactionType_Sale  || _transactionType == ECLTransactionType_PreAuth) && (_cardEntry.selectedSegmentIndex != 1);

    _amountField.enabled = (_transactionType != ECLTransactionType_Void);
    _amountTenderedField.enabled = (_tenderType == ECLTenderType_Cash);
    _forceSwitch.enabled = (_tenderType == ECLTenderType_Card) && (_transactionType == ECLTransactionType_Sale) && (_cardEntry.selectedSegmentIndex != 1);

    BOOL saleLikeTransaction = ((_transactionType == ECLTransactionType_Sale) || (_transactionType == ECLTransactionType_PreAuth));
    _taxAmountField.enabled = saleLikeTransaction;
    _taxInclusiveSwitch.enabled = saleLikeTransaction;
    _noteTextField.editable = saleLikeTransaction || (_transactionType == ECLTransactionType_StandaloneRefund);

    // when can you use token?
    _tokenField.enabled = (_tenderType == ECLTenderType_Card) && (_cardEntry.selectedSegmentIndex == 1);
    if ((_tenderType == ECLTenderType_Card) && (_transactionType == ECLTransactionType_Sale)) {
        _tipOnCardReaderSwitch.enabled = true;
        _tipSelection1Field.enabled = true;
        _tipSelection1Type.enabled = true;
        _tipSelection2Field.enabled = true;
        _tipSelection2Type.enabled = true;
        _tipSelection3Field.enabled = true;
        _tipSelection3Type.enabled = true;
        _tipCustomAmountSwitch.enabled = true;
        _partialApprovalSwitch.enabled = true;
    }
    _avsAddress.enabled = saleLikeTransaction && (_tenderType == ECLTenderType_Card);
    _avsZip.enabled = saleLikeTransaction && (_tenderType == ECLTenderType_Card);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTaxOnTransaction:(id<ECLCurrencyTransactionProtocol>)currencyTransaction {
    if ([_taxAmountField.text length] > 0) {
        [currencyTransaction setTax:[[ECLMoney alloc] initWithMinorUnits:[_taxAmountField.text integerValue] withCurrencyCode:_currency]];
        [currencyTransaction setIsTaxInclusive:_taxInclusiveSwitch.on];
    }
}

- (id<ECLCurrencyTransactionProtocol>)createSaleTransaction:(ECLMoney *)money {
    id<ECLCurrencyTransactionProtocol> saleTransaction = [_processor createSaleTransactionWithSubtotal:money];
    [self setTaxOnTransaction:saleTransaction];
    if ([_noteTextField.text length] > 0) {
        [saleTransaction setNote:_noteTextField.text];
    }
    if (_tenderType == ECLTenderType_Card && _tipOnCardReaderSwitch.on) {
        NSMutableArray * tipQuickSelections = [[NSMutableArray alloc] init];
        int idx = 0;
        ECLGratuityQuickValue *gratuity;
        NSInteger selValue =  [_tipSelection1Field.text integerValue];
        if (selValue > 0) {
            if (_tipSelection1Type.selectedSegmentIndex == 0) {
                gratuity = [[ECLGratuityQuickValue alloc] initWithAmount:[[ECLMoney alloc] initWithMinorUnits:selValue withCurrencyCode:_currency]];
            } else {
                gratuity = [[ECLGratuityQuickValue alloc] initWithPercentage:selValue];
            }
            [tipQuickSelections insertObject:gratuity atIndex:idx++];
        }
        selValue =  [_tipSelection2Field.text integerValue];
        if (selValue > 0) {
            if (_tipSelection2Type.selectedSegmentIndex == 0) {
                gratuity = [[ECLGratuityQuickValue alloc] initWithAmount:[[ECLMoney alloc] initWithMinorUnits:selValue withCurrencyCode:_currency]];
            } else {
                gratuity = [[ECLGratuityQuickValue alloc] initWithPercentage:selValue];
            }
            [tipQuickSelections insertObject:gratuity atIndex:idx++];
        }
        selValue =  [_tipSelection3Field.text integerValue];
        if (selValue > 0) {
            if (_tipSelection3Type.selectedSegmentIndex == 0) {
                gratuity = [[ECLGratuityQuickValue alloc] initWithAmount:[[ECLMoney alloc] initWithMinorUnits:selValue withCurrencyCode:_currency]];
            } else {
                gratuity = [[ECLGratuityQuickValue alloc] initWithPercentage:selValue];
            }
            [tipQuickSelections insertObject:gratuity atIndex:idx++];
        }
        
        [saleTransaction setGratuityQuickValues:tipQuickSelections];
        
        [saleTransaction setIsGratuityRequested:YES];
        
        if (_tipCustomAmountSwitch.on) {
            [saleTransaction setIsCustomAmountEntryAllowed:YES];
        } else {
            [saleTransaction setIsCustomAmountEntryAllowed:NO];
        }
    }
    return saleTransaction;
}

- (id<ECLCurrencyTransactionProtocol>)createPreAuthTransaction:(ECLMoney *)money {
    id<ECLCurrencyTransactionProtocol> saleTransaction = [_processor createPreAuthTransactionWithSubtotal:money];
    [self setTaxOnTransaction:saleTransaction];
    if ([_noteTextField.text length] > 0) {
        [saleTransaction setNote:_noteTextField.text];
    }
    return saleTransaction;
}

- (id<ECLStandaloneRefundTransactionProtocol>)createStandaloneRefundTransaction:(ECLMoney *)money {
    id<ECLStandaloneRefundTransactionProtocol> refundTransaction = [_processor createStandaloneRefundTransactionWithTotal:money];
    if ([_noteTextField.text length] > 0) {
        [refundTransaction setNote:_noteTextField.text];
    }
    return refundTransaction;
}

- (id<ECLCardTenderProtocol>)createCardTender {
    id<ECLCardTenderProtocol> cardTender = [_processor createCardTender];
    switch (_cardEntry.selectedSegmentIndex) {
        case 0:
            // leave at default
            break;
        case 1:
            cardTender.allowedCardEntryTypes = ECLCardEntryType_Token;
            break;
        case 2:
            cardTender.allowedCardEntryTypes = ECLCardEntryType_ManuallyEntered;
            break;
    }
    if (_transactionType == ECLTransactionType_Sale || _transactionType == ECLTransactionType_PreAuth) {
        if (_generateTokenSwitch.on) {
            cardTender.generateToken = YES;
        }
        if (_storeTokenSwitch.on) {
            cardTender.addToken = YES;
        }
    }
    if (_forceSwitch.on) {
        [cardTender setRequiresVoiceApproval];
    }
    if (cardTender.allowedCardEntryTypes == ECLCardEntryType_Token) {
        cardTender.tokenizedCardNumber = _tokenField.text;
    }
    if (_partialApprovalSwitch.on) {
        [cardTender setPartialApprovalAllowed];
    }
    if ([_avsAddress.text length] > 0) {
        [cardTender setAVSField:ECLAVS_CardholderAddress withValue:_avsAddress.text];
    }
    if ([_avsZip.text length] > 0) {
        [cardTender setAVSField:ECLAVS_CardholderZip withValue:_avsZip.text];
    }
    return cardTender;
}

- (id<ECLCashTenderProtocol>)createCashTender {
    id<ECLCashTenderProtocol> cashTender = [_processor createCashTender];
    
    if ([_amountTenderedField.text length] > 0) {
        ECLMoney *amountTendered = [[ECLMoney alloc] initWithMinorUnits:[_amountTenderedField.text integerValue] withCurrencyCode:_currency];
        [cashTender setAmountTendered:amountTendered];
    }

    return cashTender;
}

- (IBAction)continueButtonClicked:(id)sender {
    switch (_tenderType) {
        case ECLTenderType_Card:
            _resultingTender = [self createCardTender];
            break;

        case ECLTenderType_Cash :
            _resultingTender = [self createCashTender];
            break;
            
        default:
            break;
    }
    ECLMoney *money = [[ECLMoney alloc] initWithMinorUnits:[_amountField.text integerValue] withCurrencyCode:_currency];
    switch (_transactionType) {
        case ECLTransactionType_Sale:
            _resultingTransaction = [self createSaleTransaction:money];
            break;
            
        case ECLTransactionType_PreAuth:
            _resultingTransaction = [self createPreAuthTransaction:money];
            break;
            
        case ECLTransactionType_StandaloneRefund:
            _resultingTransaction = [self createStandaloneRefundTransaction:money];
            break;
            
        default:
            break;
    }
}

- (IBAction)cardEntrySegmentClicked:(id)sender {
    [self enableControls];
}
@end
