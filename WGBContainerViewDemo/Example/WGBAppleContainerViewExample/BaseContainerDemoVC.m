//
//  BaseContainerDemoVC.m
//  WGBAppleContainerViewExample
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "BaseContainerDemoVC.h"

@implementation BaseContainerDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // 基类默认实现
}

#pragma mark - Screen Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // 自动处理容器视图的屏幕旋转
    if (self.containerView) {
        NSLog(@"🔄 %@ handling rotation to size: %@", NSStringFromClass([self class]), NSStringFromCGSize(size));
        [self.containerView transitionToSize:size withTransitionCoordinator:coordinator];
    }
}

@end