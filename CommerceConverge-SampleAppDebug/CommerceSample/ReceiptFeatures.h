//
//  MainViewController+Receipts.h
//  Commerce Sample
//
//  Created by Bryan, Edward P on 11/10/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

@class MainViewController;
#import "FlavorIncludes.h"

@interface ReceiptFeatures : NSObject<ECLReceiptProcessingDelegate,ECLDevicesSearchingDelegate>
@property ECLTransactionSearchResult *theResult;
@property id<ECLReceiptProcessorProtocol> receiptProcessor;
@property id<ECLReceiptProtocol> receipt;
@property MainViewController *mainViewController;

- (id)init:(MainViewController *)mainViewController;
- (void)sendEmailReceipt;
- (void)sendSMSReceipt;
- (void)printReceipt;
- (void)choosePrinterAlertBox;
- (void)askForEmailAddress:(ECLTransactionSearchResult *)result;
- (void)askForPrinter:(ECLTransactionSearchResult *)result;
@end
