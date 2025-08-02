# WGBAppleContainerView

一个现代化的iOS容器视图SDK，提供类似Apple Maps的三段式交互体验。

得益于[mrustaa/ContainerView](https://github.com/mrustaa/ContainerView)以及Claude Code共同加持下,基本上完成了这个组件



## ✨ 特性

- 🍎 **Apple风格设计**: 完美复制Apple官方应用的交互体验
- 🎯 **三段式停顿**: 支持上、中、下三个位置的平滑过渡
- 🎨 **高度可定制**: 灵活的配置选项，支持多种视觉风格
- 📱 **全面兼容**: 支持纯代码、Xib、Nib多种集成方式
- ⚡ **流畅动画**: 基于Spring动画的自然交互体验
- 🔧 **易于集成**: 简单的API设计，一行代码即可集成
- 📱 **设备旋转支持**: 完美处理设备旋转和尺寸变化
- 🎯 **手势冲突解决**: 智能的手势区域限制，避免与内容滚动冲突

## 🚀 快速开始

### 基础用法

```objc
#import "WGBAppleContainerView-Umbrella.h"

// 创建容器视图
WGBAppleContainerView *containerView = [WGBContainerViewBuilder createAppleMapsContainer];

// 添加到父视图
[WGBContainerViewBuilder addContainer:containerView toParentView:self.view];

// 添加内容
UIViewController *contentVC = [[UIViewController alloc] init];
[containerView addContentViewController:contentVC];

// 设置标准header（推荐，避免手势冲突）
[containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"My Container"];
```

### 📋 Header类型和手势处理

为了解决手势冲突问题，SDK提供了专门的Header组件：

```objc
// 1. 只有拖拽指示器的Header
[containerView setStandardHeaderWithType:WGBHeaderViewTypeGrip title:nil];

// 2. 包含标题的Header  
[containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"标题"];

// 3. 包含搜索框的Header
[containerView setStandardHeaderWithType:WGBHeaderViewTypeSearch title:@"搜索占位符"];

// 4. 自定义Header
UIView *customContent = [[UIView alloc] init];
// 配置您的自定义内容...
WGBContainerHeaderView *header = [WGBContainerHeaderView headerWithCustomContent:customContent];
containerView.headerView = header;
```

### 自定义配置

```objc
// 创建自定义配置
WGBContainerConfiguration *config = [[WGBContainerConfiguration alloc] init];
config.topPositionRatio = 0.1;        // 顶部位置(相对高度)
config.middlePositionRatio = 0.5;     // 中间位置
config.bottomPositionRatio = 0.85;    // 底部位置
config.enableMiddlePosition = YES;     // 启用中间位置
config.cornerRadius = 16.0;           // 圆角半径
config.style = WGBContainerStyleLight; // 视觉风格

// 使用自定义配置创建容器
WGBAppleContainerView *containerView = [WGBContainerViewBuilder createContainerWithConfiguration:config];
```

## 📋 主要组件

### WGBAppleContainerView
核心容器视图类，提供完整的交互功能。

### WGBContainerConfiguration  
配置类，用于自定义容器的外观和行为。

### WGBContainerViewBuilder
构建器类，提供便捷的创建和集成方法。

### WGBContainerViewIB
Interface Builder支持类，可在Storyboard中直接使用。

## 🎨 支持的样式

- **WGBContainerStyleLight**: 浅色模糊效果
- **WGBContainerStyleDark**: 深色模糊效果  
- **WGBContainerStyleExtraLight**: 超浅色模糊效果
- **WGBContainerStyleDefault**: 默认样式

## 📱 集成方式

### 1. 纯代码集成

```objc
WGBAppleContainerView *containerView = [WGBContainerViewBuilder createDefaultContainer];
[self.view addSubview:containerView];
```

### 2. Interface Builder集成

1. 在Storyboard中添加一个UIView
2. 将Class设置为`WGBContainerViewIB`
3. 在Attributes Inspector中配置属性
4. 通过IBOutlet连接到代码

### 3. Nib文件集成

```objc
WGBAppleContainerView *containerView = [WGBContainerViewBuilder loadContainerFromNib:@"CustomContainer" 
                                                                               bundle:nil 
                                                                        configuration:nil];
```

## 📱 设备旋转支持

在您的ViewController中添加设备旋转支持：

```objc
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // 方法1: 直接调用容器的旋转处理方法
    [self.containerView transitionToSize:size withTransitionCoordinator:coordinator];
    
    // 方法2: 使用Builder的便捷方法
    // [WGBContainerViewBuilder handleDeviceRotation:self.containerView 
    //                                       toSize:size 
    //                        withTransitionCoordinator:coordinator];
}
```

## 🔧 代理方法

```objc
@protocol WGBAppleContainerViewDelegate <NSObject>
@optional
- (void)containerView:(WGBAppleContainerView *)containerView
    willMoveToPosition:(WGBContainerPosition)position
             animated:(BOOL)animated;
             
- (void)containerView:(WGBAppleContainerView *)containerView
     didMoveToPosition:(WGBContainerPosition)position;
     
- (void)containerView:(WGBAppleContainerView *)containerView
      didChangeOffset:(CGFloat)offset
            percentage:(CGFloat)percentage;
@end
```

## 🎯 核心优势

### 相比原始ContainerView的改进:

1. **移除硬编码**: 不再依赖宏定义和硬编码数值
2. **配置化设计**: 通过Configuration对象进行灵活配置
3. **更好的封装**: 清晰的API设计，易于理解和使用
4. **现代化架构**: 采用现代iOS开发模式
5. **全面的集成支持**: 支持多种集成方式
6. **Apple风格**: 完美复制Apple官方交互体验

## 🎯 手势冲突解决方案

### 问题描述
传统的容器拖拽实现经常遇到手势冲突问题：
- 容器内的ScrollView滚动与容器拖拽冲突
- 用户不知道在哪里可以拖拽容器  
- 内容区域的交互被误触为容器拖拽

### 解决方案
WGBAppleContainerView采用Apple Maps的设计理念：

#### 1. 专用拖拽区域
- 手势识别限制在Header区域
- 配置 `restrictGestureToHeader = YES`（默认启用）
- 提供视觉指示器（grip）告知用户拖拽位置

#### 2. 多种Header类型
```objc
// 最小化Header - 只有拖拽指示器
[containerView setStandardHeaderWithType:WGBHeaderViewTypeGrip title:nil];

// 带标题的Header  
[containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"标题"];

// 带搜索的Header
[containerView setStandardHeaderWithType:WGBHeaderViewTypeSearch title:@"搜索"];
```

#### 3. 智能手势处理
- Header区域：响应容器拖拽
- 内容区域：正常的滚动和交互
- 自动处理手势冲突，无需手动配置

### 技术特点:

- ✅ Auto Layout支持
- ✅ Safe Area适配
- ✅ 弹簧动画系统
- ✅ 手势冲突处理
- ✅ 内存管理优化
- ✅ Interface Builder支持
- ✅ 设备旋转适配

## 📖 示例项目

查看`Example`目录中的示例项目，了解各种用法和最佳实践。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交Issues和Pull Requests来帮助改进这个项目！