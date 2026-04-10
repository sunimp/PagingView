# PagingView

[![CI](https://github.com/sunimp/PagingView/actions/workflows/ci.yml/badge.svg)](https://github.com/sunimp/PagingView/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.10-orange)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

`PagingView` 是一个面向 iOS 的分页容器组件，提供 UIKit 内核与 SwiftUI 封装，支持顶部 Header、SegmentedView、横向分页、列表滚动联动与吸顶场景。

## 特性

- UIKit 核心能力：`PagingView` + `SegmentedView`
- SwiftUI 封装：`PagerView`、`CombinedSegmentView`、`SegmentView`
- 支持 Header 吸顶、分页切换、指示器动画、列表懒加载
- 同仓库包含一个统一 Demo App，内部区分 UIKit 与 SwiftUI 两套示例
- 以 Swift Package 形式分发，便于集成

## 环境要求

- iOS 15.0+
- Xcode 15+
- Swift 5.10+

## 安装

当前仓库尚未发布语义化版本标签，建议先以默认分支接入：

```swift
dependencies: [
    .package(url: "https://github.com/sunimp/PagingView.git", branch: "main")
]
```

然后在目标中引入：

```swift
.product(name: "PagingView", package: "PagingView")
```

## 快速开始

### UIKit

```swift
import PagingView
import UIKit

final class DemoViewController: UIViewController, PagingViewDataSource {

    private lazy var pagingView = PagingView(dataSource: self)
    private let segmentedView = SegmentedView()
    private let titles = ["A", "B", "C"]
    private let dataSource = SegmentedTitleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.titles = titles
        segmentedView.dataSource = dataSource
        segmentedView.contentScrollView = pagingView.listCollectionView

        view.addSubview(pagingView)
        pagingView.frame = view.bounds
    }

    func heightForHeaderView(in pagingView: PagingView) -> CGFloat { 200 }
    func headerView(in pagingView: PagingView) -> UIView { UIView() }
    func heightForSegmentedView(in pagingView: PagingView) -> CGFloat { 44 }
    func offsetYForSegmentedView(in pagingView: PagingView) -> CGFloat { 0 }
    func segmentedView(in pagingView: PagingView) -> UIView { segmentedView }
    func numberOfLists(in pagingView: PagingView) -> Int { titles.count }

    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> PagingViewListProtocol {
        DemoListViewController()
    }
}
```

### SwiftUI

```swift
import PagingView
import SwiftUI

struct DemoView: View {
    let titles = ["A", "B", "C"]

    var body: some View {
        PagerView(
            titles,
            header: {
                Text("Header")
                    .frame(maxWidth: .infinity, minHeight: 160)
            },
            content: { _, _ in
                Page(
                    data: Array(0...20),
                    item: { _, value in Text("\(value)") },
                    loadingView: { ProgressView() },
                    noDataView: { Text("No Data") }
                )
            }
        )
        .titleSelectedColor(.blue)
        .indicatorColor(.blue)
    }
}
```

更多用法可参考：

- [SwiftUIExample](/Users/sun/projects/github/PagingView/SwiftUIExample)
- [UIKitExample](/Users/sun/projects/github/PagingView/UIKitExample)

当前两个目录的示例页面已合并到同一个 Demo target 中运行，启动后可在 App 内分别进入 `UIKit` 与 `SwiftUI` 分区。

## 项目结构

```text
PagingView/
├── PagingView/          # 核心库代码
├── PagingViewTests/     # 测试目标（待继续完善）
├── SwiftUIExample/      # SwiftUI 示例页面源码
└── UIKitExample/        # Demo App 与 UIKit 示例页面源码
```

## 本地验证

```bash
xcodebuild build -workspace .swiftpm/xcode/package.xcworkspace -scheme PagingView -destination 'generic/platform=iOS Simulator'
xcodebuild test -workspace .swiftpm/xcode/package.xcworkspace -scheme PagingView -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild build -project PagingView.xcodeproj -scheme UIKitExample -destination 'generic/platform=iOS Simulator'
```

## 路线

- 补齐测试与回归验证
- 继续拆分超大文件，降低维护成本
- 提升 SwiftUI 状态驱动与配置能力
- 增加版本标签与变更日志

## 许可证

本项目基于 [MIT License](./LICENSE) 开源。
