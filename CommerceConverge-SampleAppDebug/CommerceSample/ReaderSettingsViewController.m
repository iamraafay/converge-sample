//
//  ReaderSettingsViewController.m
//  Commerce Sample
//
//  Created by Pete on Jul 14, 2016.
//  Copyright (c) 2016 Elavon. All rights reserved.
//


#import "ReaderSettingsViewController.h"
#import <CommerceDataTypes/ECLConnectionConfiguration.h>
#import "OurUserDefaults.h"

@interface ReaderSettingsViewController ()

/* these get poked in before viewDidLoad */

@property (weak, nonatomic) IBOutlet UISegmentedControl *connectionTypeControl;	/* SB connectionMethodControl - can't figure out how to change */
@property (weak, nonatomic) IBOutlet UITextField *ipControl;
@property (weak, nonatomic) IBOutlet UITextField *portControl;


@property	OurUserDefaults * ourUserDefaults;

- (void)loadDefaults;
- (void)saveDefaults;

@end

@implementation ReaderSettingsViewController


/* This doesn't seem to get called, but it was in AccountSettingsViewController (which I started with */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

/* Called when they click on the connection method control - remember new selection */

- (IBAction)connectionTypeChanged:(id)sender
{
	UISegmentedControl *connectionType = (UISegmentedControl*)sender;
	
	NSInteger idx = connectionType.selectedSegmentIndex;
    _defConnectionMethod = [connectionType titleForSegmentAtIndex:idx];
}

/* These next two could be removed (if I could figure how) because they don't get called if a field is changed but focus is still there */
/* when Save is clicked. */

- (IBAction)ipChanged:(id)sender 
{
	UITextField *ipCtrl = (UITextField *)sender;
	_defIP = [ipCtrl text];

}

- (IBAction)portChanged:(id)sender 
{
	UITextField *portCtrl = (UITextField *)sender;
	_defPortStr = [portCtrl text];
}
- (BOOL) isValidPort:(NSString *) portStr
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:portStr];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    return valid;
}
- (IBAction)saveClicked:(id)sender 
{
    NSString * portStr = [_portControl text];
    if (![self isValidPort:portStr])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commerce Sample - Error"
                                                    message:@"Invalid port string"
                                                    delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        _defPortStr = [_portControl text];
        _defIP = [_ipControl text];

        [self saveDefaults];

        /* Now update the reader connection confiuration singleton */
    
        ECLConnectionConfiguration *config = [ECLConnectionConfiguration sharedInstance];
    
        ECLConnectionMethod meth = _ourUserDefaults.ReaderConnectionMethod;
    
        config.connectionMethod = meth;
    
        if (ECLConnectionMethod_Internet == meth)
        {
    		NSString * ipAddress = _ourUserDefaults.ReaderIP;
			NSNumber *port = _ourUserDefaults.ReaderPort;
            ECLInetAddress * inetAddress = [[ECLInetAddress alloc] initWithHost:ipAddress port:port encryptionScheme:_ourUserDefaults.ReaderIPEncryptionScheme];
			config.inetAddress = inetAddress;
        }
    }

}

/* Convience methods to convert ECLConnectionMethod to string and back */
/* NOTE_SUPPORT:  Currently we only support internet and audio, if that changes fix it here and @NOTE_SUPPORT. */

- (ECLConnectionMethod) connectionMethodFromString:(NSString *) name
{
	NSString * temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Internet];
	if ([temp isEqualToString:name])
		return ECLConnectionMethod_Internet;

	temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Audio];
	if ([temp isEqualToString:name])
		return ECLConnectionMethod_Audio;

	return ECLConnectionMethod_Nil;

}
- (NSString *) stringFromConnectionMethod:(ECLConnectionMethod) connMeth
{
	return [ECLDebugDescriptions descriptionOfConnectionMethod:connMeth];
}

/* Load default values from standardUserDefaults */

- (void)loadDefaults
{
	_ourUserDefaults = [[OurUserDefaults alloc] init];
    
    _defIP = _ourUserDefaults.ReaderIP;

	_defPortStr = [_ourUserDefaults.ReaderPort stringValue];

    _defConnectionMethod = [self stringFromConnectionMethod:_ourUserDefaults.ReaderConnectionMethod];
}

/* Save values back into standardUserDefaults */

- (void)saveDefaults
{
    _ourUserDefaults.ReaderIP = _defIP;

    _ourUserDefaults.ReaderPort = [NSNumber numberWithInt:[_defPortStr intValue]];
    
    ECLConnectionMethod meth = [self connectionMethodFromString:_defConnectionMethod];
    
    _ourUserDefaults.ReaderConnectionMethod = meth;
    
    [_ourUserDefaults save];

}

/* NOTE_SUPPORT: Currenly we only support audio and internet.  If that changes this fix it here and @NOTE_SUPPORT */

- (void) setupConnectionMethodControl
{
    [_connectionTypeControl removeAllSegments];

    NSUInteger index = 0;

    NSString * audio = [self stringFromConnectionMethod:ECLConnectionMethod_Audio];
    [_connectionTypeControl insertSegmentWithTitle:audio atIndex:0 animated:NO];

    NSString * internet = [self stringFromConnectionMethod:ECLConnectionMethod_Internet];
    [_connectionTypeControl insertSegmentWithTitle:internet atIndex:1 animated:NO];
	
	if ([internet isEqualToString:_defConnectionMethod])
		index = 1;

    [_connectionTypeControl setSelectedSegmentIndex:index];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
	/* Load default values and put them in the UI */  

	[self loadDefaults];
	[_ipControl setText:_defIP];
    [_portControl setText:_defPortStr];
    [self setupConnectionMethodControl];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
