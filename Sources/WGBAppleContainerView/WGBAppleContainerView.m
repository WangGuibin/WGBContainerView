//
//  WGBAppleContainerView.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "WGBAppleContainerView.h"
#import "WGBContainerHeaderView.h"
#import "WGBContentRefreshable.h"
#import "UITableView+WGBContentRefreshable.h"

@interface WGBAppleContainerView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIVisualEffectView *backgroundEffectView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 重新声明为可读写

@property (nonatomic, assign) WGBContainerPosition currentPosition;
@property (nonatomic, assign) CGFloat startPanY;
@property (nonatomic, assign) CGFloat initialContainerY;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isTransitioning;

// 布局模式相关
@property (nonatomic, assign) WGBContainerLayoutMode actualLayoutMode; // 实际使用的布局模式

@end

@implementation WGBAppleContainerView

#pragma mark - Properties

- (void)setDelegate:(id<WGBAppleContainerViewDelegate>)delegate {
    _delegate = delegate;
    
    // 如果contentView还没有创建，现在创建它
    if (!self.contentView && delegate) {
        [self setupContentView];
    }
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithConfiguration:[WGBContainerConfiguration defaultConfiguration]];
}

- (instancetype)initWithConfiguration:(WGBContainerConfiguration *)configuration {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _configuration = configuration;
        _currentPosition = WGBContainerPositionBottom;
        _isAnimating = NO;
        _isTransitioning = NO;
        [self setupUI];
        [self setupGestures];
    }
    return self;
}

#pragma mark - Setup

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor]; // 保持透明，让毛玻璃效果正常
    
    // 确定实际使用的布局模式
    [self determineLayoutMode];
    
    [self setupBackgroundEffect];
    // 延迟setupContentView到设置代理之后
    // [self setupContentView];
    [self updateAppearance];
}

- (void)determineLayoutMode {
    switch (self.configuration.layoutMode) {
        case WGBContainerLayoutModeAutomatic:
            // 自动检测模式：延迟到内容添加后检测
            self.actualLayoutMode = WGBContainerLayoutModeConstraint; // 默认使用约束
            break;
        case WGBContainerLayoutModeConstraint:
            self.actualLayoutMode = WGBContainerLayoutModeConstraint;
            break;
        case WGBContainerLayoutModeFrame:
            self.actualLayoutMode = WGBContainerLayoutModeFrame;
            break;
    }
    
    // // NSLog(@"📐 Layout mode determined: %@ (config: %@)", 
    //       [self layoutModeString:self.actualLayoutMode],
    //       [self layoutModeString:self.configuration.layoutMode]);
}

- (NSString *)layoutModeString:(WGBContainerLayoutMode)mode {
    switch (mode) {
        case WGBContainerLayoutModeAutomatic: return @"Automatic";
        case WGBContainerLayoutModeConstraint: return @"Constraint";
        case WGBContainerLayoutModeFrame: return @"Frame";
    }
}

- (void)setupBackgroundEffect {
    // 移除旧的背景效果视图
    if (self.backgroundEffectView) {
        [self.backgroundEffectView removeFromSuperview];
        self.backgroundEffectView = nil;
    }
    
    UIBlurEffect *blurEffect;
    switch (self.configuration.style) {
        case WGBContainerStyleLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            break;
        case WGBContainerStyleDark:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
        case WGBContainerStyleExtraLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        default:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            break;
    }
    
    self.backgroundEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.backgroundEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.backgroundEffectView atIndex:0]; // 插入到最底层
    
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundEffectView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.backgroundEffectView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.backgroundEffectView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.backgroundEffectView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    // 立即应用圆角
    self.backgroundEffectView.layer.cornerRadius = self.configuration.cornerRadius;
    self.backgroundEffectView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.backgroundEffectView.clipsToBounds = YES;
}

- (void)setupContentView {
    // 通知代理即将设置内容视图（此时 contentView 还是 nil 或旧的）
    if ([self.delegate respondsToSelector:@selector(containerView:willSetupContentView:)]) {
        [self.delegate containerView:self willSetupContentView:self.contentView];
    }
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = YES; // 防止子视图超出边界显示
    
    if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
        // 约束布局模式：简单的填满容器布局，使用transform动画
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.contentView];
        
        // 先设置基本约束，header添加后会调整topAnchor
        [NSLayoutConstraint activateConstraints:@[
            [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        // // NSLog(@"ContentView created with constraint layout (transform animations)");
    } else {
        // Frame布局模式：修复滚动问题，适合列表内容
        self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
        [self addSubview:self.contentView];
        
        // Frame模式下给contentView一个临时的背景色，防止透明时看到间隙
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];
        
        // // NSLog(@"ContentView created with frame layout (scroll fix)");
    }
    
    // 通知代理内容视图已设置完成（此时 contentView 已经创建并添加到视图层级）
    if ([self.delegate respondsToSelector:@selector(containerView:didSetupContentView:)]) {
        [self.delegate containerView:self didSetupContentView:self.contentView];
    }
}

