//
//  RetrieveCardDataViewController.m
//  CommerceSample
//
//  Created by Phan, Trac B on 4/27/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RetrieveCardDataViewController.h"
#import "Flavor.h"
#import "ServerNames.h"
#import <CommerceDataTypes/ECLConnectionConfiguration.h>
#import <CommerceDataTypes/ECLConnectionMethod.h>


@interface RetrieveCardDataViewController ()

@property id<ECLAccountDelegate> delegate;

@end

@implementation RetrieveCardDataViewController

- (void) passMainViewController: (MainViewController *) controller{
    _mainViewController = controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)continueButtonClicked:(id)sender {
    id <ECLCardReaderProtocol> cardReader = _mainViewController.cardReader;
    if (cardReader != nil) {
        [_mainViewController addStatusString:[NSString stringWithFormat:@"Retrieving Card Data...\n"]];
        dispatch_async(dispatch_get_main_queue(), ^() {
            ECLCardEntryType cardEntryTypes = ECLCardEntryType_None;
            if (_magstripeSwitch.on) {
                cardEntryTypes |= ECLCardEntryType_MagneticStripeSwipe;
            }
            if (_contactlessSwitch.on) {
                cardEntryTypes |= ECLCardEntryType_MagneticStripeContactless;
            }
            if (_manualKeySwitch.on) {
                cardEntryTypes |= ECLCardEntryType_ManuallyEntered;
            }
            if (_emvSwitch.on) {
                cardEntryTypes |= ECLCardEntryType_EmvContact;
            }
            [cardReader retrieveCardData:self usingCardEntries:cardEntryTypes];
        });

    } else {
        [_mainViewController addStatusString:@"No card reader connected.\n"];
    }
}

- (void)cardReaderRetrieveCardData:(id<ECLCardReaderProtocol>)cardReader providedMagStripeCardData:(ECLMagStripeCardData *)data {
    //[cardReader removeConnectionDelegate:self];
    
    _mainViewController.prevMagStripeCardData = data;
    [_mainViewController addStatusString:@"Retrieve Card Data:\n"];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"%@\n",[ECLDebugDescriptions descriptionOfCardEntryType:[data source]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Track 1 data: %@\n",[self formatString:[data encryptedTrack1Data]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Track 2 data: %@\n",[self formatString:[data encryptedTrack2Data]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Combine track data: %@\n",[self formatString:[data encryptedCombineTrackData]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Masked PAN: %@\n",[self formatString:[data maskedPan]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Cardholder First name : %@\n",[self formatString:[data firstName]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Cardholder Last name : %@\n",[self formatString:[data lastName]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Service Code : %@\n",[self formatString:[data serviceCode]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Expiration Date : %@\n",[self formatString:[data expirationDateYYMM]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Encryption Format : %@\n",[ECLDebugDescriptions descriptionOfCardEncryptionFormat:[data formatCode]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"KSN : %@\n",[self formatString:[data ksn]]]];
    
    NSString * tdf = [ECLDebugDescriptions descriptionOfTrackDataFormat: [data trackDataFormat]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Track Data Format : %@\n",[self formatString:tdf]]];
}

- (NSString *)formatString:(NSString *)text {
    if (text.length > 0) {
        return text;
    } else {
        return @"<NOT SET>";
    }
}

- (void)cardReaderRetrieveCardData:(id<ECLCardReaderProtocol>)cardReader providedEmvData:(ECLEmvCardData *)data{
    [_mainViewController addStatusString:@"Retrieve Card Data: providedEmvData\n"];
}

- (void)cardReaderRetrieveCardData:(id<ECLCardReaderProtocol>)cardReader error:(NSError *)error{
    //[cardReader removeConnectionDelegate:self];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Retrieve Card Data failed: %@\n",[error debugDescription]]];
}
- (void)cardReaderRetrieveCardData:(id<ECLCardReaderProtocol>)cardReader progress:(ECLTransactionProgress)progress{
    [_mainViewController addStatusString:[NSString stringWithFormat:@"%@\n",[ECLDebugDescriptions descriptionOfTransactionProgress:progress]]];
}

@end
