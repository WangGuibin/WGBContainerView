//
//  CollectionViewDemoVC.m
//  WGBAppleContainerViewExample
//
//  Created by CoderWGB on 2025-08-01.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "CollectionViewDemoVC.h"
#import "WGBAppleContainerView-Umbrella.h"

@interface CollectionViewDemoVC () <WGBAppleContainerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
// containerView 属性继承自 BaseContainerDemoVC
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<UIColor *> *colorArray;
@end

@implementation CollectionViewDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"CollectionView Demo";
    [self setupData];
    [self setupBackgroundView];
    [self setupContainerView];
}

- (void)setupData {
    // 准备演示数据 - 各种颜色
    self.colorArray = @[
        [UIColor systemRedColor], [UIColor systemOrangeColor], [UIColor systemYellowColor],
        [UIColor systemGreenColor], [UIColor systemBlueColor], [UIColor systemIndigoColor],
        [UIColor systemPurpleColor], [UIColor systemPinkColor], [UIColor systemTealColor],
        [UIColor systemCyanColor], [UIColor systemMintColor], [UIColor systemBrownColor],
        [UIColor systemGrayColor], [UIColor systemRedColor], [UIColor systemOrangeColor],
        [UIColor systemYellowColor], [UIColor systemGreenColor], [UIColor systemBlueColor],
        [UIColor systemIndigoColor], [UIColor systemPurpleColor], [UIColor systemPinkColor],
        [UIColor systemTealColor], [UIColor systemCyanColor], [UIColor systemMintColor],
        [UIColor systemBrownColor], [UIColor systemGrayColor], [UIColor systemRedColor],
        [UIColor systemOrangeColor], [UIColor systemYellowColor], [UIColor systemGreenColor]
    ];
}

- (void)setupBackgroundView {
    // 创建背景视图
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor systemIndigoColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    
    // 添加背景说明文字
    UILabel *backgroundLabel = [[UILabel alloc] init];
    backgroundLabel.text = @"UICollectionView Demo\n\n展示 UICollectionView\n在容器中的使用\n支持屏幕旋转和\n自动布局更新";
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
    config.restrictGestureToHeader = YES; // 限制手势到header，避免与CollectionView滚动冲突
    config.respectSafeArea = YES;
    config.layoutMode = WGBContainerLayoutModeFrame; // 使用Frame布局，适合CollectionView
    
    // 创建容器视图
    self.containerView = [[WGBAppleContainerView alloc] initWithConfiguration:config];
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];
    
    NSLog(@"📋 Container added with frame layout mode for UICollectionView");
    
    // 设置 Header
    [self.containerView setStandardHeaderWithType:WGBHeaderViewTypeTitle title:@"彩色网格 CollectionView"];
    
    // 添加内容
    [self setupCollectionView];
}

- (void)setupCollectionView {
    // 创建布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
    
    // 创建 UICollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    // 注册 cell
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ColorCell"];
    
    // Frame布局模式下，collectionView由框架自动管理frame
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.containerView.contentView addSubview:self.collectionView];
    
    NSLog(@"📋 UICollectionView added to contentView, frame will be managed by framework");
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    
    // 设置背景色
    cell.backgroundColor = self.colorArray[indexPath.item];
    cell.layer.cornerRadius = 8;
    
    // 添加标签显示索引
    UILabel *label = [cell.contentView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = 100;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        label.textColor = [UIColor whiteColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:label];
        
        [NSLayoutConstraint activateConstraints:@[
            [label.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
            [label.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor]
        ]];
    }
    
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 动态计算 cell 大小，根据容器宽度自适应
    CGFloat containerWidth = CGRectGetWidth(collectionView.bounds);
    if (containerWidth <= 0) {
        containerWidth = [UIScreen mainScreen].bounds.size.width; // 回退值
    }
    
    CGFloat padding = 16 * 2; // 左右边距
    CGFloat spacing = 8 * 2;  // item间距（3列需要2个间距）
    CGFloat availableWidth = containerWidth - padding - spacing;
    CGFloat itemWidth = availableWidth / 3.0; // 3列布局
    
    return CGSizeMake(itemWidth, itemWidth);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UIColor *selectedColor = self.colorArray[indexPath.item];
    NSLog(@"选中了颜色项目 %ld: %@", (long)indexPath.item, selectedColor);
    
    // 可以在这里添加选中效果
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    // 添加选中动画
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }];
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
    
    // 位置改变后，可能需要重新计算 CollectionView 的布局
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    });
}

@end