//
//  HCIssue.m
//  MaxLeap
//

#import "HCIssue.h"
#import <MaxLeap/MaxLeap.h>
#import "MLDevice.h"
#import "MLPaths.h"
#import "MLAssert.h"
#import "MLInternalUtils.h"

static HCIssue *__currentIssue = nil;

NSString * const kHCIssueUserNameKey = @"userName";
NSString * const kHCIssueUserEmailKey = @"email";

@interface MLObject ()
- (BOOL)handleFetchResult:(NSDictionary *)result;
@end

@implementation HCIssue

@dynamic status, title, content, attach, langCode, langName, tags, platform, lastReply, tz, read;
@dynamic userInfo, deviceInfo, installId, appId;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"_Issue";
}

+ (void)assertValidLeapClassName:(NSString *)className {
    MLParameterAssert([className isEqualToString:[HCIssue leapClassName]],
                      @"Cannot initialize HCIssue with the custom class name `%@`", className);
}

- (HCIssueStatus)issueStatus {
    return (HCIssueStatus)[self.status integerValue];
}

- (BOOL)handleFetchResult:(NSDictionary *)result {
    NSMutableArray *toRemove = [NSMutableArray array];
    for (NSString *key in result.allKeys) {
        if (result[key] == [NSNull null]) {
            [toRemove addObject:key];
        }
    }
    NSMutableDictionary *dict = [result mutableCopy];
    [dict removeObjectsForKeys:toRemove];
    return [super handleFetchResult:dict];
}

- (void)setUserName:(NSString *)userName {
    NSMutableDictionary *dict = [self.userInfo mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    dict[kHCIssueUserNameKey] = userName;
    self.userInfo = dict;
}

- (void)setUserEmail:(NSString *)userEmail {
    NSMutableDictionary *dict = [self.userInfo mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    dict[kHCIssueUserEmailKey] = userEmail;
    self.userInfo = dict;
}

+ (HCIssue *)newIssueWithTitle:(NSString *)title
                      userName:(NSString *)userName
                     userEmail:(NSString *)userEmail
                         files:(NSArray *)files
{
    HCIssue *issue = [HCIssue object];
    issue.title = title;
    [issue setUserName:userName];
    if (userEmail.length) {
        [issue setUserEmail:userEmail];
    }
    issue.files = files;
    issue.platform = @[@"0"];
    issue.installId = [MLInstallation currentInstallation].installationId;
    issue.tz = [[NSTimeZone systemTimeZone] localizedName:NSTimeZoneNameStyleShortStandard locale:[NSLocale currentLocale]];
    issue.deviceInfo = [self deviceInfo];
    issue.langCode = [MLDevice currentDevice].preferredLanguageId;
    return issue;
}

+ (NSDictionary *)deviceInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"appId"] = [MaxLeap applicationId];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]?:@"";
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"%@(%@)", appVersion, build];
    dict[@"appVersion"] = version;
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]?:[NSNull null];
    dict[@"appName"] = appName;
    
    dict[@"deviceModel"] = [MLDevice currentDevice].modelIdentifier;
    
    NSString *batteryLevel = @"Unknown";
    if ([UIDevice currentDevice].batteryLevel >= 0) {
        batteryLevel = [NSString stringWithFormat:@"%.1f%%", [UIDevice currentDevice].batteryLevel];
    }
    dict[@"batteryLevel"] = batteryLevel;
    dict[@"batteryStatus"] = [@([UIDevice currentDevice].batteryState) stringValue];
    
    long long totalSpace = [[MLDevice currentDevice] totalDiskSpace];
    dict[@"totalSpace"] = [self formatedBytes:totalSpace];
    
    long long freeSpace = [[MLDevice currentDevice] freeDiskSpace];
    dict[@"freeSpace"] = [self formatedBytes:freeSpace];
    
    dict[@"osVersion"] = [MLDevice currentDevice].systemVersion;
    dict[@"deviceType"] = @"ios";
    dict[@"network"] = [MLDevice currentDevice].networkType;
    dict[@"national"] = [MLDevice currentDevice].national;
    dict[@"language"] = [MLDevice currentDevice].preferredLanguageId;
    dict[@"sdkVersion"] = MaxLeap_VERSION;
    
    return dict;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[self valueForKey:@"estimatedData"] mutableCopy];
    NSMutableArray *msgs = [NSMutableArray array];
    for (HCMessage *message in self.msgs) {
        [msgs addObject:[message toDictionary]];
    }
    dict[@"msgs"] = msgs;
    
    if (self.objectId) dict[@"objectId"] = self.objectId;
    
    NSString *createdAtStr = [MLInternalUtils stringFromDate:self.createdAt];
    if (createdAtStr) dict[@"createdAt"] = createdAtStr;
    
    NSString *updatedAtStr = [MLInternalUtils stringFromDate:self.updatedAt];
    if (updatedAtStr) dict[@"updatedAt"] = updatedAtStr;
    
    return dict;
}

+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    
    NSMutableArray<HCMessage*> *messages = [NSMutableArray array];
    [dictionary[@"msgs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [messages addObject:[HCMessage fromDictionary:obj]];
        }
    }];
    
    NSString *objectId = dictionary[@"objectId"];
    if (objectId) {
        HCIssue *issue = [HCIssue objectWithoutDataWithObjectId:objectId];
        [issue handleFetchResult:dictionary];
        issue.msgs = messages;
        return issue;
    } else {
        NSMutableDictionary *dict_M = [dictionary mutableCopy];
        [dict_M removeObjectForKey:@"updatedAt"];
        [dict_M removeObjectForKey:@"createdAt"];
        HCIssue *issue = [HCIssue objectWithClassName:[HCIssue leapClassName] dictionary:dict_M];
        issue.msgs = messages;
        return issue;
    }
}

+ (NSString *)formatedBytes:(long long)bytes {
    NSString *unit = @"B";
    double space = (double)bytes;
    if (space > 1024) {
        space /= 1024.f;
        unit = @"KB";
    }
    if (space > 1024) {
        space /= 1024.f;
        unit = @"MB";
    }
    if (space > 1024) {
        space /= 1024.f;
        unit = @"GB";
    }
    return [NSString stringWithFormat:@"%.1f%@", space, unit];
}

+ (NSString *)issuePath {
    static NSString *_dirPath = nil;
    if (!_dirPath) {
        _dirPath = [[MLPaths privateDocumentPath] stringByAppendingPathComponent:@"issues"];
    }
    [MLPaths ensureDirExist:_dirPath];
    return _dirPath;
}

@end
