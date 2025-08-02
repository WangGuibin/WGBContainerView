#import "HeaderRestrictDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface HeaderRestrictDemoVC () <WGBAppleContainerViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HeaderRestrictDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Header 手势限制";
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupBackgroundView {
    // 创建背景视图
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor systemGreenColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"背景内容\n\n只有 Header 区域可以拖拽\n内容区域可以正常滚动";
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
    // 创建配置，启用 Header 手势限制
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.8;
    config.restrictGestureToHeader = NO; // 禁用header限制，测试容器拖拽
    config.enableFullscreen = NO;
    config.layoutMode = WGBContainerLayoutModeFrame; // 强制使用Frame布局，修复列表滚动问题
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // Frame布局模式下，容器位置由框架通过frame控制
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with frame layout mode for scroll view compatibility");
    
    // 设置 Header
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"Header 手势限制 Demo"];
    
    // 添加内容
    [self setupContainerContent];
}

- (void)setupContainerContent {
    // 创建 tableView 作为内容
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; // 禁用自动调整
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Frame布局模式下，tableView由框架自动管理frame
    self.tableView.translatesAutoresizingMaskIntoConstraints = YES; // 启用frame布局
    [self.containerView.contentView addSubview:self.tableView];
    
    // 确保初始数据加载
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        NSLog(@"📋 Initial tableView data reload triggered");
    });
    
    NSLog(@"📋 TableView added to contentView, frame will be managed by framework");
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"🎯 Header 手势限制特点：";
        cell.textLabel.textColor = [UIColor systemOrangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"• 只有 Header 区域可以拖拽容器";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"• 内容区域可以正常滚动";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"• 避免拖拽与滚动冲突";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"内容项目 %ld - 可以正常滚动", (long)indexPath.row];
        cell.textLabel.textColor = [UIColor labelColor];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - WGBAppleContainerViewDelegate

- (void)containerView:(WGBAppleContainerView *)containerView 
     willMoveToPosition:(WGBContainerPosition)position 
              animated:(BOOL)animated {
    // 容器位置改变前的准备
}

- (void)containerView:(WGBAppleContainerView *)containerView 
      didMoveToPosition:(WGBContainerPosition)position {
    NSLog(@"容器已移动到位置: %ld", (long)position);
    
    // 简化处理：框架已经处理了布局，不需要手动调整tableView
    // 移除可能导致闪烁的contentInset重置和布局强制更新
}

@end 