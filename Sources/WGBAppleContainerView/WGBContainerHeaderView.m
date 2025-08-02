//
//  WGBContainerHeaderView.m
//  WGBAppleContainerView
//
//  Created by CoderWGB on 2025-07-30.
//  Copyright © 2025 CoderWGB All rights reserved.
//

#import "WGBContainerHeaderView.h"
#import "WGBAppleContainerView.h"

@interface WGBContainerHeaderView () <UISearchBarDelegate>

@property (nonatomic, assign) WGBHeaderViewType headerType;
@property (nonatomic, strong) UIView *gripView;
@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UISearchBar *searchBar;
@property (nonatomic, strong, nullable) UIView *customContentView;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation WGBContainerHeaderView

#pragma mark - Class Methods

+ (instancetype)headerWithGrip {
    WGBContainerHeaderView *header = [[WGBContainerHeaderView alloc] initWithType:WGBHeaderViewTypeGrip];
    return header;
}

+ (instancetype)headerWithTitle:(NSString *)title {
    WGBContainerHeaderView *header = [[WGBContainerHeaderView alloc] initWithType:WGBHeaderViewTypeTitle];
    header.titleLabel.text = title;
    return header;
}

+ (instancetype)headerWithSearchPlaceholder:(NSString *)placeholder {
    WGBContainerHeaderView *header = [[WGBContainerHeaderView alloc] initWithType:WGBHeaderViewTypeSearch];
    header.searchBar.placeholder = placeholder;
    return header;
}

+ (instancetype)headerWithCustomContent:(UIView *)contentView {
    WGBContainerHeaderView *header = [[WGBContainerHeaderView alloc] initWithType:WGBHeaderViewTypeCustom];
    header.customContentView = contentView;
    [header setupCustomContent];
    return header;
}

#pragma mark - Initialization

- (instancetype)initWithType:(WGBHeaderViewType)type {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _headerType = type;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithType:WGBHeaderViewTypeGrip];
}

#pragma mark - Setup

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self createGripView];
    [self createSeparatorLine];
    
    switch (self.headerType) {
        case WGBHeaderViewTypeGrip:
            [self setupGripOnlyLayout];
            break;
        case WGBHeaderViewTypeTitle:
            [self createTitleLabel];
            [self setupTitleLayout];
            break;
        case WGBHeaderViewTypeSearch:
            [self createSearchBar];
            [self setupSearchLayout];
            break;
        case WGBHeaderViewTypeCustom:
            // Custom content will be added later
            [self setupGripOnlyLayout];
            break;
    }
}

- (void)createGripView {
    self.gripView = [[UIView alloc] init];
    self.gripView.backgroundColor = [UIColor systemGray3Color];
    self.gripView.layer.cornerRadius = 3.0;
    self.gripView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.gripView];
}

- (void)createTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];
}

- (void)createSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.searchBar];
}

- (void)createSeparatorLine {
    self.separatorLine = [[UIView alloc] init];
    self.separatorLine.backgroundColor = [UIColor separatorColor];
    self.separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.separatorLine];
}

#pragma mark - Layout

- (void)setupGripOnlyLayout {
    [NSLayoutConstraint activateConstraints:@[
        [self.gripView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.gripView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.gripView.widthAnchor constraintEqualToConstant:40],
        [self.gripView.heightAnchor constraintEqualToConstant:6],
        
        [self.separatorLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.separatorLine.heightAnchor constraintEqualToConstant:0.5],
        
        [self.heightAnchor constraintEqualToConstant:60] // 从20调整为60
    ]];
}

- (void)setupTitleLayout {
    [NSLayoutConstraint activateConstraints:@[
        [self.gripView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.gripView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.gripView.widthAnchor constraintEqualToConstant:40],
        [self.gripView.heightAnchor constraintEqualToConstant:6],
        
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.gripView.bottomAnchor constant:12],
        [self.titleLabel.heightAnchor constraintEqualToConstant:24],
        
        [self.separatorLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.separatorLine.heightAnchor constraintEqualToConstant:0.5],
        
        [self.heightAnchor constraintEqualToConstant:60] // 从52调整为60
    ]];
}

- (void)setupSearchLayout {
    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.searchBar.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
        [self.searchBar.heightAnchor constraintEqualToConstant:56],
        
        [self.separatorLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.separatorLine.heightAnchor constraintEqualToConstant:0.5],
        
        [self.heightAnchor constraintEqualToConstant:60]
    ]];
}

- (void)setupCustomContent {
    if (!self.customContentView) return;
    
    // 移除默认布局
    [self removeConstraints:self.constraints];
    
    self.customContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.customContentView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.gripView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.gripView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.gripView.widthAnchor constraintEqualToConstant:40],
        [self.gripView.heightAnchor constraintEqualToConstant:6],
        
        [self.customContentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.customContentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.customContentView.topAnchor constraintEqualToAnchor:self.gripView.bottomAnchor constant:8],
        [self.customContentView.bottomAnchor constraintEqualToAnchor:self.separatorLine.topAnchor],
        
        [self.separatorLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.separatorLine.heightAnchor constraintEqualToConstant:0.5]
    ]];
}

#pragma mark - Appearance

- (void)updateAppearanceForStyle:(NSInteger)style {
    switch (style) {
        case 0: // Light
            self.gripView.backgroundColor = [UIColor systemGray3Color];
            self.separatorLine.backgroundColor = [UIColor separatorColor];
            self.titleLabel.textColor = [UIColor labelColor];
            if (self.searchBar) {
                self.searchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
            }
            break;
        case 1: // Dark
            self.gripView.backgroundColor = [UIColor systemGray2Color];
            self.separatorLine.backgroundColor = [UIColor separatorColor];
            self.titleLabel.textColor = [UIColor labelColor];
            if (self.searchBar) {
                self.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
            }
            break;
        case 2: // Extra Light
            self.gripView.backgroundColor = [UIColor systemGray4Color];
            self.separatorLine.backgroundColor = [UIColor separatorColor];
            self.titleLabel.textColor = [UIColor labelColor];
            if (self.searchBar) {
                self.searchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
            }
            break;
        default:
            [self updateAppearanceForStyle:0];
            break;
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    // 自动移动容器到顶部位置并聚焦搜索框
    if (self.containerView) {
        [self.containerView moveToPosition:WGBContainerPositionTop animated:YES];
    }
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(headerView:searchBarDidBeginEditing:)]) {
        [self.delegate headerView:self searchBarDidBeginEditing:searchBar];
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // 通知代理搜索文本变化
    if ([self.delegate respondsToSelector:@selector(headerView:searchBar:textDidChange:)]) {
        [self.delegate headerView:self searchBar:searchBar textDidChange:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
