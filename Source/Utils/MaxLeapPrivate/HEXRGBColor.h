//
//  HEXRGBColor.h
//  MaxLeap
//

#ifndef ML_HEXRGBColor_h
#define ML_HEXRGBColor_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//RGB color macro with alpha
#define UIColorFromHEXRGBWithAlpha(hexValue,a) \
        [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
                        green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
                         blue:((float)(hexValue & 0xFF))/255.0 alpha:a]

//RGB color macro
#define UIColorFromHEXRGB(hexValue) UIColorFromHEXRGBWithAlpha(hexValue, 1.0)

static inline UIColor * ml_color_from_hex_string(NSString *hexString) {
    if (hexString.length < 6) {
        return nil;
    }
    unsigned hexValue = 0;
    NSString *noHashString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    if ([scanner scanHexInt:&hexValue]) {
        return UIColorFromHEXRGB(hexValue);
    } else {
        return nil;
    }
}

#define UIColorFromHEXString(hexString) ml_color_from_hex_string(hexString)

#endif
