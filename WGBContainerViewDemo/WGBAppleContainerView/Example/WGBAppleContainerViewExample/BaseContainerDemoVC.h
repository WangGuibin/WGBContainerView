//
//  BaseContainerDemoVC.h
//  WGBAppleContainerViewExample
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGBAppleContainerView-Umbrella.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 容器演示的基类 - 自动处理屏幕旋转
 * 所有包含 WGBAppleContainerView 的 demo 都应该继承这个基类
 */
@interface BaseContainerDemoVC : UIViewController

/// 容器视图 - 子类应该设置这个属性
@property (nonatomic, strong, nullable) WGBAppleContainerView *containerView;

@end

NS_ASSUME_NONNULL_END