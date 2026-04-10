//
//  SegmentWappedView.swift
//  PagingView
//
//  Created by Sun on 2024/8/1.
//

import UIKit
import SwiftUI

class SegmentWappedView: UIView, SegmentedViewDelegate {
    
    let segmentedView: SegmentedView
    
    var dataSource: SegmentedTitleDataSource
    var indicator: SegmentedIndicatorView
    
    var foregroundColor: UIColor
    var defaultSelectedIndex: Int
    var isSyncScrollingWhenScrollListContainer: Bool
    
    var listContainer: SegmentedViewListContainer?
    var onSelect: ((Int) -> Void)?
    
    init(
        foregroundColor: UIColor,
        defaultSelectedIndex: Int,
        isSyncScrollingWhenScrollListContainer: Bool,
        dataSource: SegmentedTitleDataSource,
        indicator: SegmentedIndicatorView,
        listContainer: SegmentedViewListContainer?,
        onSelect: ((Int) -> Void)?
    ) {
        self.segmentedView = SegmentedView()
        self.foregroundColor = foregroundColor
        self.defaultSelectedIndex = defaultSelectedIndex
        self.isSyncScrollingWhenScrollListContainer = isSyncScrollingWhenScrollListContainer
        self.dataSource = dataSource
        self.indicator = indicator
        self.listContainer = listContainer
        self.onSelect = onSelect
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.segmentedView.backgroundColor = self.foregroundColor
        self.segmentedView.delegate = self
        self.segmentedView.dataSource = self.dataSource
        self.segmentedView.indicators = [self.indicator]
        self.segmentedView.defaultSelectedIndex = self.defaultSelectedIndex
        self.segmentedView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        self.segmentedView.listContainer = self.listContainer
        self.addSubview(self.segmentedView)
        self.segmentedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.segmentedView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.segmentedView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.segmentedView.topAnchor.constraint(equalTo: self.topAnchor),
            self.segmentedView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func reloadData() {
        if self.segmentedView.delegate == nil {
            self.segmentedView.delegate = self
        }
        self.segmentedView.dataSource = self.dataSource
        self.segmentedView.indicators = [self.indicator]
        self.segmentedView.backgroundColor = self.foregroundColor
        self.segmentedView.defaultSelectedIndex = self.defaultSelectedIndex
        self.segmentedView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        self.segmentedView.listContainer = self.listContainer
        self.segmentedView.reloadData()
    }
    
    // MARK: - SegmentedViewDelegate
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        self.onSelect?(index)
    }
}

