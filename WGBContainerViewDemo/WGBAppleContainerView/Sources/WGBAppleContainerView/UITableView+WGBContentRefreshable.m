//
//  UITableView+WGBContentRefreshable.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-31.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "UITableView+WGBContentRefreshable.h"
#import <objc/runtime.h>

@implementation UITableView (WGBContentRefreshable)

#pragma mark - New Protocol Methods

- (void)performInitialDataRender {
    // 在主队列中进行初始数据渲染
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        // 标记已经完成初始渲染
        [self setInitialDataRendered:YES];
        // // NSLog(@"📋 UITableView initial data rendered");
    });
}

- (void)updateLayoutFrame {
    // 布局更新时不需要重新加载数据，frame由容器框架管理
    // 这里可以处理一些布局相关的调整，比如contentInset等
}

- (BOOL)needsInitialDataRender {
    // 检查是否已经完成初始渲染
    return ![self isInitialDataRendered] && (self.dataSource != nil);
}

#pragma mark - Deprecated Protocol Methods (for backward compatibility)

- (void)refreshContentData {
    // 为了向后兼容，保留此方法，但建议使用新的协议方法
    [self performInitialDataRender];
}

- (BOOL)needsContentRefresh {
    // 为了向后兼容，保留此方法
    return [self needsInitialDataRender];
}

#pragma mark - Private Helper Methods

static const void *kInitialDataRenderedKey = &kInitialDataRenderedKey;

- (void)setInitialDataRendered:(BOOL)rendered {
    objc_setAssociatedObject(self, kInitialDataRenderedKey, @(rendered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInitialDataRendered {
    NSNumber *rendered = objc_getAssociatedObject(self, kInitialDataRenderedKey);
    return [rendered boolValue];
}

@end