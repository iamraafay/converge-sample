//
//  ECCLogging.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#ifndef Commerce_ECCLogging_h
#define Commerce_ECCLogging_h

#ifdef DEBUG

#define ECC_LOG_DEBUGF(format, ...) NSLog(format, ##__VA_ARGS__)
#define ECC_LOG_DEBUG(message)      NSLog(message)

#define ECC_LOG_OBJC_TRACE()        NSLog(@"TRACE: [%@ %s] (%s:%d)", [[self class] description], sel_getName(_cmd), __FILE__, __LINE__)
#define ECC_LOG_OBJC_TRACEF(format, ...) NSLog(@"TRACE: [%@ %s]; %@ (%s:%d)", [[self class] description], sel_getName(_cmd), [NSString stringWithFormat:format, ##__VA_ARGS__], __FILE__, __LINE__)
#define ECC_LOG_C_TRACE_FUNC()      NSLog(@"TRACE: %s (%s:%d)", __FUNCTION__, __FILE__, __LINE__)

#define ECC_LOG_INFOF(format, ...)  NSLog(format, ##__VA_ARGS__)
#define ECC_LOG_INFO(message)       NSLog(message)

#define ECC_LOG_ERRORF(format, ...) NSLog(format, ##__VA_ARGS__)
#define ECC_LOG_ERROR(message)      NSLog(message)

#else

#define ECC_LOG_DEBUGF(format, ...)
#define ECC_LOG_DEBUG(message)

#define ECC_LOG_OBJC_TRACE()
#define ECC_LOG_OBJC_TRACEF(format, ...)
#define ECC_LOG_C_TRACE_FUNC()

#define ECC_LOG_INFOF(format, ...)  NSLog(format, ##__VA_ARGS__)
#define ECC_LOG_INFO(message)       NSLog(message)

#define ECC_LOG_ERRORF(format, ...) NSLog(format, ##__VA_ARGS__)
#define ECC_LOG_ERROR(message)      NSLog(message)

#endif

#endif
