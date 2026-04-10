//
//  Page.swift
//  PagingView
//
//  Created by Sun on 2024/7/29.
//

import UIKit
import SwiftUI

public class Page<T: Hashable, C: View, L: View, N: View>: PagingViewListProtocol,
                                                           SegmentedViewListProtocol {
    
    let tableView: TableView<T, C, L, N>
    
    public init(
        data: [T]?,
        @ViewBuilder item: @escaping (Int, T) -> C,
        @ViewBuilder loadingView: @escaping () -> L,
        @ViewBuilder noDataView: @escaping () -> N,
        didScroll: ((CGFloat) -> Void)? = nil
    ) {
        self.tableView = TableView(
            data: data,
            item: item,
            loadingView: loadingView,
            noDataView: noDataView,
            didScroll: didScroll
        )
    }
    
    public func reloadData() {
        self.tableView.reloadData()
    }
    
    public func listView() -> UIView {
        return self.tableView
    }
    
    public func listScrollView() -> UIScrollView {
        return self.tableView.internalTableView
    }
}

extension Page {
    
    /// The contentInset of the UITableView inside a Page.
    ///
    /// - Parameters:
    ///   - insets: UIEdgeInsets value
    /// - Attention: The top value will be ignored
    /// - Returns: An instance of self
    public func contentInset(_ insets: UIEdgeInsets = .zero) -> Self {
        let fixedInsets = UIEdgeInsets(
            top: 0,
            left: insets.left,
            bottom: insets.bottom,
            right: insets.right
        )
        self.tableView.internalTableView.contentInset = fixedInsets
        return self
    }
    
}