- (void)setupGestures {
    if (self.configuration.enablePanGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        self.panGesture.delegate = self;
        
        // NSLog(@"Setting up gestures - restrictGestureToHeader: %d", self.configuration.restrictGestureToHeader);
        
        // 根据配置决定手势添加到哪个视图
        if (!self.configuration.restrictGestureToHeader) {
            // 如果不限制到header，直接添加到整个容器
            [self addGestureRecognizer:self.panGesture];
            // NSLog(@"Added pan gesture to entire container view");
        } else {
            // 如果限制到header，先临时添加到容器，等header设置后再移动
            [self addGestureRecognizer:self.panGesture];
            // NSLog(@"Temporarily added pan gesture to container, will move to header when set");
        }
        // 如果限制到header，会在setHeaderView时重新设置
    }
}

- (void)updateAppearance {
    self.layer.cornerRadius = self.configuration.cornerRadius;
    self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.clipsToBounds = NO;
    
    if (self.configuration.enableShadow) {
        self.layer.shadowColor = self.configuration.shadowColor.CGColor;
        self.layer.shadowOffset = self.configuration.shadowOffset;
        self.layer.shadowOpacity = self.configuration.shadowOpacity;
        self.layer.shadowRadius = self.configuration.shadowRadius;
    }
    
    self.backgroundEffectView.layer.cornerRadius = self.configuration.cornerRadius;
    self.backgroundEffectView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.backgroundEffectView.clipsToBounds = YES;
}

#pragma mark - Layout

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        [self refreshLayout];
        
        // 根据布局模式设置初始位置
        if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
            // 约束模式：容器填满父视图，通过transform控制位置
            self.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor],
                [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
                [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor],
                [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor]
            ]];
        } else {
            // Frame模式：容器使用frame布局，设置初始frame
            self.translatesAutoresizingMaskIntoConstraints = YES;
            CGRect superviewBounds = self.superview.bounds;
            self.frame = superviewBounds; // 初始设置为填满父视图
            // NSLog(@"Frame Mode - Container initial frame set: %@", NSStringFromCGRect(self.frame));
        }
        
        // 初始位置设置为底部
        dispatch_async(dispatch_get_main_queue(), ^{
            [self moveToPosition:WGBContainerPositionBottom animated:NO];
            // 确保内容在添加到父视图后立即刷新
            [self refreshAllContent];
        });
    }
}

- (void)refreshAllContent {
    // 非侵入式内容管理机制：优先让业务方处理，框架提供便利实现作为后备
    for (UIView *subview in self.contentView.subviews) {
        // 首先询问代理是否要自己处理
        BOOL delegateHandled = NO;
        if ([self.delegate respondsToSelector:@selector(containerView:shouldPerformInitialDataRenderForContentView:)]) {
            delegateHandled = [self.delegate containerView:self shouldPerformInitialDataRenderForContentView:subview];
        }
        
        // 如果代理没有处理，才使用框架的便利实现
        if (!delegateHandled && [subview conformsToProtocol:@protocol(WGBContentRefreshable)]) {
            id<WGBContentRefreshable> refreshableContent = (id<WGBContentRefreshable>)subview;
            
            // 使用协议方法：只有需要初始渲染时才渲染数据
            if ([refreshableContent respondsToSelector:@selector(needsInitialDataRender)] && 
                [refreshableContent needsInitialDataRender]) {
                if ([refreshableContent respondsToSelector:@selector(performInitialDataRender)]) {
                    [refreshableContent performInitialDataRender];
                    // NSLog(@"📋 Framework performed initial data render for %@", NSStringFromClass([subview class]));
                }
            }
        } else if (delegateHandled) {
            // NSLog(@"📋 Delegate handled initial data render for %@", NSStringFromClass([subview class]));
        }
    }
}

- (void)updateAllContentLayout {
    // 非侵入式布局更新机制：优先让业务方处理
    for (UIView *subview in self.contentView.subviews) {
        // 首先询问代理是否要自己处理
        BOOL delegateHandled = NO;
        if ([self.delegate respondsToSelector:@selector(containerView:shouldUpdateLayoutForContentView:)]) {
            delegateHandled = [self.delegate containerView:self shouldUpdateLayoutForContentView:subview];
        }
        
        // 如果代理没有处理，才使用框架的便利实现
        if (!delegateHandled && [subview conformsToProtocol:@protocol(WGBContentRefreshable)]) {
            id<WGBContentRefreshable> refreshableContent = (id<WGBContentRefreshable>)subview;
            
            // 使用协议方法：只更新布局
            if ([refreshableContent respondsToSelector:@selector(updateLayoutFrame)]) {
                [refreshableContent updateLayoutFrame];
                // NSLog(@"📋 Framework updated layout for %@", NSStringFromClass([subview class]));
            }
        } else if (delegateHandled) {
            // NSLog(@"📋 Delegate handled layout update for %@", NSStringFromClass([subview class]));
        }
    }
}

#pragma mark - Public Content Management Methods

- (void)performInitialContentRender {
    [self refreshAllContent];
}

- (void)updateContentLayout {
    [self updateAllContentLayout];
}

- (void)refreshLayout {
    // 刷新布局配置
}

- (void)updateVisualStyle {
    [self setupBackgroundEffect];
    [self updateAppearance];
}

- (void)transitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (!coordinator) return;
    
    self.isTransitioning = YES;
    WGBContainerPosition currentPos = self.currentPosition;
    
    // NSLog(@"🔄 Screen rotation - from %@ to %@, maintaining position %@", 
