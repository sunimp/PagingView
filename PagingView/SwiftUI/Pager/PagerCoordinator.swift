//
//  PagerCoordinator.swift
//  PagingView
//
//  Created by Sun on 2024/7/29.
//

import UIKit
import SwiftUI

final class PagerCoordinator<H: View, T: Hashable, C: View, L: View, N: View> {
    
    var parent: PagerRepresentableView<H, T, C, L, N>
    
    init(_ parent: PagerRepresentableView<H, T, C, L, N>) {
        self.parent = parent
    }
}

extension PagerCoordinator: PagingViewDataSource {
    // MARK: - PagingViewDataSource
    
    func heightForHeaderView(in pagingView: PagingView) -> CGFloat {
        return self.parent.headerHeight
    }
    
    func headerView(in pagingView: PagingView) -> UIView {
        return self.parent.headerView
    }
    
    func heightForSegmentedView(in pagingView: PagingView) -> CGFloat {
        return self.parent.segmentedHeight
    }
    
    func offsetYForSegmentedView(in pagingView: PagingView) -> CGFloat {
        return self.parent.segmentedOffsetY
    }
    
    func segmentedView(in pagingView: PagingView) -> UIView {
        return self.parent.segmentedView
    }
    
    func numberOfLists(in pagingView: PagingView) -> Int {
        return self.parent.dataSource.titles.count
    }
    
    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> any PagingViewListProtocol {
        let page = self.parent.pages[index]
        page.reloadData()
        return page
    }
}

extension PagerCoordinator: PagingViewDelegate {
    // MARK: - PagingViewDelegate
    
    func pagingViewCurrentListViewDidScroll(_ pagingView: PagingView, scrollView: UIScrollView, contentOffset: CGPoint) {
        self.parent.onDidScroll?(contentOffset.y)
    }
}

extension PagerCoordinator: SegmentedViewDelegate {
    // MARK: - SegmentedViewDelegate
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        self.parent.onSelect?(index)
    }
}
