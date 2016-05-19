//
//  HCMessage.m
//  MaxLeap
//

#import "HCMessage.h"
#import "HCIssueClient.h"
#import "MLPaths.h"
#import "MLInternalUtils.h"
#import "HCLocalizable.h"
#import <MaxLeap/MaxLeap.h>

@interface MLFile ()
+ (instancetype)fileWithName:(NSString *)name url:(NSString *)url;
- (NSData *)getLocalData;
@end

@interface HCMessage ()
@property (nonatomic, strong) MLProgressBlock uploadProgressBlock;
@property (nonatomic, strong) MLProgressBlock downloadProgressBlock;
@property (nonatomic, strong) HCFaqReferrence *faqReferrence;
@property (nonatomic, strong) UIImage *imageCachedInMemory;
@end

@implementation HCMessage

@synthesize formattedCreatedAt = _formattedCreatedAt;

- (HCMessageContentType)contentType {
    if (self.attach.count > 0 || self.imageFile) {
        return HCMessageContentTypeImage;
    }
    return HCMessageContentTypeText;
}

- (NSString *)displayContent {
    if (self.content) {
        if (self.faqReferrence) {
            NSString *text = HCLocalizedString(@"Please refer to FAQ: ", nil);
            NSString *title = [self.faqReferrence title];
            text = [text stringByAppendingString:title];
            return text;
        }
        return self.content;
    }
    return nil;
}



+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *dict = [dictionary mutableCopy];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == [NSNull null]) {
            [dict removeObjectForKey:key];
        }
    }];
    
    HCMessage *message = [[HCMessage alloc] init];
    message.content = dict[@"content"];
    message.faqReferrence = [HCFaqReferrence referrenceFromString:message.content];
    if ([dict[@"createdAt"] isKindOfClass:[NSString class]]) {
        message.createdAt = [MLInternalUtils dateFromString:dict[@"createdAt"]];
    }
    message.authorInfo = dict[@"authorInfo"];
    
    message.attach = dict[@"attach"];
    
    message.localId = dict[@"localId"];
    message.issueId = dict[@"issueId"];
    message.filePath = dict[@"filePath"];
    message.appId = dict[@"appId"];
    message.dataStatus = (HCMessageStatus)[dict[@"dataStatus"] integerValue];
    message.reachStatus = (HCMessageReachStatus)[dict[@"reachStatus"] integerValue];
    
    return message;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.content) dict[@"content"] = self.content;
    if (self.attach)  dict[@"attach"] = self.attach;
    
    NSString *createdAtStr = [MLInternalUtils stringFromDate:self.createdAt];
    if (createdAtStr) {
        dict[@"createdAt"] = createdAtStr;
    }
    if (self.authorInfo) dict[@"authorInfo"] = self.authorInfo;
    dict[@"localId"] = self.localId;
    if (self.issueId) dict[@"issueId"] = self.issueId;
    if (self.filePath) dict[@"filePath"] = self.filePath;
    dict[@"dataStatus"] = @(self.dataStatus);
    dict[@"reachStatus"] = @(self.reachStatus);
    return dict;
}

+ (HCMessage *)messageWithContent:(NSString *)content issueId:(NSString *)issueId {
    if (content.length) {
        HCMessage *message = [[HCMessage alloc] init];
        message.content = content;
        message.faqReferrence = [HCFaqReferrence referrenceFromString:message.content];
        message.issueId = issueId;
        message.dataStatus = HCMessageStatusShouldUpload;
        message.createdAt = [NSDate date];
        message.appId = [MaxLeap applicationId];
        return message;
    } else {
        return nil;
    }
}

+ (HCMessage *)messageWithImage:(UIImage *)image issueId:(NSString *)issueId {
    if (image) {
        NSString *path = [self storeImage:image];
        MLFile *img = [MLFile fileWithName:@"image.jpg" contentsAtPath:path];
        HCMessage *message = [[HCMessage alloc] init];
        message.imageFile = img;
        message.issueId = issueId;
        message.filePath = path;
        message.dataStatus = HCMessageStatusShouldUpload;
        message.createdAt = [NSDate date];
        message.appId = [MaxLeap applicationId];
        return message;
    }
    return nil;
}

