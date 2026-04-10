//
//  CombinedWappedRepresentableView.swift
//  PagingView
//
//  Created by Sun on 2024/7/31.
//

import UIKit
import SwiftUI

struct CombinedWappedRepresentableView<T: Hashable, C: View, L: View, N: View>: UIViewRepresentable {
    
    let combinedView: CombinedWappedView<T, C, L, N>
    let pages: [Page<T, C, L, N>]
    
    let dataSource: SegmentedTitleDataSource
    let indicator: SegmentedIndicatorView
    
    var segmentedHeight: CGFloat
    var foregroundColor: Color
    var defaultSelectedIndex: Int
    var isSyncScrollingWhenScrollListContainer: Bool
    
    var onDidScroll: ((CGFloat) -> Void)?
    var onSelect: ((Int) -> Void)?
    
    init(
        segmentedHeight: CGFloat,
        foregroundColor: Color,
        defaultSelectedIndex: Int,
        isSyncScrollingWhenScrollListContainer: Bool,
        dataSource: SegmentedTitleDataSource,
        indicator: SegmentedIndicatorView,
        pages: [Page<T, C, L, N>],
        onDidScroll: ((CGFloat) -> Void)?,
        onSelect: ((Int) -> Void)?
    ) {
        self.combinedView = CombinedWappedView(
            segmentedHeight: segmentedHeight,
            foregroundColor: UIColor(foregroundColor),
            defaultSelectedIndex: defaultSelectedIndex,
            isSyncScrollingWhenScrollListContainer: isSyncScrollingWhenScrollListContainer,
            dataSource: dataSource,
            indicator: indicator,
            pages: pages,
            onDidScroll: onDidScroll,
            onSelect: onSelect
        )
        self.segmentedHeight = segmentedHeight
        self.foregroundColor = foregroundColor
        self.defaultSelectedIndex = defaultSelectedIndex
        self.isSyncScrollingWhenScrollListContainer = isSyncScrollingWhenScrollListContainer
        self.dataSource = dataSource
        self.indicator = indicator
        self.pages = pages
        self.onDidScroll = onDidScroll
        self.onSelect = onSelect
    }
    
    func makeUIView(context: Context) -> CombinedWappedView<T, C, L, N> {
        return self.combinedView
    }
    
    func updateUIView(_ containerView: CombinedWappedView<T, C, L, N>, context: Context) {
        containerView.pages = self.pages
        containerView.segmentedHeight = self.segmentedHeight
        containerView.dataSource = self.dataSource
        containerView.indicator = self.indicator
        containerView.foregroundColor = UIColor(self.foregroundColor)
        containerView.defaultSelectedIndex = self.defaultSelectedIndex
        containerView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        containerView.onSelect = self.onSelect
        containerView.onDidScroll = self.onDidScroll
        containerView.reloadData()
    }
}
