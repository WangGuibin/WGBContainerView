//
//  WGBContainerViewBuilder.h
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGBAppleContainerView.h"

NS_ASSUME_NONNULL_BEGIN

/// Builder class for easy integration with Xib/Nib/Code
@interface WGBContainerViewBuilder : NSObject

/// Create container view with default configuration
+ (WGBAppleContainerView *)createDefaultContainer;

/// Create container view with Apple Maps style
+ (WGBAppleContainerView *)createAppleMapsContainer;

/// Create container view with custom configuration
+ (WGBAppleContainerView *)createContainerWithConfiguration:(WGBContainerConfiguration *)configuration;

/// Add container to parent view with Auto Layout
+ (void)addContainer:(WGBAppleContainerView *)container 
          toParentView:(UIView *)parentView;

/// Add container to parent view controller
+ (void)addContainer:(WGBAppleContainerView *)container 
    toViewController:(UIViewController *)viewController;

/// Load container from Nib
+ (WGBAppleContainerView *)loadContainerFromNib:(NSString *)nibName 
                                         bundle:(NSBundle * _Nullable)bundle
                                  configuration:(WGBContainerConfiguration * _Nullable)configuration;

/// Handle device rotation for container (convenience method)
+ (void)handleDeviceRotation:(WGBAppleContainerView *)container
                      toSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

/// Interface Builder support
IB_DESIGNABLE
@interface WGBContainerViewIB : UIView

/// Configuration properties for Interface Builder
@property (nonatomic, assign) IBInspectable CGFloat topPositionRatio;
@property (nonatomic, assign) IBInspectable CGFloat middlePositionRatio;
@property (nonatomic, assign) IBInspectable CGFloat bottomPositionRatio;
@property (nonatomic, assign) IBInspectable BOOL enableMiddlePosition;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable BOOL enableShadow;
@property (nonatomic, assign) IBInspectable BOOL enablePanGesture;
@property (nonatomic, assign) IBInspectable NSInteger containerStyle;

/// The actual container view
@property (nonatomic, readonly) WGBAppleContainerView *containerView;

@end

NS_ASSUME_NONNULL_END
