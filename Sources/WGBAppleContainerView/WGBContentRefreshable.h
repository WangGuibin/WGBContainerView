//
//  WGBContentRefreshable.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-31.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 内容刷新协议
 * 任何需要在容器布局更新后刷新数据的组件都可以实现此协议
 */
@protocol WGBContentRefreshable <NSObject>

@optional
/**
 * 初始化数据渲染 - 只在内容首次添加到容器时调用一次
 * 用于加载和渲染初始数据，确保内容完全可见
 */
- (void)performInitialDataRender;

/**
 * 更新布局 - 在容器位置改变或尺寸变化时调用
 * 只更新frame、约束等布局相关内容，不重新加载数据
 */
- (void)updateLayoutFrame;

/**
 * 判断是否需要初始数据渲染
 * @return YES表示需要初始渲染，NO表示已经渲染过了
 */
- (BOOL)needsInitialDataRender;


@end

NS_ASSUME_NONNULL_END
