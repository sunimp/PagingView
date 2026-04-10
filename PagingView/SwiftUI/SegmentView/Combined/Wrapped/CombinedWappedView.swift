//
//  CombinedWappedView.swift
//  PagingView
//
//  Created by Sun on 2024/8/1.
//

import UIKit
import SwiftUI

class CombinedWappedView<T: Hashable, C: View, L: View, N: View>: UIView,
                                                                  SegmentedViewDelegate,
                                                                  SegmentedViewContainerDataSource {
    
    let segmentedView: SegmentedView
    let listContainerView: SegmentedListContainerView
    var pages: [Page<T, C, L, N>]
    
    var segmentedHeight: CGFloat
    
    var dataSource: SegmentedTitleDataSource
    var indicator: SegmentedIndicatorView
    
    var foregroundColor: UIColor
    var defaultSelectedIndex: Int
    var isSyncScrollingWhenScrollListContainer: Bool
    
    var onDidScroll: ((CGFloat) -> Void)?
    var onSelect: ((Int) -> Void)?
    
    private var heightConstraint: NSLayoutConstraint?
    
    init(
        segmentedHeight: CGFloat,
        foregroundColor: UIColor,
        defaultSelectedIndex: Int,
        isSyncScrollingWhenScrollListContainer: Bool,
        dataSource: SegmentedTitleDataSource,
        indicator: SegmentedIndicatorView,
        pages: [Page<T, C, L, N>],
        onDidScroll: ((CGFloat) -> Void)?,
        onSelect: ((Int) -> Void)?
    ) {
        self.segmentedView = SegmentedView()
        self.listContainerView = SegmentedListContainerView()
        self.segmentedHeight = segmentedHeight
        self.foregroundColor = foregroundColor
        self.defaultSelectedIndex = defaultSelectedIndex
        self.isSyncScrollingWhenScrollListContainer = isSyncScrollingWhenScrollListContainer
        self.dataSource = dataSource
        self.indicator = indicator
        self.pages = pages
        self.onDidScroll = onDidScroll
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
        self.addSubview(self.segmentedView)
        self.segmentedView.translatesAutoresizingMaskIntoConstraints = false
        
        self.listContainerView.dataSource = self
        self.listContainerView.backgroundColor = self.foregroundColor
        self.segmentedView.listContainer = self.listContainerView
        self.addSubview(self.listContainerView)
        self.listContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = self.segmentedView.heightAnchor.constraint(equalToConstant: self.segmentedHeight)
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            self.segmentedView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.segmentedView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.segmentedView.topAnchor.constraint(equalTo: self.topAnchor),
            heightConstraint,
            
            self.listContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.listContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.listContainerView.topAnchor.constraint(equalTo: self.segmentedView.bottomAnchor),
            self.listContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func reloadData() {
        if self.heightConstraint?.constant != self.segmentedHeight {
            self.heightConstraint?.constant = self.segmentedHeight
        }
        if self.segmentedView.delegate == nil {
            self.segmentedView.delegate = self
        }
        self.segmentedView.dataSource = self.dataSource
        self.segmentedView.indicators = [self.indicator]
        self.segmentedView.backgroundColor = self.foregroundColor
        self.segmentedView.defaultSelectedIndex = self.defaultSelectedIndex
        self.segmentedView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        self.segmentedView.reloadData()
        self.listContainerView.backgroundColor = self.foregroundColor
        self.segmentedView.listContainer = self.listContainerView
        self.listContainerView.reloadData()
    }
    
    // MARK: - SegmentedViewDelegate
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        self.onSelect?(index)
    }
    
    // MARK: - SegmentedViewContainerDataSource
    
    func numberOfLists(in listContainerView: SegmentedListContainerView) -> Int {
        self.dataSource.dataSource.count
    }
    
    func listContainerView(
        _ listContainerView: SegmentedListContainerView,
        initListAt index: Int
    ) -> SegmentedViewListProtocol {
        self.pages[index]
    }
}
