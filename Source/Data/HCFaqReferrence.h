//
//  HCFaqReferrence.h
//  MaxLeap
//

#import <Foundation/Foundation.h>

@interface HCFaqReferrence : NSObject

@property (nonatomic, readonly) NSString *schema;
@property (nonatomic, strong) NSString *faqId;
@property (nonatomic, strong) NSString *langcode;
@property (nonatomic, strong) NSString *title;

+ (instancetype)referrenceFromString:(NSString *)string;
- (NSString *)stringValue;

+ (NSString *)schema;

@end
