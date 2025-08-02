//
//  UIScrollView+WGBContentRefreshable.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "UIScrollView+WGBContentRefreshable.h"
#import <objc/runtime.h>

@implementation UIScrollView (WGBContentRefreshable)

#pragma mark - New Protocol Methods

- (void)performInitialDataRender {
    // UIScrollView 的初始数据渲染
    // 对于普通的 UIScrollView，主要是确保 contentSize 和子视图正确设置
    dispatch_async(dispatch_get_main_queue(), ^{
        // 标记已经完成初始渲染
        [self setInitialDataRendered:YES];
        
        // 如果有代理且实现了相关方法，可以通知代理进行数据加载
        if ([self.delegate respondsToSelector:@selector(scrollViewDidFinishInitialSetup:)]) {
            // 注意：这个方法不是标准的UIScrollViewDelegate方法，需要自定义
            // [(id)self.delegate scrollViewDidFinishInitialSetup:self];
        }
        
        // // NSLog(@"📋 UIScrollView initial data rendered");
    });
}

- (void)updateLayoutFrame {
    // 布局更新时的处理
    // UIScrollView 主要需要处理 contentSize 和 contentInset 的调整
    
    // 可以在这里处理一些布局相关的调整
    // 比如根据新的 frame 调整 contentInset 等
    
    // // NSLog(@"📋 UIScrollView layout frame updated");
}

- (BOOL)needsInitialDataRender {
    // 检查是否已经完成初始渲染
    return ![self isInitialDataRendered];
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

static const void *kScrollViewInitialDataRenderedKey = &kScrollViewInitialDataRenderedKey;

- (void)setInitialDataRendered:(BOOL)rendered {
    objc_setAssociatedObject(self, kScrollViewInitialDataRenderedKey, @(rendered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInitialDataRendered {
    NSNumber *rendered = objc_getAssociatedObject(self, kScrollViewInitialDataRenderedKey);
    return [rendered boolValue];
}

@end