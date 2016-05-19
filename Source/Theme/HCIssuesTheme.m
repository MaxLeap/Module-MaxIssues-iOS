//
//  HCTheme.m
//  MaxLeap
//


#import "MLIssuesImageHelper.h"
#import "HCIssuesTheme.h"
#import "MLLogging.h"
#import "HEXRGBColor.h"
#import "MLAssert.h"

#define DEFAULT_IMAGE_BUNDLE @"MLIssuesImages.bundle"

@interface HCNavigationBarAttributes ()
@property (nonatomic, strong) NSString *shadowImageName;                // Bar shadow image name (iOS 6)
@property (nonatomic, strong) NSString *backgroundImageName;            // Background image (iOS 6)
@property (nonatomic, strong) NSString *backgroundImageLangscapeName;   // Background image landscape (iOS 6)

@property (nonatomic, strong) NSString *contactUsImageName;             // Contact us button image
@property (nonatomic, strong) NSString *contactUsImageHighlightedName;  // Contact us button image highlighted
@end

@implementation HCNavigationBarAttributes

- (instancetype)init {
    if (self = [super init]) {
        self.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
        self.titleColor = [UIColor whiteColor];
        self.titleShadowOffset = CGSizeZero;
        self.backgroundColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:235/255.f alpha:1.00f];
        self.buttonTextColor = [UIColor whiteColor];
        self.buttonTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        NSString *fontName = dictionary[@"Title font name"];
        if (fontName) {
            CGFloat fontSize = [dictionary[@"Title font size"] doubleValue];
            UIFont *font = [UIFont fontWithName:fontName size:fontSize];
            if (font) {
                self.titleFont = font;
            } else {
                MLLogInfoF(@"cannot find font with name '%@'", fontName);
            }
        }
        self.titleColor = UIColorFromHEXString(dictionary[@"Title color"])?:self.titleColor;
        self.titleShadowColor = UIColorFromHEXString(dictionary[@"Title shadow color (iOS 6)"])?:self.titleShadowColor;
        self.titleShadowOffset = CGSizeFromString(dictionary[@"Title shadow offset (iOS 6)"]);
        self.backgroundColor = UIColorFromHEXString(dictionary[@"Background color"])?:self.backgroundColor;
        self.backgroundImageName = dictionary[@"Background image (iOS 6)"];
        self.backgroundImageLangscapeName = dictionary[@"Background image landscape (iOS 6)"];
        self.buttonTextColor = UIColorFromHEXString(dictionary[@"Bar button text color"])?:self.buttonTextColor;
        
        NSString *btnTextFontName = dictionary[@"Bar button font name"];
        if (btnTextFontName.length > 0) {
            CGFloat btnTextFontSize = [dictionary[@"Bar button font size"] doubleValue];
            UIFont *font = [UIFont fontWithName:btnTextFontName size:btnTextFontSize];
            if (font) {
                self.buttonTextFont = font;
            } else {
                MLLogInfoF(@"cannot find font with name '%@'", btnTextFontName);
            }
        }
        
        self.contactUsImageName = dictionary[@"Contact us button image"];
        self.contactUsImageHighlightedName = dictionary[@"Contact us button image highlighted"];
    }
    return self;
}

- (UIImage *)backgroundImage {
    return HCImageNamed(self.backgroundImageName);
}

- (UIImage *)backgroundImageLangscape {
    return HCImageNamed(self.backgroundImageLangscapeName);
}

- (UIImage *)shadowImage {
    return HCImageNamed(self.shadowImageName)?:[UIImage new];
}

- (UIImage *)contactUsImage {
    return HCImageNamed(self.contactUsImageName);
}

- (UIImage *)contactUsImageHighlighted {
    return HCImageNamed(self.contactUsImageHighlightedName);
}

@end

#pragma mark -

@interface HCNewConversationViewAttributes ()
@property (nonatomic, strong) NSString *titleImageName;
@end

@implementation HCNewConversationViewAttributes

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        self.titleImageName = dictionary[@"Title image"];
    }
    return self;
}

- (UIImage *)titleImage {
    return HCImageNamed(self.titleImageName);
}

@end

#pragma mark -

@interface HCConversationViewAttributes ()
@property (nonatomic, strong) NSString *titleImageName;
@end

@implementation HCConversationViewAttributes

