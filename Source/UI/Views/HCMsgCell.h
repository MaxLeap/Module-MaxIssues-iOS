//
//  HCMsgCell.h
//  MaxLeap
//

#import "HCMessage.h"

@protocol HCMsgCell <NSObject>

@property (nonatomic, strong) HCMessage *message;

@optional

+ (CGFloat)heightOfMessage:(HCMessage *)message;

@end
