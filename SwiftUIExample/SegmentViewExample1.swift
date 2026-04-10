//
//  SegmentViewExample1.swift
//  SwiftUIExample
//
//  Created by Sun on 2024/8/2.
//

import SwiftUI

import PagingView

struct SegmentViewExample1: View {
    
    let titles: [String]
    
    var body: some View {
        CombinedSegmentView(
            self.titles,
            segmentedHeight: 40,
            defaultSelectedIndex: max((titles.endIndex - titles.startIndex) / 2, 0),
            content: { _, _ in
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
            }
        )
        .indicatorColor(.green)
        .titleSelectedColor(.green)
        .didSelect { newIndex in
            print("Did select: \(newIndex)")
        }
    }
}

#Preview {
    SegmentViewExample1(titles: RootView.titles)
}
