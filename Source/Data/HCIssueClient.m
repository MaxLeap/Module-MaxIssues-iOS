//
//  HCIssueClient.m
//  MaxLeap
//

#import "HCIssueClient.h"
#import "MLRequest.h"
#import "MLInternalUtils.h"
#import "MLAssert.h"
#import <MaxLeap/MaxLeap.h>

@interface MLObject ()
- (BOOL)handleSaveResult:(id)result error:(NSError *)error;
@end

@implementation HCIssueClient

+ (void)uploadAttaches:(NSArray *)attaches completion:(dispatch_block_t)completion {
    if (attaches.count > 0) {
        MLFile *file = attaches.firstObject;
        attaches = [attaches subarrayWithRange:NSMakeRange(1, attaches.count -1)];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self uploadAttaches:attaches completion:completion];
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

+ (void)createIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block {
    MLParameterAssert(issue.title, @"new issue must have a title!!!");
    [self uploadAttaches:issue.files completion:^{
        
        NSMutableArray *attach = [NSMutableArray array];
        for (MLFile *file in issue.files) {
            if (file.url) [attach addObject:file.url];
        }
        NSInteger failureCount = issue.files.count - attach.count;
        NSError *fileUploadError = nil;
        if (failureCount > 0) {
            fileUploadError = [NSError errorWithDomain:@"HCImageUploadErrorDomain" code:-199 userInfo:@{@"failureCount":@(failureCount)}];
        }
        
        NSMutableDictionary *bodyObj = [NSMutableDictionary dictionary];
        bodyObj[@"title"] = issue.title;
        bodyObj[@"attach"] = attach;
        bodyObj[@"platform"] = issue.platform;
        bodyObj[@"installId"] = issue.installId;
        bodyObj[@"tz"] = issue.tz;
        bodyObj[@"userInfo"] = issue.userInfo;
        bodyObj[@"deviceInfo"] = issue.deviceInfo;
        if (issue.langCode) {
            bodyObj[@"langCode"] = issue.langCode;
        }
        if (issue.langName) {
            bodyObj[@"langName"] = issue.langName;
        }
        
        MLRequest *request = [MLRequest new];
        request.method = MLConnectMethodPost;
        request.path = @"/help/issue";
        request.body = bodyObj;
        [request sendWithCompletion:^(id object, NSError *error) {
             BOOL success = [issue handleSaveResult:object error:error];
             if (success && !error && fileUploadError) {
                 error = fileUploadError;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (block) {
                     block(success, error);
                 }
             });
         }];
    }];
}

+ (void)getCurrentIssueWithBlock:(void(^)(HCIssue *issue, NSError *error))block {
    NSString *installId = [MLInstallation currentInstallation].installationId;
    NSDictionary *params = @{
                             @"where":@{
                                     @"$and":@[
                                             @{@"installId":installId},
                                             @{@"status":@{@"$ne":@"3"}},
                                             @{@"status":@{@"$ne":@"4"}}
                                             ]
                                     },
                             @"limit":@1
                             };
    [self findIssueWithParams:params block:^(NSArray *objects, NSError *error) {
        HCIssue *issue = [objects firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(issue, error);
            }
        });
    }];
}

+ (void)getMessagesAfter:(NSDate *)date block:(void (^)(HCIssue *, NSError *))block {
    NSString *installId = [MLInstallation currentInstallation].installationId;
    long long ts = (long long)ceil([date timeIntervalSince1970] * 1000);
    
#ifdef DEBUG
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)ts/1000.f];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSString *str = [formatter stringFromDate:lastDate];
    
    MLLogDebugF(@"last message Date: %@", str);
#endif
    
    NSDictionary *params = @{
                             @"where":@{
                                     @"$and":@[
                                             @{@"installId":installId},
                                             @{@"status":@{@"$ne":@"3"}},
                                             @{@"status":@{@"$ne":@"4"}}
                                             ]
                                     },
                             @"limit":@1,
                             @"msgValidTime":@(ts),
                             @"keys":@"objectId,status,msgs"
                             };
    [self findIssueWithParams:params block:^(NSArray *objects, NSError *error) {
        HCIssue *issue = objects.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(issue, error);
            }
        });
    }];
}

+ (void)findIssueWithParams:(NSDictionary *)params block:(MLArrayResultBlock)block {
    MLRequest *reqeust = [MLRequest new];
    reqeust.method = MLConnectMethodPost;
    reqeust.path = @"help/issue/find";
    reqeust.body = params;
    [reqeust sendWithCompletion:^(id object, NSError *error) {
        NSMutableArray *result = nil;
        if (error == nil && [object isKindOfClass:[NSArray class]]) {
            result = [NSMutableArray array];
            [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                HCIssue *issue = [HCIssue fromDictionary:obj];
                [result addObject:issue];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(result, error);
        });
    }];
}

+ (void)updateTags:(NSArray *)tags forIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block {
    NSDictionary *param = @{@"tags":tags};
    [self updateIssue:issue withParams:param block:block];
}

+ (void)closeIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block {
    NSDictionary *param = @{@"status":[@(HCIssueStatusCloseByAppUser) stringValue]};
    [self updateIssue:issue withParams:param block:block];
}

+ (void)reopenIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block {
    NSDictionary *param = @{@"status":[@(HCIssueStatusInprogress) stringValue]};
    [self updateIssue:issue withParams:param block:block];
}

+ (void)updateIssue:(HCIssue *)issue withParams:(NSDictionary *)params block:(MLBooleanResultBlock)block {
    MLParameterAssert(issue.objectId, @"Cannot update issue without issue id!");
    MLRequest *request = [MLRequest new];
    request.method = MLConnectMethodPut;
    request.path = [@"help/issue/" stringByAppendingString:issue.objectId];
    request.body = params;
    [request sendWithCompletion:^(id object, NSError *error) {
        BOOL success = [issue handleSaveResult:object error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(success, error);
        });
    }];
}

+ (void)sendMessage:(HCMessage *)message block:(MLBooleanResultBlock)block {
    
    NSError *ierr = nil;
    if (!message ||
        (message.content.length == 0 && message.attach.count == 0))
    {
        ierr = [NSError errorWithDomain:MLErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Cannot send empty message."}];
    }
    if (!ierr && !message.issueId) {
        ierr = [NSError errorWithDomain:MLErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Message's issueId cannot be nil."}];
    }
    if (ierr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(NO, ierr);
        });
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (message.content.length) params[@"content"] = message.content;
    if (message.attach.count)   params[@"attach"] = message.attach;
    
    MLRequest *request = [MLRequest new];
    request.method = MLConnectMethodPost;
    request.path = [@"help/issue/msg/" stringByAppendingString:message.issueId];
    request.body = params;
    [request sendWithCompletion:^(id object, NSError *error) {
        if (!error && [object isKindOfClass:[NSDictionary class]]) {
            NSString *dateStr = [object objectForKey:@"createdAt"];
            if (!dateStr) dateStr = [object objectForKey:@"updatedAt"];
            if (dateStr) {
                message.createdAt = [MLInternalUtils dateFromString:dateStr];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(error==nil, error);
        });
    }];
}

@end
