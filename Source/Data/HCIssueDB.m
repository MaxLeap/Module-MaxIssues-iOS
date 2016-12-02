//
//  HCIssueDBManager.m
//  MaxLeap
//

#import "HCIssueDB.h"
#import "MLSQLiteManager.h"
#import <MaxLeap/MaxLeap.h>

@interface MLFile ()
+ (instancetype)fileWithName:(NSString *)name url:(NSString *)url;
@end

#define GCD_IS_CURRENT (dispatch_get_specific(&syncQueueID) ==  &syncQueueID)
static int syncQueueID = 1000;

@interface HCIssueDB ()
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation HCIssueDB

+ (instancetype)sharedDB {
    static HCIssueDB *__shareddb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__shareddb) {
            __shareddb = [[HCIssueDB alloc] init];
        }
    });
    return __shareddb;
}

- (instancetype)init {
    if (self = [super init]) {
        self.syncQueue = dispatch_queue_create("com.maxleap.helpcenter.issue.db.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(self.syncQueue, &syncQueueID, &syncQueueID, NULL);
        
        [self loadDB];
    }
    return self;
}

- (void)runSynchronously:(dispatch_block_t)block {
    if (GCD_IS_CURRENT) {
        block();
    } else {
        dispatch_sync(self.syncQueue, block);
    }
}

- (void)runAsynchronously:(dispatch_block_t)block {
    dispatch_async(self.syncQueue, block);
}

- (NSString *)dbPath {
    return [[HCIssue issuePath] stringByAppendingPathComponent:@"issues.db"];
}

- (void)loadDB {
    [self runAsynchronously:^{
        self.dbManager = [[MLSQLiteManager alloc] initWithDatabaseNamed:[self dbPath]];
        [self.dbManager doUpdateQuery:
         @"CREATE TABLE IF NOT EXISTS messages ( \
         'localId' TEXT NOT NULL PRIMARY KEY UNIQUE, \
         'content' TEXT, \
         'attach' TEXT, \
         'cacheName' TEXT, \
         'authorInfo' TEXT NOT NULL, \
         'issueId' TEXT NOT NULL, \
         'createdAt' REAL, \
         'appId' TEXT, \
         'dataStatus' INTEGER, \
         'reachStatus' INTEGER);" withParams:nil];
        
        [self.dbManager doUpdateQuery:@"PRAGMA journal_mode = WAL;"
                           withParams:nil];
    }];
}

- (HCMessage *)messageWithLocalId:(NSString *)localId {
    if (!localId) {
        return nil;
    }
    NSString *appId = [MaxLeap applicationId];
    NSString *sql = @"SELECT * FROM messages WHERE localId=? AND appId=?";
    NSArray *params = @[localId, appId];
    return [self messageWithSql:sql params:params];
}

- (HCMessage *)messageFromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    HCMessage *msg = [[HCMessage alloc] init];
    msg.localId = dict[@"localId"];
    msg.issueId = dict[@"issueId"];
    msg.dataStatus = (HCMessageStatus)[dict[@"dataStatus"] integerValue];
    msg.reachStatus = (HCMessageReachStatus)[dict[@"reachStatus"] integerValue];
    
    if (dict[@"cacheName"] != [NSNull null]) msg.filePath = [HCMessage cachePathWithFilename:dict[@"cacheName"]];
    if (dict[@"content"] != [NSNull null])  msg.content = dict[@"content"];
    if (dict[@"attach"] != [NSNull null])   msg.attach = [dict[@"attach"] componentsSeparatedByString:@" | "];
    if (dict[@"authorInfo"] != [NSNull null]) {
        NSString *authorInfo = dict[@"authorInfo"];
        NSData *data = [authorInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        msg.authorInfo = info;
    }
    if (dict[@"createdAt"] != [NSNull null]) {
        msg.createdAt = [NSDate dateWithTimeIntervalSince1970:[dict[@"createdAt"] doubleValue]];
    }
    
    if (msg.attach.count) {
        msg.imageFile = [MLFile fileWithName:nil url:msg.attach.firstObject];
    } else if (msg.filePath) {
        msg.imageFile = [MLFile fileWithName:@"image.jpg" contentsAtPath:msg.filePath];
    }
    
    return msg;
}

- (HCMessage *)messageWithSql:(NSString *)sql params:(NSArray *)params {
    __block HCMessage *msg = nil;
    [self runSynchronously:^{
        NSArray *results = [self.dbManager getRowsForQuery:sql withParams:params];
        msg = [self messageFromDictionary:results.firstObject];
    }];
    return msg;
}

- (NSArray *)loadMessagesWithIssueId:(NSString *)issueId {
    if (!issueId) {
        return nil;
    }
    __block NSArray *msgs = nil;
    [self runSynchronously:^{
        NSString *sql = @"SELECT * FROM messages WHERE issueId=? ORDER BY createdAt ASC";
        NSArray *results = [self.dbManager getRowsForQuery:sql withParams:@[issueId]];
        NSMutableArray *messages = [NSMutableArray array];
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            HCMessage *msg = [self messageFromDictionary:obj];
            [messages addObject:msg];
        }];
        msgs = messages;
    }];
    return msgs;
}

- (void)insertMessage:(HCMessage *)message {
    if (!message) {
        return;
    }
    [self runAsynchronously:^{
        NSString *sql = @"INSERT OR IGNORE INTO messages (localId, content, attach, cacheName, authorInfo, issueId, createdAt, appId, dataStatus, reachStatus) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        NSString *attach = message.attach.count > 0 ? [message.attach componentsJoinedByString:@" | "] : nil;
        NSString *authorInfo = @"{}";
        if (message.authorInfo) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:message.authorInfo options:kNilOptions error:NULL];
            authorInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        NSArray *params = @[message.localId,
                            message.content?:[NSNull null],
                            attach?:[NSNull null],
                            message.filePath.lastPathComponent?:[NSNull null],
                            authorInfo,
                            message.issueId,
                            message.createdAt?:[NSNull null],
                            message.appId?:[NSNull null],
                            @(message.dataStatus),
                            @(message.reachStatus)];
        [self.dbManager doUpdateQuery:sql withParams:params];
    }];
}

- (void)updateMessage:(HCMessage *)message {
    if (!message) {
        return;
    }
    [self runAsynchronously:^{
        NSString *attach = message.attach.count > 0 ? [message.attach componentsJoinedByString:@" | "] : nil;
        NSString *sql = @"UPDATE OR IGNORE messages SET content=?, attach=?, cacheName=?, createdAt=?, dataStatus=?, reachStatus=? WHERE localId=?";
        NSArray *params = @[message.content?:[NSNull null],
                            attach?:[NSNull null],
                            message.filePath.lastPathComponent?:[NSNull null],
                            message.createdAt?:[NSNull null],
                            @(message.dataStatus),
                            @(message.reachStatus),
                            message.localId
                            ];
        [self.dbManager doUpdateQuery:sql withParams:params];
    }];
}

- (void)deleteMessage:(HCMessage *)message {
    if (!message.localId) {
        return;
    }
    [self runAsynchronously:^{
        NSString *sql = @"DELETE FROM messages WHERE localId=?";
        [self.dbManager doUpdateQuery:sql withParams:@[message.localId]];
    }];
}

@end