//          NSStringFromCGSize(self.superview.bounds.size), NSStringFromCGSize(size), [self positionName:currentPos]);
    
    // 通知代理即将开始屏幕旋转
    if ([self.delegate respondsToSelector:@selector(containerView:willTransitionToSize:withTransitionCoordinator:)]) {
        [self.delegate containerView:self willTransitionToSize:size withTransitionCoordinator:coordinator];
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 关键修复：根据当前位置类型，重新计算在新屏幕尺寸下的对应位置
        CGFloat targetY = [self yPositionForPosition:currentPos withSize:size];
        
        if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
            // 约束模式：更新transform到新的位置比例
            CGAffineTransform targetTransform = CGAffineTransformMakeTranslation(0, targetY);
            self.transform = targetTransform;
            // NSLog(@"🔄 Constraint mode - %@ position targetY: %.2f", [self positionName:currentPos], targetY);
        } else {
            // Frame模式：重新计算frame，确保容器高度合理
            CGFloat containerHeight = MAX(100, size.height - targetY); // 确保最小高度
            CGRect newFrame = CGRectMake(0, targetY, size.width, containerHeight);
            self.frame = newFrame;
            
            // 立即更新内容布局以适应新尺寸
            [self updateFrameAndLayoutAtomically:targetY animated:NO];
            // NSLog(@"🔄 Frame mode - %@ position targetY: %.2f, containerHeight: %.2f", 
//                  [self positionName:currentPos], targetY, containerHeight);
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.isTransitioning = NO;
        
        if (!context.isCancelled) {
            // 旋转完成后确保位置和布局完全正确
            dispatch_async(dispatch_get_main_queue(), ^{
                // 使用最终的superview bounds重新计算位置
                CGFloat finalTargetY = [self yPositionForPosition:currentPos];
                
                if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
                    CGAffineTransform finalTransform = CGAffineTransformMakeTranslation(0, finalTargetY);
                    self.transform = finalTransform;
                } else {
                    // Frame模式：最终调整
                    [self updateFrameAndLayoutAtomically:finalTargetY animated:NO];
                }
                
                // 通知代理布局即将更新
                if ([self.delegate respondsToSelector:@selector(containerView:willUpdateLayout:animated:)]) {
                    [self.delegate containerView:self willUpdateLayout:currentPos animated:NO];
                }
                
                // 确保内容布局正确更新
                [self updateAllContentLayout];
                
                // 通知代理布局已更新完成
                if ([self.delegate respondsToSelector:@selector(containerView:didUpdateLayout:)]) {
                    [self.delegate containerView:self didUpdateLayout:currentPos];
                }
                
                // 通知代理屏幕旋转已完成
                if ([self.delegate respondsToSelector:@selector(containerView:didTransitionToSize:)]) {
                    [self.delegate containerView:self didTransitionToSize:size];
                }
                
                // NSLog(@"🔄 Rotation completed - %@ position maintained at targetY: %.2f", 
//                      [self positionName:currentPos], finalTargetY);
            });
        }
    }];
}

- (NSString *)positionName:(WGBContainerPosition)position {
    switch (position) {
        case WGBContainerPositionTop: return @"TOP";
        case WGBContainerPositionMiddle: return @"MIDDLE";
        case WGBContainerPositionBottom: return @"BOTTOM";
        case WGBContainerPositionHidden: return @"HIDDEN";
        default: return @"UNKNOWN";
    }
}

#pragma mark - Position Calculations

- (CGFloat)yPositionForPosition:(WGBContainerPosition)position {
    return [self yPositionForPosition:position withSize:CGSizeZero];
}

- (CGFloat)yPositionForPosition:(WGBContainerPosition)position withSize:(CGSize)targetSize {
    if (!self.superview) return 0;
    
    // 使用目标尺寸（旋转时）或当前尺寸
    CGFloat superviewHeight = !CGSizeEqualToSize(targetSize, CGSizeZero) ? 
                              targetSize.height : 
                              CGRectGetHeight(self.superview.bounds);
    
    CGFloat safeAreaTop = 0;
    CGFloat safeAreaBottom = 0;
    
    if (@available(iOS 11.0, *)) {
        if (self.configuration.respectSafeArea && !self.configuration.enableFullscreen) {
            safeAreaTop = self.superview.safeAreaInsets.top;
            safeAreaBottom = self.superview.safeAreaInsets.bottom;
        }
    }
    
    CGFloat availableHeight = superviewHeight - safeAreaTop - safeAreaBottom;
    CGFloat baseOffset = self.configuration.enableFullscreen ? 0 : safeAreaTop;
    
    CGFloat calculatedY = 0;
    
    switch (position) {
        case WGBContainerPositionTop:
            // Top位置：根据配置的比例计算
            calculatedY = availableHeight * self.configuration.topPositionRatio + baseOffset;
            break;
        case WGBContainerPositionMiddle:
            // Middle位置：根据配置的比例计算
            calculatedY = availableHeight * self.configuration.middlePositionRatio + baseOffset;
            break;
        case WGBContainerPositionBottom:
            // Bottom位置：根据配置的比例计算
            calculatedY = availableHeight * self.configuration.bottomPositionRatio + baseOffset;
            break;
        case WGBContainerPositionHidden:
            // 隐藏位置：完全移出屏幕
            calculatedY = superviewHeight;
            break;
    }
    
    // 确保容器始终在可见范围内，至少保留最小高度
    CGFloat minContainerHeight = 100; // 最小容器高度
    CGFloat maxAllowedY = superviewHeight - minContainerHeight;
    
    if (calculatedY > maxAllowedY && position != WGBContainerPositionHidden) {
        CGFloat originalY = calculatedY;
        calculatedY = maxAllowedY;
        // NSLog(@"⚠️ %@ position clamped from %.2f to %.2f (screen height: %.2f)", 
//              [self positionName:position], originalY, calculatedY, superviewHeight);
    }
    
    // NSLog(@"📐 %@ position calculation: ratio=%.2f, availableHeight=%.2f, baseOffset=%.2f, result=%.2f", 
//          [self positionName:position], [self ratioForPosition:position], availableHeight, baseOffset, calculatedY);
    
    return calculatedY;
}

