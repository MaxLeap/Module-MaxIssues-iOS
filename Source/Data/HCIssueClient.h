//
//  HCIssueClient.h
//  MaxLeap
//

#import "HCIssue.h"

@interface HCIssueClient : NSObject

+ (void)createIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block;

+ (void)getCurrentIssueWithBlock:(void(^)(HCIssue *issue, NSError *error))block;
+ (void)getMessagesAfter:(NSDate *)date block:(void(^)(HCIssue *issue, NSError *error))block;

+ (void)updateTags:(NSArray *)tags forIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block;
+ (void)closeIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block;
+ (void)reopenIssue:(HCIssue *)issue block:(MLBooleanResultBlock)block;

+ (void)sendMessage:(HCMessage *)message block:(MLBooleanResultBlock)block;

@end
