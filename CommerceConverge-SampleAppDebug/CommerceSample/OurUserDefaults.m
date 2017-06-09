// OurUserDefaults 

#import "OurUserDefaults.h"
#import <Commerce-Converge/ECLDebugDescriptions.h>

@interface OurUserDefaults ()

- (void) loadDefaults;
- (void) saveDefaults;

@end


static NSString *const KEY_CONNECTION_METHOD = @"ECL_Reader_ConnectionMethod";
static NSString *const KEY_IP = @"ECL_Reader_IP";
static NSString *const KEY_PORT = @"ECL_Reader_Port";
static NSString *const KEY_IP_SECURED = @"ECL_Reader_IP_Secured";

NSString *const DEF_IP = @"192.168.1.115";
NSString *const DEF_PORT = @"12000";
Boolean DEF_IP_SECURED = FALSE;


@implementation OurUserDefaults


// Place this in the .m file, inside the @implementation block
// A method to convert an enum to string
+(NSString*) eclEncryptionSchemeTypeEnumToString:(ECLEncryptionScheme)enumVal
{
    NSArray * encryptionSchemeTypeArray = [[NSArray alloc] initWithObjects:ECLEncryptionSchemeTypeArray];
    return [encryptionSchemeTypeArray objectAtIndex:enumVal];
}

// A method to retrieve the int value from the NSArray of NSStrings
+(ECLEncryptionScheme) eclEncryptionSchemeTypeStringToEnum:(NSString*)strVal
{
    NSArray *encryptionSchemeTypeArray = [[NSArray alloc] initWithObjects:ECLEncryptionSchemeTypeArray];
    NSUInteger n = [encryptionSchemeTypeArray indexOfObject:strVal];
    if(n < 1) n = ECLEncryptionScheme_NONE;
    return (ECLEncryptionScheme) n;
}


- (BOOL) isValidPort:(NSString *) portStr
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:portStr];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    return valid;
}

- (void)loadDefaults
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    [defaults synchronize];

	NSString *ip = [defaults stringForKey:KEY_IP];
	if (nil == ip)
	{
		ip = DEF_IP;
		[defaults setValue:ip forKey:KEY_IP]; 
	}
	_ReaderIP = ip;

	NSString *portStr = [defaults stringForKey:KEY_PORT];
	if ((nil == portStr)
        || (![self isValidPort:portStr]))
	{
		portStr = DEF_PORT;
		[defaults setValue:portStr forKey:KEY_PORT];
	}
    _ReaderPort = [NSNumber numberWithInt:[portStr intValue]];

	NSString *connMethStr = [defaults stringForKey:KEY_CONNECTION_METHOD];
	if (nil == connMethStr)
	{
        connMethStr = [self stringFromConnectionMethod:ECLConnectionMethod_Audio];
		[defaults setValue:connMethStr forKey:KEY_CONNECTION_METHOD];
	}
	_ReaderConnectionMethod = [self connectionMethodFromString:connMethStr];
    
    NSString *ipEncryptionSchemeValue = [defaults stringForKey:KEY_IP_SECURED];
    if (ipEncryptionSchemeValue == nil) {
        ipEncryptionSchemeValue = @"ECLEncryptionScheme_NONE";
        [defaults setValue:ipEncryptionSchemeValue forKey:KEY_IP_SECURED];
    }
    _ReaderIPEncryptionScheme = [OurUserDefaults eclEncryptionSchemeTypeStringToEnum:ipEncryptionSchemeValue];
}

- (id) init
{
    self = [super init];
    if  (self)
    {
        [self loadDefaults];
    }
    return self;
}

- (ECLConnectionMethod) connectionMethodFromString:(NSString *) name
{
    NSString * temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Internet];
    if ([temp isEqualToString:name])
        return ECLConnectionMethod_Internet;

    temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Audio];
    if ([temp isEqualToString:name])
        return ECLConnectionMethod_Audio;

    temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_USB];
    if ([temp isEqualToString:name])
        return ECLConnectionMethod_USB;

    temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Bluetooth];
    if ([temp isEqualToString:name])
        return ECLConnectionMethod_Bluetooth;

    temp = [ECLDebugDescriptions descriptionOfConnectionMethod:ECLConnectionMethod_Unknown];
    if ([temp isEqualToString:name])
        return ECLConnectionMethod_Bluetooth;

    return ECLConnectionMethod_Nil;

}
- (NSString *) stringFromConnectionMethod:(ECLConnectionMethod) connMeth
{
    return [ECLDebugDescriptions descriptionOfConnectionMethod:connMeth];
}



- (void) saveDefaults
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    [defaults setValue:_ReaderIP forKey:KEY_IP];

    [defaults setValue:[_ReaderPort stringValue] forKey:KEY_PORT];
    
    NSString * ipSecured = [OurUserDefaults eclEncryptionSchemeTypeEnumToString:_ReaderIPEncryptionScheme];
    
    [defaults setValue:ipSecured forKey:KEY_IP_SECURED];

    [defaults setValue:[self stringFromConnectionMethod:_ReaderConnectionMethod] forKey:KEY_CONNECTION_METHOD];

    [defaults synchronize];
}

- (void) save
{
	[self saveDefaults];
}

@end