- (CGFloat)ratioForPosition:(WGBContainerPosition)position {
    switch (position) {
        case WGBContainerPositionTop:
            return self.configuration.topPositionRatio;
        case WGBContainerPositionMiddle:
            return self.configuration.middlePositionRatio;
        case WGBContainerPositionBottom:
            return self.configuration.bottomPositionRatio;
        case WGBContainerPositionHidden:
            return 1.0; // 完全移出屏幕
        default:
            return self.configuration.bottomPositionRatio;
    }
}

- (WGBContainerPosition)nearestPositionForY:(CGFloat)y {
    CGFloat topY = [self yPositionForPosition:WGBContainerPositionTop];
    CGFloat middleY = [self yPositionForPosition:WGBContainerPositionMiddle];
    CGFloat bottomY = [self yPositionForPosition:WGBContainerPositionBottom];
    
    NSMutableArray *positions = [NSMutableArray arrayWithObjects:
        @[@(WGBContainerPositionTop), @(topY)],
        @[@(WGBContainerPositionBottom), @(bottomY)],
        nil];
    
    if (self.configuration.enableMiddlePosition) {
        [positions addObject:@[@(WGBContainerPositionMiddle), @(middleY)]];
    }
    
    WGBContainerPosition nearestPosition = WGBContainerPositionBottom;
    CGFloat nearestDistance = CGFLOAT_MAX;
    
    for (NSArray *positionData in positions) {
        WGBContainerPosition position = [positionData[0] integerValue];
        CGFloat positionY = [positionData[1] doubleValue];
        CGFloat distance = ABS(y - positionY);
        
        if (distance < nearestDistance) {
            nearestDistance = distance;
            nearestPosition = position;
        }
    }
    
    return nearestPosition;
}

#pragma mark - Animation

- (void)moveToPosition:(WGBContainerPosition)position animated:(BOOL)animated {
    [self moveToPosition:position animated:animated completion:nil];
}

- (void)moveToPosition:(WGBContainerPosition)position animated:(BOOL)animated completion:(void (^)(void))completion {
    if (position == WGBContainerPositionMiddle && !self.configuration.enableMiddlePosition) {
        position = WGBContainerPositionBottom;
    }
    
    if (self.isAnimating && animated) {
        return;
    }
    
    CGFloat targetY = [self yPositionForPosition:position];
    // NSLog(@"🎯 Moving to %@ position, targetY: %.2f, superview height: %.2f", 
//          [self positionName:position], targetY, CGRectGetHeight(self.superview.bounds));
    
    if ([self.delegate respondsToSelector:@selector(containerView:willMoveToPosition:animated:)]) {
        [self.delegate containerView:self willMoveToPosition:position animated:animated];
    }
    
    void (^animationBlock)(void) = ^{
        if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
            // 约束动画模式：使用简单的transform动画，保持原本的丝滑感
            CGAffineTransform targetTransform = CGAffineTransformMakeTranslation(0, targetY);
            self.transform = targetTransform;
            // NSLog(@"🎯 Applied constraint transform for %@ position: %@", 
//                  [self positionName:position], NSStringFromCGAffineTransform(targetTransform));
        } else {
            // Frame动画模式：使用带动画的原子性更新，保持流畅感
            [self updateFrameAndLayoutAtomically:targetY animated:YES];
            // NSLog(@"🎯 Applied animated atomic frame update for %@ position: %.2f", 
//                  [self positionName:position], targetY);
        }
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
        if (finished) {
            self.isAnimating = NO;
            self.currentPosition = position; // 重要：更新当前位置状态
            
            // 通知代理布局即将更新
            if ([self.delegate respondsToSelector:@selector(containerView:willUpdateLayout:animated:)]) {
                [self.delegate containerView:self willUpdateLayout:position animated:animated];
            }
            
            // 动画完成后，延迟更新布局以避免干扰动画效果
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // Frame模式需要确保contentView正确布局
                if (self.actualLayoutMode == WGBContainerLayoutModeFrame) {
                    [self updateContentViewForPosition:position];
                }
                
                // 只更新布局，不刷新数据
                [self updateAllContentLayout];
                
                // 通知代理布局已更新完成
                if ([self.delegate respondsToSelector:@selector(containerView:didUpdateLayout:)]) {
                    [self.delegate containerView:self didUpdateLayout:position];
                }
                
                // NSLog(@"🎯 Successfully moved to %@ position and updated layout", [self positionName:position]);
            });
            
            if ([self.delegate respondsToSelector:@selector(containerView:didMoveToPosition:)]) {
                [self.delegate containerView:self didMoveToPosition:position];
            }
            if (completion) completion();
        }
    };
    
    if (animated) {
        self.isAnimating = YES;
        WGBContainerAnimationConfig *config = self.configuration.animationConfig;
        [UIView animateWithDuration:config.duration
                              delay:0
             usingSpringWithDamping:config.dampingRatio
              initialSpringVelocity:config.initialVelocity
                            options:config.options
                         animations:animationBlock
                         completion:completionBlock];
    } else {
        animationBlock();
        // 非动画模式立即更新位置状态和布局
        self.currentPosition = position; // 重要：立即更新位置状态
        if (self.actualLayoutMode == WGBContainerLayoutModeFrame) {
            // Frame模式已经在animationBlock中使用原子性更新了
            // 这里只需要确保内容布局正确
            [self updateAllContentLayout];
        } else {
            // 约束模式需要更新布局
            [self updateAllContentLayout];
        }
        completionBlock(YES);
    }
}

