//
//  UICollectionView+WGBContentRefreshable.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGBContentRefreshable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * UICollectionView扩展，支持内容刷新协议
 */
@interface UICollectionView (WGBContentRefreshable) <WGBContentRefreshable>

@end

NS_ASSUME_NONNULL_END