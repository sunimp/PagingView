//
//  PagerViewExample.swift
//  SwiftUIExample
//
//  Created by Sun on 2024/8/2.
//

import SwiftUI

import PagingView

struct PagerViewExample: View {
    
    let titles: [String]
    
    @State private var headerHeight: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        PagerView(
            self.titles,
            header: { HeaderView() },
            defaultSelectedIndex: titles.startIndex,
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
                .contentInset(.only(bottom: UIUtils.safeAreaInsets.bottom))
            }
        )
        .indicatorColor(.blue)
        .titleSelectedColor(.blue)
        .itemWidthIncrement(20)
        .isSyncScrollingWhenScrollListContainer(false)
        .didSelect { newIndex in
            print("Did select: \(newIndex)")
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct HeaderView: View {
    
    var title: String = "Vibration Sound Room"
    var subtitle: String = "Too much music, too few ears"
    var coverColor: Color = .blue
    @State var subscribers: Int = Int.random(in: 100000...200000)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 20)
            
            HStack(alignment: .top) {
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 72, height: 72)
                    .foregroundStyle(coverColor)
            }
            
            HStack(spacing: 10) {
                Text("\(subscribers) Subscribers")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    self.subscribers += 1
                }) {
                    Text("+ Subscribe")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 32)
                        .background(Color.black)
                        .cornerRadius(4)
                }
            }
            .padding(.bottom, 10)
        }
        .padding([.leading, .trailing], 20)
    }
}

extension UIEdgeInsets {
    
    static func only(
        top: CGFloat = .zero,
        left: CGFloat = .zero,
        bottom: CGFloat = .zero,
        right: CGFloat = .zero
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

#Preview {
    PagerViewExample(titles: RootView.titles)
}
