//
//  HCImageHelper.m
//  MaxLeap
//

#import "MLIssuesImageHelper.h"
#import "MLLogging.h"

static NSMutableArray *_bundlePaths = nil;
static NSBundle *_preferedBundle = nil;

@implementation MLIssuesImageHelper

+ (void)registerBundleWithPath:(NSString *)bundlePath {
    if (bundlePath.length == 0) {
        return;
    }
    if (!_bundlePaths) {
        _bundlePaths = [NSMutableArray arrayWithCapacity:1];
    }
    [_bundlePaths removeObject:bundlePath];
    [_bundlePaths addObject:bundlePath];
    
    [self setupPreferedBundle];
}

+ (void)setupPreferedBundle {
    NSString *relativePath = [_bundlePaths lastObject];
    NSURL *mUrl = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
    NSURL *url = [NSURL URLWithString:relativePath relativeToURL:mUrl];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    if (bundle) {
        _preferedBundle = bundle;
    } else {
        MLLogInfoF(@"Cannot initialize bundle with path %@, HelpCenter will use previous %@.", relativePath, _preferedBundle.bundlePath.lastPathComponent);
    }
}

+ (UIImage *)imageNamed:(NSString *)name {
    UIImage *img = nil;
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        img = [UIImage imageNamed:name inBundle:_preferedBundle compatibleWithTraitCollection:nil];
    } else {
        NSBundle *bundle = _preferedBundle?:[NSBundle mainBundle];
        return [self findImageNamed:name inBundle:bundle];
    }
    if (!img && name) {
        MLLogInfoF(@"Image named '%@' not found", name);
    }
    return img;
}

+ (UIImage *)findImageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    
    if (name.length == 0) {
        return nil;
    }
    
    NSString *ext = [name pathExtension];
    if (ext.length == 0) {
        ext = @"png";
    }
    name = [name stringByDeletingPathExtension];
    
    
    UIImage *img = nil;
    
    NSString *x2 = @"@2x",
    *x3 = @"@3x",
    *iPad = @"~ipad";
    
    if ( ! ( [name hasSuffix:x2] || [name hasSuffix:x3] || [name hasSuffix:iPad] ) )
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            for (int i = (int)scale; i > 0; i --) {
                NSString *fixedName = name;
                NSString *sufix = iPad;
                if (i != 1) {
                    fixedName = [NSString stringWithFormat:@"@%dx~ipad", i];
                } else {
                    fixedName = [name stringByAppendingString:sufix];
                }
                NSString *imagePath = [bundle pathForResource:fixedName ofType:ext];
                img = [UIImage imageWithContentsOfFile:imagePath];
                if (img) {
                    break;
                }
            }
        }
        
        if (!img) {
            for (int i = (int)scale; i > 0; i --) {
                NSString *fixedName = name;
                if (i != 1) {
                    NSString *sufix = [NSString stringWithFormat:@"@%dx", i];
                    fixedName = [name stringByAppendingString:sufix];
                }
                NSString *imagePath = [bundle pathForResource:fixedName ofType:ext];
                img = [UIImage imageWithContentsOfFile:imagePath];
                if (img) {
                    break;
                }
            }
        }
        
    } else {
        NSString *imagePath = [bundle pathForResource:name ofType:ext];
        img = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return img;
}

@end
