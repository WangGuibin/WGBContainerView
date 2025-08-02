//
//  UITableView+WGBContentRefreshable.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-31.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGBContentRefreshable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * UITableView扩展，支持内容刷新协议
 */
@interface UITableView (WGBContentRefreshable) <WGBContentRefreshable>

@end

NS_ASSUME_NONNULL_END