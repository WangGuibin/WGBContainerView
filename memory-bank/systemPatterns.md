# System Patterns *Optional*

This file documents recurring patterns and standards used in the project.
It is optional, but recommended to be updated as the project evolves.
2025-07-31 19:57:22 - Log of updates made.

*

## Coding Patterns

* 控制器命名采用"场景+DemoVC"格式，如 AppleMapsStyleDemoVC。
* 每个 Demo 控制器只展示一种典型用法，代码极简、注释清晰。
* 入口 DemoListViewController 使用 UITableView 展示所有场景。
* Demo 控制器统一采用 setupBackgroundView + setupContainerView + setupContainerContent 三段式结构。

## Architectural Patterns

* Demo 采用"列表入口+多控制器"结构，便于扩展和维护。
* 每个控制器独立，互不影响，便于复制粘贴。
* 背景视图 + 容器视图 + 内容视图的三层架构模式。

## Testing Patterns

* Demo 代码无需单元测试，主打可读性和可运行性。
* 每个 Demo 控制器独立测试，确保功能完整。
*