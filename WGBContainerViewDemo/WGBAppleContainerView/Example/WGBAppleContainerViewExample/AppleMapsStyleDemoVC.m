#import "AppleMapsStyleDemoVC.h"
#import "BaseContainerDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface AppleMapsStyleDemoVC () <WGBAppleContainerViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@end

@implementation AppleMapsStyleDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0f green:arc4random()%256/255.0f  blue:arc4random()%256/255.0f alpha:1.0f];;
    self.title = @"Apple Maps 风格";
    [self setupContainerView];
}

- (void)setupContainerView {
    // 创建 Apple Maps 风格配置
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.95;
    config.restrictGestureToHeader = YES; // 恢复header手势限制
    config.enableFullscreen = YES;
    config.enableBackgroundInteraction = YES;
    config.layoutMode = WGBContainerLayoutModeConstraint; // 强制使用约束布局，获得丝滑动画
    
    // 创建容器视图并设置到基类属性
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // 约束布局模式下，容器本身的布局由框架处理
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with constraint layout mode for smooth animations");
    
    // 设置标准 Header
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"Apple Maps 风格 Demo"];
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
