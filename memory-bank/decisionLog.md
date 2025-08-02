# Decision Log

This file records architectural and implementation decisions using a list format.
2025-07-31 19:57:22 - Log of updates made.

*

## Decision

* Demo 结构由单控制器多菜单切换，调整为多控制器分场景展示，入口为 DemoListViewController。

## Rationale 

* 降低接入门槛，提升可读性和可维护性，便于开发者“无脑接入”。

## Implementation Details

* 每个典型场景新建独立控制器，DemoListViewController 作为入口，点击跳转。
*   