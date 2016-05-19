//
//  MLInernelUtils.h
//  MaxLeap
//

#import <Foundation/Foundation.h>

@interface MLInternalUtils : NSObject

#pragma mark - Date Formatter
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;

@end

