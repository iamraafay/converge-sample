//
//  ECLEncryptionScheme.h
//  CommerceDataTypes
//
//  Created by Yuan, Oliver on 11/9/16.
//  Copyright © 2016 Elavon Inc. All rights reserved.
//

#ifndef ECLEncryptionScheme_h
#define ECLEncryptionScheme_h

/// \brief Enum of encryption scheme.
/// ECLCurrencyCode_Nil is unset value. ECLCurrencyCode_Unknown is unmatched value.
/// \copyright (c) 2016 Elavon. All rights reserved.
typedef enum
{
    ECLEncryptionScheme_NONE = 0,
    ECLEncryptionScheme_TLS_12,
} ECLEncryptionScheme;

#endif /* ECLEncryptionScheme_h */
