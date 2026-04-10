//
//  ListContainerWrappedRepresentableView.swift
//  PagingView
//
//  Created by Sun on 2024/8/1.
//

import UIKit
import SwiftUI

struct ListContainerWrappedRepresentableView<T: Hashable, C: View, L: View, N: View>: UIViewRepresentable {
    
    let wrapperView: ListContainerWappedView<T, C, L, N>
    let pages: [Page<T, C, L, N>]
    
    var count: Int
    var foregroundColor: Color
    
    var onListContainer: ((SegmentedListContainerView) -> Void)?
    var onDidScroll: ((CGFloat) -> Void)?
    
    init(
        foregroundColor: Color,
        count: Int,
        pages: [Page<T, C, L, N>],
        onListContainer: ((SegmentedListContainerView) -> Void)?,
        onDidScroll: ((CGFloat) -> Void)?
    ) {
        self.wrapperView = ListContainerWappedView(
            foregroundColor: UIColor(foregroundColor),
            count: count,
            pages: pages,
            onListContainer: onListContainer,
            onDidScroll: onDidScroll
        )
        self.count = count
        self.foregroundColor = foregroundColor
        self.pages = pages
        self.onListContainer = onListContainer
        self.onDidScroll = onDidScroll
    }
    
    func makeUIView(context: Context) -> ListContainerWappedView<T, C, L, N> {
        return self.wrapperView
    }
    
    func updateUIView(_ wrapperView: ListContainerWappedView<T, C, L, N>, context: Context) {
        wrapperView.pages = self.pages
        wrapperView.count = self.count
        wrapperView.foregroundColor = UIColor(self.foregroundColor)
        wrapperView.onListContainer = self.onListContainer
        wrapperView.onDidScroll = self.onDidScroll
        wrapperView.reloadData()
    }
}
