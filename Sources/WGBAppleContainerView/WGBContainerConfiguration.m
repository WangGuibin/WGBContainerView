//
//  WGBContainerConfiguration.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "WGBContainerConfiguration.h"

@implementation WGBContainerAnimationConfig

+ (instancetype)defaultConfig {
    WGBContainerAnimationConfig *config = [[WGBContainerAnimationConfig alloc] init];
    config.duration = 0.3;        // 较快的动画
    config.dampingRatio = 1.0;     // 无弹性效果
    config.initialVelocity = 0.0;  // 无初始速度
    config.options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    return config;
}

+ (instancetype)springConfig {
    WGBContainerAnimationConfig *config = [[WGBContainerAnimationConfig alloc] init];
    config.duration = 0.5;        // 稍慢的动画，展现弹性效果
    config.dampingRatio = 0.8;     // 适度的弹性效果
    config.initialVelocity = 0.1;  // 轻微的初始速度
    config.options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    return config;
}

+ (instancetype)smoothConfig {
    WGBContainerAnimationConfig *config = [[WGBContainerAnimationConfig alloc] init];
    config.duration = 0.45;       // 稍微增加动画时长，更自然
    config.dampingRatio = 0.95;    // 保持极轻微的弹性，但基本感觉不到
    config.initialVelocity = 0.0;  // 无初始速度
    config.options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    return config;
}

@end

@implementation WGBContainerConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaults]; // 设置默认值
    }
    return self;
}

- (void)setupDefaults {
    // 位置配置 - 模拟Apple Maps的三段式布局
    self.topPositionRatio = 0.1;      // 距离顶部10%的位置
    self.middlePositionRatio = 0.5;   // 屏幕中间位置
    self.bottomPositionRatio = 0.85;  // 距离顶部85%的位置（即底部留出15%）
    
    // 基础设置
    self.enableMiddlePosition = YES;  // 启用三段式布局
    self.style = WGBContainerStyleLight; // 使用浅色模糊效果
    self.cornerRadius = 16.0;         // 16pt圆角，符合iOS设计规范
    
    // 阴影配置 - 营造卡片悬浮效果
    self.enableShadow = YES;
    self.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]; // 半透明黑色阴影
    self.shadowOffset = CGSizeMake(0, -2); // 向上投射阴影，增强悬浮感
    self.shadowOpacity = 0.2;         // 轻微的阴影透明度
    self.shadowRadius = 8.0;          // 较大的模糊半径，营造柔和效果
    
    // 动画配置 - 使用平滑动画获得更自然的体验
    self.animationConfig = [WGBContainerAnimationConfig smoothConfig];
    
    // 手势配置
    self.enablePanGesture = YES;                  // 启用拖拽手势
    self.panGestureMinimumDistance = 20.0;        // 最小拖拽距离20pt
    self.restrictGestureToHeader = YES;           // 限制手势到Header区域，避免冲突
    
    // 布局配置
    self.layoutMode = WGBContainerLayoutModeAutomatic; // 自动检测布局模式
    self.respectSafeArea = YES;              // 考虑安全区域
    self.enableFullscreen = NO;              // 默认不启用全屏模式  
    self.enableBackgroundInteraction = NO;  // 默认不启用背景交互效果
}

+ (instancetype)defaultConfiguration {
    return [[WGBContainerConfiguration alloc] init];
}

+ (instancetype)appleMapsConfiguration {
    WGBContainerConfiguration *config = [[WGBContainerConfiguration alloc] init];
    
    // Apple Maps特有的位置配置 - 更贴近顶部
    config.topPositionRatio = 0.08;      // 更接近顶部
    config.middlePositionRatio = 0.4;    // 稍微偏上的中间位置
    config.bottomPositionRatio = 0.88;   // 底部位置更低一些
    
    // Apple Maps风格的视觉配置
    config.enableMiddlePosition = YES;
    config.style = WGBContainerStyleLight;
    config.cornerRadius = 12.0;          // 稍小的圆角，更接近Apple Maps
    
    // 使用平滑动画，避免弹跳感，获得更自然的体验
    config.animationConfig = [WGBContainerAnimationConfig smoothConfig];
    
    return config;
}

@end
