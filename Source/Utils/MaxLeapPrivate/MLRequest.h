//
//  MLRequestBuilder.h
//  MaxLeap
//

#import <MaxLeap/MLConstants.h>

typedef NS_ENUM(NSInteger, MLConnectMethod) {
    MLConnectMethodGet,
    MLConnectMethodPost,
    MLConnectMethodPut,
    MLConnectMethodDelete
};

NS_ASSUME_NONNULL_BEGIN

@interface MLRequest : NSObject

@property (nonatomic) MLConnectMethod method; // default is MLConnectMethodGet
@property (nonatomic, copy) NSString *path;
@property (nullable, nonatomic, strong) NSDictionary *queryParams;
/*
    body 只接受 NSArray 和 NSDictionary 对象
 */
@property (nullable, nonatomic, strong) id body;

- (void)sendWithCompletion:(MLIdResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
