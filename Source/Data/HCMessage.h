//
//  HCMessage.h
//  MaxLeap
//

#import "HCFaqReferrence.h"
#import <MaxLeap/MLConstants.h>

#define HCMessageStatuChangeNotification  @"HCMessageStatuChange"
#define HCMessageReachStatuChangeNotification  @"HCMessageReachStatuChange"
#define IMAGE_MAX_WIDTH  150
#define IMAGE_MAX_HEIGHT  100

typedef NS_ENUM(NSInteger, HCMessageStatus) {
    HCMessageStatusNormal=0,
    HCMessageStatusShouldDownload,
    HCMessageStatusIsDownloading,
    HCMessageStatusDownloadFailed,
    HCMessageStatusShouldUpload,
    HCMessageStatusIsUploading,
    HCMessageStatusUploadFailed
};

typedef NS_ENUM(NSInteger, HCMessageReachStatus) {
    HCMessageReachStatusNull=0,
    HCMessageReachStatusReach,
    HCMessageReachStatusRead
};

typedef NS_ENUM(NSInteger, HCMessageAuthorType) {
    HCMessageAuthorTypeUnknown = -1,
    HCMessageAuthorTypeApp = 0,
    HCMessageAuthorTypeOrg = 1,
    HCMessageAuthorTypeAdmin = 2,
    HCMessageAuthorTypePassport = 5
};

typedef NS_ENUM(NSInteger, HCMessageContentType) {
    HCMessageContentTypeText=0,
    HCMessageContentTypeImage
};


@interface HCMessage : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, readonly) NSString *formattedCreatedAt;
@property (nonatomic) NSInteger seq;

@property (nonatomic, strong) NSDictionary *authorInfo;
- (HCMessageAuthorType)authorType;
- (BOOL)isFromSelf;

@property (nonatomic, strong) NSArray *attach;
//@property (nonatomic, strong) NSArray *files; // MLFile Objects
//- (void)getAttachAtIndex:(NSInteger)index completion:(void(^)(NSData *data, NSString *filename, NSError *error))completion;

// local datas
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *localId;
@property (nonatomic, strong) NSString *issueId;
@property (nonatomic, strong) MLFile *imageFile;

// 发送图片之前会现在本地保存一份，filePath 是本地保存图片的路径
@property (nonatomic, strong) NSString *filePath; // only for image to upload
+ (NSString *)cachePathWithFilename:(NSString *)filename;

// 取图片顺序：内存，磁盘，网络
- (void)getImageWithCompletion:(void(^)(UIImage *image, NSError *error))completion;
- (UIImage *)imageCachedInMemory;
- (void)clearMemoryCache;


@property (nonatomic, readonly) HCFaqReferrence *faqReferrence;
- (NSString *)displayContent;

- (HCMessageContentType)contentType;

+ (void)splitImageMessages:(NSMutableArray *)messages;
+ (void)reorderMessages:(NSMutableArray *)messages;

+ (HCMessage *)messageWithContent:(NSString *)content issueId:(NSString *)issueId;
+ (HCMessage *)messageWithImage:(UIImage *)image issueId:(NSString *)issueId;

+ (instancetype)fromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;



@property (nonatomic) HCMessageStatus dataStatus;
@property (nonatomic) HCMessageReachStatus reachStatus;


- (BOOL)isEmpty;

- (void)reset;

- (void)uploadData:(MLBooleanResultBlock)complete;
- (void)setUploadProgressBlock:(MLProgressBlock)block;

- (void)downloadData:(MLDataStreamResultBlock)complete;
- (void)setDownloadProgressBlock:(MLProgressBlock)block;

@end