- (void)updateContentViewForPosition:(WGBContainerPosition)position {
    if (!self.superview) return;
    
    // 根据布局模式处理header和contentView
    if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
        // 约束模式：header固定在容器顶部，contentView在header下方
        [self updateContentViewForConstraintMode:position];
    } else {
        // Frame模式：按原逻辑处理
        [self updateContentViewForFrameMode:position];
    }
}

- (void)updateContentViewForConstraintMode:(WGBContainerPosition)position {
    // 约束模式：header和contentView都通过约束自动布局，只需要处理子视图
    
    // contentView的子视图布局
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            // 所有UIScrollView子类（包括UITableView、UICollectionView等）填满contentView
            subview.frame = self.contentView.bounds;
        }
        
        // 只更新布局，不重新渲染数据
        if ([subview conformsToProtocol:@protocol(WGBContentRefreshable)]) {
            id<WGBContentRefreshable> refreshableContent = (id<WGBContentRefreshable>)subview;
            if ([refreshableContent respondsToSelector:@selector(updateLayoutFrame)]) {
                [refreshableContent updateLayoutFrame];
            }
        }
    }
}

- (void)updateContentViewForFrameMode:(WGBContainerPosition)position {
    if (!self.superview) return;
    
    // 关键修复：contentView不能超出容器bounds，应该在容器内滚动
    CGFloat containerWidth = CGRectGetWidth(self.frame);
    CGFloat containerHeight = CGRectGetHeight(self.frame);
    
    // 首先正确设置header frame
    CGFloat headerHeight = 0;
    if (self.headerView) {
        // 关键修复：如果header已经有frame，优先使用现有高度，避免intrinsicContentSize的不一致性
        if (CGRectGetHeight(self.headerView.frame) > 0) {
            headerHeight = CGRectGetHeight(self.headerView.frame);
        } else {
            headerHeight = [self.headerView intrinsicContentSize].height;
            if (headerHeight <= 0) {
                headerHeight = 60; // 调整默认高度为60，更适合现代iOS设备
            }
        }
        // Header固定在容器顶部，宽度填满容器
        self.headerView.frame = CGRectMake(0, 0, containerWidth, headerHeight);
    }
    
    // 然后设置contentView，填满容器剩余空间
    CGFloat availableContentHeight = containerHeight - headerHeight;
    CGRect contentFrame = CGRectMake(0, headerHeight, containerWidth, availableContentHeight);
    self.contentView.frame = contentFrame;
    
    // 使用新的递归更新方法，确保所有子视图的宽度正确适配
    if (availableContentHeight > 0) {
        [self updateSubviewsFrameRecursively:self.contentView withSize:CGSizeMake(containerWidth, availableContentHeight)];
        
        // 只更新布局，不重新渲染数据
        for (UIView *subview in self.contentView.subviews) {
            if ([subview conformsToProtocol:@protocol(WGBContentRefreshable)]) {
                id<WGBContentRefreshable> refreshableContent = (id<WGBContentRefreshable>)subview;
                if ([refreshableContent respondsToSelector:@selector(updateLayoutFrame)]) {
                    [refreshableContent updateLayoutFrame];
                }
            }
        }
    }
}

- (void)updateContentViewForCurrentY:(CGFloat)currentY {
    if (!self.superview) return;
    
    // 实时轻量级更新，contentView填满容器可用空间
    CGFloat containerWidth = CGRectGetWidth(self.frame);
    CGFloat containerHeight = CGRectGetHeight(self.frame);
    
    // 关键修复：拖拽过程中不要重新计算header尺寸，使用现有的frame
    CGFloat headerHeight = 0;
    if (self.headerView) {
        headerHeight = CGRectGetHeight(self.headerView.frame); // 使用现有frame，不重新计算
        // 只更新header的宽度，保持高度不变
        CGRect currentHeaderFrame = self.headerView.frame;
        self.headerView.frame = CGRectMake(0, 0, containerWidth, currentHeaderFrame.size.height);
    }
    
    // 然后更新contentView frame
    CGFloat availableContentHeight = containerHeight - headerHeight;
    CGRect contentFrame = CGRectMake(0, headerHeight, containerWidth, availableContentHeight);
    self.contentView.frame = contentFrame;
    
    // 确保所有滚动视图填满contentView
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            subview.frame = self.contentView.bounds;
        }
    }
}

