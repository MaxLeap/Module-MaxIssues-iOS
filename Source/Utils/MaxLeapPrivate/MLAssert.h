//
//  MLAssert.h
//  MaxLeap
//

#ifndef MaxLeap_MLAssert_h
#define MaxLeap_MLAssert_h

#import "MLLogging.h"

/*!
 Raises an `NSInvalidArgumentException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define MLParameterAssert(condition, description, ...) \
do { \
    if (!(condition)) { \
        [NSException raise:NSInvalidArgumentException format:description, ##__VA_ARGS__]; \
    } \
} while (0)

/*!
 Raises an `NSRangeException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define MLRangeAssert(condition, description, ...) \
do { \
    if (!(condition)) { \
        [NSException raise:NSRangeException format:description, ##__VA_ARGS__]; \
    } \
} while (0)

/*!
 Raises an `NSInternalInconsistencyException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define MLConsistencyAssert(condition, description, ...) \
do { \
    if (!(condition)) { \
        [NSException raise:NSInternalInconsistencyException format:description, ##__VA_ARGS__]; \
    } \
} while (0)


/*!
 Always raises `NSInternalInconsistencyException` with details
 about the method used and class that received the message
 */
#define MLNotDesignatedInitializer() \
do { \
    MLConsistencyAssert(NO, \
                        @"%@ is not the designated initializer for instances of %@.", \
                        NSStringFromSelector(_cmd), \
                        NSStringFromClass([self class])); \
} while (0)

/*!
 Raises `NSInternalInconsistencyException` if current thread is not main thread.
 */
#define MLAssertMainThread() \
do { \
    MLConsistencyAssert([NSThread isMainThread], @"This method must be called on the main thread."); \
} while (0)

/*!
 Raises `NSInternalInconsistencyException` if current thread is not the required one.
 */
#define MLAssertIsOnThread(thread) \
do { \
    MLConsistencyAssert([NSThread currentThread] == thread, @"This method must be called only on thread: %@.", thread); \
} while (0)

#endif // MaxLeap_MLAssert_h
