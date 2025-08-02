//
//  NonIntrusiveDemoVC.m
//  WGBAppleContainerViewExample
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "NonIntrusiveDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface NonIntrusiveDemoVC () <WGBAppleContainerViewDelegate, UITableViewDataSource, UITableViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *dataArray;
@property (nonatomic, assign) BOOL hasPerformedInitialDataLoad;
@end

@implementation NonIntrusiveDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemPurpleColor];
    self.title = @"非侵入式架构演示";
    
    // 准备业务数据
    self.dataArray = [NSMutableArray array];
    self.hasPerformedInitialDataLoad = NO;
    
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)setupBackgroundView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor systemPurpleColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"非侵入式架构\n\n业务方完全控制\n数据渲染和布局更新\n\n框架只提供回调时机\n不自动执行任何操作";
    backgroundLabel.textAlignment = NSTextAlignmentCenter;
    backgroundLabel.numberOfLines = 0;
    backgroundLabel.textColor = [UIColor whiteColor];
    backgroundLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:backgroundLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [backgroundLabel.centerXAnchor constraintEqualToAnchor:backgroundView.centerXAnchor],
        [backgroundLabel.centerYAnchor constraintEqualToAnchor:backgroundView.centerYAnchor]
    ]];
}

- (void)setupContainerView {
    WGBContainerConfiguration *config = [WGBContainerConfiguration appleMapsConfiguration];
    config.topPositionRatio = 0.1;
    config.middlePositionRatio = 0.5;
    config.bottomPositionRatio = 0.8;
    config.restrictGestureToHeader = YES;
    config.respectSafeArea = YES;
    config.layoutMode = WGBContainerLayoutModeFrame;
    
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];
    
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"业务方控制的数据"];
    
    NSLog(@"🎯 NonIntrusive Demo - Container setup completed");
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = YES; // Frame 模式
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.containerView.contentView addSubview:self.tableView];
    
    // 立即设置初始布局
    [self updateMyOwnLayout];
    
    NSLog(@"🎯 NonIntrusive Demo - TableView created and added to contentView");
}

#pragma mark - 业务数据管理（完全由业务方控制）

- (void)performMyOwnDataLoading {
    if (self.hasPerformedInitialDataLoad) {
        NSLog(@"🎯 Business Logic - Data already loaded, skipping");
        return;
    }
    
    // 模拟数据加载
    [self.dataArray removeAllObjects];
    for (int i = 0; i < 50; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"业务数据项 %d - 由业务方完全控制", i]];
    }
    
    NSLog(@"🎯 Business Logic - Created %lu data items", (unsigned long)self.dataArray.count);
    
    // 重新加载表格数据
    if (self.tableView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.hasPerformedInitialDataLoad = YES;
            NSLog(@"🎯 Business Logic - Data loaded and tableView reloaded (%lu items)", (unsigned long)self.dataArray.count);
            NSLog(@"🎯 Business Logic - TableView frame after reload: %@", NSStringFromCGRect(self.tableView.frame));
            
            // 确保布局正确
            [self updateMyOwnLayout];
        });
    } else {
        NSLog(@"🚨 Business Logic - ERROR: TableView is nil, cannot reload data!");
    }
}

- (void)updateMyOwnLayout {
    if (self.tableView && self.containerView.contentView) {
        // 业务方决定如何更新布局
        CGRect contentBounds = self.containerView.contentView.bounds;
        self.tableView.frame = contentBounds;
        
        NSLog(@"🎯 Business Logic - Layout updated to frame: %@", NSStringFromCGRect(self.tableView.frame));
        NSLog(@"🎯 Business Logic - ContentView bounds: %@", NSStringFromCGRect(contentBounds));
        
        // 如果布局有变化，确保 TableView 重新显示
        if (!CGRectIsEmpty(contentBounds)) {
            [self.tableView setNeedsLayout];
            [self.tableView layoutIfNeeded];
        }
    }
}

#pragma mark - WGBAppleContainerViewDelegate（非侵入式回调）