#pragma mark - Cache

- (MLFile *)imageFile {
    if (!_imageFile && self.attach.count > 0) {
        _imageFile = [MLFile fileWithName:nil url:self.attach.firstObject];
    }
    return _imageFile;
}

+ (NSString *)storeImage:(UIImage *)image {
    NSString *path = [self cachePathForImage:image];
    
    NSData *data = UIImageJPEGRepresentation(image, 1.f);
    BOOL success = [data writeToFile:path atomically:YES];
    MLLogDebugF(@"store image success %d", success);
    
    return path;
}

+ (NSString *)cacheDir {
    static NSString *_imageCacheFolder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageCacheFolder = [[MLPaths cachesPath] stringByAppendingPathComponent:@"helpcenter"];
    });
    [MLPaths ensureDirExist:_imageCacheFolder];
    
    return _imageCacheFolder;
}

+ (NSString *)cachePathForImage:(UIImage *)image {
    NSString *uuid = [[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *path = [[self cacheDir] stringByAppendingPathComponent:uuid];
    return path;
}

+ (NSString *)cachePathWithFilename:(NSString *)filename {
    NSString *path = [[self cacheDir] stringByAppendingPathComponent:filename];
    return path;
}

#pragma mark - Author info

- (HCMessageAuthorType)authorType {
    return (HCMessageAuthorType)[self.authorInfo[@"userType"] integerValue];
}

- (BOOL)isFromSelf {
    return [self authorType] == HCMessageAuthorTypeApp;
}

#pragma mark -

- (NSString *)localId {
    if (!_localId) {
        _localId = [[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    }
    return _localId;
}

- (NSString *)formattedCreatedAt {
    if (!_formattedCreatedAt) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        _formattedCreatedAt = [formatter stringFromDate:self.createdAt];
    }
    return _formattedCreatedAt;
}

#pragma mark -

+ (NSArray *)splitedMessagesFromMessage:(HCMessage *)message {
    NSMutableArray *list = [NSMutableArray array];
    if (message.content.length && message.attach.count) {
        for (NSString *url in message.attach) {
            HCMessage *msg = [[HCMessage alloc] init];
            msg.attach = @[url];
            msg.appId = message.appId;
            msg.seq = message.seq;
            msg.createdAt = message.createdAt;
            msg.authorInfo = message.authorInfo;
            [list addObject:msg];
        }
        HCMessage *msg = [[HCMessage alloc] init];
        msg.content = message.content;
        msg.faqReferrence = message.faqReferrence;
        msg.seq = message.seq;
        msg.appId = message.appId;
        msg.createdAt = message.createdAt;
        msg.authorInfo = message.authorInfo;
        [list addObject:msg];
    }
    return list;
}

+ (void)splitImageMessages:(NSMutableArray *)messages {
    
    NSInteger index = 0;
    
    while (messages.count > index) {
        HCMessage *msg = messages[index];
        NSArray *splitedList = [self splitedMessagesFromMessage:msg];
        if (splitedList.count > 0) {
            [messages removeObjectAtIndex:index];
            [messages insertObjects:splitedList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, splitedList.count)]];
        }
        
        index ++;
    }
}

+ (void)reorderMessages:(NSMutableArray *)messages {
    for (int i = 0; i < messages.count ; i ++) {
        for (int j = i+1; j < messages.count; j ++) {
            HCMessage *msgi = messages[i];
            HCMessage *msgj = messages[j];
            if ([msgj.createdAt compare:msgi.createdAt] == NSOrderedAscending) { // msgj 早于 msgi
                [messages exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}


#pragma mark -

- (BOOL)isEmpty {
    return self.content.length == 0 && self.attach.count == 0 && !self.imageFile;
}

- (void)reset {
    
}

- (void)uploadData:(MLBooleanResultBlock)complete {
    
    if (self.dataStatus == HCMessageStatusShouldUpload) {
        
        self.dataStatus = HCMessageStatusIsUploading;
        
        if (self.imageFile) {
            
            [self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (self.imageFile.url) {
                        self.attach = @[self.imageFile.url];
                    }
                    [HCIssueClient sendMessage:self block:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            self.dataStatus = HCMessageStatusNormal;
                        } else {
                            self.dataStatus = HCMessageStatusUploadFailed;
                        }
                        if (complete) {
                            complete(succeeded, error);
                        }
                    }];
                } else {
                    self.dataStatus = HCMessageStatusUploadFailed;
                    if (complete) {
                        complete(succeeded, error);
                    }
                }
            } progressBlock:^(int percentDone) {
                if (self.uploadProgressBlock) {
                    self.uploadProgressBlock(percentDone);
                }
            }];
            
        } else if (self.content.length) {
            
            [HCIssueClient sendMessage:self block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.dataStatus = HCMessageStatusNormal;
                } else {
                    self.dataStatus = HCMessageStatusUploadFailed;
                }
                if (complete) {
                    complete(succeeded, error);
                }
            }];
        }
        
    } else if (self.dataStatus == HCMessageStatusUploadFailed) {
        
        if (self.attach.count == 0) {
            
            self.dataStatus = HCMessageStatusShouldUpload;
            [self uploadData:complete];
            
        } else {
            
            [HCIssueClient sendMessage:self block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.dataStatus = HCMessageStatusNormal;
                } else {
                    self.dataStatus = HCMessageStatusUploadFailed;
                }
                if (complete) {
                    complete(succeeded, error);
                }
            }];
        }
    }
}

