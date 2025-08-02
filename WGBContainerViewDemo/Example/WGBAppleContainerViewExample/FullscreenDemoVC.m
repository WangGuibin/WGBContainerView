#import "FullscreenDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface FullscreenDemoVC () <WGBAppleContainerViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL isFullscreen;
@end

@implementation FullscreenDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"全屏模式";
    self.isFullscreen = NO;
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 初始状态显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    // 确保导航栏透明度为 1.0
    self.navigationController.navigationBar.alpha = 1.0;
}

- (void)setupBackgroundView {
    // 创建背景视图，模拟地图或内容
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor orangeColor];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundView];
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"背景内容\n\n拖拽容器到顶部体验全屏模式";
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
    // 创建配置，启用全屏模式
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.0;       // 顶部位置设为 0，实现全屏
    config.middlePositionRatio = 0.5;    // 中间位置
    config.bottomPositionRatio = 0.8;    // 底部位置
    config.enableFullscreen = YES;       // 启用全屏模式
    config.restrictGestureToHeader = YES; // 恢复header手势限制
    config.layoutMode = WGBContainerLayoutModeConstraint; // 强制使用约束布局，获得丝滑动画
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // 约束布局模式下，容器本身的布局由框架处理
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with constraint layout mode for smooth animations");
    
    // 设置自定义 Header
    [self setupCustomHeader];
    
    // 添加内容
    [self setupContainerContent];
}

- (void)setupCustomHeader {
    // 创建自定义 Header 内容
    UIView *customContent = [[UIView alloc] init];
    customContent.backgroundColor = [UIColor clearColor];
    
    // 创建返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.backButton.tintColor = [UIColor systemBlueColor];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.backButton.alpha = 0.0; // 初始状态隐藏
    [customContent addSubview:self.backButton];
    
    // 创建标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"全屏模式 Demo";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [customContent addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.backButton.leadingAnchor constraintEqualToAnchor:customContent.leadingAnchor constant:16],
        [self.backButton.centerYAnchor constraintEqualToAnchor:customContent.centerYAnchor],
        [self.backButton.widthAnchor constraintEqualToConstant:60],
        [self.backButton.heightAnchor constraintEqualToConstant:44], // 调整按钮高度为标准44
        
        [titleLabel.centerXAnchor constraintEqualToAnchor:customContent.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:customContent.centerYAnchor],
        [titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.backButton.trailingAnchor constant:8],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:customContent.trailingAnchor constant:-16],
        
        [customContent.heightAnchor constraintEqualToConstant:84] // 全屏模式使用84高度，适配刘海屏
    ]];
    
    WGBContainerHeaderView *customHeader = [WGBContainerHeaderView headerWithCustomContent:customContent];
    self.containerView.headerView = customHeader;
}

- (void)setupContainerContent {
    // 创建说明文字
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"🎯 全屏模式特点：\n\n• 容器可以滑到屏幕最顶部\n• 全屏时导航栏自动隐藏\n• 自定义返回按钮直接跳转到底部\n• 根据滚动偏移量进行渐变处理\n• 类似淘宝二楼、京东生活交互\n\n💡 尝试拖拽到顶部位置体验渐变效果";
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

- (void)backButtonTapped {
    // 返回按钮点击，直接跳转到底部位置
    [self.containerView moveToPosition:WGBContainerPositionBottom animated:YES];
}

#pragma mark - WGBAppleContainerViewDelegate

- (void)containerView:(WGBAppleContainerView *)containerView 
     willMoveToPosition:(WGBContainerPosition)position 
              animated:(BOOL)animated {
    // 根据位置决定是否隐藏导航栏和返回按钮
    BOOL shouldHideNavBar = (position == WGBContainerPositionTop);
    
    if (shouldHideNavBar != self.isFullscreen) {
        self.isFullscreen = shouldHideNavBar;
        [self.navigationController setNavigationBarHidden:shouldHideNavBar animated:animated];
    }
    
    // 根据位置控制返回按钮显示
    [self updateBackButtonVisibility:position];
}

- (void)containerView:(WGBAppleContainerView *)containerView 
      didMoveToPosition:(WGBContainerPosition)position {
    NSLog(@"容器已移动到位置: %ld", (long)position);
    
    // 简化处理：框架已经处理了布局，只处理全屏模式UI更新
    if (position == WGBContainerPositionTop) {
        NSLog(@"进入全屏模式");
    } else if (position == WGBContainerPositionBottom) {
        if (self.isFullscreen) {
            self.isFullscreen = NO;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
        [self updateBackButtonVisibility:position];
        NSLog(@"退出全屏模式");
    }
}

- (void)containerView:(WGBAppleContainerView *)containerView 
       didChangeOffset:(CGFloat)offset 
            percentage:(CGFloat)percentage {
    // 根据滚动偏移量进行渐变处理
   // [self updateUIWithPercentage:percentage];
}

- (void)updateBackButtonVisibility:(WGBContainerPosition)position {
    // 根据位置控制返回按钮显示/隐藏
    BOOL shouldShowBackButton = (position == WGBContainerPositionTop);
    self.backButton.alpha = shouldShowBackButton?  1.0 : 0.0;
    self.navigationController.navigationBar.hidden = shouldShowBackButton;

}

- (void)updateUIWithPercentage:(CGFloat)percentage {
    // 根据滚动百分比进行渐变处理
    // percentage: 0.0 (底部) -> 1.0 (顶部)
    
    // 导航栏透明度渐变：从完全显示渐变到完全隐藏
    CGFloat navBarAlpha = 1.0 - percentage;
    navBarAlpha = MAX(0.0, MIN(1.0, navBarAlpha));
    self.navigationController.navigationBar.alpha = navBarAlpha;
    
    // 返回按钮透明度渐变：只在接近顶部时显示
    CGFloat backButtonAlpha = 0.0;
    if (percentage > 0.7) {
        backButtonAlpha = (percentage - 0.7) / 0.3; // 0.7-1.0 区间渐变
    }
    backButtonAlpha = MAX(0.0, MIN(1.0, backButtonAlpha));
    self.backButton.alpha = backButtonAlpha;
    
    // 背景视图透明度渐变
    self.backgroundView.alpha = 1.0 - (percentage * 0.2);
}

@end 
