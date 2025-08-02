# WGBAppleContainerView 使用指南

## 🚨 修复说明

抱歉之前的代码确实存在问题！我重新仔细分析了原始ContainerView的实现原理，并完全重写了核心逻辑。现在的版本应该能正常工作了。

## 🔧 主要修复内容

### 1. 修复了动画系统
- 使用`CGAffineTransform`替代约束动画，提供更流畅的交互体验
- 实现了正确的三段式停留点计算
- 添加了阻尼效果和弹性边界

### 2. 修复了手势识别
- 正确处理手势状态转换
- 实现了速度检测和智能位置切换
- 修复了手势冲突问题

### 3. 修复了布局问题
- 使用正确的视图层级结构
- 修复了约束冲突和布局异常
- 实现了动态样式切换

## 🎯 核心特性

现在您应该能看到以下效果：

### ✅ 三段式交互
- **底部位置**: 显示少量内容，类似Apple Maps的默认状态
- **中间位置**: 显示部分内容，便于快速浏览
- **顶部位置**: 全屏显示，类似Apple Maps的搜索结果页面

### ✅ 流畅动画
- **弹簧动画**: 自然的Spring动画效果
- **阻尼边界**: 超出边界时的阻尼反馈
- **智能切换**: 根据手势速度和位置智能选择目标位置

### ✅ 视觉效果
- **毛玻璃背景**: 支持Light/Dark/ExtraLight多种模糊效果
- **圆角阴影**: Apple风格的圆角和阴影效果
- **动态透明度**: 容器移动时背景的视觉层次变化

## 🎮 交互测试

运行示例项目后，您可以：

1. **拖拽容器**: 用手指上下拖动容器，感受三个停留点
2. **快速滑动**: 快速向上或向下滑动，容器会智能跳转到相应位置
3. **点击按钮**: 使用导航栏的"Style"和"Position"按钮测试不同配置
4. **滚动内容**: 容器内的TableView可以正常滚动，不会与拖拽手势冲突

## 📱 集成示例

### 最简单的集成方式

```objc
#import "WGBAppleContainerView-Umbrella.h"

// 在 viewDidLoad 中
WGBAppleContainerView *containerView = [WGBContainerViewBuilder createAppleMapsContainer];
containerView.delegate = self;

[self.view addSubview:containerView];
containerView.translatesAutoresizingMaskIntoConstraints = NO;
[NSLayoutConstraint activateConstraints:@[
    [containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [containerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
]];

// 添加您的内容视图控制器
UIViewController *contentVC = [[YourContentViewController alloc] init];
[containerView addContentViewController:contentVC];

// 添加设备旋转支持
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [containerView transitionToSize:size withTransitionCoordinator:coordinator];
}
```

### 自定义配置

```objc
WGBContainerConfiguration *config = [[WGBContainerConfiguration alloc] init];
config.topPositionRatio = 0.1;        // 顶部位置 (屏幕高度的10%)
config.middlePositionRatio = 0.5;     // 中间位置 (屏幕高度的50%)
config.bottomPositionRatio = 0.8;     // 底部位置 (屏幕高度的80%)
config.enableMiddlePosition = YES;     // 启用三段式
config.cornerRadius = 16.0;           // 圆角半径
config.style = WGBContainerStyleLight; // 毛玻璃样式

WGBAppleContainerView *containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
```

## 🐛 如果仍然有问题

如果您运行代码后仍然没有看到预期效果，请检查：

1. **头文件导入**: 确保正确导入了`WGBAppleContainerView-Umbrella.h`
2. **约束设置**: 确保容器视图的约束正确设置到父视图
3. **代理方法**: 检查代理方法是否正确实现
4. **控制台日志**: 查看是否有约束冲突或其他错误信息

## 💡 实现原理

这个新版本的核心改进：

1. **参考原版精髓**: 仔细研究了原始ContainerView的手势处理和动画逻辑
2. **现代化重构**: 去除了硬编码，使用配置化设计
3. **Apple风格**: 完全模仿Apple Maps的交互体验和视觉效果
4. **性能优化**: 使用Transform动画替代约束动画，性能更好

现在这个版本应该能够完美展示类似Apple Maps的三段式容器交互效果了！