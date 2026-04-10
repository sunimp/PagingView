//
//  RootView.swift
//  SwiftUIExample
//
//  Created by Sun on 2026/4/10.
//

import SwiftUI

struct RootView: View {
    static let titles = ShowcaseCatalog.pagerTitles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeroPanelView()
                DemoLinkCard(
                    title: "Editorial Pager",
                    subtitle: "带头图、统计和多层次内容流的沉浸式频道页。",
                    tint: .orange,
                    destination: PagerViewExample(titles: ShowcaseCatalog.pagerTitles)
                )
                DemoLinkCard(
                    title: "Combined Segment Canvas",
                    subtitle: "将分段与内容合并在同一区域，适合高密度信息切换。",
                    tint: .pink,
                    destination: SegmentViewExample1(titles: ShowcaseCatalog.combinedTitles)
                )
                DemoLinkCard(
                    title: "Toolbar Segment Deck",
                    subtitle: "把分段驻留在工具栏，让内容区域保持完全独立。",
                    tint: .red,
                    destination: SegmentViewExample2(titles: ListType.allCases.map(\.title))
                )
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: ShowcaseTone.slate.softColor),
                    Color.white,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("SwiftUI Gallery")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct HeroPanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("SwiftUI Showcase")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("用同一套 `PagingView` 能力，演示沉浸式 Pager、紧凑型 Combined Segment 和导航栏分段容器。")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                HeroMetricView(value: "3", title: "Patterns")
                HeroMetricView(value: "6", title: "Tabs")
                HeroMetricView(value: "A+", title: "Depth")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: ShowcaseTone.plum.gradientColors.map(Color.init(uiColor:)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 22, y: 12)
    }
}

private struct HeroMetricView: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DemoLinkCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let tint: Color
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.14))
                    .frame(width: 58, height: 58)
                    .overlay(
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(tint)
                    )
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Open Demo")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(tint)
                    .padding(.top, 4)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        RootView()
    }
}
