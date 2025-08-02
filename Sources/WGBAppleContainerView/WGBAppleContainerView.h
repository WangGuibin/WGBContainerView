//
//  WGBAppleContainerView.h  
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGBContainerConfiguration.h"
#import "WGBContainerHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@class WGBAppleContainerView;

/// 容器视图状态变化的代理协议
@protocol WGBAppleContainerViewDelegate <NSObject>
@optional
/// 容器即将移动到指定位置时调用
/// @param containerView 容器视图
/// @param position 目标位置
/// @param animated 是否有动画
- (void)containerView:(WGBAppleContainerView *)containerView
    willMoveToPosition:(WGBContainerPosition)position
             animated:(BOOL)animated;
             
/// 容器已经移动到指定位置时调用
/// @param containerView 容器视图
/// @param position 当前位置
- (void)containerView:(WGBAppleContainerView *)containerView
     didMoveToPosition:(WGBContainerPosition)position;
     
/// 容器偏移量发生变化时调用（拖拽过程中实时回调）
/// @param containerView 容器视图
/// @param offset 当前Y轴偏移量
/// @param percentage 当前位置的百分比（0.0-1.0，0表示顶部，1表示底部）
- (void)containerView:(WGBAppleContainerView *)containerView
      didChangeOffset:(CGFloat)offset
           percentage:(CGFloat)percentage;

/// 背景交互效果代理（可选）- 用于实现拖拽时背景的缩放和透明度变化
/// @param containerView 容器视图
/// @param scale 建议的背景缩放比例
/// @param alpha 建议的背景透明度
/// @param offset 容器当前偏移量
- (void)containerView:(WGBAppleContainerView *)containerView
 updateBackgroundScale:(CGFloat)scale
                alpha:(CGFloat)alpha
               offset:(CGFloat)offset;

#pragma mark - 内容生命周期回调（非侵入式）

/// 容器内容视图即将设置时调用 - 业务方可以在此时机进行初始化
/// @param containerView 容器视图
/// @param contentView 内容视图
- (void)containerView:(WGBAppleContainerView *)containerView
  willSetupContentView:(UIView *)contentView;

/// 容器内容视图已经设置完成时调用 - 业务方可以在此时机添加子视图
/// @param containerView 容器视图
/// @param contentView 内容视图
- (void)containerView:(WGBAppleContainerView *)containerView
   didSetupContentView:(UIView *)contentView;

/// 容器布局即将更新时调用 - 业务方可以在此时机准备布局更新
/// @param containerView 容器视图
/// @param position 当前位置
/// @param animated 是否有动画
- (void)containerView:(WGBAppleContainerView *)containerView
      willUpdateLayout:(WGBContainerPosition)position
              animated:(BOOL)animated;

/// 容器布局已经更新完成时调用 - 业务方可以在此时机更新自己的内容布局
/// @param containerView 容器视图
/// @param position 当前位置
- (void)containerView:(WGBAppleContainerView *)containerView
       didUpdateLayout:(WGBContainerPosition)position;

/// 容器即将开始屏幕旋转时调用 - 业务方可以在此时机进行旋转前的准备
/// @param containerView 容器视图
/// @param size 目标尺寸
/// @param coordinator 转换协调器
- (void)containerView:(WGBAppleContainerView *)containerView
willTransitionToSize:(CGSize)size
withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

/// 容器屏幕旋转完成时调用 - 业务方可以在此时机进行旋转后的处理
/// @param containerView 容器视图
/// @param size 新的尺寸
- (void)containerView:(WGBAppleContainerView *)containerView
 didTransitionToSize:(CGSize)size;

/// 容器需要初始数据渲染时调用 - 业务方可以选择是否响应这个时机
/// @param containerView 容器视图
/// @param contentView 需要渲染数据的内容视图
/// @return YES 表示业务方已处理，框架不再自动处理；NO 表示让框架使用默认处理
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldPerformInitialDataRenderForContentView:(UIView *)contentView;

/// 容器需要更新内容布局时调用 - 业务方可以选择是否响应这个时机
/// @param containerView 容器视图
/// @param contentView 需要更新布局的内容视图
/// @return YES 表示业务方已处理，框架不再自动处理；NO 表示让框架使用默认处理
- (BOOL)containerView:(WGBAppleContainerView *)containerView
shouldUpdateLayoutForContentView:(UIView *)contentView;
@end

/// 主容器视图 - 提供Apple风格的交互体验
@interface WGBAppleContainerView : UIView

#pragma mark - 核心属性
/// 配置对象 - 控制容器的所有行为和外观
@property (nonatomic, strong) WGBContainerConfiguration *configuration;

/// 代理对象 - 接收容器状态变化回调
@property (nonatomic, weak) id<WGBAppleContainerViewDelegate> delegate;

/// 当前位置（只读）
@property (nonatomic, readonly) WGBContainerPosition currentPosition;

/// 内容视图 - 开发者添加自定义内容的容器（只读）
@property (nonatomic, readonly) UIView *contentView;

/// Header视图 - 可选的头部视图，推荐使用WGBContainerHeaderView以获得内置拖拽支持
@property (nonatomic, strong, nullable) UIView *headerView;

/// 拖拽手势识别器（只读）- 供外部访问以进行高级手势配置
@property (nonatomic, strong, readonly, nullable) UIPanGestureRecognizer *panGesture;

#pragma mark - 初始化方法
/// 使用配置对象初始化容器
/// @param configuration 配置对象，控制容器的行为和外观
- (instancetype)initWithConfiguration:(WGBContainerConfiguration *)configuration;

#pragma mark - Header设置
/// 创建并设置标准Header视图
/// @param type Header类型（握柄、标题、搜索框、自定义）
/// @param title 标题文本（对于标题和搜索框类型）
- (void)setStandardHeaderWithType:(WGBHeaderViewType)type title:(NSString * _Nullable)title;

#pragma mark - 位置控制
/// 移动到指定位置
/// @param position 目标位置
/// @param animated 是否使用动画
- (void)moveToPosition:(WGBContainerPosition)position animated:(BOOL)animated;

/// 移动到指定位置（带完成回调）
/// @param position 目标位置
/// @param animated 是否使用动画
/// @param completion 完成回调
- (void)moveToPosition:(WGBContainerPosition)position animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion;

#pragma mark - 内容管理
/// 添加内容视图控制器
/// @param viewController 要添加的视图控制器
- (void)addContentViewController:(UIViewController *)viewController;

/// 触发初始数据渲染 - 只渲染尚未渲染的内容
- (void)performInitialContentRender;

/// 更新所有内容的布局 - 只更新布局，不重新加载数据
- (void)updateContentLayout;

/// 监听指定视图及其子视图中tableView的contentSize变化
/// @param view 要监听的根视图
- (void)observeContentSizeChangesInView:(UIView *)view;

#pragma mark - 布局和样式
/// 刷新布局 - 当父视图边界发生变化时调用
- (void)refreshLayout;

/// 更新视觉样式 - 修改configuration.style后调用此方法应用更改
- (void)updateVisualStyle;

#pragma mark - 设备旋转支持
/// 处理设备尺寸变化 - 在ViewController的viewWillTransitionToSize:withTransitionCoordinator:中调用
/// @param size 新的尺寸
/// @param coordinator 转换协调器
- (void)transitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

NS_ASSUME_NONNULL_END
