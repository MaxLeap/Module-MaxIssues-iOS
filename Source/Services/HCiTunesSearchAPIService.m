//
//  HCiTunesSearchAPIService.m
//  MaxLeap
//

#import "HCiTunesSearchAPIService.h"
#import "MLLogging.h"

#define ITUNES_SEARCH_API_BASE_URL @"https://itunes.apple.com"
#define ITUNES_SEARCH_PATH @"/search"
#define ITUNES_LOOKUP_PATH @"/lookup"

@implementation HCiTunesSearchAPIService

+ (NSOperationQueue *)iTunesSearchQueue {
    @synchronized (self) {
        static NSOperationQueue *_iTunesSearchQueue = nil;
        if (!_iTunesSearchQueue) {
            _iTunesSearchQueue = [[NSOperationQueue alloc] init];
        }
        return _iTunesSearchQueue;
    }
}

+ (void)requestPath:(NSString *)apiPath params:(NSDictionary *)params completion:(void (^)(NSDictionary *responseObject, NSError *error))completion {
    
    if (!completion) return;
    
    if (apiPath == nil) {
        completion(nil, nil);
        return;
    }
    
    if (NO == [apiPath hasPrefix:@"/"]) apiPath = [@"/" stringByAppendingString:apiPath];
    
    NSString *url = [ITUNES_SEARCH_API_BASE_URL stringByAppendingString:apiPath];
    
    if (params) {
        NSMutableArray *keyValuePairs = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", key, obj];
            [keyValuePairs addObject:pair];
        }];
        NSString *queryString = [keyValuePairs componentsJoinedByString:@"&"];
        url = [url stringByAppendingString:@"?"];
        url = [url stringByAppendingString:queryString];
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:req queue:[self iTunesSearchQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSDictionary *result = nil;
        if ( ! connectionError && data) {
            result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&connectionError];
            if (NO == [result isKindOfClass:[NSDictionary class]]) {
                MLLogErrorF(@"!!! Unexpected response object from itunes search api, apple may have made some changes to this api !!!");
            }
        }
        completion(result, connectionError);
    }];
}

+ (void)search:(NSDictionary *)params completion:(void (^)(NSArray *results, NSInteger resultCount, NSError *error))completion {
    
    if (!completion) return;
    
    [self requestPath:ITUNES_SEARCH_PATH params:params completion:^(NSDictionary *responseObject, NSError *error) {
        NSArray *results = responseObject[@"results"];
        NSInteger resultCount = [responseObject[@"resultCount"] integerValue];
        completion(results, resultCount, error);
    }];
}

+ (void)lookup:(NSDictionary *)params completion:(void (^)(NSArray *results, NSInteger resultCount, NSError *error))completion {
    
    if (!completion) return;
    
    [self requestPath:ITUNES_LOOKUP_PATH params:params completion:^(NSDictionary *responseObject, NSError *error) {
        NSArray *results = responseObject[@"results"];
        NSInteger resultCount = [responseObject[@"resultCount"] integerValue];
        completion(results, resultCount, error);
    }];
}

+ (void)getiTunesAppId:(void(^)(NSNumber *appId, NSError *error))callback {
    
    if ( ! callback) return;
    
    NSString *bid = [NSBundle mainBundle].bundleIdentifier;
    NSDictionary *params = @{@"bundleId":bid};
    [self lookup:params completion:^(NSArray *results, NSInteger resultCount, NSError *error) {
        NSDictionary *appInfo = [results firstObject];
        NSNumber *appId = appInfo[@"trackId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(appId, error);
        });
    }];
}

@end
