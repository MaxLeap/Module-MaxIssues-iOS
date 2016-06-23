//
//  HCIssueManager.m
//  MaxLeap
//

#import "HCIssueManager.h"
#import "HCIssueDB.h"
#import "HCIssueClient.h"
#import "HCLocalizable.h"
#import <MaxLeap/MaxLeap.h>
#import "HCConversationViewController.h"

#define MESSAGE_REFRESH_INTERVAL 3
#define MESSAGE_UNREAD_COUNT_KEY_PATTERN(appId) [NSString stringWithFormat:@"com.maxleap.helpcenter.issues.unreadMessageCount@%@", appId]

@interface HCIssueManager () <UIAlertViewDelegate>

@property (nonatomic, strong) HCIssue *currentIssue;
@property (nonatomic, strong) NSMutableArray *msgs;
@property (nonatomic, strong) NSMutableArray *localMessages;

@property (nonatomic, strong) void (^newMessageBlock)(NSArray *newMessages);
@property (nonatomic, strong) dispatch_block_t messageChanged;
@property (nonatomic, strong) void (^issueStautsChanged)(HCIssueStatus newStatus);

@property (nonatomic, strong) NSTimer *autoRefreshTimer;
@property (nonatomic) BOOL fetchingIssue;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL checkingIssue;

@property (nonatomic, strong) NSDate *lastMessageDate;

@end

@implementation HCIssueManager

@synthesize unreadMessagesCount = _unreadMessagesCount;

+ (instancetype)sharedManager {
    static HCIssueManager *__sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__sharedManager) {
            __sharedManager = [[HCIssueManager alloc] init];
        }
    });
    return __sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.msgs = [NSMutableArray array];
        self.localMessages = [NSMutableArray array];
        
        NSString *path = [[HCIssue issuePath] stringByAppendingPathComponent:@"currentIssue"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            self.currentIssue = [HCIssue fromDictionary:dict];
            if (self.currentIssue.msgs) {
                self.msgs = [self.currentIssue.msgs mutableCopy];
                [HCMessage reorderMessages:self.msgs];
                self.lastMessageDate = [self.msgs.lastObject createdAt];
            }
        }
        [self loadMessages];
        
        self.unreadMessagesCount = [[NSUserDefaults standardUserDefaults] integerForKey:MESSAGE_UNREAD_COUNT_KEY_PATTERN([MaxLeap applicationId])];
        
        self.shouldAlertNewMessage = YES;
        [self checkNewMessageCountAndAlert:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)loadMessages {
    NSArray *messages = [[HCIssueDB sharedDB] loadMessagesWithIssueId:self.currentIssue.objectId];
    if (messages.count) {
        self.localMessages = [messages mutableCopy];
        [self.msgs addObjectsFromArray:messages];
        [HCMessage splitImageMessages:self.msgs];
        [HCMessage reorderMessages:self.msgs];
    }
}

- (NSDate *)lastMessageDate {
    if (!_lastMessageDate) {
        _lastMessageDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return _lastMessageDate;
}

- (NSInteger)unreadMessagesCount {
    @synchronized (self) {
        return _unreadMessagesCount;
    }
}

- (void)setUnreadMessagesCount:(NSInteger)unreadMessagesCount {
    @synchronized (self) {
        _unreadMessagesCount = unreadMessagesCount;
        [[NSUserDefaults standardUserDefaults] setInteger:unreadMessagesCount forKey:MESSAGE_UNREAD_COUNT_KEY_PATTERN([MaxLeap applicationId])];
    }
}

#pragma mark -
#pragma mark notification handlers

- (void)appWillResignActive:(NSNotification *)notification {
    [self checkNewMessageCountAndAlert:NO];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self checkNewMessageCountAndAlert:YES];
}

- (void)checkNewMessageCountAndAlert:(BOOL)alert {
    [self getNewMessageCountInBackgroundWithBlock:^(NSInteger msgCount) {
        if (alert && msgCount && self.shouldAlertNewMessage) {
            [self showNewMessageAlert];
        }
    }];
}

- (void)getNewMessageCountInBackgroundWithBlock:(void (^)(NSInteger))block {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self checkIssueWithBlock:^(NSArray *unreadMessages, NSError *error) {
            self.unreadMessagesCount += unreadMessages.count;
            if (block) block(self.unreadMessagesCount);
        }];
    });
}

- (void)didReceiveMemoryWarning {
    for (HCMessage *msg in self.msgs) {
        [msg clearMemoryCache];
    }
}

#pragma mark -
#pragma mark New message alert

