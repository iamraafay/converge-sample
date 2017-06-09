/* OurUserDefaults.h */

/* Wrap NSUserDefaults */

#import <Foundation/Foundation.h>

#import <CommerceDataTypes/ECLConnectionMethod.h>
#import <CommerceDataTypes/ECLEncryptionScheme.h>

#define ECLEncryptionSchemeTypeArray @"ECLEncryptionScheme_NONE", @"ECLEncryptionScheme_TLS_12", nil

@interface OurUserDefaults : NSObject

@property ECLConnectionMethod	ReaderConnectionMethod;
@property NSString*			ReaderIP;
@property NSNumber*			ReaderPort;
@property ECLEncryptionScheme ReaderIPEncryptionScheme;

- (id) init;
- (void) save;


// Place this in the .m file, inside the @implementation block
// A method to convert an enum to string
+(NSString*) eclEncryptionSchemeTypeEnumToString:(ECLEncryptionScheme)enumVal;


// A method to retrieve the int value from the NSArray of NSStrings
+(ECLEncryptionScheme) eclEncryptionSchemeTypeStringToEnum:(NSString*)strVal;

@end

