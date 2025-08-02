# 非侵入式架构设计文档

## 🎯 架构设计理念

WGBAppleContainerView 框架采用**非侵入式架构**，遵循"**框架提供时机，业务控制逻辑**"的设计原则：

- **框架职责**：提供精确的生命周期回调时机
- **业务职责**：决定在每个时机做什么以及如何做
- **可选便利**：框架提供扩展作为便利实现，业务方可选择使用

## 🔄 生命周期回调设计

### 内容视图生命周期
```objc
// 1. 内容视图即将设置（可进行准备工作）
- (void)containerView:(WGBAppleContainerView *)containerView
  willSetupContentView:(UIView *)contentView;

// 2. 内容视图已设置完成（可添加子视图）
- (void)containerView:(WGBAppleContainerView *)containerView
   didSetupContentView:(UIView *)contentView;
```

### 数据渲染控制
```objc
// 业务方选择是否自己处理数据渲染
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldPerformInitialDataRenderForContentView:(UIView *)contentView {
    if (contentView == self.myTableView) {
        [self loadMyOwnData];  // 业务逻辑
        return YES;  // 告诉框架：我已处理，不需要框架再处理
    }
    return NO;  // 让框架使用便利扩展处理
}
```

### 布局更新控制
```objc
// 业务方选择是否自己处理布局更新
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldUpdateLayoutForContentView:(UIView *)contentView {
    if (contentView == self.myTableView) {
        [self updateMyOwnLayout];  // 业务逻辑
        return YES;  // 告诉框架：我已处理
    }
    return NO;  // 让框架处理
}
```

### 布局更新生命周期
```objc
// 布局即将更新（准备阶段）
- (void)containerView:(WGBAppleContainerView *)containerView
      willUpdateLayout:(WGBContainerPosition)position
              animated:(BOOL)animated;

// 布局已更新完成（后续处理）
- (void)containerView:(WGBAppleContainerView *)containerView
       didUpdateLayout:(WGBContainerPosition)position;
```

### 屏幕旋转生命周期
```objc
// 即将开始旋转（准备阶段）
- (void)containerView:(WGBAppleContainerView *)containerView
willTransitionToSize:(CGSize)size
withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

// 旋转已完成（后续处理）
- (void)containerView:(WGBAppleContainerView *)containerView
 didTransitionToSize:(CGSize)size;
```

## 🛠 使用方式对比

### 传统侵入式（问题）
```objc
// ❌ 框架自动为所有 UITableView 添加行为
// ❌ 业务无法控制何时刷新数据
// ❌ 框架在背后执行未知操作
```

### 新的非侵入式（推荐）
```objc
// ✅ 业务方完全控制
@interface MyVC : BaseContainerDemoVC <WGBAppleContainerViewDelegate>
@end

@implementation MyVC

- (void)setupContainer {
    self.containerView.delegate = self;  // 设置代理接收回调
}

// 选择性处理数据渲染
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldPerformInitialDataRenderForContentView:(UIView *)contentView {
    if ([contentView isKindOfClass:[UITableView class]]) {
        // 我要自己控制 TableView 的数据加载
        [self loadBusinessData];
        return YES;  // 我已处理
    }
    return NO;  // 其他视图让框架处理
}

// 选择性处理布局更新
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldUpdateLayoutForContentView:(UIView *)contentView {
    if (contentView == self.specialView) {
        // 我要自己控制特殊视图的布局
        [self updateSpecialViewLayout];
        return YES;  // 我已处理
    }
    return NO;  // 其他视图让框架处理
}

@end
```

## 🎨 灵活性优势

### 1. 业务控制权
- 业务方决定**何时**加载数据
- 业务方决定**如何**更新布局
- 业务方决定**是否**响应某个时机

### 2. 选择性处理
- 可以只处理特定的视图
- 可以混合使用框架便利实现
- 可以根据业务场景灵活选择

### 3. 调试友好
- 所有操作都在业务代码中可见
- 清晰的执行流程
- 易于定位问题

## 🔧 便利扩展（可选）

框架仍然提供便利扩展，但**不再自动执行**：

```objc
// UITableView+WGBContentRefreshable.h
@interface UITableView (WGBContentRefreshable) <WGBContentRefreshable>
// 提供默认实现，业务方可选择使用
@end
```

使用方式：
```objc
// 业务方可以主动调用框架的便利方法
[self.containerView performInitialContentRender];  // 手动触发
[self.containerView updateContentLayout];          // 手动触发

// 或者在代理回调中返回 NO，让框架自动使用便利实现
- (BOOL)containerView:shouldPerformInitialDataRenderForContentView: {
    return NO;  // 让框架使用便利扩展
}
```

## 📋 最佳实践

### 1. 简单场景
```objc
// 不实现 should 回调，让框架使用便利扩展
// 框架会自动处理 UITableView、UICollectionView 等
```

### 2. 复杂业务场景
```objc
// 实现 should 回调，完全控制特定视图
- (BOOL)containerView:shouldPerformInitialDataRenderForContentView: {
    if (contentView == self.complexBusinessView) {
        [self handleComplexBusinessLogic];
        return YES;  // 我已处理
    }
    return NO;  // 其他视图让框架处理
}
```

### 3. 混合使用
```objc
// 一些视图自己处理，一些视图让框架处理
- (BOOL)containerView:shouldUpdateLayoutForContentView: {
    if ([contentView isKindOfClass:[MyCustomView class]]) {
        [self updateCustomViewLayout:contentView];
        return YES;  // 自己处理
    }
    // UITableView、UICollectionView 等让框架处理
    return NO;
}
```

## 🎯 总结

**非侵入式架构的核心价值**：
- ✅ **控制权交还给业务方**
- ✅ **框架变成纯粹的通知者**
- ✅ **业务方可灵活选择处理方式**
- ✅ **保持便利扩展作为可选实现**
- ✅ **更好的可调试性和可维护性**

这种设计遵循了软件工程中的"**控制反转**"原则，让框架专注于提供稳定的容器交互体验，而把业务逻辑的控制权完全交给接入方。