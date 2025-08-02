//
//  WGBContainerConfiguration.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 容器位置枚举
typedef NS_ENUM(NSUInteger, WGBContainerPosition) {
    WGBContainerPositionTop,        // 顶部位置
    WGBContainerPositionMiddle,     // 中间位置
    WGBContainerPositionBottom,     // 底部位置
    WGBContainerPositionHidden      // 隐藏位置
};

/// 容器视觉样式枚举
typedef NS_ENUM(NSUInteger, WGBContainerStyle) {
    WGBContainerStyleDefault,       // 默认样式（不透明白色背景）
    WGBContainerStyleLight,         // 浅色模糊效果
    WGBContainerStyleDark,          // 深色模糊效果
    WGBContainerStyleExtraLight     // 超浅色模糊效果
};

/// 布局模式枚举
typedef NS_ENUM(NSUInteger, WGBContainerLayoutMode) {
    WGBContainerLayoutModeAutomatic,    // 自动检测：有滚动视图用Frame，静态内容用约束
    WGBContainerLayoutModeConstraint,   // 强制使用约束布局（动画更丝滑，适合静态内容）
    WGBContainerLayoutModeFrame         // 强制使用Frame布局（修复滚动问题，适合列表内容）
};

/// 动画配置类 - 控制容器移动时的动画效果
@interface WGBContainerAnimationConfig : NSObject
@property (nonatomic, assign) NSTimeInterval duration;      // 动画持续时间
@property (nonatomic, assign) CGFloat dampingRatio;         // 弹簧阻尼比例（0.0-1.0，越小弹性越大）
@property (nonatomic, assign) CGFloat initialVelocity;      // 初始速度
@property (nonatomic, assign) UIViewAnimationOptions options; // 动画选项

/// 创建默认动画配置
+ (instancetype)defaultConfig;

/// 创建弹簧动画配置（推荐用于流畅的Apple风格动效）
+ (instancetype)springConfig;

/// 创建平滑动画配置（无弹性，更流畅自然）
+ (instancetype)smoothConfig;
@end

/// 主配置类 - 控制容器的所有行为和外观
@interface WGBContainerConfiguration : NSObject

#pragma mark - 位置配置
/// 各位置的高度比例（相对于父视图高度：0.0 - 1.0）
@property (nonatomic, assign) CGFloat topPositionRatio;     // 顶部位置比例（如0.1表示距离顶部10%的位置）
@property (nonatomic, assign) CGFloat middlePositionRatio;  // 中间位置比例
@property (nonatomic, assign) CGFloat bottomPositionRatio;  // 底部位置比例

/// 是否启用中间位置（禁用后只有顶部和底部两个位置）
@property (nonatomic, assign) BOOL enableMiddlePosition;

#pragma mark - 视觉样式配置
/// 容器的视觉风格
@property (nonatomic, assign) WGBContainerStyle style;

/// 圆角半径（只对顶部两个角生效，营造卡片效果）
@property (nonatomic, assign) CGFloat cornerRadius;

#pragma mark - 阴影配置
/// 是否启用阴影效果
@property (nonatomic, assign) BOOL enableShadow;
/// 阴影颜色
@property (nonatomic, strong) UIColor *shadowColor;
/// 阴影偏移量
@property (nonatomic, assign) CGSize shadowOffset;
/// 阴影透明度
@property (nonatomic, assign) CGFloat shadowOpacity;
/// 阴影模糊半径
@property (nonatomic, assign) CGFloat shadowRadius;

#pragma mark - 动画配置
/// 动画配置对象
@property (nonatomic, strong) WGBContainerAnimationConfig *animationConfig;

#pragma mark - 手势配置
/// 是否启用拖拽手势
@property (nonatomic, assign) BOOL enablePanGesture;
/// 拖拽手势的最小识别距离
@property (nonatomic, assign) CGFloat panGestureMinimumDistance;

/// 是否将手势限制在Header区域（推荐设为YES，避免与内容滚动冲突）
@property (nonatomic, assign) BOOL restrictGestureToHeader;

#pragma mark - 布局配置
/// 布局模式选择
@property (nonatomic, assign) WGBContainerLayoutMode layoutMode;

/// 是否考虑安全区域（iPhone X系列的刘海和底部指示器区域）
@property (nonatomic, assign) BOOL respectSafeArea;

/// 全屏模式 - 允许容器扩展到屏幕最顶部（忽略状态栏和导航栏）
@property (nonatomic, assign) BOOL enableFullscreen;

/// 背景交互效果 - 启用后拖拽容器时背景会有缩放和透明度变化
@property (nonatomic, assign) BOOL enableBackgroundInteraction;

#pragma mark - 预设配置
/// 创建默认配置
+ (instancetype)defaultConfiguration;

/// 创建Apple Maps风格的配置（推荐使用）
+ (instancetype)appleMapsConfiguration;

@end

NS_ASSUME_NONNULL_END
