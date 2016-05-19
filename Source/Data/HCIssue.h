//
//  HCIssue.h
//  MaxLeap
//

#import <MaxLeap/MLObject.h>
#import <MaxLeap/MLSubclassing.h>
#import <MaxLeap/MLObject+Subclass.h>
#import "HCMessage.h"

extern NSString * const kHCIssueUserNameKey;
extern NSString * const kHCIssueUserEmailKey;

typedef NS_ENUM(NSInteger, HCIssueStatus) {
    HCIssueStatusCreated = 0,
    HCIssueStatusInprogress = 1,
    HCIssueStatusResolved = 2,
    HCIssueStatusRejected = 3,
    HCIssueStatusCloseByAppUser = 4,
    HCIssueStatusCloseBySystem = 5
};

@interface HCIssue : MLObject <MLSubclassing>

@property (nonatomic) HCIssueStatus issueStatus;
@property (nonatomic) NSString *status;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *content;
@property (nonatomic) NSArray *attach;
@property (nonatomic, strong) NSArray *files; // not dynamic

@property (nonatomic) NSString *langCode;
@property (nonatomic) NSString *langName;

@property (nonatomic) NSArray *tags;
@property (nonatomic) NSArray *platform;

@property (nonatomic) NSArray *msgs; // 注意：这个属性不是 dynamic 的
@property (nonatomic) NSString *lastReply;

@property (nonatomic) NSString *tz;
@property (nonatomic, strong) NSTimeZone *timeZone;

@property (nonatomic) BOOL read;

@property (nonatomic) NSDictionary *userInfo;
- (void)setUserName:(NSString *)userName;
- (void)setUserEmail:(NSString *)userEmail;

@property (nonatomic) NSDictionary *deviceInfo;
@property (nonatomic) NSString *installId;
@property (nonatomic) NSString *appId;

- (NSDictionary *)toDictionary;
+ (instancetype)fromDictionary:(NSDictionary *)dictionary;

+ (HCIssue *)newIssueWithTitle:(NSString *)title
                      userName:(NSString *)userName
                     userEmail:(NSString *)userEmail
                         files:(NSArray *)files;

+ (NSString *)issuePath;

@end
