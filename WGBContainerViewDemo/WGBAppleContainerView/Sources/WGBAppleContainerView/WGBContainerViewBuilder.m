//
//  WGBContainerViewBuilder.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "WGBContainerViewBuilder.h"

@implementation WGBContainerViewBuilder

+ (WGBAppleContainerView *)createDefaultContainer {
    WGBContainerConfiguration *config = [WGBContainerConfiguration defaultConfiguration];
    return [[WGBAppleContainerView alloc] initWithConfiguration:config];
}

+ (WGBAppleContainerView *)createAppleMapsContainer {
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    return [[WGBAppleContainerView alloc] initWithConfiguration:config];
}

+ (WGBAppleContainerView *)createContainerWithConfiguration:(WGBContainerConfiguration *)configuration {
    return [[WGBAppleContainerView alloc] initWithConfiguration:configuration];
}

+ (void)addContainer:(WGBAppleContainerView *)container toParentView:(UIView *)parentView {
    if (!container || !parentView) return;
    
    [parentView addSubview:container];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [container.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor],
        [container.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor],
        [container.topAnchor constraintEqualToAnchor:parentView.topAnchor],
        [container.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor]
    ]];
}

+ (void)addContainer:(WGBAppleContainerView *)container toViewController:(UIViewController *)viewController {
    if (!container || !viewController) return;
    
    [self addContainer:container toParentView:viewController.view];
    [viewController addChildViewController:(UIViewController *)container];
}

+ (WGBAppleContainerView *)loadContainerFromNib:(NSString *)nibName 
                                         bundle:(NSBundle *)bundle
                                  configuration:(WGBContainerConfiguration *)configuration {
    if (!nibName) return nil;
    
    NSBundle *targetBundle = bundle ?: [NSBundle mainBundle];
    NSArray *nibContents = [targetBundle loadNibNamed:nibName owner:nil options:nil];
    
    for (id object in nibContents) {
        if ([object isKindOfClass:[WGBContainerViewIB class]]) {
            WGBContainerViewIB *ibView = (WGBContainerViewIB *)object;
            return ibView.containerView;
        }
    }
    
    WGBContainerConfiguration *config = configuration ?: [WGBContainerConfiguration defaultConfiguration];
    return [[WGBAppleContainerView alloc] initWithConfiguration:config];
}

+ (void)handleDeviceRotation:(WGBAppleContainerView *)container
                      toSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (!container || !coordinator) return;
    
    [container transitionToSize:size withTransitionCoordinator:coordinator];
}

@end

#pragma mark - Interface Builder Support

@interface WGBContainerViewIB ()
@property (nonatomic, strong) WGBAppleContainerView *containerView;
@end

@implementation WGBContainerViewIB

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults];
        [self createContainerView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDefaults];
        [self createContainerView];
    }
    return self;
}

- (void)setupDefaults {
    _topPositionRatio = 0.1;
    _middlePositionRatio = 0.5;
    _bottomPositionRatio = 0.85;
    _enableMiddlePosition = YES;
    _cornerRadius = 16.0;
    _enableShadow = YES;
    _enablePanGesture = YES;
    _containerStyle = WGBContainerStyleLight;
}

- (void)createContainerView {
    WGBContainerConfiguration *config = [[WGBContainerConfiguration alloc] init];
    config.topPositionRatio = self.topPositionRatio;
    config.middlePositionRatio = self.middlePositionRatio;
    config.bottomPositionRatio = self.bottomPositionRatio;
    config.enableMiddlePosition = self.enableMiddlePosition;
    config.cornerRadius = self.cornerRadius;
    config.enableShadow = self.enableShadow;
    config.enablePanGesture = self.enablePanGesture;
    config.style = (WGBContainerStyle)self.containerStyle;
    
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    [self addSubview:self.containerView];
    
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self createContainerView];
}

#pragma mark - Property Updates

- (void)setTopPositionRatio:(CGFloat)topPositionRatio {
    _topPositionRatio = topPositionRatio;
    [self updateConfiguration];
}

- (void)setMiddlePositionRatio:(CGFloat)middlePositionRatio {
    _middlePositionRatio = middlePositionRatio;
    [self updateConfiguration];
}

- (void)setBottomPositionRatio:(CGFloat)bottomPositionRatio {
    _bottomPositionRatio = bottomPositionRatio;
    [self updateConfiguration];
}

- (void)setEnableMiddlePosition:(BOOL)enableMiddlePosition {
    _enableMiddlePosition = enableMiddlePosition;
    [self updateConfiguration];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateConfiguration];
}

- (void)setEnableShadow:(BOOL)enableShadow {
    _enableShadow = enableShadow;
    [self updateConfiguration];
}

- (void)setEnablePanGesture:(BOOL)enablePanGesture {
    _enablePanGesture = enablePanGesture;
    [self updateConfiguration];
}

- (void)setContainerStyle:(NSInteger)containerStyle {
    _containerStyle = containerStyle;
    [self updateConfiguration];
}

- (void)updateConfiguration {
    if (self.containerView) {
        self.containerView.configuration.topPositionRatio = self.topPositionRatio;
        self.containerView.configuration.middlePositionRatio = self.middlePositionRatio;
        self.containerView.configuration.bottomPositionRatio = self.bottomPositionRatio;
        self.containerView.configuration.enableMiddlePosition = self.enableMiddlePosition;
        self.containerView.configuration.cornerRadius = self.cornerRadius;
        self.containerView.configuration.enableShadow = self.enableShadow;
        self.containerView.configuration.enablePanGesture = self.enablePanGesture;
        self.containerView.configuration.style = (WGBContainerStyle)self.containerStyle;
        
        [self.containerView refreshLayout];
    }
}

@end
