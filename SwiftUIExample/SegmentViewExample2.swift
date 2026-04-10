//
//  SegmentViewExample2.swift
//  SwiftUIExample
//
//  Created by Sun on 2026/4/10.
//

import PagingView
import SwiftUI

struct SegmentViewExample2: View {
    let titles: [String]

    @State private var listContainer: SegmentedListContainerView?

    var body: some View {
        VStack(spacing: 14) {
            DetachedSummaryStrip()
            ListContentView(
                titles: self.titles,
                onListContainer: { listContainer in
                    DispatchQueue.main.async {
                        self.listContainer = listContainer
                    }
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color(uiColor: UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)))
        .toolbar {
            ToolbarItem(placement: .principal) {
                TitleView(titles: self.titles, listContainer: self.$listContainer)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct DetachedSummaryStrip: View {
    var body: some View {
        HStack(spacing: 12) {
            SummaryPill(title: "Mode", value: "Toolbar", tone: .coral)
            SummaryPill(title: "Cards", value: "Hybrid", tone: .amber)
            SummaryPill(title: "Focus", value: "Fast", tone: .mint)
        }
    }
}

private struct SummaryPill: View {
    let title: String
    let value: String
    let tone: ShowcaseTone

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(uiColor: tone.color))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(uiColor: tone.softColor), lineWidth: 1)
        )
    }
}

struct TitleView: View {
    let titles: [String]

    @Binding var listContainer: SegmentedListContainerView?

    var body: some View {
        SegmentView(
            titles,
            segmentedHeight: 42,
            defaultSelectedIndex: 0,
            listContainer: listContainer
        )
        .indicatorColor(Color(uiColor: ShowcaseTone.coral.color))
        .indicatorHeight(3)
        .indicatorWidthIncrement(22)
        .titleNormalColor(.black.opacity(0.48))
        .titleSelectedColor(Color(uiColor: ShowcaseTone.coral.color))
        .titleNormalFont(.systemFont(ofSize: 14, weight: .semibold))
        .titleSelectedFont(.systemFont(ofSize: 14, weight: .bold))
        .frame(width: min(UIUtils.screenWidth * 0.7, 320))
    }
}

struct ListContentView: View {
    let titles: [String]

    var onListContainer: ((SegmentedListContainerView) -> Void)?

    var body: some View {
        SegmentListContainerView(
            titles.count,
            content: { index in
                let listType = ListType.allCases[index]
                let items = ShowcaseCatalog.items(for: listType)
                return Page(
                    data: items,
                    item: { _, item in
                        DetachedFlowCard(item: item, listType: listType)
                    },
                    loadingView: { ProgressView().padding(.vertical, 40) },
                    noDataView: { Text("No Data") }
                )
                .contentInset(.only(bottom: UIUtils.safeAreaInsets.bottom + 20))
            }
        )
        .onListContainer { listContainer in
            self.onListContainer?(listContainer)
        }
    }
}

private struct DetachedFlowCard: View {
    let item: ShowcaseItem
    let listType: ListType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(listType.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(uiColor: listType.tone.color))
                    Text(item.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                Spacer()
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: item.tone.softColor))
                    .frame(width: 68, height: 68)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(uiColor: item.tone.color))
                    )
            }

            Text(item.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text(item.note)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

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
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .padding(.vertical, 7)
    }

    private var iconName: String {
        switch listType {
        case .recent:
            return "waveform.and.magnifyingglass"
        case .nearby:
            return "location.viewfinder"
        case .all:
            return "books.vertical"
        }
    }
}

#Preview {
    SegmentViewExample2(titles: ListType.allCases.map(\.title))
}
