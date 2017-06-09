//
//  MainViewController+Specifics.m
//  Commerce Sample
//
//  Created by Bryan, Edward P on 10/9/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "Flavor.h"
#import "ConvergeAccountDelegate.h"
#import "ReceiptFeatures.h"
#import "MainViewController.h"

@interface Flavor() {
    ConvergeAccountDelegate *virtualMerchantAccountDelegate;
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

- (id<ECLAccountDelegate>)createAccountDelegate {
    if (virtualMerchantAccountDelegate == nil) {
        virtualMerchantAccountDelegate = [[ConvergeAccountDelegate alloc] init:_mainViewController];
    }
    return virtualMerchantAccountDelegate;
}

- (void)addButtons:(NSInteger)verticalButtonPosition {
    [_mainViewController addButton:_mainViewController.receiptFeatures selector:@selector(printReceipt) withTitle:@"Print Receipt" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
    [_mainViewController addButton:_mainViewController.receiptFeatures selector:@selector(sendEmailReceipt) withTitle:@"Send Email Receipt" atVerticalPosition:verticalButtonPosition];
    verticalButtonPosition += 20;
}

- (NSMutableArray*) createSettingsView:(CGFloat)width {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    labelVerticalPosition = 0;
    textfieldVerticalPosition = 5;
    [views addObject:[self addLabel:@"Merchant ID" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"User ID" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Pin" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Vendor ID" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Vendor App Name" startPoint:CGPointMake(10, labelVerticalPosition)]];
    [views addObject:[self addLabel:@"Vendor App Version" startPoint:CGPointMake(10, labelVerticalPosition)]];
    
    NSUInteger textFieldWidth = width - 186;
    [views addObject:[self addTextfield:@"merchantID" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    [views addObject:[self addTextfield:@"userID" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    [views addObject:[self addTextfield:@"pin" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    [views addObject:[self addTextfield:@"vendorID" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    [views addObject:[self addTextfield:@"vendorAppName" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    [views addObject:[self addTextfield:@"vendorAppVersion" startPoint:CGPointMake(176, textfieldVerticalPosition) width:textFieldWidth]];
    
    return views;
}

- (UILabel*) addLabel:(NSString*) title startPoint:(CGPoint)point {
    UILabel *label = [[UILabel alloc] init];
    [label setText:title];
    [label setTextColor:[UIColor blackColor]];
    label.frame = CGRectMake(point.x, point.y, 175, 40);
    labelVerticalPosition += 40;
    return label;
}

- (UITextField*)addTextfield:(NSString *)text startPoint:(CGPoint)point width:(NSUInteger)width {
    UITextField *textField = [[UITextField alloc] init];
    [textField setRestorationIdentifier:text];
    [textField setText:[virtualMerchantAccountDelegate userDefault:text]];
    [textField setTextColor:[UIColor blackColor]];
    [textField setTintColor:[UIColor blueColor]];
    textField.frame = CGRectMake(point.x, point.y, width, 30);
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    textfieldVerticalPosition +=40;
    return textField;
}

- (void) setUserDefault: (NSString *)key withValue:(NSString *)value{
    [[virtualMerchantAccountDelegate userDefaults] setString:value forKey:key updateExisting:YES];
}

- (NSString *)serverType {
    return [virtualMerchantAccountDelegate.userDefaults getStringForKey:@"serverType"];
}

- (void)setServerType:(NSString *)server {
    [virtualMerchantAccountDelegate.userDefaults setString:server forKey:@"serverType" updateExisting:YES];
}

@end