#pragma mark - Atomic Layout Update

- (void)updateSubviewsFrameRecursively:(UIView *)parentView withSize:(CGSize)parentSize {
    // 递归更新所有子视图的frame，确保在旋转时正确适配新的宽度
    for (UIView *subview in parentView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            // 滚动视图类（UITableView、UICollectionView等）填满父视图
            if (subview.backgroundColor == nil || [subview.backgroundColor isEqual:[UIColor clearColor]]) {
                subview.backgroundColor = [UIColor systemBackgroundColor];
            }
            subview.frame = CGRectMake(0, 0, parentSize.width, parentSize.height);
            
            // 如果是有内容的滚动视图，继续递归更新其子视图
            if (subview.subviews.count > 0) {
                [self updateSubviewsFrameRecursively:subview withSize:subview.bounds.size];
            }
        } else if (subview.translatesAutoresizingMaskIntoConstraints) {
            // Frame布局的子视图需要更新宽度
            CGRect currentFrame = subview.frame;
            if (currentFrame.size.width != parentSize.width) {
                // 保持原有的高度和y位置，但更新宽度以适配新的父视图宽度
                subview.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, 
                                         parentSize.width, currentFrame.size.height);
            }
            
            // 继续递归更新子视图
            if (subview.subviews.count > 0) {
                [self updateSubviewsFrameRecursively:subview withSize:subview.bounds.size];
            }
        }
        // 约束布局的视图不需要手动更新frame，约束系统会自动处理
    }
}

- (void)updateFrameAndLayoutAtomically:(CGFloat)newY {
    [self updateFrameAndLayoutAtomically:newY animated:NO];
}

- (void)updateFrameAndLayoutAtomically:(CGFloat)newY animated:(BOOL)animated {
    // 原子性更新：确保frame和布局同步更新，避免视觉间隙
    
    if (!self.superview) return;
    
    // 第一步：计算新的frame
    CGFloat superviewHeight = CGRectGetHeight(self.superview.bounds);
    CGFloat superviewWidth = CGRectGetWidth(self.superview.bounds);
    CGFloat containerHeight = superviewHeight - newY;
    
    // 确保容器高度不会为负数
    containerHeight = MAX(0, containerHeight);
    
    CGRect newFrame = CGRectMake(0, newY, superviewWidth, containerHeight);
    
    void (^updateBlock)(void) = ^{
        // 同时更新容器frame和所有子视图布局
        self.frame = newFrame;
        
        // 立即更新背景效果视图frame（关键！）
        if (self.backgroundEffectView) {
            self.backgroundEffectView.frame = self.bounds;
        }
        
        // 只有当容器有有效高度时才更新子视图
        if (containerHeight > 0) {
            // 立即更新header frame（如果存在）
            CGFloat headerHeight = 0;
            if (self.headerView) {
                headerHeight = CGRectGetHeight(self.headerView.frame);
                // 确保header有有效尺寸
                if (headerHeight <= 0) headerHeight = 60;
                self.headerView.frame = CGRectMake(0, 0, superviewWidth, headerHeight);
            }
            
            // 立即更新contentView frame
            CGFloat availableContentHeight = containerHeight - headerHeight;
            availableContentHeight = MAX(0, availableContentHeight); // 确保不为负数
            
            CGRect contentFrame = CGRectMake(0, headerHeight, superviewWidth, availableContentHeight);
            self.contentView.frame = contentFrame;
            
            // 立即递归更新所有子视图frame，确保宽度正确适配
            if (availableContentHeight > 0) {
                [self updateSubviewsFrameRecursively:self.contentView withSize:CGSizeMake(superviewWidth, availableContentHeight)];
            }
        }
    };
    
    if (animated) {
        // 动画模式：保持一些流畅性
        [UIView animateWithDuration:0.1 // 很短的动画，主要是为了平滑
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:updateBlock
                         completion:nil];
    } else {
        // 拖拽过程中：完全同步更新，绝对不能有任何延迟
        [CATransaction begin];
        [CATransaction setDisableActions:YES]; // 完全禁用动画
        updateBlock();
        [CATransaction commit];
    }
}

