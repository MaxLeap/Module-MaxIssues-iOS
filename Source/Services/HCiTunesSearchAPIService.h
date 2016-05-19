//
//  HCiTunesSearchAPIService.h
//  MaxLeap
//

#import <Foundation/Foundation.h>

@interface HCiTunesSearchAPIService : NSObject

+ (void)getiTunesAppId:(void(^)(NSNumber *appId, NSError *error))callback;

@end
