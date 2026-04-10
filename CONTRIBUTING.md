# Contributing

感谢你关注 `PagingView`。

## 提交问题

- Bug 请尽量提供最小复现、系统版本、Xcode 版本和预期行为
- 新功能建议请先说明使用场景、API 设计方向和兼容性影响
- 安全问题不要通过公开 Issue 提交，先阅读 [SECURITY.md](./SECURITY.md)

## 提交代码

- 保持改动聚焦，避免无关重构混入同一个 PR
- 如涉及对外行为变化，请同步更新 README 或示例
- 如涉及 UI 行为，请在 PR 中补充截图、录屏或操作说明
- 如涉及公共 API 调整，请明确说明兼容性影响与迁移方式

## 本地检查

提交前建议至少完成以下构建：

```bash
xcodebuild build -workspace .swiftpm/xcode/package.xcworkspace -scheme PagingView -destination 'generic/platform=iOS Simulator'
xcodebuild test -workspace .swiftpm/xcode/package.xcworkspace -scheme PagingView -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild build -project PagingView.xcodeproj -scheme UIKitExample -destination 'generic/platform=iOS Simulator'
```

当前测试基线仍在完善中；如果你的修改影响滚动联动、列表生命周期或指示器行为，请尽量补充验证说明。
