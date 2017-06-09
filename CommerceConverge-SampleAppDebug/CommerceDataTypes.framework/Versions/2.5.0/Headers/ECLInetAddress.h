/* ECLInetAddress.h */

#import <Foundation/Foundation.h>
#import "ECLEncryptionScheme.h"

@interface ECLInetAddress : NSObject

- (id) initWithHost:(NSString*)host port:(NSNumber *)port encryptionScheme:(ECLEncryptionScheme)encryptionScheme;
- (id) initWithHostAndClientCerficateInfo:(NSString*)host port:(NSNumber *)port encryptionScheme:(ECLEncryptionScheme)encryptionScheme clientPFXFilePath:(NSString*)clientPFXFilePath pfxFilePasscode:(NSString*)pfxFilePasscode;
@property NSString * host;
@property NSNumber * port;
@property ECLEncryptionScheme encryptionScheme;

@property NSString * clientPFXFilePath;
@property NSString * pfxFilePasscode;

@end
