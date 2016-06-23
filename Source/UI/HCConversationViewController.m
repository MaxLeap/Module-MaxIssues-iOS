//
//  MLConversationViewController.m
//  MaxLeap
//

#import "HCConversationViewController.h"
#import "HCMsgInputView.h"
#import "HCIssueManager.h"
#import "HCNewIssueView.h"
#import "HCHorizonalDialog.h"
#import "HCRightTextCell.h"
#import "HCLeftTextCell.h"
#import "HCRightImageCell.h"
#import "HCLeftImageCell.h"
#import "HCImagePickerController.h"
#import "HCISFaqItemViewController.h"
#import "HCImageViewController.h"
#import "HCiTunesSearchAPIService.h"
#import <StoreKit/StoreKit.h>
#import "HCLocalizable.h"
#import "HCIssuesTheme.h"
#import <MaxLeap/MLFile.h>

@interface HCConversationViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
HCMsgInputViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate,
HCTextCellDelegate,
HCImageCellDelegate,
UIActionSheetDelegate,
SKStoreProductViewControllerDelegate
>

@property (nonatomic) BOOL messageLoaded;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) CGFloat tableViewBottomOffset;

@property (nonatomic, strong) HCMsgInputView *inputView;
@property (nonatomic, strong) HCNewIssueView *issueView;
@property (nonatomic, strong) HCHorizonalDialog *reopenDialog;
@property (nonatomic, strong) HCHorizonalDialog *resolveDialog;

@property (nonatomic, strong) HCMessage *messageToRetry;

@property (nonatomic) BOOL isViewDidAppear;

@property (nonatomic) CGRect keyboardEndFrame;
@property (nonatomic) NSTimeInterval keyboardAnimationDuration;

@end

@implementation HCConversationViewController

#pragma mark -
#pragma mark view life-cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    // setup message tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    MLLogDebugF(@"view did load");
    
    
    [self configIssueManager];
}

- (void)dealloc {
    [[HCIssueManager sharedManager] setNewMessageBlock:nil];
    [[HCIssueManager sharedManager] setIssueStautsChangedBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    MLLogDebugF(@"view will appear");
    [super viewWillAppear:animated];
    
    // register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[HCIssueManager sharedManager] startRefreshingMessages];
    [HCIssueManager sharedManager].unreadMessagesCount = 0;
    
    if ( ! self.issueView.isEditing) {
        [self.issueView beginEditing];
    }
    
    MLLogDebugF(@"view did appear");
    self.isViewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    MLLogDebugF(@"view will disappear");
    self.isViewDidAppear = NO;
    [super viewWillDisappear:animated];
    
    [[HCIssueManager sharedManager] stopRefreshingMessages];
    [self.view endEditing:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ( ! self.messageLoaded) {
        [self scrollMessageTableToBottomAnimated:NO];
    }
    self.messageLoaded = YES;
}

#pragma mark -
#pragma mark Keyboard Events

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    if (!self.view.window) {
        return;
    }
    
    [self refreshKeyboardInfoFromNotification:notification];
    [self layoutViewsAfterKeyboardChange];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    
    if (!self.view.window) {
        return;
    }
    
    [self refreshKeyboardInfoFromNotification:notification];
    [self layoutViewsAfterKeyboardChange];
}

- (void)refreshKeyboardInfoFromNotification:(NSNotification *)notification {
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    BOOL _is7_0OrEarlier = [[UIDevice currentDevice].systemVersion compare:@"8.0"] == NSOrderedAscending;
    if (_is7_0OrEarlier) { // < 8.0
        CGSize windowSize = self.view.window.frame.size;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
        if (isLandscape) {
            CGFloat keyboardWidth = endFrame.size.height;
            CGFloat keyboardHeight = endFrame.size.width;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                self.keyboardEndFrame = CGRectMake(endFrame.origin.y, endFrame.origin.x, keyboardWidth, keyboardHeight);
            } else {
                CGFloat keyboardY = endFrame.origin.x/*这个是 keyboard.frame.y*/ == 0 ? windowSize.width - keyboardHeight : windowSize.width;
                self.keyboardEndFrame = CGRectMake(windowSize.height - endFrame.origin.y - keyboardWidth,
                                                   keyboardY,
                                                   keyboardWidth, keyboardHeight);
            }
        } else {
            endFrame.origin.y = endFrame.origin.y == 0 ? windowSize.height - endFrame.size.height : endFrame.origin.y;
            self.keyboardEndFrame = endFrame;
        }
    } else {
        self.keyboardEndFrame = endFrame;
    }
    MLLogDebugF(@"keyboard end frame = %@", NSStringFromCGRect(self.keyboardEndFrame));
    self.keyboardAnimationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (CGRect)frameOnScreenOfView:(UIView *)view {
    CGRect issueViewFrame = view.frame;
    CGRect endFrame = [view.window convertRect:issueViewFrame fromView:self.view];
    BOOL _is7_0OrEarlier = [[UIDevice currentDevice].systemVersion compare:@"8.0"] == NSOrderedAscending;
    if (_is7_0OrEarlier) {
        CGSize windowSize = view.window.frame.size;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
        if (isLandscape) {
            CGFloat ivWidth = endFrame.size.height;
            CGFloat ivHeight = endFrame.size.width;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                endFrame = CGRectMake(endFrame.origin.y, endFrame.origin.x, ivWidth, ivHeight);
            } else {
                endFrame = CGRectMake(windowSize.height - endFrame.origin.y - ivWidth,
                                                    windowSize.width - endFrame.origin.x - ivHeight, ivWidth, ivHeight);
            }
        } else if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            endFrame.origin.x = windowSize.width - endFrame.origin.x - endFrame.size.width;
            endFrame.origin.y = windowSize.height - endFrame.origin.y - endFrame.size.height;
        }
    }
    return endFrame;
}

