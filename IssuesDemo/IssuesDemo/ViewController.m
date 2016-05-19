//
//  ViewController.m
//  IssuesDemo
//
//  Created by Sun Jin on 16/5/19.
//  Copyright © 2016年 maxleap. All rights reserved.
//

#import "ViewController.h"
#import "HCConversationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)contactus:(id)sender {
    [self.navigationController pushViewController:[HCConversationViewController new] animated:YES];
}

@end
