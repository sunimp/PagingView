//
//  RootView.swift
//  SwiftUIExample
//
//  Created by Sun on 2024/8/2.
//

import SwiftUI

struct RootView: View {
    
    static let titles = [
        "Alphabet",
        "Alibaba",
        "Amazon",
        "Apple",
        "eBay",
        "Meta",
        "Microsoft",
        "Netflix",
        "Oracle",
        "Tesla",
        "X",
        "Yandex"
    ]
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ExampleItemView(
                    title: "Pager",
                    color: .blue,
                    destination: {
                        PagerViewExample(titles: Self.titles)
                    }
                )
                ExampleItemView(
                    title: "Combined Segment",
                    color: .green,
                    destination: {
                        SegmentViewExample1(titles: Self.titles)
                    }
                )
                ExampleItemView(
                    title: "Detached Segment",
                    color: .red,
                    destination: {
                        SegmentViewExample2(titles: Self.titles)
                    }
                )
            }
            .navigationTitle("PagerView-SwiftUI")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

struct ExampleItemView<Destination>: View where Destination: View {
    
    let title: String
    let color: Color
    let destination: () -> Destination
    
    init(
        title: String,
        color: Color,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.color = color
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink {
            destination()
                .navigationTitle(title)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(maxHeight: .infinity)
                Text(title)
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
        }

    }
}

#Preview {
    RootView()
}
