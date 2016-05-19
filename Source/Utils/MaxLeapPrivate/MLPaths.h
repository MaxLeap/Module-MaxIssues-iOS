//
//  MLPaths.h
//  MaxLeap
//

#import <Foundation/Foundation.h>

@interface MLPaths : NSObject

// directory paths
+ (NSString *)privateDocumentPath;
+ (NSString *)cachesPath;

+ (void)ensureDirExist:(NSString *)dirPath;

@end
