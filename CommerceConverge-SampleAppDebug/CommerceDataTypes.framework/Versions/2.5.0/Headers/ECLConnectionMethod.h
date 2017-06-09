/* ECLConnectionMethod.h */

#ifndef	_ECL_CONNECTION_METHOD_H_
#define	_ECL_CONNECTION_METHOD_H_

#import <Foundation/Foundation.h>

/// \brief The general method and medium that describes how a device is connected.
/// \copyright (c) 2016 Elavon. All rights reserved.
typedef enum {
    ECLConnectionMethod_Nil = 0,
    ECLConnectionMethod_Unknown,
    ECLConnectionMethod_USB,
    ECLConnectionMethod_Bluetooth,
    ECLConnectionMethod_Internet,
    ECLConnectionMethod_Audio,
} ECLConnectionMethod;


#endif
