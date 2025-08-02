//
//  WGBContainerHeaderView.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WGBAppleContainerView,WGBContainerHeaderView;

/// Header自定义交互的代理协议
@protocol WGBContainerHeaderViewDelegate <NSObject>
@optional
/// 搜索框开始编辑时调用（自动触发容器移动到顶部）
/// @param headerView Header视图
/// @param searchBar 搜索框
- (void)headerView:(WGBContainerHeaderView *)headerView searchBarDidBeginEditing:(UISearchBar *)searchBar;

/// 搜索框文本变化时调用
/// @param headerView Header视图
/// @param searchBar 搜索框
/// @param searchText 当前搜索文本
- (void)headerView:(WGBContainerHeaderView *)headerView searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;

/// 自定义内容被点击时调用
/// @param headerView Header视图
/// @param customContent 被点击的自定义内容视图
- (void)headerView:(WGBContainerHeaderView *)headerView customContentDidReceiveTap:(UIView *)customContent;
@end

/// Header视图类型枚举
typedef NS_ENUM(NSUInteger, WGBHeaderViewType) {
    WGBHeaderViewTypeGrip,      // 仅握柄指示器 - 最简洁的样式
    WGBHeaderViewTypeTitle,     // 握柄 + 标题 - 显示标题文本
    WGBHeaderViewTypeSearch,    // 握柄 + 搜索框 - 点击自动弹到顶部并聚焦
    WGBHeaderViewTypeCustom     // 自定义内容 - 完全由开发者定制
};

/// 标准Header视图 - 提供拖拽指示器和多种内容类型
/// 这个类解决了手势冲突问题，让拖拽手势仅在Header区域生效
@interface WGBContainerHeaderView : UIView

#pragma mark - 核心属性
/// Header代理 - 接收搜索和自定义交互回调
@property (nonatomic, weak, nullable) id<WGBContainerHeaderViewDelegate> delegate;

/// 容器视图引用 - 自动设置，用于搜索框聚焦时触发容器移动
@property (nonatomic, weak, nullable) WGBAppleContainerView *containerView;

/// Header类型（只读）
@property (nonatomic, assign, readonly) WGBHeaderViewType headerType;

#pragma mark - UI组件（只读）
/// 拖拽指示器（握柄）视图 - 所有类型都包含
@property (nonatomic, strong, readonly) UIView *gripView;

/// 标题标签 - 仅标题类型包含
@property (nonatomic, strong, readonly, nullable) UILabel *titleLabel;

/// 搜索框 - 仅搜索类型包含，点击时自动弹到顶部
@property (nonatomic, strong, readonly, nullable) UISearchBar *searchBar;

/// 自定义内容视图 - 仅自定义类型包含
@property (nonatomic, strong, readonly, nullable) UIView *customContentView;

#pragma mark - 创建方法
/// 创建仅包含握柄的Header
+ (instancetype)headerWithGrip;

/// 创建包含握柄和标题的Header
/// @param title 标题文本
+ (instancetype)headerWithTitle:(NSString *)title;

/// 创建包含握柄和搜索框的Header（推荐用于搜索场景）
/// @param placeholder 搜索框占位符文本
+ (instancetype)headerWithSearchPlaceholder:(NSString *)placeholder;

/// 创建包含自定义内容的Header
/// @param contentView 自定义内容视图
+ (instancetype)headerWithCustomContent:(UIView *)contentView;

#pragma mark - 样式更新
/// 根据容器样式更新Header外观
/// @param style 容器样式（对应WGBContainerStyle枚举值）
- (void)updateAppearanceForStyle:(NSInteger)style;

@end

NS_ASSUME_NONNULL_END
