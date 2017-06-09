//
//  SignatureViewController.h
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/6/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureView.h"
#import "FlavorIncludes.h"

@interface SignatureViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *signHereLabel;
@property (strong, nonatomic) IBOutlet SignatureView *signatureView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UIImage *sign;
@property id<ECLTransactionProtocol> transaction;
@property id<ECLTenderProtocol> tender;

@end