#pragma mark - Gesture Handling

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    // NSLog(@"Pan gesture triggered! State: %ld", (long)gesture.state);
    
    // 在转换过程中禁用手势
    if (self.isTransitioning) {
        // NSLog(@"Gesture blocked - container is transitioning");
        return;
    }
    
    CGPoint translation = [gesture translationInView:self.superview];
    CGPoint velocity = [gesture velocityInView:self.superview];
    
    // NSLog(@"Translation: %@, Velocity: %@", NSStringFromCGPoint(translation), NSStringFromCGPoint(velocity));
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.startPanY = translation.y;
            self.initialContainerY = self.frame.origin.y; // 改为使用frame
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat newY = self.initialContainerY + (translation.y - self.startPanY);
            CGFloat minY = [self yPositionForPosition:WGBContainerPositionTop];
            CGFloat maxY = [self yPositionForPosition:WGBContainerPositionBottom];
            
            // 限制在有效范围内，但允许一定的弹性
            if (newY < minY) {
                newY = minY - (minY - newY) * 0.3; // 阻尼效果
            } else if (newY > maxY) {
                newY = maxY + (newY - maxY) * 0.3; // 阻尼效果
            }
            
            // 关键修复：原子性更新frame和布局，避免视觉间隙
            [self updateFrameAndLayoutAtomically:newY];
            
            // 计算百分比并通知代理
            CGFloat percentage = (newY - minY) / (maxY - minY);
            percentage = MAX(0, MIN(1, percentage));
            
            if ([self.delegate respondsToSelector:@selector(containerView:didChangeOffset:percentage:)]) {
                [self.delegate containerView:self didChangeOffset:newY percentage:percentage];
            }
            
            // 背景交互效果
            if (self.configuration.enableBackgroundInteraction && [self.delegate respondsToSelector:@selector(containerView:updateBackgroundScale:alpha:offset:)]) {
                // 当容器向上移动时，背景可以放大并变暗
                CGFloat scale = 1.0 + (1.0 - percentage) * 0.1; // 最大放大10%
                CGFloat alpha = 1.0 - (1.0 - percentage) * 0.3; // 最大变暗30%
                [self.delegate containerView:self updateBackgroundScale:scale alpha:alpha offset:newY];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGFloat currentY = self.frame.origin.y; // 改为使用frame
            WGBContainerPosition targetPosition;
            
            // 根据速度和位置决定目标位置
            if (ABS(velocity.y) > 500) {
                if (velocity.y > 0) {
                    // 向下滑动
                    if (self.configuration.enableMiddlePosition && self.currentPosition == WGBContainerPositionTop) {
                        targetPosition = WGBContainerPositionMiddle;
                    } else {
                        targetPosition = WGBContainerPositionBottom;
                    }
                } else {
                    // 向上滑动
                    if (self.configuration.enableMiddlePosition && self.currentPosition == WGBContainerPositionBottom) {
                        targetPosition = WGBContainerPositionMiddle;
                    } else {
                        targetPosition = WGBContainerPositionTop;
                    }
                }
            } else {
                // 根据当前位置找到最近的停留点
                targetPosition = [self nearestPositionForY:currentY];
            }
            
            [self moveToPosition:targetPosition animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - Content Management

- (void)addContentViewController:(UIViewController *)viewController {
    if (!viewController) return;
    
    [viewController.view removeFromSuperview];
    
    // 自动检测模式：检查是否包含滚动视图
    if (self.configuration.layoutMode == WGBContainerLayoutModeAutomatic) {
        BOOL hasScrollView = [self detectScrollViewInView:viewController.view];
        WGBContainerLayoutMode newMode = hasScrollView ? WGBContainerLayoutModeFrame : WGBContainerLayoutModeConstraint;
        
        if (newMode != self.actualLayoutMode) {
            // NSLog(@"📐 Auto-detected layout mode change: %@ -> %@ (hasScrollView: %d)", 
//                  [self layoutModeString:self.actualLayoutMode], 
//                  [self layoutModeString:newMode], hasScrollView);
            
            // 需要重新配置布局
            [self reconfigureLayoutMode:newMode];
        }
    }
    
    if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:viewController.view];
        
        // 约束模式：让内容填满contentView，但不设置具体的frame
        [NSLayoutConstraint activateConstraints:@[
            [viewController.view.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [viewController.view.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [viewController.view.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [viewController.view.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
        ]];
    } else {
        // Frame模式：设置frame布局
        viewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:viewController.view];
        
        // Frame模式下，如果contentView的bounds还没有正确设置，先强制布局更新
        if (CGRectEqualToRect(self.contentView.bounds, CGRectZero)) {
            [self updateContentViewForPosition:self.currentPosition];
        }
        
        viewController.view.frame = self.contentView.bounds;
        
        // 初始化时进行数据渲染，而不是每次都刷新
        if ([viewController.view conformsToProtocol:@protocol(WGBContentRefreshable)]) {
            id<WGBContentRefreshable> refreshableContent = (id<WGBContentRefreshable>)viewController.view;
            if ([refreshableContent respondsToSelector:@selector(needsInitialDataRender)] && 
                [refreshableContent needsInitialDataRender]) {
                if ([refreshableContent respondsToSelector:@selector(performInitialDataRender)]) {
                    [refreshableContent performInitialDataRender];
                    // NSLog(@"📋 Frame Mode - Initial data rendered for %@", NSStringFromClass([viewController.view class]));
                }
            }
        }
        
        // NSLog(@"📋 Frame Mode - ViewController view added with frame: %@", NSStringFromCGRect(viewController.view.frame));
    }
    
    // 添加完成后，只进行必要的初始数据渲染
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshAllContent]; // 使用新的机制，只渲染需要初始渲染的内容
    });
}

