//
//  UICollectionView+WGBContentRefreshable.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "UICollectionView+WGBContentRefreshable.h"
#import <objc/runtime.h>

@implementation UICollectionView (WGBContentRefreshable)

#pragma mark - New Protocol Methods

- (void)performInitialDataRender {
    // UICollectionView 的初始数据渲染
    dispatch_async(dispatch_get_main_queue(), ^{
        // 确保有数据源才进行重新加载
        if (self.dataSource) {
            [self reloadData];
        }
        
        // 标记已经完成初始渲染
        [self setInitialDataRendered:YES];
        // // NSLog(@"📋 UICollectionView initial data rendered");
    });
}

- (void)updateLayoutFrame {
    // 布局更新时的处理
    // UICollectionView 可能需要通知 layout 对象更新
    
    if (self.collectionViewLayout) {
        // 标记布局需要更新，但不重新加载数据
        [self.collectionViewLayout invalidateLayout];
    }
    
    // // NSLog(@"📋 UICollectionView layout frame updated");
}

- (BOOL)needsInitialDataRender {
    // 检查是否已经完成初始渲染，并且确保有数据源
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

static const void *kCollectionViewInitialDataRenderedKey = &kCollectionViewInitialDataRenderedKey;

- (void)setInitialDataRendered:(BOOL)rendered {
    objc_setAssociatedObject(self, kCollectionViewInitialDataRenderedKey, @(rendered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInitialDataRendered {
    NSNumber *rendered = objc_getAssociatedObject(self, kCollectionViewInitialDataRenderedKey);
    return [rendered boolValue];
}

@end