//
//  SegmentWappedRepresentableView.swift
//  PagingView
//
//  Created by Sun on 2024/8/1.
//

import UIKit
import SwiftUI

struct SegmentWappedRepresentableView: UIViewRepresentable {
    
    let dataSource: SegmentedTitleDataSource
    let indicator: SegmentedIndicatorView
    
    var foregroundColor: Color
    var defaultSelectedIndex: Int
    
    var onSelect: ((Int) -> Void)?
    var listContainer: SegmentedViewListContainer?
    var isSyncScrollingWhenScrollListContainer: Bool
    
    init(
        foregroundColor: Color,
        defaultSelectedIndex: Int,
        isSyncScrollingWhenScrollListContainer: Bool,
        dataSource: SegmentedTitleDataSource,
        indicator: SegmentedIndicatorView,
        listContainer: SegmentedViewListContainer?,
        onSelect: ((Int) -> Void)?
    ) {
        self.foregroundColor = foregroundColor
        self.defaultSelectedIndex = defaultSelectedIndex
        self.isSyncScrollingWhenScrollListContainer = isSyncScrollingWhenScrollListContainer
        self.dataSource = dataSource
        self.indicator = indicator
        self.listContainer = listContainer
        self.onSelect = onSelect
    }
    
    func makeUIView(context: Context) -> SegmentWappedView {
        let wrapperView = SegmentWappedView(
            foregroundColor: UIColor(self.foregroundColor),
            defaultSelectedIndex: self.defaultSelectedIndex,
            isSyncScrollingWhenScrollListContainer: self.isSyncScrollingWhenScrollListContainer,
            dataSource: self.dataSource,
            indicator: self.indicator,
            listContainer: self.listContainer,
            onSelect: self.onSelect
        )
        return wrapperView
    }
    
    func updateUIView(_ wrapperView: SegmentWappedView, context: Context) {
        wrapperView.dataSource = self.dataSource
        wrapperView.indicator = self.indicator
        wrapperView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        wrapperView.foregroundColor = UIColor(self.foregroundColor)
        wrapperView.listContainer = self.listContainer
        wrapperView.onSelect = self.onSelect
        wrapperView.reloadData()
    }
}