- (void)showNewMessageAlert {
    if (self.unreadMessagesCount == 0) {
        return;
    }
    NSString *str = nil;
    if (self.unreadMessagesCount == 1) {
        str = [NSString stringWithFormat:HCLocalizedString(@"You have a new message.", nil)];
    } else {
        str = [NSString stringWithFormat:HCLocalizedString(@"You have %d new messages.", nil), self.unreadMessagesCount];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:HCLocalizedString(@"Cancel", nil) otherButtonTitles:HCLocalizedString(@"Check Out", nil), nil];
    [alertView show];
}

- (UIViewController*)topMostViewController {
    return [self parentmostViewControllerForContrller:[[[UIApplication sharedApplication] delegate] window].rootViewController];
}

- (UIViewController *)parentmostViewControllerForContrller:(UIViewController *)viewController {
    
    UIViewController *presentingViewController = viewController.view.window.rootViewController;
    while (presentingViewController.presentedViewController) {
        presentingViewController = presentingViewController.presentedViewController;
    }
    
    return presentingViewController;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[HCConversationViewController new]];
        [[self topMostViewController] presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark auto refresh message

- (void)startRefreshingMessages {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( ! self.autoRefreshTimer) {
            self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:MESSAGE_REFRESH_INTERVAL target:self selector:@selector(_autorefreshNewMessages) userInfo:nil repeats:YES];
            [self.autoRefreshTimer fire];
        }
    });
}


- (void)stopRefreshingMessages {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.autoRefreshTimer invalidate];
        self.autoRefreshTimer = nil;
    });
}


- (void)checkIssueWithBlock:(void (^)(NSArray *, NSError *))block {
    
    if (self.fetchingIssue) return;
    if (self.checkingIssue) return;
    
    self.checkingIssue = YES;
    
    if (!self.lastMessageDate) {
        self.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    [HCIssueClient getMessagesAfter:self.lastMessageDate block:^(HCIssue *issue, NSError *error) {
        NSArray *newMessages = nil;
        if (!error) {
            if ([issue.objectId isEqualToString:self.currentIssue.objectId]) {
                if (![issue.status isEqualToString:self.currentIssue.status]) {
                    self.currentIssue.status = issue.status;
                    [self saveCurrentIssue];
                    if (self.issueStautsChanged) {
                        self.issueStautsChanged(self.currentIssue.issueStatus);
                    }
                }
                if (issue.msgs.count) {
                    
                    self.currentIssue.msgs = [self.currentIssue.msgs arrayByAddingObjectsFromArray:issue.msgs];
                    [self saveCurrentIssue];
                    
                    NSMutableArray *msgsFromSelf = [NSMutableArray array];
                    [issue.msgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isFromSelf]) {
                            [msgsFromSelf addObject:obj];
                        }
                    }];
                    NSMutableArray *newMsgs = [issue.msgs mutableCopy];
                    [HCMessage reorderMessages:newMsgs];
                    self.lastMessageDate = [newMsgs.lastObject createdAt];
                    
                    [newMsgs removeObjectsInArray:msgsFromSelf];
                    
                    [HCMessage splitImageMessages:newMsgs];
                    [self.msgs addObjectsFromArray:newMsgs];
                    [HCMessage reorderMessages:self.msgs];
                    
                    newMessages = newMsgs;
                }
            }
        }
        if (block) {
            block(newMessages, error);
        }
        self.checkingIssue = NO;
    }];
}


- (void)_autorefreshNewMessages {
    
    if (!self.currentIssue) return;
    if (self.fetchingIssue) return;
    if (self.refreshing) return;
    if (self.currentIssue.issueStatus != HCIssueStatusCreated && self.currentIssue.issueStatus != HCIssueStatusInprogress) {
        return;
    }
    
    self.refreshing = YES;
    
    if (!self.lastMessageDate) {
        self.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    [self checkIssueWithBlock:^(NSArray *newMsgs, NSError *error) {
        if (newMsgs.count > 0 && self.newMessageBlock) {
            self.newMessageBlock(newMsgs);
        }
        self.refreshing = NO;
    }];
}

#pragma mark -
#pragma mark issue manager

- (void)loadIssueFromRemoteWithBlock:(MLBooleanResultBlock)block {
    self.fetchingIssue = YES;
    [HCIssueClient getCurrentIssueWithBlock:^(HCIssue *issue, NSError *error) {
        if (!error) {
            self.currentIssue = issue;
            if (issue) {
                [self saveCurrentIssue];
                if (issue.msgs) {
                    self.msgs = [issue.msgs mutableCopy];
                } else {
                    self.msgs = [NSMutableArray array];
                }
                
                [HCMessage reorderMessages:self.msgs];
                self.lastMessageDate = [self.msgs.lastObject createdAt];
                
                [self.msgs addObjectsFromArray:self.localMessages];
                [HCMessage splitImageMessages:self.msgs];
                [HCMessage reorderMessages:self.msgs];
            } else {
                [self deleteLocalCurrentIssue];
            }
        }
        if (block) {
            block(error == nil, error);
        }
        self.fetchingIssue = NO;
    }];
}

- (void)createIssueWithTitle:(NSString *)title
                    username:(NSString *)username
                       email:(NSString *)email
                       files:(NSArray *)files
                       block:(MLBooleanResultBlock)block
{
    HCIssue *issue = [HCIssue newIssueWithTitle:title userName:username userEmail:email files:files];
    [HCIssueClient createIssue:issue block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.currentIssue = issue;
            [self saveCurrentIssue];
        }
        if (block) {
            block(succeeded, error);
        }
    }];
}

