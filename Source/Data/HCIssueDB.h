//
//  HCIssueDBManager.h
//  MaxLeap
//

#import "HCIssue.h"

@class MLSQLiteManager;

@interface HCIssueDB : NSObject

+ (instancetype)sharedDB;

@property (nonatomic, strong) MLSQLiteManager *dbManager;

- (HCMessage *)messageWithLocalId:(NSString *)localId;

- (NSArray *)loadMessagesWithIssueId:(NSString *)issueId;

- (void)insertMessage:(HCMessage *)message;
- (void)updateMessage:(HCMessage *)message;
- (void)deleteMessage:(HCMessage *)message;

@end
