#import "DemoListViewController.h"
#import "AppleMapsStyleDemoVC.h"
#import "FullscreenDemoVC.h"
#import "HeaderRestrictDemoVC.h"
#import "BackgroundInteractionDemoVC.h"
#import "HeaderStylesDemoVC.h"
#import "ScrollInteractionDemoVC.h"
#import "CollectionViewDemoVC.h"
#import "NonIntrusiveDemoVC.h"

@interface DemoListViewController ()
@property (nonatomic, strong) NSArray<NSDictionary *> *demoList;
@end

@implementation DemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo 列表";
    self.demoList = @[
        @{@"title": @"Apple Maps 风格", @"class": @"AppleMapsStyleDemoVC"},
        @{@"title": @"全屏模式", @"class": @"FullscreenDemoVC"},
        @{@"title": @"Header 手势限制", @"class": @"HeaderRestrictDemoVC"},
        @{@"title": @"背景交互效果", @"class": @"BackgroundInteractionDemoVC"},
        @{@"title": @"Header 样式", @"class": @"HeaderStylesDemoVC"},
        @{@"title": @"滚动联动交互", @"class": @"ScrollInteractionDemoVC"},
        @{@"title": @"CollectionView 演示", @"class": @"CollectionViewDemoVC"},
        @{@"title": @"非侵入式架构演示", @"class": @"NonIntrusiveDemoVC"},
    ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 确保数据在视图出现时刷新
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.demoList[indexPath.row][@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *className = self.demoList[indexPath.row][@"class"];
    Class vcClass = NSClassFromString(className);
    if (vcClass) {
        UIViewController *vc = [[vcClass alloc] init];
        vc.title = self.demoList[indexPath.row][@"title"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end 