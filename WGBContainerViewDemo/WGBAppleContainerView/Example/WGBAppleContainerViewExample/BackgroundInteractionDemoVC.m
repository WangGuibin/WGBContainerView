#import "BackgroundInteractionDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface BackgroundInteractionDemoVC () <WGBAppleContainerViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation BackgroundInteractionDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"背景交互效果";
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)setupBackgroundView {
    // 创建背景视图，模拟地图
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor systemPurpleColor];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundView];
    
    // 添加模拟地图元素
    for (int i = 0; i < 8; i++) {
        UIView *pinView = [[UIView alloc] init];
        pinView.backgroundColor = [UIColor systemYellowColor];
        pinView.layer.cornerRadius = 6;
        pinView.frame = CGRectMake(arc4random_uniform(300) + 50, arc4random_uniform(400) + 100, 12, 12);
        [self.backgroundView addSubview:pinView];
    }
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"背景内容\n\n拖拽容器观察背景变化\n缩放和透明度效果";
    backgroundLabel.textAlignment = NSTextAlignmentCenter;
    backgroundLabel.numberOfLines = 0;
    backgroundLabel.textColor = [UIColor whiteColor];
    backgroundLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundView addSubview:backgroundLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [backgroundLabel.centerXAnchor constraintEqualToAnchor:self.backgroundView.centerXAnchor],
        [backgroundLabel.centerYAnchor constraintEqualToAnchor:self.backgroundView.centerYAnchor]
    ]];
}

- (void)setupContainerView {
    // 创建配置，启用背景交互
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.8;
    config.enableBackgroundInteraction = YES;  // 启用背景交互效果
    config.restrictGestureToHeader = YES; // 恢复header手势限制
    config.layoutMode = WGBContainerLayoutModeConstraint; // 强制使用约束布局，获得丝滑动画
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // 约束布局模式下，容器本身的布局由框架处理
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with constraint layout mode for smooth animations");
    
    // 设置 Header
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"背景交互 Demo"];
    
    // 添加内容
    [self setupContainerContent];
}

- (void)setupContainerContent {
    // 创建说明文字
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"🎯 背景交互效果特点：\n\n• 拖拽时背景会缩放\n• 背景透明度会变化\n• 创造层次感和沉浸感\n• 类似 Apple Maps 效果\n\n💡 尝试拖拽容器观察背景变化";
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.translatesAutoresizingMaskIntoConstraints = NO; // 约束布局模式
    [self.containerView.contentView addSubview:contentLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [contentLabel.centerXAnchor constraintEqualToAnchor:self.containerView.contentView.centerXAnchor],
        [contentLabel.centerYAnchor constraintEqualToAnchor:self.containerView.contentView.centerYAnchor],
        [contentLabel.leadingAnchor constraintEqualToAnchor:self.containerView.contentView.leadingAnchor constant:20],
        [contentLabel.trailingAnchor constraintEqualToAnchor:self.containerView.contentView.trailingAnchor constant:-20]
    ]];
    
    NSLog(@"📋 ContentLabel added with constraint layout for smooth positioning");
}

#pragma mark - WGBAppleContainerViewDelegate

- (void)containerView:(WGBAppleContainerView *)containerView 
     willMoveToPosition:(WGBContainerPosition)position 
              animated:(BOOL)animated {
    NSLog(@"容器即将移动到位置: %ld", (long)position);
}

- (void)containerView:(WGBAppleContainerView *)containerView 
      didMoveToPosition:(WGBContainerPosition)position {
    NSLog(@"容器已移动到位置: %ld", (long)position);
    
    // 简化处理：框架已经处理了布局，不需要额外操作
}

- (void)containerView:(WGBAppleContainerView *)containerView
 updateBackgroundScale:(CGFloat)scale
                alpha:(CGFloat)alpha
               offset:(CGFloat)offset {
    // 应用背景缩放和透明度变化
    self.backgroundView.transform = CGAffineTransformMakeScale(scale, scale);
    self.backgroundView.alpha = alpha;
}

@end 