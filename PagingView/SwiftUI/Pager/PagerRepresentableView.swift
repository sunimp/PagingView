//
//  PagerRepresentableView.swift
//  PagingView
//
//  Created by Sun on 2024/7/29.
//

import UIKit
import SwiftUI

struct PagerRepresentableView<H: View, T: Hashable, C: View, L: View, E: View> {
    
    let pagingView: PagingView
    let segmentedView: SegmentedView
    
    let headerView: HeaderView<H>
    let pages: [Page<T, C, L, E>]
    
    var headerHeight: CGFloat
    var segmentedHeight: CGFloat
    var segmentedOffsetY: CGFloat
    
    let dataSource: SegmentedTitleDataSource
    let indicator: SegmentedIndicatorView
    
    var defaultSelectedIndex: Int
    var isFillContentSizeAutomatically: Bool
    var isSyncScrollingWhenScrollListContainer: Bool
    
    var onDidScroll: ((CGFloat) -> Void)?
    var onSelect: ((Int) -> Void)?
    
    init(
        dataSource: SegmentedTitleDataSource,
        indicator: SegmentedIndicatorView,
        headerHeight: CGFloat,
        segmentedHeight: CGFloat,
        segmentedOffsetY: CGFloat,
        headerView: HeaderView<H>,
        pages: [Page<T, C, L, E>],
        defaultSelectedIndex: Int,
        isFillContentSizeAutomatically: Bool,
        isSyncScrollingWhenScrollListContainer: Bool,
        onDidScroll: ((CGFloat) -> Void)?,
        onSelect: ((Int) -> Void)?
    ) {
        self.pagingView = PagingView()
        self.segmentedView = SegmentedView()
        
        self.headerHeight = headerHeight
        self.segmentedHeight = segmentedHeight
        self.segmentedOffsetY = segmentedOffsetY
        
        self.headerView = headerView
        self.pages = pages
        self.defaultSelectedIndex = defaultSelectedIndex
        self.isFillContentSizeAutomatically = isFillContentSizeAutomatically
        self.isSyncScrollingWhenScrollListContainer = isSyncScrollingWhenScrollListContainer
        
        self.dataSource = dataSource
        self.indicator = indicator
        
        self.onDidScroll = onDidScroll
        self.onSelect = onSelect
    }
}

extension PagerRepresentableView: UIViewRepresentable {
    
    func makeCoordinator() -> PagerCoordinator<H, T, C, L, E> {
        PagerCoordinator(self)
    }
    
    func makeUIView(context: Context) -> PagingView {
        self.pagingView.dataSource = context.coordinator
        self.pagingView.delegate = context.coordinator
        self.pagingView.defaultSelectedIndex = self.defaultSelectedIndex
        self.pagingView.isFillContentSizeAutomatically = self.isFillContentSizeAutomatically
        
        self.segmentedView.backgroundColor = .white
        self.segmentedView.delegate = context.coordinator
        self.segmentedView.dataSource = self.dataSource
        self.segmentedView.indicators = [self.indicator]
        self.segmentedView.contentScrollView = self.pagingView.listCollectionView
        self.segmentedView.defaultSelectedIndex = self.defaultSelectedIndex
        self.segmentedView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        
        return self.pagingView
    }
  
    func updateUIView(_ pagingView: PagingView, context: Context) {
        context.coordinator.parent = self
        if pagingView.dataSource == nil {
            pagingView.dataSource = context.coordinator
        }
        if pagingView.delegate == nil {
            pagingView.delegate = context.coordinator
        }
        pagingView.isFillContentSizeAutomatically = self.isFillContentSizeAutomatically
        
        self.segmentedView.backgroundColor = .white
        self.segmentedView.contentScrollView = pagingView.listCollectionView
        self.segmentedView.dataSource = self.dataSource
        self.segmentedView.indicators = [self.indicator]
        self.segmentedView.isSyncScrollingWhenScrollListContainer = self.isSyncScrollingWhenScrollListContainer
        
        if self.segmentedView.delegate == nil {
            self.segmentedView.delegate = context.coordinator
        }
        self.segmentedView.defaultSelectedIndex = self.defaultSelectedIndex
        self.segmentedView.reloadData()
        pagingView.reloadData()
        pagingView.defaultSelectedIndex = self.defaultSelectedIndex
    }
}
