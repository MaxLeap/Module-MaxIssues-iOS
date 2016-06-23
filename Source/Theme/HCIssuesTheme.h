//
//  HCTheme.h
//  MaxLeap
//

#import <Foundation/Foundation.h>

@interface HCNavigationBarAttributes : NSObject

@property (nonatomic, strong) UIFont *titleFont;            // Title font name + Title font size
@property (nonatomic, strong) UIColor *titleColor;          // Title color
@property (nonatomic, strong) UIColor *backgroundColor;     // Background color

@property (nonatomic) UIBarStyle barStyle; // Status Bar Style

@property (nonatomic, strong) UIColor *buttonTextColor;     // Bar button text color
//@property (nonatomic, strong) UIColor *buttonTextColorHighlited;// Bar button text color
@property (nonatomic, strong) UIFont *buttonTextFont;       // Bar button font name + Bar button font size

@property (nonatomic, strong) UIImage *contactUsImage;      // Contact us button image
@property (nonatomic, strong) UIImage *contactUsImageHighlighted;// Contact us button image highlighted

@end

@interface MLISFaqItemContentViewAttributes : NSObject
@property (nonatomic, strong) UIImage *titleImage;          // Title image
@end

@interface HCNewConversationViewAttributes : NSObject
@property (nonatomic, strong) UIImage *titleImage;          // Title image
@end

@interface HCConversationViewAttributes : NSObject
@property (nonatomic, strong) UIImage *titleImage;          // Title image
@property (nonatomic, strong) UIFont *messageTextFont;      // Message text font name + Message text font size
@property (nonatomic, strong) UIColor *messageTextColorLeft; // Message text color left
@property (nonatomic, strong) UIColor *messageTextColorRight;// Message text color right
@property (nonatomic, strong) UIFont *dateTextFont;         // Date text font name + Date text font size
@property (nonatomic, strong) UIColor *dateTextColor;       // Date text color
@end

@interface HCIssuesTheme : NSObject

+ (instancetype)currentTheme;

@property (nonatomic, strong, readonly) HCNavigationBarAttributes *navigationBarAttributes;
@property (nonatomic, strong, readonly) MLISFaqItemContentViewAttributes *itemContentAttr;
@property (nonatomic, strong, readonly) HCNewConversationViewAttributes *conversationCreateViewAttr;
@property (nonatomic, strong, readonly) HCConversationViewAttributes *conversationViewAttr;

@end