- (void)containerView:(WGBAppleContainerView *)containerView didSetupContentView:(UIView *)contentView {
    NSLog(@"🎯 Delegate Callback - didSetupContentView, now I can add my subviews");
    [self setupTableView];  // 在此时机设置 TableView
    
    // 确保在 TableView 设置完成后立即尝试加载数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performMyOwnDataLoading];
    });
}

- (BOOL)containerView:(WGBAppleContainerView *)containerView shouldPerformInitialDataRenderForContentView:(UIView *)contentView {
    if (contentView == self.tableView) {
        NSLog(@"🎯 Delegate Callback - shouldPerformInitialDataRender for TableView, I will handle it myself");
        [self performMyOwnDataLoading];  // 业务方自己处理数据加载
        return YES;  // 返回 YES，告诉框架我已经处理了，不需要框架再处理
    }
    return NO;  // 其他视图让框架处理
}

- (BOOL)containerView:(WGBAppleContainerView *)containerView shouldUpdateLayoutForContentView:(UIView *)contentView {
    if (contentView == self.tableView) {
        NSLog(@"🎯 Delegate Callback - shouldUpdateLayoutForContentView for TableView, I will handle it myself");
        [self updateMyOwnLayout];  // 业务方自己处理布局更新
        return YES;  // 返回 YES，告诉框架我已经处理了
    }
    return NO;  // 其他视图让框架处理
}

- (void)containerView:(WGBAppleContainerView *)containerView willUpdateLayout:(WGBContainerPosition)position animated:(BOOL)animated {
    NSLog(@"🎯 Delegate Callback - willUpdateLayout for position: %ld, animated: %d", (long)position, animated);
    // 业务方可以在布局更新前做准备工作
}

- (void)containerView:(WGBAppleContainerView *)containerView didUpdateLayout:(WGBContainerPosition)position {
    NSLog(@"🎯 Delegate Callback - didUpdateLayout for position: %ld", (long)position);
    // 业务方可以在布局更新后做后续处理
    [self updateMyOwnLayout];  // 确保布局更新后重新设置 TableView frame
}

- (void)containerView:(WGBAppleContainerView *)containerView willTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"🎯 Delegate Callback - willTransitionToSize: %@", NSStringFromCGSize(size));
    // 业务方可以在屏幕旋转前做准备
}

- (void)containerView:(WGBAppleContainerView *)containerView didTransitionToSize:(CGSize)size {
    NSLog(@"🎯 Delegate Callback - didTransitionToSize: %@", NSStringFromCGSize(size));
    // 业务方可以在屏幕旋转后做处理
    [self updateMyOwnLayout];  // 旋转完成后更新布局
}

- (void)containerView:(WGBAppleContainerView *)containerView willMoveToPosition:(WGBContainerPosition)position animated:(BOOL)animated {
    NSLog(@"🎯 Delegate Callback - willMoveToPosition: %ld", (long)position);
}

- (void)containerView:(WGBAppleContainerView *)containerView didMoveToPosition:(WGBContainerPosition)position {
    NSLog(@"🎯 Delegate Callback - didMoveToPosition: %ld", (long)position);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"🎯 TableView DataSource - numberOfRowsInSection called, returning %lu", (unsigned long)self.dataArray.count);
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"🎯 非侵入式架构特点：";
        cell.textLabel.textColor = [UIColor systemPurpleColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"• 框架只提供回调时机，不自动执行操作";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"• 业务方通过代理回调完全控制数据和布局";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"• 支持业务方选择性处理某些视图";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"• 框架扩展作为便利实现，业务方可选择使用";
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if (indexPath.row < self.dataArray.count) {
        // 确保不会越界访问
        cell.textLabel.text = self.dataArray[indexPath.row];
        cell.textLabel.textColor = [UIColor labelColor];
    } else {
        // 安全回退
        cell.textLabel.text = [NSString stringWithFormat:@"数据项 %ld", (long)indexPath.row];
        cell.textLabel.textColor = [UIColor labelColor];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"🎯 Business Logic - Selected row %ld: %@", (long)indexPath.row, self.dataArray[indexPath.row]);
}

@end
