//
//  MainViewController+Specifics.m
//  Commerce Sample
//
//  Created by Bryan, Edward P on 10/9/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "Flavor.h"
#import "CreditCallAccountDelegate.h"
#import <Commerce-CreditCall/ECLCreditCallAccountProtocol.h>
#import "ReceiptFeatures.h"
#import "MainViewController.h"

@interface Flavor()<ECLCreditCallRetrieveTerminalIDsDelegate, ECLCreditCallRetrieveTransactionKeyDelegate> {
    CreditCallAccountDelegate *creditCallAccountDelegate;
    int labelVerticalPosition;
    int textfieldVerticalPosition;
}
@end

@implementation Flavor

- (id)init:(MainViewController *)mainViewController {
    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
    }
    return self;
}

- (void)account:(id<ECLCreditCallAccountProtocol>)account didReceiveTerminalIds:(NSArray *)terminalIds {
    [_mainViewController addStatusString:@"Terminal IDs received:\n"];
    ECCSensitiveData *data;
    for (data in terminalIds) {
        [_mainViewController addStatusString:[NSString stringWithFormat:@"    %@\n", [data string]]];
    }
}

- (void)account:(id<ECLCreditCallAccountProtocol>)account didReceiveTerminalIdsError:(NSError *)error {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Failed to get terminal ids: %@\n", [error debugDescription]]];
}

- (void)account:(id<ECLCreditCallAccountProtocol>)account didReceiveTransactionKey:(ECCSensitiveData *)transactionKey forTerminalID:(ECCSensitiveData *)terminalId {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Transaction key received: %@\n", [transactionKey string]]];
}

- (void)account:(id<ECLCreditCallAccountProtocol>)account didReceiveTransactionKeyError:(NSError *)error forTerminalID:(ECCSensitiveData *)terminalId {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Failed to get transaction key: %@\n", [error debugDescription]]];
}

- (id<ECLAccountDelegate>)createAccountDelegate {
    if (creditCallAccountDelegate == nil) {
        creditCallAccountDelegate = [[CreditCallAccountDelegate alloc] init:_mainViewController];
        
        //ECCSensitiveData *terminalID = [[creditCallAccountDelegate userDefaults] getSensitiveDataForKey:@"terminalID"];
        //if (terminalID == nil) {
            
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [[creditCallAccountDelegate userDefaults] setString:[creditCallAccountDelegate getPassword] forKey:@"webMisPassword" updateExisting:YES];
            [[creditCallAccountDelegate userDefaults] setString:[creditCallAccountDelegate getUsername] forKey:@"webMisUser" updateExisting:YES];
            [[creditCallAccountDelegate userDefaults] setString:[creditCallAccountDelegate getTerminalID] forKey:@"terminalID" updateExisting:YES];
            [[creditCallAccountDelegate userDefaults] setString:[creditCallAccountDelegate getTransactionKey] forKey:@"transactionKey" updateExisting:YES];
            [[creditCallAccountDelegate userDefaults] setString:[creditCallAccountDelegate getApplicationId]
                forKey:@"applicationID" updateExisting:YES];
            [[creditCallAccountDelegate userDefaults] setString:[ECLDebugDescriptions descriptionOfServerTypes:ECLServerType_Demo] forKey:@"serverType" updateExisting:YES];
            
            /*
            [defaults setObject:[creditCallAccountDelegate getPassword] forKey:@"webMisPassword"];
            [defaults setObject:[creditCallAccountDelegate getUsername] forKey:@"webMisUser"];
            [defaults setObject:[creditCallAccountDelegate getTerminalID] forKey:@"terminalID"];
            [defaults setObject:[creditCallAccountDelegate getTransactionKey] forKey:@"transactionKey"];
            [defaults setObject:[creditCallAccountDelegate applicationId:[_mainViewController account]] forKey:@"applicationID"];
            [defaults setObject:[ECLDebugDescriptions descriptionOfServerTypes:ECLServerType_Demo] forKey:@"serverType"];
            
            [creditCallAccountDelegate setUserDefaults:defaults];*/
        //}
    }
    return creditCallAccountDelegate;
}

