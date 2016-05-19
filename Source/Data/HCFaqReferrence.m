//
//  HCFaqReferrence.m
//  MaxLeap
//

#import "HCFaqReferrence.h"

@interface HCFaqReferrence ()
@property (nonatomic, strong) NSURL *url;
@end

@implementation HCFaqReferrence

+ (instancetype)referrenceFromString:(NSString *)string {
    HCFaqReferrence *r = [[HCFaqReferrence alloc] initWithString:string];
    return r;
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:string];
        if ([url.scheme isEqualToString:self.schema]) {
            self.url = url;
            self.faqId = url.host;
            NSArray *pathComponents = [url pathComponents];
            self.langcode = pathComponents[1];
            self.title = pathComponents[2];
        } else {
            return nil;
        }
    }
    return self;
}

+ (NSString *)schema {
    return @"lasfaq";
}

- (NSString *)schema {
    return [[self class] schema];
}

- (NSString *)stringValue {
    return [self.url absoluteString];
}

@end