- (void)downloadData:(MLDataStreamResultBlock)complete {
    
    if (self.dataStatus == HCMessageStatusShouldDownload) {
        
        self.dataStatus = HCMessageStatusIsDownloading;
        
        NSString *url = self.attach.firstObject;
        self.imageFile = [MLFile fileWithName:nil url:url];
        [self.imageFile getDataStreamInBackgroundWithBlock:^(NSInputStream *stream, NSError *error) {
            if (error) {
                self.dataStatus = HCMessageStatusDownloadFailed;
            } else {
                self.dataStatus = HCMessageStatusNormal;
            }
            if (complete) {
                complete(stream, error);
            }
        } progressBlock:^(int percentDone) {
            if (self.downloadProgressBlock) {
                self.downloadProgressBlock(percentDone);
            }
        }];
        
    } else if (self.dataStatus == HCMessageStatusDownloadFailed) {
        
        self.dataStatus = HCMessageStatusShouldDownload;
        [self downloadData:complete];
    }
}

#pragma mark -
#pragma mark 

- (UIImage *)imageCachedInMemory {
    if (!_imageCachedInMemory) {
        NSData *imgData = [self.imageFile getLocalData];
        _imageCachedInMemory = [UIImage imageWithData:imgData];
    }
    return _imageCachedInMemory;
}

- (void)clearMemoryCache {
    self.imageCachedInMemory = nil;
}

- (void)getImageWithCompletion:(void (^)(UIImage *, NSError *))completion {
    UIImage *cachedImage = self.imageCachedInMemory;
    if (cachedImage) {
        if (completion) {
            completion(cachedImage, nil);
        }
    } else {
        [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                [self downloadImageCompletion:completion];
            } else {
                if (completion) {
                    UIImage *img = [UIImage imageWithData:data];
                    self.imageCachedInMemory = img;
                    completion(img, nil);
                }
            }
        }];
    }
}

- (void)downloadImageCompletion:(void(^)(UIImage *, NSError *))block {
    
    [self downloadData:^(NSInputStream *stream, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableData *imgData = [NSMutableData data];
            if (stream) {
                [stream open];
                uint8_t *buffer = malloc(4 * 1024 * sizeof(uint8_t));
                while ([stream hasBytesAvailable]) {
                    NSInteger lenRead = [stream read:buffer maxLength:1024];
                    if (lenRead > 0) {
                        [imgData appendBytes:buffer length:lenRead];
                    }
                }
                free(buffer);
                [stream close];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imgData];
                if (block) {
                    block(image, error);
                }
            });
        });
    }];
}

@end
