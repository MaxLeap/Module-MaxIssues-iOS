//
//  HCIssueManager.h
//  MaxLeap
//

#import <Foundation/Foundation.h>
#import "HCMessage.h"
#import "HCIssue.h"

@interface HCIssueManager : NSObject

@property (nonatomic, readonly) HCIssue *currentIssue;

+ (instancetype)sharedManager;

// if true, show an alert when app enter foreground if there is new messages
@property (nonatomic) BOOL shouldAlertNewMessage;

// auto refreshing
- (void)startRefreshingMessages;
- (void)stopRefreshingMessages;

- (void)checkIssueWithBlock:(void (^)(NSArray *newMessages, NSError *error))block;
- (void)getNewMessageCountInBackgroundWithBlock:(void (^)(NSInteger))block;

// issue
- (void)loadIssueFromRemoteWithBlock:(MLBooleanResultBlock)block;

- (void)createIssueWithTitle:(NSString *)title
                    username:(NSString *)username
                       email:(NSString *)email
                       files:(NSArray *)files
                       block:(MLBooleanResultBlock)block;

- (void)closeCurrentIssue:(MLBooleanResultBlock)block;
- (void)reopenCurrentIssue:(MLBooleanResultBlock)block;

// messages

- (void)setNewMessageBlock:(void(^)(NSArray *newMessages))block;
- (void)setIssueStautsChangedBlock:(void (^)(HCIssueStatus))block;

@property (nonatomic) NSInteger unreadMessagesCount;
- (NSArray *)messages;
- (NSArray *)messagesAfter:(NSDate *)date;

- (void)sendMessage:(HCMessage *)message completion:(MLBooleanResultBlock)completion;
- (void)resendFailedMessage:(HCMessage *)message completion:(MLBooleanResultBlock)completion;

- (void)deleteMessage:(HCMessage *)message;
- (void)updateMessage:(HCMessage *)message;

@end
