#import "HeaderStylesDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface HeaderStylesDemoVC () <WGBAppleContainerViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UISegmentedControl *styleSegment;
@end

@implementation HeaderStylesDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Header 样式";
    [self setupBackgroundView];
    [self setupContainerView];
    [self setupStyleSelector];
}

- (void)setupBackgroundView {
    // 创建背景视图
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor systemTealColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"背景内容\n\n切换不同 Header 样式\n体验不同的交互效果";
    backgroundLabel.textAlignment = NSTextAlignmentCenter;
    backgroundLabel.numberOfLines = 0;
    backgroundLabel.textColor = [UIColor whiteColor];
    backgroundLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:backgroundLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [backgroundLabel.centerXAnchor constraintEqualToAnchor:backgroundView.centerXAnchor],
        [backgroundLabel.centerYAnchor constraintEqualToAnchor:backgroundView.centerYAnchor]
    ]];
}

- (void)setupContainerView {
    // 创建配置
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.8;
    config.restrictGestureToHeader = YES; // 恢复header手势限制
    config.layoutMode = WGBContainerLayoutModeConstraint; // 强制使用约束布局，获得丝滑动画
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // 约束布局模式下，容器本身的布局由框架处理
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with constraint layout mode for smooth animations");
    
    // 默认设置 Title 样式
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"Header 样式 Demo"];
    
    // 添加内容
    [self setupContainerContent];
}

- (void)setupContainerContent {
    // 创建说明文字
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"🎯 Header 样式特点：\n\n• Grip：简洁的拖拽指示器\n• Title：带标题的 Header\n• Search：搜索框样式\n• Custom：自定义样式\n\n💡 使用上方选择器切换样式";
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

- (void)setupStyleSelector {
    // 创建样式选择器
    NSArray *styles = @[@"Grip", @"Title", @"Search", @"Custom"];
    self.styleSegment = [[UISegmentedControl alloc] initWithItems:styles];
    self.styleSegment.selectedSegmentIndex = 1; // 默认选择 Title
    [self.styleSegment addTarget:self action:@selector(styleChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.styleSegment.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.styleSegment];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.styleSegment.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.styleSegment.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.styleSegment.widthAnchor constraintEqualToConstant:300]
    ]];
}

- (void)styleChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: // Grip
            [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeGrip title:nil];
            break;
        case 1: // Title
            [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"Header 样式 Demo"];
            break;
        case 2: // Search
            [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeSearch title:@"点击搜索框自动弹到顶部"];
            break;
        case 3: // Custom
            [self createCustomHeader];
            break;
    }
}

- (void)createCustomHeader {
    // 创建自定义 Header 内容
    UIView *customContent = [[UIView alloc] init];
    customContent.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:@"star.fill"];
    iconView.tintColor = [UIColor systemYellowColor];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [customContent addSubview:iconView];
    
    UILabel *customLabel = [[UILabel alloc] init];
    customLabel.text = @"⭐ 自定义 Header - 拖拽此区域";
    customLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    customLabel.textColor = [UIColor labelColor];
    customLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [customContent addSubview:customLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:customContent.leadingAnchor constant:16],
        [iconView.centerYAnchor constraintEqualToAnchor:customContent.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:20],
        [iconView.heightAnchor constraintEqualToConstant:20],
        
        [customLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:8],
        [customLabel.trailingAnchor constraintEqualToAnchor:customContent.trailingAnchor constant:-16],
        [customLabel.centerYAnchor constraintEqualToAnchor:customContent.centerYAnchor],
        
        [customContent.heightAnchor constraintEqualToConstant:60] // 调整为60，与其他header保持一致
    ]];
    
    WGBContainerHeaderView *customHeader = [WGBContainerHeaderView headerWithCustomContent:customContent];
    self.containerView.headerView = customHeader;
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

@end 