- (BOOL)detectScrollViewInView:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    
    for (UIView *subview in view.subviews) {
        if ([self detectScrollViewInView:subview]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)reconfigureLayoutMode:(WGBContainerLayoutMode)newMode {
    if (newMode == self.actualLayoutMode) return;
    
    // 移除现有的子视图和约束
    [self.contentView removeFromSuperview];
    
    // 如果从约束模式切换，需要清理容器约束
    if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
        self.translatesAutoresizingMaskIntoConstraints = YES;
        [self removeFromSuperview];
        [self.superview addSubview:self];
    }
    
    // 更新模式并重新设置
    self.actualLayoutMode = newMode;
    [self setupContentView];
    
    // 如果切换到约束模式，需要设置容器约束
    if (newMode == WGBContainerLayoutModeConstraint && self.superview) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor],
            [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
            [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor],
            [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor]
        ]];
    }
}

- (void)observeContentSizeChangesInView:(UIView *)view {
    // 暂时保留这个方法以避免编译错误，但不再使用KVO监听
    // 因为contentView应该在容器bounds内，不需要随contentSize变化
    // NSLog(@"📋 ContentSize observation disabled - using container-bounded layout");
}

#pragma mark - Header View

- (void)setStandardHeaderWithType:(WGBHeaderViewType)type title:(NSString *)title {
    WGBContainerHeaderView *headerView;
    
    switch (type) {
        case WGBHeaderViewTypeGrip:
            headerView = [WGBContainerHeaderView headerWithGrip];
            break;
        case WGBHeaderViewTypeTitle:
            headerView = [WGBContainerHeaderView headerWithTitle:title ?: @"Title"];
            break;
        case WGBHeaderViewTypeSearch:
            headerView = [WGBContainerHeaderView headerWithSearchPlaceholder:title ?: @"Search"];
            break;
        case WGBHeaderViewTypeCustom:
        default:
            headerView = [WGBContainerHeaderView headerWithGrip];
            break;
    }
    
    self.headerView = headerView;
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView) {
        [_headerView removeFromSuperview];
        // 移除旧header上的手势
        if (self.panGesture && self.configuration.restrictGestureToHeader) {
            [_headerView removeGestureRecognizer:self.panGesture];
            // NSLog(@"Removed pan gesture from old header");
        }
    }
    
    _headerView = headerView;
    
    if (headerView) {
        if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
            // 约束模式：header使用约束布局，固定在容器顶部
            headerView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:headerView];
            
            // header固定在容器顶部
            [NSLayoutConstraint activateConstraints:@[
                [headerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
                [headerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
                [headerView.topAnchor constraintEqualToAnchor:self.topAnchor]
            ]];
            
            // NSLog(@"Header added with constraints for constraint mode");
        } else {
            // Frame模式：header使用frame布局，需要设置初始frame
            headerView.translatesAutoresizingMaskIntoConstraints = YES;
            [self addSubview:headerView];
            
            // 设置初始frame，避免显示问题
            CGFloat headerHeight = [headerView intrinsicContentSize].height;
            if (headerHeight <= 0) {
                headerHeight = 60;
            }
            
            // Frame模式下，先设置一个初始frame
            CGFloat containerWidth = CGRectGetWidth(self.bounds);
            if (containerWidth <= 0 && self.superview) {
                // 如果容器还没有bounds，使用父视图的宽度
                containerWidth = CGRectGetWidth(self.superview.bounds);
            }
            if (containerWidth <= 0) {
                // 最后的回退方案，使用屏幕宽度
                containerWidth = [UIScreen mainScreen].bounds.size.width;
            }
            
            headerView.frame = CGRectMake(0, 0, containerWidth, headerHeight);
            // NSLog(@"Frame Mode - Header initial frame set: %@ (container width: %.2f)", NSStringFromCGRect(headerView.frame), containerWidth);
            // NSLog(@"Header added with frame layout for frame mode");
        }
        
        // NSLog(@"Header setup completed");
        
        // 约束模式下需要重新设置contentView约束以为header留出空间
        if (self.actualLayoutMode == WGBContainerLayoutModeConstraint) {
            // 移除contentView并重新添加，设置正确的约束
            [self.contentView removeFromSuperview];
            self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:self.contentView];
            
            // contentView在header下方
            [NSLayoutConstraint activateConstraints:@[
                [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
                [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
                [self.contentView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
                [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
            ]];
            
            // NSLog(@"Reset contentView constraints for header in constraint mode");
        }
        
        // 如果配置了限制手势到header区域，将手势从容器移动到header
        if (self.panGesture && self.configuration.restrictGestureToHeader) {
            // 先从容器移除手势
            [self removeGestureRecognizer:self.panGesture];
            // 添加到header
            [headerView addGestureRecognizer:self.panGesture];
            // NSLog(@"Moved pan gesture from container to header view: %@", headerView);
            
            // 确保header可以接收手势
            headerView.userInteractionEnabled = YES;
        }
        
        // 如果是WGBContainerHeaderView，更新其外观并设置容器引用
        if ([headerView isKindOfClass:[WGBContainerHeaderView class]]) {
            WGBContainerHeaderView *standardHeader = (WGBContainerHeaderView *)headerView;
            standardHeader.containerView = self; // 设置容器引用
            [standardHeader updateAppearanceForStyle:self.configuration.style];
        }
    }
    
    // 触发布局更新，确保header和contentView正确定位
    [self updateContentViewForPosition:self.currentPosition];
}

@end