- (void)closeCurrentIssue:(MLBooleanResultBlock)block {
    self.currentIssue.status = [@(HCIssueStatusCloseByAppUser) stringValue];
    [self saveCurrentIssue];
    [HCIssueClient closeIssue:self.currentIssue block:^(BOOL succeeded, NSError *error) {
        if (block) {
            block(succeeded, error);
        }
    }];
}
- (void)reopenCurrentIssue:(MLBooleanResultBlock)block {
    self.currentIssue.status = [@(HCIssueStatusInprogress) stringValue];
    [self saveCurrentIssue];
    [HCIssueClient reopenIssue:self.currentIssue block:block];
}

- (void)saveCurrentIssue {
    if (self.currentIssue) {
        NSString *path = [[HCIssue issuePath] stringByAppendingPathComponent:@"currentIssue"];
        NSDictionary *dict = [self.currentIssue toDictionary];
        if (dict) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
            [data writeToFile:path atomically:YES];
        }
    }
}

- (void)deleteLocalCurrentIssue {
    NSString *path = [[HCIssue issuePath] stringByAppendingPathComponent:@"currentIssue"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    self.currentIssue = nil;
    self.msgs = [NSMutableArray array];
    self.localMessages = [NSMutableArray array];
}

#pragma mark -
#pragma mark Messages Manager

- (void)setIssueStautsChangedBlock:(void (^)(HCIssueStatus))block {
    self.issueStautsChanged = block;
}

- (NSArray *)messages {
    return [self.msgs copy];
}

- (NSArray *)messagesAfter:(NSDate *)date {
    __block NSArray *array = nil;
    NSArray *msgs = [self.msgs copy];
    [msgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj createdAt] compare:date] != NSOrderedAscending) {
            array = [msgs subarrayWithRange:NSMakeRange(idx, msgs.count - idx)];
            *stop = YES;
        }
    }];
    return array;
}

- (void)sendMessage:(HCMessage *)message completion:(MLBooleanResultBlock)completion {
    [self insertMessage:message];
    [message uploadData:^(BOOL succeeded, NSError *error) {
        if (error) {
            [[HCIssueDB sharedDB] updateMessage:message];
        } else {
            [[HCIssueDB sharedDB] deleteMessage:message];
            [self.localMessages removeObject:message];
            self.currentIssue.msgs = [self.currentIssue.msgs arrayByAddingObject:message];
            [self saveCurrentIssue];
        }
        if (completion) {
            completion(succeeded, error);
        }
    }];
}

- (void)resendFailedMessage:(HCMessage *)message completion:(MLBooleanResultBlock)completion {
    if (message.dataStatus != HCMessageStatusUploadFailed) {
        return;
    }
    
    [self deleteMessage:message];
    message.dataStatus = HCMessageStatusShouldUpload;
    message.createdAt = [NSDate date];
    [self sendMessage:message completion:completion];
}

- (void)insertMessage:(HCMessage *)message {
#ifndef DEBUG
    if (!message) {
        return;
    }
#endif
    [self.msgs addObject:message];
    [self.localMessages addObject:message];
    [[HCIssueDB sharedDB] insertMessage:message];
    
    if (self.newMessageBlock) {
        self.newMessageBlock(@[message]);
    }
}

- (void)deleteMessage:(HCMessage *)message {
#ifndef DEBUG
    if (!message) {
        return;
    }
#endif
    [self.msgs removeObject:message];
    [self.localMessages removeObject:message];
    [[HCIssueDB sharedDB] deleteMessage:message];
}

- (void)updateMessage:(HCMessage *)message {
#ifndef DEBUG
    if (!message) {
        return;
    }
#endif
    [[HCIssueDB sharedDB] updateMessage:message];
}

@end
