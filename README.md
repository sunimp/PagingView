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
- 支持命令式滚动到 Idle / Pinned 状态
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
- [Example](/Users/sun/projects/github/PagingView/Example)

当前示例页统一运行在 `Example` target 中，启动后可在 App 内分别进入 `UIKit` 与 `SwiftUI` 分区。

## Demo 说明

Demo App 当前包含以下页面：

- UIKit
  - `Paging Header Studio`：大头图、吸顶分段、滚动状态与命令式控制
  - `Detached Segment Lab`：分段与列表容器分离的组合方式
- SwiftUI
  - `Editorial Pager`：`PagerView` 头图 + 分段 + 内容流
  - `Combined Segment Canvas`：组合式分段与内容区域
  - `Toolbar Segment Deck`：顶部工具栏分段 + 独立内容区

其中 `Paging Header Studio` 额外覆盖了：

- `automaticDimension` Header 高度测量
- Header 吸顶与列表滚动联动
- 横向分页切换时的 Header 同步
- 列表内容卡片与分段吸顶共存的场景

## 项目结构

```text
PagingView/
├── PagingView/          # 核心库代码
├── PagingViewTests/     # 测试目标（待继续完善）
├── Example/             # Demo App 与 UIKit 示例页面源码
├── SwiftUIExample/      # SwiftUI 示例页面源码
└── README.md
```

## 本地验证

```bash
swift build
swift test
xcodebuild -project PagingView.xcodeproj -scheme PagingView -configuration Debug -destination 'generic/platform=iOS Simulator' build
xcodebuild -project PagingView.xcodeproj -scheme Example -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

## 路线

- 补齐测试与回归验证
- 继续拆分超大文件，降低维护成本
- 提升 SwiftUI 状态驱动与配置能力
- 增加版本标签与变更日志

## 许可证

本项目基于 [MIT License](./LICENSE) 开源。
