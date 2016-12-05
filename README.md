# Module-MaxIssues-iOS

##使用说明：

### 一、设置 appid 和 clientkey

1、在 maxleap.cn 中创建 app，记录 appid 和 clientkey。

2、更换 AppDelegate.m 中的宏定义为1中的 appid 和 clientkey：

    #define MAXLEAP_APPID           @"your_app_id"
    #define MAXLEAP_CLIENTKEY       @"your_client_key"

### 二、ViewController 介绍

1、HCConversationViewController：Issues 主界面，使用方法：

- 使用 navigation controller push
    
    ```objc
    HCConversationViewController *issuesViewController = [[HCConversationViewController alloc] init];
    [self.navigationController pushViewController:faqViewController animated:YES];
    ```


- 展示为 Modal View：

    ```objc
    HCConversationViewController *issuesViewController = [[HCConversationViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:issuesViewController];
    [self presentViewController:navCtrl animated:YES completion:nil];
    ```


**注意：必须使用 NavigationController, 因为有一部分按钮放在导航栏上**

