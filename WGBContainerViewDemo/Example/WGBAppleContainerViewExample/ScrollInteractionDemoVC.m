#import "ScrollInteractionDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface ScrollInteractionDemoVC () <WGBAppleContainerViewDelegate, UITableViewDataSource, UITableViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isScrollingToTop;
@property (nonatomic, assign) BOOL isScrollingToBottom;
@end

@implementation ScrollInteractionDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"滚动联动交互";
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 布局完成后更新 tableView 的 contentSize
}

- (void)setupBackgroundView {
    // 创建背景视图
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor systemOrangeColor];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundView];
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"背景内容\n\n容器在顶部时向下滚动到边界\n会把容器拉下来\n容器在底部时向上滚动到边界\n会把容器推上去\n超出边界 20 点后触发移动";
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
    // 创建配置
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.8;
    config.restrictGestureToHeader = NO; // 禁用header限制，让整个容器可拖拽
    config.respectSafeArea = YES; // 恢复安全区支持
    config.layoutMode = WGBContainerLayoutModeFrame; // 强制使用Frame布局，修复列表滚动问题
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    // Frame布局模式下，容器位置由框架通过frame控制
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with frame layout mode for scroll view compatibility");
    
    // 设置 Header
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"滚动联动 Demo"];
    
    // 添加内容
    [self setupContainerContent];
}

- (void)setupContainerContent {
    // 创建 tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; // 禁用自动调整
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // 关键修复：Frame布局模式下，tableView由框架自动管理frame
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
    return 100; // 增加更多内容来测试滚动边界
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"🎯 滚动联动交互特点：";
        cell.textLabel.textColor = [UIColor systemOrangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"• 容器在顶部时，向下滚动到边界会把容器拉下来";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"• 容器在底部时，向上滚动到边界会把容器推上去";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"• 超出边界 20 点后触发容器移动";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"• 类似微信聊天界面的跟手交互效果";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"• 列表内容已增加到 100 项，便于测试边界";
        cell.textLabel.textColor = [UIColor systemGreenColor];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"列表项目 %ld - 继续滚动测试边界效果", (long)indexPath.row];
        cell.textLabel.textColor = [UIColor labelColor];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 实时检测滚动边界，实现跟手效果
    [self checkScrollBoundary:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始拖拽时重置状态
    self.isScrollingToTop = NO;
    self.isScrollingToBottom = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 停止拖拽时检查边界
    if (!decelerate) {
        [self checkScrollBoundary:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 停止减速时检查边界
    [self checkScrollBoundary:scrollView];
}

- (void)checkScrollBoundary:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // 获取当前容器位置
    WGBContainerPosition currentPosition = self.containerView.currentPosition;
    
    // 当容器在顶部位置时，向下滚动到边界会把容器拉下来
    if (currentPosition == WGBContainerPositionTop) {
        // 检测是否已经滚动到顶部边界
        if (offsetY <= 0) {
            // 计算超出边界的距离，实现跟手效果
            CGFloat overScrollDistance = -offsetY;
            if (overScrollDistance > 0) {
                // 根据超出距离调整容器位置，实现跟手效果
                [self handleOverScrollToBottom:overScrollDistance];
            }
        } else {
            // 重置状态
            self.isScrollingToTop = NO;
        }
    }
    
    // 当容器在底部位置时，向上滚动到边界会把容器推上去
    else if (currentPosition == WGBContainerPositionBottom) {
        // 检测是否已经滚动到底部边界
        if (offsetY >= maxOffsetY && maxOffsetY > 0) {
            // 计算超出边界的距离，实现跟手效果
            CGFloat overScrollDistance = offsetY - maxOffsetY;
            if (overScrollDistance > 0) {
                // 根据超出距离调整容器位置，实现跟手效果
                [self handleOverScrollToTop:overScrollDistance];
            }
        } else {
            // 重置状态
            self.isScrollingToBottom = NO;
        }
    }
    
    // 调试信息：打印滚动位置和边界信息
    NSLog(@"Scroll - offsetY: %.2f, maxOffsetY: %.2f, contentSize: %.2f, frameHeight: %.2f", 
          offsetY, maxOffsetY, scrollView.contentSize.height, scrollView.frame.size.height);
}

- (void)handleOverScrollToBottom:(CGFloat)overScrollDistance {
    // 处理向下超出滚动，容器跟随手指移动
    if (!self.isScrollingToTop) {
        self.isScrollingToTop = YES;
        
        // 根据超出距离决定是否触发容器移动
        if (overScrollDistance > 20) { // 超出 20 点就触发移动
            [self moveContainerToBottom];
        }
    }
}

- (void)handleOverScrollToTop:(CGFloat)overScrollDistance {
    // 处理向上超出滚动，容器跟随手指移动
    if (!self.isScrollingToBottom) {
        self.isScrollingToBottom = YES;
        
        // 根据超出距离决定是否触发容器移动
        if (overScrollDistance > 20) { // 超出 20 点就触发移动
            [self moveContainerToTop];
        }
    }
}

- (void)moveContainerToTop {
    // 容器向上移动到顶部
    [self.containerView moveToPosition:WGBContainerPositionTop animated:YES];
    NSLog(@"容器向上移动到顶部");
}

- (void)moveContainerToBottom {
    // 容器向下移动到底部
    [self.containerView moveToPosition:WGBContainerPositionBottom animated:YES];
    NSLog(@"容器向下移动到底部");
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
    
    // 简化处理：框架已经处理了布局，不需要额外的异步操作
    // 移除dispatch_async和过多调试日志，避免闪烁
}


@end 
