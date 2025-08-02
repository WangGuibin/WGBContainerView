//
//  ViewController.m
//  WGBAppleContainerViewExample
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "ViewController.h"
#import "DemoListViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 直接跳转到 DemoListViewController
    DemoListViewController *listVC = [[DemoListViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:NO completion:nil];
}

@end