- (void)layoutViewsAfterKeyboardChange {
    CGRect endFrame = self.keyboardEndFrame;
    NSTimeInterval duration = self.keyboardAnimationDuration;
    if (self.issueView) {
        CGRect issueViewFrame = self.issueView.frame;
        CGRect issueViewFrameOnScreen = [self frameOnScreenOfView:self.issueView];
        issueViewFrame.size.height = MIN(self.issueView.superview.frame.size.height, endFrame.origin.y - issueViewFrameOnScreen.origin.y);
        [UIView animateWithDuration:duration animations:^{
            self.issueView.frame = issueViewFrame;
        }];
    } else if (self.inputView) {
        
        CGRect inputViewFrame = self.inputView.frame;
        CGRect inputViewFrameOnScreen = [self frameOnScreenOfView:self.inputView];
        CGFloat d = (endFrame.origin.y - inputViewFrameOnScreen.size.height) - inputViewFrameOnScreen.origin.y;
        inputViewFrame.origin.y += d;
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = inputViewFrame.origin.y - tableFrame.origin.y;
        
        self.tableViewBottomOffset = self.tableView.contentOffset.y + MIN(self.tableView.frame.size.height - self.tableView.contentInset.top, self.tableView.contentSize.height);
        
        [UIView animateWithDuration:duration animations:^{
            self.inputView.frame = inputViewFrame;
            self.tableView.frame = tableFrame;
            [self keepMessageTableBottomOffset];
        }];
    }
}

#pragma mark -

- (void)configIssueManager {
    
    MLLogDebugF(@"config issue manager");
    
    __weak typeof(self)weakSelf = self;
    [[HCIssueManager sharedManager] setNewMessageBlock:^(NSArray *newMessages) {
        MLLogDebugF(@"new message come");
        [weakSelf.tableView reloadData];
        [weakSelf scrollMessageTableToBottomAnimated:YES];
    }];
    
    [[HCIssueManager sharedManager] setIssueStautsChangedBlock:^(HCIssueStatus newStatus) {
        MLLogDebugF(@"issue status changed");
        [weakSelf configureWithIssue:[HCIssueManager sharedManager].currentIssue];
    }];
    
    HCIssue *issue = [HCIssueManager sharedManager].currentIssue;
    if (issue) {
        MLLogDebugF(@"there is cached issue: %@", issue);
        [self configureWithIssue:issue];
        [self.tableView reloadData];
    } else {
        MLLogDebugF(@"no cached issue, start activity indicator");
        [weakSelf startActivity];
    }
    
    MLLogDebugF(@"fetch issue from remote server");
    [[HCIssueManager sharedManager] loadIssueFromRemoteWithBlock:^(BOOL succeeded, NSError *error) {
        HCIssue *currentIssue = [HCIssueManager sharedManager].currentIssue;
        MLLogDebugF(@"fetch issue succeeded %d, error: %@ \n current issue: %@", succeeded, error, currentIssue);
        if (error) {
            // 连接服务器出错
            [self showError:HCLocalizedString(@"failed to fetch current issue", nil)];
        }
        [weakSelf configureWithIssue:currentIssue];
        [weakSelf stopActivity];
    }];
}

