//
//  MLLogging.h
//  MaxLeap
//

#ifndef MaxLeap_MLLogging_h
#define MaxLeap_MLLogging_h

#import <MaxLeap/MLLogger.h>

#ifndef MLLogTag
    #warning Please define a "MLLogTag" in "Preprocessor Macros"
    #define MLLogTag @"MaxLeap"
#endif  // MLLogTag

#define MLLogError(...) MLLogMessageTo(MLLogTag, MLLogLevelError, __VA_ARGS__)
#define MLLogErrorF(...) MLLogMessageToF(MLLogTag, MLLogLevelError, __FUNCTION__, __VA_ARGS__)
#define MLLogErrorToF(tag, ...) MLLogMessageToF(tag, MLLogLevelError, __FUNCTION__, __VA_ARGS__)

#define MLLogWarning(...) MLLogMessageTo(MLLogTag, MLLogLevelWarning, __VA_ARGS__)
#define MLLogWarningF(...) MLLogMessageToF(MLLogTag, MLLogLevelWarning, __FUNCTION__, __VA_ARGS__)
#define MLLogWarningToF(tag, ...) MLLogMessageToF(tag, MLLogLevelWarning, __FUNCTION__, __VA_ARGS__)

#define MLLogInfo(...) MLLogMessageTo(MLLogTag, MLLogLevelInfo, __VA_ARGS__)
#define MLLogInfoF(...) MLLogMessageToF(MLLogTag, MLLogLevelInfo, __FUNCTION__, __VA_ARGS__)
#define MLLogInfoToF(tag, ...) MLLogMessageToF(tag, MLLogLevelInfo, __FUNCTION__, __VA_ARGS__)

#define MLLogDebug(...) MLLogMessageTo(MLLogTag, MLLogLevelDebug, __VA_ARGS__)
#define MLLogDebugF(...) MLLogMessageToF(MLLogTag, MLLogLevelDebug, __FUNCTION__, __VA_ARGS__)
#define MLLogDebugToF(tag, ...) MLLogMessageToF(tag, MLLogLevelDebug, __FUNCTION__, __VA_ARGS__)

#define MLLogException(exception) \
    MLLogError(@"Caught \"%@\" with reason \"%@\"%@", \
                exception.name, exception, \
                [exception callStackSymbols] ? [NSString stringWithFormat:@":\n%@.", [exception callStackSymbols]] : @"")

#endif
