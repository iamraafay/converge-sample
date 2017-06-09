/* ECLConnectionConfiguration.h */

#import <Foundation/Foundation.h>

#import "ECLConnectionMethod.h"
#import "ECLInetAddress.h"

@interface ECLConnectionConfiguration : NSObject

+ (id)sharedInstance;

@property ECLConnectionMethod connectionMethod;
@property ECLInetAddress * inetAddress;


@end