#pragma mark -
#pragma mark Config view style

- (void)configureWithIssue:(HCIssue *)issue {
    MLLogDebugF(@"config UI with issue: %@", issue);
    if ( ! issue || issue.issueStatus == HCIssueStatusCloseByAppUser || issue.issueStatus == HCIssueStatusRejected) {
        [self configAsNewIssueStyle];
    } else if (issue.issueStatus == HCIssueStatusCloseBySystem) {
        [self configAsReopenStyle];
    } else if (issue.issueStatus == HCIssueStatusResolved) {
        [self configAsResolvedStyle];
    } else {
        [self configAsMsgInputStyle];
    }
}

- (void)removeViews {
    [self.inputView removeFromSuperview];
    self.inputView = nil;
    [self.issueView removeFromSuperview];
    self.issueView = nil;
    [self.reopenDialog removeFromSuperview];
    self.reopenDialog = nil;
    [self.resolveDialog removeFromSuperview];
    self.resolveDialog = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)createIssue {
    [self.issueView tryToTriggerSendAction];
}

- (void)configAsNewIssueStyle {
    if (self.issueView) {
        return;
    }
    
    [self removeViews];
    
    CGFloat toplg = [self respondsToSelector:@selector(topLayoutGuide)] ?[self.topLayoutGuide length]:0 - self.view.frame.origin.x;
    self.issueView = [[HCNewIssueView alloc] initWithFrame:CGRectMake(0, toplg, self.view.bounds.size.width, self.view.bounds.size.height - toplg)];
    self.issueView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.issueView.delegate = self;
    self.issueView.interfaceOrientation = self.interfaceOrientation;
    [self.view addSubview:self.issueView];
    self.tableView.hidden = YES;
    
    if (self.isViewDidAppear) {
        [self.issueView beginEditing];
    }
    
    __weak typeof(self) wself = self;
    [self.issueView setDoneAction:^(NSString *title, NSString *name, NSString *email, UIImage *image) {
        
        [wself.issueView endEditing:NO];
        [wself showMessage:HCLocalizedString(@"Sending your message...", nil) onlyText:NO withDuration:-1];
        
        NSArray *files = nil;
        if (image) {
            NSData *data = UIImageJPEGRepresentation(image, 1.f);
            MLFile *imgFile = [MLFile fileWithName:@"image.jpg" data:data];
            if (imgFile) files = @[imgFile];
        }
        [[HCIssueManager sharedManager] createIssueWithTitle:title
                                                    username:name
                                                       email:email
                                                       files:files
                                                       block:^(BOOL succeeded, NSError *issueCreateError)
        {
            if (succeeded) {
                [[HCIssueManager sharedManager] loadIssueFromRemoteWithBlock:^(BOOL succeeded, NSError *error) {
                    wself.tableView.hidden = NO;
                    [wself.tableView reloadData];
                    [wself configAsMsgInputStyle];
                    
                    if ([issueCreateError.domain isEqualToString:@"HCImageUploadErrorDomain"] && issueCreateError.code == -199) {
                        // 有图片上传失败
                        NSString *errMsg = HCLocalizedString(@"Images upload failed.", nil);
                        NSInteger failureCount = [issueCreateError.userInfo[@"failureCount"] integerValue];
                        if (failureCount < files.count) {
                            errMsg = [NSString stringWithFormat:@"%ld %@", (long)failureCount, HCLocalizedString(@"images upload failed.", nil)];
                        }
                        [wself showError:errMsg];
                    } else {
                        [wself stopActivity];
                    }
                }];
            } else {
//                [wself stopActivity];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HCLocalizedString(@"Message send failure.", nil) message:HCLocalizedString(@"Please check your network connection and try again.", nil) delegate:nil cancelButtonTitle:HCLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                [alertView show];
                [wself showError:HCLocalizedString(@"Message send failure!\nPlease check your network connection and try again.", nil)];
            }
        }];
    }];
    
    UIImage *titleImage = [HCIssuesTheme currentTheme].conversationCreateViewAttr.titleImage;
    if (titleImage) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    } else {
        self.title = HCLocalizedString(@"New Conversation", nil);
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:HCLocalizedString(@"Send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(createIssue)];
}

- (void)configAsMsgInputStyle {
    if (self.inputView) {
        return;
    }
    [self removeViews];
    
    UIImage *titleImage = [HCIssuesTheme currentTheme].conversationViewAttr.titleImage;
    if (titleImage) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    } else {
        self.title = HCLocalizedString(@"Conversation", nil);
    }
    self.inputView = [[HCMsgInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -50, self.view.frame.size.width, 50)];
    self.inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.inputView.delegate = self;
    [self.view addSubview:self.inputView];
    if (!self.tableView.superview) {
        [self.view addSubview:self.tableView];
    }
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.inputView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)configAsReopenStyle {
    if (self.reopenDialog) {
        return;
    }
    [self removeViews];
    
    UIImage *titleImage = [HCIssuesTheme currentTheme].conversationViewAttr.titleImage;
    if (titleImage) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    } else {
        self.title = HCLocalizedString(@"Conversation", nil);
    }
    
    if (!self.tableView.superview) {
        [self.view addSubview:self.tableView];
    }
    
    self.reopenDialog = [[HCHorizonalDialog alloc] initWithLeftTitle:HCLocalizedString(@"Reopen", nil)
                                                          rightTitle:HCLocalizedString(@"NO", nil)
                                                              prompt:HCLocalizedString(@"Continue to reopen it?", nil)];
    self.reopenDialog.frame = CGRectMake(0, self.view.frame.size.height -35, self.view.frame.size.width, 35);
    self.reopenDialog.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    __weak typeof(self) wself = self;
    [self.reopenDialog setLeftAction:^{
        [[HCIssueManager sharedManager] reopenCurrentIssue:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [wself configAsMsgInputStyle];
            }
        }];
    }];
    
    [self.reopenDialog setRightAction:^{
        [[HCIssueManager sharedManager] closeCurrentIssue:^(BOOL succeeded, NSError *error) {
            MLLogDebugF(@"close current issue success %d, error: %@", succeeded, error);
            if (!succeeded) {
                [wself showError:HCLocalizedString(@"Conversation close failure!\nPlease check your network connection and try again.", nil)];
            }
            [wself.tableView reloadData];
        }];
    }];
    
    [self.view addSubview:self.reopenDialog];
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.reopenDialog.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)configAsResolvedStyle {
    if (self.resolveDialog) {
        return;
    }
    [self removeViews];
    
    UIImage *titleImage = [HCIssuesTheme currentTheme].conversationViewAttr.titleImage;
    if (titleImage) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    } else {
        self.title = HCLocalizedString(@"Conversation", nil);
    }
    
    if (!self.tableView.superview) {
        [self.view addSubview:self.tableView];
    }
    
    self.resolveDialog = [[HCHorizonalDialog alloc] initWithLeftTitle:HCLocalizedString(@"Resolved", nil) rightTitle:HCLocalizedString(@"Not yet", nil) prompt:HCLocalizedString(@"The issue has been resolved?", nil)];
    self.resolveDialog.frame = CGRectMake(0, self.view.frame.size.height -35, self.view.frame.size.width, 35);
    self.resolveDialog.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    __weak typeof(self) wself = self;
    
    [self.resolveDialog setLeftAction:^{
        [wself startActivity];
        [[HCIssueManager sharedManager] closeCurrentIssue:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:HCLocalizedString(@"Are you satisfied with the answer? Would you like to review the App?", nil) delegate:wself cancelButtonTitle:HCLocalizedString(@"Later", nil) otherButtonTitles:HCLocalizedString(@"Review", nil), nil];
                [alertView show];
            } else {
                [wself showError:HCLocalizedString(@"failed to close current issue", nil)];
            }
        }];
    }];
    
    [self.resolveDialog setRightAction:^{
        [[HCIssueManager sharedManager] reopenCurrentIssue:nil];
        [wself configAsMsgInputStyle];
    }];
    
    [self.view addSubview:self.resolveDialog];
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.resolveDialog.frame.origin.y;
    self.tableView.frame = frame;
}

