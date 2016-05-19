//
//  ViewDelegates.h
//  MaxLeap
//

#define ACTION_SEND_PHOTO 2000
#define ACTION_ATTACH_PHOTO 2005
#define ACTION_SEND_MSG 2001
#define ACTION_CANCEL_NOT_YET 2002
#define ACTION_REOPEN 2003

@protocol HCViewDelegate <NSObject>

@optional

- (void)performAction:(NSInteger)action;

@end




@protocol HCMsgInputViewDelegate <HCViewDelegate>

@optional

- (void)msgInputViewWillChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration;

@end
