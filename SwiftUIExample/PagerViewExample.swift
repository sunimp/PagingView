//
//  PagerViewExample.swift
//  SwiftUIExample
//
//  Created by Sun on 2026/4/10.
//

import PagingView
import SwiftUI

struct PagerViewExample: View {
    let titles: [String]

    var body: some View {
        PagerView(
            titles,
            header: { EditorialHeaderView(channel: ShowcaseCatalog.channel) },
            defaultSelectedIndex: titles.startIndex,
            content: { _, title in
                let items = ShowcaseCatalog.pagerItems(for: title)
                return Page(
                    data: items,
                    item: { row, item in
                        EditorialCardView(item: item, index: row)
                    },
                    loadingView: { ProgressView().padding(.vertical, 40) },
                    noDataView: { Text("No Data") }
                )
                .contentInset(.only(bottom: UIUtils.safeAreaInsets.bottom + 16))
            }
        )
        .headerHeight(280)
        .segmentedHeight(54)
        .indicatorColor(Color(uiColor: ShowcaseTone.cobalt.color))
        .indicatorHeight(4)
        .indicatorWidthIncrement(24)
        .indicatorCornerRadius(2)
        .titleNormalColor(Color.black.opacity(0.58))
        .titleSelectedColor(Color(uiColor: ShowcaseTone.cobalt.color))
        .titleNormalFont(.systemFont(ofSize: 15, weight: .semibold))
        .titleSelectedFont(.systemFont(ofSize: 15, weight: .bold))
        .itemSpacing(24)
        .itemWidthIncrement(18)
        .isSyncScrollingWhenScrollListContainer(false)
        .background(Color(uiColor: UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1)))
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct EditorialHeaderView: View {
    let channel: ShowcaseChannel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: channel.tone.gradientColors.map(Color.init(uiColor:)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .blur(radius: 3)
                    .offset(x: 32, y: -20)
            }

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(channel.subtitle.uppercased())
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                    Spacer()
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 92, height: 92)
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: "waveform.path.ecg.rectangle")
                                    .font(.system(size: 22, weight: .bold))
                                Text("LIVE")
                                    .font(.system(size: 12, weight: .black))
                            }
                            .foregroundStyle(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(channel.title)
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(channel.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    EditorialMetricChip(metric: channel.primaryMetric)
                    EditorialMetricChip(metric: channel.secondaryMetric)
                    EditorialMetricChip(metric: channel.tertiaryMetric)
                }

                HStack {
                    Text(channel.audience)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.82))
                    Spacer()
                    Text(channel.updateNote)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .padding(24)
        }
    }
}

private struct EditorialMetricChip: View {
    let metric: ShowcaseMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(metric.value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(metric.label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct EditorialCardView: View {
    let item: ShowcaseItem
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                badgeStrip
                Spacer()
                Text("#\(index + 1)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(Color(uiColor: item.tone.color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: item.tone.softColor))
                    .clipShape(Capsule())
            }

            Group {
                switch item.style {
                case .hero:
                    heroContent
                case .editorial:
                    editorialContent
                case .compact:
                    compactContent
                case .stat:
                    statContent
                case .mosaic:
                    mosaicContent
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 14, y: 8)
    }

    private var badgeStrip: some View {
        HStack(spacing: 8) {
            ForEach(item.badges, id: \.self) { badge in
                Text(badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(uiColor: item.tone.color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: item.tone.softColor))
                    .clipShape(Capsule())
            }
        }
    }

    private var heroContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: item.tone.gradientColors.map(Color.init(uiColor:)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .padding(20)
                }

            Text(item.note)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            metricGrid
        }
    }

    private var editorialContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(item.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Divider()
            Text(item.note)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
            metricGrid
        }
    }

    private var compactContent: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: item.tone.softColor))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(uiColor: item.tone.color))
                )
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(item.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(item.note)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(uiColor: item.tone.color))
            }
        }
    }

    private var statContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(item.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(item.note)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(item.metrics, id: \.label) { metric in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric.value)
                            .font(.system(size: 20, weight: .bold))
                        Text(metric.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: item.tone.softColor))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private var mosaicContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.system(size: 21, weight: .bold, design: .rounded))
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: item.tone.softColor))
                    .frame(height: 110)
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(uiColor: item.tone.mutedColor))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(uiColor: item.tone.softColor))
                }
                .frame(width: 110, height: 110)
            }
            Text(item.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private var metricGrid: some View {
        HStack(spacing: 10) {
            ForEach(item.metrics, id: \.label) { metric in
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
}

extension UIEdgeInsets {
    static func only(
        top: CGFloat = .zero,
        left: CGFloat = .zero,
        bottom: CGFloat = .zero,
        right: CGFloat = .zero
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

#Preview {
    PagerViewExample(titles: ShowcaseCatalog.pagerTitles)
}
