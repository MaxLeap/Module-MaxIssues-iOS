//
//  MLFaqItemViewController.m
//  MaxLeap
//

#import "HCISFaqItemViewController.h"
#import "HCIssuesTheme.h"
#import "HCLocalizable.h"
#import <MaxLeap/MLQuery.h>
#import "MLRequest.h"
#import "MLDevice.h"

@interface HCISFaqItemViewController () <UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *webView;
@end

@implementation HCISFaqItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *titleImage = [HCIssuesTheme currentTheme].itemContentAttr.titleImage;
    if (titleImage) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    } else {
        self.title = HCLocalizedString(@"Question", nil);
    }
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    if (self.faqItem) {
        [self displayFaqItem];
    } else {
        [self loadFaqItem];
    }
}

- (void)loadFaqItem {
    
    [self startActivity];
    
    MLRequest *request = [MLRequest new];
    request.method = MLConnectMethodPost;
    request.path = @"/help/faq/item/find";
    request.body = @{@"where":@{@"objectId":self.faqItemId},
                     @"langCode":[MLDevice currentDevice].preferredLanguageId,
                     @"platform": @"0"};
    [request sendWithCompletion:^(id object, NSError *error) {
        if (error) {
            [self showError:HCLocalizedString(@"failed to get faq item content", nil)];
        } else {
            self.faqItem = object;
            if (object) {
                
            } else {
                // no item, should not occurr
            }
            [self displayFaqItem];
            [self stopActivity];
        }
    }];
}

- (void)displayFaqItem {
    
    NSString *template = @"<!doctype html>\n<html>\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=100%, user-scalable=yes, minimum-scale=1.0, initial-scale=1.0\">\n<title>%@</title>\n<style type=\"text/css\">\n#faq {\n  padding-top: 0px;\n  padding-left: 14px;\n  padding-right: 14px;\n  padding-bottom: 15px;\n}\n#faqcontent {\n  font-family:\"Helvetica Neue Light\";\n  font-size: 11pt;\n  color:#4a4a4a;\n}\np {\n  word-break: normal;\n}\n</style>\n</head>\n\n<body>\n<div id=\"faq\">\n<div id=\"faqtitle\">\n<p style=\"font-family:\'Helvetica Neue\'; font-size:18px; color:#4a4a4a; -webkit-margin-before:30px; -webkit-margin-after:17px\">%@</p>\n</div>\n<div id=\"faqcontent\">\n%@\n</div>\n</div>\n</body>\n</html>\n";
    NSString *html = [NSString stringWithFormat:template, self.faqItem[@"title"]?:HCLocalizedString(@"FAQ", nil), self.faqItem[@"title"]?:HCLocalizedString(@"This FAQ does not exit.", nil), self.faqItem[@"content"]?:@""];
    [self.webView loadHTMLString:html baseURL:nil];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showError:HCLocalizedString(@"failed to display faq item content", nil)];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
