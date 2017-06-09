//
//  SignatureViewController.m
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/6/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "SignatureViewController.h"
#import "MainViewController.h"

@interface SignatureViewController ()

@end

@implementation SignatureViewController
@synthesize tender;
@synthesize transaction;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _signHereLabel.text = @"Sign Here";
    _signHereLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_signatureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *) signatureData{
    UIImage *signatureImage = [_signatureView renderTrimmedImage];
    return signatureImage;
}

- (IBAction)clearButtonTapped:(id)sender{
    [_signatureView clear];
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if (sender == _cancelButton) {
         _sign = nil;
     } else {
         _sign = [_signatureView renderTrimmedImage];
     }
 }
@end