- (void)addButtons:(NSInteger)verticalButtonPosition {
    verticalButtonPosition += [_mainViewController addButton:self selector:@selector(getTerminalIDs) withTitle:@"Get Terminal IDs" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += [_mainViewController addButton:self selector:@selector(getTransactionKey) withTitle:@"Get Transaction Key" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += [_mainViewController addButton:_mainViewController.receiptFeatures selector:@selector(sendEmailReceipt) withTitle:@"Send Email Receipt" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += [_mainViewController addButton:_mainViewController.receiptFeatures selector:@selector(sendSMSReceipt) withTitle:@"Send SMS Receipt" atVerticalPosition:verticalButtonPosition];
}


- (IBAction)getTerminalIDs {
    _mainViewController.statusLabel.text = @"getting terminal ids\n";
    id<ECLCreditCallAccountProtocol> ccAccount = (id<ECLCreditCallAccountProtocol>)_mainViewController.account;
    [ccAccount retrieveTerminalIDs:self];
}

- (IBAction)getTransactionKey {
    _mainViewController.statusLabel.text = @"getting transaction key\n";
    id<ECLCreditCallAccountProtocol> ccAccount = (id<ECLCreditCallAccountProtocol>)_mainViewController.account;
    [ccAccount retrieveTransactionKey:self forTerminalID:[creditCallAccountDelegate terminalId:_mainViewController.account]];
}

- (NSMutableArray*) createSettingsView:(CGFloat)width {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    labelVerticalPosition = 0;
    textfieldVerticalPosition = 5;
    [views addObject:[self addLabel:@"Terminal ID" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Transaction Key" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Webmis Email" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Webmis Password" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Application ID" startPoint:CGPointMake(10, labelVerticalPosition)]];

    
    [views addObject:[self addTextfield:@"terminalID" startPoint:CGPointMake(140, textfieldVerticalPosition)]];
    [views addObject:[self addTextfield:@"transactionKey" startPoint:CGPointMake(140, textfieldVerticalPosition)]];
    [views addObject:[self addTextfield:@"webMisUser" startPoint:CGPointMake(140, textfieldVerticalPosition)]];
    [views addObject:[self addTextfield:@"webMisPassword" startPoint:CGPointMake(140, textfieldVerticalPosition)]];
    [views addObject:[self addTextfield:@"applicationID" startPoint:CGPointMake(140, textfieldVerticalPosition)]];

    return views;
}


- (UILabel*) addLabel:(NSString*) title startPoint:(CGPoint) point{
    UILabel *label = [[UILabel alloc] init];
    [label setText:title];
    [label setTextColor:[UIColor blackColor]];
    label.frame = CGRectMake(point.x, point.y, 125, 40);
    labelVerticalPosition += 40;
    return label;
}

- (UITextField*)addTextfield:(NSString *)text startPoint:(CGPoint) point{
    UITextField *textField = [[UITextField alloc] init];
    [textField setRestorationIdentifier:text];
    [textField setText:[creditCallAccountDelegate userDefault:text]];
    [textField setTextColor:[UIColor blackColor]];
    [textField setTintColor:[UIColor blueColor]];
    textField.frame = CGRectMake(point.x, point.y, 175, 30);
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfieldVerticalPosition +=40;
    return textField;
}

- (void) setUserDefault: (NSString *)key withValue:(NSString *)value{
    [[creditCallAccountDelegate userDefaults] setString:value forKey:key updateExisting:YES];
    //[[creditCallAccountDelegate userDefaults] synchronize];
}


- (NSString *)serverType {
    return [[creditCallAccountDelegate userDefaults] getStringForKey:@"serverType"];
}

- (void)setServerType:(NSString *)server {
    [[creditCallAccountDelegate userDefaults] setString:server forKey:@"serverType" updateExisting:YES];
}

@end