- (instancetype)init {
    if (self = [super init]) {
        self.messageTextFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.messageTextColorLeft = [UIColor colorWithRed:74/255.f green:74/255.f blue:74/255.f alpha:1];
        self.messageTextColorRight = [UIColor whiteColor];
        
        BOOL ios7OrLater = [[UIDevice currentDevice].systemVersion compare:@"7.0"] != NSOrderedAscending;
        if (ios7OrLater) {
            self.dateTextFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:9];
        } else {
            self.dateTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        }
        self.dateTextColor = [UIColor colorWithRed:151/255.f green:151/255.f blue:151/255.f alpha:1.f];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        NSString *fontName = dictionary[@"Message text font name"];
        if (fontName) {
            CGFloat fontSize = [dictionary[@"Message text font size"] doubleValue];
            UIFont *font = [UIFont fontWithName:fontName size:fontSize];
            if (font) {
                self.messageTextFont = font;
            } else {
                MLLogInfoF(@"cannot find font with name '%@'", fontName);
            }
        }
        self.messageTextColorLeft = UIColorFromHEXString(dictionary[@"Message text color left"])?:self.messageTextColorLeft;
        self.messageTextColorRight = UIColorFromHEXString(dictionary[@"Message text color right"])?:self.messageTextColorRight;
        self.titleImageName = dictionary[@"Title image"];
        
        NSString *dateTextFontName = dictionary[@"Date text font name"];
        if (dateTextFontName) {
            CGFloat dateFontSize = [dictionary[@"Date text font size"] doubleValue];
            UIFont *font = [UIFont fontWithName:dateTextFontName size:dateFontSize];
            if (font) {
                self.dateTextFont = font;
            } else {
                MLLogInfoF(@"cannot find font with name '%@'", dateTextFontName);
            }
        }
        self.dateTextColor = UIColorFromHEXString(dictionary[@"Date text color"])?:self.dateTextColor;
    }
    return self;
}

- (UIImage *)titleImage {
    return HCImageNamed(self.titleImageName);
}

@end

#pragma mark -

@implementation HCIssuesTheme

+ (instancetype)currentTheme {
    static HCIssuesTheme *_currentTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MLIssuesThemes" ofType:@"bundle"];
        NSString *path = [bundlePath stringByAppendingPathComponent:@"Default.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        MLConsistencyAssert(dict.count > 0, @"Invalid file in path `main_bundle/MLIssuesThemes.bundle/Default.plist`");
        _currentTheme = [[HCIssuesTheme alloc] initWithConfig:dict];
    });
    return _currentTheme;
}

- (instancetype)init {
    if (self = [super init]) {
        [self applyDefaultConfigs];
    }
    return self;
}

- (instancetype)initWithConfig:(NSDictionary *)config {
    if (self = [self init]) {
        NSDictionary *dict = [self dictionaryByRemovingEmptyValues:config];
        [self applyConfig:dict];
    }
    return self;
}

- (NSDictionary *)dictionaryByRemovingEmptyValues:(NSDictionary *)config {
    if (!config) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [config enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([(NSString *)obj length] > 0) {
                result[key] = obj;
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            result[key] = [self dictionaryByRemovingEmptyValues:obj];
        } else {
            result[key] = obj;
        }
    }];
    return result;
}

- (void)applyDefaultConfigs {
    [MLIssuesImageHelper registerBundleWithPath:DEFAULT_IMAGE_BUNDLE];
    _navigationBarAttributes = [[HCNavigationBarAttributes alloc] init];
    _conversationViewAttr = [HCConversationViewAttributes new];
}

- (void)applyConfig:(NSDictionary *)config {
    if (!config) return;
    
    NSString *imgBundleName = config[@"Image bundle name"];
    if (imgBundleName.length > 0) {
        if (NO == [imgBundleName hasSuffix:@".bundle"]) {
            imgBundleName = [imgBundleName stringByAppendingPathExtension:@"bundle"];
        }
        [MLIssuesImageHelper registerBundleWithPath:imgBundleName];
    }
    
    _navigationBarAttributes = [[HCNavigationBarAttributes alloc] initWithDictionary:config[@"Navigation Bar"]];
    _conversationCreateViewAttr = [[HCNewConversationViewAttributes alloc] initWithDictionary:config[@"New conversation view"]];
    _conversationViewAttr = [[HCConversationViewAttributes alloc] initWithDictionary:config[@"Conversation view"]];
}

@end
