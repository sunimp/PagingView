//
//  SegmentViewExample1.swift
//  SwiftUIExample
//
//  Created by Sun on 2026/4/10.
//

import PagingView
import SwiftUI

struct SegmentViewExample1: View {
    let titles: [String]

    var body: some View {
        VStack(spacing: 16) {
            CompactHeroView(
                title: "Combined Segment Canvas",
                subtitle: "分段与列表共处同一区域，适合高密度情报和快速切换。",
                tone: .plum
            )
            CombinedSegmentView(
                self.titles,
                segmentedHeight: 44,
                foregroundColor: Color(uiColor: UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)),
                defaultSelectedIndex: 1,
                content: { _, title in
                    let items = ShowcaseCatalog.combinedItems(for: title)
                    return Page(
                        data: items,
                        item: { _, item in
                            CompactDiscoveryCard(item: item)
                        },
                        loadingView: { ProgressView().padding(.vertical, 40) },
                        noDataView: { Text("No Data") }
                    )
                }
            )
            .titleNormalColor(.black.opacity(0.52))
            .titleSelectedColor(Color(uiColor: ShowcaseTone.plum.color))
            .titleNormalFont(.systemFont(ofSize: 14, weight: .semibold))
            .titleSelectedFont(.systemFont(ofSize: 14, weight: .bold))
            .indicatorColor(Color(uiColor: ShowcaseTone.plum.color))
            .indicatorWidthIncrement(26)
            .indicatorHeight(3)
            .indicatorCornerRadius(1.5)
            .itemSpacing(20)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 18, y: 10)
        }
        .padding(20)
        .background(Color(uiColor: UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)))
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct CompactHeroView: View {
    let title: String
    let subtitle: String
    let tone: ShowcaseTone

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: tone.gradientColors.map(Color.init(uiColor:)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 92, height: 92)
                .overlay(
                    Image(systemName: "square.grid.3x2.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, y: 10)
    }
}

private struct CompactDiscoveryCard: View {
    let item: ShowcaseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.badges.first ?? "Highlight")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(uiColor: item.tone.color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: item.tone.softColor))
                    .clipShape(Capsule())
                Spacer()
                Circle()
                    .fill(Color(uiColor: item.tone.color))
                    .frame(width: 9, height: 9)
            }
            Text(item.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(item.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Divider()
            HStack(spacing: 10) {
                ForEach(item.metrics.prefix(2), id: \.label) { metric in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric.value)
                            .font(.system(size: 16, weight: .bold))
                        Text(metric.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: item.tone.softColor))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}

#Preview {
    SegmentViewExample1(titles: ShowcaseCatalog.combinedTitles)
}