#pragma mark -

- (void)scrollMessageTableToBottomAnimated:(BOOL)animated {
    self.tableViewBottomOffset = self.tableView.contentSize.height - self.tableView.contentInset.top;
    [UIView animateWithDuration:0.2 animations:^{
        [self keepMessageTableBottomOffset];
    }];
}

- (void)keepMessageTableBottomOffset {
    CGPoint offset = CGPointMake(0, MAX(self.tableViewBottomOffset - (self.tableView.frame.size.height - self.tableView.contentInset.top), -self.tableView.contentInset.top));
    [self.tableView setContentOffset:offset animated:NO];
}

#pragma mark -
#pragma mark HCMsgInputViewDelegate

- (void)msgInputViewWillChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration {
    
    CGFloat delta = height - self.inputView.frame.size.height;
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height -= delta;
    
    self.tableViewBottomOffset = self.tableView.contentOffset.y + MIN(self.tableView.frame.size.height - self.tableView.contentInset.top, self.tableView.contentSize.height);
    
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.tableView.frame = tableFrame;
            [self keepMessageTableBottomOffset];
        }];
    } else {
        self.tableView.frame = tableFrame;
    }
}

- (void)performAction:(NSInteger)action {
    
    if (action == ACTION_SEND_PHOTO) {
        HCImagePickerController *imagePicker = [[HCImagePickerController alloc] init];
        imagePicker.doneButtonTitle = HCLocalizedString(@"Send", nil);
        
        [imagePicker setDoneAction:^(UIImage *image) {
            NSString *issueId = [[HCIssueManager sharedManager] currentIssue].objectId;
            HCMessage *message = [HCMessage messageWithImage:image issueId:issueId];
            [self sendMsg:message];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else if (action == ACTION_ATTACH_PHOTO) {
        HCImagePickerController *imagePicker = [[HCImagePickerController alloc] init];
        imagePicker.doneButtonTitle = HCLocalizedString(@"Ok,attach", nil);
        
        [imagePicker setDoneAction:^(UIImage *image) {
            [self.issueView didPickImage:image];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else if (action == ACTION_SEND_MSG) {
        [self sendMsg:[self.inputView getMessage]];
    }
}

- (void)sendMsg:(HCMessage *)msg {
    if ([msg isEmpty]) {
        MLLogDebugF(@"Cannot send empty message.");
        return;
    }
    [[HCIssueManager sharedManager] sendMessage:msg completion:^(BOOL succeeded, NSError *error) {
        NSInteger index = [[[HCIssueManager sharedManager] messages] indexOfObject:msg];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        MLLogDebugF(@"message send success %d, error: %@", succeeded, error);
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        
        MLLogDebugF(@"The user would like to review the app.");
        [self showProduct];
        
    } else if (buttonIndex == alertView.cancelButtonIndex) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showProduct {
    
    [self startActivity];
    
    [HCiTunesSearchAPIService getiTunesAppId:^(NSNumber *appId, NSError *error) {
        
        if (appId) {
            
            SKStoreProductViewController *prodViewController = [[SKStoreProductViewController alloc] init];
            prodViewController.delegate = self;
            [prodViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appId} completionBlock:^(BOOL result, NSError *error) {
                if (result) {
                    [self presentViewController:prodViewController animated:YES completion:nil];
                    [self stopActivity];
                } else {
                    [self showError:HCLocalizedString(@"Error", nil)];
                }
            }];
            
        } else {
            [self showError:HCLocalizedString(@"Cannot find this app on iTunes Store.", nil)];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
#pragma mark SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[HCIssueManager sharedManager] messages].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *msgs = [[HCIssueManager sharedManager] messages];
    HCMessage *message = msgs[indexPath.row];
    
    // text message
    if (message.contentType == HCMessageContentTypeText) {
        
        static NSString *rightTextCellId = @"rightText", *leftTextCellId = @"leftText";
        HCTextCell *textCell = nil;
        
        if ([message isFromSelf]) {
            textCell = [tableView dequeueReusableCellWithIdentifier:rightTextCellId];
            if (!textCell) {
                textCell = [[HCRightTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightTextCellId];
            }
        } else {
            textCell = [tableView dequeueReusableCellWithIdentifier:leftTextCellId];
            if (!textCell) {
                textCell = [[HCLeftTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftTextCellId];
            }
        }
        textCell.delegate = self;
        [textCell configWithMessage:message];
        textCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return textCell;
        
    // image message
    } else {
        
        static NSString *rightImageCellId = @"rightImage", *leftImageCellId = @"leftImage";
        HCImageCell *imgCell = nil;
        
        if ([message isFromSelf]) {
            imgCell = [tableView dequeueReusableCellWithIdentifier:rightImageCellId];
            if (!imgCell) {
                imgCell = [[HCRightImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightImageCellId];
            }
        } else {
            imgCell = [tableView dequeueReusableCellWithIdentifier:leftImageCellId];
            if (!imgCell) {
                imgCell = [[HCLeftImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftImageCellId];
            }
        }
        imgCell.delegate = self;
        imgCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [imgCell configWithMessage:message reloadBlock:^{
            NSIndexPath *indexPath = [tableView indexPathForCell:imgCell];
            if (indexPath) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        
        return imgCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    NSArray *msgs = [[HCIssueManager sharedManager] messages];
    HCMessage *message = msgs[indexPath.row];
    if (message.contentType == HCMessageContentTypeText) {
        if ([message isFromSelf]) {
            height = [HCRightTextCell heightOfMessage:message];
        } else {
            height = [HCLeftTextCell heightOfMessage:message];
        }
    } else {
        if ([message isFromSelf]) {
            height = [HCRightImageCell heightOfMessage:message];
        } else {
            height = [HCLeftImageCell heightOfMessage:message];
        }
    }
    return height;
}

#pragma mark HCTextCellDelegate

- (void)didTapFAQ:(NSURL *)faq {
    NSString *faqId = faq.host;
    if (faqId) {
        HCISFaqItemViewController *itemvc = [[HCISFaqItemViewController alloc] init];
        itemvc.faqItemId = faqId;
        [self.navigationController pushViewController:itemvc animated:YES];
    }
}

#pragma mark HCImageCellDelegate

- (void)didTapImageView:(UIImageView *)imageView {
    if (imageView) {
        [self.view endEditing:NO];
        
        // Create image info
        HCImageInfo *imageInfo = [[HCImageInfo alloc] init];
        imageInfo.image = imageView.image;
        imageInfo.referenceRect = imageView.frame;
        imageInfo.referenceView = imageView.superview;
        imageInfo.referenceContentMode = imageView.contentMode;
        imageInfo.referenceCornerRadius = imageView.layer.cornerRadius;
        
        [HCImageViewController displayWithImageInfo:imageInfo fromViewController:self];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:NO];
    
    NSArray *msgs = [[HCIssueManager sharedManager] messages];
    HCMessage *message = msgs[indexPath.row];
    if (message.dataStatus == HCMessageStatusUploadFailed) {
        self.messageToRetry = message;
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:HCLocalizedString(@"Your message was not sent. Tap \"Try Again\" to send this message?", nil) delegate:self cancelButtonTitle:HCLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:HCLocalizedString(@"Try Again", nil), nil];
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        // try again
        HCMessage *message = self.messageToRetry;
        [[HCIssueManager sharedManager] resendFailedMessage:message completion:^(BOOL succeeded, NSError *error) {
            NSInteger index = [[[HCIssueManager sharedManager] messages] indexOfObject:message];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            MLLogDebugF(@"message send success %d, error: %@", succeeded, error);
        }];
        [self.tableView reloadData];
    }
    self.messageToRetry = nil;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
}

@end

