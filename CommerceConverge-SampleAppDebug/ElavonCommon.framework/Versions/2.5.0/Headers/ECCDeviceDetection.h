//
//  DeviceDetection.h
//  MobileMerchant
//
//  Copyright (c) 2013 Elavon Inc. All rights reserved.
//

#ifndef __ECCDeviceDetection__
#define __ECCDeviceDetection__

#import "ECCDeviceDetectionStatus.h"

extern "C"  {
    namespace ecc
    {
        ECCDeviceDetectionStatus isDeviceSafe();
    }
}
#endif