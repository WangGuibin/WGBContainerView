# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.
2025-07-31 19:57:22 - Log of updates made will be appended as footnotes to the end of this file.

*

## Project Goal

* 提供 Apple Maps 风格的可拖拽容器视图组件，支持多种交互模式，便于在 iOS 项目中快速集成。
* Demo 目标：让开发者一眼看懂每种典型用法，做到"无脑接入"。

## Key Features

* 支持顶部、中部、底部多段停靠
* 支持全屏模式（可滑到屏幕最顶部）
* 支持 Header 区域手势限制
* 支持背景交互（缩放、透明度变化）
* 支持多种 Header 样式（Grip、Title、Search、自定义）
* 支持内容滚动与容器拖拽分离
* Demo 代码极简、注释清晰、每种场景单独控制器
* [2025-07-31 20:37:26] - Demo 多控制器拆分：新增 5 个典型场景 Demo 控制器（Apple Maps 风格、全屏模式、Header 手势限制、背景交互效果、Header 样式），实现"无脑接入"目标

## Overall Architecture

* 组件核心代码位于 WGBAppleContainerView/Sources/WGBAppleContainerView/
* Demo 采用多控制器结构：
  - DemoListViewController：入口列表，展示所有典型场景
  - AppleMapsStyleDemoVC：Apple Maps 风格演示
  - FullscreenDemoVC：全屏模式演示
  - HeaderRestrictDemoVC：Header 区域手势限制演示
  - BackgroundInteractionDemoVC：背景交互演示
  - HeaderStylesDemoVC：多种 Header 样式演示
  - 其他典型场景可扩展
* 每个 Demo 控制器只展示一种用法，便于复制粘贴
* Demo 入口和导航清晰，便于扩展和维护

*