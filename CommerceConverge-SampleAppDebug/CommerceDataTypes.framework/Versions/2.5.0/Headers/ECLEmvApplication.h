//
//  ECLEmvApplication.h
//  CommerceDataTypes
//
//  Created by Mills, Matthew J on 5/27/16.
//  Copyright © 2016 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// \brief Representation of an EMV application
/// \copyright (c) 2016 Elavon. All rights reserved.

@interface ECLEmvApplication : NSObject

- (id)init:(NSString *)label aid:(NSString *)aid;

/// \return The readable label (or name) of the application
- (NSString *)label;

/// \return The AID of the application
- (NSString *)aid;

@end
