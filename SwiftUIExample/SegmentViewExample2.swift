//
//  SegmentViewExample2.swift
//  SwiftUIExample
//
//  Created by Sun on 2024/8/2.
//

import SwiftUI

import PagingView

struct SegmentViewExample2: View {
    
    let titles: [String]
    @State private var listContainer: SegmentedListContainerView?
    
    var body: some View {
        ListContentView(
            titles: self.titles,
            onListContainer: { listContainer in
                DispatchQueue.main.async {
                    self.listContainer = listContainer
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                TitleView(titles: self.titles, listContainer: self.$listContainer)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TitleView: View {
    
    let titles: [String]
    
    @Binding var listContainer: SegmentedListContainerView?
    
    var body: some View {
        SegmentView(
            self.titles,
            segmentedHeight: 45,
            defaultSelectedIndex: titles.endIndex - 1,
            listContainer: self.listContainer
        )
        .indicatorColor(.red)
        .titleSelectedColor(.red)
        .didSelect { newIndex in
            print("Did select: \(newIndex)")
        }
    }
}

struct ListContentView: View {
    
    let titles: [String]
    var onListContainer: ((SegmentedListContainerView) -> Void)?
    
    var body: some View {
        SegmentListContainerView(
            self.titles.count,
            content: { _ in
                Page(
                    data: Array(0...100),
                    item: { row, value in
                        VStack {
                            if row.isMultiple(of: 2) {
                                Text("Even Row: \(row), Value: \(value)")
                            } else {
                                Text("Odd Row: \(row)")
                                Text("Value: \(value)")
                            }
                            Divider()
                        }
                    },
                    loadingView: { Text("Loading...") },
                    noDataView: { Text("No Data") }
                )
                .contentInset(.only(bottom: UIUtils.safeAreaInsets.bottom))
            }
        )
        .onListContainer { listContainer in
            self.onListContainer?(listContainer)
        }
    }
}

#Preview {
    SegmentViewExample2(titles: RootView.titles)
}
